**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

Dcl-F DCTSEGF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTSEGD2_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTSEGD2PR // Always include the prototype for the current program

Dcl-Ds Dta Qualified;
  dtaSeg Like(APLDCT.dtaSeg);
  Des    Like(APLDCT.Des);
  colTxt Like(APLDCT.colTxt);
  colHdgSeg Like(APLDCT.colHdgSeg);
  cnfExs Like(APLDCT.cnfExs);
  Nte    Like(APLDCT.Nte);
End-Ds;

Dcl-S pmrDtaSeg Like(APLDCT.dtaSeg);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S DltAct Ind;
Dcl-S EofDct Ind;
Dcl-S AlwF16 Ind;

Dcl-Ds DspVal ExtName('DCTSEGF2') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTSEGD2');
    pmr1DtaSeg Like(APLDCT.dtaSeg);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrDtaSeg=pmr1DtaSeg;
  dtaSeg = pmrDtaSeg;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  // No clue what F16 does it is only allowed on Option 1=create and 3=copy
  // It seems to make DCTSEGB0 hard delete the record
  If pmrKeyPressed = 'F16';
    AlwF16 = *on;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12' or keyPressed = 'F16';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3'; // F3=Exit
      Leave;
    ElseIf keyPressed = 'F5';  // F5=Refresh
      InitializeProgram();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf mode = 'Display'; // If in display mode, don't validate or update, just leave
      keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  pmr1DtaSeg = dtaSeg; // set the return key in case a new entry was added or copied
  Close DCTSEGF2;


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
    FldAtrCpy = *allx'A2';    // @PrWht
    $SetAttribute(frmKeys@:'');
  Else;
    FldAtrCpy = *allx'A7';    // @PrND
  EndIf;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  Error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From DCTSEG
    Where dtaSeg = :dtaSeg;
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
  If Option = '7'  and dtaSeg <> pmrDtaSeg;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Dictionary Name
  If dtaSeg = *blanks;
    $ErrorMessage('DCT1001':'':Error:dtaSeg@:'dtaSeg':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Dictionary Desscription
  If Des = *Blanks and not ProtectDta;
    $ErrorMessage('DCT1003':'':Error:des@:'des':outRow:outCol:psDsPgmNam);
  EndIf;

  // if the column text or heading is missing, default them to the description and redisplay the screen
  If colTxt='';
    coltxt=des;
    Error=*on;
  EndIf;
  If colHdgSeg='';
    colhdgSeg=des;
    Error=*on;
  EndIf;

  Return Error;

End-Proc;

// select item
Dcl-Proc UpdateScreen;

  Eval-Corr Dta = DspVal;

  // Read error
  If %error;
    $ErrorMessage('DCT0200');

    // Inactivate
  ElseIf Option = '4';
    Exec SQL
    Update DCTSEG
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where dtaSeg = :dtaSeg;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
    Update DCTSEG
    Set   dtaSeg = :dtaSeg
    Where dtaSeg = :pmrDtaSeg;
    Exec SQL
      Update DCTSEG
      Set (dtaSeg, MntDtm, MntUsr, MntJob, MntPgm)
    = (:dtaSeg, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where dtaSeg = :pmrDtaSeg;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update DCTSEG
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where dtaSeg = :dtaSeg;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Create/Copy
  ElseIf Option = '1' or Option = '3';
    Exec SQL
    Insert Into DCTSEG
          (AcvRow, dtaSeg, Des,  colTxt, colHdgSeg, cnfExs, Nte,
           CrtDtm, CrtUsr, CrtJob, CrtPgm,
           MntDtm, MntUsr, MntJob, MntPgm)
    Values('1'   ,:dtaSeg, :Des,:colTxt,:colHdgSeg,:cnfExs,:Nte,
           Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
           Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update - any other option
  Else;
    Exec SQL
      Update DCTSEG
      Set ( Des, colTxt, colHdgSeg, cnfExs, Nte,
            MntDtm, MntUsr, MntJob, MntPgm)
        = (:Des,:colTxt,:colHdgSeg,:cnfExs,:Nte,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where dtaSeg = :dtaSeg;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

End-Proc;


// Initialization subroutine
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *off;
  ProtectKey = *on;
  ProtectDta = *on;

  // * allow key field changes on create
  If Option = '1';
    Mode = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DCTNME':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    Mode = 'Copy';
    ProtectCpy = *on;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);


    // * disallow key field changes on delete
  ElseIf Option = '4' and DltAct <> '1';
    Mode = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    Mode = 'Display';
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);
    Mode = 'Rename';
    ProtectCpy = *on;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);
    Mode = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'DTASEG':outRow:outCol);
    Mode = 'Unknown';
  EndIf;

  If not %open(DCTSEGF2);
    Open DCTSEGF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  dtaSegCpy = pmrDtaSeg;
  DltAct   = *off;

  // Display and process data
  Clear Dta;
  dtaSeg = pmrDtaSeg;
  Exec SQL
    Select dtaSeg, Des, colTxt, colHdgseg, cnfExs, Nte Into :Dta
    From DCTSEG
    Where dtaSeg = :dtaSeg;
  EofDct = sqlState > '02';
  Eval-Corr DspVal = Dta;

  If Option = '3';
    // dtaSeg = dtaSegCpyTo;
  EndIf;

  // If in entry mode set the key value to what ever is passed in and move cursor to the next field
  If Option='1' and pmrDtaSeg<>'';
    dtaSeg=pmrDtaSeg;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);
  EndIf;

End-Proc;
