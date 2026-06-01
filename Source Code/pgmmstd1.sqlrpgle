**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Master List

Dcl-F PGMMSTF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMMSTD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,PGMMSTD1PR // Always include the prototype for the current program
/Copy QSRC,PGMMSTDZPR
/Copy QSRC,PGMMSTB0PR

Dcl-S RRN1   Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN  Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);

Dcl-S SchSav Like(SchVal);
Dcl-Ds filterDsSave Likeds(filterDs);
Dcl-Ds filterDs ExtName('PGMMSTFZ') Qualified Inz End-DS;

Dcl-S Option  like(APLDCT.Option);

Dcl-S sqlStm varchar(5120);
Dcl-S orderBy varchar(1024);
Dcl-S Where Char(5);

Dcl-S dataEntered Ind;
Dcl-S Changed     Ind;
Dcl-S Display     Ind;
Dcl-S Selects     Ind;
Dcl-S Maintenance Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selpgmNme Like(APLDCT.pgmNme);

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   char(132);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMMSTD1');
    pmrPgmNme Like(APLDCT.pgmNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Sets the Option if passed
  // **CHANGE - match pmrOption to the parm number, add any passed parms to globals vars if required
  If %parms >= 2;
    Option = pmrOption;
  EndIf;

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
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F6';
      Add();
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

  Close PGMMSTF1;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers
  If %parms >= 3;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  // **CHANGE parm numbers
  If selected;
    If %parms >= 1;
      pmrPgmNme=selpgmNme;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

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
    $GetFieldLocation(PgmNme2:csrFld:outRow:outCol);
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
  PGMMSTDz(filterDs:keyPressed);

  Select;
    When keyPressed = 'F3';

    When keyPressed = 'F12';
      keyPressed = '';

    When filterDsSave <> filterDs;
      LoadSFL();
  EndSl;

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes, for lists normally just the key field has to be changed,
// if it updates anything it needs to be added
Dcl-Proc UpdateScreen;

  // Save the SFL options entered on the current screen
  SaveOptions();
  Clear positionToKey;

  // Check for entries on the first line and process them
  If Sel1 <> '' or line1<>line1Defaults;
    Sel     = Sel1;
    sflFields=line1;
    // Overide option to 8=position to if not entered
    If Sel = '';
      Sel = '8';
    EndIf;
    If Sel='8'; // In caes no fields are populated
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
      pgmNme  = optionsArray(1).key;
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


// Process F6=Add
Dcl-Proc Add;
  Dcl-S pmPgmNme like(APLDCT.pgmNme);
  Dcl-S pmOption like(APLDCT.Option);
  pmOption = '1';

  PGMMSTB0(pmPgmNme:pmOption:keyPressed);

  filterDs.SrtCde = 1;
  LoadSFL();

End-Proc;


// Sets the sort code based on which position to field is entered
// **CHANGE This must be changed, the sort code has to be set based on which field had data entered
// the sort code must match the field names going across the screen in the same order
Dcl-Proc SetSrtCde;

  If pgmNme > '';
    filterDs.SrtCde = 1;
  ElseIf pgmDes > '';
    filterDs.SrtCde = 2;
  ElseIf dspFle > '';
    filterDs.SrtCde = 3;
  ElseIf AcvDes > '';
    filterDs.SrtCde = 4;
  ElseIf TypDes > '';
    filterDs.SrtCde = 5;
  ElseIf totCnt > 0;
    filterDs.SrtCde = 6;
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
    selpgmNme=pgmNme;

    // Handle all other options via the B0 program
  ElseIf Sel<>'';
    PGMMSTB0(pgmNme:Sel:keyPressed);
    // If adding a new entry, possition to it
    If Sel = '1' and Maintenance;
      pos=sflFields;
    EndIf;
    // Flag the SFL to reload if not inquiry only and they didn't press F3
    If Sel <> '5' and keyPressed <> 'F3';
      Changed = *on;
    EndIf;
  EndIf;

End-Proc;


// Validate anything entered on the screen
// **CHANGE Add validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S sflRcd packed(5);
  Dcl-S tsAcvRow like(APLDCT.acvRow);

  RRN1  = 1;
  error = *Off;


  // check for entries on the first line
  If Sel1<>'';

    // Check record in file, move top line entries into SFL fields
    Sel = Sel1;
    sflFields=line1;

    // get found and active status
    Clear found;
    Clear tsAcvRow;
    Exec SQL
      Select '1',acvRow Into :found,:tsAcvRow
      From   PGMMST
      Where  pgmNme = :pgmNme
      Fetch First Row Only;

    // validate Option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the dictionary name must be provided
    ElseIf not #$IN(Sel:'8':'1') and pgmNme = '';
      $ErrorMessage('DCT1001':'':error:pgmNme1@:'pgmNme1':outRow:outCol:psDsPgmNam);

      // If deleting make sure the row is active
    ElseIf Sel = '4' and tsAcvRow<>'1';
      $ErrorMessage('DCT1004':'':error:pgmNme1@:'pgmNme1':outRow:outCol:psDsPgmNam);

      // If reinstating make sure the row is inactive
    ElseIf Sel = '13' and tsAcvRow<>'0';
      $ErrorMessage('DCT1013':'':error:Sel1@:'Sel1':outRow:outCol:psDsPgmNam:pgmNme1@);

      // If adding make sure the entry does not exist
    ElseIf Sel = '1' and not Maintenance and found;
      $ErrorMessage('DCT1101':'':error:pgmNme1@:'pgmNme1':outRow:outCol:psDsPgmNam);

      // If any option but add or position to, make sure the entry exists
    ElseIf not #$IN(Sel:'1':'8') and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:pgmNme1@:'pgmNme1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 to RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      // * Validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs)
      or Sel = '1' and Maintenance;
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '4' and AcvDes = 'Inactive';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '13' and AcvDes = 'Active';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      EndIf;
      Update SFL;
    EndIf;
  EndFor;

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
  Dcl-S pages packed(7);
  Dcl-S pageNbr packed(7);
  Dcl-S message varchar(132);

  BuildSQLStatement();

  Changed = *Off;

  // Clear SFL
  LastRRN = 0;
  sflClr = *on;
  Write SFLCTL;
  sflClr = *off;
  sflDsp = *on;


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
    If dta(i).pgmNme<>'';
      Eval-Corr sflFields=dta(i);
      Sel = GetOption(dta(i).Key);
      RRN1 += 1;
      Write SFL;
      // if a position to is provided move the cursos to this entry
      If positionToKey=dta(i).Key;
        $GetFieldLocation(pgmNme2:'SEL':outRow:outCol);
        outRow+=i-1; // required to move to the correct SFL line
      EndIf;
    EndIf;
  EndFor;

  RRN1SV = RRN1;
  OutRRN1 = 1;
  Clear positionToKey;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    sflDsp  = *Off;
  EndIf;

  // Build a message for the page of entries in the SFL. Append filters allied if applicable.
  message='';
  pages=%int(#$RNDUP(NumberOfRows/SFLPage));
  pageNbr=%int(%int(#$RNDUP((CurrentRow+RRN1)/SFLPage)));

  // if the current record is not the first entry in a page we have to add 1 to the number of pages
  If %rem(CurrentRow:SFLPage)<>0;
    pages+=1;
  EndIf;
  // If the last record is shown force the page to the last page and show last page message
  If NumberOfRows-currentRow<=SFLPage;
    message='Page '+%char(pages)+' of '+%char(pages) +', last page shown.';
  Else;
    message='Page '+%char(pageNbr)+' of '+%char(pages)+'.';
  EndIf;

  // If the total rows are not equal to number of rows, add it to the message
  If numberOfRows<>totalNumberOfRows;
    message += ' Filtered ' + %char(NumberOfRows) + ' rows from ' + %char(totalNumberOfRows) +
               ' rows available.';
  Else;
    message += ' ' + %char(NumberOfRows) + ' rows available.';
  EndIf;

  // This message is for then number of entries, paging information and filters,
  // it is not shown if there are no records
  If message<>'';
    $ErrorMessage('':message);
  EndIf;

End-Proc;


// Build the SQL Statement
// **CHANGE the intial SQL statement and filter options have to be changed here
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  sqlStm='+
    Select * From (+
      Select Distinct +
        PGMMST.pgmNme Key, +
        PGMMST.pgmNme pgmNme, +
        PGMMST.Des pgmDes, +
        PGMMST.dspFle dspFle, +
        coalesce(a.EnmDes,''Error'') AcvDes, +
        coalesce(b.EnmDes,''Error'') TypDes, +
        PGMMST.totCnt-PGMMST.hlpCnt totCnt, +
        PGMMST.objTyp objTyp, +
        coalesce(c.EnmDes,''Error'') AplDes +
      From PGMMST +
      left join DCTVAL as a on a.dctNme=''APLDCT'' +
                            and a.FldNme=''ACVROW'' +
                            and a.EnmVal=PGMMST.AcvRow  +
      left join DCTVAL as b on b.dctNme=''APLDCT'' +
                            and b.FldNme=''PGMTYP'' +
                            and b.EnmVal=PGMMST.pgmTyp +
      left join DCTVAL as c on c.dctNme=''APLDCT'' +
                            and c.FldNme=''APL   '' +
                            and c.EnmVal=PGMMST.apl +
    )';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Insensitive Scroll Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL GET DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // AcvRow
  If filterDs.acvDes <> '';
    sqlStm += ' ' + Where + ' uCase(AcvDes) = Ucase(''' + %trim(filterDs.AcvDes) + ''')';
    Where = 'and';
  EndIf;

  // Name Contains
  If filterDs.pgmNme > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(pgmNme) Like uCase(''%' + %trim(filterDs.pgmNme) + '%'')';
    Where = 'and';
  EndIf;

  // Description Contains
  If filterDs.des > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(pgmDes) Like uCase(''%' + %trim(filterDs.Des) + '%'')';
    Where = 'and';
  EndIf;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' ' + Where + $BuildSearch(pgmNme2:SchVal);
    Where = 'and';
  EndIf;

  // handle position to if any position to values are entered
  If pos<>posDefault;
    PositionSFL();
  EndIf;

  // Add order by
  sqlStm += ' ' + orderBy;

  // Get total number of records for selected data
  Exec SQL Prepare sqlStm2 From :sqlStm;
  Exec SQL Declare SQLCrs Cursor For sqlStm2;
  Exec SQL Open  SQLCrs;
  Exec SQL GET DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Find the record number of the entered position to data
// **CHANGE add each position to field here
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // Add position to values

  // Position To pgmNme
  If pos.pgmNme > '';
    SQLStmPos += ' ' + Where + ' ucase(pgmNme) < uCase(''' + %trim(pos.pgmNme) + ''')';
    Where = 'and';
  ElseIf pos.pgmDes > '';
    SQLStmPos += ' ' + Where + ' ucase(pgmDes) < uCase(''' + %trim(pos.pgmDes) + ''')';
    Where = 'and';
  ElseIf pos.dspFle > '';
    SQLStmPos += ' ' + Where + ' ucase(dspFle) < uCase(''' + %trim(pos.dspFle) + ''')';
    Where = 'and';
  ElseIf pos.AcvDes > '';
    SQLStmPos += ' ' + Where + ' ucase(AcvDes) < uCase(''' + %trim(pos.AcvDes) + ''')';
    Where = 'and';
  ElseIf pos.TypDes > '';
    SQLStmPos += ' ' + Where + ' ucase(TypDes) < uCase(''' + %trim(pos.TypDes) + ''')';
    Where = 'and';
  ElseIf pos.TotCnt > 0;
    SQLStmPos += ' ' + Where + ' totCnt < ' + %char(pos.totCnt);
    Where = 'and';
  EndIf;

  // Add order by
  SQLStmPos += ' ' + orderBy;

  Exec SQL Prepare SQLStmPos From :SQLStmPos;
  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;
  Exec SQL Open SQLCrsPos;
  Exec SQL GET DIAGNOSTICS :CurrentRow = DB2_NUMBER_ROWS;
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
    Chain CsrRrn1 SFL;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=key;
      optionsArray(optionsCount).Option='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 to RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      // Left Justify Option
      Sel=%trim(Sel);
      // add to optionsArray
      found=*off;
      For i = 1 To optionsCount;
        If optionsArray(i).key=key;
          optionsArray(i).Option=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not found and sel<>'';
        optionsCount+=1;
        optionsArray(i).key=key;
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
  Dcl-S temp char(132);
  Dcl-S sortStm varchar(1000);

  // if there are no options, skip this
  If optionsCount=0;
    Return;
  EndIf;

  // loop through optionArray and populate the sort field
  For i = 1 to optionsCount;
    sortStm='select ' + %trim(orderByDS.value(filterDs.SrtCde)) + ' +
             from ('+sqlStm+') as a +
             where key='''+optionsArray(i).key+'''';
    Exec SQL Prepare sortStm From :sortStm;
    Exec SQL Declare sortCrs Cursor For sortStm;
    Exec Sql Open sortCrs;
    Exec Sql fetch next from sortCrs into :temp;
    Exec Sql close sortCrs;
    optionsArray(i).sort=temp;
  EndFor;

  // sort options by sort field then key
  sorta %subarr(optionsArray : 1 : optionsCount) %fields(sort : key);

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
// **CHANGE The cursor name and display file name needs to be changed as well as the initial field to set the cursor to
Dcl-Proc ProgramInitialization;

  Exec SQL
       Declare PGMMST Asensitive Scroll Cursor For DYNSQLStm;

  // Open the screen DSPF if it is not already open
  If not %open(PGMMSTF1); // **CHANGE
    Open PGMMSTF1; // **CHANGE
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow=0;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme2 is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // positition cursor to the dictionary position to field
  $GetFieldLocation(PgmNme2:'pgmNme1':outRow:outCol);

  // Sets the default filter options
  Clear filterDs;
  filterDs.SrtCde = 1;

  // Sets on indicators for the mode and the mode name
  Selects = *Off;
  Display = *Off;
  Maintenance = *Off;
  If Option = '1';
    Selects = *On;
    mode='Select';
  ElseIf Option = '5';
    Display = *On;
    mode='Inquiry';
  Else;
    Maintenance = *On;
    mode='Update';
  EndIf;

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:131);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:131);
  fncKeys=$NextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;
