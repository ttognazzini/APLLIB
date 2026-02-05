**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Data Segment Filter

dcl-f DCTSEGFZ workstn infds(dspds) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTSEGDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTSEGDZPR // Always include the prototype for the current program

Dcl-Ds filterDs extname('DCTSEGFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTSEGDZ');
    pmrflt like(filterDs);
    pmrkeyPressed like(keyPressed);
  End-Pi;

  filterDs = pmrFlt;

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
      pmrFlt=filterDs;
      Return;
    EndIf;
  EndDo;

  Close DCTSEGFZ;

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

  ExFmt SCREEN;

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
  Dcl-S PmDctNme like(APLDCT.des);

  $ErrorMessage('APL0002');

End-Proc;


// Edit Screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  error = *off;

  // remove any %, they will mess up the SQL statement
  des=%scanrpl('%':'':des);

  //* Sort By
  If srtCde<0 or srtCde>3;
    $ErrorMessage('':'Invalid Sort Code':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the active value is correct
  If not #$in(#$Upify(AcvDes):'ACTIVE':'INACTIVE':'');
    $ErrorMessage('':'Invalid Sort Code':error:AcvDes@:'AcvDes':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the conflict exists value is correct
  If not #$in(#$upify(CnfExsD):'YES':'NO':'');
    $ErrorMessage('':'Invalid Conflict Exists Option':error:CnfExsD@:'CnfExsD'
                    :outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;


//This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;

  Open DCTSEGFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get valid function key data structure
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$nextFunctionKeys(fncDs);

End-Proc;
