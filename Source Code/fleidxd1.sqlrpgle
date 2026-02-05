**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// File Indexes List

Dcl-F FLEIDXF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEIDXD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEIDXD1PR
/Copy QSRC,FLEIDXDZPR
/Copy QSRC,FLEIDXB0PR

Dcl-S RRN1 Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);
Dcl-S Where Char(5); // used to change the first where to an and after the first use

Dcl-S SchSav Like(SchVal);
Dcl-Ds filterDsSave Likeds(filterDs);
Dcl-Ds filterDs ExtName('FLEIDXFZ') Qualified Inz End-Ds;

Dcl-S Option  like(APLDCT.Option);
Dcl-S fleIdxIdn  like(APLDCT.fleIdxIdn);

Dcl-S sqlStm  Varchar(5120);
Dcl-S orderBy Varchar(1024);

Dcl-S dataEntered Ind;
Dcl-S Changed     Ind;
Dcl-S Display     Ind;
Dcl-S Selects     Ind;
Dcl-S Maintenance Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selIdxLib Like(APLDCT.idxLib);
Dcl-S selIdxNme Like(APLDCT.idxNme);

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   Char(132);
End-Ds;

// Globals for parameters
Dcl-S pmrFleLib Like(APLDCT.fleLib);
Dcl-S pmrFleNme Like(APLDCT.fleNme);

// set default SQL options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Mainline, Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEIDXD1');
    pmr1FleLib Like(APLDCT.fleLib) const;
    pmr1FleNme Like(APLDCT.fleNme) const;
    pmrIdxLib Like(APLDCT.IdxLib);
    pmrIdxNme Like(APLDCT.IdxNme);
    pmrOption Like(Option);
    pmrKeyPressed Like(keyPressed);
    pmrSchVal like(APLDCT.schVal) options(*nopass);
  End-Pi;

  // Sets options based on parameters
  If %parms >= 1;
    pmrFleLib = pmr1FleLib;
  EndIf;
  If %parms >= 2;
    pmrFleNme = pmr1FleNme;
  EndIf;
  If %parms >= 3;
    pos.idxLib = pmrIdxLib;
  EndIf;
  If %parms >= 4;
    pos.IdxNme = pmrIdxNme;
  EndIf;
  If %parms >= 5;
    Option = pmrOption;
  EndIf;

  // Figure out authority stuff, downgrade option if higher than allowed, set option if 0
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  // if a search value was passed, force it into the search parameter
  If %parms>=4 and %addr(pmrSchVal)<> *null;
    schVal=pmrSchVal;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' or keyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F5';
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F6';
      Add();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F13';
      Filter();
    ElseIf keyPressed = 'F23';
      options=$NextSFLOption(optDs);
    ElseIf keyPressed = 'F24';
      fncKeys=$NextFunctionKeys(fncDs);
    ElseIf keyPressed = 'PAGEDOWN';
      PageDown();
    ElseIf keyPressed = 'PAGEUP';
      PageUp();
    ElseIf ValidateScreen();
      Iter;
    Else;
      UpdateScreen();
      If selected or not dataEntered;
        Leave;
      EndIf;
    EndIf;

  EndDo;

  Close FLEIDXF1;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers if number of parms changed
  If %parms >=5 ;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  // **CHANGE parm numbers if number of parms changed
  If selected;
    If %parms >= 2;
      pmrIdxLib=selIdxLib;
    EndIf;
    If %parms >= 3;
      pmrIdxNme=selIdxNme;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
// **CHANGE onyl if the big/small and/or number of views change
Dcl-Proc DisplayScreen;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  // **CHANGE change the screens based on the size and view options
  Write FOOTER;
  Exfmt SFLCTL;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // Left Justify Option
  Sel1=%trim(Sel1);

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
    $GetFieldLocation(PgmNme:csrFld:outRow:outCol:*omit:CSRRCD);
  EndIf;

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

  dataEntered=*off;

End-Proc;


// Prompt for filters and reload the SFL
// **ChangedFromMassReplace, change the name of the filter program
Dcl-Proc Filter;

  filterDsSave = filterDs;
  FLEIDXDZ(filterDs:keyPressed);

  If keyPressed = 'F3';
  ElseIf keyPressed = 'F12';
    keyPressed = '';
  EndIf;

  If filterDsSave <> filterDs;
    LoadSFL();
  EndIf;

End-Proc;


// Add a new field
Dcl-Proc Add;
  Dcl-S pmIdxLib like(APLDCT.IdxLib);
  Dcl-S pmIdxNme like(APLDCT.idxNme);
  Dcl-S pmOption like(Option);
  Dcl-S pmKeyPressed like(keyPressed);

  pmIdxLib = '';
  pmIdxNme = '';
  pmOption = '1';
  FLEIDXB0(pmrFleLib:pmrFleNme:pmIdxLib:pmIdxNme:pmOption:pmKeyPressed);

  // possition to new field
  pos.IdxLib = pmIdxLib;
  pos.IdxNme = pmIdxNme;
  pos.idxTxt = idxTxt;

  // Refresh screen
  LoadSFL();

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes, for lists normally just the key field has to be changed,
// if it updates anything it needs to be added

Dcl-Proc UpdateScreen;

  // Save the SFL options entered on the current screen
  SaveOptions();

  // If they changed the search term, clear the selected options. This prevents actions being taken on items no
  // longer in the list.
  If schval<>schSav;
    Clear optionsCount;
    Clear optionsArray;
  EndIf;

  // Check for entries on the first line and process them
  If Sel1<>'' or line1<>line1Defaults;
    Sel     = Sel1;
    eval sflFields=line1;
    // Overide option to 8=position to if not entered
    If Sel = '';
      Sel  = '8';
    EndIf;
    If Sel='8'; // In case no fields are populated
      Clear CurrentRow;
    EndIf;
    idxLib = '';
    idxNme = '';
    ProcessLine();
    dataEntered = *on;
    Clear Sel1;
    Clear line1;
  Else;
    // Process saved SFL options
    SortOptions();
    DoW optionsCount>0;
      Clear sflFields;
      fleIdxIdn  = optionsArray(1).key;
      Sel  = optionsArray(1).Option;
      positionToKey=optionsArray(1).key;
      Exec SQL Select idxLib, idxNme into :idxLib, :idxNme from FLEIDX where fleIdxIdn = :fleIdxIdn;
      ProcessLine();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
      PopOptions();
    EndDo;
  EndIf;

  // Rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Process SFL Options
Dcl-Proc ProcessLine;

  // handle position to
  If Sel = '8';
    eval pos=sflFields;
    SetSrtCde();
    LoadSFL();

    // Handle Select
  ElseIf sel='1' and Selects;
    selected=*on;
    selIdxLib=IdxLib;
    selIdxNme=IdxNme;

    // Handle all other options via the B0 program
  ElseIf Sel<>'';
    FLEIDXB0(pmrFleLib:pmrFleNme:idxLib:idxNme:Sel:keyPressed);
    // If adding a new entry, possition to it
    If Sel = '1' and Maintenance;
      pos.idxLib = idxLib;
      pos.idxNme = idxNme;
      pos.idxTxt = idxTxt;
    EndIf;
    // Flag the SFL to reload if not inquiry only and they didn't press F3
    If Sel <> '5' and keyPressed <> 'F3';
      Changed = *on;
    EndIf;
  EndIf;

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S sflRcd packed(5);
  Dcl-S tsAcvRow like(APLDCT.acvRow);

  RRN1  = 1;
  error = *Off;

  // check for entries on the first line
  If Sel1 <>'';
    dataEntered = *on;

    If Sel1>'1' and Sel1 <> '8' and (IdxNme1 = '' or idxLib1 = ' ');
      $ErrorMessage('DCT0001':'':error:IdxNme1@:'IdxNme1':outRow:outCol:psDsPgmNam:idxLib1@);
    EndIf;

    // check record in file
    Sel = Sel1;
    Eval sflFields=line1;

    Clear found;
    Clear tsAcvRow;
    Exec SQL
      Select '1',acvRow Into :found,:tsAcvRow
      From FLEIDX
      Where (fleLib,fleNme,idxLib,idxNme) = (:fleLib,:fleNme,:idxLib,:idxNme)
      Fetch First Row Only;

    // Validate option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the dictionary name must be provided
    ElseIf not #$IN(Sel:'8':'1') and (idxLib = '' or idxNme = '');
      $ErrorMessage('DCT1001':'':error:idxNme1@:'idxNme1':outRow:outCol:psDsPgmNam:idxLib1@);

      // If deleting make sure the row is active
    ElseIf Sel = '4' and tsAcvRow<>'1';
      $ErrorMessage('DCT1004':'':error:idxNme1@:'idxNme1':outRow:outCol:psDsPgmNam);

      // If reinstating make sure the row is inactive
    ElseIf Sel = '13' and tsAcvRow<>'0';
      $ErrorMessage('DCT1013':'':error:Sel1@:'Sel1':outRow:outCol:psDsPgmNam:idxNme1@);

      // If adding make sure the entry does not exist
    ElseIf Sel = '1' and not Maintenance and found;
      $ErrorMessage('DCT1101':'':error:idxNme1@:'idxNme1':outRow:outCol:psDsPgmNam);

      // If any option but add or position to, make sure the entry exists
    ElseIf not #$IN(Sel:'1':'8') and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:idxNme1@:'idxNme1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      If Sel <> '';
        dataEntered = *on;
      EndIf;
      // * validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs)
        or Sel = '1' and Maintenance;
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '4' and acvDes = 'Inactive';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '13' and acvDes <> 'Inactive';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      EndIf;
      Update SFL;
    EndIf;
  EndFor;

  Return error;

End-Proc;


// Load the SFL
// *** Do not change anything in here ***
Dcl-Proc LoadSFL;
  Dcl-S i packed(2);

  BuildSQLStatement();


  // Clear all SFL's
  LastRRN = 0;
  SflClr = *on;
  Write SFLCTL;
  SflClr = *off;
  SflDsp = *on;

  // Add the offest and limit to the statement and read in one screen worth of data
  Clear dta;
  sqlStm += ' Limit ' + %char(SFLPage) + ' Offset ' + %char(CurrentRow);
  Exec SQL Prepare sqlStm4 From :sqlStm;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch SQLCrs4 For :SFLPage rows Into :dta;
  Exec SQL Close SQLCrs4;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If dta(i).idxNme<>'';
      Eval sflFields=dta(i);
      Sel = GetOption(Key);
      RRN1 += 1;
      Write SFL;
      // if a position to is provided move the cursor to this entry
      If positionToKey=dta(i).key;
        $GetFieldLocation(pgmNme:'SEL':outRow:outCol);
        outRow+=i-1; // required to move to the correct SFL line
      EndIf;
    EndIf;
  EndFor;

  RRN1SV = RRN1;
  OutRRN1 = 1;
  Clear positionToKey;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    SflDsp  = *Off;
  EndIf;

  // This message is for the number of entries, paging information and filters, it is not shown if there are no records
  If numberOfRows<>0;
    $ErrorMessage('':$BuildSFLMessage(NumberOfRows:totalNumberOfRows:SFLPage:CurrentRow:RRN1));
  EndIf;

End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  sqlStm = ' +
  Select *  +
  From ( +
    Select +
      fleIdxIdn key, +
      fleLib, +
      fleNme, +
      idxLib, +
      idxNme, +
      idxTxt, +
      coalesce(uni.enmDes,''Not Unique'') idxUniD, +
      coalesce(acv.enmDes,'''') acvDes +
    from FLEIDX +
    left join DCTVAL as uni on uni.DctNme=''APLDCT'' and uni.FldNme=''IDXUNI'' and uni.EnmVal = idxUni +
    left join DCTVAL as acv on acv.DctNme=''APLDCT'' and acv.FldNme=''ACVROW'' and acv.EnmVal = FLEIDX.acvRow +
    Where (fleLib,fleNme) = (''' + %trim(pmrFleLib) + ''',''' + %trim(pmrFleNme) + ''') +
    )';
  Where = 'and';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Active Row is
  If filterDs.acvDes <> '';
    sqlStm += ' and acvDes = ''' + %trim(filterDs.acvDes) + '''';
  EndIf;

  // Index Name Contains
  If filterDs.idxNme > '';
    sqlStm += ' and ucase(idxNme) Like uCase(''%' + %trim(filterDs.idxNme) + '%'')';
  EndIf;

  // Text Contains
  If filterDs.IdxTxt > '';
    sqlStm += ' and ucase(idxTxt) Like uCase(''%' + %trim(filterDs.idxTxt) + '%'')';
  EndIf;

  // Type Contains
  If filterDs.idxUniD > '';
    sqlStm += ' and ucase(idxUniD) Like uCase(''%' + %trim(filterDs.idxUniD) + '%'')';
  EndIf;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' and ' + $BuildSearch(pgmNme:SchVal);
  EndIf;

  // handle position to if any position to values are entered
  If pos<>posDefault;
    PositionSFL();
  EndIf;

  // Add order by
  sqlStm += ' ' + orderBy;

  // Get total number of records for selected data
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// This routine gets run when the program is first started
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(FLEIDXF1); // **change
    Open FLEIDXF1; // **change
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

  // Get the file name and alias/table name
  Exec SQL
    Select fleDes, tblNme, FLEMST.dctNme, coalesce(des,''),
           coalesce(prd.enmDes,''),coalesce(chg.enmDes,''),coalesce(sts.enmDes,'')
    Into  :fleDes,:tblNme,:dctNme,       :dctDes,
          :prdFle,                :chgScd,                 :fleSts
    From  FLEMST
    Left Join DCTMST on DCTMST.dctNme = FLEMST.dctNme
    Left Join DCTVAL as prd on prd.DctNme='APLDCT' and prd.fldNme='PRDFLE'
      and prd.EnmVal=coalesce(Case When prdFle = 'Y' Then 'Y' Else 'N' End,'')
    Left Join DCTVAL as chg on chg.DctNme='APLDCT' and chg.FldNme='CHGSCD'
      and chg.EnmVal=coalesce(Case When chgScd = 'Y' Then 'Y' Else 'N' End,'')
    Left Join DCTVAL as sts on (sts.DctNme,sts.FldNme,sts.enmVal) = ('APLDCT','FLESTS',fleSts)
    Where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme)
    Fetch First Row Only;

  // Build file description line, (library/file) table name, description
  desLine = %trim(pmrFleLib)+'/'+%trim(pmrFleNme);

  // **CHANGE positition cursor to the perfered field
  $GetFieldLocation(PgmNme:'SCHVAL':outRow:outCol);

  // Set filter defaults
  Clear filterDs;
  filterDs.srtCde = 1;

  // Sets on indicators for the mode and the mode name
  Selects = *Off;
  Display = *Off;
  Maintenance = *Off;
  If Option = '1';
    Selects = *On;
    mde='Select';
  ElseIf Option = '5';
    Display = *On;
    mde='Inquiry';
  Else;
    Maintenance = *On;
    mde='Update';
  EndIf;

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:132);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:132);
  fncKeys=$NextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/Copy QSRC,FLEIDXD1_2


// Copies in procedures SaveOptions, PopOptions, SoprtOptions and Get Options
// These never change so no point in duplicating the code in each program
/Copy QSRC,$options
