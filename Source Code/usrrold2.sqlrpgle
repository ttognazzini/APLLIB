**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Role Master Maintenance

Dcl-F USRROLF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRROLD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRROLD2PR // Always include the prototype for the current program
/Copy QSRC,USRMSTBPPR // User auto prompter
/Copy QSRC,USRMSTD1PR // User prompt
/Copy QSRC,ROLMSTBPPR // Role auto prompter
/Copy QSRC,ROLMSTD1PR // Role prompt


// Data structure used to read SQL into
Dcl-Ds dta Qualified;
  usrMstIdn like(APLDCT.usrMstIdn);
  rolMstIdn like(APLDCT.rolMstIdn);
  usrNme Like(APLDCT.usrNme);
  rolNme Like(APLDCT.rolNme);
  lngCmt Like(APLDCT.lngCmt);
  acvDes Like(APLDCT.acvDes);
  aprStr Like(APLDCT.crtStr);
  crtStr Like(APLDCT.crtStr);
  mntStr Like(APLDCT.mntStr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrUsrRolIdn Like(APLDCT.usrRolIdn);
Dcl-S usrMstIdn Like(APLDCT.usrMstIdn);
Dcl-S rolMstIdn Like(APLDCT.rolMstIdn);

Dcl-S option like(APLDCT.option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Dcl-Ds dspVal ExtName('USRROLF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRROLD2');
    pmr1UsrRolIdn Like(APLDCT.UsrRolIdn);
    pmrUsrMstIdn Like(APLDCT.usrMstIdn);
    pmrRolMstIdn Like(APLDCT.rolMstIdn);
    pmrOption Like(APLDCT.option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrUsrRolIdn = pmr1UsrRolIdn;
  usrMstIdn = pmrUsrMstIdn;
  rolMstIdn = pmrRolMstIdn;
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
  Close USRROLF2;

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
    $SetAttribute(usrNmeP@:'ND');
    $SetAttribute(rolNmeP@:'ND');
  Else;
    Clear FldAtrKey;
  EndIf;

  If protectCpy;
    FldAtrCpy = *allx'A7';    // @PrND
  Else;
    FldAtrCpy = *allx'A2';    // @PrWht
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
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmSchVal Like(APLDCT.schVal);
  Dcl-S pmUsrNme Like(APLDCT.usrNme);
  Dcl-S pmRolNme Like(APLDCT.rolNme);

  error = *off;

  // Check Required Data

  // make sure user name is correct, Auto prompt first if not valid, handles ?
  If not protectKey;
    Clear usrMstIdn;
    pmSchVal=usrNme;
    USRMSTBP(pmAcNo:pmSchVal:pmKeyPressed);
    If pmAcNo <> 0;
      Clear pmUsrNme;
      Exec SQL Select trim(acFNam) concat ' ' concat trim(acLNam) into :pmUsrNme from ACCESSPF where acNo = :pmAcNo;
      If pmUsrNme <> usrNme;
        error = *on;
      EndIf;
      usrNme = pmUsrNme;
      Exec SQL Select usrMstIdn into :usrMstIdn from USRMST where accNbr = :pmAcNo;
    EndIf;
    Clear found;
    Exec SQL Select '1' into :found from ACCESSPF where trim(acFNam) concat ' ' concat trim(acLNam) = :usrNme;
    If not found;
      $ErrorMessage('':'Error, invalid user name.':error:usrNme@:'usrNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the role name is correct, Auto prompt first if not valid, handles ?
  If not protectKey;
    Clear rolMstIdn;
    pmRolNme=rolNme;
    ROLMSTBP(pmRolNme:pmKeyPressed);
    If rolNme <> pmRolNme;
      error=*on;
    EndIf;
    rolNme = pmRolNme;
    Exec SQL Select rolMstIdn into :rolMstIdn from ROLMST where rolNme = :rolNme;
    Clear found;
    Exec SQL Select '1' into :found from ROLMST where rolNme = :rolNme;
    If not found;
      $ErrorMessage('':'Error, invalid role.':error:rolNme@:'rolNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From USRROL
    Where usrMstIdn = :usrMstIdn
      and rolMstIdn = :rolMstIdn;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (option = '1' or option = '3' or option = '7') and found;
    $ErrorMessage('':'Entry already exists.':error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If option <> '1' and option <> '3' and option <> '7' and not found;
    $ErrorMessage('':'Entry not found for update.':error);
  EndIf;

  // Validate Rename
  If option = '7';
    // code rename edits here,

    // Validate DeActivate
  ElseIf option = '4';
    // code inactivation edits here,

  EndIf;


  Return error;

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
      Insert Into USRROL
            ( UsrMstIdn, rolMstIdn)
      Values(:usrMstIdn,:rolMstIdn);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Inactivate
  ElseIf option = '4';
    Exec SQL Update USRROL Set AcvRow = '0' Where UsrRolIdn = :pmrUsrRolIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Rename
  ElseIf option = '7';

    // ReActivate
  ElseIf option = '13';
    Exec SQL Update USRROL Set AcvRow  = '1' Where UsrRolIdn = :pmrUsrRolIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Update
  ElseIf option = '2';

  EndIf;

  Return error;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmOption Like(APLDCT.option);
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmRolNme Like(APLDCT.rolNme);

  // Prompt user
  If CsrFld = 'USRNME';
    pmOption = '1';
    USRMSTD1(pmAcNo:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      Clear usrNme;
      Exec SQL Select acFNam concat ' ' concat acLNam into :usrNme from ACCESSPF where acNo = :pmAcNo;
      Clear usrMstIdn;
      Exec SQL Select usrMstIdn into :usrMstIdn from USRMST where accNbr = :pmAcNo;
    EndIf;

    // Prompt role
  ElseIf CsrFld = 'ROLNME';
    pmOption = '1';
    ROLMSTD1(pmRolNme:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      rolNme = pmRolNme;
      Clear rolMstIdn;
      Exec SQL Select rolMstIdn into :rolMstIdn from ROLMST where rolNme = :rolNme;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;

// Initialization subroutine, also called for a F5=Refresh
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

    // * allow key field changes on revise
  ElseIf option = '2';
    mde = 'Revise';
    protectDta = *off;

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

  If not %open(USRROLF2);
    Open USRROLF2;
  EndIf;

  Clear dspVal;

  // Display and process data
  Clear dta;
  If pmrUsrRolIdn <> 0;
    Exec SQL
      Select
        USRROL.usrMstIdn,
        USRROL.rolMstIdn,
        trim(acFNam) || ' ' || trim(acLNam) userNme,
        rolNme,
        lngCmt,
        coalesce(acv.EnmDes,'Error') AcvDes,
        coalesce(
          to_char(ROLAPR.CrtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(ROLAPR.crtJob) || ' ' || trim(ROLAPR.crtpgm),
          'Not Appoved'),
        to_char(USRROL.crtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(USRROL.crtJob) || ' ' || trim(USRROL.crtpgm),
        to_char(USRROL.mntDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(USRROL.mntJob) || ' ' || trim(USRROL.mntpgm)
      Into :dta
      From USRROL
      Left Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn
      Left Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn
      left join ACCESSPF on acNo = accNbr
      Left Join ROLAPR on ROLAPR.rolAprIdn = USRROL.rolAprIdn
      left join DCTVAL as acv on (acv.dctNme,acv.fldNme,acv.enmVal) = ('APLDCT','ACVROW',USRROL.AcvRow)
      Where UsrRolIdn = :pmrUsrRolIdn;
    usrMstIdn = dta.usrMstIdn;
    rolMstIdn = dta.rolMstIdn;
  EndIf;
  Eval-Corr dspVal = dta;
  acvDes = dta.acvDes;
  lngCmt = dta.lngCmt;
  aprStr = dta.aprStr;
  crtStr = dta.crtStr;
  mntStr = dta.mntStr;

  // On entry, set the user name if passed
  If option='1' and usrMstIdn <> 0;
    Exec SQL
      Select trim(acFNam) || ' ' || trim(acLNam) into :usrNme
      From USRMST
      left join ACCESSPF on acNo = accNbr
      Where usrMstIdn = :usrMstIdn;
  EndIf;

  // On entry, set the role name if passed
  If option='1' and rolMstIdn <> 0;
    Exec SQL
      Select rolNme into :rolNme
      From ROLMST
      Where rolMstIdn = :rolMstIdn;
  EndIf;

  If usrNme = '';
    $GetFieldLocation(psdsPgmNam:'USRNME':outRow:outCol);
  Else;
    $GetFieldLocation(psdsPgmNam:'ROLNME':outRow:outCol);
  EndIf;

  SetAttributes();

End-Proc;
