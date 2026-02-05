**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Value List

Dcl-F DCTVALFP WorkStn ExtFile('APLLIB/DCTVALFP') SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALDP_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTVALDPPR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN  Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S sqlStm  varchar(5120);
Dcl-S orderBy varchar(1024);
Dcl-S Where Char(5);
Dcl-S SchSav Like(SchVal);
Dcl-S Option    like(APLDCT.Option);
Dcl-S DctNme    like(APLDCT.DctNme);
Dcl-S FldNme    like(APLDCT.FldNme);
Dcl-S ColTxt    like(APLDCT.ColTxt);
Dcl-S SortCode  packed(2:0);
Dcl-S Changed Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selEnmVal Like(EnmVal);
Dcl-S selEnmDes Like(EnmDes);

// Used to save options while paging through the data
Dcl-Ds optionsDs Qualified Inz;
  count  packed(5);
  Key    like(dta.key) Dim(1000);
  Option like(Option)  Dim(1000);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTVALDP');
    pmrDctNme Like(DctNme) Const;
    pmrFldNme Like(FldNme) Const;
    pmrEnmVal Like(EnmVal) Options(*nopass);
    pmrEnmDes Like(EnmDes) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;

  // For testing fill in dictionary and field name
  If %parms = 0;
    DctNme='APLDCT';
    FldNme='ACVROW';
  Else;
    DctNme=#$UPIFY(pmrDctNme);
    FldNme=#$UPIFY(pmrFldNme);
  EndIf;

  // If a value or description is passed position to it by default
  If %parms >= 3 and pmrEnmVal<>'';
    pos.EnmVal = pmrEnmVal;
    SortCode = 1;
  EndIf;
  If %parms >= 4 and pmrEnmDes<>'';
    pos.EnmDes = EnmDes;
    SortCode = 2;
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
      RefreshScreen();
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

  Close DCTVALFP;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 5;
    pmrKeyPressed=keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  If selected;
    If %parms >= 3;
      pmrEnmVal=selEnmVal;
    EndIf;
    If %parms >= 4;
      pmrEnmDes=selEnmDes;
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


// Refresh the screen back to how it was when the program was first called
Dcl-Proc RefreshScreen;

  // Refresh Only = *On;
  Sel    = '8';
  EnmVal = pos.EnmVal;
  EnmDes = pos.EnmDes;
  Clear Sel1;
  Clear EnmVal1;
  Clear EnmDes1;
  LoadSFL();

End-Proc;


// Update anything entered on the screen
Dcl-Proc UpdateScreen;
  Dcl-S i packed(5);

  // Save the SFL options entered on the current screen
  SaveOptions();

  // Check for entries on the first line and process them
  If Sel1 <> '' or EnmVal1 > '' or EnmDes1 > '';
    Sel     = Sel1;
    EnmVal  = EnmVal1;
    EnmDes  = EnmDes1;

    // Overide option to 8=position to if not entered
    If Sel1 = '';
      Sel = '8';
    EndIf;
    ProcessLine();
    Clear Sel1;
    Clear EnmVal1;
    Clear EnmDes1;

  Else;
    // Process saved SFL options
    For i = 1 To optionsDs.count;
      EnmVal  = optionsDs.key(i);
      Sel  = optionsDs.Option(i);
      ProcessLine();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
    EndFor;
    Clear optionsDs;
  EndIf;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Process SFL Options
Dcl-Proc ProcessLine;

  // handle position to
  If Sel = '8';
    SortCode = 1;
    Clear pos;
    If EnmVal <> '';
      pos.EnmVal = EnmVal;
    ElseIf EnmDes <> '';
      pos.EnmDes = EnmDes;
      SortCode = 2;
    EndIf;
    LoadSFL();

    // Handle Select
  ElseIf sel='1';
    selected=*on;
    selEnmVal=EnmVal;
    Exec SQL select enmDes into :selEnmDes
             from dctval
             Where DctNme=:DctNme
              and FldNme=:FldNme
              and EnmVal=:selEnmVal;
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
    If Sel1 = '1' and EnmVal1 = '';
      $ErrorMessage('DCT0001':'':error:EnmVal1@:'EnmVal':outRow:outCol:psDsPgmNam);
    EndIf;

    // check record in file
    Sel = Sel1;
    EnmVal = EnmVal1;
    EnmDes = EnmDes1;

    Clear found;
    Exec SQL
      Select '1' Into :found
      From   DCTVAL
      Where  DctNme = :DctNme and FldNme=:FldNme and EnmVal=:EnmVal
      Fetch First Row Only
      With NC;

    // validate Option
    If Sel <> '' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // required fields missing
    ElseIf Sel = '1' and EnmVal = '';
      $ErrorMessage('DCT1001':'':error:EnmVal1@:'EnmVal1':outRow:outCol:psDsPgmNam);

    EndIf;
  EndIf;

  // check for entries in the subfile
  For i = 1 To SFLPage;
    Chain i SFL;
    If %found;
      Sel@ = '';

      // Left Justify Option
      Sel=%trim(Sel);

      // * validate Option
      If %eof;
        Leave;
      Else;
        If Sel <> '' and not $ValidSFLOption(sel:optDs);
          $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        EndIf;
      EndIf;
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
    If dta(i).EnmVal <> '' or dta(i).enmDes <> '';
      EnmVal = dta(i).EnmVal;
      EnmDes = dta(i).EnmDes;
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

End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  If SortCode = 1;
    orderBy = 'Order By EnmVal';
  ElseIf SortCode = 2;
    orderBy = 'Order By EnmDes,EnmVal';
  EndIf;

  SchSav = SchVal;
  sqlStm = 'Select Distinct +
              EnmVal Key, +
              EnmVal, +
              EnmDes +
            From APLLIB.DCTVAL +
            Where DctNme='''+%trim(DctNme)+''' +
              and FldNme='''+%trim(FldNme)+''' +
              and AcvRow=''1''';

  // Select Search Values
  If SchVal > '';
    #$BLDSCHF(01)='EnmVal';
    #$BLDSCHF(02)='EnmDes';
    sqlStm += ' ' + Where + #$BLDSCH(SchVal:#$BLDSCHF);
  EndIf;

  // Handle position to if any position to values are entered
  If pos.EnmVal<>'' or
     pos.EnmDes<>'';
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


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // Add position to values

  // Position To DctNme
  If pos.EnmVal > '';
    SQLStmPos += ' and ucase(EnmVal) < uCase(''' + %trim(pos.EnmVal) + ''')';
  EndIf;

  // Position To Description
  If pos.EnmDes > '';
    SQLStmPos += ' and ucase(EnmDes) < uCase(''' + %trim(pos.EnmDes) + ''')';
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


// Saves options entered in the SFL to optionsDs
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5:0);

  // If enter is pressed try to select the line the cursor is on
  If keyPressed='ENTER' and not selected;
    Chain CsrRrn1 SFL;
    If %found and sel='';
      optionsDs.Count+=1;
      optionsDs.key(optionsDs.Count)=EnmVal;
      optionsDs.Option(optionsDs.Count)='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain sflRcd SFL;
    If %found and sel<>'';
      // Left Justify Option
      Sel=%trim(Sel);
      // add to optionsDs
      found=*off;
      For i = 1 To optionsDs.count;
        If optionsDs.key(i)=enmVal;
          optionsDs.Option(i)=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not found and sel<>'';
        optionsDs.count+=1;
        optionsDs.key(i)=enmVal;
        optionsDs.Option(i)=Sel;
      EndIf;
    EndIf;
  EndFor;

End-Proc;


// Retrieves an option for a row
Dcl-Proc GetOption;
  Dcl-Pi *n Like(APLDCT.Option);
    Key Like(dta.Key);
  End-Pi;
  Dcl-S i packed(5);

  // Loop through optionsDs and return an option if the customer is found
  For i = 1 To optionsDs.Count;
    If optionsDs.Key(i) = Key;
      Return optionsDs.Option(i);
    EndIf;
  EndFor;

  Return '  ';

End-Proc;


// This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;

  Exec SQL
  Declare DCTVAL Asensitive Scroll Cursor For DYNSQLStm;

  Open DCTVALFP;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Positition cursor to the description position to field
  $GetFieldLocation(PgmNme:'EnmDes1':outRow:outCol);

  // Get the field name
  Exec SQL Select ColTxt Into :ColTxt From DCTFld
           Where Ucase(DctNme)=Ucase(:DctNme) and Ucase(FldNme)=Ucase(:FldNme);

  // Build the screen title
  title=#$CNTR(%trim(ColTxt) + ' Prompt':40);

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:60);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:60);
  fncKeys=$NextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;
