**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Create Developer Environment. Asks for the
// First 3 characters of the developer's library. It will first try
// the first 3 characters of their first name, if that exists it will
// try the first 3 characters of their last name. If that exists it
// leave blank for the user to enter the first 3 characters to use.

Dcl-F USRMSTF8 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD8_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD8PR // Always include the prototype for the current program
/Copy QSRC,USRMSTC1PR // Get User Profile Values
/Copy GPJOBJLIBP      // Get library - used to see if library exists
/Copy CLP472PR        // Create Developer Environment

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S acUPrf Like(APLLIB.acUPrf);

Dcl-Ds DspVal ExtName('USRMSTF8') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD8');
    pmrAcno Zoned(5);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  acno = pmrAcno;
  Option=pmrOption;

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
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close USRMSTF8;

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
// *** Do not change anything in here ***
Dcl-Proc SetAttributes;

  If ProtectDta;
    FldAtrDta = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrDta;
  EndIf;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmrObjNme like(APLDCT.objNme);
  Dcl-S pmrObjLib like(APLDCT.objLib);
  Dcl-S pmrObjTyp like(APLDCT.objTyp);

  Dcl-Pr opendir Pointer EXTPROC('opendir');
    dirname        Pointer    VALUE OPTIONS(*STRING);
  End-Pr;
  Dcl-Pr closedir Int(10) EXTPROC('closedir');
    dirhandle      Pointer    VALUE;
  End-Pr;
  Dcl-S dir          Pointer;

  error=*off;

  // make sure first 3 value is correct
  If fst3 = ' ';
    $ErrorMessage('':'Error first 3 required.':error:fst3@:'fst3':outRow:outCol:psDsPgmNam);
  EndIf;
  If %subst(fst3:1:1) = ' ' or
     %subst(fst3:2:1) = ' ' or
     %subst(fst3:3:1) = ' ' ;
    $ErrorMessage('':'Error first 3 not valid.':error:fst3@:'fst3':outRow:outCol:psDsPgmNam);
  EndIf;
  pmrObjTyp = '*LIB';
  pmrObjNme = fst3 + 'LIB';
  GPJOBJLIB(pmrObjNme:pmrObjTyp:pmrObjLib);
  If pmrObjLib <> 'NOTFOUND';
    $ErrorMessage('':'Error first 3 already used.':error:fst3@:'fst3':outRow:outCol:psDsPgmNam);
  EndIf;
  Return error;

End-Proc;


// Perform updates if no error
Dcl-Proc UpdateScreen;

  If not ProtectDta;
    CLP472(fst3:acUPrf:USRNME);
  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  // Prompt company
  If CsrFld = 'CMPNME' and not ProtectDta;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;
  // These are returned from USRMSTC1, we need the user name from it
  Dcl-S acFNam Like(APLDCT.acFNam);
  Dcl-S acLNam Like(APLLIB.acLNam);
  Dcl-S acgCde Like(APLDCT.acgCde);
  Dcl-S grpPrf Like(APLDCT.grpPrf);
  Dcl-S jdOqLb Like(APLLIB.jdOqLb);
  Dcl-S jdOutQ Like(APLLIB.jdOutQ);
  Dcl-S usrSts like(APLDCT.usrSts);
  Dcl-S usrCls like(APLDCT.usrCls);
  Dcl-S pmrObjNme like(APLDCT.objNme);
  Dcl-S pmrObjLib like(APLDCT.objLib);
  Dcl-S pmrObjTyp like(APLDCT.objTyp);

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;

  If Option = '14';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'FST3':outRow:outCol);
  Else;
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
  EndIf;

  If not %open(USRMSTF8);
    Open USRMSTF8;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // get user profile from Accesspf
  Exec SQL Select acUPrf, acFNam, acLNam into :acUPrf, :acFNam, :acLNam
  from accesspf where acNo = :acNo;

  // get values from user profile
  USRMSTC1(acUPrf:acgCde:usrNme:jdOutQ:jdOqLb:grpPrf:usrSts:usrCls);

  // Try to figure out which 3 characters to use for the library.
  // First try the first 3 characters of the first name
  // The reason I'm not using QSYS2 is because it can run
  // really slow.
  pmrObjTyp = '*LIB';
  fst3 = %trim(%subst(acFNam:1:3));
  pmrObjNme = fst3 + 'LIB';
  GPJOBJLIB(pmrObjNme:pmrObjTyp:pmrObjLib);
  If pmrObjLib <> 'NOTFOUND';
    // If that doesn't work try the first 3 characters of the last name
    fst3 = %trim(%subst(acLNam:1:3));
    pmrObjNme = fst3 + 'LIB';
    GPJOBJLIB(pmrObjNme:pmrObjTyp:pmrObjLib);
    If pmrObjLib <> 'NOTFOUND';
      // If that doesn't work leave it blank
      fst3 = '';
    EndIf;
  EndIf;

End-Proc;
