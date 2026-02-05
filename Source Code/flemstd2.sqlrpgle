**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// File Master Maintenance

Dcl-F FLEMSTF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTD2_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEMSTD2PR // Always include the prototype for the current program
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR
/Copy QSRC,DCTMSTBPPR
/Copy QSRC,DCTMSTD1PR
/Copy QSRC,FLEFLDB1PR // refresh file statuses
/Copy QSRC,FLEMSTD3PR // Copy Fields


// Data structure used to read SQL into
Dcl-Ds dta Qualified;
  fleDes Like(APLDCT.fleDes);
  tblNme Like(APLDCT.tblNme);
  prdFle Like(APLDCT.prdFle);
  chgScd Like(APLDCT.chgScd);
  dctNme Like(APLDCT.dctNme);
End-Ds;

// Added for each key because the one passed to the program can be changed for a copy
Dcl-S pmrFleLib Like(APLDCT.FleLib);
Dcl-S pmrFleNme Like(APLDCT.FleNme);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Dcl-S chgScd like(APLDCT.chgScd);
Dcl-S prdFle like(APLDCT.prdFle);

Dcl-Ds DspVal ExtName('FLEMSTF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program loop
// **CHANGE the parameters will change as well as any additional function keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTD2');
    pmr1FleLib Like(APLDCT.FleLib);
    pmr1FleNme Like(APLDCT.FleNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrFleLib=pmr1FleLib;
  pmrFleNme=pmr1FleNme;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
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
      If not UpdateScreen();
        Leave;
      EndIf;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  pmrOption = Option;
  pmr1FleLib = fleLib; // set the return key in case a new entry was added or copied
  pmr1FleNme = fleNme; // set the return key in case a new entry was added or copied
  Close FLEMSTF2;

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
  Dcl-S pmDctDes Like(APLDCT.Des);
  Dcl-S pmDctNme Like(APLDCT.DctNme);

  Error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From FLEMST
    Where (fleLib,fleNme) = (:fleLib,:fleNme);

  // Make sure file name is 6 characters
  If (Option = '1' or Option = '3' or Option = '7') and %len(%trim(fleNme)) <> 6;
    $ErrorMessage('':'Error file name must be 6 characters.':Error
                    :fleNme@:'fleNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and found;
    $ErrorMessage('':'Error Library/File already exists.':Error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  //  If Option <> '1' and Option <> '3' and Option <> '7' and not found;
  //    $ErrorMessage('':'Error Library/File does not exist.':error);
  //  EndIf;

  // Validate Rename
  If Option = '7'  and (fleNme <> pmrFleNme or fleLib <> fleLib);
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Valid File Library
  If fleLib = '' or not #$ISLIB(fleLib);
    $ErrorMessage('':'Invalid Library Name':Error:fleLib@:'fleLib':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid File Name
  If fleNme = *blanks;
    $ErrorMessage('':'Invalid File Name':Error:fleNme@:'fleNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid File Description
  If fleDes = *Blanks and not ProtectDta;
    $ErrorMessage('':'Missing file description.':Error:fleDes@:'fleDes':outRow:outCol:psDsPgmNam);
  EndIf;

  // Valid File Alias
  If tblNme = *Blanks and not ProtectDta;
    $ErrorMessage('':'Table name requried, use F1 if you need help.':Error:tblNme@:'tblNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the active value is correct, Auto prompt first if not valid, handles ?
  If Option = '2';
    pmEnmVal = '';
    pmEnmDes = prdFleD;
    Callp(e) DCTVALBP('APLDCT':'PRDFLE':pmEnmVal:pmEnmDes:pmKeyPressed);
    If prdFleD <> pmEnmDes;
      prdFleD = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(prdFleD):'APLDCT':'prdFle');
      $ErrorMessage('DCT1002':'':Error:prdFleD@:'prdFleD':outRow:outCol:psDsPgmNam);
    EndIf;
    Exec SQL select enmVal into :prdFle from DCTVAL where (dctNme,fldNme,EnmDes) = ('APLDCT','PRDFLE',:prdFleD);
  EndIf;

  // make sure the active value is correct, Auto prompt first if not valid, handles ?
  If Option = '2';
    pmEnmVal = '';
    pmEnmDes = chgScdD;
    Callp(e) DCTVALBP('APLDCT':'CHGSCD':pmEnmVal:pmEnmDes:pmKeyPressed);
    If chgScdD <> pmEnmDes;
      chgScdD = pmEnmDes;
      Error=*on;
    EndIf;
    If not $ValidEnmDes(#$UPIFY(chgScdD):'APLDCT':'chgScd');
      $ErrorMessage('DCT1002':'':Error:chgScdD@:'chgScdD':outRow:outCol:psDsPgmNam);
    EndIf;
    Exec SQL select enmVal into :chgScd from DCTVAL where (dctNme,fldNme,enmDes) = ('APLDCT','CHGSCD',:chgScdD);
  EndIf;

  // make sure the dictionary name is correct, Auto prompt first if not valid, handles ?
  If Option = '2';
    pmDctNme = dctNme;
    Callp(e) DCTMSTBP(pmDctNme:pmDctDes:pmKeyPressed);
    If dctNme <> pmDctNme;
      dctNme = pmDctNme;
      Error=*on;
    EndIf;
    found = *off;
    Exec SQL select '1' into :found from DCTMST where dctNme = :dctNme;
    If not found;
      $ErrorMessage('':'Invalid dictionary name.':Error:dctNme@:'dctNme':outRow:outCol:psDsPgmNam);
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

  Eval-Corr dta = DspVal;
  error = *off;

  // Perform updates if no error

  // Read error
  If %error;
    $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);

    // Create/Copy
  ElseIf Option in %list('1':'3');
    Exec SQL
    Insert Into FLEMST
          ( flelib, fleNme, fleDes, tblNme, prdFle, chgScd, dctNme,
            CrtDtm, CrtUsr, CrtJob, CrtPgm,
            MntDtm, MntUsr, MntJob, MntPgm)
    Values(:fleLib,:fleNme,:fleDes,:tblNme,:prdFle,:chgScd,:dctNme,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    Else;
      AddDefaults();
      If Option = '3';
        FLEMSTD3(fleLib:fleNme:fleLibCpy:fleNmeCpy:Option:keyPressed);
      EndIf;
      Option = '2';
    EndIf;

    // Inactivate
  ElseIf Option = '4';
    Exec SQL
    Update FLEMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;


    // Rename
  ElseIf Option = '7';
    Exec SQL
    Update FLEMST
    Set   (fleLib,fleNme) = (:fleLib,:fleNme)
    Where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme);
    Exec SQL
      Update FLEMST
      Set (fleLib, fleNme, MntDtm, MntUsr, MntJob, MntPgm)
    = (:fleLib, :fleNme, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update FLEMST
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update FLEMST
      Set ( fleDes, tblNme, prdFle, chgScd, dctNme, MntDtm, MntUsr, MntJob, MntPgm)
        = (:fleDes,:tblNme,:prdFle,:chgScd,:dctNme, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where (fleLib,fleNme) = (:fleLib,:fleNme);
    If sqlState > '02';
      $ErrorMessage(#$SQLMSGID(sqlCode):sqlErrmc:error);
    EndIf;

  EndIf;

  If not error;
    FLEFLDB1(pmrFleLib:pmrFleNme:'N':'N');
  EndIf;

  Return error;

End-Proc;


Dcl-Proc AddDefaults;
  Dcl-S fleMstIdn like(APLDCT.fleMstIdn);
  Dcl-S idnFld like(APLDCT.fldNme);
  Dcl-S fldNmeSql like(APLDCT.fldNmeSql);
  Dcl-S colTxt like(APLDCT.colTxt);
  Dcl-S colHdg like(APLDCT.colHdg);
  Dcl-S idxNme like(APLDCT.idxNme);
  Dcl-S fleIdxIdn like(APLDCT.fleIdxIdn);
  Dcl-S fleFldIdn like(APLDCT.fleFldIdn);

  // Get file id
  Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // see if there is a dictionary entry for the primary id field, if not add one
  found = *off;
  idnFld = %trim(fleNme) + 'IDN';
  Exec SQL Select '1' into :found from DCTFLD where (dctNme,fldNme) = (:dctNme,:idnFld) limit 1;
  If not found;
    colTxt = %trim(fleDes) + ' Id';
    colHdg = BuildColHdg(colTxt);
    fldNmeSql = %scanrpl(' ':'_':%trim(%lower(colTxt)));
    Exec SQL Insert into DCTFLD
           (dctNme, fldNme, fldNmeSQL, fldTyp, colTxt, colHdg,
            CrtDtm, CrtUsr, CrtJob, CrtPgm,
            MntDtm, MntUsr, MntJob, MntPgm)
    Values(:dctNme,:idnFld,:fldNmeSql,'BIGINT',:colTxt,:colHdg,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  EndIf;

  // add default fields that should be in all files
  AddField('1': 10:'ACVROW':fleMstIdn);
  AddField('2': 20:idnFld:fleMstIdn);
  AddField('5': 30:'CRTDTM':fleMstIdn);
  AddField('5': 40:'CRTUSR':fleMstIdn);
  AddField('5': 50:'CRTJOB':fleMstIdn);
  AddField('5': 60:'CRTPGM':fleMstIdn);
  AddField('5': 70:'MNTDTM':fleMstIdn);
  AddField('5': 80:'MNTUSR':fleMstIdn);
  AddField('5': 90:'MNTJOB':fleMstIdn);
  AddField('5':100:'MNTPGM':fleMstIdn);

  // Add default index for the IDN
  idxNme = %trim(flenme) + 'IDN';
  Exec SQL insert into FLEIDX
        ( idxLib, idxNme, fleMstIdn, fleLib, fleNme, idxTxt, idxUni,
          CrtDtm, CrtUsr, CrtJob, CrtPgm,
          MntDtm, MntUsr, MntJob, MntPgm)
  Values(:fleLib, :idxNme,:fleMstIdn,:fleLib,:fleNme,substr(trim(:fleDes) || ' - Id',1,50),'Y',
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  // Get Id for the file index and file field
  Exec SQL Select fleIdxIdn  into :fleIdxIdn from FLEIDX Where (idxLib, idxNme) = (:fleLib,:idxNme);
  Exec SQL Select fleFldIdn  into :fleFldIdn from FLEFLD Where (fleLib, fleNme, fldNme) = (:fleLib,:FleNme,:idnFld);
  // Add index field entry
  Exec SQL insert into IDXFLD
        ( idxLib, idxNme, idxFld, idxSeq, fleIdxIdn, fleLib, fleNme, fleFldIdn,
          CrtDtm, CrtUsr, CrtJob, CrtPgm,
          MntDtm, MntUsr, MntJob, MntPgm)
  Values(:fleLib,:idxNme,:idnFld, 1,     :fleIdxIdn,:fleLib,:fleNme,:fleFldIdn,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);

End-Proc;


Dcl-Proc AddField;
  Dcl-Pi *n;
    fldLvl like(APLDCT.fldLvl) const;
    fldSeq like(APLDCT.fldSeq) value;
    fldNme like(APLDCT.fldNme) const;
    fleMstIdn like(APLDCT.fleMstIdn);
  End-Pi;
  Exec SQL Insert into FLEFLD ( fleLib, fleNme, fldNme, fleMstIdn, fldLvl, fldSeq)
                        values(:fleLib,:fleNme,:fldNme,:fleMstIdn,:fldLvl,:fldSeq);
End-Proc;


// build column heading from column text
Dcl-Proc BuildColHdg;
  Dcl-Pi *n like(APLDCT.colHdg);
    colTxt like(APLDCT.colTxt);
  End-Pi;
  Dcl-S colHdg1 char(20);
  Dcl-S colHdg2 char(20);
  Dcl-S colHdg3 char(20);
  Dcl-S word Varchar(20) Dim(20);
  Dcl-S cnt packed(3);

  // split coltxt out by words, then figure out how many words there are
  word = %split(colTxt);
  For cnt = 1 To 20;
    If word(cnt) = ' ';
      cnt -= 1;
      Leave;
    EndIf;
  EndFor;

  // split the words to the column headings
  colHdg1 = '';
  colHdg2 = '';
  colHdg3 = '';
  If cnt = 1;
    colHdg1=word(1);
  ElseIf cnt = 2;
    colHdg1=word(1);
    colHdg2=word(2);
  ElseIf cnt = 3;
    colHdg1=word(1);
    colHdg2=word(2);
    colHdg3=word(3);
  ElseIf cnt = 4;
    colHdg1=word(1) + ' ' + word(2);
    colHdg2=word(3);
    colHdg3=word(4);
  ElseIf cnt = 5;
    colHdg1=word(1) + ' ' + word(2);
    colHdg2=word(3) + ' ' + word(4);
    colHdg3=word(5);
  ElseIf cnt = 6;
    colHdg1=word(1) + ' ' + word(2);
    colHdg2=word(3) + ' ' + word(4);
    colHdg3=word(5) + ' ' + word(6);
  ElseIf cnt = 7;
    colHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
    colHdg2=word(4) + ' ' + word(5);
    colHdg3=word(6) + ' ' + word(7);
  ElseIf cnt = 8;
    colHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
    colHdg2=word(4) + ' ' + word(5) + ' ' + word(6);
    colHdg3=word(7) + ' ' + word(8);
  ElseIf cnt >= 9;
    colHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
    colHdg2=word(4) + ' ' + word(5) + ' ' + word(6);
    colHdg3=word(7) + ' ' + word(8) + ' ' + word(9);
  EndIf;

  Return colHdg1 + colHdg2 + colHdg3;

End-Proc;


// Handle prompt key (F4)
// **CHANGE, this needs to be updated to handle any promptable fields. Follow the pattern already set here.
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S pmDctNme Like(APLDCT.dctNme);
  Dcl-S pmOption Like(Option);

  // Prompt status description
  If CsrFld = 'PRDFLED' and Option = '2';
    Callp DCTVALDP('APLDCT':'PRDFLE':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      prdFleD = pmEnmDes;
    EndIf;

    // Prompt change scheduled option
  ElseIf CsrFld = 'CHGSCDD' and Option = '2';
    Callp DCTVALDP('APLDCT':'CHGSCD':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      chgScdD = pmEnmDes;
    EndIf;

    // Prompt dictionary name
  ElseIf CsrFld = 'DCTNME' and Option = '2';
    pmOption = '1';
    Callp DCTMSTD1(pmDctNme:pmOption:keyPressed);
    If keyPressed = 'ENTER';
      dctNme = pmDctNme;
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
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
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
    $GetFieldLocation(psdsPgmNam:'fleLib':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    mde = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'fleDes':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    mde = 'Copy';
    ProtectCpy = *off;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4';
    mde = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    mde = 'Display';
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);
    mde = 'Rename';
    ProtectCpy = *off;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);
    mde = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'fleNme':outRow:outCol);
    mde = 'Unknown';
  EndIf;

  If not %open(FLEMSTF2);
    Open FLEMSTF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  fleLibCpy = pmrFleLib;
  fleNmeCpy = pmrFleNme;

  // Display and process data
  Clear dta;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  Exec SQL
    Select fleDes, tblNme, prdFle, chgScd, dctNme Into :dta
    From FLEMST
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
  // a description or table name is not found, try to get ti form the object
  If dta.tblNme = '';
    Exec SQL Select lcase(table_name) into :dta.tblNme
       from QSYS2/SYSTABLES
       where (base_table_schema, base_table_name) = (:fleLib,:fleNme)
         and table_type = 'A'
       fetch first row only;
  EndIf;
  If dta.fleDes = '';
    Exec SQL Select cast(table_text as char(50)) into :dta.fleDes
       from QSYS2/SYSTABLES
       where (table_schema, table_name) = (:fleLib,:fleNme)
         and table_type<>'A'
       fetch first row only;
  EndIf;

  Eval-Corr DspVal = dta;

  // these fields are not on the screen so they have to be moved manually
  prdFle = dta.prdFle;
  chgScd = dta.chgScd;

  // get enum descriptions
  Exec SQL select enmDes into :prdFleD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','PRDFLE',:prdFle);
  Exec SQL select enmDes into :chgScdD from DCTVAL where (dctNme,fldNme,enmVal) = ('APLDCT','CHGSCD',:chgScd);

  // If in entry mode set the key value to what ever is passed in and move cursor to the next field
  If Option='1' and pmrfleNme<>'';
    fleLib=pmrFleLib;
    fleNme=pmrFleNme;
    $GetFieldLocation(psdsPgmNam:'fleDes':outRow:outCol);
  EndIf;

End-Proc;
