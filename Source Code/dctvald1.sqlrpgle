**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Value List

Dcl-F DCTVALF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTVALD1PR // Always include the prototype for the current program
/Copy QSRC,DCTVALDZPR
/Copy QSRC,DCTVALB0PR

Dcl-S RRN1   Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN  Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S SchSav Like(SchVal);
Dcl-Ds filterDsSave Likeds(filterDs);
Dcl-Ds filterDs ExtName('DCTVALFZ') Qualified Inz End-DS;
Dcl-S Option    like(APLDCT.Option);
Dcl-S sqlStm  varchar(5120);
Dcl-S orderBy varchar(1024);
Dcl-S Where Char(5);
Dcl-S Changed Ind;
Dcl-S Display Ind;
Dcl-S Selects     Ind;
Dcl-S Maintenance Ind;

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
  Dcl-Pi *n ExtPgm('DCTVALD1');
    pmrDctNme Like(DctNme) Const;
    pmrFldNme Like(FldNme) Const;
    pmrEnmVal Like(EnmVal) Options(*nopass);
    pmrOption Like(Option) Const Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
    pmrEnmDes Like(EnmDes) Options(*nopass);
  End-Pi;

  // For testing fill in dictionary and field name
  If %parms = 0;
    DctNme='APLDCT';
    FldNme='ACVROW';
  Else;
    DctNme=#$UPIFY(pmrDctNme);
    FldNme=#$UPIFY(pmrFldNme);
  EndIf;

  // Sets the Option if passed
  If %parms >= 4;
    Option = pmrOption;
  EndIf;

  // If a value or description is passed position to it by default
  If %parms >= 3 and pmrEnmVal<>'';
    pos.EnmVal = pmrEnmVal;
    filterDs.SrtCde = 1;
  EndIf;
  If %parms >= 6 and pmrEnmDes<>'';
    pos.EnmDes = EnmDes;
    filterDs.SrtCde = 2;
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
      RefreshScreen();
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
      If selected;
        Leave;
      EndIf;
    EndIf;

  EndDo;

  Close DCTVALF1;

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
    If %parms >= 6;
      pmrEnmDes=selEnmDes;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  Write FOOTER;
  Exfmt SFLCTL;

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
  outRow=csrRow;
  outCol=csrCol;

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
  Clear AcvDes1;
  LoadSFL();

End-Proc;


// Prompt for filters and reload the SFL
Dcl-Proc Filter;

  filterDsSave = filterDs;
  Callp DCTVALDZ(filterDs:keyPressed);

  Select;
    When keyPressed = 'F3';

    When keyPressed = 'F12';
      keyPressed = '';

    When filterDsSave <> filterDs;
      LoadSFL();
  EndSl;

End-Proc;


// Update anything entered on the screen
Dcl-Proc UpdateScreen;
  Dcl-S i packed(5);

  // Save the SFL options entered on the current screen
  SaveOptions();

  // Check for entries on the first line and process them
  If Sel1 <> '' or EnmVal1 > '' or EnmDes1 > '' or AcvDes1 > '';
    Sel     = Sel1;
    EnmVal  = EnmVal1;
    EnmDes  = EnmDes1;
    AcvDes  = AcvDes1;
    // Overide option to 8=position to if not entered
    If Sel1 = '';
      Sel = '8';
    EndIf;
    ProcessLine();
    Clear Sel1;
    Clear EnmVal1;
    Clear EnmDes1;
    Clear AcvDes1;
  Else;
    // Process saved SFL options
    For i = 1 To optionsDs.count;
      EnmVal = optionsDs.key(i);
      Sel    = optionsDs.Option(i);
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
    filterDs.SrtCde = 1;
    Clear pos;
    If EnmVal > '';
      pos.EnmVal = EnmVal;
    ElseIf EnmDes > '';
      pos.EnmDes = EnmDes;
      filterDs.SrtCde = 2;
    ElseIf AcvDes > '';
      pos.AcvDes = AcvDes;
      filterDs.SrtCde = 3;
    EndIf;
    LoadSFL();

    // Handle Select
  ElseIf sel='1' and Selects;
    selected=*on;
    selEnmVal=EnmVal;
    selEnmDes=EnmDes;

    // Handle all other options via the B0 program
  ElseIf Sel<>'';
    DCTVALB0(DctNme:FldNme:EnmVal:Sel:keyPressed);
    // If adding a new entry, possition to it
    If Sel = '1' and Maintenance;
      pos.EnmVal = EnmVal;
      pos.EnmDes = EnmDes;
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

  RRN1  = 1;
  error = *Off;


  // check for entries on the first line
  If Sel1 <> '';

    // if they enter an option other than postition to and create make sure they
    // enter the value
    If Sel1 > '1' and Sel1 <> '8' and EnmVal1 = '';
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
    ElseIf Sel <> '8' and Sel <> '1' and EnmVal = '';
      $ErrorMessage('DCT1001':'':error:EnmVal1@:'EnmVal1':outRow:outCol:psDsPgmNam);

      // on deactivate, make sure it exists
    ElseIf Sel = '4' and Maintenance;
      Exec SQL
        Select '1' Into :found
        From DCTVAL
          Where DctNme = :DctNme
            and AcvRow    = '1'
        Fetch First Row Only;

      If sqlState > '02';
        $ErrorMessage('':'Enumeration value not found for Inactivation':
                      error:EnmVal1@:'EnmVal1':outRow:outCol:psDsPgmNam);
      EndIf;

    ElseIf Sel = '13' and Maintenance;
      Exec SQL
        Select '1' Into :found
        From DCTVAL
        Where DctNme = :DctNme
          and AcvRow = '0'
      Fetch First Row Only;

      If sqlState > '02';
        $ErrorMessage('DCT1013':'':error:Sel1@:'Sel1':outRow:outCol:psDsPgmNam:EnmVal1@);
      EndIf;

      // validate itm
    ElseIf found and Sel = '1' and Maintenance;
      $ErrorMessage('DCT1101':'':error:EnmVal1@:'EnmVal1':outRow:outCol:psDsPgmNam);

      // validate itm
    ElseIf not found and Sel = '1' and not Maintenance
      or not found and Sel <> '1' and Sel <> '8';
      $ErrorMessage('DCT1102':'':error:EnmVal1@:'EnmVal1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 to RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      // * validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs)
      or Sel = '1' and Maintenance;
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);

      ElseIf Sel = '4' and AcvDes = '0';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);

      ElseIf Sel = '13' and AcvDes = '1';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
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
      AcvDes = dta(i).AcvDes;
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
  If filterDs.SrtCde = 1;
    orderBy = 'Order By EnmVal';
  ElseIf filterDs.SrtCde = 2;
    orderBy = 'Order By EnmDes, EnmVal';
  ElseIf filterDs.SrtCde = 3;
    orderBy = 'Order By AcvDes, EnmVal';
  EndIf;

  SchSav = SchVal;
  Where = 'Where';
  sqlStm = 'With DATALIST as ( +
              Select Distinct +
                DCTVAL.EnmVal key, +
                DCTVAL.EnmVal, +
                DCTVAL.EnmDes, +
                coalesce(DES.EnmDes,''Error'') AcvDes +
              From DCTVAL +
              left join DCTVAL as DES on DES.DctNme=''APLDCT'' +
                              and DES.FldNme=''ACVROW'' +
                              and DES.EnmVal=DCTVAL.AcvRow +
              Where DCTVAL.DctNme='''+%trim(DctNme)+''' +
                and DCTVAL.FldNme='''+%trim(FldNme)+''' ) +
            Select * From DATALIST';

  // Name Contains
  If filterDs.EnmVal > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(EnmVal) Like uCase(''%' + %trim(filterDs.EnmVal) + '%'')';
    Where = 'and';
  EndIf;

  // Description Contains
  If filterDs.EnmDes > '';
    sqlStm += ' ' + Where + ' '
      + ' ucase(EnmDes) Like uCase(''%' + %trim(filterDs.EnmDes) + '%'')';
    Where = 'and';
  EndIf;

  // Active Row
  If filterDs.AcvDes <> '';
    sqlStm += ' ' + Where + ' uCase(AcvDes) = Ucase(''' + %trim(filterDs.AcvDes) + ''')';
    Where = 'and';
  EndIf;

  // Select Search Values
  If SchVal > '';
    #$BLDSCHF(01)='EnmVal';
    #$BLDSCHF(02)='EnmDes';
    #$BLDSCHF(03)='AcvDes';
    sqlStm += ' ' + Where + #$BLDSCH(SchVal:#$BLDSCHF);
    Where = 'and';
  EndIf;

  // handle position to if any position to values are entered
  If pos.EnmVal<>'' or
     pos.EnmDes<>'' or
     pos.AcvDes<>'';
    PositionSFL();
  EndIf;

  // Add order by
  sqlStm += ' ' + orderBy;

  // Create and open cursor for selected records
  Exec SQL Close SQLCrs;
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;

  // Get total number of records for selected data
  Exec SQL GET DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  // Add position to values

  // Position To EnmVal
  If pos.EnmVal > '';
    SQLStmPos += ' ' + Where + ' ucase(EnmVal) < uCase(''' + %trim(pos.EnmVal) + ''')';
    Where = 'and';
  EndIf;

  // Position To Description
  If pos.EnmDes > '';
    SQLStmPos += ' ' + Where + ' ucase(EnmDes) < uCase(''' + %trim(pos.EnmDes) + ''')';
    Where = 'and';
  EndIf;

  // Position to Active
  If pos.AcvDes > '';
    SQLStmPos += ' ' + Where + ' ucase(AcvDes) < uCase(''' + %trim(pos.AcvDes) + ''')';
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


// Saves options entered in the SFL to optionsDs
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5);

  // If in select mode and enter is pressed try to select the line the cursor is on
  If Selects and keyPressed='ENTER' and not selected;
    Chain CsrRrn1 SFL;
    If %found and sel='';
      optionsDs.Count+=1;
      optionsDs.key(optionsDs.Count)=EnmVal;
      optionsDs.Option(optionsDs.Count)='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 to RRN1sv;
    Chain(e) sflRcd SFL;
    If %found;
      // Left Justify Option
      Sel=%trim(Sel);
      // add to optionsDs
      found=*off;
      For i = 1 To optionsDs.Count;
        If optionsDs.key(i)=EnmVal;
          optionsDs.Option(i)=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not found and sel<>'';
        optionsDs.count+=1;
        optionsDs.key(i)=EnmVal;
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

  Open DCTVALF1;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // positition cursor to the dictionary position to field
  $GetFieldLocation(PgmNme:'EnmVal1':outRow:outCol);

  // Get the dictionary name
  Exec SQL Select Des Into :DctDes From DCTMST Where Ucase(DctNme)=Ucase(:DctNme);

  // Get the field name
  Exec SQL Select ColTxt Into :ColTxt From DCTFld
           Where Ucase(DctNme)=Ucase(:DctNme) and Ucase(FldNme)=Ucase(:FldNme);

  // Sets the default filter options
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
  optDs=$GetSFLOptions(psdsPgmNam:Option);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs);
  fncKeys=$NextFunctionKeys(fncDs);

  LoadSFL();

End-Proc;
