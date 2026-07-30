**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Prompt for User

dcl-f USRMSTF5 WORKSTN InfDS(DspDS) UsrOpn;


/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD5_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD5PR // Always include the prototype for the current program
/Copy QSRC,USRMSTBPPR // Prompt for a user

Dcl-S Option like(APLDCT.Option);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD5');
    pmrTitle char(50) const;
    pmrUsrPrf like(APLDCT.usrPrf);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  title = #$cntr(pmrTitle:50);
  usrPrf = pmrUsrPrf;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12';
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
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  pmrUsrPrf = usrPrf;
  Close USRMSTF5;

End-Proc;


// Display Screen
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRow and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields otuRowScr and outRowCol which means we
  // have to move the values into those fields before we display the screen.
  outRowScr=outRow;
  outColScr=outCol;

  // Load SFL options if needed
  Write MSGCTL;

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
// *** Do not change anything in here ***
Dcl-Proc SetAttributes;

  Clear FldAtrDta;
  Clear FldAtrKey;
  Clear FldAtrCpy;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  error=*off;

  // make sure the user entered is valid
  if usrPrf <> '';
    found = *off;
    Exec SQL Select '1' into :found from USRMST where usrPRf = :usrPrf;
    if not found;
      $ErrorMessage('':'Error - invalid user.':error:usrPrf@:'usrPrf':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;


End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmSchVal Like(APLLIB.SchVal);
  Dcl-S pmAcNo Like(APLLIB.ACNO);

  // Prompt State
  if CsrFld = 'USRPRF';
    USRMSTBP(pmAcNo:pmSchVal:keyPressed);
    If keyPressed = 'ENTER';
      Exec SQL Select acUPrf into :usrPrf from accesspf where acNo=:pmAcNo;
    EndIf;

  //* Error if not on promptable field
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
  fncKeys=$nextFunctionKeys(fncDs);

  If not %open(USRMSTF5);
    Open USRMSTF5;
  EndIf;

  SetAttributes();
End-Proc;
