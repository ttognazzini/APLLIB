**free
Ctl-Opt debug option(*srcstmt:*nodebugio:*noshowcpy) dftactgrp(*no) actgrp(*new) Main(Main);

// Dictionary Segment Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTSEGB0PR // Always include the prototype for the current program
/Copy QSRC,DCTSEGD2PR

Dcl-S Option Like(APLDCT.Option);
Dcl-S NxtScr int(5) inz(2);
Dcl-C LASSCR 3;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n extPgm('DCTSEGB0');
    pmrDtaSeg Like(APLDCT.DtaSeg);
    pmrOption Like(APLDCT.Option) Const;
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  keyPressed=pmrKeyPressed;
  Option=pmrOption;

  DoW NxtScr > 1 and NxtScr <= LASSCR;
    // If Create or Copy Option, Signal to Allow F16
    Clear keyPressed;

    If NxtScr = 2;
      CallP(e) DCTSEGD2(pmrDtaSeg:Option:keyPressed);
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

  If Option <> '5' and keyPressed <> 'F16';
  EndIf;

End-Proc;
