**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

Dcl-F DCTMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTMSTD2PR // Always include the prototype for the current program


// Data structure used to read SQL into
Dcl-Ds dta Qualified;
  DctNme Like(APLDCT.DctNme);
  Des    Like(APLDCT.Des);
  Nte    Like(APLDCT.Nte);
  acvDes Like(APLDCT.acvDes);
  crtStr Like(APLDCT.crtStr);
  mntStr Like(APLDCT.mntStr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrDctMstIdn Like(APLDCT.DctMstIdn);

Dcl-S option like(APLDCT.option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Dcl-Ds dspVal ExtName('DCTMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTMSTD2');
    pmr1DctMstIdn Like(APLDCT.DctMstIdn);
    pmrOption Like(APLDCT.option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrDctMstIdn = pmr1DctMstIdn;
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
  Close DCTMSTF2;

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
    From DCTMST
    Where DctNme = :DctNme;
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

  // Valid Dictionary Name
  If DctNme = *blanks;
    $ErrorMessage('DCT1001':'':Error:dctNme@:'dctNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Dictionary Description
  If Des = *Blanks and not protectDta;
    $ErrorMessage('DCT1003':'':Error:des@:'des':outRow:outCol:psDsPgmNam);
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
      Insert Into DCTMST
            ( DctNme, Des, Nte)
      Values(:DctNme,:Des,:Nte);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Inactivate
  ElseIf option = '4';
    Exec SQL Update DCTMST Set AcvRow = '0' Where DctMstIdn = :pmrDctMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Rename
  ElseIf option = '7';
    Exec SQL Update DCTMST Set DctNme = :DctNme Where DctMstIdn = :pmrDctMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // ReActivate
  ElseIf option = '13';
    Exec SQL Update DCTMST Set AcvRow  = '1' Where DctMstIdn = :pmrDctMstIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Update
  ElseIf option = '2';
    Exec SQL
      Update DCTMST
      Set ( Des, Nte)
        = (:Des,:Nte)
      Where DctMstIdn = :pmrDctMstIdn;
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
    // Callp(e) FLDDTLD1('STE':PmFldVal:1:keyPressed);
    // If keyPressed = 'Enter' and not ProtectDta;
    //    Des = PmFldVal;
    // EndIf;

    // Prompt Country
  ElseIf CsrFld = 'NTE';
    // Callp(e) FLDDTLD1('COU':PmFldVal:1:keyPressed);
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
  If option = '1';
    mde = 'Create';
    protectKey = *off;
    protectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);

    // * allow key field changes on revise
  ElseIf option = '2';
    mde = 'Revise';
    protectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf option = '3';
    mde = 'Copy';
    protectCpy = *off;
    protectKey = *off;
    protectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);

    // * disallow field changes on display
  ElseIf option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);

    // * allow key field changes on rename
  ElseIf option = '7';
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);
    mde = 'Rename';
    protectCpy = *off;
    protectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf option = '13';
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(DCTMSTF2);
    Open DCTMSTF2;
  EndIf;

  Clear dspVal;

  // Display and process data
  Clear dta;
  Exec SQL
    Select DCTMST.DctNme, Des, Nte,
           coalesce(acv.EnmDes,'Error') AcvDes,
           to_char(DCTMST.crtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(DCTMST.crtJob) || ' ' || trim(DCTMST.crtpgm),
           to_char(DCTMST.mntDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(DCTMST.mntJob) || ' ' || trim(DCTMST.mntpgm)
    Into :dta
    From DCTMST
    left join DCTVAL as acv on (acv.DctNme,acv.fldNme,acv.enmVal) = ('APLDCT','ACVROW',DCTMST.AcvRow)
    Where DctMstIdn = :pmrDctMstIdn;
  Eval-Corr dspVal = dta;
  acvDes = dta.acvDes;
  crtStr = dta.crtStr;
  mntStr = dta.mntStr;
  dctNmeCpy = dctNme;

  SetAttributes();

End-Proc;
