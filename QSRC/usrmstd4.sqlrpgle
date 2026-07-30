**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// User Master Maintenance - Authorized Programs

Dcl-F USRMSTF4 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTD4_@ // auto generated data structures for field attribute fields
/Copy QSRC,USRMSTD4PR // Always include the prototype for the current program
/Copy QSRC,USRMSTD5PR // Prompt for user

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S RRN1SV Like(OutRRN1); // the relative record number for the SFL
Dcl-S CurrentRow packed(9); // the postion in the data set for the start of the current screen
Dcl-S NumberOfRows packed(9); // the total number of rows in the data set
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S SchSav Like(SchVal); // used to see if the search field changed, which forces a SFL reload

Dcl-S Option  like(APLDCT.Option); // global variable to store the option parameter in

Dcl-S sqlStm Varchar(5120); // used for the select statment for the fields
Dcl-S sqlStm1 Varchar(5120); // used for the select statment for the fields
Dcl-S orderBy Varchar(1024); // used to build the order by clause
Dcl-S Where Char(5); // used to change the first where to an and after the first use

// Used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

Dcl-S srtCde like(APLDCT.srtCde);
Dcl-S aCode like(APLLIB.aCode);
Dcl-S cmpACode like(APLLIB.aCode);

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
  Dcl-Pi *n ExtPgm('USRMSTD4');
    prmAcNo Zoned(5);
  End-Pi;

  // get user profile from user number
  Exec SQL select acUPrf into :usrPrf from ACCESSPF where acNo = :prmAcNo;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' and KeyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F5';
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F7';
      ImportFromUser();
    ElseIf keyPressed = 'F9';
      CompareToUser();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F23';
      options=$nextSFLOption(optDs);
    ElseIf keyPressed = 'F24';
      fncKeys=$nextFunctionKeys(fncDs);
    ElseIf keyPressed = 'PAGEDOWN';
      PageDown();
    ElseIf keyPressed = 'PAGEUP';
      PageUp();
    ElseIf ValidateScreen();
      Iter;
    Else;
      UpdateScreen();
    EndIf;

  EndDo;

  Close USRMSTF4;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // This message is for the number of entries, paging information and filters, it is not shown if there are no records
  $ErrorMessage('':$buildSFLMessage(NumberOfRows:totalNumberOfRows:sflPage:CurrentRow:RRN1));

  // hide/show comparisson information
  If cmpUsr <> '';
    $SetAttribute(shwCmp@:'');
    $SetAttribute(shwCmpH@:'HI UL');
    $SetAttribute(cmpDes1@:'CS UL');
  Else;
    $SetAttribute(shwCmp@:'ND');
    $SetAttribute(shwCmpH@:'ND');
    $SetAttribute(cmpDes1@:'ND PR');
  EndIf;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  Write FOOTER;
  Exfmt SFLCTL;

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
    $getFieldLocation(PgmNme:csrFld:outRow:OutCol);
  EndIf;

  // Left Justify Option
  Sel1=%trim(Sel1);

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

End-Proc;


// Update anything entered on the screen
// **ChangedFromMassReplace and sometimes,   for lists normally just the key field has to be changed,
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
      pgmNam  = optionsArray(1).key;
      Sel  = optionsArray(1).Option;
      positionToKey=optionsArray(1).key;
      ProcessLine();
      PopOptions();
    EndDo;
  EndIf;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


Dcl-Proc CompareToUser;

  // Prompt for user
  USRMSTD5('Select User to Compare To':cmpUsr:keyPressed);

  // get suers name and code if populated
  If cmpUsr <> '';
    Exec SQL Select acCode, trim(acFNam) || ' ' || trim(acLNam) into :cmpACode, :cmpNme
             from ACCESSPF where acUprf = :cmpUsr;
  Else;
    cmpACode = '';
    cmpNme = '';
  EndIf;

  CurrentRow=0;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


Dcl-Proc ImportFromUser;
  Dcl-S impUsr like(APLDCT.usrPrf);
  Dcl-S impACode like(APLLIB.aCode);

  // Prompt for user
  impUsr = '';
  USRMSTD5('Select User to Import From':impUsr:keyPressed);

  // Import form user if selected
  If impUsr <> '';
    Exec Sql Select acCode into :impACode from ACCESSPF where acUPrf = :impUsr;
    If impACode <> '';
      Exec SQL insert into AVAL (aCode, pgmNam)
        Select :aCode, pgmNam from AVAL
        where aCode = :impACode
          and pgmNam not in (Select pgmNam from AVAL where aCode = :aCode);
      $ErrorMessage('':'Import Complete.');
    Else;
      $ErrorMessage('':'Import not done, invalid user or no entries found.');
    EndIf;
  EndIf;

  CurrentRow=0;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Sets the sort code based on which position to field is entered
// **CHANGE This must be changed, the sort code has to be set based on which field had data entered
// the sort code must match the field names going across the screen in the same order
Dcl-Proc SetSrtCde;

  If pgmNam <> '';
    srtCde = 1;
  ElseIf pgmDes > '';
    srtCde = 2;
  ElseIf cmpDes > '';
    srtCde = 3;
  EndIf;

End-Proc;


// Process SFL Options
// Anything that needs to happen based on the SFL option needs to be handled in the navigator (XXXXXXB0)
// **ChangedFromMassReplace, the filter program and keyfields need to be changed,
//   also navigator parameters might need to be changed, check them
Dcl-Proc ProcessLine;

  // Handle position to
  If Sel = '8';
    eval pos=sflFields;
    SetSrtCde();

    // Handle Delete
  ElseIf sel='4';
    Exec SQL Delete from AVAL where (aCode,pgmNam) = (:aCode,:pgmNam);

    // Handle Add
  ElseIf sel='1';
    found = '1';
    Exec SQL Select '1' into :found from AVAL where aCode=:aCode and pgmNam=:pgmNam;
    Exec SQL insert into AVAL (pgmNam,aCode) values(:pgmNam,:aCode);

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

    // get found and active status
    Clear found;
    Exec SQL
      Select '1' Into :found
      From   AVAL
      Where  (pgmNam,aCode) = (:pgmNam,:aCode)
      Fetch First Row Only;

    // Validate option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for add the entry most not be found already
    ElseIf Sel = '1' and found;
      $ErrorMessage('':'Error, Entry already exists.':error:pgmNam1@:'pgmNam1':outRow:outCol:psDsPgmNam);

      // For add, make sure the user has an access code
    ElseIf Sel = '1' and aCode = '';
      $ErrorMessage('':'Error, user does not have an access code, permissions cannot be added.'
                      :error:pgmNam1@:'pgmNam1':outRow:outCol:psDsPgmNam);

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
      If Sel <> '' and not $ValidSFLOption(sel:optDs);
        $ErrorMessage('':'Error - invalidoption entered,':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
        // For add, make sure the user has an access code
      ElseIf Sel = '1' and aCode = '';
        $ErrorMessage('':'Error, user does not have an access code, permissions cannot be added.'
                        :error:pgmNam1@:'pgmNam1':outRow:outCol:psDsPgmNam);
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

  BuildSQLStatement();

  // Clear SFL
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

  // hide/show comparisson information
  If cmpUsr <> '';
    $SetAttribute(shwCmp@:'');
  Else;
    $SetAttribute(shwCmp@:'ND');
  EndIf;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If Dta(i).pgmNam<>'';
      Eval-Corr sflFields=dta(i);
      Sel = GetOption(Dta(i).key);
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
  orderBy = 'Order By ' + %trim(orderByDS.value(srtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  sqlStm1='+
    Select +
      coalesce(usr.pgmNam,cmp.pgmNam) as key, +
      coalesce(usr.pgmNam,cmp.pgmNam) as pgmNam, +
      coalesce(PDL,'''') pgmDes, +
      case when usr.pgmNam is null then ''User missing'' +
           when cmp.pgmNam is null then ''Comparison user missing'' +
           else ''Both have.'' end cmpDes +
    from (Select pgmNam, acUPrf usrUprf +
          from AVAL +
          Left join  ACCESSPF on acCode = aCode +
          Where aCode = '''+%trim(aCode)+''' +
          ) as usr +
    full outer join (Select pgmNam, acUPrf cmpUprf +
          from AVAL +
          Left join ACCESSPF on acCode = aCode +
          Where aCode = '''+%trim(cmpACode)+''' +
            and aCode <> ''''+
          ) as cmp on cmp.pgmNam = usr.pgmNam +
    left join pgmdes on PGMDES.pgmNam = coalesce(usr.pgmNam,cmp.pgmNam) and dLine = 1';
  sqlStm = 'Select * from ('+%trim(sqlStm1)+')';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Insensitive Scroll Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

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
  Exec SQL Prepare sqlStm2 From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm2;
  Exec SQL Open  SQLCrs;
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// Find the record number of the entered position to data
// **CHANGE add each position to field here
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // **CHANGE - Add position to values
  If Pos.pgmNam > '';
    SQLStmPos += ' ' + Where + ' ucase(pgmNam) < uCase(''' + %trim(Pos.pgmNam) + ''')';
    Where = 'and';
  ElseIf Pos.pgmDes > '';
    SQLStmPos += ' ' + Where + ' ucase(pgmDes) < uCase(''' + %trim(Pos.pgmDes) + ''')';
    Where = 'and';
  ElseIf Pos.cmpDes > '';
    SQLStmPos += ' ' + Where + ' ucase(cmpDes) < uCase(''' + %trim(Pos.cmpDes) + ''')';
    Where = 'and';
  EndIf;

  // Add order by
  SQLStmPos += ' ' + orderBy;

  Exec SQL Prepare SQLStmPos From :SQLStmPos;
  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;
  Exec SQL Open SQLCrsPos;
  Exec SQL Get DIAGNOSTICS :CurrentRow = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrsPos;

  Clear Pos;

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
      If not Found and sel<>'';
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
    sortStm='select ' + %trim(orderByDS.value(srtCde)) + ' +
             From ('+sqlStm+') as a +
             Where Key='''+%char(optionsArray(i).key)+'''';
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

  // Loop through options array and return an option if the customer is found
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
  If not %open(USRMSTF4); // **change
    Open USRMSTF4; // **change
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow=0;
  srtCde = 1;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // **CHANGE positition cursor to the perfered field
  $getFieldLocation(PgmNme:'schVal':outRow:OutCol);

  // get access code and name for user
  Exec SQL Select acCode, trim(acFNam) || ' ' || trim(acLNam) into :aCode, :usrNam
           from ACCESSPF where acUprf = :usrPrf;

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:132);
  options=$nextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:132);
  fncKeys=$nextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;
