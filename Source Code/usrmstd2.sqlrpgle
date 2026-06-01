**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Detail Screen

// chgobjown obj(usrmstd2) objtype(*pgm) newown(qsecofr)

Dcl-F USRMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,USRMSTD2PR // Always include the prototype for the current program
/Copy QSRC,USRMSTC2PR // Update User Profile Values
/Copy QSRC,USRMSTC3PR // Copy User Profile
/Copy QSRC,USRMSTC5PR // Disable User Profile
/Copy QSRC,USRMSTC6PR // Enable User Profile
/Copy QSRC,USRMSTC7PR // Delete User Profile
/Copy QSRC,USRMSTB1PR // Update FastFax for a user
/Copy QSRC,USRMSTB2PR // Update RPT for a user
/Copy QSRC,USRMSTB3PR // Update SpyView for a user
/Copy QSRC,USRMSTB4PR // Refresh Index, USRMST file
/Copy QSRC,DCTVALBPPR // enumerated value prompt/validator
/Copy QSRC,DCTVALDPPR // enumerated value prompt
/Copy QSRC,PHYDEVD1PR // Physical device listing

Dcl-S usrOqn like(APLDCT.usrOqn);
Dcl-S usrOql like(APLDCT.usrOql);


// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  usrEml   Like(APLDCT.usrEml);
  acgCde   Like(APLDCT.acgCde);
  phnExt   Like(APLDCT.phnExt);
  usrTxt   Like(APLDCT.usrTxt);
  usrDpt   Like(APLDCT.usrDpt);
  empNbr   Like(APLDCT.empNbr);
  usrInt   Like(APLDCT.usrInt);
  frmKey   Like(APLDCT.frmKey);
  phnNbr   Like(APLDCT.phnNbr);
  lstNme   Like(APLDCT.lstNme);
  usrTtl   Like(APLDCT.usrTtl);
  grpPrf   Like(APLDCT.grpPrf);
  fstNme   Like(APLDCT.fstNme);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrUsrPrf Like(APLDCT.usrPrf);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-Ds DspVal ExtName('USRMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTD2');
    pmr1UsrPrf Like(APLDCT.UsrPrf);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrUsrPrf=pmr1UsrPrf;
  acno = pmrAcno;
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
      If UpdateScreen();
        iter;
      Else;
        Leave;
      EndIf;
    EndIf;
  EndDo;

  pmr1UsrPrf=usrPrf;
  pmrOption=Option;
  pmrKeyPressed = keyPressed;
  Close USRMSTF2;

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

  If ProtectKey;
    FldAtrKey = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrKey;
  EndIf;

  If ProtectCpy;
    FldAtrCpy = *allx'A7';    // @PrND
  Else;
    FldAtrCpy = *allx'A2';    // @PrWht
    $SetAttribute(frmKeys@:'');
  EndIf;

End-Proc;


// Validate screen
// **CHANGE and any required validation here
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S Error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S Count packed(5);

  Error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From USRMST
    Where usrPrf = :usrPrf;

  // Make sure record doesn't exists if create, copy or rename
  If Option in %list('1':'3':'7') and found;
    $ErrorMessage('':'Error - user already exists.':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and not found;
    $ErrorMessage('':'Error - user not found.':Error);
  EndIf;

  // Validate Rename
  If Option = '7'  and acNo <> pmrAcno;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid User Profile
  If usrPrf = '' and not ProtectDta;
    $ErrorMessage('':'Error - you must enter a user profile name.':Error:usrPrf@:'usrPrf':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid First Name
  If fstNme = *Blanks and not ProtectDta;
    $ErrorMessage('':'You must enter a first name.':Error:fstNme@:'fstNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // if in entry or copy, make sure the initials are not already used
  If Option='1' or Option='3';
    found = *off;
    Exec SQL Select '1' Into :found From USRMST Where usrInt=:usrInt Fetch First Row Only;
    If found;
      $ErrorMessage('':'Error - These initials are already in use.':
                    Error:usrInt@:'usrInt':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S smtpUsr Char(30);
  Dcl-S smtpDmn Char(30);
  Dcl-S pmMessage Char(100);
  Dcl-S bdgUsrPrf like(APLDCT.usrPrf);
  Dcl-S bdgUsrNbr packed(9);
  Dcl-S toUsrMstIdn like(APLDCT.usrMstIdn);
  Dcl-S frmUsrMstIdn like(APLDCT.usrMstIdn);

  Eval-Corr Dta = DspVal;
  Clear error;

  // Perform updates if no error

  // if the user profile name is not entered, default it
  If usrTxt = '';
    usrTxt = %trim(#$C1ST(fstNme)) + ' ' + %trim(#$C1ST(lstNme));
  EndIf;

  // Read error
  If %error;
    $ErrorMessage('DCT0200');

    // Create
  ElseIf Option = '1';
    Exec SQL
      Insert Into ACCESSPF
            (ACNO,ACBR,fstNme,lstNme,usrInt,ACDEPT,ACJOBD,ACTYPE,ACCRTA,ACCODE,
             ACWSNO,ACPEXT,ACEXRS,ACUPRF,ACPWDACT,ACEMAIL,
             ACEMAIL2,ACEMPNO,ACCTIEXT,ACAGTID,ACAGTAL)
      Values(:ACNO,:ACBR,:fstNme,:lstNme,:usrInt,:ACDEPT,:ACJOBD,:ACTYPE,:ACCRTA,:ACCODE,
             :ACWSNO,:ACPEXT,:ACEXRS,:ACUPRF,:ACPWDACT,:ACEMAIL,
             :ACEMAIL2,:ACEMPNO,:ACCTIEXT,:ACAGTID,:ACAGTAL);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Create the user profile
    USRMSTC3(acUPrf:cpyUsr:acgCde:usrTxt:usrOqn:usrOql:grpPrf);

    // Copy
  ElseIf Option = '3';
    Exec SQL
      Insert Into ACCESSPF
            (ACNO,ACBR,fstNme,lstNme,usrInt,ACDEPT,ACJOBD,ACTYPE,ACCRTA,ACCODE,
             ACWSNO,ACPEXT,ACEXRS,ACUPRF,ACPWDACT,ACEMAIL,
             ACEMAIL2,ACEMPNO,ACCTIEXT,ACAGTID,ACAGTAL)
      Values(:ACNO,:ACBR,:fstNme,:lstNme,:usrInt,:ACDEPT,:ACJOBD,:ACTYPE,:ACCRTA,:ACCODE,
             :ACWSNO,:ACPEXT,:ACEXRS,:ACUPRF,:ACPWDACT,:ACEMAIL,
             :ACEMAIL2,:ACEMPNO,:ACCTIEXT,:ACAGTID,:ACAGTAL);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;
    // Copy the GPPJOB Entry
    Exec SQL Insert Into GPPJOBD
          (JDUSER,JDLB01,JDLB02,JDLB03,JDLB04,JDLB05,JDLB06,JDLB07,JDLB08,JDLB09,JDLB10,JDLB11,
           JDLB12,JDLB13,JDLB14,JDLB15,JDLB16,JDLB17,JDLB18,JDLB19,JDLB20,JDLB21,JDLB22,JDLB23,
           JDLB24,JDLB25,JDMENU,JDJPTY,JDOPTY,JDLOG1,JDLOG2,JDLOG3,JDJOBQ,JDJQLB,JDOUTQ,JDOQLB,
           JDAREM,JDEXCP,JDVLOC)
      Select :acUprf ,JDLB01,JDLB02,JDLB03,JDLB04,JDLB05,JDLB06,JDLB07,JDLB08,JDLB09,JDLB10,JDLB11,
           JDLB12,JDLB13,JDLB14,JDLB15,JDLB16,JDLB17,JDLB18,JDLB19,JDLB20,JDLB21,JDLB22,JDLB23,
           JDLB24,JDLB25,JDMENU,JDJPTY,JDOPTY,JDLOG1,JDLOG2,JDLOG3,JDJOBQ,JDJQLB,JDOUTQ,JDOQLB,
           JDAREM,JDEXCP,JDVLOC
      From GPPJOBD
      Where jdUser = :cpyUsr;
    // Copy the user profile
    If acUPrf <> '';
      USRMSTC3(acUPrf:cpyUsr:acgCde:usrTxt:usrOqn:usrOql:grpPrf);
    EndIf;
    // Add the new user to USRMST
    USRMSTB4(acUPrf);
    // Copy the users roles, but make then in a pending status
    Clear toUsrMstIdn;
    Clear frmUsrMstIdn;
    Exec SQL Select usrMstIdn into :frmUsrMstIdn from USRMST where accNbr = :acNoCpy;
    Exec SQL Select usrMstIdn into :toUsrMstIdn from USRMST where usrPrf = :acUPrf;
    If toUsrMstIdn <> 0 and frmUsrMstIdn <> 0;
      Exec SQL
        Insert into USRROL
              ( usrMstIdn,    rolMstIdn, rolApr)
        Select :toUsrMstIdn, rolMstIdn, '0'
        From USRROL
        Where usrMstIdn = :frmUsrMstIdn;
    EndIf;

    // Inactivate
  ElseIf Option = '4' and acUPrf <> '';
    USRMSTC5(acUprf:pmMessage);  // disable the profile
    $ErrorMessage('':pmMessage); // Log the message returned
    If pmMessage < 'User disabled.';
      error = *on;
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
      Update ACCESSPF
      Set (acNo)
        = (:acNo)
    Where acNo = :pmrAcno;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13' and acUPrf <> '';
    USRMSTC6(acUprf:pmMessage);  // Ensable the profile
    $ErrorMessage('':pmMessage); // Log the message returned
    If pmMessage < 'User Profile Enabled.';
      error = *on;
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update ACCESSPF
      Set(ACNO,ACBR,fstNme,lstNme,usrInt,ACDEPT,ACJOBD,ACTYPE,ACCRTA,ACCODE,
          ACWSNO,ACPEXT,ACEXRS,ACUPRF,ACPWDACT,ACEMAIL,
          ACEMAIL2,ACEMPNO,ACCTIEXT,ACAGTID,ACAGTAL)
       = (:ACNO,:ACBR,:fstNme,:lstNme,:usrInt,:ACDEPT,:ACJOBD,:ACTYPE,:ACCRTA,:ACCODE,
          :ACWSNO,:ACPEXT,:ACEXRS,:ACUPRF,:ACPWDACT,:ACEMAIL,
          :ACEMAIL2,:ACEMPNO,:ACCTIEXT,:ACAGTID,:ACAGTAL)
      Where acNo = :acNo;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Split the email address into a user and domain
    Monitor;
      smtpUsr = %subst(acEmail:1:%scan('@':acEmail)-1);
      smtpDmn = %subst(acEmail:%scan('@':acEmail)+1:%len(acEmail) - %scan('@':acEmail));
    On-Error;
    EndMon;

  EndIf;

  If acUPrf <> '';
    // Update output queue in user profile
    USRMSTC2(acUPrf:acgCde:usrTxt:usrOqn:usrOql:grpPrf:smtpUsr:smtpDmn);
    // Update FASTFAX, RPT and Spyview
    USRMSTB1(acUPrf);
    USRMSTB2(acUPrf);
    USRMSTB3(acUPrf);
    USRMSTB4(acUPrf);
  EndIf;

  // try add or delete the badge user if it says to
  bdgUsrPrf = 'Q1234' + acEmpNo;
  If bdgUsr = 'Y';
    #$CMD('CRTSCNPRF ' + acempNo);
  Else;
    USRMSTC7(bdgUsrPrf:pmMessage);
  EndIf;

  // try add or delete the supervisor override option
  bdgUsrNbr = 123400000 + #$RVL(acEmpNo);
  If sprOvr = 'Y';
    found = *off;
    Exec SQL Select '1' Into :found From SPRVOVPF Where sprVNum = :bdgUsrNbr;
    If not found;
      Exec SQL Insert Into SPRVOVPF (sprVNum) values(:bdgUsrNbr);
    EndIf;
  Else;
    Exec SQL Delete From SPRVOVPF Where SPRVNUM = :bdgUsrNbr;
  EndIf;

  If #$TESTN(acEmpNo) and %dec(acempno:5:0) <> 0;
    Exec SQL update fabrcut3/unique3/empsweb
             set epswrd = trim(substr(:fstNme,1,1) || '$' || :accode)
             where enum = :acempno;
    If sqlstate >= '02';
      Exec SQL insert into fabrcut3/unique3/empsweb
                   (estat,enum,efname,elname,eusrprf,eusreml,epswrd,
                    edept,eext)
             values('E',:acEmpNo,:fstNme,:lstNme,:acUPrf,:acEmail,trim(substr(:fstNme,1,1) || '$' || :accode),
                    :acDept,:acpext);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmWsno   Like(APLLIB.acWsno);
  Dcl-S pmOption Like(Option);

  // Prompt Password action
  If CsrFld = 'ACPWDACT' and not ProtectDta;
    DCTVALDP('APLLIB':'ACPWDACT':pmEnmVal:pmEnmDes:pmKeyPressed);
    If pmKeyPressed = 'ENTER';
      ACPWDACT = pmEnmVal;
    EndIf;

    // Prompt workstation
  ElseIf CsrFld = 'ACWSNO' and not ProtectDta;
    pmOption='1';
    PHYDEVD1(pmWsno:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER' and pmWsno <> '';
      acWsno = pmWsno;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;

// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;
  Dcl-S usrSts Like(APLDCT.usrSts);
  Dcl-S usrCls Like(APLDCT.usrCls);
  Dcl-S bdgUsrPrf Like(APLDCT.usrPrf);
  Dcl-S bdgUsrNbr packed(9);

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;

  // * allow key field changes on create
  If Option = '1';
    mde = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    mde = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
    mde = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'acNo':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(USRMSTF2);
    Open USRMSTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  // Display and process data
  Clear Dta;
  usrPrf = pmrUsrPrf;
  Exec SQL
    Select
      usrEml,
      acgCde,
      phnExt,
      usrTxt,
      usrDpt,
      empNbr,
      usrInt,
      frmKey,
      phnNbr,
      lstNme,
      usrTtl,
      grpPrf,
      fstNme
    Into :Dta
    From USRMST
    Where usrPRf = :usrPrf;
  Eval-Corr DspVal = Dta;
  cpyUsr = pmrUsrPrf;

  // on copy clear the user profile so they have to enter it
  If Option='3';
    Clear usrPrf;
  EndIf;

End-Proc;
