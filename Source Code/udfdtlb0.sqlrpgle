**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// User Default Detail Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,UDFDTLD2PR

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('UDFDTLB0');
    pmrPgmNme Like(APLDCT.pgmNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // Handle normal progression
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      UDFDTLD2(pmrPgmNme:Option:keyPressed);
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
