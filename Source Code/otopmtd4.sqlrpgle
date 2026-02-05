**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Output Options - Prompt Driver

Dcl-F OTOPMTF4 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR // prototypes for output options procedures
/Copy QSRC,OTOPMTD4_@ // auto generatde data structures for field attribute fields
/Copy QSRC,CHGUSRB1PR // Change users


Dcl-S Option like(APLDCT.Option);
Dcl-S protectCpy Ind;
Dcl-S protectKey Ind;
Dcl-S protectDta Ind;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOPMTD4');
    prmOto Like(otoDs);
    prmKeyPressed Like(keyPressed);
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
      otoDs = prmOto;
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

  Close OTOPMTF4;

  prmOto = otoDs;

  // pass key pressed back if passed in
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
  Dcl-Pr opendir Pointer EXTPROC('opendir');
    dirname        Pointer    VALUE OPTIONS(*STRING);
  End-Pr;
  Dcl-Pr closedir Int(10) EXTPROC('closedir');
    dirhandle      Pointer    VALUE;
  End-Pr;
  Dcl-S dir          Pointer;
  error=*off;

  // validate attachment type
  If vldAta = '2' and not(ataTyp in %list('*PDF':'*TEXT':'*CSV'))
  or vldAta = '3' and not(ataTyp in %list('*PDF':'*TEXT':'*CSV':'*XML'))
  or vldAta = '4'and not(ataTyp in %list('*PDF':'*TEXT':'*CSV':'*XML':'*XLSX'))
  or not(vldAta in %list('2':'3':'4')) and ataTyp <> '*PDF';
    $ErrorMessage('':'Error invalid attachment type.':error:ataTyp@:'ataTyp':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate file format
  If not(ataFmt in %list('1':'2'));
    $ErrorMessage('':'Error invalid file format.':error:ataFmt@:'ataFmt':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate file name
  If ataNme = '';
    $ErrorMessage('':'Error missing file name.':error:ataNme@:'ataNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure some characters are not in the file name, this is incomplete but better than nothing.
  If %scan(NULL:ataNme) > 0
  or %scan('/' :ataNme) > 0
  or %scan('\' :ataNme) > 0
  or %scan('*' :ataNme) > 0
  or %scan('?' :ataNme) > 0
  or %scan('"' :ataNme) > 0
  or %scan('>' :ataNme) > 0
  or %scan('<' :ataNme) > 0
  or %scan('|' :ataNme) > 0;
    $ErrorMessage('':'Error file name cannot contain characters /,\,:,*,?,",<,>, or |.'
                    :error:ataNme@:'ataNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate folder name
  CHGUSRB1('ZZWINCHTAG');
  dir = opendir(%trim(arcFlr));
  If dir = *NULL;
    $ErrorMessage('':'Error folder not found.':error:arcFlr@:'arcFlr':outRow:outCol:psDsPgmNam);
  Else;
    closedir(dir);
  EndIf;
  CHGUSRB1();

  Return error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  error = *off;


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

  If vldAta = '2';
    vldAty = '((*PDF, *TEXT, *CSV)';
  ElseIf vldAta = '3';
    vldAty = '(*PDF, *TEXT, *CSV, *XML)';
  ElseIf vldAta = '4';
    vldAty = '(*PDF, *TEXT, *CSV, *XML, *XLSX)';
  Else;
    vldAty = '(*PDF)';
  EndIf;

  If not %open(OTOPMTF4);
    Open OTOPMTF4;
  EndIf;

  SetAttributes();

End-Proc;
