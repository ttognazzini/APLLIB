**free
Ctl-Opt Option(*SrcStmt) Main(Main) srtseq(*langidshr) DftActGrp(*No) BndDir('APLLIB') actgrp(*new);

// SQL Query Manager

Dcl-F DSPFLEF1 workstn sfile(SFL:RRN1) InfDS(dspDs) usropn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DSPFLED1_@ // auto generated data structures for field attribute fields
/Copy QSRC,DSPFLED1PR // Always include the prototype for the current program
/Copy QSRC,DSPFLEC1PR // Get library of file

// globals for input parameters
Dcl-S fleLib char(10);
Dcl-S fleNme char(10);

Dcl-S Where varchar(5);
Dcl-S sqlStm varchar(5000);
Dcl-S sqlStmCnt like(sqlStm); // used to get the count of total records

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S RRN1SV Like(OutRRN1); // the relative record number for the SFL
Dcl-S CurrentRow packed(9); // the postion in the data set for the start of the current screen
Dcl-S NumberOfRows packed(9); // the total number of rows in the data set
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S schSav Like(schVal); // used to see if the search field changed, which forces a SFL reload
Dcl-Ds filterDsSave Likeds(filterDs); // used to see if the filter options changed, which forces a SFL reload
Dcl-Ds filterDs ExtName('DCTMSTFZ') Qualified Inz End-Ds; // contains the filter and sort options from DZ

Dcl-S option  like(APLDCT.option); // global variable to store the option parameter in

Dcl-S orderBy Varchar(1024); // used to build the order by clause

Dcl-S dataEntered Ind; // set on if anything is entered on the screen
Dcl-S Changed     Ind; // set on if any of the SFL entries are changed, forces a reload of the SFL
Dcl-S Display     Ind; // set on if the program is in inquiry mode, option parameter=5
Dcl-S Selects     Ind; // set on if the program is in select mode, option parameter=1
Dcl-S Maintenance Ind; // set on if the program is in update mode, option parameter=2

// Used for selection if in select mode
// **ChangedFromMassReplace, change the name of the key field, if there are more than one addtional fields
// will need to be added.
Dcl-S selected  Ind;
Dcl-S selfldNme Like(APLDCT.fldNme);

// Used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  option like(option);
  Sort   Char(132);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;


// Process Screen F12
Dcl-Proc Main;
  Dcl-Pi *n;
    pmrFleLib char(20);
  End-Pi;

  If %parms() >= 1;
    fleNme = %subst(pmrFleLib:1:10);
    fleLib = %subst(pmrFleLib:11:10);
  Else;
    fleNme = 'ASSEMBLY';
    fleLib = 'MRPS38S';
  EndIf;


  ProgramInitialization();


  DoU 1=2;
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
      If selected or (%parms<>0 and not dataEntered);
        Leave;
      EndIf;
    EndIf;

  EndDo;


  Close DSPFLEF1;

End-Proc;


// Write message SFL, Display the screen, reset errors
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // This message is for the number of entries, paging information and filters, it is not shown if there are no records
  $ErrorMessage('':$BuildSFLMessage(NumberOfRows:totalNumberOfRows:SFLPage:CurrentRow:RRN1));

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  Write FOOTER;
  Exfmt SFLCTL;

  // Convert key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // Set the initial SFL position to the one the cursor is on or the top
  // if page down was pressed and the cursor is not on a SFL row set to bottom
  If keyPressed = 'PAGEDOWN' and CsrRRN1 = 0 and EOF;
    OutRRN1 = RRN1;
  ElseIf CsrRRN1 = 0;
    OutRRN1 = 1;
  Else;
    OutRRN1 = CsrRRN1;
  EndIf;

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow = csrRow;
  outCol = csrCol;

  // This logic moves the cursor to the start of a field if it was left somewhere in the middle
  If csrFld <> '';
    $GetFieldLocation(PgmNme:csrFld:outRow:outCol);
  EndIf;

  // Left Justify Option
  Sel1=%trim(Sel1);

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

  dataEntered = *off;

End-Proc;


// Prompt for filters and reload the SFL
// **ChangedFromMassReplace, change the name of the filter program
Dcl-Proc Filter;

  filterDsSave = filterDs;
  // Callp DCTMSTDZ(filterDs:keyPressed);

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
  If schval <> schSav;
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
      // fleLibFld  = optionsArray(1).key;
      Sel  = optionsArray(1).option;
      positionToKey = optionsArray(1).key;
      ProcessLine();
      PopOptions();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
    EndDo;
  EndIf;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Process SFL Options
// Anything that needs to happen based on the SFL option needs to be handled in the navigator (XXXXXXB0)
// **ChangedFromMassReplace, the filter program and keyfields need to be changed,
//   also navigator parameters might need to be changed, check them
Dcl-Proc ProcessLine;
  If sel <> '';
    dataEntered = *on;
  EndIf;

  // Handle position to
  If Sel = '8';
    pos=sflFields;
    SetSrtCde();

    // Handle Select
  ElseIf sel = '1' and Selects;
    selected = *on;
    selfldNme = fldNme;

    // Handle all other options via the B0 program
  ElseIf Sel <> '';
    // DSPFLEB0(dctMstIdn:Sel:keyPressed);
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


// Process F6=Add
Dcl-Proc Add;
  // Dcl-S pmIdn like(APLDCT.idn);
  Dcl-S pmOption like(APLDCT.option);
  pmOption = '1';

  // DSPFLEB0(pmIdn:pmOption:keyPressed);

  filterDs.SrtCde = 1;
  LoadSFL();

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
  If Sel1 <> '';

    // Check record in file, move top line entries into SFL fields
    Sel = Sel1;
    sflFields = line1;

    // Validate option
    If Sel <> '' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the flield name must be provided
    ElseIf not (sel in %list('8':'1')) and fldNme = '';
      $ErrorMessage('DCT1001':'':error:fldNme1@:'fldNme1':outRow:outCol:psDsPgmNam);

      // If any option but add or position to, make sure the entry exists
    ElseIf not (Sel in %list('1':'8')) and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:fldNme1@:'fldNme1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel = %trim(Sel);
      // * Validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs)
      or Sel = '1' and Maintenance;
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow += sflRcd - 1; // required to move to the correct SFL line
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

  Changed = *Off;

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

  // Load SFL from the array
  RRN1 = 0;
  For i = 1 To SFLPage;
    If dta(i).fldNme <> '';
      Eval-Corr sflFields = dta(i);
      Sel = GetOption(dta(i).key);
      // make the row red if inactive
      // If acvDes = 'Inactive';
      //   $SetAttribute(rowClr@:'Red');
      // Else;
      $SetAttribute(rowClr@:'');
      // EndIf;
      RRN1 += 1;
      Write SFL;
      // if a position to is provided move the cursor to this entry
      If positionToKey = dta(i).key;
        $GetFieldLocation(pgmNme:'SEL':outRow:outCol);
        outRow += i - 1; // required to move to the correct SFL line
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


Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval <> schSav;
    CurrentRow = 0;
    dataEntered = *on;
    If schVal <> '' and Selects; // if in select mode and searching, position to selection column
      $GetFieldLocation(PgmNme:'sel':outRow:outCol);
    EndIf;
  EndIf;
  schSav = SchVal;

  Where = 'Where';

  sqlStm = '+
    Select * +
    From ( +
      Select +
        system_table_schema || system_table_name || system_column_name key, +
        ordinal_position fldSeq, +
        system_column_name fldNme, +
        Coalesce( +
          case when data_type in (''DECIMAL'',''NUMERIC'') and coalesce(numeric_scale,0) > 0 +
              then trim(data_type)||''('' || length || '',''||coalesce(numeric_scale,0)||'')'' +
              when data_type in (''DECIMAL'',''NUMERIC'',''CHAR'',''VARCHAR'',''CLOB'',''GRAPHIC'', +
                                  ''VARG'',''DBCLOB'',''BINARY'',''VARBIN'',''BLOB'') +
              then trim(data_type)||''(''||length||'')'' +
              else data_type end +
            ,''Error'') fldTyp, +
        case when cast(column_text as char(50) ccsid 37) <> '''' then cast(column_text as char(50) ccsid 37) +
            when column_name <> system_column_name then column_name +
            when cast(column_heading as char(60) ccsid 37) <> '' '' +
            then trim(substr(cast(column_heading as char(60) ccsid 37),1,20)) || '' '' || +
                  trim(substr(cast(column_heading as char(60) ccsid 37),21,20)) || '' '' || +
                  trim(substr(cast(column_heading as char(60) ccsid 37),41,20)) +
            else '''' end fldTxt, +
        column_name nmeSql +
      From syscolumns2 +
      Where system_table_name = ''' + %trim(fleNme) + ''' +
        and system_table_schema = ''' + %trim(fleLib) + ''' +
    )';
  // Get the total number of records before any filters, this is used for a message at the bottom
  sqlStmCnt = 'Select count(*) from (' + sqlStm + ')';
  Exec SQL Prepare sqlStm3 From :sqlStmCnt;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Fetch next from sqlCrs3 into :totalNumberOfRows;
  Exec SQL Close SQLCrs3;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' ' + Where + $BuildSearch(pgmNme:SchVal);
    Where = 'and';
  EndIf;

  // handle position to if any position to values are entered
  If pos <> posDefault;
    PositionSFL();
  EndIf;

  // Add order by
  sqlStm += ' ' + orderBy;

  // Create and open cursor for selected records
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;

  // Get total number of records for selected data
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;


End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;
  Dcl-S exists char(1);

  // Open the screen DSPF if it is not already open
  If not %open(DSPFLEF1); // **change
    Open DSPFLEF1; // **change
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow = 0;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk = 'MAIN';
  pgmNme = psdsPgmNam;

  // **CHANGE positition cursor to the perfered field
  If option = '1' and %subst(schVal:1:1) = '?' or schVal = '';
    schVal = '';
    $GetFieldLocation(PgmNme:'schVal':outRow:outCol);
  ElseIf option = '1';
    $GetFieldLocation(PgmNme:'sel':outRow:outCol);
  Else;
    $GetFieldLocation(PgmNme:'fldNme1':outRow:outCol);
  EndIf;

  // Sets the default filter options
  Clear filterDs;
  filterDs.SrtCde = 1;
  filterDs.acvDes = 'Active';

  // Sets on indicators for the mode and the mode name
  Selects = *Off;
  Display = *Off;
  Maintenance = *Off;
  If option = '1';
    Selects = *On;
    mde='Select';
  ElseIf option = '5';
    Display = *On;
    mde='Inquiry';
  Else;
    Maintenance = *On;
    mde='Update';
  EndIf;

  // Get Valid SFL Options and Function keys data structures
  optDs = $GetSFLOptions(psdsPgmNam:option:132);
  options = $NextSFLOption(optDs);
  fncDs = $GetFunctionKeys(psdsPgmNam:option:optDs:132);
  fncKeys = $NextFunctionKeys(fncDs);

  // If the library iblnk or equales library list, try to get the library
  // from the first instance of the object in the library list
  Clear objTyp;
  DSPFLEC1(fleLib:fleNme:exists:objTyp);
  If exists = 'N';
    $ErrorMessage('':'Error File not found');
  EndIf;

  keyFld = #$GetKeys(fleLib:fleNme);

  fleLibHdr = %trim(fleLib) + '/' + %trim(fleNme);

  LoadSFL();

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/copy QSRC,DSPFLED1_2


// Copies in procedures SaveOptions, PopOptions, SoprtOptions and Get Options
// These never change so no point in duplicating the code in each program
/Copy QSRC,$options
