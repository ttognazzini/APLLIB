**FREE
Ctl-Opt option(*srcstmt) DftActGrp(*No)
        ActGrp(*New) BndDir('APLLIB') Main(Main);

// Output Queue Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,OTQMSTD2PR
/Copy QSRC,PRTTGLD1PR
/Copy QSRC,PRTTGLB2PR
/Copy QSRC,AUDLOGD1PR
/Copy QSRC,RTVWTRB1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S prt like(APLDCT.prt);
Dcl-S otqNme like(APLDCT.otqNme);
Dcl-S otqLib like(APLDCT.otqLib);
Dcl-S otqTyp like(APLDCT.otqTyp);
Dcl-S frmTyp like(APLDCT.frmTyp);
Dcl-S frmMsg like(APLDCT.frmMsg);
Dcl-S cde char(1);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(2);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTQMSTB0');
    pmrOTQMSTIdn Like(APLDCT.OTQMSTIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // Handle special options
  If Option = '5';
    Exec SQL Select substr(com,12,1) into :cde from Common
              Where rrn(Common) = 378;
    Exec SQL Select otqNme into :otqNme from OTQMST where OTQMSTIdn = :pmrOTQMSTIdn;
    prt = otqNme;
    If cde = 'N';
      CallP PRTTGLD1(prt);
    Else;
      #$CMD('WRKOUTQ ' + %trim(prt):1);
    EndIf;
    pmrKeyPressed='F12';
    Return;
  ElseIf Option = '6'; // Work with output queue
    Exec SQL Select otqNme into :otqNme from OTQMST where OTQMSTIdn = :pmrOTQMSTIdn;
    prt = otqNme;
    #$CMD('WRKOUTQ ' + %trim(prt):1);
    pmrKeyPressed='F12';
    Return;
  ElseIf Option='9';  // Start writer
    Exec SQL Select otqNme, otqLib, otqTyp, frmTyp, frmMsg
              into :otqNme, :otqLib, :otqTyp, :frmTyp, :frmMsg
              from OTQMST where OTQMSTIdn = :pmrOTQMSTIdn;
    If otqTyp = 'L';
      #$CMD('STRPRTWTR '+ %trim(otqNme) + 'OUTQ(' + %trim(otqLib) +
              '/' + %trim(otqNme) + ') FORMTYPE(' + %trim(frmTyp) +
              ' ' + %trim(frmMsg) +')':1);
    Else;
      #$CMD('STRRMTWTR OUTQ(' + %trim(otqLib) +
              '/' + %trim(otqNme) + ') FORMTYPE('+ %trim(frmTyp) +
              ' ' + %trim(frmMsg) +')':1);
    EndIf;
    prt=otqNme;
    PRTTGLB2(prt);
    Return;
  ElseIf Option='12';  // End writer
    Exec SQL Select otqNme into :otqNme
              from OTQMST where OTQMSTIdn = :pmrOTQMSTIdn;
    #$CMD('ENDWTR WTR('+ %trim(otqNme) + ') OPTION(*IMMED)':1);
    Return;
  ElseIf Option = '11'; // View Log
    pmOption='5';
    CallP AUDLOGD1('APLLIB':'OTQMST':'':pmrOTQMSTIdn:pmOption:keyPressed);
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
      CallP OTQMSTD2(pmrOTQMSTIdn:Option:keyPressed);
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
