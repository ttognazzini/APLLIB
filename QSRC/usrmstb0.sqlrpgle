**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Dictionary Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD2PR
/Copy QSRC,USRMSTD3PR
/Copy QSRC,USRMSTB5PR // Hard Delete User
/Copy QSRC,USRMSTD4PR // Work with program authorities
/Copy QSRC,USRMSTD6PR // Work with program authorities
/Copy QSRC,USRMSTD7PR // Work with program authorities
/Copy QSRC,USRMSTD8PR // Create Developer Environment
/Copy QSRC,USRROLD1PR // Work with users roles
/Copy QSRC,PMPWDWD1PR // generic prompt window


Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(5);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTB0');
    pmrUsrPrf like(APLDCT.usrPrf);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;
  Dcl-S pmAns    Char(1);
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S acNo like(APLLIB.acNo);
  Dcl-S pmUsrRolIdn Like(APLDCT.usrRolIdn);
  Dcl-S pmUsrMstIdn Like(APLDCT.usrMstIdn);
  Dcl-S pmRolMstIdn Like(APLDCT.rolMstIdn);
  Dcl-S pmOption Like(APLDCT.Option);


  Option = pmrOption;

  // Handle special options
  If Option = '14';
    USRMSTD8(pmrAcNo:Option:keyPressed);
    Return;

    // 16 = Hard Delete
  ElseIf Option = '16';

    PMPWDWD1('This will delete the user from all systems. Any output in the users fax queue will be moved to TRASH2, +
              any objects the user owns will be changed to QPGMR. The user will be removed from ACCESSPF, GPPJOBD, +
              FastFax, RPT, SpyView and the AS400. It is recomended that you deactivate the user instead. +
              Are you sure you want to do this?':pmAns:'YN':'Y=Yes, N=No':pmKeyPressed);
    If pmAns = 'Y';
      acNo = pmrAcNo;
      USRMSTB5(acNo);
    EndIf;
    Return;

    // Work with menu permissions
  ElseIf Option='6';
    USRMSTD4(pmrAcNo);
    Return;

    // Work with users roles
  ElseIf Option='10';
    pmOption = '2';
    Clear pmUsrRolIdn;
    Clear pmRolMstIdn;
    Clear pmUsrMstIdn;
    Exec SQL Select usrMstIdn into :pmUsrMstIdn from USRMST where accNbr = :pmrAcNo;
    USRROLD1(pmUsrRolIdn:pmUsrMstIdn:pmRolMstIdn:pmOption:pmKeyPressed);
    Return;

  EndIf;

  // Handle normal progression
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;

    If NxtScr = 2;
      USRMSTD2(pmrAcNo:Option:keyPressed);
      If Option in %list('3':'1') and keyPressed = 'ENTER';
        Option = '2';
      EndIf;
    ElseIf NxtScr = 3;
      USRMSTD3(pmrAcNo:Option:keyPressed);
    ElseIf NxtScr = 4;
      USRMSTD6(pmrAcNo:Option:keyPressed);
    ElseIf NxtScr = 5;
      USRMSTD7(pmrAcNo:Option:keyPressed);
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
