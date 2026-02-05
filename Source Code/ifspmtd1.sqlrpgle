**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB/APLLIB') Main(Main);

// IFS File/Folder Prompt

Dcl-F IFSPMTF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn ExtFile('APLLIB/IFSPMTF1');

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,IFSPMTD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,IFSPMTD1PR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S RRN1SV Like(OutRRN1); // the relative record number for the SFL
Dcl-S CurrentRow packed(9); // the postion in the data set for the start of the current screen
Dcl-S NumberOfRows packed(9); // the total number of rows in the data set
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S SchSav Like(SchVal); // used to see if the search field changed, which forces a SFL reload
Dcl-Ds filterDsSave Likeds(filterDs); // used to see if the filter options changed, which forces a SFL reload
Dcl-Ds filterDs qualified;
  SrtCde packed(2);
End-Ds; // contains the filter and sort options from DZ

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
Dcl-S selected  Ind;
Dcl-S selRtnPth varchar(999);
Dcl-S pthNme varchar(999);

// Used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);


// Globals for parameters
Dcl-S strDir varchar(999);
Dcl-S alwFlr varchar(1);
Dcl-S alwFle varchar(1);

Dcl-S curDir varchar(999);

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
  Dcl-Pi *n ExtPgm('IFSPMTD1');
    pmrStrDir varchar(999) const; // Starting Directory
    pmrRtnPth varchar(999); // returned path
    pmrAlwFlr varchar(1) options(*nopass:*omit) const; // Allow a folder to be selected - Default N
    pmrAlwFle varchar(1) options(*nopass:*omit) const; // Allow a file to be selected - Default Y
    pmrKeyPressed Like(keyPressed) options(*nopass:*omit); // key pressed, = ENTER if selected
    pmrSchVal like(APLDCT.schVal) options(*nopass:*omit) const; // Optional default search string
  End-Pi;

  // override to select, that is all this program is used for
  Option = '1';

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  // pull in allow folder/file parms or default
  If %parms>=1;
    strDir=pmrStrDir;
  Else;
    strDir='/tog';
  EndIf;
  curDir = strDir;

  // pull in allow folder/file parms or default
  If %parms>=3 and %addr(pmrAlwFlr)<> *null and pmrAlwFlr = 'Y';
    alwFlr=pmrAlwFlr;
  Else;
    alwFlr='N';
  EndIf;
  If %parms>=5 and %addr(pmrAlwFle)<> *null and pmrAlwFle = 'N';
    alwFle=pmrAlwFle;
  Else;
    alwFle='Y';
  EndIf;

  // if a search value was passed, force it into the search parameter
  If %parms>=6 and %addr(pmrSchVal)<> *null;
    schVal=pmrSchVal;
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
    ElseIf keyPressed = 'F7';
      UpFolder();
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

  Close IFSPMTF1;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 5;
    pmrKeyPressed=keyPressed;
  EndIf;

  // return the selected file/folder
  pmrRtnPth=selRtnPth;

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

  // Process saved SFL options
  SortOptions();
  DoW optionsCount>0;
    Clear sflFields;
    pthNme  = optionsArray(1).key;
    Sel  = optionsArray(1).Option;
    positionToKey=optionsArray(1).key;
    ProcessLine();
    PopOptions();
    If keyPressed = 'F3' or keyPressed = 'F12';
      Leave;
    EndIf;
  EndDo;

  // rebuild subfile so the options are set correct again
  LoadSFL();

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
    selRtnPth=pthNme;

    // Handle Browse Directory
  ElseIf sel='7';
    curDir = pthNme;
    ProgramInitialization();

  EndIf;

End-Proc;


// Goes up one folder level
Dcl-Proc UpFolder;
  Dcl-S l packed(3);

  // cannot go up past the start folder
  If curDir <> strDir;

    // strip off the last part of the current displayed directory

    // Find the last / in the path
    l = %scanr('/':curDir);
    If l > 2;
      curDir = %subst(curDir:1:l-1);
    EndIf;

    ProgramInitialization();

  EndIf;

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S sflRcd packed(5);
  Dcl-S error Ind;

  RRN1  = 1;
  error = *Off;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      // * Validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs);
        $ErrorMessage('':'Error, invalid option.':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '7' and typ <> 'Dir';
        $ErrorMessage('':'Error, option only valid on directories.'
                        :error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '1' and typ = 'Dir' and alwFlr <> 'Y';
        $ErrorMessage('':'Error, you cannot select a folder.'
                        :error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '1' and typ <> 'Dir' and alwFle <> 'Y';
        $ErrorMessage('':'Error, you cannot select a file.'
                        :error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      EndIf;
      Update SFL;
    EndIf;
  EndFor;

  Return error;

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
  sqlStm += ' Limit ' + %char(SFLPage) + ' Offset ' + %char(CurrentRow) ;
  Exec SQL Prepare sqlStm4 From :sqlStm;
  Exec SQL Declare SQLCrs4 Cursor For sqlStm4;
  Exec SQL Open  SQLCrs4;
  Exec SQL Fetch SQLCrs4 For :SFLPage rows Into :dta;
  Exec SQL Close SQLCrs4;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If dta(i).fle<>'';
      Eval-Corr sflFields=dta(i);
      // this removes any non-displayable characters in the path name
      fle = #$CCHAR(fle);
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
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
    If schVal<>'' and Selects; // if in select mode and searching, position to selection column
      $GetFieldLocation(PgmNme:'sel':outRow:outCol);
    EndIf;
  EndIf;
  SchSav = SchVal;

  Where = 'Where';

  // This one was the old one for use the IBM view. It doesn't work with QNTC. I left it here
  // in case that ever gets resolved.
  // sqlStm='+
  // Select +
  //   cast(path_name as varchar(999)) key, +
  //   case when length(cast(path_name as varchar(999))) <= 76 +
  //        then substr(cast(path_name as varchar(999)),1,76) +
  //        else ''...'' || +
  //          substr(cast(path_name as varchar(999)), +
  //                 length(cast(path_name as varchar(999))) - 72 , +
  //                 73) end pthSht, +
  //   object_type objTyp +
  // From Table(qsys2.ifs_object_statistics( +
  //   start_path_name => '''+%trim(strDir)+''', +
  //   subtree_directories =>''NO''))';

  sqlStm='+
  Select +
    pth key, +
    fle, +
    objTyp +
  From QTEMP/IFSPMTD1TP';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
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
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
Dcl-Proc ProgramInitialization;

  // Open the screen DSPF if it is not already open
  If not %open(IFSPMTF1); // **change
    Open IFSPMTF1; // **change
  EndIf;

  // Initalize data structures
  Clear pos;
  Clear line1;
  Clear positionToKey;
  CurrentRow=0;

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
    $GetFieldLocation(PgmNme:'dctNme1':outRow:outCol);
  EndIf;

  // Sets the default filter options
  Clear filterDs;
  filterDs.SrtCde = 1;

  // Sets on indicators for the mode and the mode name
  Selects = *On;
  mde='Select';

  // Get Valid SFL Options and Function keys data structures
  optDs=$GetSFLOptions(psdsPgmNam:Option);
  options=$NextSFLOption(optDs);
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs);
  fncKeys=$NextFunctionKeys(fncDs);

  // if the current directory is thestart directory, do not include F7=Up Folder
  // otherwise add F7=Up Folder
  If curDir = strDir;
    fncKeys=$ChangeFunctionKey(fncDs:'F7':'');
  Else;
    fncKeys=$ChangeFunctionKey(fncDs:'F7':'F7=Up One Folder');
  EndIf;

  curDirSht = curDir;

  // build temp file with items in the directory
  BuildIFSList();

  LoadSFL();

End-Proc;


// Build IFS list
// this proceudre builds a list of entries in an IFS directory in file QTEMP/IFSPMTD1TP
Dcl-Proc BuildIFSList;
  Dcl-S l packed(3);

  // Open a directory
  Dcl-Pr OpenDir Pointer ExtProc('opendir');
    dirName Pointer Value Options(*STRING);
  End-Pr;
  // Read directory entry
  Dcl-Pr ReadDir Pointer ExtProc('readdir');
    DIRP Pointer Value Options(*STRING);
  End-Pr;
  // Close a directory
  Dcl-Pr CloseDir Int(10) ExtProc('closedir');
    dirP Pointer VALUE OPTIONS(*STRING);
  End-Pr;
  Dcl-S p_dirEnt Pointer;
  Dcl-Ds dirEnt  Based(p_dirEnt);
    d_reserv1      Char(16);
    d_reserv2      Uns(10);
    d_fileNo       Uns(10);
    d_recLen       Uns(10);
    d_reserv3      Int(10);
    d_reserv4      Char(8);
    d_nlsinfo      Char(12);
    nls_ccsid      Int(10)    OVERLAY( D_NLSINFO:1 );
    nls_cntry      Char(2)    OVERLAY( D_NLSINFO:5 );
    nls_lang       Char(3)    OVERLAY( D_NLSINFO:7 );
    nls_reserv     Char(3)    OVERLAY( D_NLSINFO:10 );
    d_nameLen      Uns(10);
    d_name         Char(640);
  End-Ds;

  Dcl-S dirHandle Pointer;

  Dcl-S test char(100);
  Dcl-S type char(5);

  // Create tempfile to hold the output
  Exec SQL Create or Replace Table QTEMP/IFSPMTD1TP (
    pth char(999),
    fle char(76),
    objTyp char(12)
  );
  Exec SQL Delete From QTEMP/IFSPMTD1TP;

  // Open up the directory.
  dirHandle = OpenDir( %trim(curDir) );
  If dirHandle = *NULL;
    #$DSPWIN('Error opening "'+curDir+'", error: ' + psdsExcDta);
    Return;
  EndIf;

  // Read each entry from the directory (in a loop)
  p_dirEnt = ReadDir( dirHandle );
  DoW p_dirEnt <> *null;
    // trim the dname to the lenght provided
    d_name = %subst(d_name:1:d_nameLen);

    If not (d_name in %list('.':'..'));
      // Get the status structure to see what type of object it is
      If stat( %trim(curDir) + '/' + %trim(d_name) : %addr(test) ) <> 0;
        type = 'Error';
        // overide the object type if it is a directory
      ElseIf %subst(test:51:3) = 'DIR';
        type = 'Dir';
      Else;
        // Find the last period in the file name
        l = %scanr('.':d_name);
        If %len(%trimr(d_name)) - l <= 5;
          type = #$LAST(d_name:%len(%trimr(d_name)) - l);
        Else;
          type = 'STMF';
        EndIf;
      EndIf;
      // add to temp file
      Exec SQL Insert into QTEMP/IFSPMTD1TP (pth,fle,objTyp)
      values(
        trim(:curDir) || '/' || trim(:d_name),
        case when length(trim(:d_name)) > 76
             then '...' || substr(:d_name,length(:d_name) - 72 , 73)
             else :d_name
        end,
        :type);
    EndIf;
    p_dirEnt = ReadDir( dirHandle );
  EndDo;

  // Close the directory
  CloseDir( dirHandle );

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/copy QSRC,IFSPMTD1_2


// Copies in procedures SaveOptions, PopOptions, SoprtOptions and Get Options
// These never change so no point in duplicating the code in each program
/Copy QSRC,$options
