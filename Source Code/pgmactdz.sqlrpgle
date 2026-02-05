**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Master Filter

dcl-f PGMOPTFZ workstn infds(dspds) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMOPTDZ_@ // auto generated data structures for field attribute fields
/Copy QSRC,PGMOPTDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALDPPR
/Copy QSRC,DCTVALBPPR

Dcl-Ds filterDs extname('PGMOPTFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// **ChangedFromMassReplace, Screen name should be changed from the mass replace
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMACTDZ');
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
      pmrFlt=filterDs;
      Return;
    EndIf;
  EndDo;

  Close PGMOPTFZ;

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
// **CHANGE, add in any promptable fields
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


// Validate anything entered on the screen
// **CHANGE Add any required validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(KeyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  error = *off;

  // Remove any %, they will mess up the SQL statement
  // **CHANGE, add/change any alpahnumeric fields below
  acvDes=%scanrpl('%':'':acvDes);

  //* Sort By
  If srtCde<1 or srtCde>6;
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
    If not $ValidEnmDes(#$upify(AcvDes):'APLDCT':'AcvRow');
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

  Open PGMOPTFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // positition cursor to the dictionary field
  // $getFieldLocation(PgmNme:'pgmNme':outRow:OutCol);

  // Get valid function key data structure
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$nextFunctionKeys(fncDs);

End-Proc;
