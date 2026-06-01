**free
Ctl-Opt Option(*SrcStmt:*nounref) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Help Master List

dcl-f PGMHLPF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMHLPD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,PGMHLPD1PR // Always include the prototype for the current program
/Copy QSRC,PGMHLPB0PR
/Copy QSRC,HLPMSTB1PR // rebuild help panel group
/Copy QSRC,HLPDTLD1PR // Update Help Detail

Dcl-S RRN1   Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S  SchSav Like(SchVal);
Dcl-Ds filterDs qualified;
  srtCde like(APLDCT.srtCde);
END-DS;

// Used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

Dcl-S Option  like(APLDCT.Option);

Dcl-S sqlStm  varchar(20000);
Dcl-S sqlStm2 varchar(20000);
Dcl-S sqlStm4 varchar(20000);
Dcl-S orderBy varchar(1024);
Dcl-S Where Char(5);

Dcl-S dataEntered Ind; // set on if anything is entered on the screen
Dcl-S Changed     Ind;

Dcl-S dspFle Like(APLDCT.dspFle);

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
  Dcl-Pi *n ExtPgm('PGMHLPD1');
    pmrPgmNme Like(APLDCT.DctNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move input parameters to globals so they can be used everywhere
  pgmNme = pmrPgmNme;

  lib = 'APLLIB';

  // The file name is the same as the program name but the D in character 7 is replaced with an F
  // Example: INVINQD1 = INVINQF1
  // dspFle = %subst(pgmNme:1:6) + 'F' + %subSt(pgmNme:8:3);
  //
  // Get the display file name from PGMMST
  Exec SQL Select dspFle into :dspFle from PGMMST where pgmNme = :pgmNme;

  // Sets the Option if passed
  If %Parms >= 2;
    Option = pmrOption;
  EndIf;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' or KeyPressed='F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs);
      $ErrorMessage('APL0001':keyPressed);
    ElseIf keyPressed = 'F3';
      Leave;
    ElseIf keyPressed = 'F5';
      Clear schVal;
      ProgramInitialization();
    ElseIf keyPressed = 'F9';
      RebuildPanelGroup();
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

  Close PGMHLPF1;

  // Handle return options

  // Send back Key pressed if passed
  If %Parms >= 3;
    pmrKeyPressed=KeyPressed;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

  // Load message SFL
  Write MSGCTL;

  // Actually Display the Screen
  Write FOOTER;
  ExFmt SFLCTL;

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
    $getFieldLocation(PgmNme1:csrFld:outRow:OutCol);
  EndIf;

  // Left Justify Option
  Sel1=%trim(Sel1);

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

  dataEntered=*off;

End-Proc;


// Rebuild the live panel group for the screen
Dcl-Proc RebuildPanelGroup;
  Dcl-s srcLib char(10);
  Dcl-s srcFle char(10) Inz('QSRC');
  Dcl-s srcMbr char(10);
  Dcl-s devLib char(10);

  // get screen name
  srcMbr=%subst(pgmNme:1:6) + 'F' + %subst(pgmNme:8:3);

  // get the dev lib for the current user
  Exec SQL Select upDLib into :devLib from SYS249IPF where upUser = :user;

  // see if the screen file is checked out, if it is build in the DevLib, else build live
  if #$isMbr(devLib:srcFle:srcMbr);
    srcLib = devLib;
  Else;
    srcLib = 'APLLIB';
  ENDIF;

  // Create the help panel group
  HLPMSTB1(srcLib:srcFle:srcMbr);
  $ErrorMessage('':'Help panel group rebuild sent, check job log for results.');


End-Proc;


// Update anything entered on the screen
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
      fldNme  = %subst(optionsArray(1).key:1:10);
      val     = %subst(optionsArray(1).key:11:10);
      Sel  = optionsArray(1).option;
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

  If fldRow > 0;
    filterDs.SrtCde = 1;
  ElseIf fldCol > 0;
    filterDs.SrtCde = 2;
  ElseIf FldNme > '';
    filterDs.SrtCde = 3;
  ElseIf val > '';
    filterDs.SrtCde = 4;
  ElseIf hlpTypd > '';
    filterDs.SrtCde = 5;
  ElseIf lneCnt > 0;
    filterDs.SrtCde = 6;
  ElseIf txt > '';
    filterDs.SrtCde = 7;
  ElseIf refFle > '';
    filterDs.SrtCde = 8;
  ElseIf refFld > '';
    filterDs.SrtCde = 9;
  ElseIf fldDes > '';
    filterDs.SrtCde = 10;
  EndIf;

End-Proc;


// Process SFL Options
Dcl-Proc ProcessLine;
  dcl-s pmDctNme Like(APLDCT.dctNme);
  dcl-s pmdspFle Like(APLDCT.dspFle);
  dcl-s pmFldNme Like(APLDCT.fldNme);
  dcl-s pmVal    Like(APLDCT.val);
  dcl-s pmOption Like(APLDCT.Option);
  dcl-s pmKeyPressed Like(keyPressed);

  // handle position to
  If Sel = '8';

    pos=sflFields;
    SetSrtCde();

  // Handle Update Dictionary Defaults
  ElseIf Sel = '6';
    Exec SQL Select Max(refFle), Max(refFld) into :pmDctNme, :pmFldNme
             From SCRLOC
             where mbr = :dspFle
               and lib = :lib
               and fldCol <> 0
               and fldNme = :fldNme;
    pmDspFle = '';
    pmVal    = val;
    pmOption = '2';
    pmKeyPressed  = '';
    HLPDTLD1(pmDctNme:pmFldNme:pmDspFle:pmVal:pmOption:pmKeyPressed);

  // Handle Update System Defaults
  ElseIf Sel = '7';
    pmDctNme = '';
    pmFldNme = fldNme;
    pmDspFle = '';
    pmVal    = val;
    pmOption = '2';
    pmKeyPressed  = '';
    HLPDTLD1(pmDctNme:pmFldNme:pmDspFle:pmVal:pmOption:pmKeyPressed);

  // Handle all other options via the B0 program
  ElseIf Sel<>'';
    PGMHLPB0(pgmNme:dspFle:fldNme:val:Sel:keyPressed);
    // Flag the SFL to reload if they didn't press F3
    If keyPressed <> 'F3';
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
  Error = *Off;

  // check for entries on the first line
  If Sel1<>'';

    // validate Option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('FAB0007':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);
    EndIf;

  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %Found;
      Sel@ = '';
      // Left Justify Option
      Sel=%Trim(Sel);
      //* Validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs);
        $ErrorMessage('FAB0007':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '6' and refFle = '';
        $ErrorMessage('':'Error - does not reference a dictionary.'
                      :error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
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
  SflClr = *on;
  Write SFLCTL;
  SflClr = *off;
  SflDsp = *on;

  // Add the offest and limit to the statement and read in one screen worth of data
  Clear dta;
  sqlStm2 += ' Limit ' + %char(SFLPage) + ' Offset ' + %char(CurrentRow) ;
  Exec SQL Prepare sqlStm5 From :sqlStm2;
  Exec SQL Declare SQLCrs5 Cursor For sqlStm5;
  Exec SQL Open  SQLCrs5;
  Exec SQL Fetch SQLCrs5 For :SFLPage rows Into :dta;
  Exec SQL Close SQLCrs5;

  // Load SFL from the array
  rrn1=0;
  For i = 1 To SFLPage;
    If Dta(i).key<>'' or dta(i).hlpTypD<>'';
      Eval-Corr sflFields=dta(i);
      Sel = GetOption(key);
      RRN1 += 1;
      if txt = 'Not Defined';
        $setAttribute(txt@:'RED');
      Else;
        $setAttribute(txt@:'');
      ENDIF;
      Write SFL;
      // if a position to is provided move the cursor to this entry
      If positionToKey=dta(i).key;
        $GetFieldLocation(pgmNme1:'SEL':outRow:outCol);
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
    $ErrorMessage('':$buildSFLMessage(numberOfRows:totalNumberOfRows:sflPage:currentRow:rrn1));
  EndIf;


End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;
  Dcl-S Trash Char(10);

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %Trim(orderByDS.value(filterDs.SrtCde))+',fldRow,fldCol,fldNme,val,key';

  If schval<>schSav;
    currentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  sqlStm2 = 'Select * From Table(PGMHLPT1('''+%trim(pgmNme)+''','''+%trim(dspFle)+''','''+%trim(lib)+'''))';

  // Get count of lines without help text
  sqlStm4 = 'Select count(*) from (' +sqlStm2 + ') Where lnecnt = 0';
  Exec SQL Prepare sqlStm4 From :sqlStm4;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch next from SQLCrs4 into :misCnt;
  Exec SQL Close SQLCrs4;


  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm2;
  Exec SQL Declare SQLCrs3 Insensitive Scroll Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Select Search Values
  If SchVal > '';
    sqlStm2 += ' ' + Where + $BuildSearch(pgmNme1:SchVal);
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
  Exec SQL GET DIAGNOSTICS :numberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

  // Calulate counts and show message if any help missing
  totCnt = numberOfRows;
  hlpCnt = totCnt - misCnt;
  if misCnt = 0;
    $setAttribute(notxt@:'ND');
  Else;
    $setAttribute(notxt@:'Red');
  ENDIF;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm2;

  // Add position to values

  // **CHANGE - Add position to values
  If Pos.fldRow > 0;
    sqlStmPos += ' ' + Where + ' ucase(fldRow) < ' + %char(Pos.fldRow);
    Where = 'and';
  ElseIf Pos.fldCol > 0;
    sqlStmPos += ' ' + Where + ' ucase(fldCol) < ' + %char(Pos.fldCol);
    Where = 'and';
  ElseIf Pos.fldNme > '';
    sqlStmPos += ' ' + Where + ' ucase(FldNme) < uCase(''' + %trim(Pos.fldNme) + ''')';
    Where = 'and';
  ElseIf Pos.val > '';
    sqlStmPos += ' ' + Where + ' ucase(val) < uCase(''' + %trim(Pos.val) + ''')';
    Where = 'and';
  ElseIf Pos.hlpTypD > '';
    sqlStmPos += ' ' + Where + ' ucase(hlpTypD) < uCase(''' + %trim(Pos.hlpTypD) + ''')';
    Where = 'and';
  ElseIf Pos.lneCnt > 0;
    sqlStmPos += ' ' + Where + ' ucase(lneCnt) < ' + %char(Pos.lneCnt);
    Where = 'and';
  ElseIf Pos.txt > '';
    sqlStmPos += ' ' + Where + ' ucase(txt) < uCase(''' + %trim(Pos.txt) + ''')';
    Where = 'and';
  ElseIf Pos.refFle > '';
    sqlStmPos += ' ' + Where + ' ucase(refFle) < uCase(''' + %trim(Pos.refFle) + ''')';
    Where = 'and';
  ElseIf Pos.refFld > '';
    sqlStmPos += ' ' + Where + ' ucase(refFld) < uCase(''' + %trim(Pos.refFld) + ''')';
    Where = 'and';
  ElseIf Pos.fldDes > '';
    sqlStmPos += ' ' + Where + ' ucase(FldDes) < uCase(''' + %trim(Pos.fldDes) + ''')';
    Where = 'and';
  EndIf;

  // Add order by
  SQLStmPos += ' ' + OrderBy;

  Exec SQL Prepare SQLStmPos From :SQLStmPos;
  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;
  Exec SQL Open SQLCrsPos;
  Exec SQL GET DIAGNOSTICS :currentRow = DB2_NUMBER_ROWS;
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
    If %Found;
      // Left Justify Option
      Sel=%Trim(Sel);
      // add to optionsArray
      found=*off;
      For i = 1 To optionsCount;
        If optionsArray(i).key=Key;
          optionsArray(i).option=Sel;
          found=*on;
          Leave;
        EndIf;
      EndFor;
      If not Found and sel<>'';
        optionsCount+=1;
        optionsArray(i).key=Key;
        optionsArray(i).option=Sel;
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
    sortStm='select ' + %Trim(orderByDS.value(filterDs.SrtCde)) + ' +
             From ('+sqlstm2+') as a +
             Where Key='''+%char(optionsArray(i).key)+'''';
    Exec SQL Prepare sortStm From :sortStm;
    Exec SQL Declare sortCrs Cursor For sortStm;
    Exec SQL Open sortCrs;
    Exec SQL Fetch Next From sortCrs Into :temp;
    Exec SQL Close sortCrs;
    optionsArray(i).sort=temp;
  EndFor;

// sort options by sort field then key
sorta %SUBARR(optionsArray : 1 : optionsCount) %FIELDS(sort : Key);

End-Proc;


// Retrieves an option for a row
// *** Do not change anything in here ***
Dcl-Proc GetOption;
  Dcl-Pi *n Like(APLDCT.option);
    Key Like(dta.Key);
  End-Pi;
  Dcl-S i packed(5);

  // Loop through optionsArray and return an option if the customer is found
  For i = 1 To optionsCount;
    If optionsArray(i).key = Key;
      Return optionsArray(i).option;
    EndIf;
  EndFor;

  Return '  ';

End-Proc;


//This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;

  Exec SQL
       Declare PGMHLP Asensitive Scroll Cursor For DYNSQLStm;

  // Open the screen DSPF if it is not already open
  If not %open(PGMHLPF1); // **change
    Open PGMHLPF1; // **change
  EndIf;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme1=psdsPgmNam;

  // positition cursor to the dictionary position to field
  $getFieldLocation(pgmNme1:'dctNme1':outRow:OutCol);

  // Sets the default filter options
  clear filterDs;
  filterDs.SrtCde = 1;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow=0;

  mode='Update';

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option:131);
  options=$nextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:131);
  fncKeys=$nextFunctionKeys(fncDs);

  // get program description
  Exec SQL Select Des into :des from PGMMST where pgmNme = :pgmNme;

  LoadSFL();

End-Proc;
