**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Help Master Navigation

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,HLPMSTB0PR // Always include the prototype for the current program
/Copy QSRC,HLPMSTB4PR // Dislay Help text
/Copy QSRC,HLPDTLD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('HLPMSTB0');
    pmrDctNme Like(APLDCT.dctNme);
    pmrFldNme Like(APLDCT.fldNme);
    pmrDspFle Like(APLDCT.dspFle);
    pmrVal    Like(APLDCT.val   );
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  // Handle special options

  // Display Help text
  If pmrOption = '5';
    CallP HLPMSTB4(pmrDctNme:pmrFldNme:pmrDspFle:pmrVal);
    Return;
  EndIf;



  Option = pmrOption;
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      CallP(e) HLPDTLD1(pmrDctNme:pmrFldNme:pmrDspFle:pmrVal:Option:keyPressed);

      If keyPressed = 'F12';
        NxtScr -= 1;
      ElseIf Option = '4' or Option = '6' or Option = '7' or Option = '8';
        Clear NxtScr;
      ElseIf keyPressed = 'F3';
        Clear NxtScr;
      Else;
        NxtScr += 1;
      EndIf;
    EndIf;

  EndDo;

End-Proc;
