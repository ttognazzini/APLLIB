**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp('DCTFLDB9') BndDir('APLLIB') Main(Main);

// Build Dictionary From DCTFLD

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDB9PR // Always include the prototype for the current program

Dcl-Ds dta Qualified;
  AcvRow    Like(APLDCT.AcvRow);
  DctNme    Like(APLDCT.DctNme);
  FldNme    Like(APLDCT.FldNme);
  FldTyp    Like(APLDCT.FldTyp);
  FldLen    Like(APLDCT.FldLen);
  FldScl    Like(APLDCT.FldScl);
  FldAlc    Like(APLDCT.FldAlc);
  ColTxt    Like(APLDCT.ColTxt);
  ColHdg    Like(APLDCT.ColHdg);
  AlwNul    Like(APLDCT.AlwNul);
  DftVal    Like(APLDCT.DftVal);
  FldNmeSql Like(APLDCT.FldNmeSql);
End-Ds;

// field type attributes
Dcl-Ds typ Qualified;
  reqLen like(APLDCT.reqLen);
  alwDec like(APLDCT.alwDec);
  alwAlc like(APLDCT.alwAlc);
End-Ds;


Dcl-S DftValUpp Like(APLDCT.DftVal);
Dcl-S sqlStm Varchar(5120);
Dcl-S Tic Char(1) Inz(x'7D');

Dcl-S DctNme Like(APLDCT.DctNme);
Dcl-S FldNme Like(APLDCT.FldNme);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endmod;

// Main
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDB9');
    pmrDctNme Like(APLDCT.DctNme);
    pmrFldNme Like(APLDCT.FldNme);
  End-Pi;
  DctNme = pmrDctNme;
  FldNme = pmrFldNme;

  If DctNme = *blanks or FldNme = *blanks;
    Return;
  EndIf;

  Exec SQL
    Select AcvRow, DctNme, FldNme, FldTyp, FldLen, FldScl, FldAlc, ColTxt, ColHdg, AlwNul, DftVal,
           FldNmeSql
    Into :dta
    From DCTFLD
    Where DctNme = :DctNme
      and FldNme = :FldNme
    Fetch First Row Only;
  If sqlState > '02';
    Return;
  EndIf;

  // build or clean the SQL Alias
  If dta.FldNmeSql > *blanks;
    dta.FldNmeSql = $BuildSQLAlias(dta.FldNmeSql);
  Else;
    dta.FldNmeSql = $BuildSQLAlias(dta.ColTxt:dta.ColHdg);
  EndIf;
  Exec SQL
    Update DCTFLD
    Set FldNmeSql = :dta.FldNmeSql
    Where (DctNme, FldNme) = (:DctNme, :FldNme);

  // get field type attributes
  Exec sql Select reqLen, alwDec, alwAlc into :typ from FLDTYP where fldTyp = :dta.fldTyp;

  // try to add the field with the SQL name, if it fails add it without, this corrects an issue where
  // some of the SQL names are duplciated becasue in the old system dictionary the prefixes make multiple
  // fields have the same SQL alias
  If not AddField();
    dta.FldNmeSQL = '';
    AddField();
  EndIf;

End-Proc;

Dcl-Proc AddField;
  Dcl-Pi *n Ind;
  End-Pi;

  // add auto reply entry for lost data...
  #$CMD('ADDRPYLE SEQNBR(3333) MSGID(CPA32B2) RPY(''I'')':1);
  #$CMD('CHGJOB INQMSGRPY(*SYSRPYL)':1);

  // Try to create the table incase it doesn't already exist
  sqlStm = 'Create table APLLIB/'+%trim(DctNme) +
               '(active_row for column AcvRow Char(1) not null with default ''1'')';
  Exec SQL Execute Immediate :sqlStm;

  // Remove field from dictionary to allow adding
  // Prevents issues when Field Type changes
  sqlStm = 'Alter Table APLLIB/' + %trim(DctNme)
         + ' Drop Column ' + %trim(dta.FldNme);
  Exec SQL Execute Immediate :sqlStm;

  // If Field inactive, return
  If dta.AcvRow <> '1';
    Return *On;
  EndIf;

  // Add Field to Dictionary
  If dta.FldNmeSql = *blanks;
    sqlStm = 'Alter Table APLLIB/' + %trim(DctNme)
    + ' Add Column ' + %trim(dta.FldNme);
  Else;
    sqlStm = 'Alter Table APLLIB/' + %trim(DctNme)
    + ' Add Column ' + %trim(dta.FldNmeSql)
    + ' For Column ' + %trim(dta.FldNme);
  EndIf;

  If dta.FldTyp = 'IDENTITY';
    sqlStm += ' BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY '
            + '(START WITH 1 INCREMENT by 1)';
    Exec SQL Execute Immediate :sqlStm;
    If sqlState>='02';
      Return *Off;
    EndIf;
    AddColumnData();
    Return *On;
  Else;
    sqlStm += ' ' + %trim(dta.FldTyp);
  EndIf;

  // add length and scale if needed
  If typ.reqLen = 'Y';
    sqlStm += ' (' + %char(dta.FldLen);
    If typ.alwDec = 'Y';
      sqlStm += ',' + %char(dta.FldScl);
    EndIf;
    sqlStm += ')';
  EndIf;

  // add the allocation if needed
  If typ.alwAlc = 'Y' and dta.fldAlc > 0;
    sqlStm += ' ALLOCATE(' + %char(dta.fldAlc) + ')';
  EndIf;

  // Default Values for character field must include in Quotes
  // Unless they are valid SQL Key Words
  Exec SQL Set :DftValUpp = trim(upper(:dta.DftVal));
  If  dta.DftVal > *blanks
  and %scan(%trim(dta.FldTyp):'CHAR¦VARCHAR') > *zeros
  and %scan(Tic:dta.DftVal) = *zeros
  and (DftValUpp <> 'USER' or dta.FldLen < 18);
    dta.DftVal = Tic + %trim(dta.DftVal) + Tic;
  EndIf;

  // Add null and default options
  If dta.AlwNul = 'Y' and dta.DftVal > *blanks;
    sqlStm += ' Default ' + %trim(dta.DftVal);
  ElseIf dta.AlwNul = 'Y' and dta.DftVal = *blanks;
  ElseIf dta.DftVal > *blanks;
    sqlStm += ' Not Null Default ' + %trim(dta.DftVal);
  Else;
    sqlStm += ' Not Null With Default';
  EndIf;

  Exec SQL Execute Immediate :sqlStm;
  If sqlState>='02';
    Return *Off;
  EndIf;

  AddColumnData();

  Return *On;

End-Proc;


// Add Column Text and Headings
Dcl-Proc AddColumnData;

  // Change Column Headings
  sqlStm = 'Label On Column ' + %trim(dta.DctNme) + '.' + %trim(dta.FldNme)
         + ' Is ''' + %trim(dta.ColHdg) + '''';
  Exec SQL Execute Immediate :sqlStm;

  // Change Column Headings

  sqlStm = 'Label On Column ' + %trim(dta.DctNme) + '.' + %trim(dta.FldNme)
         + ' Text Is ''' + %trim(dta.ColTxt)  + '''';
  Exec SQL Execute Immediate :sqlStm;

  // Remove auto reply entry for lost data...
  #$CMD('RMVRPYLE SEQNBR(3333)':1);
  #$CMD('CHGJOB INQMSGRPY(*RQD)':1);

End-Proc;
