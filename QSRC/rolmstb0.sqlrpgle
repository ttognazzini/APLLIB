**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Role Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,ROLMSTD2PR
/Copy QSRC,USRROLD1PR // Work with users roles
/Copy QSRC,AUDLOGD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S RolNme like(APLDCT.RolNme);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ROLMSTB0');
    pmrRolMstIdn Like(APLDCT.rolMstIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmUsrRolIdn Like(APLDCT.usrRolIdn);
  Dcl-S pmUsrMstIdn Like(APLDCT.usrMstIdn);
  Dcl-S pmOption Like(APLDCT.Option);

  Option = pmrOption;

  // Handle special options
  If Option = '11'; // View Log
    pmOption='5';
    AUDLOGD1('APLLIB':'ROLMST':'':pmrRolMstIdn:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

    // Work with users for a role
  ElseIf Option='6';
    pmOption = '2';
    Clear pmUsrRolIdn;
    Clear pmUsrMstIdn;
    USRROLD1(pmUsrRolIdn:pmUsrMstIdn:pmrRolMstIdn:pmOption:pmKeyPressed);
    Return;

  EndIf;

  // Handle normal progression
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      ROLMSTD2(pmrRolMstIdn:Option:keyPressed);
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
