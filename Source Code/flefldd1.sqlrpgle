**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// File Field List

Dcl-F FLEFLDF1 WorkStn SFile(SFL1:RRN1) SFile(SFL2:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,FLEFLDD1PR
/Copy QSRC,FLEFLDB1PR
/Copy QSRC,FLEFLDDZPR
/Copy QSRC,FLEFLDB0PR
/Copy QSRC,FLEFLDB8PR

Dcl-S RRN1 Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);
Dcl-S Where Char(5); // used to change the first where to an and after the first use

Dcl-S SchSav Like(SchVal);
Dcl-Ds filterDsSave Likeds(filterDs);
Dcl-Ds filterDs ExtName('FLEFLDFZ') Qualified Inz End-Ds;

Dcl-S Option  like(APLDCT.Option);

Dcl-S sqlStm  varchar(5120);
Dcl-S orderBy varchar(1024);

Dcl-S dataEntered Ind;
Dcl-S Changed     Ind;
Dcl-S Display     Ind;
Dcl-S Selects     Ind;
Dcl-S Maintenance Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selFldNme Like(APLDCT.FldNme);

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   char(132);
End-Ds;

// Globals for parameters
Dcl-S pmrFleLib Like(APLDCT.fleLib);
Dcl-S pmrFleNme Like(APLDCT.fleNme);

// set default SQL options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


// Mainline, Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDD1');
    pmr1FleLib Like(APLDCT.fleLib) const;
    pmr1FleNme Like(APLDCT.fleNme) const;
    pmrFldNme Like(APLDCT.FldNme);
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
    pos.FldNme = pmrFldNme;
  EndIf;
  If %parms >= 4;
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
    ElseIf keyPressed = 'F10';
      ChangeView();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F13';
      Filter();
    ElseIf keyPressed = 'F16';
      UpdateFile();
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

  Close FLEFLDF1;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers if number of parms changed
  If %parms >=4 ;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  // **CHANGE parm numbers if number of parms changed
  If selected;
    If %parms >= 2;
      pmrFldNme=selFldNme;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
// **CHANGE onyl if the big/small and/or number of views change
Dcl-Proc DisplayScreen;

  // Set the view based on the current view
  If filterDs.Dvw = '1';
    fncKeys=$ChangeFunctionKey(fncDs:'F10':'F10=View Column Name');
  Else;
    fncKeys=$ChangeFunctionKey(fncDs:'F10':'F10=View Column Text');
  EndIf;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  // **CHANGE change the screens based on the size and view options
  Write FOOTER;
  If filterDs.Dvw='2';
    Exfmt SFLCTL2;
  Else;
    Exfmt SFLCTL1;
  EndIf;

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
  FLEFLDDZ(filterDs:keyPressed);

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
  Dcl-S pmFldNme like(APLDCT.fldNme);
  Dcl-S pmOption like(Option);
  Dcl-S pmKeyPressed like(keyPressed);

  pmFldNme = '';
  pmOption = '1';
  FLEFLDB0(pmrFleLib:pmrFleNme:pmFldNme:pmOption:pmKeyPressed);

  // possition to new field
  pos.FldNme = FldNme;
  pos.ColTxt = ColTxt;

  // Refresh screen
  LoadSFL();

End-Proc;


// Update File
// This actually updates or schedules an update for a file. If in production
// the update will be scheduled for the night job, otherwise it processes the
// update immediately
Dcl-Proc UpdateFile;
  Dcl-S prdFle like(APLDCT.prdFle);
  Dcl-S locked Ind;

  Exec SQL select prdFle into :prdFle from FLEMST where (fleLib,FleNme) = (:pmrFleLib,:pmrFleNme);
  If prdFle = 'Y';
    Exec SQL update FLEMST set chgScd = 'Y' where (fleLib,FleNme) = (:pmrFleLib,:pmrFleNme);
    $ErrorMessage('':'Files update scheduled, production file updates get done at night.');
  Else;
    // check for filelocks, if locked give error
    Exec SQL
      Select '1' into :locked
      from object_lock_info
      WHERE SYSTEM_OBJECT_SCHEMA = :fleLib
        AND SYSTEM_OBJECT_NAME = :fleNme
        AND OBJECT_TYPE = '*FILE'
      limit 1;
    If locked;
      $ErrorMessage('':'Error, file locked, cannot update live. Schedule the update or resolve the locks.');
    Else;
      FLEFLDB8(pmrFleLib:pmrFleNme);
      $ErrorMessage('':'File updated.');
    EndIf;
  EndIf;

End-Proc;


// Cycle through different views  (F6=Change View)
Dcl-Proc ChangeView;

  // Set the view based on the current view
  If filterDs.Dvw = '2';
    filterDs.Dvw='1';
  Else;
    filterDs.Dvw='2';
  EndIf;

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
    ProcessLine();
    Clear Sel1;
    Clear line1;
  Else;
    // Process saved SFL options
    SortOptions();
    DoW optionsCount>0;
      Clear sflFields;
      FleLib  = %subst(optionsArray(1).key:1:10);
      FleNme  = %subst(optionsArray(1).key:11:10);
      FldNme  = %subst(optionsArray(1).key:21:10);
      Sel  = optionsArray(1).Option;
      positionToKey=optionsArray(1).key;
      ProcessLine();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
      PopOptions();
    EndDo;
  EndIf;

  // if anything changed, update the statuses and errors
  If dataEntered;
    FLEFLDB1(pmrFleLib:pmrFleNme:'Y':'N');
  EndIf;

  // Rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Process SFL Options
Dcl-Proc ProcessLine;

  If sel <> ' ';
    dataEntered = *on;
  EndIf;

  // handle position to
  If Sel = '8';
    eval pos=sflFields;
    SetSrtCde();
    LoadSFL();

    // Handle Select
  ElseIf sel='1' and Selects;
    selected=*on;
    selFldNme=FldNme;

    // Handle all other options via the B0 program
  ElseIf Sel<>'';
    FLEFLDB0(pmrFleLib:pmrFleNme:fldNme:Sel:keyPressed);
    // If adding a new entry, possition to it
    If Sel = '1' and Maintenance;
      pos.FldNme = FldNme;
      pos.ColTxt = ColTxt;
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

    If Sel1>'1' and Sel1 <> '8' and FldNme1 = '';
      $ErrorMessage('DCT0001':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);
    EndIf;

    // check record in file
    Sel = Sel1;
    Eval sflFields=line1;

    Clear found;
    Clear tsAcvRow;
    Exec SQL
      Select '1',acvRow Into :found,:tsAcvRow
      From FLEFLD
      Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme)
      Fetch First Row Only;

    // Validate option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the dictionary name must be provided
    ElseIf not #$IN(Sel:'8':'1') and fldNme = '';
      $ErrorMessage('DCT1001':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);

      // If deleting make sure the row is active
    ElseIf Sel = '4' and tsAcvRow<>'1';
      $ErrorMessage('DCT1004':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);

      // If reinstating make sure the row is inactive
    ElseIf Sel = '13' and tsAcvRow<>'0';
      $ErrorMessage('DCT1013':'':error:Sel1@:'Sel1':outRow:outCol:psDsPgmNam:FldNme1@);

      // If adding make sure the entry does not exist
    ElseIf Sel = '1' and not Maintenance and found;
      $ErrorMessage('DCT1101':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);

      // If any option but add or position to, make sure the entry exists
    ElseIf not #$IN(Sel:'1':'8') and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 to RRN1SV;
    If filterDs.Dvw='2';
      Chain(e) sflRcd SFL2;
    Else;
      Chain(e) sflRcd SFL1;
    EndIf;
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
      ElseIf Sel = '4' and stsDes = 'Inactive';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '13' and stsDes <> 'Inactive';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      EndIf;
      If filterDs.Dvw='2';
        Update SFL2;
      Else;
        Update SFL1;
      EndIf;
    EndIf;
  EndFor;

  // if no other errors and nothing has changed since the last reload, validate file completeness
  If not error and not dataEntered and Option = '2';
    // make sure there is at least one primary key
    found = *off;
    Exec SQL Select '1' into :found from FLEFLD where (fleLib,fleNme,priKey) = (:fleLib,:fleNme,'Y') limit 1;
    If not found;
      $ErrorMessage('':'Error, all files must have at least one primary key field.':error);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// Load the previous page of data
// *** Do not change anything in here ***
Dcl-Proc PageUp;

  SaveOptions();

  If CurrentRow-SFLPage<0;
    CurrentRow=0;
  Else;
    CurrentRow-=SFLPage;
  EndIf;
  LoadSFL();

End-Proc;


// Load the next page of data
// *** Do not change anything in here ***
Dcl-Proc PageDown;

  SaveOptions();

  If CurrentRow+SFLPage<NumberOfRows;
    CurrentRow+=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Load the SFL
// *** Do not change anything in here ***
Dcl-Proc LoadSFL;
  Dcl-S i packed(2);

  BuildSQLStatement();


  // Clear all SFL's
  LastRRN = 0;
  SflClr = *on;
  Write SFLCTL2;
  Write SFLCTL1;
  SflClr = *off;
  SflDsp = *on;

  // Add the offest and limit to the statement and read in one screen worth of data
  Clear dta;
  sqlStm += ' Limit ' + %char(SFLPage) + ' Offset ' + %char(CurrentRow) ;
  Exec SQL Prepare sqlStm4 From :sqlStm;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch SQLCrs4 For :SFLPage rows Into :dta;
  Exec SQL Close SQLCrs4;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If dta(i).FldNme<>'';
      Eval sflFields=dta(i);
      Sel = GetOption(key);
      RRN1 += 1;
      If filterDs.Dvw='2';
        Write SFL2;
      Else;
        Write SFL1;
      EndIf;
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
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',fldLvl,fldSeq,key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  sqlStm = ' +
  Select *  +
  From ( +
    Select +
      FLEFLD.fleLib || FLEFLD.fleNme || FLEFLD.fldNme key, +
      FLEFLD.fleLib, +
      FLEFLD.fleNme, +
      fldLvl, +
      fldSeq, +
      coalesce(key.enmDes,''No'') priKey, +
      FLEFLD.fldNme fldNme, +
      coalesce(case when length(trim(DCTFLD.colTxt)) > 40 then substr(trim(DCTFLD.colTxt),1,37) || ''...'' +
                    else trim(DCTFLD.colTxt) end,''Error'') colTxt, +
      coalesce(sts.enmDes,'''') stsDes, +
      Coalesce( +
        case when DCTFLD.FldTyp in (''DECIMAL'',''NUMERIC'') and fldScl > 0 +
            then trim(DCTFLD.FldTyp)||''(''||fldLen||'',''||fldScl||'')'' +
            when DCTFLD.FldTyp in (''DECIMAL'',''NUMERIC'',''CHAR'',''VARCHAR'',''CLOB'',''GRAPHIC'', +
                                    ''VARG'',''DBCLOB'',''BINARY'',''VARBIN'',''BLOB'') +
            then trim(DCTFLD.FldTyp)||''(''||fldLen||'')'' +
            else DCTFLD.FldTyp end +
          ,''Error'') typ, +
      coalesce(enm.enmDes,''N/A'') FldEnmD, +
      coalesce(nul.enmDes,''No'') alwNul, +
      case when coalesce(FLEFLD.nteExs,'''') = ''Y'' then ''Y'' else '''' end nteExs, +
      coalesce(aud.enmDes,''No'') audfld, +
      coalesce(DCTFLD.fldNmeSQL,'''') colNme +
    From FLEFLD +
    Join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme) +
    Left Join DCTFLD on (DCTFLD.DctNme,DCTFLD.FldNme) = (FLEMST.DctNme,FLEFLD.FldNme) +
    Left Join DCTVAL as sts on (sts.DctNme,sts.FldNme,sts.EnmVal)=(''APLDCT'',''FLDSTS'',coalesce(FLEFLD.fldSts,'''')) +
    Left Join DCTVAL as enm on enm.DctNme=''APLDCT'' and enm.FldNme=''FLDENM'' +
          and enm.EnmVal=coalesce(case when DCTFLD.fldEnm = ''Y'' then ''Y'' else ''N'' end,'''') +
    Left Join DCTVAL as nul on nul.DctNme=''APLDCT'' and nul.FldNme=''ALWNUL'' +
          and nul.EnmVal=coalesce(case when alwNul = ''Y'' then ''Y'' else ''N'' end,'''') +
    Left Join DCTVAL as key on key.DctNme=''APLDCT'' and key.FldNme=''PRIKEY'' +
          and key.EnmVal=coalesce(case when priKey = ''Y'' then ''Y'' else ''N'' end,'''') +
    Left Join DCTVAL as aud on aud.DctNme=''APLDCT'' and aud.FldNme=''AUDFLD'' +
          and aud.EnmVal=FLEFLD.audFld +
    Where (FLEFLD.fleLib,FLEFLD.fleNme) = (''' + %trim(pmrFleLib) + ''',''' + %trim(pmrFleNme) + ''') +
  )';
  Where = 'and';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Active Row is
  If filterDs.stsDes <> '';
    sqlStm += ' and stsDes = ''' + %trim(filterDs.stsDes) + '''';
  EndIf;

  // Enumerated is
  If filterDs.FldEnmD <> '';
    sqlStm += ' and FldEnmD = ''' + %trim(filterDs.FldEnmD) + '''';
  EndIf;

  // Field Name Contains
  If filterDs.FldNme > '';
    sqlStm += ' and ucase(FldNme) Like uCase(''%' + %trim(filterDs.FldNme) + '%'')';
  EndIf;

  // Column Text Contains
  If filterDs.ColTxt > '';
    sqlStm += ' and ucase(ColTxt) Like uCase(''%' + %trim(filterDs.ColTxt) + '%'')';
  EndIf;

  // Type Contains
  If filterDs.Typ > '';
    sqlStm += ' and ucase(Typ) Like uCase(''%' + %trim(filterDs.Typ) + '%'')';
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
  Exec SQL GET DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Saves options entered in the SFL to optionsDs
// **CHANGE, only if the Screen size or view options change
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5);

  // If in select mode and enter is pressed try to select the line the cursor is on
  If Selects and keyPressed='ENTER' and not selected;
    If filterDs.Dvw='2';
      Chain(e) CsrRrn1 SFL2;
    Else;
      Chain(e) CsrRrn1 SFL1;
    EndIf;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=Key;
      optionsArray(optionsCount).Option='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 to RRN1SV;
    If filterDs.Dvw='2';
      Chain(e) sflRcd SFL2;
    Else;
      Chain(e) sflRcd SFL1;
    EndIf;
    If %found;
      // Left Justify Option
      Sel=%trim(Sel);
      // add to optionsArray
      found=*off;
      For i = 1 To optionsCount;
        If optionsArray(i).key=Key;
          optionsArray(i).Option=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not found and sel<>'';
        optionsCount+=1;
        optionsArray(i).key=Key;
        optionsArray(i).Option=Sel;
      EndIf;
    EndIf;
  EndFor;

End-Proc;


// Removes the first entry of the options array
// This is here so if the user f12's half way through processing a list of option, only the
// processed ones are removed from the array so the others still have the option in front of them.
// *** Do not change anything in here ***
Dcl-Proc PopOptions;
  If optionsCount<=1;
    Clear optionsArray;
    optionsCount=0;
    Return;
  EndIf;

  // move options starting a index 2 to options starting at index 1
  %subarr(optionsArray:1:optionsCount-1)=%subarr(optionsArray:2:optionsCount);

  // clear the last entry
  Clear optionsArray(optionsCount);

  // lower the count by 1
  optionsCount-=1;

End-Proc;


// Sorts the optionArray by the current sort field
// This one is a little wierd, when a user enters an option they get added to the bottom of
// the optionsArray. They can page up and down and change sorts and search so all these options can
// be added in any order. We want to process them in the order of the screen sort at the time they
// finally press enter. To do this we populate the sort values in the array with the field value for
// sort field based on the sort code. Then we sort the array by that value. This should make the
// options get processed in the order they are on the screen regaurdless of the way they were entered.
// *** Do not change anything in here ***
Dcl-Proc SortOptions;
  Dcl-S i int(5);
  Dcl-S temp Char(132);
  Dcl-S sortStm Varchar(1000);

  // if there are no options, skip this
  If optionsCount=0;
    Return;
  EndIf;

  // loop through optionArray and populate the sort field
  For i = 1 To optionsCount;
    sortStm='select ' + %trim(orderByDS.value(filterDs.SrtCde)) + ' +
             From ('+sqlStm+') as a +
             Where Key='''+optionsArray(i).key+'''';
    Exec SQL Prepare sortStm From :sortStm;
    Exec SQL Declare sortCrs Cursor For sortStm;
    Exec SQL Open sortCrs;
    Exec SQL Fetch Next From sortCrs Into :temp;
    Exec SQL Close sortCrs;
    optionsArray(i).sort=temp;
  EndFor;

  // sort options by sort field then key
  sorta %subarr(optionsArray : 1 : optionsCount) %fields(sort : Key);

End-Proc;


// Retrieves an option for a row
// *** Do not change anything in here ***
Dcl-Proc GetOption;
  Dcl-Pi *n Like(APLDCT.Option);
    Key Like(dta.Key);
  End-Pi;
  Dcl-S i packed(5);

  // Loop through optionsArray and return an option if the customer is found
  For i = 1 To optionsCount;
    If optionsArray(i).Key = Key;
      Return optionsArray(i).Option;
    EndIf;
  EndFor;

  Return '  ';

End-Proc;


// This routine gets run when the program is first started
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(FLEFLDF1); // **change
    Open FLEFLDF1; // **change
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
    left join DCTMST on DCTMST.dctNme = FLEMST.dctNme
    left join DCTVAL as prd on prd.DctNme='APLDCT' and prd.FldNme='PRDFLE'
      and prd.EnmVal=coalesce(case when prdFle = 'Y' then 'Y' else 'N' end,'')
    left join DCTVAL as chg on chg.DctNme='APLDCT' and chg.FldNme='CHGSCD'
      and chg.EnmVal=coalesce(case when chgScd = 'Y' then 'Y' else 'N' end,'')
    left join DCTVAL as sts on (sts.DctNme,sts.FldNme,sts.enmVal) = ('APLDCT','FLESTS',fleSts)
    Where (fleLib,fleNme) = (:pmrFleLib,:pmrFleNme)
    Fetch First Row Only;

  // Build file description line, (library/file) table name, description
  desLine = %trim(pmrFleLib)+'/'+%trim(pmrFleNme);

  // **CHANGE positition cursor to the perfered field
  $GetFieldLocation(PgmNme:'FldNme1':outRow:outCol);

  // Set filter defaults
  Clear filterDs;
  filterDs.srtCde = 1;
  filterDs.dvw = '1';

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
/copy QSRC,FLEFLDD1_2
