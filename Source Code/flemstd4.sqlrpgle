**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// File Master Copy Options

Dcl-F FLEMSTF4 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTD4_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEMSTD4PR // Always include the prototype for the current program
/Copy QSRC,FLEMSTB9PR // Create the source members
/Copy QSRC,APLLIBD1PR // Library list, prompt
/Copy QSRC,APLLIBBPPR // Library validate/auto promper
/Copy QSRC,PRCSCRD1PR // Display processing screen


Dcl-S option like(APLDCT.Option);
Dcl-Ds DspVal ExtName('FLEMSTF4') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTD4');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  option = '2';

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psdsPgmNam:psdsUsrPrf:option);
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
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  Close FLEMSTF4;

  If %parms >= 3;
    pmrKeyPressed = keyPressed;
  EndIf;

End-Proc;


// Display Screen
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // populate the source library descrption
  Exec SQL Select libDes into :srcLibDes from APLLIB where libNme = :srcLib;


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

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error        Ind;
  Dcl-S pmLibNme     like(APLDCT.LibNme);
  Dcl-S pmDes        like(APLDCT.des);
  Dcl-S pmKeyPressed like(keyPressed);

  Error=*off;

  // Validate/Auto Prompt source library
  pmLibNme = srcLib;
  Callp APLLIBBP(pmLibNme:pmDes:pmKeyPressed);
  If pmlibNme <> '';
    If srcLib <> pmLibNme; // redisplay if the value changes
      error=*on;
    EndIf;
    srcLib = pmLibNme;
  EndIf;

  If srcLib = '';
    $ErrorMessage('':'Error Source Library is required.':Error:srcLib@:'srcLib':outRow:outCol:psdsPgmNam);
  ElseIf not #$ISLIB(srcLib);
    $ErrorMessage('':'Error Source Library does not exists.':Error:srcLib@:'srcLib':outRow:outCol:psdsPgmNam);
  EndIf;

  // Validate source file
  If srcFle = '';
    $ErrorMessage('':'Error Source File is required.':Error:srcFle@:'srcFle':outRow:outCol:psdsPgmNam);
  ElseIf not #$ISFILE(srcFle:srcLib);
    $ErrorMessage('':'Error Source File does not exists.':Error:srcFle@:'srcFle':outRow:outCol:psdsPgmNam);
  EndIf;

  // Validate source library
  If objLib <> '' and not #$ISLIB(objLib);
    $ErrorMessage('':'Error Object Library does not exists.':Error:objLib@:'objLib':outRow:outCol:psdsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// Update the screen
Dcl-Proc UpdateScreen;

  // Display processing screen
  PRCSCRD1('Building source members.');

  // call program to build source members
  FLEMSTB9(fleLib:fleNme:srcLib:srcFle:objLib);

End-Proc;



// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmLibNme like(APLDCT.fldTyp);
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmOption like(Option);
  // Prompt status description
  If csrFld = 'SRCLIB';
    pmOption = '1';
    APLLIBD1(pmLibNme:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      srcLib = pmLibNme;
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
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$NextFunctionKeys(fncDs);

  If not %open(FLEMSTF4);
    Open FLEMSTF4;
  EndIf;

  Clear DspVal;

  // Default the source library to the developemnt library of the user if found
  Exec SQL Select libNme into :srcLib From APLLIB Where devUsr = :user limit 1;
  If srcLib = '';
    srcLib = user;
  EndIf;

  // Default the srouce file to QSRC
  srcFle = 'QSRC';

  // populate the file descrption
  Exec SQL Select fleDes into :fleDes from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // populate the library descrption
  Exec SQL Select libDes into :libDes from APLLIB where libNme = :fleLib;

End-Proc;
