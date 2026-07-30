**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Detail Screen 2

Dcl-F USRMSTF3 WORKSTN InfDS(DspDS) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD3_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD3PR // Always include the prototype for the current program
/Copy QSRC,USRMSTC1PR // Get User Profile Values
/Copy QSRC,USRMSTC2PR // Update User Profile Values
/Copy QSRC,USRMSTB1PR // Update FastFax for a user
/Copy QSRC,USRMSTB2PR // Update RPT for a user
/Copy QSRC,USRMSTB3PR // Update SpyView for a user
/Copy QSRC,USRMSTB4PR // Refresh Index, USRMST file


// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  JDLB01  Like(APLLIB.JDLB01);
  JDLB02  Like(APLLIB.JDLB02);
  JDLB03  Like(APLLIB.JDLB03);
  JDLB04  Like(APLLIB.JDLB04);
  JDLB05  Like(APLLIB.JDLB05);
  JDLB06  Like(APLLIB.JDLB06);
  JDLB07  Like(APLLIB.JDLB07);
  JDLB08  Like(APLLIB.JDLB08);
  JDLB09  Like(APLLIB.JDLB09);
  JDLB10  Like(APLLIB.JDLB10);
  JDLB11  Like(APLLIB.JDLB11);
  JDLB12  Like(APLLIB.JDLB12);
  JDLB13  Like(APLLIB.JDLB13);
  JDLB14  Like(APLLIB.JDLB14);
  JDLB15  Like(APLLIB.JDLB15);
  JDLB16  Like(APLLIB.JDLB16);
  JDLB17  Like(APLLIB.JDLB17);
  JDLB18  Like(APLLIB.JDLB18);
  JDLB19  Like(APLLIB.JDLB19);
  JDLB20  Like(APLLIB.JDLB20);
  JDLB21  Like(APLLIB.JDLB21);
  JDLB22  Like(APLLIB.JDLB22);
  JDLB23  Like(APLLIB.JDLB23);
  JDLB24  Like(APLLIB.JDLB24);
  JDLB25  Like(APLLIB.JDLB25);
  JDMENU  Like(APLLIB.JDMENU);
  JDJPTY  Like(APLLIB.JDJPTY);
  JDOPTY  Like(APLLIB.JDOPTY);
  JDLOG1  Like(APLLIB.JDLOG1);
  JDLOG2  Like(APLLIB.JDLOG2);
  JDLOG3  Like(APLLIB.JDLOG3);
  JDJOBQ  Like(APLLIB.JDJOBQ);
  JDJQLB  Like(APLLIB.JDJQLB);
  JDOUTQ  Like(APLLIB.JDOUTQ);
  JDOQLB  Like(APLLIB.JDOQLB);
  JDAREM  Like(APLLIB.JDAREM);
  JDEXCP  Like(APLLIB.JDEXCP);
  JDVLOC  Like(APLLIB.JDVLOC);
End-Ds;

Dcl-S acUPrf Like(APLLIB.acUPrf);
Dcl-S acgCde Like(APLDCT.acgCde);
Dcl-S grpPrf Like(APLDCT.grpPrf);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('USRMSTF3') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD3');
    pmrAcno Zoned(5);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  acno = pmrAcno;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SndMsg('Not authorized to program');
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

  pmrKeyPressed = keyPressed;
  Close USRMSTF3;

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

  // reset all field attributes
  SetAttributes();

End-Proc;


// Set Field Attributes
// *** Do not change anything in here ***
Dcl-Proc SetAttributes;

  If ProtectDta;
    FldAtrDta = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrDta;
  EndIf;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;

  error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From ACCESSPF
    Where acno = :acno;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and not EOF;
    $ErrorMessage('DCT1101':'':error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and EOF;
    $ErrorMessage('DCT1102':'':error);
  EndIf;

  // Check Required Data

  // Make sure the output queues exist if entered
  If jdoutq <> '' and not #$isOBJ(jdOutQ:'*OUTQ':jdOQLb);
    $ErrorMessage('':'Error - Output Queue does not exist.':error:jdOutQ@:'jdQoutQ':outRow:outCol:psDsPgmNam);
  EndIf;
  If SPOQNM <> '' and not #$isOBJ(SPOQNM:'*OUTQ':SPOQLB);
    $ErrorMessage('':'Error - Output Queue does not exist.':error:SPOQNm@:'SPOQNM':outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Eval-Corr Dta = DspVal;

  // Perform updates if no error


  // Update JPPJOBD
  Exec SQL
    Update GPPJOBD
    Set (JDLB01,JDLB02,JDLB03,JDLB04,JDLB05,JDLB06,JDLB07,JDLB08,JDLB09,JDLB10,JDLB11,JDLB12,JDLB13,JDLB14,
         JDLB15,JDLB16,JDLB17,JDLB18,JDLB19,JDLB20,JDLB21,JDLB22,JDLB23,JDLB24,JDLB25,JDMENU,JDJPTY,JDOPTY,
         JDLOG1,JDLOG2,JDLOG3,JDJOBQ,JDJQLB,JDOUTQ,JDOQLB,JDAREM,JDEXCP,JDVLOC)
      = (:JDLB01,:JDLB02,:JDLB03,:JDLB04,:JDLB05,:JDLB06,:JDLB07,:JDLB08,:JDLB09,:JDLB10,:JDLB11,:JDLB12,
         :JDLB13,:JDLB14,:JDLB15,:JDLB16,:JDLB17,:JDLB18,:JDLB19,:JDLB20,:JDLB21,:JDLB22,:JDLB23,:JDLB24,
         :JDLB25,:JDMENU,:JDJPTY,:JDOPTY,:JDLOG1,:JDLOG2,:JDLOG3,:JDJOBQ,:JDJQLB,:JDOUTQ,:JDOQLB,:JDAREM,
         :JDEXCP,:JDVLOC)
    Where jdUser = :acUPrf;
  If sqlState > '02';
    Exec SQL Insert Into GPPJOBD
          (JDLB01,JDLB02,JDLB03,JDLB04,JDLB05,JDLB06,JDLB07,JDLB08,JDLB09,JDLB10,JDLB11,JDLB12,JDLB13,JDLB14,
           JDLB15,JDLB16,JDLB17,JDLB18,JDLB19,JDLB20,JDLB21,JDLB22,JDLB23,JDLB24,JDLB25,JDMENU,JDJPTY,JDOPTY,
           JDLOG1,JDLOG2,JDLOG3,JDJOBQ,JDJQLB,JDOUTQ,JDOQLB,JDAREM,JDEXCP,JDVLOC, JDUSER)
    Values(:JDLB01,:JDLB02,:JDLB03,:JDLB04,:JDLB05,:JDLB06,:JDLB07,:JDLB08,:JDLB09,:JDLB10,:JDLB11,:JDLB12,
           :JDLB13,:JDLB14,:JDLB15,:JDLB16,:JDLB17,:JDLB18,:JDLB19,:JDLB20,:JDLB21,:JDLB22,:JDLB23,:JDLB24,
           :JDLB25,:JDMENU,:JDJPTY,:JDOPTY,:JDLOG1,:JDLOG2,:JDLOG3,:JDJOBQ,:JDJQLB,:JDOUTQ,:JDOQLB,:JDAREM,
           :JDEXCP,:JDVLOC,:acUPrf);
  EndIf;

  if acUprf <> '';
    // Update output queue in user profile
    USRMSTC2(acUPrf:acgCde:usrNme:jdoutq:jdoqlb:grpPrf);
    // Update FASTFAX, RPT and Spyview
    USRMSTB1(acUPrf);
    USRMSTB2(acUPrf);
    USRMSTB3(acUPrf);
    USRMSTB4(acUPrf);
    // Update SPYVIEW with the output queue
    Exec SQL Update RSUBSCR Set (SOUTQ,SOUTQL) = (:SPOQNM,:SPOQLB) where SUBSID = :acUPrf;
  Endif;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  // Prompt State
  If CsrFld = 'DES';
  // FLDDTLD1('STE':PmFldVal:1:keyPressed);
  // If keyPressed = 'Enter' and not ProtectDta;
  //    Des = PmFldVal;
  // EndIf;

  // Prompt Country
  ElseIf CsrFld = 'NTE';
  // FLDDTLD1('COU':PmFldVal:1:keyPressed);
  // If keyPressed = 'Enter' and not ProtectDta;
  //    Nte = PmFldVal;
  // EndIf;

  //* Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;

// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;
  Dcl-s usrSts like(APLDCT.usrSts);
  Dcl-s usrCls like(APLDCT.usrCls);

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$nextFunctionKeys(fncDs);

  //* protect fields
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;

  if Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);
  Else;
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
  EndIf;

  If not %open(USRMSTF3);
    Open USRMSTF3;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // get user profile from Accesspf
  Exec SQL Select acUPrf into :acUPrf from accesspf where acNo = :acNo;

  // get values from user profile
  USRMSTC1(acUPrf:acgCde:usrNme:jdoutq:jdoqlb:grpPrf:usrSts:usrcls);

  // Get JPPJOBD values
  Clear Dta;
  Exec SQL
    Select JDLB01,JDLB02,JDLB03,JDLB04,JDLB05,JDLB06,JDLB07,JDLB08,JDLB09,JDLB10,JDLB11,JDLB12,JDLB13,JDLB14,
           JDLB15,JDLB16,JDLB17,JDLB18,JDLB19,JDLB20,JDLB21,JDLB22,JDLB23,JDLB24,JDLB25,JDMENU,JDJPTY,JDOPTY,
           JDLOG1,JDLOG2,JDLOG3,JDJOBQ,JDJQLB,JDOUTQ,JDOQLB,JDAREM,JDEXCP,JDVLOC
    Into :Dta
    From GPPJOBD
    Where jdUser = :acUPrf;
  Eval-Corr DspVal = Dta;

  // If there is no Library list, setup all defaults
  if jdLb01 = '';
    jdLb01 = 'QTEMP';
    jdLb02 = 'BJQ2LIB';
    jdLb03 = 'FABNOSYNC';
    jdLb04 = 'APLLIB';
    jdLb05 = 'APLLIB';
    jdLb06 = 'ARRLIB';
    jdLb07 = 'NVTLIB';
    jdLb08 = 'APPLIB';
    jdLb09 = 'OEILIB';
    jdLb10 = 'QGPL';
    jdLb11 = 'QIDU';
    jdLb12 = 'PAYLIB';
    JDMENU = 3;
    JDJPTY = '5';
    JDOPTY = '5';
    JDLOG1 = '5';
    JDLOG2 = '4';
    JDLOG3 = '*SECLVL';
    JDJOBQ = 'QBATCH';
    JDJQLB = 'BJQ2LIB';
    JDEXCP = 20;
  ENDIF;

  // Get Spy View default output queue
  Exec SQL Select SOUTQ,SOUTQL into :SPOQNM,:SPOQLB from RSUBSCR where SUBSID = :acUPrf;

End-Proc;
