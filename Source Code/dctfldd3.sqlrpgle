**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Field Copy Options

dcl-f DCTFLDF3 WORKSTN InfDS(DspDS) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDD3_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTFLDD3PR // Always include the prototype for the current program
/Copy QSRC,DCTSEGBPPR
/Copy QSRC,DCTSEGD1PR

Dcl-S FldNme Like(APLDCT.FldNme);
Dcl-S Option like(APLDCT.Option);

Dcl-Ds ScreenFields ExtName('DCTFLDF3':*input) End-DS;
Dcl-Ds saveScreenFields ExtName('DCTFLDF3':*input) Qualified End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDD3');
    pmrDctNme Like(APLDCT.DctNme);
    pmrFldNme Like(APLDCT.FldNme);
    pmrColTxt Like(APLDCT.ColTxt);
    pmrColHdg Like(APLDCT.ColHdg);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  DctNme = pmrDctNme;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3'; // F3=Exit
      Leave;
    ElseIf keyPressed = 'F4'; // F4=Prompt
      Prompt();
    ElseIf keyPressed = 'F5'; // F5=Refresh
      RefreshScreen();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      // if there were no cahnges, leave the program
      If saveScreenFields=ScreenFields;
        pmrFldNme=%Trim(DtaSeg1) + %trim(DtaSeg2) + %trim(DtaSeg3);
        pmrColTxt=ColTxt;
        pmrColHdg=ColHdg1+ColHdg2+ColHdg3;
        Leave;
      EndIf;
    EndIf;
  EndDo;

  Close DCTFLDF3;

  pmrKeyPressed = keyPressed;

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

  // Save the value of all input fields to see if anything changes
  saveScreenFields=ScreenFields;

  ExFmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  Clear FldAtrDta;

End-Proc;


// Refresh, reset the values back to what they were when the program first started
Dcl-Proc RefreshScreen;

  Clear FldAtrDta;
  Clear DtaSeg1;
  Clear DtaSeg2;
  Clear DtaSeg3;
  Clear ColTxt1;
  Clear ColTxt2;
  Clear ColTxt3;
  Clear FldNme;

  // Position Cursor back to the first segment
  $GetFieldLocation(psdsPgmNam:'DtaSeg1':outRow:outCol);

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;
  Dcl-S pmDtaSeg like(APLDCT.DtaSeg);
  Dcl-S pmKeyPressed like(KeyPressed);

  error=*off;

  // validate data segment 1
  If DtaSeg1<>'';
    pmDtaSeg=DtaSeg1;
    Callp(e) DCTSEGBP(pmDtaSeg:pmKeyPressed);
    If DtaSeg1 <> pmDtaSeg;
      DtaSeg1 = pmDtaSeg;
      error=*on;
    EndIf;
    found = *off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:DtaSeg1;
    If not found;
      $ErrorMessage('':'Invalid Data Segement,':error:DtaSeg1@:'DtaSeg1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate data segment 2
  If DtaSeg2<>'';
    pmDtaSeg=DtaSeg2;
    Callp(e) DCTSEGBP(pmDtaSeg:pmKeyPressed);
    If DtaSeg2 <> pmDtaSeg;
      DtaSeg2 = pmDtaSeg;
      error=*on;
    EndIf;
    found = *off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:DtaSeg2;
    If not found;
      $ErrorMessage('':'Invalid Data Segement,':error:DtaSeg2@:'DtaSeg2':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate data segment 3
  If DtaSeg3<>'';
    pmDtaSeg=DtaSeg3;
    Callp(e) DCTSEGBP(pmDtaSeg:pmKeyPressed);
    If DtaSeg3 <> pmDtaSeg;
      DtaSeg3 = pmDtaSeg;
      error=*on;
    EndIf;
    found = *off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:DtaSeg3;
    If not found;
      $ErrorMessage('':'Invalid Data Segement,':error:DtaSeg3@:'DtaSeg3':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  BuildField();

  Return error;

End-Proc;

// Update Screen
Dcl-Proc UpdateScreen;

  BuildField();

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmDtaSeg like(APLDCT.DtaSeg);

  // Prompt DtaSeg1
  If CsrFld = 'DTASEG1';
    Callp DCTSEGD1(pmDtaSeg:'1':keyPressed);
    If keyPressed = 'ENTER';
      DtaSeg1 = pmDtaSeg;
    EndIf;

  ElseIf CsrFld = 'DTASEG2';
    Callp DCTSEGD1(pmDtaSeg:'1':keyPressed);
    If keyPressed = 'ENTER';
      DtaSeg2 = pmDtaSeg;
    EndIf;

  ElseIf CsrFld = 'DTASEG3';
    Callp DCTSEGD1(pmDtaSeg:'1':keyPressed);
    If keyPressed = 'ENTER';
      DtaSeg3 = pmDtaSeg;
    EndIf;

  Else;
    $ErrorMessage('DCT0004');
  EndIf;

  BuildField();

End-Proc;

// Initialization subroutine
Dcl-Proc BuildField;
  Dcl-S Des1 like(APLDCT.Des);
  Dcl-S Des2 like(APLDCT.Des);
  Dcl-S Des3 like(APLDCT.Des);

  // pull in column texts and headers
  ColTxt1='';
  ColTxt2='';
  ColTxt3='';
  ColHdg1='';
  ColHdg2='';
  ColHdg3='';
  Des1='';
  Des2='';
  Des3='';
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt1,:ColHdg1,:Des1
           From DCTSEG Where DtaSeg=:DtaSeg1;
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt2,:ColHdg2,:Des2
           From DCTSEG Where DtaSeg=:DtaSeg2;
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt3,:ColHdg3,:Des3
           From DCTSEG Where DtaSeg=:DtaSeg3;

  // If Column Text or Column headings aer blank override them to the description
  If ColTxt1='';
    ColTxt1=Des1;
  EndIf;
  If ColTxt2='';
    ColTxt2=Des2;
  EndIf;
  If ColTxt3='';
    ColTxt3=Des3;
  EndIf;
  If ColHdg1='';
    ColHdg1=ColTxt1;
  EndIf;
  If ColHdg2='';
    ColHdg2=ColTxt2;
  EndIf;
  If ColHdg3='';
    ColHdg3=ColTxt3;
  EndIf;

  // Build column text
  ColTxt=%trim(ColTxt1) + ' ' + %trim(ColTxt2) + ' ' + %trim(ColTxt3) + ' ';

End-Proc;

// Initialization subroutine
Dcl-Proc InitializeProgram;
  Clear Screen;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$nextFunctionKeys(fncDs);

  Open DCTFLDF3;

  RefreshScreen();

End-Proc;
