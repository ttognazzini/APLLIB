**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Master Filter

Dcl-F DCTVALFZ workstn infds(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTVALDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALDPPR
/Copy QSRC,DCTVALBPPR

Dcl-Ds filterDS extname('DCTVALFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTVALDZ');
    pmrFlt like(filterDS);
    pmrkeyPressed like(keyPressed);
  End-Pi;

  filterDS=pmrFlt;

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
      filterDS=pmrFlt;
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen();
      Iter;
    Else;
      pmrFlt=filterDS;
      Return;
    EndIf;
  EndDo;

  Close DCTVALFZ;

End-Proc;

// Clear Screen Indicators
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

  // Clear message SFL
  $ClearMessages();

  // Reset all field attributes
  Clear FldAtrDta;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt Active Description
  If CsrFld = 'ACVDES';
    Callp DCTVALDP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      AcvDes = pmEnmDes;
    EndIf;

    // Give error if the field is not promptable
  Else;
    $ErrorMessage('APL0002');
  EndIf;


End-Proc;


// Edit Screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  error = *off;

  // remove any %, they will mess up the SQL statement
  EnmVal=%scanrpl('%':'':EnmVal);
  EnmDes=%scanrpl('%':'':EnmDes);

  // * Sort By
  If srtCde<1 or srtCde>3;
    $ErrorMessage('':'Invalid Sort Code':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the active value is correct, Auto prompt first if not valid, handles ?
  If AcvDes<>'';
    pmEnmVal='';
    pmEnmDes=AcvDes;
    Callp(e) DCTVALBP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:pmKeyPressed);
    If AcvDes <> pmEnmDes;
      AcvDes = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(AcvDes):'APLDCT':'AcvRow');
      $ErrorMessage('DCT1002':'':error:AcvDes@:'AcvDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;

  Open DCTVALFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get valid function key data structure
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

End-Proc;
