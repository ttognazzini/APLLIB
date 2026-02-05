**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Program Action Prompt

Dcl-F PGMACTFP WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMACTDP_@ // auto generated data structures for field attribute fields
/Copy QSRC,PGMACTDPPR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN  Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);
Dcl-S sqlStm  varchar(5120);
Dcl-S sqlStm2 Varchar(5120);
Dcl-S orderBy varchar(1024);
Dcl-S Where Char(5);
Dcl-S pgmNme like(APLDCT.pgmNme);

Dcl-S dataEntered Ind;
Dcl-S SchSav Like(SchVal);
Dcl-S Option    like(APLDCT.Option);
Dcl-S SrtCde  packed(2:0);
Dcl-S Changed Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selActCde Like(actCde);

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   Char(132);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMACTDP');
    pmrPgmNme Like(pgmNme);
    pmrActCde Like(actCde) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;

  pgmNme = pmrPgmNme;

  // If a value or description is passed position to it by default
  If %parms >= 2 and pmrActCde<>'';
    pos.actCde = pmrActCde;
    SrtCde = 1;
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
      ProgramInitialization();
    ElseIf keyPressed = 'F12';
      Leave;
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
      If selected;
        Leave;
      EndIf;
    EndIf;

  EndDo;

  Close PGMACTFP;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 3;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  If selected;
    If %parms >= 2;
      pmrActCde=selActCde;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

  // Write the footer first since it is the window, everything else gets written in it
  Write FOOTER;
  Write MSGCTL; // Load message SFL
  Exfmt SFLCTL; // Actually Display the Screen

  // Left Justify Option
  Sel1=%trim(Sel1);

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
  outRow=csrRow2;
  outCol=csrCol2;

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

End-Proc;


// Update anything entered on the screen
Dcl-Proc UpdateScreen;
  Dcl-S i packed(5);

  // Save the SFL options entered on the current screen
  SaveOptions();
  Clear positionToKey;

  // Check for entries on the first line and process them
  If Sel1 <> '' or line1<>line1Defaults;
    Sel     = Sel1;
    sflFields=line1;
    // Overide option to 8=position to if not entered
    If Sel1 = '';
      Sel = '8';
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
      actCde  = optionsArray(1).key;
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

  If actCde > '';
    SrtCde = 1;
  ElseIf Des > '';
    SrtCde = 2;
  ElseIf fncKey > '';
    SrtCde = 3;
  EndIf;

End-Proc;

// Process SFL Options
Dcl-Proc ProcessLine;

  // handle position to
  If Sel = '8';
    pos=sflFields;
    SetSrtCde();

    // Handle Select
  ElseIf sel='1';
    selected=*on;
    selActCde=actCde;

    // Handle auto select with enter, only if another line is not selected
  ElseIf sel='S1' and not selected;
    selected=*on;
    selActCde=actCde;
  EndIf;

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S i packed(5:0);

  RRN1  = 1;
  error = *Off;

  // check for entries on the first line
  If Sel1 <> '';

    // if they enter an option other than postition to make sure they enter the value
    If Sel1 = '1' and ActCde1 = '';
      $ErrorMessage('DCT0001':'':error:ActCde1@:'actCde1':outRow:outCol:psDsPgmNam);
    EndIf;

    // Check record in file, move top line entries into SFL fields
    Sel = Sel1;
    sflFields=line1;

    Clear found;
    Exec SQL
      Select '1' Into :found
      From   PGMACT
      Where  pgmNme = :pgmNme and actCde=:actCde
      Fetch First Row Only
      With NC;

    // validate Option
    If Sel <> '' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // required fields missing
    ElseIf Sel = '1' and actCde = '';
      $ErrorMessage('DCT1001':'':error:ActCde1@:'actCde1':outRow:outCol:psDsPgmNam);

    EndIf;
  EndIf;

  // check for entries in the subfile
  For i = 1 To SFLPage;
    Chain(e) i SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      If Sel <> '' and not $ValidSFLOption(sel:optDs);
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
      EndIf;
      Update SFL;
    EndIf;
  EndFor;

  Return error;

End-Proc;


// Load the previous page of data
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
Dcl-Proc PageDown;

  SaveOptions();

  If CurrentRow+SFLPage<NumberOfRows;
    CurrentRow+=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Load the SFL
Dcl-Proc LoadSFL;
  Dcl-S i packed(2);

  BuildSQLStatement();

  Changed = *Off;

  // Clear SFL
  LastRRN = 0;
  SflClr = *on;
  Write SFLCTL;
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
    If dta(i).actCde<>'';
      Eval-Corr sflFields=dta(i);
      Sel = GetOption(dta(i).key);
      RRN1 += 1;
      Write SFL;
    EndIf;
  EndFor;

  RRN1SV = RRN1;
  OutRRN1 = 1;

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
  orderBy = 'Order By ' + %trim(orderByDS.value(SrtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
    If schVal<>''; // if searching, position to selection column
      $GetFieldLocation(pgmNme:'sel':outRow:outCol);
    EndIf;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  sqlStm = '+
    Select +
      actCde Key, +
      actCde, +
      des, +
      fncKey +
    From PGMACT +
    Where pgmNme=''' + %trim(pgmNme) + ''' +
    and AcvRow=''1''';

  sqlStm2 = 'With DATALIST as ('+sqlStm+') +
             Select * From DATALIST';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm2;
  Exec SQL Declare SQLCrs3 Insensitive Scroll Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Select Search Values
  If SchVal > '';
    sqlStm2 += ' ' + Where + $BuildSearch(pgmNme2:SchVal);
    Where = 'and';
  EndIf;

  // handle position to if any position to values are entered
  If pos<>posDefault;
    PositionSFL();
  EndIf;

  // Add order by
  sqlStm2 += ' ' + orderBy;

  // Get total number of records for selected data
  Exec SQL Prepare sqlStm From :sqlStm2;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;
  Exec SQL GET DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // Add position to values
  If pos.actCde > '';
    SQLStmPos += ' and ucase(actCde) < uCase(''' + %trim(pos.ActCde) + ''')';
  ElseIf pos.Des > '';
    SQLStmPos += ' and ucase(des) < uCase(''' + %trim(pos.des) + ''')';
  ElseIf pos.fncKey > '';
    SQLStmPos += ' and ucase(fncKey) < uCase(''' + %trim(pos.fncKey) + ''')';
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

  // If enter is pressed try to select the line the cursor is on
  If keyPressed='ENTER' and not selected;
    Chain CsrRrn1 SFL;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=Key;
      optionsArray(optionsCount).Option='S1';
    EndIf;
  EndIf;

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
    sortStm='select ' + %trim(orderByDS.value(SrtCde)) + ' +
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
Dcl-Proc ProgramInitialization;

  Exec SQL
    Declare PGMACT Asensitive Scroll Cursor For DYNSQLStm;

  // Open the screen DSPF if it is not already open
  If not %open(PGMACTFP); // **change
    Open PGMACTFP; // **change
  EndIf;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // Positition cursor to the description position to field
  $GetFieldLocation(pgmNme:'Des1':outRow:outCol);

  // Sets the default sort option
  SrtCde = 1;

  // Build the screen title, it is the progrm name + "Action Selection"
  title = '';
  Exec SQL Select des into :title from PGMMST where pgmNme=:pgmNme;
  title=#$CNTR(%trim(title) + ' Action Selection':40);

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:60);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:60);
  fncKeys=$NextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;
