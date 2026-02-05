**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Audit Log Display

Dcl-F AUDLOGF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,AUDLOGD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,AUDLOGD2PR // Always include the prototype for the current program


// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  FleDes Like(APLDCT.FleDes);
  colTxt Like(APLDCT.colTxt);
  bfrVal Like(APLDCT.bfrVal);
  aftVal Like(APLDCT.AftVal);
  crtDtm like(APLDCT.crtDtm);
  crtUsr like(APLDCT.crtUsr);
  crtJob like(APLDCT.crtJob);
  crtPgm like(APLDCT.crtPgm);
End-Ds;

Dcl-S Option like(APLDCT.Option);
Dcl-S audLogIdn like(APLDCT.audLogIdn);

Dcl-Ds DspVal ExtName('AUDLOGF2':*output) Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('AUDLOGD2');
    pmrFleLib Like(APLDCT.FleLib);
    pmrFleNme Like(APLDCT.FleNme);
    pmrFldNme Like(APLDCT.FldNme);
    pmrAudLogIdn Like(APLDCT.audLogIdn) const;
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  fleLib    = pmrFleLib;
  fleNme    = pmrFleNme;
  fldNme    = pmrFldNme;
  audLogIdn = pmrAudLogIdn;
  Option    = pmrOption;

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
    ElseIf keyPressed = 'F5';  // F5=Refresh
      InitializeProgram();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    Else; // Since inquiry only, just leave
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close AUDLOGF2;

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

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  If not %open(AUDLOGF2);
    Open AUDLOGF2;
  EndIf;

  // Display and process data
  Clear Dta;
  Exec SQL
    Select
      coalesce(fleDes,''),
      coalesce(colTxt,''),
      bfrVal,aftVal,AUDLOG.crtDtm,AUDLOG.crtUsr,AUDLOG.crtJob,AUDLOG.crtPgm
    Into :Dta
    From AUDLOG
    left join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (AUDLOG.fleLib,AUDLOG.fleNme)
    left join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,AUDLOG.fldNme)
    Where audLogIdn = :audLogIdn;
  Eval-Corr DspVal = Dta;

  audLogIdnC = %char(audLogIdn);

End-Proc;
