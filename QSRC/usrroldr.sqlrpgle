**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Role Master List Prompt

Dcl-F USRROLFR WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRROLDR_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRROLDRPR // Always include the prototype for the current program
/Copy QSRC,USRROLBRPR // Contact List
/Copy QSRC,DCTVALBPPR // Enumerated value auto prompter
/Copy QSRC,DCTVALDPPR // Enumerated value prompt
/Copy QSRC,USRMSTBPPR // User auto prompter
/Copy QSRC,USRMSTD1PR // User prompt
/Copy QSRC,ROLMSTBPPR // Role auto prompter
/Copy QSRC,ROLMSTD1PR // Role prompt


Dcl-S option like(APLDCT.option);

// define values where only the description is on the screen
Dcl-S acvRow like(APLDCT.acvRow);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRROLDR');
    pmrUsrRolBrDs LikeDs(usrRolBrDs);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  srtCde = pmrUsrRolBrDs.srtCde;
  rptTtl = pmrUsrRolBrDs.rptTtl;
  acvRow = pmrUsrRolBrDs.acvRow;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:option);
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
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors leave
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  pmrUsrRolBrDs.srtCde = srtCde;
  pmrUsrRolBrDs.rptTtl = rptTtl;
  pmrUsrRolBrDs.acvRow = acvRow;

  Close USRROLFR;

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

  Clear FldAtrDta;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmEnmVal     like(APLDCT.EnmVal);
  Dcl-S pmEnmDes     like(APLDCT.EnmDes);
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmSchVal Like(APLDCT.schVal);
  Dcl-S pmRolNme Like(APLDCT.rolNme);
  Dcl-S error Ind;

  error=*off;

  // Check Required Data

  // Validate report title
  If rptTtl = '';
    $ErrorMessage('':'Error, missing report title.':error:rptTtl@:'rptTtl':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate sort option
  If srtCde < 1 or srtCde > 2;
    $ErrorMessage('':'Error, invalid or missing sort option.':error:srtCDe@:'srtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure user name is correct, Auto prompt first if not valid, handles ?
  If usrNme <> '';
    pmSchVal=usrNme;
    USRMSTBP(pmAcNo:pmSchVal:pmKeyPressed);
    If pmAcNo <> 0;
      Clear usrNme;
      Exec SQL Select acFNam concat ' ' concat acLNam into :usrNme from ACCESSPF where acNo = :pmAcNo;
    EndIf;
    Clear found;
    Exec SQL Select '1' into :found from ACCESSPF where acFNam concat ' ' concat acLNam = :usrNme;
    If not found;
      $ErrorMessage('':'Error, invalid user name.':error:AcvDes@:'AcvDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the role name is correct, Auto prompt first if not valid, handles ?
  If rolNme <> '';
    pmRolNme=rolNme;
    ROLMSTBP(pmRolNme:pmKeyPressed);
    If rolNme <> pmRolNme;
      error=*on;
    EndIf;
    Clear found;
    Exec SQL Select '1' into :found from ROLMST where rolNme = :rolNme;
    If not found;
      $ErrorMessage('':'Error, invalid role.':error:rolNme@:'rolNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate the ative row option
  If acvDes <> '';
    pmEnmVal='';
    pmEnmDes=acvDes;
    DCTVALBP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If acvDes <> pmEnmDes;
      error=*on;
    EndIf;
    acvDes = pmEnmDes;
    acvRow = pmEnmVal;
    If not $ValidEnmDes(#$UPIFY(acvDes):'APLDCT':'acvRow');
      $ErrorMessage('':'Error, invalid option.':error:acvDes@:'acvDes':outRow:outCol:psDsPgmNam);
    EndIf;
  Else;
    Clear acvDes;
  EndIf;

  Return error;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmOption Like(APLDCT.option);
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmRolNme Like(APLDCT.rolNme);


  // Prompt active des
  If CsrFld = 'ACVDES';
    DCTVALDP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      acvDes = pmEnmDes;
    EndIf;

    // Prompt user
  ElseIf CsrFld = 'USRPRF';
    pmOption = '1';
    USRMSTD1(pmAcNo:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      Clear usrNme;
      Exec SQL Select acFNam concat ' ' concat acLNam into :usrNme from ACCESSPF where acNo = :pmAcNo;
    EndIf;

    // Prompt role
  ElseIf CsrFld = 'ROLNME';
    pmOption = '1';
    ROLMSTD1(pmRolNme:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      rolNme = pmRolNme;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:option:*omit:132);
  fncKeys=$NextFunctionKeys(fncDs);

  // * allow key field changes on create
  $GetFieldLocation(psdsPgmNam:'vprNme ':outRow:outCol);

  mde = 'Prompt';

  If not %open(USRROLFR);
    Open USRROLFR;
  EndIf;

  // get active description
  Clear acvDes;
  Exec SQL Select enmDes into :acvDes from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','ACVROW',:acvRow);

  SetAttributes();

End-Proc;
