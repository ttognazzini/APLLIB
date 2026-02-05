**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Dictionary Master Driver

/Copy QSRC,BASFNCV1PR   // Prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,DCTMSTD2PR
/Copy QSRC,DCTFLDD1PR
/Copy QSRC,DCTFLDB8PR
/Copy QSRC,AUDLOGD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S DctNme like(APLDCT.DctNme);
Dcl-S fldNme like(APLDCT.fldNme);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTMSTB0');
    pmrDctMstIdn Like(APLDCT.dctMstIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // Handle special options
  If Option = '6'; // dictionary fields
    pmOption='2';
    Exec SQL Select dctNme into :DctNme from DCTMST where dctMstIdn = :pmrDctMstIdn;
    CallP DCTFLDD1(DctNme:fldNme:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;
  ElseIf Option='9';  // rebuild full dictionary file
    Exec SQL Select dctNme into :DctNme from DCTMST where dctMstIdn = :pmrDctMstIdn;
    CallP DCTFLDB8(DctNme);
    Return;
  ElseIf Option = '11'; // View Log
    pmOption='5';
    CallP AUDLOGD1('APLLIB':'DCTMST':'':pmrDctMstIdn:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;
  EndIf;

  // Handle normal progression
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      CallP DCTMSTD2(pmrDctMstIdn:Option:keyPressed);
    Else;
      Leave;
    EndIf;

    If keyPressed = 'F12';
      NxtScr -= 1;
    ElseIf Option = '4' or Option = '6' or Option = '7' or Option = '8';
      Clear NxtScr;
    ElseIf keyPressed = 'F3';
      Clear NxtScr;
    Else;
      NxtScr += 1;
    EndIf;

  EndDo;

  // return key pressed
  pmrKeyPressed=keyPressed;

End-Proc;
