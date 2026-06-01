**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Role Approval Filter

Dcl-F ROLAPRFZ workstn infds(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,ROLAPRDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,ROLAPRDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALBPPR // Enumerated value auto prompter
/Copy QSRC,DCTVALDPPR // Enumerated value prompt
/Copy QSRC,USRMSTBPPR // User auto prompter
/Copy QSRC,USRMSTD1PR // User prompt
/Copy QSRC,ROLMSTBPPR // Role auto prompter
/Copy QSRC,ROLMSTD1PR // Role prompt

Dcl-Ds filterDs extname('ROLAPRFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


// **ChangedFromMassReplace, Screen name should be changed from the mass replace
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ROLAPRDZ');
    pmrflt like(filterDs);
    pmrkeyPressed like(keyPressed);
  End-Pi;

  filterDs=pmrFlt;

  ProgramInitialization();

  DoU keyPressed='F3' or keyPressed='F12';

    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001');
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F4';
      Prompt();
    ElseIf keyPressed = 'F5';
      filterDs=pmrFlt;
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen();
      Iter;
    Else;
      pmrflt=filterDs;
      Return;
    EndIf;
  EndDo;

  Close ROLAPRFZ;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // Load SFL options if needed
  Write MSGCTL;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRow and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields to outRowScr and outColScr which means we
  // have to move the values into those fields before we display the screen.
  outRowScr=outRow;
  outColScr=outCol;

  Exfmt SCREEN;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // This logic moves the cursor to the start of a field if it was left somewhere in the middle
  If csrFld<>'';
    $GetFieldLocation(PgmNme:csrFld:outRow:outCol:*omit:CSRRCD);
  EndIf;

  // Clear message SFL
  $ClearMessages();

  // Reset all field attributes
  Clear FldAtrDta;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, add in any promptable fields
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmOption Like(APLDCT.option);
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmRolNme Like(APLDCT.rolNme);

  // Prompt Active Description
  If CsrFld = 'ACVDES';
    DCTVALDP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      AcvDes = pmEnmDes;
    EndIf;

    // Prompt user
  ElseIf CsrFld = 'USRPRF';
    pmOption = '1';
    USRMSTD1(pmAcNo:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      Clear usrNme;
      Exec SQL Select acFNam concat ' ' concat acLNam into :usrNme from ACCESSPF where acNo = :pmAcNo;
      Clear usrMstIdn;
      Exec SQL Select usrMstIdn into :usrMstIdn from USRMST where accNbr = :pmAcNo;
    EndIf;

    // Prompt role
  ElseIf CsrFld = 'ROLNME';
    pmOption = '1';
    ROLMSTD1(pmRolNme:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      rolNme = pmRolNme;
      Clear rolMstIdn;
      Exec SQL Select rolMstIdn into :rolMstIdn from ROLMST where rolNme = :rolNme;
    EndIf;

    // Give error if the field is not promptable
  Else;
    $ErrorMessage('APL0002');
  EndIf;

End-Proc;


// Validate anything entered on the screen
// **CHANGE Add any required validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmAcNo Like(APLDCT.acNo);
  Dcl-S pmSchVal Like(APLDCT.schVal);
  Dcl-S pmUsrNme Like(APLDCT.usrNme);
  Dcl-S pmRolNme Like(APLDCT.rolNme);

  error = *off;

  // Remove any %, they will mess up the SQL statement
  // **CHANGE, add/change any alpahnumeric fields below
  // des   =%scanrpl('%':'':des);

  // * Sort By
  If srtCde<1 or srtCde>3;  // **CHANGE, set the maximum sort code here
    $ErrorMessage('':'Invalid Sort Code':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure user name is correct, Auto prompt first if not valid, handles ?
  If usrNme <> '';
    Clear usrMstIdn;
    pmSchVal=usrNme;
    USRMSTBP(pmAcNo:pmSchVal:pmKeyPressed);
    If pmAcNo <> 0;
      Clear pmUsrNme;
      Exec SQL Select trim(acFNam) concat ' ' concat trim(acLNam) into :pmUsrNme from ACCESSPF where acNo = :pmAcNo;
      If pmUsrNme <> usrNme;
        error = *on;
      EndIf;
      usrNme = pmUsrNme;
      Exec SQL Select usrMstIdn into :usrMstIdn From USRMST where accNbr = :pmAcNo;
    EndIf;
    Clear found;
    Exec SQL Select '1' into :found from ACCESSPF where trim(acFNam) concat ' ' concat trim(acLNam) = :usrNme;
    If not found;
      $ErrorMessage('':'Error, invalid user name.':error:usrNme@:'usrNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the role name is correct, Auto prompt first if not valid, handles ?
  If rolNme <> '';
    Clear rolMstIdn;
    pmRolNme=rolNme;
    ROLMSTBP(pmRolNme:pmKeyPressed);
    If rolNme <> pmRolNme;
      error=*on;
    EndIf;
    rolNme = pmRolNme;
    Exec SQL Select rolMstIdn into :rolMstIdn from ROLMST where rolNme = :rolNme;
    Clear found;
    Exec SQL Select '1' into :found from ROLMST where rolNme = :rolNme;
    If not found;
      $ErrorMessage('':'Error, invalid role.':error:rolNme@:'rolNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the active value is correct, Auto prompt first if not valid, handles ?
  If acvDes <> '';
    pmEnmVal = '';
    pmEnmDes = acvDes;
    DCTVALBP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If acvDes <> pmEnmDes;
      acvDes = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(AcvDes):'APLDCT':'AcvRow');
      $ErrorMessage('DCT1002':'':error:AcvDes@:'AcvDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started
// **ChangedFromMassReplace, the display file name should be changed from the mass replace,
// also if needed a position to field can be added, see the commented out code, this is only
// needed if you want the cursor to start in a field other than the top one.
Dcl-Proc ProgramInitialization;

  Open ROLAPRFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // positition cursor to the dictionary field
  // $getFieldLocation(PgmNme:'RolNme':outRow:OutCol);

  // Get valid function key data structure
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

End-Proc;
