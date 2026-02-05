**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Program Function Key Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMFNCB0PR // Always include the prototype for the current program
/Copy QSRC,PGMFNCD2PR

Dcl-S Option2 like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LasScr const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMFNCB0');
    pmrPgmNme Like(APLDCT.pgmNme);
    pmrFncKey Like(APLDCT.fncKey);
    pmrOption Like(APLDCT.option);
    pmrOption2 Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  // Handle special options
  If pmrOption2 = '16'; // hard delete
    Exec SQL Delete from PGMFNC where (pgmNme,fncKey,option) = (:pmrPgmNme,:pmrFncKey,:pmrOption);
    Return;
  EndIf;

  Option2 = pmrOption2;
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LasScr;
    // If Create or Copy Option, Signal to Allow F16
    If pmrOption2 = '1' or pmrOption2 = '3';
      keyPressed = 'F16';
    Else;
      Clear keyPressed;
    EndIf;

    If NxtScr = 2;
      CallP PGMFNCD2(pmrPgmNme:pmrFncKey:pmrOption:Option2:keyPressed);
    Else;
      Return;
    EndIf;

    If keyPressed = 'F12';
      NxtScr -= 1;
    ElseIf Option2 = '4' or Option2 = '6' or Option2 = '7' or Option2 = '8';
      Clear NxtScr;
    ElseIf keyPressed = 'F3';
      Clear NxtScr;
    Else;
      NxtScr += 1;
    EndIf;

  EndDo;

End-Proc;
