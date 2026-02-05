**FREE
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Dictionary Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALB0PR // Always include the prototype for the current program
/Copy QSRC,DCTVALD2PR

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTVALB0');
    pmrDctNme Like(APLDCT.dctNme);
    pmrFldNme Like(APLDCT.fldNme);
    pmrEnmVal Like(APLDCT.EnmVal);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;
    // If Create or Copy Option, Signal to Allow F16
    If pmrOption = '1' or pmrOption = '3';
      keyPressed = 'F16';
    Else;
      Clear keyPressed;
    EndIf;

    If NxtScr = 2;
      CallP(e) DCTVALD2(pmrDctNme:pmrFldNme:pmrEnmVal:Option:keyPressed);
    Else;
      Return;
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

End-Proc;
