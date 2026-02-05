**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Program Actions Maintenance
//
// WARNING this deviates from the template a little, the issue is both PGMNME and OPTION
// are keys to the file. To overcome this the template OPTION has been renamed to OPTION2
// and PGMNME has been renamed to PGMNME2. The instances of OPTION and PGMNME remaining are
// the data variables, not the template variables.

Dcl-F PGMACTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMACTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,PGMACTD2PR // Always include the prototype for the current program

// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  des       Like(APLDCT.des);
  fncKey    Like(APLDCT.fncKey);
  seqNbr    Like(APLDCT.seqNbr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrPgmNme Like(APLDCT.pgmNme);
Dcl-S pmrActCde Like(APLDCT.actCde);
Dcl-S pmrOption Like(APLDCT.option);

Dcl-S Option2 like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('PGMACTF2') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMACTD2');
    pmr1pgmNme    Like(APLDCT.pgmNme);
    pmr1actCde    Like(APLDCT.actCde);
    pmrOption     Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrPgmNme = pmr1pgmNme;
  pmrActCde = pmr1actCde;
  pgmNme    = pmrPgmNme;
  actCde    = pmrActCde;
  Option2   = pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option2);
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
    ElseIf mode = 'Display'; // If in display mode, don't validate or update, just leave
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close PGMACTF2;

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
    From PGMACT
    Where (pgmNme,actCde) = (:pgmNme,:actCde);
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option2 = '1' or Option2 = '3' or Option2 = '7') and not EOF;
    $ErrorMessage('DCT1101':'':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option2 <> '1' and Option2 <> '3' and Option2 <> '7' and EOF;
    $ErrorMessage('DCT1102':'':Error);
  EndIf;

  // Validate Rename
  If Option2 = '7'  and pgmNme <> pmrPgmNme;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option2 = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Dictionary Name
  If pgmNme = *blanks;
    $ErrorMessage('DCT1001':'':Error:pgmNme@:'pgmNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Program Description
  If Des = *Blanks and not ProtectDta;
    $ErrorMessage('DCT1003':'':Error:des@:'des':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;

  Eval-Corr Dta = DspVal;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage('DCT0200');

    // Create/Copy
  ElseIf Option2 = '1' or Option2='3';
    Exec SQL
    Insert Into PGMACT
    (AcvRow, pgmNme, actCde, option, Des, fncKey, seqNbr,
     CrtDtm, CrtUsr, CrtJob, CrtPgm,
     MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :pgmNme, :actCde, :option, :Des, :fncKey, :seqNbr,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Inactivate
  ElseIf Option2 = '4';
    Exec SQL
    Update PGMACT
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (pgmNme,actCde) = (:pgmNme,:actCde);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option2 = '7';
    Exec SQL
    Update PGMACT
    Set   ( pgmNme, actCde, option,MntDtm,MntUsr,MntJob,MntPgm)
        = (:pgmNme,:actCde,:option,Current TimeStamp,:User,:psdsJobNam,:psdsPgmNam)
    Where (pgmNme,actCde) = (:pmrPgmNme,:pmrActCde);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option2 = '13';
    Exec SQL
    Update PGMACT
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (pgmNme,actCde) = (:pmrPgmNme,:pmrActCde);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option2 = '2';
    Exec SQL
      Update PGMACT
      set (AcvRow, pgmNme, actCde, option, Des, fncKey, seqNbr,
           MntDtm, MntUsr, MntJob, MntPgm)
        = ('1', :pgmNme, :actCde, :option, :Des, :fncKey, :seqNbr,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (pgmNme,actCde) = (:pmrPgmNme,:pmrActCde);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  $ErrorMessage('DCT0004');

End-Proc;

// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme2 is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;

  // * allow key field changes on create
  $GetFieldLocation(psdsPgmNam:'actCde':outRow:outCol);
  If Option2 = '1';
    Mode = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;

    // * allow key field changes on revise
  ElseIf Option2 = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option2 = '3';
    Mode = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;

    // * disallow key field changes on delete
  ElseIf Option2 = '4';
    Mode = 'DeActivate';

    // * disallow field changes on display
  ElseIf Option2 = '5';
    Mode = 'Display';

    // * allow key field changes on rename
  ElseIf Option2 = '7';
    Mode = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option2 = '13';
    Mode = 'ReActivate';

  Else;
    Mode = 'Unknown';
  EndIf;

  If not %open(PGMACTF2);
    Open PGMACTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  pgmNmeCpy = pmrPgmNme;
  actCdeCpy = pmrActCde;

  // Display and process data
  Clear Dta;
  pgmNme = pmrPgmNme;
  actCde = pmrActCde;
  Exec SQL
    Select des, fncKey, seqNbr
      Into :Dta
    From PGMACT
    Where (pgmNme,actCde) = (:pgmNme,:actCde);
  Eval-Corr DspVal = Dta;

End-Proc;
