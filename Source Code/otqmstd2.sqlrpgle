**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Output Queue Master Maintenance

Dcl-F OTQMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTQMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,OTQMSTD2PR // Always include the prototype for the current program
/Copy QSRC,PRTTGLB2PR
/Copy QSRC,RTVWTRB1PR

// Data structure used to read SQL into
Dcl-Ds dta Qualified;
  otqNme Like(APLDCT.otqNme);
  crtStr Like(APLDCT.crtStr);
  mntStr Like(APLDCT.mntStr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrOTQMSTIdn Like(APLDCT.OTQMSTIdn);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('OTQMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTQMSTD2');
    pmr1OTQMSTIdn Like(APLDCT.OTQMSTIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrOTQMSTIdn=pmr1OTQMSTIdn;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SndMsg('Not authorized to program');
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

  pmrKeyPressed = keyPressed;
  Close OTQMSTF2;

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

  If ProtectKey;
    FldAtrKey = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrKey;
  EndIf;

  If ProtectCpy;
    FldAtrCpy = *allx'A7';    // @PrND
  Else;
    FldAtrCpy = *allx'A2';    // @PrWht
    $SetAttribute(frmKeys@:'');
  EndIf;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  Error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From OTQMST
    Where otqNme = :otqNme;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and not EOF;
    $ErrorMessage('DCT1101':'':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and EOF;
    $ErrorMessage('DCT1102':'':Error);
  EndIf;

  // Validate Rename
  If Option = '7';
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Output Queue Name Name
  If otqNme = *blanks;
    $ErrorMessage('':'Output Queue Name Required':Error:otqNme@:'OTQNME':outRow:outCol:psDsPgmNam);
  EndIf;
  // Valid Dictionary Name
  If frmTyp = *blanks;
    $ErrorMessage('':'Form Type Required':Error:otqNme@:'FRMTYP':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S prt like(APLDCT.prt);
  Dcl-S frmMsg like(APLDCT.frmMsg);

  Eval-Corr dta = DspVal;
  error = *off;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage(#$SQLMsgId(sqlCode):sqlErrmc:error);

    // Create/Copy
  ElseIf Option = '1' or Option = '3';
    Exec SQL
      Insert Into OTQMST
            ( otqNme)
      Values(:otqNme);
    If sqlState > '02';
      $ErrorMessage(#$SQLMsgId(sqlCode):sqlErrmc:error);
    EndIf;

    // Inactivate
  ElseIf Option = '4';
    Exec SQL Update OTQMST Set AcvRow = '0' Where OTQMSTIdn = :pmrOTQMSTIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMsgId(sqlCode):sqlErrmc:error);
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL Update OTQMST Set otqNme = :otqNme Where OTQMSTIdn = :pmrOTQMSTIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMsgId(sqlCode):sqlErrmc:error);
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL Update OTQMST Set AcvRow  = '1' Where OTQMSTIdn = :pmrOTQMSTIdn;
    If sqlState > '02';
      $ErrorMessage(#$SQLMsgId(sqlCode):sqlErrmc:error);
    EndIf;

    // Update
  ElseIf Option = '2';
    prt = otqNme;
    frmTyp = %trim(frmTyp);
    Exec SQL
    Select frmMsg
    Into :frmMsg
    From OTQMST
    Where OTQMSTIdn = :pmrOTQMSTIdn;
    #$CMD('CHGWTR WTR(' + %trim(otqNme) +
           ') FORMTYPE('+ %trim(frmTyp) + ' ' + %trim(frmMsg) +')':1);
    PRTTGLB2(prt);

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

  Dcl-S pmrWtrNme char(10);
  Dcl-S pmrWtrSts char(10);
  Dcl-S pmrFrmTyp char(10);

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

  // * allow key field changes on create
  If Option = '1';
    mde = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    mde = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);
    mde = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'OTQNME':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(OTQMSTF2);
    Open OTQMSTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // Display and process data
  Clear dta;
  Exec SQL
    Select otqNme,
           to_char(crtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(crtJob) || ' ' || trim(crtpgm),
           to_char(mntDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(mntJob) || ' ' || trim(mntpgm)
    Into :dta
    From OTQMST
    Where OTQMSTIdn = :pmrOTQMSTIdn;
  Eval-Corr DspVal = dta;
  crtStr = dta.crtStr;
  mntStr = dta.mntStr;
  otqNmeCpy = otqNme;
  pmrWtrNme = otqNme;
  pmrWtrSts = ' ';
  pmrFrmTyp = ' ';
  RTVWTRB1(pmrWtrNme:pmrWtrSts:pmrFrmTyp);
  frmTyp = pmrFrmTyp;

End-Proc;
