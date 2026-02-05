**Free
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) DftActGrp(*No) ActGrp(*Caller) Main(Main);

//  File Field Navigator

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDD2PR
/Copy QSRC,FLDNTED1PR
/Copy QSRC,DCTVALD1PR
/Copy QSRC,AUDLOGD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDB0');
    pmrFleLib Like(APLDCT.FleLib);
    pmrFleNme Like(APLDCT.FleNme);
    pmrFldNme Like(APLDCT.FldNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;
  Dcl-S dctNme like(APLDCT.dctNme);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S fleFldIdn Like(APLDCT.fleFldIdn);
  Dcl-S fleMstIdn Like(APLDCT.fleMstIdn);

  Option = pmrOption;

  // Handle special options

  // View Notes
  If Option='6';
    pmOption = '2';
    CallP FLDNTED1(pmrFleLib:pmrFleNme:pmrFldNme:pmOption:keyPressed);
    Return;

    // Enum Values
  ElseIf Option='9';
    // get dictionary name from the file
    Exec SQL Select DctNme into :dctNme from FLEMST where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme);
    pmOption = '5';
    CallP DCTVALD1(dctNme:pmrFldNme:pmEnmVal:pmOption:keyPressed);
    Return;

    // View Log
  ElseIf Option = '11';
    pmOption='5';
    Exec SQL Select fleFldIdn into :fleFldIdn from FLEFLD
      where (fleLib,fleNme,FldNme) = (:pmrFleLib,:pmrFleNme,:pmrFldNme);
    CallP AUDLOGD1('APLLIB':'FLEFLD':'':fleFldIdn:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

    // Hard Delete
  ElseIf Option = '16';
    // get feiland field record ID's
    Exec SQL Select fleFldIdn into :fleFldIdn from FLEFLD
      where (fleLib,fleNme,FldNme) = (:pmrFleLib,:pmrFleNme,:pmrFldNme);
    Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme);
    // Add log entry
    Exec SQL Insert Into FLELOG
            ( FLELIB,    FLENME,    FLEMSTIDN, fldNme,    fleFldIdn,
              LOGTYP, LOGDES)
      values(:pmrFleLib,:pmrFleNme,:fleMstIdn,:pmrFldNme,:fleFldIdn,
             'Field Deleted','Field ' || trim(:pmrFldNme) || ' has been hard delted.');
    // deleted the record
    Exec SQL Delete from FLEFLD
      where (fleLib,fleNme,FldNme) = (:pmrFleLib,:pmrFleNme,:pmrFldNme);
    Return;
  EndIf;


  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      CallP FLEFLDD2(pmrFleLib:pmrFleNme:pmrFldNme:Option:keyPressed);
    Else;
      Return;
    EndIf;

    If keyPressed = 'F12';
      NxtScr -= 1;
    ElseIf keyPressed = 'F3' or Option = '4' or Option = '6' or Option = '7' or Option = '8';
      Clear NxtScr;
    Else;
      NxtScr += 1;
    EndIf;

  EndDo;

End-Proc;
