**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Role Master Maintenance

Dcl-F ROLMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,ROLMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,ROLMSTD2PR // Always include the prototype for the current program


// Data structure used to read SQL into
Dcl-Ds dta Qualified;
  RolNme Like(APLDCT.RolNme);
  lngCmt Like(APLDCT.lngCmt);
  acvDes Like(APLDCT.acvDes);
  crtStr Like(APLDCT.crtStr);
  mntStr Like(APLDCT.mntStr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrRolMstIdn Like(APLDCT.RolMstIdn);

Dcl-S option like(APLDCT.option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Dcl-Ds dspVal ExtName('ROLMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ROLMSTD2');
    pmr1RolMstIdn Like(APLDCT.RolMstIdn);
    pmrOption Like(APLDCT.option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrRolMstIdn = pmr1RolMstIdn;
  option = pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs = $Security(psDsPgmNam:psDsUsrPrf:option);
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
    ElseIf mde = 'Display'; // If in display mode, don't validate or update, just leave
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    ElseIf not UpdateScreen(); // If no errors process screen updates
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close ROLMSTF2;

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
  outRowScr = outRow;
  outColScr = outCol;

  Exfmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed = $ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow = csrRow;
  outCol = csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  SetAttributes();

End-Proc;


// Set Field Attributes
// *** Do not change anything in here ***
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
    $SetAttribute(frmKeys@:'');
  EndIf;

  // make the status red if inactive
  If acvDes = 'Inactive';
    $SetAttribute(acvDes@:'Red');
  Else;
    $SetAttribute(acvDes@:'');
  EndIf;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  Error = *off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From ROLMST
    Where RolNme = :RolNme;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (option = '1' or option = '3' or option = '7') and not EOF;
    $ErrorMessage('DCT1101':'':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If option <> '1' and option <> '3' and option <> '7' and EOF;
    $ErrorMessage('DCT1102':'':Error);
  EndIf;

  // Validate Rename
  If option = '7';
    // code rename edits here,

    // Validate DeActivate
  ElseIf option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Role Name
  If RolNme = *blanks;
    $ErrorMessage('DCT1001':'':Error:rolNme@:'rolNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Role Description
  If lngCmt = *Blanks and not protectDta;
    $ErrorMessage('DCT1003':'':Error:lngCmt@:'lngCmt':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  Eval-Corr dta = dspVal;
  error = *off;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);

    // Create/Copy
  ElseIf option = '1' or option = '3';
    Exec SQL
      Insert Into ROLMST
            ( RolNme, lngCmt)
      Values(:RolNme,:lngCmt);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Inactivate
  ElseIf option = '4';
    Exec SQL Update ROLMST Set AcvRow = '0' Where RolMstIdn = :pmrRolMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Rename
  ElseIf option = '7';
    Exec SQL Update ROLMST Set RolNme = :RolNme Where RolMstIdn = :pmrRolMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // ReActivate
  ElseIf option = '13';
    Exec SQL Update ROLMST Set AcvRow  = '1' Where RolMstIdn = :pmrRolMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Update
  ElseIf option = '2';
    Exec SQL
      Update ROLMST
      Set ( lngCmt)
        = (:lngCmt)
      Where RolMstIdn = :pmrRolMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

  EndIf;

  Return error;

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
  callStk = 'MAIN';
  pgmNme = psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs = $GetFunctionKeys(psdsPgmNam);
  fncKeys = $NextFunctionKeys(fncDs);

  // * protect fields
  protectCpy = *on;
  protectKey = *on;
  protectDta = *on;

  // * allow key field changes on create
  $GetFieldLocation(psdsPgmNam:'ROLNME':outRow:outCol);
  If option = '1';
    mde = 'Create';
    protectKey = *off;
    protectDta = *off;

    // * allow key field changes on revise
  ElseIf option = '2';
    mde = 'Revise';
    protectDta = *off;
    $GetFieldLocation(psdsPgmNam:'LNGCMT':outRow:outCol);

    // allow key field changes on copy
  ElseIf option = '3';
    mde = 'Copy';
    protectCpy = *off;
    protectKey = *off;
    protectDta = *off;

    // * disallow key field changes on delete
  ElseIf option = '4';
    mde = 'DeActivate';

    // * disallow field changes on display
  ElseIf option = '5';
    mde = 'Display';

    // * allow key field changes on rename
  ElseIf option = '7';
    mde = 'Rename';
    protectCpy = *off;
    protectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf option = '13';
    mde = 'ReActivate';

  Else;
    mde = 'Unknown';
  EndIf;

  If not %open(ROLMSTF2);
    Open ROLMSTF2;
  EndIf;

  Clear dspVal;

  // Display and process data
  Clear dta;
  Exec SQL
    Select rolNme, lngCmt,
           coalesce(acv.EnmDes,'Error') AcvDes,
           to_char(ROLMST.crtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(ROLMST.crtJob) || ' ' || trim(ROLMST.crtpgm),
           to_char(ROLMST.mntDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(ROLMST.mntJob) || ' ' || trim(ROLMST.mntpgm)
    Into :dta
    From ROLMST
    left join DCTVAL as acv on (acv.dctNme,acv.fldNme,acv.enmVal) = ('APLDCT','ACVROW',ROLMST.AcvRow)
    Where RolMstIdn = :pmrRolMstIdn;
  Eval-Corr dspVal = dta;
  acvDes = dta.acvDes;
  crtStr = dta.crtStr;
  mntStr = dta.mntStr;
  rolNmeCpy = rolNme;

  SetAttributes();

End-Proc;
