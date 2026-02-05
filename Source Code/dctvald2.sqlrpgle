**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

Dcl-F DCTVALF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTVALD2PR // Always include the prototype for the current program

Dcl-Ds Dta Qualified;
  EnmVal Like(APLDCT.EnmVal);
  EnmDes Like(APLDCT.EnmDes);
End-Ds;

// Data Structure to hold Field Type Values
Dcl-Ds fieldValues Qualified;
  isNumeric Ind;
  MaxValue like(APLDCT.LrgVal);
End-Ds;

Dcl-S FldTyp like(APLDCT.FldTyp);
Dcl-S FldLen like(APLDCT.FldLen);

Dcl-S pmrEnmVal Like(APLDCT.EnmVal);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S DltAct Ind;
Dcl-S EofDct Ind;

Dcl-Ds DspVal ExtName('DCTVALF2') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTVALD2');
    pmrDctNme  Like(APLDCT.DctNme);
    pmrFldNme  Like(APLDCT.FldNme);
    pmr1EnmVal Like(APLDCT.EnmVal);
    pmrOption  Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  DctNme = pmrDctNme;
  FldNme = pmrFldNme;
  pmrEnmVal=pmr1EnmVal;
  EnmVal = pmrEnmVal;
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

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3'; // F3=Exit
      Leave;
    ElseIf keyPressed = 'F5';  // F5=Refresh
      RefreshScreen();
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
  Close DCTVALF2;

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


// Refresh, reset the values back to what they were when the program first started
Dcl-Proc RefreshScreen;

  SetAttributes();
  Clear DspVal;

  EnmValCpy = pmrEnmVal;
  DltAct   = *off;

  // Display and process data
  Clear Dta;
  EnmVal = pmrEnmVal;
  Exec SQL
    Select EnmVal, EnmDes Into :Dta
    From DCTVAL
    Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
  EofDct = sqlState > '02';
  Eval-Corr DspVal = Dta;

  If Option = '3';
    // DctNme = DctNmeCpyTo;
  EndIf;

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
    From DCTVAL
    Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and not EOF;
    $ErrorMessage('':'Value Already Exists':Error:EnmVal@:'EnmVal':outRow:outCol:psDsPgmNam);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and EOF;
    $ErrorMessage('':'Value Does Not Exist':Error:EnmVal@:'EnmVal':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Rename
  If Option = '7'  and EnmVal <> pmrEnmVal;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Enumerated Value
  If EnmVal = *blanks;
    $ErrorMessage('DCT1001':'':Error:EnmVal@:'EnmVal':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Enumerated Desscription
  If EnmDes = *Blanks and not ProtectDta;
    $ErrorMessage('DCT1003':'':Error:EnmDes@:'EnmDes':outRow:outCol:psDsPgmNam);
  EndIf;

  Return Error;

End-Proc;

// select item
Dcl-Proc UpdateScreen;

  Eval-Corr Dta = DspVal;

  // Perform updates if no error
  Select ;

      // Read error
    When %error;
      $ErrorMessage('DCT0200');

      // Inactivate
    When Option = '4';
      Exec SQL
    Update DCTVAL
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

      // Rename
    When Option = '7';
      Exec SQL
      Update DCTVAL
      Set (EnmVal, MntDtm, MntUsr, MntJob, MntPgm)
    = (:EnmVal, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

      // ReActivate
    When Option = '13';
      Exec SQL
    Update DCTVAL
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

      // Update
    When Option <> '1' and Option <> '3';
      Exec SQL
      Update DCTVAL
      Set ( EnmDes, MntDtm, MntUsr, MntJob, MntPgm)
        = (:EnmDes, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal;
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

      // Create
    When Option = '1';
      Exec SQL
    Insert Into DCTVAL
    (AcvRow, DctNme, FldNme, EnmVal, EnmDes,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :DctNme, :FldNme, :EnmVal, :EnmDes,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

      // Copy
    When  Option = '3';
      Exec SQL
    Insert Into DCTVAL
    (AcvRow, DctNme, FldNme, EnmVal, EnmDes,
    CrtDtm, CrtUsr, CrtJob, CrtPgm,
    MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :DctNme, :FldNme, :EnmVal, :EnmDes,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
      If sqlState > '02';
        $ErrorMessage('DCT0200');
      EndIf;

  EndSL;

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
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'EnmDes':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    Mode = 'Copy';
    ProtectCpy = *on;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);


    // * disallow key field changes on delete
  ElseIf Option = '4' and DltAct <> '1';
    Mode = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    Mode = 'Display';
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);
    Mode = 'Rename';
    ProtectCpy = *on;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);
    Mode = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'EnmVal':outRow:outCol);
    Mode = 'Unknown';
  EndIf;

  // Get the dictionary name
  Exec SQL Select Des Into :DctDes From DCTMST Where DctNme=:DctNme;

  // Get the field name, type and length
  Exec SQL Select ColTxt, FldTyp, FldLen
           Into  :ColTxt,:FldTyp,:FldLen
           From DCTFld
           Where DctNme=:DctNme
             and FldNme=:FldNme;

  // Set values used to validate the value. It must fit the type and length,
  // so numeric values have a maximum value and character values have a
  // maximum length
  Exec SQL
    Select
       Case when Nmr='Y' Then '1' Else '0' End,
       case when Nmr<>'Y' then :FldLen
            when :FldLen>0 then int(10**:FldLen*0.99999999999)
            Else MaxLen End
    Into :fieldValues
    From FLDTYP
    Where FldTyp=:FldTyp;

  Open DCTVALF2;

  RefreshScreen();

End-Proc;
