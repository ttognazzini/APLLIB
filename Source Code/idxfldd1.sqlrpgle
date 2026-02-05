**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Index Field List

Dcl-F IDXFLDF1 WorkStn SFile(SFL1:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,IDXFLDD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,IDXFLDD1PR
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR

Dcl-S RRN1 Like(OutRRN1);
Dcl-S LastRRN Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);
Dcl-S Where Char(5); // used to change the first where to an and after the first use

Dcl-S SchSav Like(SchVal);

Dcl-S Option  like(APLDCT.Option);
Dcl-S idxUni  like(APLDCT.idxUni);
Dcl-S savUni  like(APLDCT.idxUni);
Dcl-S savTxt  like(APLDCT.idxTxt);

Dcl-S sqlStm  varchar(5120);
Dcl-S orderBy varchar(1024);

Dcl-S dataEntered Ind;
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

// if you do not have a filter screen you must define your own filterDs with the sort code
Dcl-Ds filterDs qualified;
  srtCde  like(APLDCT.srtCde);
End-Ds;

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(key);

// Globals for parameters
Dcl-S pmrFleLib Like(APLDCT.fleLib);
Dcl-S pmrFleNme Like(APLDCT.fleNme);
Dcl-S pmrIdxLib Like(APLDCT.idxLib);
Dcl-S pmrIdxNme Like(APLDCT.idxNme);

// set default SQL options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Mainline, Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('IDXFLDD1');
    pmr1FleLib Like(APLDCT.fleLib) const;
    pmr1FleNme Like(APLDCT.fleNme) const;
    pmr1IdxLib Like(APLDCT.IdxLib);
    pmr1IdxNme Like(APLDCT.IdxNme);
    pmrOption Like(Option);
    pmrKeyPressed Like(keyPressed);
    pmrSchVal like(APLDCT.schVal) options(*nopass);
  End-Pi;

  // Sets options based on parameters
  pmrFleLib = pmr1FleLib;
  pmrFleNme = pmr1FleNme;
  pmrIdxLib = pmr1IdxLib;
  pmrIdxNme = pmr1IdxNme;
  If %Parms >= 5;
    Option = pmrOption;
  EndIf;

  // Figure out authority stuff, downgrade option if higher than allowed, set option if 0
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  // if a search value was passed, force it into the search parameter
  If %Parms>=4 and %addr(pmrSchVal)<> *null;
    schVal=pmrSchVal;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' or KeyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F4';
      Prompt();
    ElseIf keyPressed = 'F5';
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F24';
      fncKeys=$nextFunctionKeys(fncDs);
    ElseIf keyPressed = 'PAGEUP';
    ElseIf keyPressed = 'PAGEDOWN';
      outRrn1 = rrn1;
    ElseIf ValidateScreen();
      Iter;
    Else;
      UpdateScreen();
      if not dataEntered;
        leave;
      EndIf;
    EndIf;

  EndDo;

  Close IDXFLDF1;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers if number of parms changed
  If %Parms >=5 ;
    pmrKeyPressed=KeyPressed;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
// **CHANGE onyl if the big/small and/or number of views change
Dcl-Proc DisplayScreen;

  if outrrn1 <= 0;
    outRrn1 = 1;
  elseif outrrn1 > rrn1;
    outrrn1 = rrn1;
  EndIf;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  // **CHANGE change the screens based on the size and view options
  Write FOOTER;
  ExFmt SFLCTL1;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // Set the initial SFL position to the one the cursor is on or the top
  // if page down was pressed and the cursor is not on a SFL row set to bottom
  If Keypressed='PAGEDOWN' and CsrRRN1=0 and EOF;
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
    $getFieldLocation(PgmNme:csrFld:outRow:OutCol:*omit:CSRRCD);
  EndIf;

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  SetAttributes();

  dataEntered=*off;

End-Proc;


// Set Field Attributes
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
    FldAtrCpy = *allx'A2';    // @PrWht
    $SetAttribute(frmKeys@:'');
  Else;
    FldAtrCpy = *allx'A7';    // @PrND
  EndIf;

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes, for lists normally just the key field has to be changed,
// if it updates anything it needs to be added
Dcl-Proc UpdateScreen;
  Dcl-s fleMstIdn like(APLDCT.fleMstIdn);
  Dcl-s fleIdxIdn like(APLDCT.fleIdxIdn);
  Dcl-s fleFldIdn like(APLDCT.fleFldIdn);
  Dcl-s idxFldIdn like(APLDCT.idxFldIdn);
  Dcl-s i packed(5);
  Dcl-s seq like(APLDCT.idxSeq);

  // Check for entries on the first line and process them
  If line1<>line1Defaults;
    eval sflFields=line1;
    eval pos=sflFields;
    dataEntered = *on;
    SetSrtCde();
    Clear line1;
  EndIf;

  // turn on data entered if any of the header fields are changed
  if savTxt <> idxtxt or savUni <> idxUni;
    dataEntered = *on;
  EndIf;

  // get File master id
  Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme);

  // Update the actual index file

  // Create/Copy
  If Option in %list('1':'3');
    Exec SQL
    Insert Into FLEIDX
          ( idxLib, idxNme, fleMstIdn, flelib, fleNme, idxtxt, idxUni,
            CrtDtm, CrtUsr, CrtJob, CrtPgm,
            MntDtm, MntUsr, MntJob, MntPgm)
    Values(:idxLib,:idxNme,:fleMstIdn,:pmrFleLib,:pmrFleNme,:idxTxt,:IDXUNI,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    Option = '2';
    If sqlState > '02';
      $ErrorMessage('':'Error index not added.');
    EndIf;

  // Inactivate
  ElseIf Option = '4';
    Exec SQL
      Update FLEIDX
      Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
        = ('0', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where (idxLib,idxNme) = (:idxLib,:idxNme);
    If sqlState > '02';
      $ErrorMessage('':'Error indedx not deleted.');
    EndIf;

  // Rename
  ElseIf Option = '7';
    Exec SQL
      Update IDXFLD
      Set   (idxLib,idxNme) = (:idxLib,:idxNme)
      Where (idxLib,idxNme) = (:pmrIdxLib,:pmrIdxNme);
    Exec SQL
      Update FLEIDX
      Set   (idxLib,idxNme, MntDtm, MntUsr, MntJob, MntPgm)
         = (:idxLib,:idxNme, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where (idxLib,idxNme) = (:pmrIdxLib,:pmrIdxNme);
    If sqlState > '02';
      $ErrorMessage('':'Error, index not renamed.');
    EndIf;

  // ReActivate
  ElseIf Option = '13';
    Exec SQL
    Update FLEIDX
    Set (AcvRow, MntDtm, MntUsr, MntJob, MntPgm)
      = ('1', Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
    Where (idxLib,idxNme) = (:idxLib,:idxNme);
    If sqlState > '02';
      $ErrorMessage('':'Error index not reactivated.');
    EndIf;

  // Update
  ElseIf Option = '2';
    Exec SQL
      Update FLEIDX
      Set ( idxTxt, idxUni, MntDtm, MntUsr, MntJob, MntPgm)
        = (:idxTxt,:idxUni, Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam)
      Where (idxLib,idxNme) = (:idxLib,:idxNme);
    If sqlState > '02';
      $ErrorMessage('':'Error, index not updated.');
    EndIf;

  EndIf;

  // update the Seq numbers from the SFL
  for i = 1 to numberOfRows;
    chain i sfl1;
    if %found;
      if savSeq <> idxSeq;
        dataEntered = *on;
      EndIf;
    if idxSeq = 0;
        exec SQL delete from IDXFLD where (idxLib,idxNme,idxfld) = (:idxLib,:idxNme,:fldNme);
      else;
        // get index and field id's
        Exec Sql select fleIdxIdn into :fleIdxIdn from FLEIDX where (idxLib,idxNme) = (:idxLib,:idxNme);
        Exec Sql select fleFldIdn into :fleFldIdn from FLEFld where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);
        // update/write the record
        exec SQL update IDXFLD set idxSeq = :idxSeq where (idxLib,idxNme,idxFld) = (:idxLib,:idxNme,:fldNme);
        if sqlstate >= '02';
          exec SQL insert into IDXFLD
                 (idxLib, idxNme, idxFld, idxSeq, fleIdxIdn, fleLib, fleNme, fleFldIdn,
                  CrtDtm, CrtUsr, CrtJob, CrtPgm,
                  MntDtm, MntUsr, MntJob, MntPgm)
          Values(:idxLib,:idxNme,:fldNme,:idxseq,:fleIdxIdn,:pmrFleLib,:pmrFleNme,:fleFldIdn,
                  Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
                  Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
        EndIf;
      EndIf;
    EndIf;
  EndFor;

  // resequence the sequence numbers by 10
  Seq = 0;
  Exec SQL declare reSeqCrs cursor for
    Select idxFldIdn from IDXFLD where (idxLib,idxNme) = (:idxLib,:idxNme) order by idxSeq;
  Exec SQL Open reSeqCrs;
  Exec SQL fetch next from reSeqCrs into :idxFldIdn;
  dow sqlstate < '02';
    seq += 10;
    Exec SQL update IDXFLD set idxSeq = :seq where idxFldIdn = :idxFldIdn;
    Exec SQL fetch next from reSeqCrs into :idxFldIdn;
  EndDo;
  Exec SQL close reSeqCrs;

  // save the header fields to test for change
  savTxt = idxTxt;
  savUni = idxUni;

  //Rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  Error = *Off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From FLEIDX
    Where (idxLib,idxNme) = (:idxLib,:idxNme);
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and found;
    $ErrorMessage('':'Error, index already exists.':error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and not found;
    $ErrorMessage('':'Error, index not found.':error);
  EndIf;

  // Validate Rename
  If Option = '7'  and (idxLib <> pmrIdxLib or idxNme <> pmrIdxNme);
  // code rename edits here,

  // Validate DeActivate
  ElseIf Option = '4';
  // code inactivation edits here,

  EndIf;

  // Check Required Data

  // on entry or copy validate the key fields
  if option in %list('1':'3');
    if not #$isLib(idxLib);
      $ErrorMessage('':'Error, invalid libary.':error:idxLib@:'IdxLib':outRow:outCol:psDsPgmNam);
    EndIf;
    if idxNme = '';
      $ErrorMessage('':'Error, missing index name.':error:idxNme@:'IdxNme':outRow:outCol:psDsPgmNam);
    EndIf;
    if %subst(idxNme:1:6) <> %subst(fleNme:1:6);
      $ErrorMessage('':'Error, index name should start with the file name and then append a pstfix.'
                    :error:idxNme@:'IdxNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;


  // make sure the primary key value is correct, Auto prompt first if not valid, handles ?
  pmEnmVal = '';
  pmEnmDes = idxUniD;
  Callp(e) DCTVALBP('APLDCT':'IDXUNI':pmEnmVal:pmEnmDes:pmKeyPressed);
  If idxUniD <> pmEnmDes;
    idxUniD = pmEnmDes;
    error=*on;
  EndIf;
  If not $ValidEnmDes(#$upify(idxUniD):'APLDCT':'idxUni');
    $ErrorMessage('':'Error - Index Type not valid.':error:idxUniD@:'idxUniD':outRow:outCol:psDsPgmNam);
  EndIf;
  Exec SQL select enmVal into :idxUni from DCTVAL where (dctNme,fldNme,enmDes) = ('APLDCT','IDXUNI',:idxUniD);

  Return error;

End-Proc;


// Load the SFL
// *** Do not change anything in here ***
Dcl-Proc LoadSFL;

  BuildSQLStatement();


  // Clear all SFL's
  LastRRN = 0;
  SflClr = *on;
  Write SFLCTL1;
  SflClr = *off;
  SflDsp = *on;

  // Load SFL
  Clear Dta;
  Exec SQL Prepare sqlStm4 From :sqlStm;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch Next from SQLCrs4 Into :sflFields;
  rrn1=0;
  Dow SQLState < '02';
    // if the Seq number is 999999, make 0, if a field is not selected it uses 9999999 so it sorts to the bottom,
    // but we wnat them to display as empty.
    If idxSeq = 9999999;
      idxSeq = 0;
    EndIf;
    RRN1 += 1;
    Write SFL1;
    Exec SQL Fetch Next from SQLCrs4 Into :sflFields;
  EndDo;
  Exec SQL Close SQLCrs4;

  Clear positionToKey;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    SflDsp  = *Off;
  EndIf;

End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;
  Dcl-s innerSqlStm varchar(2000);

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %Trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    currentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  innerSqlStm = '+
  Select +
    substr(FLEFLD.fleLib,1,10) || substr(FLEFLD.fleNme,1,10) || substr(FLEFLD.fldNme,1,10) key, +
    FLEFLD.fleLib, +
    FLEFLD.fleNme, +
    coalesce(idxSeq,0) savSeq, +
    coalesce(idxSeq,9999999) idxSeq, +
    priKey, +
    FLEFLD.fldNme, +
    coltxt, +
    case when FldTyp in (''TIMESTAMP'',''DATE'',''TIME'',''INTEGER'',''SMALLINT'', +
            ''BIGINT'',''REAL'',''DOUBLE PRECISION'') +
       then FldTyp +
       When FldTyp = ''VARCHAR'' +
       Then Trim(FldTyp) concat ''('' +
            concat trim(Char(FldLen)) Concat '') ALLOCATE('' +
            concat trim(FldAlc) concat '')'' +
       When FldTyp in (''FLOAT'',''NUMERIC'',''DECIMAL'') +
       Then Trim(FldTyp) concat ''('' +
            concat trim(Char(FldLen)) Concat '','' +
            concat trim(Char(FldScl)) concat '')'' +
       Else Trim(FldTyp) concat ''('' concat Trim(Char(FldLen)) concat '')'' +
    end Typ, +
    coalesce(enm.enmDes,''N/A'') FldEnmD, +
    alwNul +
  From FLEFLD +
  left Join IDXFLD on (IDXFLD.fleLib,IDXFLD.fleNme,IDXFLD.idxFld,IDXFLD.idxLib,IDXFLD.idxNme) +
                    = (FLEFLD.fleLib,FLEFLD.fleNme,FLEFLD.fldNme,'''+%trim(idxLib) + ''',''' +%trim(idxNme) + ''') +
  Join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme) +
  Join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (fleMst.dctNme,FLEFLD.FldNme) +
  left join DCTVAL as enm on enm.DctNme=''APLDCT'' and enm.FldNme=''FLDENM'' +
        and enm.EnmVal=case when DCTFLD.fldEnm = ''Y'' then ''Y'' else ''N'' end +
  where FLEFLD.acvRow = ''1'' or coalesce(idxfld.acvRow,''0'') = ''1''';


  sqlStm = 'Select * from (' + innersqlstm + ') +
            Where (fleLib,fleNme) = (''' + %trim(pmrFleLib) + ''',''' + %trim(pmrFleNme) + ''')';
  where = 'and';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' and ' + $BuildSearch(pgmNme:SchVal);
  EndIf;

  // handle position to if any position to values are entered
  If pos<>posDefault;
    PositionSFL();
    outRrn1 = currentRow + 1;
  Else;
    outRrn1 = 1;
  EndIf;

  // Add order by
  sqlStm += ' ' + orderBy;

  // Get total number of records for selected data
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;
  Exec SQL GET DIAGNOSTICS :numberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt status description
  If CsrFld = 'IDXUNID';
    Callp DCTVALDP('APLDCT':'IDXUNI':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      idxUniD = pmEnmDes;
    EndIf;

  //* Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


//This routine gets run when the program is first started
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(IDXFLDF1); // **change
    Open IDXFLDF1; // **change
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow=0;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  idxLib = pmrIdxLib;
  idxNme = pmrIdxNme;

  // Get the file name and alias/table name
  Exec SQL
  Select fleDes, tblNme, FLEMST.dctNme, coalesce(des,''),
         coalesce(prd.enmDes,''),coalesce(chg.enmDes,''),coalesce(sts.enmDes,'')
  Into  :fleDes,:tblNme,:dctNme,       :dctDes,
        :prdFle,                :chgScd,                 :fleSts
  From  FLEMST
  left join DCTMST on DCTMST.dctNme = FLEMST.dctNme
  left join DCTVAL as prd on prd.DctNme='APLDCT' and prd.FldNme='PRDFLE'
    and prd.EnmVal=coalesce(case when prdFle = 'Y' then 'Y' else 'N' end,'')
  left join DCTVAL as chg on chg.DctNme='APLDCT' and chg.FldNme='CHGSCD'
    and chg.EnmVal=coalesce(case when chgScd = 'Y' then 'Y' else 'N' end,'')
  left join DCTVAL as sts on (sts.DctNme,sts.FldNme,sts.enmVal) = ('APLDCT','FLESTS',fleSts)
  Where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme)
  Fetch First Row Only;

  // get the index header attributes
  Exec SQL
    Select idxTxt, coalesce(uni.enmDes,''), idxUni
    Into  :idxTxt, :idxUniD, :idxUni
    from FLEIDX
    left join DCTVAL as uni on uni.DctNme='APLDCT' and uni.FldNme='IDXUNI' and uni.EnmVal = idxUni
    Where (idxLib,idxNme) = (:idxLib,:idxNme);

  // save the header fields to test for change
  savTxt = idxTxt;
  savUni = idxUni;

  // Build file description line, (library/file) table name, description
  desLine = %trim(pmrFleLib)+'/'+%trim(pmrFleNme);

  // **CHANGE positition cursor to the perfered field
  $getFieldLocation(PgmNme:'FldNme1':outRow:OutCol);

  //* Set initial defaults
  ProtectCpy = *off;
  ProtectKey = *on;
  ProtectDta = *on;
  $GetFieldLocation(psdsPgmNam:'SCHVAL':outRow:outCol);
  Mde = 'Display';

  //* allow key field changes on create
  If Option = '1';
    Mde = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    idxLib = pmrfleLib;
    idxNme = fleNme;
    idxTxt = %trim(fleDes) + ' -';
    $GetFieldLocation(psdsPgmNam:'IDXNME':outRow:outCol);

  //* allow key field changes on revise
  ElseIf Option = '2';
    Mde = 'Update';
    ProtectDta = *off;

  // allow key field changes on copy
  ElseIf Option = '3';
    Mde = 'Copy';

    ProtectCpy = *on;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'IDXNME':outRow:outCol);

  //* disallow key field changes on delete
  ElseIf Option = '4';
    Mde = 'DeActivate';

  //* allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'IDXNME':outRow:outCol);
    Mde = 'Rename';
    ProtectCpy = *on;
    ProtectKey = *off;

  //* disallow key field changes on reactivate
  ElseIf Option = '13';
    Mde = 'ReActivate';

  EndIf;

  // Set filter defaults
  filterDs.SrtCde = 1;
  SetAttributes();

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:*omit:132);
  fncKeys=$nextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/copy QSRC,IDXFLDD1_2
