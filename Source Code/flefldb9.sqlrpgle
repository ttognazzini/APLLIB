**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*caller) BndDir('APLLIB') Main(Main);

// Rebuild field in a file

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB9PR // Always include the prototype for the current program

// field attributes from the dictionary
Dcl-S  acvRow Like(APLDCT.acvRow);
Dcl-S  fldAlc Like(APLDCT.fldAlc);
Dcl-S  colNme Like(APLDCT.fldNmeSql);
Dcl-S  flefldIdn Like(APLDCT.flefldIdn);
Dcl-S  fldSeq Like(APLDCT.fldSeq);
Dcl-S  fldTyp Like(APLDCT.fldTyp);
Dcl-S  dftVal Like(APLDCT.dftVal);
Dcl-S  strIdn Like(APLDCT.strIdn);
Dcl-S  idnIcm Like(APLDCT.idnIcm);
Dcl-S  encFld Like(APLDCT.encFld);
Dcl-Ds dctDta;
  sysTyp like(APLDCT.sysTyp);
  fldLen like(APLDCT.sysLen);
  fldScl like(APLDCT.fldScl);
  colTxt like(APLDCT.colTxt);
  colHdg like(APLDCT.colHdg);
  alwNul like(APLDCT.alwNul);
  sysDftVal like(APLDCT.dftVal);
  fldNmeSql like(APLDCT.fldNmeSql);
End-Ds;

// field attributes from the DB file
Dcl-S fldExists Ind;
Dcl-Ds fleDta Qualified;
  sysTyp like(APLDCT.sysTyp);
  fldLen like(APLDCT.sysLen);
  fldScl like(APLDCT.fldScl);
  colTxt like(APLDCT.colTxt);
  colHdg like(APLDCT.colHdg);
  alwNul like(APLDCT.alwNul);
  dftVal like(APLDCT.dftVal);
  fldNmeSql like(APLDCT.fldNmeSql);
End-Ds;

// field type attributes
Dcl-Ds typ Qualified;
  reqLen like(APLDCT.reqLen);
  alwDec like(APLDCT.alwDec);
  alwAlc like(APLDCT.alwAlc);
End-Ds;

Dcl-S sqlStm Varchar(5120);

Dcl-S fleLib Like(APLDCT.fleLib);
Dcl-S fleNme Like(APLDCT.fleNme);
Dcl-S fldNme Like(APLDCT.fldNme);
Dcl-S fleMstIdn Like(APLDCT.fleMstIdn);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endmod;

// Main
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDB9');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrFldNme Like(APLDCT.fldNme);
  End-Pi;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  fldNme = pmrFldNme;

  If fleLib = '' or fleNme = '' or fldNme = '';
    Return;
  EndIf;

  // Get the file master id number for the log entries
  Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // Delete field type errors, they will be re-added if this update fails
  Exec SQL Delete from FLEERR where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme)
                                and des in ('Field not created','Field not updated');

  // see if the file exists, it will not the first time through, create it if needed.
  found = *off;
  Exec SQL Select '1' Into :found  From sysTables Where (system_table_schema,system_table_name) = (:fleLib, :fleNme);
  If not found;
    CreateFile();
  EndIf;

  // Get field attributes, override default length, column defaulats and nullable
  Exec SQL
    Select FLEFLD.AcvRow, FldAlc, FldNmeSql, fleFldIdn, fldSeq, dct.fldTyp, dct.dftVal, strIdn, idnIcm,
           encFld,
           typ.sysTyp,
           case when dct.fldLen = 0 then typ.sysLen else dct.fldLen end fldLen,
           FldScl, ColTxt, ColHdg,
           case when alwNul = 'Y' then 'Y' else 'N' end,
           case when fldLvl = 2 then '' -- for identity the system defaults to 0
                when dct.dftVal <> '' then dct.dftVal -- use default from the dictionary
                when dct.alwNul <> 'Y' then typ.dftVal -- if not nullable use the system default
                else '' end dftVal,
           DCT.fldNmeSql
    Into  :acvRow, :fldAlc, :colNme, :flefldIdn, :fldSeq, :fldTyp, :dftVal, :strIdn, :idnIcm, :encFld, :dctDta
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
    Join DCTFLD as dct on (dct.dctNme,dct.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    Join FLDTYP as typ on (typ.fldTyp) = (dct.fldTyp)
    Where (FLEFLD.fleLib,FLEFLD.fleNme,FLEFLD.fldNme) = (:fleLib,:fleNme,:fldNme)
    Fetch First Row Only;
  If sqlState > '02';
    Return;
  EndIf;

  // get attrbiutes from the DB file
  Clear fleDta;
  fldExists = *off;
  Exec SQL
    Select
      '1',
      data_type,
      case when data_type = 'DECFLOAT' and length = 8 then 16
           when data_type = 'DECFLOAT' and length = 16 then 34
           else length end,
      coalesce(numeric_scale,0) numeric_scale,
      coalesce(cast(column_text as char(50) ccsid 37),'') column_text,
      coalesce(cast(column_heading as char(60) ccsid 37),'') column_heading,
      is_nullable,
      coalesce(cast(column_default as varchar(500) ccsid 37),'') column_default,
      column_name
    Into :fldExists, :fleDta
    From syscolumns2
    Where (system_table_schema,system_table_name,system_column_name) = (:fleLib,:fleNme,:fldNme);

  // get field type attributes
  Exec sql Select reqLen, alwDec, alwAlc into :typ from FLDTYP where fldTyp = :fldTyp;

  // If the field is flagged to include encrypted data the length needs to be the field length
  // rounded up to the next 16 byte block + 32
  If encFld = 'Y';
    If %rem(fldLen:16) <> 0;
      fldLen += 16 - %rem(fldLen:16);
    EndIf;
    fldLen += 32;
    If %rem(fldAlc:16) <> 0;
      fldAlc += 16 - %rem(fldAlc:16);
    EndIf;
    fldAlc += 32;
  EndIf;

  // add auto reply entry for lost data...
  #$CMD('ADDRPYLE SEQNBR(3333) MSGID(CPA32B2) RPY(''I'')':1);
  #$CMD('CHGJOB INQMSGRPY(*SYSRPYL)':1);

  // remove the field if needed
  If fldExists and acvRow <> '1';
    RemoveField();
    // add the field to the file
  ElseIf not fldExists and acvRow = '1';
    AddField();
    // Only try to update the field if it does not already exist
  ElseIf dctDta <> fleDta and acvRow = '1';
    UpdateField();
  EndIf;

  // update column headings if needed
  If colHdg <> fleDta.ColHdg and acvRow = '1';
    UpdateHeadings();
  EndIf;

  // update column text if needed
  If colTxt <> fleDta.Coltxt and acvRow = '1';
    UpdateText();
  EndIf;

  // remove auto reply entry for lost data...
  #$CMD('RMVRPYLE SEQNBR(3333)':1);
  #$CMD('CHGJOB INQMSGRPY(*RQD)':1);

End-Proc;


// try to create the table incase it doesn't already exist
Dcl-Proc CreateFile;

  sqlStm = 'Create Table ' + %trim(fleLib) + '/' + %trim(fleNme) +
     '(active_row for column AcvRow Char(1) not null with default ''1'')';
  Exec SQL Execute Immediate :sqlStm;
  If sqlState < '02';
    AddLog('Table Created':'Table created.':'Table ' + %trim(fleLib) + '/' + %trim(fleNme) + ' created.' +
         ' : SQLStm = ' + sqlStm);
  Else;
    AddLog('Create Table Error':'Table '  + %trim(fleLib) + '/' + %trim(fleNme) + ' create failed.':
       'SQLState = ' + sqlState + ' : SQLERRMC = ' + %trim(#$CCHAR(SQLErrMc)) +
       ' : SQLStm = ' + sqlStm);
  EndIf;

End-Proc;


// Drop a field from a file
Dcl-Proc RemoveField;

  sqlStm = 'Alter Table ' + %trim(fleLib) + '/' + %trim(fleNme) + ' Drop Column ' + %trim(fldNme);
  Exec SQL Execute Immediate :sqlStm;
  If sqlState < '02';
    AddLog('Field Dropped':'Field dropped.':'Field ' + %trim(fleLib) + '/' + %trim(fleNme) +
            ',' +%trim(fldNme)+  ' dropped.' +
            '&N SQLStm = ' + sqlStm);
  Else;
    AddLog('Field Drop Error':'Field '  + %trim(fleLib) + '/' + %trim(fleNme) +
            ',' +%trim(fldNme)+  ' dropped failed.':
       'SQLState = ' + sqlState + ' : SQLERRMC = ' + %trim(#$CCHAR(SQLErrMc)) +
       '&N SQLStm = ' + sqlStm);
  EndIf;

End-Proc;


// Add a field to a file
Dcl-Proc AddField;
  Dcl-S bfrFld like(APLDCT.fldNme);
  Dcl-S bfrSeq like(APLDCT.fldSeq);

  If colNme = '';
    sqlStm = 'Alter Table ' + %trim(fleLib) + '/' + %trim(fleNme)
            + ' Add Column ' + %trim(fldNme);
  Else;
    sqlStm = 'Alter Table ' + %trim(fleLib) + '/' + %trim(fleNme)
            + ' Add Column ' + %trim(colNme)
            + ' For Column ' + %trim(fldNme);
  EndIf;

  If fldNme = %trim(fleNme) + 'IDN';
    sqlStm += ' BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY '
            + '(START WITH ';
    If strIdn <> 0;
      sqlStm += %char(strIdn);
    Else;
      sqlStm += '1';
    EndIf;
    sqlStm += ' INCREMENT by ';
    If idnIcm <> 0;
      sqlStm += %char(idnIcm);
    Else;
      sqlStm += '1';
    EndIf;
    sqlStm += ')';
  Else;
    sqlStm += ' ' + %trim(fldTyp);

    // add length and scale if needed
    If typ.reqLen = 'Y';
      sqlStm += ' (' + %char(FldLen);
      If typ.alwDec = 'Y';
        sqlStm += ',' + %char(FldScl);
      EndIf;
      sqlStm += ')';
    EndIf;

    // add the allocation if needed
    If typ.alwAlc = 'Y' and fldAlc > 0;
      sqlStm += ' ALLOCATE(' + %char(fldAlc) + ')';
    EndIf;

    // Default Values for character field must be included in Quotes, unless they are valid SQL Key Words
    If dftVal > '' and fldTyp in %list('CHAR':'VARCHAR') and %scan('''':dftVal) = 0
       and (%upper(dftVal) <> 'USER' or fldLen < 18);
      dftVal = '''' + %trim(dftVal) + '''';
    EndIf;

    // Add null and default options
    If alwNul = 'Y' and dftVal > *blanks;
      sqlStm += ' Default ' + %trim(dftVal);
    ElseIf alwNul = 'Y' and dftVal = *blanks;
    ElseIf dftVal > *blanks;
      sqlStm += ' Not Null Default ' + %trim(dftVal);
    Else;
      sqlStm += ' Not Null With Default';
    EndIf;
  EndIf;

  // If the field is flagged to include encrypted data, add for bit data
  If encFld = 'Y';
    sqlStm += ' for bit data';
  EndIf;

  // Find the first field after this field that actually exists in the file, if one is not found
  // just skip this so the field gets added to the end of the file
  found = *off;
  bfrSeq = fldSeq;
  DoW not found;
    // get insert before field name, the next seq number
    Exec SQL
      select fldNme, fldSeq into :bfrFld, :bfrSeq
      from FLEFLD
      where (FLELIB,FLENME) = (:fleLib,:fleNme) and fldSeq > :bfrSeq
      order by fldSeq
      Limit 1;
    // if there are no fields left to test just leave with found still off
    If sqlState >= '02';
      Leave;
    EndIf;
    // see if the fields exists in the file, if not get the next field and try again
    Exec SQL Select '1' into :found from sysColumns2
             where (system_table_schema,system_table_name,system_column_name) = (:fleLib,:fleNme,:bfrFld);
  EndDo;
  // add before column if applicable
  If found and bfrFld <> '';
    sqlStm += ' Before ' + %trim(bfrFld);
  EndIf;

  Exec SQL Execute Immediate :sqlStm;
  If sqlState>='02';
    AddLog('Field Insert Error':'Field ' + %trim(fldNme) +' insert failed.':
           'SQLState  . . . :   ' + sqlState +
           '&N SQLStm  . . . . :   ' + sqlStm +
           '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
           #$SQLMessageHelp(sqlCode:sqlErrMc) +
           '&N Attributes . . .:   type = ' + %trim(fldTyp) +
                        ', length = ' + %char(fldLen) +
                        ', scale = ' + %char(fldScl) +
                        ', nullable = ' + %trim(alwNul) +
                        ', default = ' + %trim(dftVal) );
    Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des, fldNme, flefldIdn,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Field not created', :fldNme, :flefldIdn,
              'The last creation of this field failed, view the file log for more information.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  Else;
    AddLog('Field Inserted':'Field ' + %trim(fldNme) +' inserted.':
           'Attributes  . . :   type = ' + %trim(fldTyp) +
                     ', length = ' + %char(fldLen) +
                     ', scale = ' + %char(fldScl) +
                     ', nullable = ' + %trim(alwNul) +
                     ', default = ' + %trim(dftVal) +
           '&N SQLStm  . . . . :   ' + sqlStm);

  EndIf;

End-Proc;


// Update an existing field in a file
Dcl-Proc UpdateField;

  // if the DB file attributes match the dictionary atttributes, just return
  If dctDta = fleDta;
    Return;
  EndIf;

  // check for changes in the attributes and try to update each one

  // if the type, length, scale, allocation, allow null or default value changes try to update the file,
  // this will get a loss of data warning, but it will not lose data if the data maps properly.
  If sysTyp <> fleDta.sysTyp or fldLen <> fleDta.fldLen or fldScl <> fleDta.FldScl or
     alwNul <> fleDta.alwNul or dftVal <> fleDta.dftVal or fldNmeSql <> fleDta.fldNmeSql;

    sqlStm = 'Alter Table ' + %trim(fleLib) + '/' + %trim(fleNme)
            + ' Alter Column ' + %trim(fldNme) + ' Set Data Type ';


    If fldNme = %trim(fleNme) + 'IDN';
      sqlStm += ' BIGINT NOT NULL GENERATED ALWAYS AS IDENTITY '
              + '(START WITH ';
      If strIdn <> 0;
        sqlStm += %char(strIdn);
      Else;
        sqlStm += '1';
      EndIf;
      sqlStm += ' INCREMENT by ';
      If idnIcm <> 0;
        sqlStm += %char(idnIcm);
      Else;
        sqlStm += '1';
      EndIf;
      sqlStm += ')';
    Else;
      sqlStm += ' ' + %trim(fldTyp);

      // add length and scale if needed
      If typ.reqLen = 'Y';
        sqlStm += ' (' + %char(FldLen);
        If typ.alwDec = 'Y';
          sqlStm += ',' + %char(FldScl);
        EndIf;
        sqlStm += ')';
      EndIf;

      // add the allocation if needed
      If typ.alwAlc = 'Y' and fldAlc > *zeros;
        sqlStm += ' ALLOCATE(' + %char(fldAlc) + ')';
      EndIf;

      // Default Values for character field must be included in Quotes, unless they are valid SQL Key Words
      If dftVal > '' and fldTyp in %list('CHAR':'VARCHAR') and %scan('''':dftVal) = 0
         and (%upper(dftVal) <> 'USER' or fldLen < 18);
        dftVal = '''' + %trim(dftVal) + '''';
      EndIf;

      // Add null and default options
      If alwNul = 'Y' and dftVal > *blanks;
        sqlStm += ' Default ' + %trim(dftVal);
      ElseIf alwNul = 'Y' and dftVal = *blanks;
      ElseIf dftVal > *blanks;
        sqlStm += ' Not Null Default ' + %trim(dftVal);
      Else;
        sqlStm += ' Not Null With Default';
      EndIf;
    EndIf;

    // If the field is flagged to include encrypted data, add for bit data
    If encFld = 'Y';
      sqlStm += ' for bit data';
    EndIf;

    Exec SQL Execute Immediate :sqlStm;
    If sqlState>='02';
      AddLog('Field Update Error':'Field ' + %trim(fldNme) +' update failed.':
             'SQLState  . . . :   ' + sqlState +
             '&N SQLStm  . . . . :   ' + sqlStm +
             '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
             #$SQLMessageHelp(sqlCode:sqlErrMc) +
             '&N Prior attributes:   type = ' + %trim(fleDta.sysTyp) +
                                   ', length = ' + %char(fleDta.fldLen) +
                                   ', scale = ' + %char(fleDta.fldScl) +
                                   ', nullable = ' + %trim(fleDta.alwNul) +
                                   ', default = ' + %trim(fleDta.dftVal) +
             '&N New attributes  :   type = ' + %trim(fldTyp) +
                              ', length = ' + %char(fldLen) +
                              ', scale = ' + %char(fldScl) +
                              ', nullable = ' + %trim(alwNul) +
                              ', default = ' + %trim(dftVal) );
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des, fldNme, flefldIdn,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Field not updated', :fldNme, :flefldIdn,
              'The last update to this field failed, view the file log for more information.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    Else;
      AddLog('Field Updated':'Field ' + %trim(fldNme) +' updated.':
             'Prior attributes:   type = ' + %trim(fleDta.sysTyp) +
                                   ', length = ' + %char(fleDta.fldLen) +
                                   ', scale = ' + %char(fleDta.fldScl) +
                                   ', nullable = ' + %trim(fleDta.alwNul) +
                                   ', default = ' + %trim(fleDta.dftVal) +
             '&N New attributes  :   type = ' + %trim(fldTyp) +
                            ', length = ' + %char(fldLen) +
                            ', scale = ' + %char(fldScl) +
                            ', nullable = ' + %trim(alwNul) +
                            ', default = ' + %trim(dftVal) +
             '&N SQLStm  . . . . :   ' + sqlStm );
    EndIf;
  EndIf;

End-Proc;


// Change Column Headings
Dcl-Proc UpdateHeadings;

  sqlStm = 'Label On Column ' + %trim(fleLib) + '/' + %trim(fleNme) + '.' + %trim(fldNme) +
            ' Is ''' + %trim(colHdg) + '''';
  Exec SQL Execute Immediate :sqlStm;
  If sqlState>='02';
    AddLog('ColHdg Upd Error':'Field ' + %trim(fldNme) +' column heading update failed.':
           'SQLState  . . . :   ' + sqlState +
           '&N SQLStm  . . . . :   ' + sqlStm +
           '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
           #$SQLMessageHelp(sqlCode:sqlErrMc) +
           '&N Previous Column Heading = ' + %trim(fleDta.colHdg) +
           '&N New Column Heading = ' + %trim(colHdg));
  Else;
    AddLog('ColHdg Updated':'Field ' + %trim(fldNme) +', column heading updated.':
           'Previous Column Heading = ' + %trim(fleDta.colHdg) +
           '&N New Column Heading = ' + %trim(colHdg));
  EndIf;

End-Proc;


// Change Column Text
Dcl-Proc UpdateText;

  sqlStm = 'Label On Column ' + %trim(fleLib) + '/' + %trim(fleNme) + '.' + %trim(fldNme)  +
            ' Text Is ''' + %trim(colTxt)  + '''';
  Exec SQL Execute Immediate :sqlStm;
  If sqlState>='02';
    AddLog('ColTxt Upd Error':'Field ' + %trim(fldNme) +' column text udpate failed.':
           'SQLState  . . . :   ' + sqlState +
           '&N SQLStm  . . . . :   ' + sqlStm +
           '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
           #$SQLMessageHelp(sqlCode:sqlErrMc) +
           '&N Prior Heading . :   ' + %trim(fleDta.colTxt) +
           '&N New Heading . . :   ' + %trim(colTxt));
  Else;
    AddLog('ColTxt Updated':'Field ' + %trim(fldNme) +', column text updated.':
           'Prior Col. Text :   ' + %trim(fleDta.colTxt) +
           '&N New Column Text :   ' + %trim(colTxt));
  EndIf;

End-Proc;


// Add log entry
Dcl-Proc AddLog;
  Dcl-Pi *n;
    logTyp Like(APLDCT.logTyp) const;
    logDes Like(APLDCT.logDes) const;
    logMsg Like(APLDCT.logMsg) const;
  End-Pi;

  Exec SQL Insert Into FLELOG
        ( FLELIB, FLENME, FLEMSTIDN, fldNme, fleFldIdn, LOGTYP, LOGDES, LOGMSG,
          CRTDTM, CRTUSR, CRTJOB,CRTPGM,
          MNTDTM, MNTUSR, MNTJOB,MNTPGM)
  values( :fleLib,:fleNme,:fleMstIdn,:fldNme,:flefldIdn,:logTyp,:logDes,:logMsg,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);

End-Proc;
