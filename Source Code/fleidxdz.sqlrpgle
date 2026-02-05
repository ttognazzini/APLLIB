**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// File Indexes Filter

Dcl-F FLEIDXFZ workstn infds(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEIDXDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEIDXDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR

Dcl-Ds filterDs extname('FLEIDXFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEIDXDZ');
    prmFlt like(filterDs);
    prmkeyPressed like(keyPressed);
  End-Pi;

  filterDs=prmFlt;

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
      filterDs=prmFlt;
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen();
      Iter;
    Else;
      prmFlt=filterDs;
      Return;
    EndIf;
  EndDo;

  Close FLEIDXFZ;

End-Proc;

// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // Load SFL options if needed
  Write MSGCTL;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRos and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields otuRowScr and outRowCol which means we
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
    $GetFieldLocation(PgmNme:csrFld:outRow:outCol);
  EndIf;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  Clear FldAtrDta;

End-Proc;

Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt type description
  If CsrFld = 'IDXUNID';
    Callp DCTVALDP('APLDCT':'IDXUNI':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      idxUniD = pmEnmDes;
    EndIf;

    // Prompt status
  ElseIf CsrFld = 'ACVDES';
    Callp DCTVALDP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      acvDes = pmEnmDes;
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

  error = *off;

  // remove any %, they will mess up the SQL statement
  idxNme=%scanrpl('%':'':idxNme);
  idxTxt=%scanrpl('%':'':idxTxt);

  // * Sort By
  If srtCde<1 or srtCde>5;
    $ErrorMessage('FAB0006':'':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the status value is correct, Auto prompt first if not valid, handles ?
  If acvDes<>'';
    pmEnmVal='';
    pmEnmDes=acvDes;
    Callp(e) DCTVALBP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If acvDes <> pmEnmDes;
      acvDes = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(acvDes):'APLDCT':'ACVROW');
      $ErrorMessage('DCT1002':'':error:acvDes@:'acvDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the enumerated value is correct, Auto prompt first if not valid, handles ?
  If idxUniD<>'';
    pmEnmVal='';
    pmEnmDes=idxUniD;
    Callp(e) DCTVALBP('APLDCT':'IDXUNI':pmEnmVal:pmEnmDes:pmKeyPressed);
    If idxUniD <> pmEnmDes;
      idxUniD = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(idxUniD):'APLDCT':'IDXUNI');
      $ErrorMessage('DCT1002':'':error:idxUniD@:'idxUniD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started
// **ChangedFromMassReplace, the display file name should be changed from the mass replace,
// also if needed a position to field can be added, see the commented out code, this is only
// needed if you want the cursor to start in a field other than the top one.
Dcl-Proc ProgramInitialization;

  Open FLEIDXFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // **CHANGE positition cursor to the perfered field
  $GetFieldLocation(PgmNme:'idxNme':outRow:outCol);

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

End-Proc;
