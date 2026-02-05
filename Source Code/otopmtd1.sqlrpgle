**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Output Options - Prompt Driver

Dcl-F OTOPMTF1 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR // prototypes for output options procedures
/Copy QSRC,OTOPMTD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,OTOPMTD2PR // Email options screen
/Copy QSRC,OTOPMTD3PR // Fax options screen
/Copy QSRC,OTOPMTD4PR // Archive options screen
/Copy QSRC,USRMSTD7PR // User master, output options screen


Dcl-S Option like(APLDCT.Option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOPMTD1');
    prmOto Like(otoDs);
    prmKeyPressed like(keyPressed) options(*nopass);
  End-Pi;

  otoDs = prmOto;

  Option='2';

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
    ElseIf keyPressed = 'F4'; // F4=Prompt
      Prompt();
    ElseIf keyPressed = 'F5';  // F5=Refresh
      otoDs = prmOto;
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf keyPressed = 'F16'; // F16=User Defaults
      UserDefaults();
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

  Close OTOPMTF1;

  // Gumbo only allows 128 character file names with the extension so cut it down here */
  ataNme = %trim(%subst(ataNme:1:123));

  prmOto = otoDs;

  // pass keypressed back if passed in
  If %parms >= 2;
    prmKeyPressed = keyPressed;
  EndIf;

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
  EndIf;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S dec3 packed(3);

  error=*off;

  // make sure selection options are valid
  If not (prtOut in %list('Y':'N'));
    $ErrorMessage('':'Error invalid option.':error:prtOut@:'prtOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (emlOut in %list('Y':'N'));
    $ErrorMessage('':'Error invalid option.':error:emlOut@:'emlOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (arcOut in %list('Y':'N'));
    $ErrorMessage('':'Error invalid option.':error:arcOut@:'arcOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (faxOut in %list('Y':'N'));
    $ErrorMessage('':'Error invalid option.':error:faxOut@:'faxOut':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate the printer device
  If prtDev <> '*USRPRF' and not #$ISOBJ(prtDev:'*DEVD');
    $ErrorMessage('':'Error printer.':error:prtDev@:'prtDev':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate the output queue
  If prtOtq <> '*DEV' and not #$ISOBJ(prtOtq:'*OUTQ');
    $ErrorMessage('':'Error ouput queue.':error:prtOtq@:'prtOtq':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate the number of copies, convert it to a number then back to char
  Monitor;
    dec3 = %dec(%trim(nbrCpy):3:0);
    nbrCpy = %editc(dec3:'X');
    If dec3 = 0 or dec3 > 255;
      $ErrorMessage('':'Error copies must be between 1 and 255.':error:nbrCpy@:'nbrCpy':outRow:outCol:psDsPgmNam);
    EndIf;
  On-Error;
    $ErrorMessage('':'Error copies must be a number.':error:nbrCpy@:'nbrCpy':outRow:outCol:psDsPgmNam);
  EndMon;

  // Make sure the hold option is *yes or *no
  If not (hldOut in %list('*NO':'*YES'));
    $ErrorMessage('':'Error invalid hold option, must be *YES or *NO.':error:hldOut@:'hldOut':outRow:outCol:psDsPgmNam);
  EndIf;

  // Make sure the save option is *yes or *no
  If not (savOut in %list('*NO':'*YES'));
    $ErrorMessage('':'Error invalid save option, must be *YES or *NO.':error:savOut@:'savOut':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate print quality
  If not (prtQul in %list('*SAME':'*DEVD':'*STD':'*DRAFT':'*NLQ':'*FASTDRAFT'));
    $ErrorMessage('':'Error invalid print quality.':error:prtQul@:'prtQul':outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed like(keyPressed);

  error = *off;

  // Get email options if selected
  If emlOut = 'Y';
    OTOPMTD2(otoDs:pmKeyPressed);
    If pmKeyPressed = 'F12';
      error = *on;
    ElseIf pmKeyPressed = 'F3';
      error = *on;
    EndIf;
  EndIf;

  // Get fax options if selected
  If faxOut = 'Y';
    OTOPMTD3(otoDs:pmKeyPressed);
    If pmKeyPressed = 'F12';
      error = *on;
    ElseIf pmKeyPressed = 'F3';
      error = *on;
    EndIf;
  EndIf;

  // Get archive options if selected
  If arcOut = 'Y';
    OTOPMTD4(otoDs:pmKeyPressed);
    If pmKeyPressed = 'F12';
      error = *on;
    ElseIf pmKeyPressed = 'F3';
      error = *on;
    EndIf;
  EndIf;

  Return error;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;

  // Prompt Allow Email
  If CsrFld = 'ALWEMLD';

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Handle user defaults key (F16)
Dcl-Proc UserDefaults;
  Dcl-S accNbr zoned(5);
  Dcl-S pmOption like(APLDCT.Option);
  Dcl-S pmKeyPressed like(keyPressed);

  USRMSTD7(user:pmOption:pmKeyPressed);

  // load populated defaults in case any have changed
  Exec SQL
    Select
      case when arcFlr <> '' then arcFlr else :arcFlr end,
      case when prtDev <> '' then prtDev else :prtDev end,
      case when prtOtq <> '' then prtOtq else :prtOtq end,
      case when aarFlr <> '' then aarFlr else :aarFlr end,
      case when otoEml <> '' then otoEml else :emlAdd end,
      case when otoNme <> '' then otoNme else :emlNme end,
      case when hldOut <> '' then hldOut else :hldOut end,
      case when savOut <> '' then savOut else :savOut end,
      case when ataTyp <> '' then ataTyp else :ataTyp end,
      case when ataFmt <> '' then ataFmt else :ataFmt end,
      case when prtOut <> '' then prtOut else :prtOut end,
      case when emlOut <> '' then emlOut else :emlOut end,
      case when arcOut <> '' then arcOut else :arcOut end,
      case when faxOut <> '' then faxOut else :faxOut end
    into  :arcFlr, :prtDev, :prtOtq, :aarFlr, :emlAdd, :emlNme, :hldOut,
          :savOut, :ataTyp, :ataFmt, :prtOut, :emlOut, :arcOut, :faxOut
    From USRMST
    Where usrPrf = :user;

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
  protectCpy = *on;
  protectKey = *on;
  protectDta = *off;

  $GetFieldLocation(psdsPgmNam:'prtout':outRow:outCol);
  mde = 'Revise';

  If not %open(OTOPMTF1);
    Open OTOPMTF1;
  EndIf;

  SetAttributes();

End-Proc;
