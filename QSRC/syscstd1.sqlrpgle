**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// System Constraint Inquiry

Dcl-F SYSCSTF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,SYSCSTD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,SYSCSTD1PR // Always include the prototype for the current program
/Copy QSRC,SYSCSTDZPR

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S RRN1SV Like(OutRRN1); // the relative record number for the SFL
Dcl-S currentRow packed(9); // the postion in the data set for the start of the current screen
Dcl-S numberOfRows packed(9); // the total number of rows in the data set
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S SchSav Like(SchVal); // used to see if the search field changed, which forces a SFL reload
Dcl-Ds filterDsSave Likeds(filterDs); // used to see if the filter options changed, which forces a SFL reload
Dcl-Ds filterDs ExtName('SYSCSTFZ') Qualified Inz End-Ds; // contains the filter and sort options from DZ

Dcl-S Option  like(APLDCT.Option); // global variable to store the option parameter in

Dcl-S sqlStm Varchar(5120); // used for the select statment for the fields
Dcl-S orderBy Varchar(1024); // used to build the order by clause
Dcl-S Where Char(5); // used to change the first where to an and after the first use

Dcl-S dataEntered Ind; // set on if anything is entered on the screen
Dcl-S Changed     Ind; // set on if any of the SFL entries are changed, forces a reload of the SFL
Dcl-S Display     Ind; // set on if the program is in inquiry mode, option parameter=5
Dcl-S Selects     Ind; // set on if the program is in select mode, option parameter=1
Dcl-S Maintenance Ind; // set on if the program is in update mode, option parameter=2

// Used for selection if in select mode
// **ChangedFromMassReplace, change the name of the key field, if there are more than one addtional fields
// will need to be added.
Dcl-S selected  Ind;
Dcl-S selLibNme Like(APLDCT.libNme);
Dcl-S selFleNme Like(APLDCT.fleNme);
Dcl-S selCstNme Like(APLDCT.cstNme);

// Used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   Char(132);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('SYSCSTD1');
    pmrlibNme Like(APLDCT.libNme);
    pmrFleNme Like(APLDCT.FleNme);
    pmrCstNme Like(APLDCT.CstNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
    pmrSchVal like(APLDCT.schVal) options(*nopass);
  End-Pi;

  // Sets the Option if passed
  // **CHANGE - match pmrOption to the parm number, add any passed parms to globals vars if required
  If %parms >= 4;
    Option = pmrOption;
  EndIf;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
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

  DoU keyPressed='F3' and keyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F5';
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F11';
      $ToggleSFLMode(sflMode);
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
      If selected or (%parms<>0 and not dataEntered);
        Leave;
      EndIf;
    EndIf;

  EndDo;

  Close SYSCSTF1;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers if number of parms changed
  If %parms >= 3;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  // **CHANGE parm numbers if number of parms changed
  If selected;
    If %parms >= 1;
      pmrlibNme=selLibNme;
      pmrFleNme=selFleNme;
      pmrCstNme=selCstNme;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // This message is for the number of entries, paging information and filters, it is not shown if there are no records
  $ErrorMessage('':$BuildSFLMessage(NumberOfRows:totalNumberOfRows:SFLPage:CurrentRow:RRN1));

  // Load message SFL
  Write MSGCTL;

  // set drop/fold option, change the comand key text
  SFLdrop = (SFLmode = *off);
  If SFLMODE=*off;
    fncKeys=$ChangeFunctionKey(fncDs:'F11':'F11=Less Detail');
  Else;
    fncKeys=$ChangeFunctionKey(fncDs:'F11':'F11=More Detail');
  EndIf;

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

  // Left Justify Option
  Sel1=%trim(Sel1);

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
  SYSCSTDZ(filterDs:keyPressed);

  If keyPressed = 'F3';
  ElseIf keyPressed = 'F12';
    keyPressed = '';
  ElseIf filterDsSave <> filterDs;
    LoadSFL();
  EndIf;

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes, for lists normally just the key field has to be changed,
// if it updates anything it needs to be added
Dcl-Proc UpdateScreen;

  // Save the SFL options entered on the current screen
  SaveOptions();
  Clear positionToKey;

  // If they changed the search term, clear the selected options. This prevents actions being taken on items no
  // longer in the list.
  If schval<>schSav;
    Clear optionsCount;
    Clear optionsArray;
  EndIf;

  // Check for entries on the first line and process them
  If Sel1 <> '' or line1<>line1Defaults;
    Sel     = Sel1;
    sflFields=line1;
    // Overide option to 8=position to if not entered
    If Sel = '';
      Sel = '8';
    EndIf;
    If Sel='8'; // In case no fields are populated
      Clear currentRow;
    EndIf;
    ProcessLine();
    Clear Sel1;
    Clear line1;
  Else;
    // Process saved SFL options
    SortOptions();
    DoW optionsCount>0;
      Clear sflFields;
      libNme  = %subst(optionsArray(1).key:1:10);
      fleNme  = %subst(optionsArray(1).key:11:10);
      cstNme  = %subst(optionsArray(1).key:21:30);
      Sel  = optionsArray(1).Option;
      positionToKey=optionsArray(1).key;
      ProcessLine();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
      PopOptions();
    EndDo;
  EndIf;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Sets the sort code based on which position to field is entered
// **CHANGE This must be changed, the sort code has to be set based on which field had data entered
// the sort code must match the field names going across the screen in the same order
Dcl-Proc SetSrtCde;

  If libNme > '';
    filterDs.SrtCde = 1;
  ElseIf fleNme > '';
    filterDs.SrtCde = 2;
  ElseIf cstNme > '';
    filterDs.SrtCde = 3;
  ElseIf cstTyp > '';
    filterDs.SrtCde = 4;
  ElseIf libTypD > '';
    filterDs.SrtCde = 5;
  EndIf;

End-Proc;


// Process SFL Options
// Anything that needs to happen based on the SFL option needs to be handled in the navigator (XXXXXXB0)
// **ChangedFromMassReplace, the filter program and keyfields need to be changed,
//   also navigator parameters might need to be changed, check them
Dcl-Proc ProcessLine;
  If sel<>'';
    dataEntered=*on;
  EndIf;

  // Handle position to
  If Sel = '8';
    pos=sflFields;
    SetSrtCde();

    // Handle Select
  ElseIf sel='1' and Selects;
    selected=*on;
    selLibNme=libNme;
    selFleNme=fleNme;
    selCstNme=cstNme;

  EndIf;

End-Proc;


// Validate anything entered on the screen
// **CHANGE Add validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S sflRcd packed(5);

  RRN1  = 1;
  error = *Off;

  // check for entries on the first line
  If Sel1<>'';

    // Check record in file, move top line entries into SFL fields
    Sel = Sel1;
    sflFields=line1;

    // Validate option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('':'Invalid option entered.':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);
    EndIf;

  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      // * Validate Option
      Update SFL;
    EndIf;
  EndFor;

  Return error;

End-Proc;


// Load the previous page of data
// *** Do not change anything in here ***
Dcl-Proc PageUp;

  SaveOptions();

  If currentRow-SFLPage<0;
    currentRow=0;
  Else;
    currentRow-=SFLPage;
  EndIf;
  LoadSFL();

End-Proc;


// Load the next page of data
// *** Do not change anything in here ***
Dcl-Proc PageDown;

  SaveOptions();

  If currentRow+SFLPage<NumberOfRows;
    currentRow+=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Load the SFL
// *** Do not change anything in here ***
Dcl-Proc LoadSFL;
  Dcl-S i packed(2);

  BuildSQLStatement();

  Changed = *Off;

  // Clear SFL
  SflClr = *on;
  Write SFLCTL;
  SflClr = *off;
  SflDsp = *on;

  // Add the offest and limit to the statement and read in one screen worth of data
  Clear dta;
  sqlStm += ' Limit ' + %char(SFLPage) + ' Offset ' + %char(currentRow) ;
  Exec SQL Prepare sqlStm4 From :sqlStm;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch SQLCrs4 For :SFLPage rows Into :dta;
  Exec SQL Close SQLCrs4;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If dta(i).libNme<>'';
      Eval-Corr sflFields=dta(i);
      Sel = GetOption(dta(i).key);
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

End-Proc;


// Build the SQl Statement
// **CHANGE the intial SQL statement and filter options have to be changed here
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    currentRow=0;
    dataEntered=*on;
    If schVal<>'' and Selects; // if in select mode and searching, position to selection column
      $GetFieldLocation(PgmNme:'sel':outRow:outCol);
    EndIf;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  sqlStm=' +
    Select * +
    From ( +
      Select +
        substr(system_table_schema,1,10) || substr(system_table_name,1,10) || substr(constraint_name,1,30) key, +
        system_table_schema libNme, +
        system_table_name fleNme, +
        constraint_name cstNme, +
        constraint_type cstTyp, +
        Coalesce(lib.enmDes,''Error'') libTypD +
      From syscst +
      Join APLLIB on libNme = system_table_schema +
      Left join DCTVAL lib on (lib.dctnme,lib.fldnme,lib.enmval)=(''APLDCT'',''LIBTYP'',APLLIB.libtyp) +
      where APLLIB.acvRow = ''1'' +
    )';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;


  // Librarty Name Contains
  If filterDs.libNme > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(libNme) = uCase(''' + %trim(filterDs.libNme) + ''')';
    Where = 'and';
  EndIf;

  // Librarty Type Is
  If filterDs.libtypD > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(libTypD) = uCase(''' + %trim(filterDs.libTypD) + ''')';
    Where = 'and';
  EndIf;

  // Name Contains
  If filterDs.fleNme > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(fleNme) = uCase(''' + %trim(filterDs.fleNme) + ''')';
    Where = 'and';
  EndIf;

  // Constraint Contains
  If filterDs.cstNme > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(cstNme) Like uCase(''%' + %trim(filterDs.cstNme) + '%'')';
    Where = 'and';
  EndIf;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' ' + Where + $BuildSearch(pgmNme:SchVal);
    Where = 'and';
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
  Exec SQL Get DIAGNOSTICS :numberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Find the record number of the entered position to data
// **CHANGE add each position to field here
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // **CHANGE - Add position to values
  If pos.libNme > '';
    SQLStmPos += ' ' + Where + ' ucase(libNme) < uCase(''' + %trim(pos.libNme) + ''')';
    Where = 'and';
  ElseIf pos.fleNme > '';
    SQLStmPos += ' ' + Where + ' ucase(fleNme) < uCase(''' + %trim(pos.fleNme) + ''')';
    Where = 'and';
  ElseIf pos.cstNme > '';
    SQLStmPos += ' ' + Where + ' ucase(cstNme) < uCase(''' + %trim(pos.cstNme) + ''')';
    Where = 'and';
  ElseIf pos.cstTyp > '';
    SQLStmPos += ' ' + Where + ' ucase(cstTyp) < uCase(''' + %trim(pos.cstTyp) + ''')';
    Where = 'and';
  ElseIf pos.libTypD > '';
    SQLStmPos += ' ' + Where + ' ucase(libTypD) < uCase(''' + %trim(pos.libTypD) + ''')';
    Where = 'and';
  EndIf;

  // Add order by
  SQLStmPos += ' ' + orderBy;

  Exec SQL Prepare SQLStmPos From :SQLStmPos;
  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;
  Exec SQL Open SQLCrsPos;
  Exec SQL Get DIAGNOSTICS :currentRow = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrsPos;

  Clear pos;

End-Proc;


// Saves options entered in the SFL to optionsArray
// *** Do not change anything in here ***
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5);

  // If in select mode and enter is pressed try to select the line the cursor is on
  If Selects and keyPressed='ENTER' and not selected;
    Chain(e) CsrRrn1 SFL;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=Key;
      optionsArray(optionsCount).Option='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
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


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(SYSCSTF1); // **change
    Open SYSCSTF1; // **change
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  currentRow=0;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // **CHANGE positition cursor to the perfered field
  If Option = '1' and %subst(schVal:1:1)='?' or schVal='';
    schVal='';
    $GetFieldLocation(PgmNme:'schVal':outRow:outCol);
  ElseIf Option = '1';
    $GetFieldLocation(PgmNme:'sel':outRow:outCol);
  Else;
    $GetFieldLocation(PgmNme:'cstNme1':outRow:outCol);
  EndIf;

  // Sets the default filter options
  Clear filterDs;
  filterDs.SrtCde = 1;
  filterDs.libTypD = 'Production';

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
