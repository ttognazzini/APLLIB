**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

dcl-f DCTFLDFL WORKSTN InfDS(DspDS) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDDL_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTFLDDLPR // Always include the prototype for the current program
/Copy QSRC,DCTFLDB8PR

Dcl-S Option like(APLDCT.Option);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endmod;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDDL');
    pmrDctNme Like(APLDCT.DctNme);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  DctNme = pmrDctNme;

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
    ElseIf keyPressed = 'F5'; // F5=Refresh
     InitializeProgram();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
    EndIf;
  EndDo;

  Close DCTFLDFL;

End-Proc;


// Display Screen
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

  ExFmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  Clear FldAtrDta;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  error=*off;

  // validate library if entered
  If not #$IsLib(lib);
    $ErrorMessage('':'Invalid library.':error:lib@:'lib':outRow:outCol:psDsPgmNam);

  // validate file
  ElseIf not #$IsFile(fle:lib);
    $ErrorMessage('':'Invalid file.':error:fle@:'fle':outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;

// Update Screen
Dcl-Proc UpdateScreen;

  Monitor;
    Exec SQL call dctflds1(:DctNme,:lib,:fle);
    #$SQLStt();
  On-Error;
    $ErrorMessage('':'Error: '+psdsExcDta);
    Return;
  EndMon;

  // update the actual referenece files for the dictionary
  DCTFLDB8(dctNme);

  $ErrorMessage('':'File Loaded.'+psdsExcDta);

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

  Open DCTFLDFL;

  // get the description for the passed dictionary name
  Exec SQL Select des Into :dctDes From DCTMST Where dctNme=:dctNme;

  Clear Fle;
  Clear Lib;

  // Position Cursor to the file
  $GetFieldLocation(psdsPgmNam:'Fld':outRow:outCol);

End-Proc;
