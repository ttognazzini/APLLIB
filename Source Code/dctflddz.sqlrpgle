**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Dictionary Master Filter

dcl-f DCTFLDFZ workstn infds(dspds) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTMSTDZ_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTFLDDZPR // Always include the prototype for the current program
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR

Dcl-Ds filterDs extname('DCTFLDFZ') Inz End-DS;
Dcl-S DctNme like(APLDCT.DctNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDDZ');
    prmDctNme like(APLDCT.DctNme);
    prmFlt like(filterDs);
    prmkeyPressed like(keyPressed);
  End-Pi;

  DctNme=prmDctNme;
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

  Close DCTFLDFZ;

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

  ExFmt SCREEN;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // This logic moves the cursor to the start of a field if it was left somewhere in the middle
  if csrFld<>'';
    $getFieldLocation(PgmNme:csrFld:outRow:OutCol);
  EndIf;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  Clear FldAtrDta;

End-Proc;

Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt dictionary name
  If CsrFld = 'ACVDES';
    Callp DCTVALDP('APLDCT':'ACVROW':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      AcvDes = pmEnmDes;
    EndIf;

  // Prompt Enumerated Option
  ElseIf CsrFld = 'FLDENMD';
    Callp DCTVALDP('APLDCT':'FLDENM':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      FldEnmD = pmEnmDes;
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

  // remove any %, they will mess up the SQL statement
  FldNme=%scanrpl('%':'':FldNme);
  ColTxt=%scanrpl('%':'':ColTxt);
  Typ=%scanrpl('%':'':Typ);
  ColHdg=%scanrpl('%':'':ColHdg);

  //* Sort By
  If srtCde<1 or srtCde>5;
    $ErrorMessage('FAB0006':'':error:SrtCde@:'SrtCde':outRow:outCol:psDsPgmNam);
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

  // make sure the enumerated value is correct, Auto prompt first if not valid, handles ?
  If FldEnmD<>'';
    pmEnmVal='';
    pmEnmDes=FldEnmD;
    Callp(e) DCTVALBP('APLDCT':'FldEnm':pmEnmVal:pmEnmDes:pmKeyPressed);
    If FldEnmD <> pmEnmDes;
      FldEnmD = pmEnmDes;
      error=*on;
    EndIf;
    If not $ValidEnmDes(#$upify(FldEnmD):'APLDCT':'FldEnm');
      $ErrorMessage('DCT1002':'':error:FldEnmD@:'FldEnmD':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the screen size is correct
  If not #$in(ScrSze:'1':'2');
    $ErrorMessage('':'Invalid Screen Size, must be 1 or 2.'
                    :error:ScrSze@:'ScrSze':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the view is valid
  If not #$in(Dvw:'1':'2':'3');
    $ErrorMessage('':'Invalid View, must be 1, 2 or 3.'
                    :error:Dvw@:'Dvw':outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started
// **ChangedFromMassReplace, the display file name should be changed from the mass replace,
// also if needed a position to field can be added, see the commented out code, this is only
// needed if you want the cursor to start in a field other than the top one.
Dcl-Proc ProgramInitialization;

  Open DCTFLDFZ;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // If the view or screen size is not valid set them to 1
  If not #$in(ScrSze:'1':'2');
    ScrSze='1';
  EndIf;
  If not #$in(Dvw:'1':'2');
    Dvw='1';
  EndIf;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$nextFunctionKeys(fncDs);

End-Proc;
