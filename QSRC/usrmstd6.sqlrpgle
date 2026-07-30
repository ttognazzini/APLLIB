**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Module Defaults

Dcl-F USRMSTF6 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD6_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD6PR // Always include the prototype for the current program
/Copy QSRC,USRMSTC1PR // Get User Profile Values
/Copy QSRC,ACPCMPBPPR // A/P Company - Validate/Auto Prompter
/Copy QSRC,ACPCMPD1PR // A/P Company - List


Dcl-S acpCmpIdn Like(APLDCT.acpCmpIdn);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('USRMSTF6') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD6');
    pmrAcno Zoned(5);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  acno = pmrAcno;
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
  Close USRMSTF6;

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
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmIdn        like(APLDCT.acpCmpIdn);
  Dcl-S pmCmpNme     like(APLDCT.cmpNme);
  Dcl-S error Ind;

  error=*off;

  // Validate company
  If cmpNme <> '' and not ProtectDta;
    pmCmpNme = cmpNme;
    ACPCMPBP(pmIdn:pmCmpNme:pmKeyPressed);
    If pmCmpNme <> cmpNme; // this causes it to redisplay the screen if number changes.
      error=*on;
    EndIf;
    cmpNme = pmCmpNme;
    acpCmpIdn = pmIdn;
    found = *off;
    Exec SQL select '1' into :found from ACPCMP where acpCmpIdn = :acpCmpIdn;
    If not found;
      $ErrorMessage('':'Invalid company.':error:cmpNme@:'cmpNme':outRow:outCol:psDsPgmNam);
    EndIf;
  Else;
    acpCmpIdn = 0;
  EndIf;

  Return error;

End-Proc;


// Perform updates if no error
Dcl-Proc UpdateScreen;

  If not ProtectDta;
    Exec SQL
    Update USRMST
      Set acpCmpIdn = :acpCmpIdn
      Where accNbr = :acNo;
    If sqlState > '02';
      Exec SQL
      Insert Into USRMST
            ( accNbr, acpCmpIdn)
      Values(:acNo,  :acpCmpIdn);
    EndIf;
  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmIdn       like(APLDCT.acpCmpIdn);
  Dcl-S pmOption    like(Option);
  Dcl-S pmKeyPressed Like(keyPressed);

  // Prompt company
  If CsrFld = 'CMPNME' and not ProtectDta;
    pmOption = '1';
    ACPCMPD1(pmIdn:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      acpCmpIdn = pmIdn;
      Clear cmpNme;
      Exec SQL Select cmpNme into :cmpNme from ACPCMP where acpCmpIdn = :acpCmpIdn;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;
  // These are returned from USRMSTC1, we need the user name from it
  Dcl-S acUPrf Like(APLLIB.acUPrf);
  Dcl-S acgCde Like(APLDCT.acgCde);
  Dcl-S grpPrf Like(APLDCT.grpPrf);
  Dcl-S jdOqLb Like(APLLIB.jdOqLb);
  Dcl-S jdOutQ Like(APLLIB.jdOutQ);
  Dcl-S usrSts Like(APLDCT.usrSts);
  Dcl-S usrCls Like(APLDCT.usrCls);

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

  If not %open(USRMSTF6);
    Open USRMSTF6;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // get user profile from Accesspf
  Exec SQL Select acUPrf into :acUPrf from accesspf where acNo = :acNo;

  // get values from user profile
  USRMSTC1(acUPrf:acgCde:usrNme:jdOutQ:jdOqLb:grpPrf:usrSts:usrCls);

  // Get User defualts
  Exec SQL
    Select USRMST.acpCmpIdn, Coalesce(cmpNme,'')
    Into :acpCmpIdn, :cmpNme
    From USRMST
    Left Join ACPCMP on ACPCMP.acpCmpIdn = USRMST.acpCmpIdn
    Where accNbr = :acNo;

End-Proc;
