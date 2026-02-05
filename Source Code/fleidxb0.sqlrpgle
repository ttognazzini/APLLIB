**Free
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) DftActGrp(*No) ActGrp(*Caller) Main(Main);

//  File Indexes Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,IDXFLDD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEIDXB0');
    pmrFleLib Like(APLDCT.FleLib);
    pmrFleNme Like(APLDCT.FleNme);
    pmrIdxLib Like(APLDCT.idxLib);
    pmrIdxNme Like(APLDCT.idxNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;


  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      CallP IDXFLDD1(pmrFleLib:pmrFleNme:pmrIdxLib:pmrIdxNme:Option:keyPressed);
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
