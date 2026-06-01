**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Output Options Defaults

Dcl-F USRMSTF7 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD7_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD7PR // Always include the prototype for the current program
/Copy QSRC,USRMSTB4PR // Sync USRMST with USRPRF
/Copy QSRC,USRMSTC1PR // Get User Profile Values
/Copy QSRC,CHGUSRB1PR // Change users


Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('USRMSTF7') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD7');
    pmrUsrPrf like(APLDCT.usrPrf);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  usrPrf = pmrUsrPrf;
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
  Close USRMSTF7;

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

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-Pr opendir Pointer EXTPROC('opendir');
    dirname        Pointer    VALUE OPTIONS(*STRING);
  End-Pr;
  Dcl-Pr closedir Int(10) EXTPROC('closedir');
    dirhandle      Pointer    VALUE;
  End-Pr;
  Dcl-S dir          Pointer;

  error=*off;

  // make sure selection options are valid
  If not (prtOut in %list('Y':'N':' '));
    $ErrorMessage('':'Error invalid option.':error:prtOut@:'prtOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (emlOut in %list('Y':'N':' '));
    $ErrorMessage('':'Error invalid option.':error:emlOut@:'emlOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (arcOut in %list('Y':'N':' '));
    $ErrorMessage('':'Error invalid option.':error:arcOut@:'arcOut':outRow:outCol:psDsPgmNam);
  EndIf;
  If not (faxOut in %list('Y':'N':' '));
    $ErrorMessage('':'Error invalid option.':error:faxOut@:'faxOut':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate the printer device
  If prtDev <> '*USRPRF' and prtDev <> ' ' and not #$ISOBJ(prtDev:'*DEVD');
    $ErrorMessage('':'Error printer.':error:prtDev@:'prtDev':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate the output queue
  If prtOtq <> '*DEV' and prtOtq <> ' ' and not #$ISOBJ(prtOtq:'*OUTQ');
    $ErrorMessage('':'Error ouput queue.':error:prtOtq@:'prtOtq':outRow:outCol:psDsPgmNam);
  EndIf;

  // Make sure the hold option is *yes or *no
  If not (hldOut in %list('*NO':'*YES':' '));
    $ErrorMessage('':'Error invalid hold option, must be *YES or *NO.':error:hldOut@:'hldOut':outRow:outCol:psDsPgmNam);
  EndIf;

  // Make sure the save option is *yes or *no
  If not (savOut in %list('*NO':'*YES':' '));
    $ErrorMessage('':'Error invalid save option, must be *YES or *NO.':error:savOut@:'savOut':outRow:outCol:psDsPgmNam);
  EndIf;

  If otoEml <> '' and #$VEML(otoEml);
    $ErrorMessage('':'Error invalid to email address.':error:otoEml@:'otoEml':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate attachment type
  If not(ataTyp in %list('*PDF':'*TEXT':'*CSV':'*XML':'*XLSX':''));
    $ErrorMessage('':'Error invalid attachment type.':error:ataTyp@:'ataTyp':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate file format
  If not(ataFmt in %list('1':'2':''));
    $ErrorMessage('':'Error invalid file format.':error:ataFmt@:'ataFmt':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate folder name
  If arcFlr <> '';
    CHGUSRB1('DDRIVEINT');
    dir = opendir(%trim(arcFlr));
    If dir = *NULL;
      $ErrorMessage('':'Error folder not found.':error:arcFlr@:'arcFlr':outRow:outCol:psDsPgmNam);
    Else;
      closedir(dir);
    EndIf;
    CHGUSRB1();
  EndIf;

  // Validate folder name
  If aarFlr <> '';
    CHGUSRB1('DDRIVEINT');
    dir = opendir(%trim(aarFlr));
    If dir = *NULL;
      $ErrorMessage('':'Error folder not found.':error:aarFlr@:'aarFlr':outRow:outCol:psDsPgmNam);
    Else;
      closedir(dir);
    EndIf;
    CHGUSRB1();
  EndIf;


  Return error;

End-Proc;


// Perform updates if no error
Dcl-Proc UpdateScreen;

  If not ProtectDta;
    Exec SQL
      Update USRMST
      Set ( prtOut, emlOut, arcOut, faxOut, prtDev, prtotq, hldOut,
            savOut, otoNme, otoEml, arcFlr, aarFlr, ataTyp, ataFmt)
        = (:prtOut,:emlOut,:arcOut,:faxOut,:prtDev,:prtotq,:hldOut,
          :savOut,:otoNme,:otoEml,:arcFlr,:aarFlr,:ataTyp,:ataFmt)
      Where usrPrf = :usrPrf;
    If sqlState > '02';
      #$DSPWIN('Defaults not updated, contact IT support for help.');
    EndIf;
  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  // Prompt company
  If CsrFld = 'CMPNME' and not ProtectDta;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // sync USRMST with USRPRF
  USRMSTB4(usrPrf);

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

  If Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);
  Else;
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
  EndIf;

  If not %open(USRMSTF7);
    Open USRMSTF7;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // Get User defualts
  Exec SQL
    Select usrTxt, prtOut, emlOut, arcOut, faxOut, prtDev, prtotq, hldOut,
           savOut, otoNme, otoEml, arcFlr, aarFlr, ataTyp, ataFmt
    Into  :usrTxt,:prtOut,:emlOut,:arcOut,:faxOut,:prtDev,:prtotq,:hldOut,
          :savOut,:otoNme,:otoEml,:arcFlr,:aarFlr,:ataTyp,:ataFmt
    From USRMST
    Where usrPrf = :usrPrf;

End-Proc;
