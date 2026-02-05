**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// File Master Driver

/Copy QSRC,BASFNCV1PR  // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR  // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTD2PR
/Copy QSRC,FLEMSTB1PR
/Copy QSRC,FLEFLDD1PR
/Copy QSRC,FLEMSTD4PR  // Build source code
/Copy QSRC,FLEIDXD1PR
/Copy QSRC,FLENTED1PR
/Copy QSRC,FLELOGD1PR
/Copy QSRC,FLEERRD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(3);
Dcl-S pmrFldNme like(APLDCT.fldNme);
Dcl-S pmrIdxLib like(APLDCT.IdxLib);
Dcl-S pmrIdxNme like(APLDCT.IdxNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB0');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // Handle special options
  If Option='6';
    If Option = '5';
      pmOption = '5';
    Else;
      pmOption = '2';
    EndIf;
    CallP FLEIDXD1(pmrFleLib:pmrFleNme:pmrIdxLib:pmrIdxNme:pmOption:pmrKeyPressed);
    Return;
  ElseIf Option='7';
    CallP FLEMSTD4(pmrFleLib:pmrFleNme:pmrKeyPressed);
    Return;
  ElseIf Option='9';
    If Option = '5';
      pmOption = '5';
    Else;
      pmOption = '2';
    EndIf;
    CallP FLENTED1(pmrFleLib:pmrFleNme:pmOption:pmrKeyPressed);
    Return;
  ElseIf Option='10';
    pmOption = '5';
    CallP FLELOGD1(pmrFleLib:pmrFleNme);
    Return;
  ElseIf Option='11';
    pmOption = '5';
    CallP FLEERRD1(pmrFleLib:pmrFleNme);
    Return;
  ElseIf Option='16';
    CallP FLEMSTB1(pmrFleLib:pmrFleNme:pmrKeyPressed);
    Return;
  EndIf;

  // Handle normal progression
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      FLEMSTD2(pmrFleLib:pmrFleNme:Option:keyPressed);
    ElseIf NxtScr = 3;
      FLEFLDD1(pmrFleLib:pmrFleNme:pmrFldNme:Option:keyPressed);
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
