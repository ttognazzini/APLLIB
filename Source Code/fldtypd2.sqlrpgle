**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Field Type Maintenance

Dcl-F FLDTYPF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLDTYPD2_@ // auto generated data structures for field attribute fields

Dcl-S pmrfldTyp Like(APLDCT.fldTyp);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S DltAct Ind;

Dcl-Ds DspVal ExtName('FLDTYPF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLDTYPD2');
    pmr1fldTyp Like(APLDCT.fldTyp);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrfldTyp=pmr1fldTyp;
  fldTyp = pmrfldTyp;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs) and KeyPressed<>'F10';
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
  Close FLDTYPF2;


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
    From FLDTYP
    Where fldTyp = :fldTyp;
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
  If Option = '7'  and fldTyp <> pmrfldTyp;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Validate that a description is entered
  If des = '';
    $ErrorMessage('':'Error, a description is required.'
                    :Error:des@:'des':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;


// select item
Dcl-Proc UpdateScreen;
  // Inactivate
  If Option = '4';
    Exec SQL
    Update FLDTYP
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where fldTyp = :fldTyp;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
      Update FLDTYP
      Set ( fldTyp, MntDtm, MntUsr, MntJob, MntPgm)
        = (:fldTyp, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where fldTyp = :fldTyp;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
      Update FLDTYP
      Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
        = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where fldTyp = :fldTyp;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update FLDTYP
      Set ( des, nmr, alwLen, reqLen, alwAlc, reqAlc, maxLen, lrgVal, smlVal, frcLen, frcLen1,
            frcLen2, frcLen3, frcLen4, frcLen5, dftVal, sysTyp, sysLen)
        = (:des,:nmr,:alwLen,:reqLen,:alwAlc,:reqAlc,:maxLen,:lrgVal,:smlVal,:frcLen,:frcLen1,
           :frcLen2,:frcLen3,:frcLen4,:frcLen5,:dftVal,:sysTyp,:sysLen)
      Where fldTyp = :fldTyp;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Create/Save
  ElseIf Option = '1' or Option = '3';
    Exec SQL
    Insert Into FLDTYP
          (AcvRow,fldTyp,
           des, nmr, alwLen, reqLen, alwAlc, reqAlc, maxLen, lrgVal, smlVal, frcLen, frcLen1,
           frcLen2, frcLen3, frcLen4, frcLen5, dftVal, sysTyp, sysLen,
           CrtDtm, CrtUsr, CrtJob, CrtPgm,
           MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :fldTyp,
           :des,:nmr,:alwLen,:reqLen,:alwAlc,:reqAlc,:maxLen,:lrgVal,:smlVal,:frcLen,:frcLen1,
           :frcLen2,:frcLen3,:frcLen4,:frcLen5,:dftVal,:sysTyp,:sysLen,
           Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
           Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;

  // Prompt status description
  If CsrFld = 'PRIKEYD';

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine
Dcl-Proc
  InitializeProgram;
  Dcl-Ds Dta Qualified;
    des     Like(APLDCT.des);
    nmr     Like(APLDCT.nmr);
    alwDec  Like(APLDCT.alwDec);
    alwLen  Like(APLDCT.alwLen);
    reqLen  Like(APLDCT.reqLen);
    alwAlc  Like(APLDCT.alwAlc);
    reqAlc  Like(APLDCT.reqAlc);
    maxLen  Like(APLDCT.maxLen);
    lrgVal  Like(APLDCT.lrgVal);
    smlVal  Like(APLDCT.smlVal);
    frcLen  Like(APLDCT.frcLen);
    frcLen1 Like(APLDCT.frcLen1);
    frcLen2 Like(APLDCT.frcLen2);
    frcLen3 Like(APLDCT.frcLen3);
    frcLen4 Like(APLDCT.frcLen4);
    frcLen5 Like(APLDCT.frcLen5);
    dftVal  Like(APLDCT.dftVal);
    sysTyp  Like(APLDCT.sysTyp);
    sysLen  Like(APLDCT.sysLen);
  End-Ds;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
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
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'FLDSEQ':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    Mode = 'Copy';
    ProtectCpy = *on;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4' and DltAct <> '1';
    Mode = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    Mode = 'Display';
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);
    Mode = 'Rename';
    ProtectCpy = *on;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);
    Mode = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'fldTyp':outRow:outCol);
    Mode = 'Unknown';
  EndIf;

  If not %open(FLDTYPF2);
    Open FLDTYPF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  fldTypCpy = pmrfldTyp;
  DltAct   = *off;

  // Display and process data
  Clear Dta;
  fldTyp = pmrfldTyp;

  // get data
  Exec SQL
    Select
      des,
      nmr,
      alwDec,
      alwLen,
      reqLen,
      alwAlc,
      reqAlc,
      maxLen,
      lrgVal,
      smlVal,
      frcLen,
      frcLen1,
      frcLen2,
      frcLen3,
      frcLen4,
      frcLen5,
      dftVal,
      sysTyp,
      sysLen
    into :Dta
    from fldtyp
    Where fldTyp = :fldTyp;
  Eval-Corr DspVal = Dta;

  // If in entry mode set the key value to whatever is passed in and move cursor to the next field
  If Option='1' and pmrfldTyp<>'';
    fldTyp=pmrfldTyp;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);
  EndIf;

End-Proc;
