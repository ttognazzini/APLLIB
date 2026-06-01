**FREE
/copy APLLIB/QSRC,$ctlopt
Ctl-Opt ActGrp(*Caller);

// Program Master Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMMSTB0PR // Always include the prototype for the current program
/Copy QSRC,PGMMSTD2PR
/Copy QSRC,PGMMSTD3PR
/Copy QSRC,HLPMSTD1PR
/Copy QSRC,PGMFNCD1PR
/Copy QSRC,PGMOPTD1PR
/Copy QSRC,PGMACTD1PR
/Copy QSRC,PGMHLPD1PR
// Copy QSRC,APLNTED1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S pmOption like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(3);
Dcl-S toPgm like(APLDCT.pgmNme);

// fields used to function key program
Dcl-S fncKey like(APLDCT.fncKey);

// fields used to SFL options program
Dcl-S opt like(APLDCT.opt);

// fields used to program actions program
Dcl-S actCde like(APLDCT.actCde);

// fields used to call the notes master screen
Dcl-S nteKey1 like(APLDCT.nteKey);
Dcl-S nteKey2 like(APLDCT.nteKey);
Dcl-S nteKey3 like(APLDCT.nteKey);
Dcl-S nteKey4 like(APLDCT.nteKey);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMMSTB0');
    pmrPgmNme Like(APLDCT.pgmNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // Handle special options

  // Help text
  If Option = '6';
    pmOption='2';
    PGMHLPD1(pmrPgmNme:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

    // Notes
  ElseIf Option='7';
    // build notes keys, programs are just the program name
    // nteKey1 = pmrPgmNme;
    // Clear nteKey2;
    // Clear nteKey3;
    // Clear nteKey4;
    // pmOption='2';
    // APLNTED1(nteKey1:nteKey2:nteKey3:nteKey4:pmOption:keyPressed);
    // If keyPressed <> 'F3';
    //   keyPressed='';
    // EndIf;
    // pmrKeyPressed=keyPressed;
    Return;

    // Function Keys
  ElseIf Option='9';
    pmOption='2';
    PGMFNCD1(pmrPgmNme:fncKey:Option:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

    // SFL Options
  ElseIf Option='10';
    pmOption='2';
    PGMOPTD1(pmrPgmNme:opt:Option:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

    // Program Actions
  ElseIf Option='11';
    pmOption='2';
    PGMACTD1(pmrPgmNme:actCde:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;

  EndIf;

  // Handle standard options, 1,2,3,4,5,13
  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LASSCR;
    // If Create or Copy Option, Signal to Allow F16
    If pmrOption = '1' or pmrOption = '3';
      keyPressed = 'F16';
    Else;
      Clear keyPressed;
    EndIf;

    If NxtScr = 2;
      PGMMSTD2(pmrPgmNme:Option:keyPressed:toPgm);
    ElseIf NxtScr = 3 and pmrOption='3'; // screen 3 is only displayed for a copy
      PGMMSTD3(pmrPgmNme:toPgm:Option:keyPressed);
    Else;
      Return;
    EndIf;

    If keyPressed = 'F12';
      NxtScr -= 1;
    ElseIf Option = '4';
      Clear NxtScr;
    ElseIf keyPressed = 'F3';
      Clear NxtScr;
    Else;
      NxtScr += 1;
    EndIf;

  EndDo;

End-Proc;
