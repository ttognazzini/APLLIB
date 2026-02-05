**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Output Options - Parameter Maintenance

Dcl-F OTOPRMF1 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR // prototypes for output options procedures
/Copy QSRC,OTOPRMD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTVALBPPR // Enumerated Value validaotr/auto prompter
/Copy QSRC,DCTVALDPPR // Enumerated Value Prompt


Dcl-S alwEml like(APLDCT.alwEml);
Dcl-S alwArc like(APLDCT.alwArc);
Dcl-S alwFax like(APLDCT.alwFax);
Dcl-S autOpt like(APLDCT.autOpt);

Dcl-S Option like(APLDCT.Option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Dcl-Ds DspVal ExtName('OTOPRMF1') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOPRMD1');
  End-Pi;

  Option='2';

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12' or keyPressed = 'F16';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3'; // F3=Exit
      Leave;
    ElseIf keyPressed = 'F4'; // F4=Prompt
      Prompt();
    ElseIf keyPressed = 'F5';  // F5=Refresh
      InitializeProgram();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf mde = 'Display'; // If in display mode, don't validate or update, just leave
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      If not UpdateScreen();
        Leave;
      EndIf;
    EndIf;
  EndDo;

  Close OTOPRMF1;

End-Proc;


// Display Screen
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // Load SFL options if needed
  Write MSGCTL;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRow and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields otuRowScr and outRowCol which means we
  // have to move the values into those fields before we display the screen.
  outRowScr=outRow;
  outColScr=outCol;

  Exfmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  SetAttributes();

End-Proc;


// Set Field Attributes
Dcl-Proc SetAttributes;

  If protectDta;
    FldAtrDta = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrDta;
  EndIf;

  If protectKey;
    FldAtrKey = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrKey;
  EndIf;

  If protectCpy;
    FldAtrCpy = *allx'A7';    // @PrND
  Else;
    FldAtrCpy = *allx'A2';    // @PrWht
  EndIf;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  error=*off;

  // make sure the allow email option is correct, Auto prompt first if not valid, handles ?
  If not protectDta;
    pmEnmVal='';
    pmEnmDes=alwEmlD;
    DCTVALBP('APLDCT':'ALWEML':pmEnmVal:pmEnmDes:pmKeyPressed);
    If alwEmlD <> pmEnmDes;
      error=*on;
    EndIf;
    alwEmlD = pmEnmDes;
    alwEml = pmEnmVal;
    If not $ValidEnmDes(#$UPIFY(alwEmlD):'APLDCT':'alwEml');
      $ErrorMessage('':'Error invalid option.':error:alwEmlD@:'alwEmlD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the allow archive option is correct, Auto prompt first if not valid, handles ?
  If not protectDta;
    pmEnmVal='';
    pmEnmDes=alwArcD;
    DCTVALBP('APLDCT':'ALWARC':pmEnmVal:pmEnmDes:pmKeyPressed);
    If alwArcD <> pmEnmDes;
      error=*on;
    EndIf;
    alwArcD = pmEnmDes;
    alwArc = pmEnmVal;
    If not $ValidEnmDes(#$UPIFY(alwArcD):'APLDCT':'alwArc');
      $ErrorMessage('':'Error invalid option.':error:alwArcD@:'alwArcD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the allow faxing option is correct, Auto prompt first if not valid, handles ?
  If not protectDta;
    pmEnmVal='';
    pmEnmDes=alwFaxD;
    DCTVALBP('APLDCT':'ALWFAX':pmEnmVal:pmEnmDes:pmKeyPressed);
    If alwFaxD <> pmEnmDes;
      error=*on;
    EndIf;
    alwFaxD = pmEnmDes;
    alwFax = pmEnmVal;
    If not $ValidEnmDes(#$UPIFY(alwFaxD):'APLDCT':'alwFax');
      $ErrorMessage('':'Error invalid option.':error:alwFaxD@:'alwFaxD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the auto display options value is correct, Auto prompt first if not valid, handles ?
  If not protectDta;
    pmEnmVal='';
    pmEnmDes=autOptD;
    DCTVALBP('APLDCT':'AUTOPT':pmEnmVal:pmEnmDes:pmKeyPressed);
    If autOptD <> pmEnmDes;
      error=*on;
    EndIf;
    autOptD = pmEnmDes;
    autOpt = pmEnmVal;
    If not $ValidEnmDes(#$UPIFY(autOptD):'APLDCT':'autOpt');
      $ErrorMessage('':'Error invalid option.':error:autOptD@:'autOptD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;


  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  error = *off;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);

    // Update
  ElseIf Option = '2';
    In *lock OTODFT;
    sysAlwEml = alwEml;
    sysAlwArc = alwArc;
    sysAlwFax = alwFax;
    sysAutOpt = autOpt;
    sysFrmEml = sysEml;
    sysFrmNme = sysNme;
    sysPstFlr = sysFlr;
    Out OTODFT;
  EndIf;

  Return error;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmKeyPressed Like(keyPressed);

  // Prompt Allow Email
  If CsrFld = 'ALWEMLD';
    Callp DCTVALDP('APLDCT':'ALWEML':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      alwEmlD = pmEnmDes;
    EndIf;

  ElseIf CsrFld = 'ALWARCD';
    // Prompt Allow Archive
    Callp DCTVALDP('APLDCT':'ALWARC':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      alwArcD = pmEnmDes;
    EndIf;

  ElseIf CsrFld = 'ALWFAXD';
    // Prompt Allow Faxing
    Callp DCTVALDP('APLDCT':'ALWFAX':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      alwFaxD = pmEnmDes;
    EndIf;

  ElseIf CsrFld = 'AUTOPTD';
    // Prompt Auot Display Output Options
    Callp DCTVALDP('APLDCT':'QUTOPT':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      autOptD = pmEnmDes;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;

// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  protectCpy = *on;
  protectKey = *on;
  protectDta = *on;

  $GetFieldLocation(psdsPgmNam:'ALWEML':outRow:outCol);
  // * allow key field changes on revise
  If Option = '2';
    mde = 'Revise';
    protectDta = *off;

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';

  Else;
    mde = 'Unknown';
  EndIf;

  If not %open(OTOPRMF1);
    Open OTOPRMF1;
  EndIf;

  // TRY to create the data area, if it works set the defualts, otheriwwse ignore it
  Monitor;
    #$CMD('CRTDTAARA  QGPL/OTODFT TYPE(*CHAR) LEN(300) VALUE(''00000000'')':2);
    In *lock OTODFT;
    sysAlwEml = 'N';
    sysAlwArc = 'N';
    sysAlwFax = 'N';
    sysAutOpt = 'Y';
    sysFrmEml = '';
    sysFrmNme = '';
    sysPstFlr = '';
    sysUniNbr = 0;
    Out OTODFT;
  On-Error;
  EndMon;

  Clear DspVal;

  // Get System options
  in OTODFT;
  alwEml = sysAlwEml;
  alwArc = sysAlwArc;
  alwFax = sysAlwFax;
  autOpt = sysAutOpt;
  sysEml = sysFrmEml;
  sysNme = sysFrmNme;
  sysFlr = sysPstFlr;

  // Get descritpions for enumerated values
  Exec SQL Select enmDes into :alwEmlD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','ALWEML',:alwEml);
  Exec SQL Select enmDes into :alwArcD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','ALWARC',:alwArc);
  Exec SQL Select enmDes into :alwFaxD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','ALWFAX',:alwFax);
  Exec SQL Select enmDes into :autOptD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','AUTOPT',:autOpt);

  SetAttributes();

End-Proc;
