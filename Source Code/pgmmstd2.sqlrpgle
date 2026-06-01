**FREE

Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Master Maintenance

Dcl-F PGMMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,PGMMSTD2PR // Always include the prototype for the current program
/Copy QSRC,DCTVALDPPR
/Copy QSRC,DCTVALBPPR

// Data structure used to read SQL into
Dcl-Ds Dta Qualified;
  PgmNme    Like(APLDCT.PgmNme);
  Des       Like(APLDCT.Des);
  AplDes    char(20);
  objTyp    Like(APLDCT.objTyp);
  mnuObjDes char(20);
  webAplDes char(20);
  mnuNme    Like(APLDCT.mnuNme);
  dspFle    Like(APLDCT.dspFle);
  secAut    Like(APLDCT.secAut);
  dftAutDes char(20);
  reqItr    Like(APLDCT.reqItr);
  reqOwn    Like(APLDCT.reqOwn);
  reqDBA    Like(APLDCT.reqDba);
  secPgm    Like(APLDCT.secPgm);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrPgmNme Like(APLDCT.PgmNme);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S apl like(APLDCT.apl);
Dcl-S mnuObj like(APLDCT.mnuObj);
Dcl-S webApl like(APLDCT.webApl);
Dcl-S dftAut like(APLDCT.dftAut);

Dcl-Ds DspVal ExtName('PGMMSTF2') Inz End-DS;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMMSTD2');
    pmr1pgmNme Like(APLDCT.pgmNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
    toPgm Like(APLDCT.pgmNme);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrPgmNme=pmr1pgmNme;
  pgmNme = pmrPgmNme;
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
    ElseIf mode = 'Display'; // If in display mode, don't validate or update, just leave
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close PGMMSTF2;

  // If a program was copied returnthe to program name
  If pmrOption='3' and %parms>=4;
    toPgm=pgmNme;
  EndIf;

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
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmKeyPressed Like(keyPressed);

  Error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From PGMMST
    Where pgmNme = :pgmNme;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and not EOF;
    $ErrorMessage('DCT1101':'':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and EOF;
    $ErrorMessage('DCT1102':'':Error);
  EndIf;

  // Validate Rename
  If Option = '7'  and pgmNme <> pmrPgmNme;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid Dictionary Name
  If pgmNme = *blanks;
    $ErrorMessage('DCT1001':'':Error:pgmNme@:'pgmNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid Program Description
  If Des = *Blanks and not ProtectDta;
    $ErrorMessage('DCT1003':'':Error:des@:'des':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the application value is correct, Auto prompt first if not valid, handles ?
  If not ProtectDta;
    pmEnmVal='';
    pmEnmDes=AplDes;
    DCTVALBP('APLDCT':'APL':pmEnmVal:pmEnmDes:pmKeyPressed);
    apl = pmEnmVal;
    If AplDes <> pmEnmDes;
      AplDes = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(AplDes):'APLDCT':'Apl');
      $ErrorMessage('DCT1002':'':Error:AplDes@:'AplDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the menu object is correct, Auto prompt first if not valid, handles ?
  If not ProtectDta;
    pmEnmVal='';
    pmEnmDes=mnuObjDes;
    DCTVALBP('APLDCT':'MNUOBJ':pmEnmVal:pmEnmDes:pmKeyPressed);
    mnuObj = pmEnmVal;
    If mnuObjDes <> pmEnmDes;
      MnuObjDes = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(mnuObjDes):'APLDCT':'mnuObj');
      $ErrorMessage('DCT1002':'':Error:mnuObjDes@:'mnuObjDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the web application value is correct, Auto prompt first if not valid, handles ?
  If not ProtectDta;
    pmEnmVal='';
    pmEnmDes=webAplDes;
    DCTVALBP('APLDCT':'WEBAPL':pmEnmVal:pmEnmDes:pmKeyPressed);
    webApl = pmEnmVal;
    If webAplDes <> pmEnmDes;
      webAplDes = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(webAplDes):'APLDCT':'webApl');
      $ErrorMessage('DCT1002':'':Error:webAplDes@:'webAplDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // make sure the default authority object value is correct, Auto prompt first if not valid, handle
  If not ProtectDta;
    pmEnmVal='';
    pmEnmDes=dftAutDes;
    DCTVALBP('APLDCT':'DFTAUT':pmEnmVal:pmEnmDes:pmKeyPressed);
    dftAut = pmEnmVal;
    If dftAutDes <> pmEnmDes;
      dftAutDes = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(dftAutDes):'APLDCT':'dftAut');
      $ErrorMessage('DCT1002':'':Error:dftAutDes@:'dftAutDes':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // if the 7th character is a D and they didn't put in a display file, default it for them and redisplay the screen
  If %subst(pgmNme:7:1)='D' and dspFle='';
    dspFle = %subst(pgmNme:1:6) + 'F' + %subst(pgmNme:8:2);
    $ErrorMessage('':'Display file name defaulted for you.':Error:dspFle@:'dspFle':outRow:outCol:psDsPgmNam);
    // validate the display file name
  ElseIf %subst(pgmNme:7:1)='D' and dspFle<>%subst(pgmNme:1:6) + 'F' + %subst(pgmNme:8:2);
    $ErrorMessage('':'Display file name does not mathc program.':Error:dspFle@:'dspFle':outRow:outCol:psDsPgmNam);
  ElseIf %subst(pgmNme:7:1)<>'D' and dspFle<>'' and %len(%trim(pgmNme)) > 7;
    $ErrorMessage('':'Display file name should be blank.':Error:dspFle@:'dspFle':outRow:outCol:psDsPgmNam);
  EndIf;

  // Default the object type if not entered
  If objTyp='' and %subst(pgmNme:7:1)='D';
    objTyp='SQLRPGLE';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='U';
    objTyp='SQLUDF';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='T';
    objTyp='SQLRPGLE';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='S';
    objTyp='SQLSP';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='B';
    objTyp='SQLRPGLE';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='P';
    objTyp='PNLGRP';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='C';
    objTyp='CLLE';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='F';
    objTyp='DSPF';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='V';
    objTyp='SQLRPGLE';
  ElseIf objTyp='' and %subst(pgmNme:7:1)='N';
    objTyp='BND';
  EndIf;

  Return Error;

End-Proc;


// select item
// **CHANGE, this need to be changed to update the correct stuff
Dcl-Proc UpdateScreen;

  Eval-Corr Dta = DspVal;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage('DCT0200');

    // Create
  ElseIf Option = '1';
    Exec SQL
    Insert Into PGMMST
    (AcvRow, pgmNme, Des,
     apl, objtyp, pgmTyp, mnuobj, secaut, dftaut, webapl,
     mnunme, dspFle, reqitr, reqown, reqdba, secpgm,
     CrtDtm, CrtUsr, CrtJob, CrtPgm,
     MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :pgmNme, :Des,
     :apl, :objtyp, substr(:pgmNme,7,1), :mnuObj, :secaut, :dftAut, :webApl,
     :mnunme, :dspFle, :reqitr, :reqown, :reqdba, :secpgm,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Copy
  ElseIf Option = '3';
    Exec SQL
    Insert Into PGMMST
    (AcvRow, pgmNme, Des,
     apl, objtyp, pgmTyp, mnuobj, secaut, dftaut, webapl,
     mnunme, dspFle, reqitr, reqown, reqdba, secpgm,
     CrtDtm, CrtUsr, CrtJob, CrtPgm,
     MntDtm, MntUsr, MntJob, MntPgm)
    Values('1', :pgmNme, :Des,
     :apl, :objtyp, substr(:pgmNme,7,1), :mnuObj, :secaut, :dftAut, :webApl,
     :mnunme, :dspFle, :reqitr, :reqown, :reqdba, :secpgm,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
      Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Inactivate
  ElseIf Option = '4';
    Exec SQL
    Update PGMMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where pgmNme = :pgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
    Update PGMMST
    Set   pgmNme = :pgmNme
    Where pgmNme = :pmrPgmNme;
    Exec SQL
      Update PGMMST
      Set (pgmNme, MntDtm, MntUsr, MntJob, MntPgm)
    = (:pgmNme, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where pgmNme = :pmrPgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update PGMMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where pgmNme = :pgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update PGMMST
      set (AcvRow, pgmNme, Des,
           apl, objtyp, pgmTyp, mnuobj, secaut, dftaut, webapl,
           mnunme, dspFle, reqitr, reqown, reqdba, secpgm,
           MntDtm, MntUsr, MntJob, MntPgm)
        = ('1', :pgmNme, :Des,
          :apl, :objtyp, substr(:pgmNme,7,1), :mnuObj, :secaut, :dftAut, :webApl,
          :mnunme, :dspFle, :reqitr, :reqown, :reqdba, :secpgm,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where pgmNme = :pgmNme;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;

  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt Active Description
  If CsrFld = 'APLDES';
    DCTVALDP('APLDCT':'APL':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      AplDes = pmEnmDes;
    EndIf;

    // Prompt Menu Object
  ElseIf CsrFld = 'MNUOBJDES';
    DCTVALDP('APLDCT':'MNUOBJ':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      MnuObjDes = pmEnmDes;
    EndIf;

    // Prompt Web Acpplication
  ElseIf CsrFld = 'WEBAPLDES';
    DCTVALDP('APLDCT':'WEBAPL':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      WebAplDes = pmEnmDes;
    EndIf;

    // Default Authorization
  ElseIf CsrFld = 'DFTAUTDES';
    DCTVALDP('APLDCT':'DFTAUT':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      DftAutDes = pmEnmDes;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;


End-Proc;

// Initialization subroutine, also called for a F5=Refresh
// **CHANGE the screen name and any logic needed to load the screen
Dcl-Proc InitializeProgram;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme2 is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;

  // * allow key field changes on create
  If Option = '1';
    Mode = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'DES':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    Mode = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    Mode = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    Mode = 'Display';
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);
    Mode = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);
    Mode = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'pgmNmeT':outRow:outCol);
    Mode = 'Unknown';
  EndIf;

  If not %open(PGMMSTF2);
    Open PGMMSTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  pgmNmeCpy = pmrPgmNme;

  // Display and process data
  Clear Dta;
  pgmNme = pmrPgmNme;
  Exec SQL
    Select
      pgmNme,
      Des,
      coalesce(a.enmDes,'') as aplDes,
      objTyp,
      coalesce(b.enmDes,'') as mnuObjDes,
      coalesce(c.enmDes,'') as webAplDes,
      mnuNme,
      dspFle,
      secAut,
      coalesce(d.enmDes,'') as dftAutDes,
      reqItr, reqOwn, reqDBA, secPgm
      Into :Dta
    From PGMMST
    left join DCTVAL as a on a.dctNme='APLDCT'
                         and a.FldNme='APL'
                         and a.EnmVal=PGMMST.apl
    left join DCTVAL as b on b.dctNme='APLDCT'
                         and b.FldNme='MNUOBJ'
                         and b.EnmVal=PGMMST.mnuObj
    left join DCTVAL as c on c.dctNme='APLDCT'
                         and c.FldNme='WEBAPL'
                         and c.EnmVal=PGMMST.webApl
    left join DCTVAL as d on d.dctNme='APLDCT'
                         and d.FldNme='DFTAUT'
                         and d.EnmVal=PGMMST.dftAut
    Where pgmNme = :pgmNme;
  Eval-Corr DspVal = Dta;

End-Proc;
