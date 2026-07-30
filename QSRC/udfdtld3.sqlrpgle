**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// User Default Detail Program Selection

Dcl-F UDFDTLF3 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,UDFDTLD3_@ // auto generated data structures for field attribute fields
/Copy QSRC,UDFDTLD3PR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S NumberOfRows packed(9); // the total number of rows in the data set
Dcl-S i  Like(OutRRN1);

Dcl-S UDFDpt like(APLDCT.UDFDpt);
Dcl-S UDFUsr like(APLDCT.UDFUsr);
Dcl-S UDFDft like(APLDCT.UDFDft);
Dcl-S usrDpt like(APLDCT.UDFDpt);
Dcl-S curDpt like(APLDCT.UDFDpt);
Dcl-S jobDes Char(10);

Dcl-S Option  like(APLDCT.Option); // global variable to store the option parameter in


// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('UDFDTLD3');
    pmrPgmNme Like(APLDCT.pgmNme);
    pmrUDFDpt Like(APLDCT.UDFDpt);
    pmrUDFUsr Like(APLDCT.UDFUsr);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  pgmNme = pmrPgmNme;
  UDFDpt = pmrUDFDpt;
  UDFUsr = pmrUDFUsr;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' and keyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F5';
      ProgramInitialization();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F24';
      fncKeys=$NextFunctionKeys(fncDs);
    ElseIf ValidateScreen();
      Iter;
    Else;
      UpdateScreen();
    EndIf;

  EndDo;

  Close UDFDTLF3;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  Write FOOTER;
  Exfmt SFLCTL;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // Set the initial SFL position to the one the cursor is on or the top
  // if page down was pressed and the cursor is not on a SFL row set to bottom
  If keyPressed='PAGEDOWN' and CsrRRN1=0 and EOF;
    OutRRN1 = RRN1;
  ElseIf CsrRRN1 = 0;
    OutRRN1 = 1;
  Else;
    OutRRN1 = CsrRRN1;
  EndIf;

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // This logic moves the cursor to the start of a field if it was left somewhere in the middle
  If csrFld<>'';
    $GetFieldLocation(PgmNme:csrFld:outRow:outCol);
  EndIf;

  // Clear message SFL
  $ClearMessages();

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes, for lists normally just the key field has to be changed,
// if it updates anything it needs to be added
Dcl-Proc UpdateScreen;

  // Loop through each SFL entry and update the option
  // if there is no value, delete the entry, otherwise update it.
  For i = 1 To NumberOfRows;
    Chain i SFL;
    If %found;
      If UDFUsr<>'' and UDFVal = '' and usrChg='';
        Exec SQL Delete From UDFDTL
                 Where (pgmNme,UDFKey,UDFDpt,UDFUsr) = (:pgmNme,:UDFKey,:UDFDpt,:UDFUsr);
      ElseIf UDFUsr='' and UDFVal = '' and dptChg='';
        Exec SQL Delete From UDFDTL
                 Where (pgmNme,UDFKey,UDFDpt,UDFUsr) = (:pgmNme,:UDFKey,:UDFDpt,:UDFUsr);
      ElseIf UDFUsr<>'';
        Exec SQL Update UDFDTL
                 set ( UDFVAL, usrCnf, MntPgm, MntUsr,MntJob,MntDtm)
                   = (:UDFVal,:usrChg,:pgmNmeH,:User, :WsId, current timestamp)
                 Where (pgmNme,UDFKey,UDFDpt,UDFUsr) = (:pgmNme,:UDFKey,:UDFDpt,:UDFUsr);
        If sqlState>='02';
          Exec SQL Insert Into UDFDTL
                    (acvRow,  UDFDpt, UDFUSR, pgmNme, UDFKey, UDFVAL, usrCnf,
                     crtPgm,  crtUsr,  crtJob, crtDtm,
                     MntPgm,  MntUsr,  MntJob, MntDtm)
             values( '1',    :UDFDpt,:UDFUsr,:pgmNMe,:UDFKey, :UDFVal, :usrChg,
                    :pgmNmeH,:User,  :WsId,   current timestamp,
                    :pgmNmeH,:User,  :WsId,   current timestamp);
        EndIf;
      Else;
        Exec SQL Update UDFDTL
                 set ( UDFVAL, usrCnf, MntPgm,  MntUsr, MntJob,MntDtm)
                   = (:UDFVal,:dptChg,:pgmNmeH,:User,  :WsId, current timestamp)
                 Where (pgmNme,UDFKey,UDFDpt,UDFUsr) = (:pgmNme,:UDFKey,:UDFDpt,:UDFUsr);
        If sqlState>='02';
          Exec SQL Insert Into UDFDTL
                    (acvRow,  UDFDpt, UDFUSR, pgmNme, UDFKey, UDFVAL,usrCnf,
                     crtPgm,  crtUsr,  crtJob, crtDtm,
                     MntPgm,  MntUsr,  MntJob, MntDtm)
             values( '1',    :UDFDpt,:UDFUsr,:pgmNMe,:UDFKey, :UDFVal,:dptChg,
                    :pgmNmeH,:User,  :WsId,   current timestamp,
                    :pgmNmeH,:User,  :WsId,   current timestamp);
        EndIf;
      EndIf;
    EndIf;
  EndFor;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Validate anything entered on the screen
// **CHANGE Add validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  // Loop through each SFL entry and make sure any entered values match the attribute type
  For i = 1 To NumberOfRows;
    Chain i SFL;
    If %found;
      If UDFVal <> '';
        If UDFOpt = 'Y/N' and not(UDFVal in %list('Y':'N'));
          $ErrorMessage('':'Error - Invalid option, must Y or N.':error:UDFVal@:'UDFVal':outRow:outCol:psDsPgmNam);
          outRow+=i-1; // required to move to the correct SFL line
        EndIf;
      EndIf;
    EndIf;
  EndFor;

  Return error;

End-Proc;


// Load the SFL
// *** Do not change anything in here ***
Dcl-Proc LoadSFL;
  Dcl-S sqlStm Varchar(10000);

  // Clear SFL
  SflClr = *on;
  Write SFLCTL;
  SflClr = *off;
  SflDsp = *on;

  // build SQL statement
  sqlStm = '+
    Select UDFKey, UDFOpt, UDFDes, UDFDft, usrCnf +
    From UDFMST +
    Where pgmNme = ''' + %trim(pgmNme) + '''';

  // Add search if populated
  If schVal <> ' ';
    #$BLDSCHF(01)='UDFKey';
    #$BLDSCHF(02)='UDFOpt';
    #$BLDSCHF(03)='UDFDes';
    #$BLDSCHF(04)='UDFDft';
    sqlStm += ' and ' + #$BLDSCH(schVal:#$BLDSCHF);
  EndIf;

  // Add order by
  sqlStm += ' Order By UDFDes';

  // Load SFL
  RRN1=0;
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Cursor For sqlStm;
  Exec SQL Open SQLCrs;
  Exec SQL Fetch Next From SQLCrs Into :UDFKey, :UDFOpt, :UDFDes, :UDFDft, :sysChg;
  DoW sqlState < '02';
    AddSFL();
    Exec SQL Fetch Next From SQLCrs Into :UDFKey, :UDFOpt, :UDFDes, :UDFDft, :sysChg;
  EndDo;
  Exec SQL Close SQLCrs;

  OutRRN1 = 1;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    SflDsp  = *Off;
  EndIf;

  NumberOfRows = RRN1;

End-Proc;


// Add an entry to the SFL
Dcl-Proc AddSFL;

  // Set the users Default, department Default and system default
  UDFVal = '';
  sysDft = '';
  dptDft = '';
  dptChg = '';
  usrChg = '';
  If UDFUsr <> '';
    Exec SQL Select UDFVal,usrCnf Into :dptDft,:dptChg From UDFDTL
             Where (UDFDpt,UDFUsr,pgmNme,UDFKey) = (:usrDpt,'',:pgmNme,:UDFKey);
    Exec SQL Select UDFVal,usrCnf Into :UDFVal,:usrChg From UDFDTL
             Where (UDFDpt,UDFUsr,pgmNme,UDFKey) = ('',:UDFUsr,:pgmNme,:UDFKey);
    sysDft = UDFDft;
    If sysChg = 'N' and dptChg <> 'Y' and usrChg <> 'Y'
      and curDpt <> 'MIS' and not(jobDes in %list('MANAGER':'SUPERVISOR':'CREDIT MGR'));
      $SetAttribute(UDFVal@:'PR');
    ElseIf dptChg = 'N' and usrChg <> 'Y'
      and curDpt <> 'MIS' and not(jobDes in %list('MANAGER':'SUPERVISOR':'CREDIT MGR'));
      $SetAttribute(UDFVal@:'PR');
    Else;
      $SetAttribute(UDFVal@:'TRQ UL');
    EndIf;
    If curDpt <> 'MIS' and not(jobDes in %list('MANAGER':'SUPERVISOR':'CREDIT MGR'));
      $SetAttribute(usrChg@:'PR');
    Else;
      $SetAttribute(usrChg@:'TRQ UL');
    EndIf;
    $SetAttribute(dptChg@:'PR');
  Else;
    Exec SQL Select UDFVal,usrCnf Into :UDFVal, :dptChg From UDFDTL
             Where (UDFDpt,UDFUsr,pgmNme,UDFKey) = (:UDFDpt,'',:pgmNme,:UDFKey);
    DptDft = UDFDft;
    sysDft = '';
    $SetAttribute(UDFVal@:'TRQ UL');
    If curDpt <> 'MIS' and not(jobDes in %list('MANAGER':'SUPERVISOR':'CREDIT MGR'));
      $SetAttribute(dptChg@:'PR');
    Else;
      $SetAttribute(dptChg@:'TRQ UL');
    EndIf;
    $SetAttribute(usrChg@:'ND PR');
  EndIf;

  RRN1 += 1;
  Write SFL;

End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(UDFDTLF3); // **change
    Open UDFDTLF3; // **change
  EndIf;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNmeH=psdsPgmNam;

  mde='Revise';

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$NextFunctionKeys(fncDs);

  // get the program description
  Exec SQL Select des Into :pgmDes From PGMMST Where pgmNme = :pgmNme;

  // get the current users department and job description
  Exec SQL Select acDept,acJobD Into :curDpt,:jobDes From accesspf Where acUPrf = :User;

  // If being run for a user, get thier name, set column headers and attribute fields, otherwise set up for a department
  If UDFUsr <> ' ';
    usr = UDFUsr;
    title1 = '      User';
    title2 = 'Dept Default';
    title3 = 'System Default';
    $SetAttribute(title3@:'WHT UL');
    $SetAttribute(title3nu@:'WHT');
    Exec SQL Select acDept,acFNam Concat ' ' Concat acLNam Into :usrDpt,:usrNme From accesspf Where acUPrf = :UDFUsr;
  Else;
    usr = UDFDpt;
    title1 = 'Department';
    title2 = 'System Default';
    title3 = '';
    $SetAttribute(title3@:'ND');
    $SetAttribute(title3nu@:'ND');
    usrNme = '';
  EndIf;

  LoadSFL();

End-Proc;
