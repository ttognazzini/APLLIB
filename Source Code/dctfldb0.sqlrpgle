**Free
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) DftActGrp(*No) ActGrp(*Caller) Main(Main);

//  Dictionary Field Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTMSTB0PR // Always include the prototype for the current program
/Copy QSRC,DCTFLDD2PR
/Copy QSRC,DCTVALD1PR
/Copy QSRC,HLPDTLD1PR // Help text detail
/Copy QSRC,AUDLOGD1PR

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LasScr const(2);

// fileds used to call HLPDTLD1
Dcl-S pmDctNme Like(APLDCT.dctNme);
Dcl-S pmFldNme Like(APLDCT.fldNme);
Dcl-S pmDspFle Like(APLDCT.dspFle);
Dcl-S pmVal    Like(APLDCT.val   );
Dcl-S pmOption Like(APLDCT.Option);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endmod;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDB0');
    pmrDctMstIdn Like(APLDCT.DctMstIdn);
    pmrDctFldIdn Like(APLDCT.DctFldIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;
  Dcl-S pmEnmVal like(APLDCT.EnmVal);

  Option = pmrOption;

  // get dicationary and field name foe external programs, they should be changed to work on the Id, but no time now.
  Exec SQL Select dctNme, fldNme into :pmDctNme, :pmFldNme from DCTFLD where dctFldIdn = :pmrDctFldIdn;

  // Handle special options

  // Help text
  If Option = '6';
    Exec SQL Select dctNme, fldNme into :pmDctNme, :pmFldNme from DCTFLD where dctFldIdn = :pmrDctFldIdn;
    pmDspFle = ' ';
    pmVal    = ' ';
    pmOption='2';
    CallP HLPDTLD1(pmDctNme:pmFldNme:pmDspFle:pmVal:pmOption:keyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;
  elseif Option = '11'; // View Log
    pmOption='5';
    CallP AUDLOGD1('APLLIB':'DCTFLD':'':pmrDctFldIdn:pmOption:KeyPressed);
    If keyPressed <> 'F3';
      keyPressed='';
    EndIf;
    pmrKeyPressed=keyPressed;
    Return;
  EndIf;


  NxtScr=2;
  DoW NxtScr > 1 and NxtScr <= LasScr;

    If NxtScr = 2;
      If pmrOption='9';
        CallP DCTVALD1(pmDctNme:pmFldNme:pmEnmVal:'2':keyPressed);
      Else;
        CallP DCTFLDD2(pmrDctFldIdn:pmrDctMstIdn:Option:keyPressed);
      EndIf;
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

  // return key pressed
  pmrKeyPressed=keyPressed;

End-Proc;
