**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

Dcl-F UDFMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,UDFMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,UDFMSTD2PR // Always include the prototype for the current program


// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  pgmNme Like(APLDCT.pgmNme);
  UDFKey Like(APLDCT.UDFKey);
  UDFDes Like(APLDCT.UDFDes);
  usrCnf Like(APLDCT.usrCnf);
  UDFOpt Like(APLDCT.UDFOpt);
  UDFDft Like(APLDCT.UDFDft);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrPgmNme Like(APLDCT.pgmNme);
Dcl-S pmrUDFKey Like(APLDCT.UDFKey);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('UDFMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('UDFMSTD2');
    pmr1PgmNme Like(APLDCT.pgmNme);
    pmr1UDFKey Like(APLDCT.UDFKey);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrPgmNme=pmr1PgmNme;
  pmrUDFKey=pmr1UDFKey;
  pgmNme = pmrPgmNme;
  UDFKey = pmrUDFKey;
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
  pmr1PgmNme = pgmNme; // set the return key in case a new entry was added or copied
  pmr1UDFKey = UDFKey; // set the return key in case a new entry was added or copied
  Close UDFMSTF2;

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
    From UDFMST
    Where pgmNme = :pgmNme and UDFKey = :UDFKey;
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
  If Option = '7'  and pgmNme <> pmrPgmNme;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Program Name
  If pgmNme = *blanks;
    $ErrorMessage('':'Error - A Program name must be entered.':Error:pgmNme@:'pgmNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Key
  If UDFKey = *blanks;
    $ErrorMessage('':'Error - A key value must be entered.':Error:UDFKey@:'UDFKey':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Description
  If UDFDes = *Blanks and not ProtectDta;
    $ErrorMessage('':'Error - A description must be entered.':Error:UDFDes@:'UDFDes':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid User Configurable
  If not(usrCnf in %list('Y':'N')) and not ProtectDta;
    $ErrorMessage('':'Error - Invalid user configurable option.':Error:usrCnf@:'usrCnf':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Option Type
  If not(UDFOpt in %list('Y/N':'ATTRIBUTE')) and not ProtectDta;
    $ErrorMessage('':'Error - Invalid option type.':Error:UDFOpt@:'UDFOpt':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Y/N Default Value
  If  UDFOpt = 'Y/N' and not (UDFDft in %list('Y':'N'))
    and not ProtectDta;
    $ErrorMessage('':'Error - Invalid option type.':Error:UDFOpt@:'UDFOpt':outRow:outCol:psDsPgmNam);
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

    // Create
  ElseIf Option = '1';
    Exec SQL
    Insert Into UDFMST
    (AcvRow, pgmNme, UDFKey, UDFDes, usrCnf, UDFOpt, UDFDft,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :pgmNme, :UDFKey, :UDFDes, :usrCnf, :UDFOpt, :UDFDft,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Copy
  ElseIf Option = '3';
    Exec SQL
    Insert Into UDFMST
    (AcvRow, pgmNme, UDFKey, UDFDes, usrCnf, UDFOpt, UDFDft,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :pgmNme, :UDFKey, :UDFDes, :usrCnf, :UDFOpt, :UDFDft,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Inactivate
  ElseIf Option = '4';
    Exec SQL
    Update UDFMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where pgmNme = :pgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
      Update UDFMST
      Set (pgmNme, UDFKey, MntDtm, MntUsr, MntJob, MntPgm)
        = (:pgmNme, :UDFKey, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (pgmNme,UDFKey) = (:pmrPgmNme,:pmrUDFKey);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update UDFMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where pgmNme = :pgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update UDFMST
      Set (  UDFDes, usrCnf, UDFOpt, UDFDft, MntDtm, MntUsr, MntJob, MntPgm)
        = ( :UDFDes,:usrCnf,:UDFOpt,:UDFDft, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where (pgmNme,UDFKey) = (:pgmNme,:UDFKey);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

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
  // the first procedure is always Main. pgmNmeH is used in the screen headers.
  callStk='MAIN';
  pgmNmeH=psdsPgmNam;

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
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'UDFDes':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    mde = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);
    mde = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'pgmNme':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(UDFMSTF2);
    Open UDFMSTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  pgmNmeCpy = pmrPgmNme;

  // Display and process data
  Clear Dta;
  pgmNme = pmrPgmNme;
  UDFKey = pmrUDFKey;
  Exec SQL
    Select  pgmNme, UDFKey, UDFDes, usrCnf, UDFOpt, UDFDft
      Into :pgmNme,:UDFKey,:UDFDes,:usrCnf,:UDFOpt,:UDFDft
    From UDFMST
    Where (pgmNme,UDFKey) = (:pgmNme,:UDFKey);

  // If in entry mode set the key value to what ever is passed in and move cursor to the next field
  If Option='1' and pmrpgmNme<>'';
    pgmNme=pmrPgmNme;
    UDFKey=pmrUDFKey;
    $GetFieldLocation(psdsPgmNam:'UDFDes':outRow:outCol);
  EndIf;

End-Proc;
