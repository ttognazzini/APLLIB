**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Help Master Filter

Dcl-F HLPMSTFZ workstn infds(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,HLPMSTDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,HLPMSTDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR

Dcl-Ds filterDs extname('HLPMSTFZ') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('HLPMSTDZ');
    pmrflt like(filterDs);
    pmrkeyPressed like(keyPressed);
  End-Pi;

  filterDs=pmrflt;

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
      filterDs=pmrflt;
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen();
      Iter;
    Else;
      If dctNme<>'' or fldNme<>'' or dspFle<>'' or val<>'' or hlpTypD<>'';
        fltEff='Y';
      Else;
        fltEff='N';
      EndIf;
      pmrflt=filterDs;
      Return;
    EndIf;
  EndDo;

  Close HLPMSTFZ;

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
  If CsrFld = 'HLPTYPD';
    Callp DCTVALDP('APLDCT':'HLPTYP':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      hlpTypD = pmEnmDes;
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
  dctNme=%scanrpl('%':'':dctNme);
  fldNme=%scanrpl('%':'':fldNme);
  dspFle=%scanrpl('%':'':dspFle);
  val   =%scanrpl('%':'':val);

  // * Sort By
  If srtCde<1 or srtCde>6;
    $ErrorMessage('':'Invalid Sort Code':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the type value is correct, Auto prompt first if not valid, handles ?
  If hlpTypD<>'';
    pmEnmVal='';
    pmEnmDes=hlpTypD;
    Callp(e) DCTVALBP('APLDCT':'HLPTYP':pmEnmVal:pmEnmDes:pmKeyPressed);
    If hlpTypD <> pmEnmDes;
      hlpTypD = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(hlpTypD):'APLDCT':'HLPTYP');
      $ErrorMessage('DCT1002':'':error:HlpTypD@:'hlpTyp':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;

  Open HLPMSTFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get valid function key data structure
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

End-Proc;
