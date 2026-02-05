**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Fabricut Libraries Maintenance

Dcl-F APLLIBF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,APLLIBD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,APLLIBD2PR // Always include the prototype for the current program
/Copy QSRC,DCTVALDPPR
/Copy QSRC,DCTVALBPPR


// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  LibNme  Like(APLDCT.LibNme);
  libDes  Like(APLDCT.libDes);
  libTypD Like(libTypD);
  devUYsr Like(APLDCT.devUsr);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrLibNme Like(APLDCT.LibNme);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('APLLIBF2') Inz End-Ds;

Dcl-S libTyp like(APLDCT.libTyp);
Dcl-S pmEnmVal Like(APLDCT.EnmVal);
Dcl-S pmEnmDes Like(APLDCT.EnmDes);
Dcl-S pmKeyPressed Like(keyPressed);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('APLLIBD2');
    pmr1LibNme Like(APLDCT.LibNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrLibNme=pmr1LibNme;
  LibNme = pmrLibNme;
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
  pmr1LibNme = LibNme; // set the return key in case a new entry was added or copied
  Close APLLIBF2;

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
    From APLLIB
    Where LibNme = :LibNme;
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
  If Option = '7'  and LibNme <> pmrLibNme;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Library Name
  If LibNme = *blanks;
    $ErrorMessage('DCT1001':'':Error:LibNme@:'LibNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // If the description is blanmk try to get ti from the actual library
  If libDes = *Blanks and not ProtectDta;
    Exec SQL Select schema_text into :libDes from sysSchemas where schema_name = :libNme;
  EndIf;

  // Valid Dictionary Description
  If libDes = *Blanks and not ProtectDta;
    $ErrorMessage('DCT1003':'':Error:libDes@:'libDes':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the library type value is correct, Auto prompt first if not valid, handles ?
  If not ProtectDta;
    pmEnmVal='';
    pmEnmDes=libTypD;
    Callp(e) DCTVALBP('APLDCT':'LIBTYP':pmEnmVal:pmEnmDes:pmKeyPressed);
    libTyp = pmEnmVal;
    If libTypD <> pmEnmDes;
      libTypD = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(%upper(libTypD):'APLDCT':'libTyp');
      $ErrorMessage('':'Error - Invalid Library Type.':Error:libTypD@:'libTypD':outRow:outCol:psDsPgmNam);
    EndIf;
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
    Insert Into APLLIB
    (AcvRow, LibNme, libDes, libTyp, devUsr,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :LibNme, :libDes, :libTyp, :devUsr,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Copy
  ElseIf Option = '3';
    Exec SQL
    Insert Into APLLIB
    (AcvRow, LibNme, libDes, libTyp, devUsr,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :LibNme, :libDes, :libTyp, :devUsr,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Inactivate
  ElseIf Option = '4';
    Exec SQL
    Update APLLIB
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where LibNme = :LibNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
    Update APLLIB
    Set   LibNme = :LibNme
    Where LibNme = :pmrLibNme;
    Exec SQL
      Update APLLIB
      Set (LibNme, MntDtm, MntUsr, MntJob, MntPgm)
    = (:LibNme, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where LibNme = :pmrLibNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update APLLIB
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where LibNme = :LibNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update APLLIB
      Set ( libDes, libTyp, devUsr, MntDtm, MntUsr, MntJob, MntPgm)
        = (:libDes,:libTyp,:devUsr, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where LibNme = :LibNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt State
  If CsrFld = 'LIBTYPD';
    Callp DCTVALDP('APLDCT':'LIBTYP':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      LibTypD = pmEnmDes;
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
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);

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
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);
    mde = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'LibNme':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(APLLIBF2);
    Open APLLIBF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  LibNmeCpy = pmrLibNme;

  // Display and process data
  Clear Dta;
  LibNme = pmrLibNme;
  Exec SQL
    Select LibNme, libDes, COALESCE(LIB.ENMDES,'ERROR'), devUsr Into :Dta
    From APLLIB
    LEFT JOIN DCTVAL LIB ON LIB.DCTNME='APLDCT' AND LIB.FLDNME='LIBTYP' AND LIB.ENMVAL=APLLIB.LIBTYP
    Where LibNme = :LibNme;
  Eval-Corr DspVal = Dta;

  // If in entry mode set the key value to what ever is passed in and move cursor to the next field
  If Option='1' and pmrLibNme<>'';
    LibNme=pmrLibNme;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);
  EndIf;

End-Proc;
