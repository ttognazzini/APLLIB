**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Create Soucre code for a FLEMST file, trigger and indexes.
//

// call flemstb9 (MRPS38S COUMST TTOGNAZZIN QSRC)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Dcl-S sqlStm       varchar(32000);
Dcl-S or           varchar(2);
Dcl-S fleLib       like(APLDCT.FLELIB);
Dcl-S fleNme       like(APLDCT.FLENME);
Dcl-S srcLib       like(APLDCT.SRCLIB);
Dcl-S srcFle       like(APLDCT.SRCFLE);
Dcl-S srcMbr       like(APLDCT.SRCMBR);
Dcl-S objLib       like(APLDCT.FLELIB);
Dcl-S fleDes       like(APLDCT.FLEDES);
Dcl-S mbrTxt       char(50);
Dcl-S fleMstIdn    like(APLDCT.FLEMSTIDN);
Dcl-S idnFldNmeSql like(APLDCT.FLDNMESQL);
Dcl-S fldTyp       like(APLDCT.FLDTYP);
Dcl-S fldNme       like(APLDCT.FLDNME);
Dcl-S fldNmeSql    like(APLDCT.FLDNMESQL);
Dcl-S fleFldIdn    like(APLDCT.FLEFLDIDN);
Dcl-S tblNme       varchar(21);
Dcl-S tblAlias     like(APLDCT.TBLNME);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


Dcl-Proc Main;
  Dcl-Pi *n extPgm('FLEMSTB9');
    pmrFleLib like(APLDCT.FLELIB);
    pmrFleNme like(APLDCT.FLENME);
    pmrSrcLib like(APLDCT.SRCLIB);
    pmrSrcFle like(APLDCT.SRCFLE);
    pmrObjLib like(APLDCT.OBJLIB);
  End-Pi;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  srcLib = pmrSrcLib;
  srcFle = pmrSrcFle;
  If %parms >= 5 and %addr(pmrObjLib) <> *null;
    objLib = pmrObjLib;
  EndIf;

  // get flemstidn and table alias
  Exec SQL select fleMstIdn, tblNme into :fleMstIdn,:tblAlias from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // Error out of the source file does not exists
  If not #$ISFILE(srcFle:srcLib);
    #$DSPWIN('Error file ' + %trim(srcLib) + '/' + %trim(srcFle) + ' does not exist. +
              source code not generated.');
    Return;
  EndIf;

  // get the long field name of the files identity column
  Exec SQL select fldNmeSQL into :idnFldNmeSql
           from FLEMST
           join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
           join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
           where (FLEMST.fleLib,FLEFLD.fleNme,FLEFLD.fldLvl) = (:fleLib,:fleNme,2);

  // build table, it may or may not include the library name
  If objLib <> '';
    tblNme = %trim(objLib) + '.' + %trim(fleNme);
  Else;
    tblNme = %trim(fleNme);
  EndIf;

  BuildFile();
  BuildTrigger();
  BuildIndexes();

End-Proc;


Dcl-Proc BuildFile;

  // field attributes from the dictionary
  Dcl-Ds dctDta;
    acvRow    Like(APLDCT.ACVROW);
    fldAlc    Like(APLDCT.FLDALC);
    colNme    Like(APLDCT.FLDNMESQL);
    fldNme    Like(APLDCT.FLDNME);
    flefldIdn Like(APLDCT.FLEFLDIDN);
    fldSeq    Like(APLDCT.FLDSEQ);
    fldTyp    Like(APLDCT.FLDTYP);
    dftVal    Like(APLDCT.DFTVAL);
    strIdn    Like(APLDCT.STRIDN);
    idnIcm    Like(APLDCT.IDNICM);
    encFld    Like(APLDCT.ENCFLD);
    sysTyp    like(APLDCT.SYSTYP);
    fldLen    like(APLDCT.SYSLEN);
    fldScl    like(APLDCT.FLDSCL);
    alwNul    like(APLDCT.ALWNUL);
    fldNmeSql like(APLDCT.FLDNMESQL);
    reqLen    like(APLDCT.REQLEN);
    alwDec    like(APLDCT.ALWDEC);
    alwAlc    like(APLDCT.ALWALC);
  End-Ds;
  Dcl-S line varchar(132);
  Dcl-S nulTxt varchar(50);
  Dcl-S colTxt like(APLDCT.COLTXT);
  Dcl-S colHdg like(APLDCT.COLHDG);
  Dcl-S lstFld like(APLDCT.FLDNME);
  Dcl-S lngCmt varchar(2000);
  Dcl-S cmtFldNme like(APLDCT.fldNme);

  // get the file text and build source member text
  Clear fleDes;
  Exec SQL
    Select trim(fleDes)
    Into :fleDes
    From FLEMST
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
  If fleDes <> '';
    mbrTxt = %trim(fleDes);
  Else;
    mbrTxt = 'Table ' + %trim(fleNme);
  EndIf;

  // create the source member if it does not exists, otherwise clear it.
  srcMbr = %trim(fleNme);
  If #$ISMBR(srcLib:srcFle:srcMbr);
    #$CMD('CLRPFM ' + %trim(srcLib) + '/' + %trim(srcFle) + ' MBR(' +  %trim(srcMbr) + ')');
  Else;
    #$CMD('ADDPFM FILE(' + %trim(srcLib) + '/' + %trim(srcFle) + ') +
                  MBR(' +  %trim(srcMbr) + ') +
                  TEXT(''' +  #$DBLQ(mbrTxt) + ''') +
                  SRCTYPE(SQLTABLE)');
  EndIf;

  // Create an alias to the source member
  Exec SQL Drop Alias QTEMP/FLEMSTB9AL;
  sqlStm='Create or Replace Alias QTEMP/FLEMSTB9AL +
          For ' + %trim(srcLib) + '/' + %trim(srcFle) + '("' + %trim(srcMbr) + '")';
  Exec SQL Execute Immediate :sqlStm;
  #$SQLSTT(sqlstate);

  WriteLine('/************************************************************************/');
  WriteLine('/* This source code was auto created via the APLLIB/FLEMST command. Do  */');
  WriteLine('/* not manually update this or it will get overlaid if generated again. */');
  WriteLine('/************************************************************************/');
  WriteLine('');
  WriteLine('/*   ' + mbrTxt + '    */');
  WriteLine('');
  If tblAlias <> '';
    WriteLine('Create or Replace Table ' + %trim(tblAlias) + ' For System Name ' + tblNme + ' (');
  Else;
    WriteLine('Create or Replace Table ' + tblNme + ' (');
  EndIf;

  // add each column
  Exec SQL Declare crs4 cursor for
    Select FLEFLD.AcvRow, FldAlc, FldNmeSql, FLEFLD.fldNme, fleFldIdn, fldSeq, dct.fldTyp,
           dct.dftVal, strIdn, idnIcm, encFld, typ.sysTyp,
           case when dct.fldLen = 0 then typ.sysLen else dct.fldLen end fldLen,
           fldScl,
           case when alwNul = 'Y' then 'Y' else 'N' end,
           DCT.fldNmeSql, reqLen, alwDec, alwAlc
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
    Join DCTFLD as dct on (dct.dctNme,dct.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    Join FLDTYP as typ on (typ.fldTyp) = (dct.fldTyp)
    Where (FLEFLD.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
    Order by fldLvl, fldSeq;
  Exec SQL Open crs4;
  Exec SQL fetch next from crs4 into :dctDta;
  DoW SQLState < '02';
    line = '  ' + colNme + ' for Column ' + fldNme + %trim(fldTyp);

    // add length and scale if needed
    If reqLen = 'Y';
      line += '(' + %char(fldLen);
      If alwDec = 'Y';
        line += ',' + %char(fldScl);
      EndIf;
      line += ')';
    EndIf;

    // add the allocation if needed
    If alwAlc = 'Y' and fldAlc > 0;
      line += ' ALLOCATE(' + %char(fldAlc) + ')';
    EndIf;

    // Default Values for character field must be included in Quotes, unless they are valid SQL Key Words
    If dftVal > '' and fldTyp in %list('CHAR':'VARCHAR') and %scan('''':dftVal) = 0
      and (%upper(dftVal) <> 'USER' or fldLen < 18);
      dftVal = '''' + %trim(dftVal) + '''';
    EndIf;

    // Add null and default options
    Clear nulTxt;
    If fldNme = %trim(fleNme) + 'IDN';
      nulTxt = ' Not Null';
    ElseIf alwNul = 'Y' and dftVal > *blanks;
      nulTxt = ' Default ' + %trim(dftVal);
    ElseIf alwNul = 'Y' and dftVal = *blanks;
    ElseIf dftVal > *blanks;
      nulTxt = ' Not Null Default ' + %trim(dftVal);
    Else;
      nulTxt = ' Not Null With Default';
    EndIf;

    // if there is enough room, append null text to the line, otherwise write the
    // line and add a new line for the null test
    If %len(line) + %len(nulTxt) < 120;
      line += nulTxt;
    Else;
      WriteLine(line);
      line = '                                ' + nulTxt;
    EndIf;

    // If the field is not an identy column add comma and write line
    If fldNme <> %trim(fleNme) + 'IDN';
      // If the field is flagged to include encrypted data, add for bit data
      If encFld = 'Y';
        WriteLine(line);
        WriteLine('                                for bit data,');
      Else;
        line += ',';
        WriteLine(line);
      EndIf;
    EndIf;


    // If the field is the identity column for the table, add that stuff
    If fldNme = %trim(fleNme) + 'IDN';
      WriteLine(line);
      // If the field is flagged to include encrypted data, add for bit data
      If encFld = 'Y';
        WriteLine('    for bit data');
      EndIf;
      line = '                                 Generated Always as Identity '
              + '(Start With ';
      If strIdn <> 0;
        line += %char(strIdn);
      Else;
        line += '1';
      EndIf;
      line += ' Increment by ';
      If idnIcm <> 0;
        line += %char(idnIcm);
      Else;
        line += '1';
      EndIf;
      line += '),';
      WriteLine(line);
    EndIf;


    Exec SQL fetch next from crs4 into :dctDta;
  EndDo;
  Exec SQL Close crs4;

  // add the primary key fields if found
  Clear line;
  Exec SQL
    Select Listagg(trim(FLEFLD.fldNme),',') Within Group (Order By fldLvl Desc, fldSeq)
    Into :line
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
    Join DCTFLD as dct on (dct.dctNme,dct.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    Where (FLEMST.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
      and priKey = 'Y';
  If line <> '';
    WriteLine('  primary key (' + line + ')');
  EndIf;

  // end the sql statement
  WriteLine(');');

  // Add table text
  WriteLine('');
  WriteLine('Label on Table ' + %trim(fleNme) + ' is ''' + %trim(#$DBLQ(fleDes)) + ''';');

  // Add notes into the long comment on the file if they exist
  Clear lngCmt;
  Exec SQL
    With dta as (
      Select listagg(cast(trim(nte) as varchar(32000)), ' ') Within Group (Order by nteSeq) notes
      From FLENTE
      Where (fleLib,fleNme) = (:fleLib,:fleNme)
      )
    Select
      Case when length(notes) > 2000 then substr(notes,1,1997) || '...' else notes end
    Into :lngCmt
    From dta;
  If lngCmt <> '';
    WriteLine('');
    WriteLine('Comment on Table ' + %trim(fleNme) + ' is');
    AddLngCmt(lngCmt);
    WriteLine('');
  EndIf;

  // Add notes into the long comment on each field if they exist
  Clear lngCmt;
  Clear cmtFldNme;
  Exec SQL Declare fldLngCmtCrs cursor for
    With dta as (
      Select fldNme, listagg(cast(trim(nte) as varchar(32000)), ' ') Within Group (Order by nteSeq) notes
      From FLDNTE
      Where (fleLib,fleNme) = (:fleLib,:fleNme)
      Group by fldNme
      )
    Select
      fldnme,
      Case when length(notes) > 2000 then substr(notes,1,1997) || '...' else notes end lngCmt
    From dta;
  Exec SQL Open fldLngCmtCrs;
  Exec SQL Fetch Next From fldLngCmtCrs into :cmtFldNme, :lngCmt;
  DoW sqlState < '02';
    WriteLine('');
    WriteLine('Comment on Column ' + %trim(fleNme) + '.' + %trim(cmtFldNme) + ' is');
    AddLngCmt(lngCmt);
    WriteLine('');
    Exec SQL Fetch Next From fldLngCmtCrs into :cmtFldNme, :lngCmt;
  EndDo;
  Exec SQL Close fldLngCmtCrs;

  // get the last field for the file, used to add commas after all but the last field.
  Exec SQL
    Select fldNme
    Into :lstFld
    From FLEFLD
    Where (FLEFLD.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
    Order by fldLvl desc, fldSeq desc
    Limit 1;

  // Add column labels
  WriteLine('');
  WriteLine('Label on Column ' + tblNme + ' (');
  Exec SQL Declare crs5 cursor for
    Select FLEFLD.fldNme, colHdg
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
    Join DCTFLD as dct on (dct.dctNme,dct.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    Where (FLEFLD.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
    Order by fldLvl, fldSeq;
  Exec SQL Open crs5;
  Exec SQL fetch next from crs5 into :fldNme,:colHdg;
  DoW SQLState < '02';
    line = '  ' + fldNme + ' is ''' + %trim(colHdg) + '''';
    If fldNme <> lstFld;
      line += ',';
    EndIf;
    WriteLine(line);
    Exec SQL fetch next from crs5 into :fldNme,:colHdg;
  EndDo;
  Exec SQL Close crs5;
  WriteLine(');');


  // Add column text
  WriteLine('');
  WriteLine('Label on Column ' + tblNme + ' (');
  Exec SQL Declare crs6 cursor for
    Select FLEFLD.fldNme, colTxt
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
    Join DCTFLD as dct on (dct.dctNme,dct.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    Where (FLEFLD.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
    Order by fldLvl, fldSeq;
  Exec SQL Open crs6;
  Exec SQL fetch next from crs6 into :fldNme,:colTxt;
  DoW SQLState < '02';
    line = '  ' + fldNme + ' text is ''' + %trim(colTxt) + '''';
    If fldNme <> lstFld;
      line += ',';
    EndIf;
    WriteLine(line);
    Exec SQL fetch next from crs6 into :fldNme,:colTxt;
  EndDo;
  Exec SQL Close crs6;
  WriteLine(');');

End-Proc;


Dcl-Proc BuildTrigger;

  // create the source member if it does not exists, otherwise clear it.
  srcMbr = %trim(fleNme) + 'TRG';
  If #$ISMBR(srcLib:srcFle:srcMbr);
    #$CMD('CLRPFM ' + %trim(srcLib) + '/' + %trim(srcFle) + ' MBR(' +  %trim(srcMbr) + ')');
  Else;
    mbrTxt = %trim(fleNme) + ' - Triggger Program';
    Exec SQL
      Select trim(fleDes) || ' - Triggger Program'
      Into :mbrTxt
      From FLEMST
      Where (fleLib,fleNme) = (:fleLib,:fleNme);
    #$CMD('ADDPFM FILE(' + %trim(srcLib) + '/' + %trim(srcFle) + ') +
                  MBR(' +  %trim(srcMbr) + ') +
                  TEXT(''' +  #$DBLQ(mbrTxt) + ''') +
                  SRCTYPE(SQLTRIGGER)');
  EndIf;

  // Create an alias to the source member
  Exec SQL Drop Alias QTEMP/FLEMSTB9AL;
  sqlStm='Create or Replace Alias QTEMP/FLEMSTB9AL +
          For ' + %trim(srcLib) + '/' + %trim(srcFle) + '("' + %trim(srcMbr) + '")';
  Exec SQL Execute Immediate :sqlStm;
  #$SQLSTT(sqlstate);

  WriteLine('/************************************************************************/');
  WriteLine('/* This source code was auto created via the APLLIB/FLEMST command. Do  */');
  WriteLine('/* not manually update this or it will get overlaid if generated again. */');
  WriteLine('/************************************************************************/');
  WriteLine('');
  WriteLine('Create or Replace Trigger ' + tblNme + 'TRG');
  WriteLine('before Insert or Update on ' + tblNme);
  WriteLine('Referencing new row as n old row as o');
  WriteLine('for each row mode db2row');
  WriteLine('');
  WriteLine('Begin');
  WriteLine('  /* On create set the crtXXX values */');
  WriteLine('  If Inserting Then');
  WriteLine('    set n.create_time_stamp = current timestamp,');
  WriteLine('        n.create_user = user,');
  WriteLine('        n.create_job = job_name,');
  WriteLine('        n.create_program = APLLIB.current_program();');
  WriteLine('  End If ;');
  WriteLine('');
  WriteLine('');
  WriteLine('  /* On create, or update and a field changes, set the mntXXX values */');
  WriteLine('  If inserting or');
  WriteLine('     (updating and (');

  // add each level 4 field that is flagged for user update
  Exec SQL Declare crs1 cursor for
    Select fldNmeSql, fldtyp
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
      and FLEFLD.fldLvl in (1,2,3,4)
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs1;
  Exec SQL fetch next from crs1 into :fldNmeSql,:fldTyp;
  or = '';
  DoW SQLState < '02';
    If fldTyp = 'XML';
      WriteLine('       ' + or + ' hash(n.' + %trim(fldNmeSql) + ') <> hash(o.' + %trim(fldNmeSql) + ')');
    Else;
      WriteLine('       ' + or + ' n.' + %trim(fldNmeSql) + ' <> o.' + %trim(fldNmeSql));
    EndIf;
    or = 'or';
    Exec SQL fetch next from crs1 into :fldNmeSql,:fldTyp;
  EndDo;
  Exec SQL Close crs1;

  WriteLine('  )) Then');
  WriteLine('    set n.maintenance_time_stamp = current timestamp,');
  WriteLine('        n.maintenance_user = user,');
  WriteLine('        n.maintenance_job = job_name,');
  WriteLine('        n.maintenance_program = APLLIB.current_program();');
  WriteLine('  End If;');

  // add all audited fields
  WriteLine('');
  WriteLine('  /* Add all audited columns */');
  Exec SQL Declare crs2 cursor for
    Select FLEFLD.fldNme,fldNmeSql, fleFldIdn
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme,audFld) = (:fleLib,:fleNme,'Y')
      and fldtyp not in ('XML','DATALINK','GRAPHIC','VARGRAPHIC','DBCLOB')
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs2;
  Exec SQL fetch next from crs2 into :fldNme,:fldNmeSql,:fleFldIdn;
  DoW SQLState < '02';
    WriteLine('');
    WriteLine('  If o.' + %trim(fldNmeSql) +' <>  n.' +%trim(fldNmeSql) + ' Then');
    WriteLine('    Insert into APLLIB.AUDLOG');
    WriteLine('          (fleLib, fleNme, fleMstIdn,');
    WriteLine('           rcdIdn, fldNme, fleFldIdn,');
    WriteLine('           bfrVal, aftVal)');
    WriteLine('    Values('''+%trim(fleLib)+''','''+%trim(fleNme)+''', ' +%char(fleMstIdn) + ',');
    WriteLine('           n.'+%trim(idnFldNmeSql) + ','''+%trim(fldNme)+''','+%char(fleFldIdn) +',');
    WriteLine('           o.'+%trim(fldNmeSql) + ', n.'+%trim(fldNmeSql)+');');
    WriteLine('  End If;');
    Exec SQL fetch next from crs2 into :fldNme,:fldNmeSql,:fleFldIdn;
  EndDo;
  Exec SQL Close crs2;

  // Trim all varchar fields in case someone messes them up
  WriteLine('');
  WriteLine('  /* Trim all varchar columns */');
  Exec SQL Declare crs3 cursor for
    Select fldNmeSql
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme,fldTyp) = (:fleLib,:fleNme,'VARCHAR')
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs3;
  Exec SQL fetch next from crs3 into :fldNmeSql;
  DoW SQLState < '02';
    WriteLine('  set n.' + %trim(fldNmeSql) + ' = trim(n.' + %trim(fldNmeSql) + ');');
    Exec SQL fetch next from crs3 into :fldNmeSql;
  EndDo;
  Exec SQL Close crs3;

  // finish out statement
  WriteLine('');
  WriteLine('End');

End-Proc;


Dcl-Proc BuildIndexes;
  Dcl-S idxNme like(APLDCT.IDXNME);
  Dcl-S idxTxt like(APLDCT.IDXTXT);
  Dcl-S idxUni like(APLDCT.IDXUni);

  // loop through index file and build each one
  Exec SQL Declare crs7 cursor for
    Select idxNme, idxTxt, idxUni
    From FLEIDX
    Where (fleLib,fleNme) = (:fleLib, :fleNme);
  Exec SQL Open crs7;
  Exec SQL Fetch Next From crs7 into :idxNme, :idxTxt, :idxUni;
  DoW sqlState < '02';
    BuildIndex(idxNme:idxTxt:idxUni);
    Exec SQL Fetch Next From crs7 into :idxNme, :idxTxt, :idxUni;
  EndDo;
  Exec SQL Close crs7;

End-Proc;


Dcl-Proc BuildIndex;
  Dcl-Pi *n;
    idxNme like(APLDCT.IDXNME);
    idxTxt like(APLDCT.IDXTXT);
    idxUni like(APLDCT.IDXUNI);
  End-Pi;
  Dcl-S lstFld like(APLDCT.FLDNME);
  Dcl-S idxFld like(APLDCT.IDXFLD);

  // create the source member if it does not exists, otherwise clear it.
  srcMbr = %trim(fleNme) + 'TRG';
  If #$ISMBR(srcLib:srcFle:idxNme);
    #$CMD('CLRPFM ' + %trim(srcLib) + '/' + %trim(srcFle) + ' MBR(' +  %trim(idxNme) + ')');
  Else;
    #$CMD('ADDPFM FILE(' + %trim(srcLib) + '/' + %trim(srcFle) + ') +
                  MBR(' +  %trim(idxNme) + ') +
                  TEXT(''' +  #$DBLQ(idxTxt) + ''') +
                  SRCTYPE(SQLINDEX)');
  EndIf;

  // Create an alias to the source member
  Exec SQL Drop Alias QTEMP/FLEMSTB9AL;
  sqlStm='Create or Replace Alias QTEMP/FLEMSTB9AL +
          For ' + %trim(srcLib) + '/' + %trim(srcFle) + '("' + %trim(idxNme) + '")';
  Exec SQL Execute Immediate :sqlStm;
  #$SQLSTT(sqlstate);

  WriteLine('/************************************************************************/');
  WriteLine('/* This source code was auto created via the APLLIB/FLEMST command. Do  */');
  WriteLine('/* not manually update this or it will get overlaid if generated again. */');
  WriteLine('/************************************************************************/');
  WriteLine('');
  If objLib <> '';
    WriteLine('Drop Index If Exists ' + %trim(objLib) + '.' + %trim(idxNme) + ';');
  Else;
    WriteLine('Drop Index If Exists ' + %trim(idxNme) + ';');
  EndIf;

  If idxUni = 'E' and objLib <> '';
    WriteLine('Create Encoded Vector Index ' + %trim(objLib) + '.' + %trim(idxNme) +
                                      ' on ' + %trim(fleLib) + '.' + %trim(fleNme) +' (');
  ElseIf idxUni = 'E';
    WriteLine('Create Encoded Vector Index ' + %trim(idxNme) + ' on ' +  %trim(fleNme) + ' (');
  ElseIf idxUni = 'Y' and objLib <> '';
    WriteLine('Create Unique Index ' + %trim(objLib) + '.' + %trim(idxNme) +
                              ' on ' + %trim(objLib) + '.' + %trim(fleNme) + ' (');
  ElseIf idxUni = 'Y';
    WriteLine('Create Unique Index ' + %trim(idxNme) +
                              ' on ' + %trim(fleNme) + ' (');
  ElseIf objLib <> '';
    WriteLine('Create Index ' + %trim(objLib) + '.' + %trim(idxNme) + ' on ' +
                                %trim(objLib) + '.' + %trim(fleNme) +' (');
  Else;
    WriteLine('Create Index ' + %trim(idxNme) + ' on ' + %trim(fleNme) +' (');
  EndIf;

  // Get last trigger fields so we know which ones to put commas after
  Exec SQL
    Select idxFld
    Into :lstFld
    From IDXFLD
    Where (idxLib, idxNme) = (:fleLib,:idxNme)
    Order By idxSeq Desc
    Limit 1;

  // Add trigger fields
  Exec SQL Declare crs8 cursor for
    Select idxFld
    From IDXFLD
    Where (idxLib, idxNme) = (:fleLib,:idxNme)
    Order By idxSeq;
  Exec SQL Open crs8;
  Exec SQL Fetch Next From crs8 into :idxFld;
  DoW sqlState < '02';
    If idxFld = lstFld;
      WriteLine('  ' + %trim(idxFld));
    Else;
      WriteLine('  ' + %trim(idxFld) + ',');
    EndIf;

    Exec SQL Fetch Next From crs8 into :idxFld;
  EndDo;
  Exec SQL Close crs8;

  // Add with... for EVI's and end statement
  If idxUni = 'E';
    WriteLine(') With 255 Distinct Values;');
  Else;
    WriteLine(');');
  EndIf;

  // Add index text
  WriteLine('');
  If objLib <> '';
    WriteLine('Label on Index ' + %trim(objLib) + '.' + %trim(idxNme) + ' is ''' + %trim(#$DBLQ(idxTxt)) + ''';');
  Else;
    WriteLine('Label on Index ' + %trim(idxNme) + ' is ''' + %trim(#$DBLQ(idxTxt)) + ''';');
  EndIf;


End-Proc;


// write one line to the source member
Dcl-Proc WriteLine;
  Dcl-Pi *n;
    data Varchar(250) const;
  End-Pi;
  Dcl-S srcSeq zoned(6:2);

  // add the string into the source file
  srcSeq+=1;
  Exec SQL Insert Into QTEMP/FLEMSTB9AL
                 (srcSeq,srcDta)
           values(:srcSeq,:data);

End-Proc;


// Add a long comment for a file or a field
Dcl-Proc AddLngCmt;
  Dcl-Pi *n;
    lngCmt Varchar(2000) const;
  End-Pi;
  Dcl-S i packed(5);

  // If less than 118 characters, do it on one line
  If %len(lngCmt) < 118;
    WriteLine('''' + lngCmt + '''');
  ElseIf %len(lngCmt) < 119 + 119;
    WriteLine('''' + %subst(lngCmt:1:119));
    WriteLine(%trim(%subst(lngCmt:120)) + '''');
  Else;
    WriteLine('''' + %subst(lngCmt:1:119));
    For i = 120 by 120 to %len(lngCmt);
      if i + 120 < %len(lngCmt);
        WriteLine( %trim(%subst(lngCmt:i:120)));
      EndIf;
    EndFor;
    WriteLine(%trim(%subst(lngCmt:i-120)) + '''');
  EndIf;
  WriteLine(';');

End-Proc;
