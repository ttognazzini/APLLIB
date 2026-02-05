**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// File Master Copy Options

Dcl-F FLEMSTF3 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTD3_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEMSTD3PR // Always include the prototype for the current program


Dcl-S Option like(APLDCT.Option);
Dcl-Ds DspVal ExtName('FLEMSTF3') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTD3');
    pmrFleLib Like(APLDCT.FleLib);
    pmrFleNme Like(APLDCT.FleNme);
    pmrCpyLib Like(APLDCT.FleLib);
    pmrCpyFle Like(APLDCT.FleNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  cpyLib = pmrCpyLib;
  cpyFle = pmrCpyFle;
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

  Close FLEMSTF3;

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


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  Error=*off;

  If (cpyAll <> 'Y' and cpyAll <> ' ');
    $ErrorMessage('':'Error enter a Y or leave blank.':Error);
  EndIf;

  Return Error;

End-Proc;


// Update the screen
Dcl-Proc UpdateScreen;

  // add fields if selected
  If cpyAll = 'Y';

    // copy fields
    Exec SQL insert into FLEFLD
        (fleLib, fleNme, fleMstIdn,
         fldNme, fldLvl, fldSeq, fldSts, priKey, nteExs, strIdn, idnIcm,
         crtDtm, crtUsr, crtJob, crtPgm,
         mntDtm, mntUsr, mntJob, mntPgm)
       Select
         FLEMST.fleLib, FLEMST.fleNme,FLEMST.fleMstIdn,
         fldNme, fldLvl, fldSeq, fldSts, priKey, FLEFLD.nteExs, strIdn, idnIcm,
         current timestamp, :user, :wsid, :pgmNme,
         current timestamp, :user, :wsid, :pgmNme
       from FLEFLD
       join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (:fleLib,:fleNme)
       where (FLEFLD.fleLib,FLEFLD.fleNme) = (:cpyLib,:cpyFle)
         and fldLvl in ('3','4');

    // copy all field notes
    Exec SQL insert into FLDNTE
        (fleLib, fleNme, fldNme, fleFldIdn,
         nteSeq, nte,
         crtDtm, crtUsr, crtJob, crtPgm,
         mntDtm, mntUsr, mntJob, mntPgm)
       Select
         FLEFLD.fleLib, FLEFLD.fleNme, FLEFLD.fldNme, FLEFLD.fleFldIdn,
         nteSeq, nte,
         current timestamp, :user, :wsid, :pgmNme,
         current timestamp, :user, :wsid, :pgmNme
       from FLDNTE
       join FLEFLD on (FLEFLD.fleLib,FLEFLD.fleNme,FLEFLD.fldNme) = (:fleLib,:fleNme,FLDNTE.fldNme)
       where (FLDNTE.fleNme,FLDNTE.fleLib) = (:cpyLib,:cpyFle)
         and fldLvl in ('3','4');

  EndIf;

End-Proc;



// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  // Prompt status description
  If CsrFld = 'PRDFLED';

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$NextFunctionKeys(fncDs);

  If not %open(FLEMSTF3);
    Open FLEMSTF3;
  EndIf;

  Clear DspVal;

End-Proc;
