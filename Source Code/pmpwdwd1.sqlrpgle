**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Display Prompt Window

Dcl-F PMPWDWF1 WORKSTN InfDS(dspDs) UsrOpn;


/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PMPWDWD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,PMPWDWD1PR // Always include the prototype for the current program

Dcl-S values varchar(40);

Dcl-S Option like(APLDCT.Option);

// Used to split the input text into seperate fields
Dcl-Ds wrap;
  clnString char(440);
  mess01 char(55) overlay(clnString:1);
  mess02 char(55) overlay(clnString:56);
  mess03 char(55) overlay(clnString:111);
  mess04 char(55) overlay(clnString:166);
  mess05 char(55) overlay(clnString:221);
  mess06 char(55) overlay(clnString:276);
  mess07 char(55) overlay(clnString:331);
  mess08 char(55) overlay(clnString:386);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PMPWDWD1');
    pmrText varchar(400) const;
    pmrAns char(1);
    pmrValues varchar(10) const;
    pmrValDes varchar(40) const;
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  clnString=#$WORDWRAP(pmrText:55);
  ans = pmrAns;
  values = pmrValues;
  dspVal = '(' + pmrValDes +')';

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SNDMSG('Not authorized to program');
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
  pmrAns = ans;
  Close PMPWDWF1;

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

  Error=*off;

  // make sure the ans entered is in the list of values
  If %scan(ans:values)=0;
    $ErrorMessage('':'Error - invalid option.':Error:ans@:'ans':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;


End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  // Prompt State
  If CsrFld = 'DES';
    // FLDDTLD1('STE':PmFldVal:1:keyPressed);
    // If keyPressed = 'Enter' and not ProtectDta;
    //    Des = PmFldVal;
    // EndIf;

    // Prompt Country
  ElseIf CsrFld = 'NTE';
    // FLDDTLD1('COU':PmFldVal:1:keyPressed);
    // If keyPressed = 'Enter' and not ProtectDta;
    //    Nte = PmFldVal;
    // EndIf;

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

  If not %open(PMPWDWF1);
    Open PMPWDWF1;
  EndIf;

  SetAttributes();
  Clear ans;

End-Proc;
