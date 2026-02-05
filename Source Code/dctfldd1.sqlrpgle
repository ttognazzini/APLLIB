**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Field List

Dcl-F DCTFLDF1 WorkStn
               SFile(SFLB1:RRN1)
               SFile(SFLB2:RRN1)
               SFile(SFLS1:RRN1)
               SFile(SFLS2:RRN1)
               SFile(SFLS3:RRN1)
               InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // Prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDD1_@ // auto generatde data structures for field attribute fields
/Copy QSRC,DCTFLDD1PR
/Copy QSRC,DCTFLDDZPR
/Copy QSRC,DCTFLDDLPR
/Copy QSRC,DCTFLDB0PR

Dcl-S RRN1 Like(OutRRN1);
Dcl-S RRN1SV Like(OutRRN1);
Dcl-S LastRRN Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);
Dcl-S totalNumberOfRows packed(9);
Dcl-S where Char(5); // used to change the first where to an and after the first use
Dcl-S DctMstIdn like(APLDCT.DctMstIdn);
Dcl-S DctFldIdn like(APLDCT.DctFldIdn);

Dcl-S SchSav Like(SchVal);
Dcl-Ds filterDsSave Likeds(filterDs);
Dcl-Ds filterDs ExtName('DCTFLDFZ') Qualified Inz End-Ds;

Dcl-S Option  like(APLDCT.Option);

Dcl-S sqlStm  Varchar(5120);
Dcl-S orderBy Varchar(1024);

Dcl-S dataEntered Ind;
Dcl-S Changed     Ind;
Dcl-S Display     Ind;
Dcl-S Selects     Ind;
Dcl-S Maintenance Ind;

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selFldNme Like(APLDCT.FldNme);

// used to position to the last updated line if it is still on the screen
Dcl-S positionToKey like(Key);

// Used to save options while paging through the data
Dcl-S optionsCount packed(5);
Dcl-Ds optionsArray Dim(1000) Qualified Inz;
  Key    like(dta.key);
  Option like(Option);
  Sort   Char(132);
End-Ds;

// set default SQL options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;


// Mainline, Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDD1');
    pmrDctNme Like(APLDCT.DctNme) const;
    pmrFldNme Like(APLDCT.FldNme);
    pmrOption Like(Option);
    pmrKeyPressed Like(keyPressed);
    pmrSchVal like(APLDCT.schVal) options(*nopass);
  End-Pi;

  // Sets options based on parameters
  If %parms >= 1;
    DctNme = pmrDctNme;
  EndIf;
  If %parms >= 2;
    pos.FldNme = pmrFldNme;
  EndIf;
  If %parms >= 3;
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
      ChangeView();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F13';
      Filter();
    ElseIf keyPressed = 'F18';
      LoadFromFile();
    ElseIf keyPressed = 'F23';
      options=$NextSFLOption(optDs);
      optionss=options;
    ElseIf keyPressed = 'F24';
      fncKeys=$NextFunctionKeys(fncDs);
      fncKeyss=fncKeys;
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

  Close DCTFLDF1;

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

  // This message is for the number of entries, paging information and filters, it is not shown if there are no records
  $ErrorMessage('':$BuildSFLMessage(NumberOfRows:totalNumberOfRows:SFLPage:CurrentRow:RRN1));

  // Load message SFL
  If filterDs.ScrSze='2';
    Write MSGCTLB;
  Else;
    Write MSGCTLS;
  EndIf;

  // Actually Display the Screen
  // **CHANGE change the screens based on the size and view options
  If filterDs.ScrSze='2';
    Write FOOTERB;
  Else;
    Write FOOTERS;
  EndIf;
  If filterDs.ScrSze='2' and filterDs.Dvw='2';
    Exfmt SFLCTLB2;
  ElseIf filterDs.ScrSze='2';
    Exfmt SFLCTLB1;
  ElseIf filterDs.Dvw='2';
    Exfmt SFLCTLS2;
  ElseIf filterDs.Dvw='3';
    Exfmt SFLCTLS3;
  Else;
    Exfmt SFLCTLS1;
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
  Callp DCTFLDDZ(DctNme:filterDs:keyPressed);

  If keyPressed = 'F3';
  ElseIf keyPressed = 'F12';
    keyPressed = '';
  EndIf;

  // If they selected a big screen but the session does not allow it, change it back to one
  If not #$132OK();
    filterDs.ScrSze = '1';
  EndIf;

  // if the screen size changed reset the SFL options and function keys
  If filterDsSave <> filterDs;
    If filterDs.ScrSze='2';
      SFLPage=18;
      optDs=$GetSFLOptions(psdsPgmNam:Option:132);
      options=$NextSFLOption(optDs);
      optionss=options;
      fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:132);
      fncKeys=$NextFunctionKeys(fncDs);
      fncKeyss=fncKeys;
    Else;
      SFLPage=14;
      optDs=$GetSFLOptions(psdsPgmNam:Option:80);
      options=$NextSFLOption(optDs);
      optionss=options;
      fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:80);
      fncKeys=$NextFunctionKeys(fncDs);
      fncKeyss=fncKeys;
    EndIf;
  EndIf;


  If filterDsSave <> filterDs;
    LoadSFL();
  EndIf;

End-Proc;


// Cycle through different views  (F6=Change View)
Dcl-Proc ChangeView;

  // Set the view based on the current view and the screen size
  // In this case there are 2 views in 132 column mode and 3 in 80 column mode
  If filterDs.Dvw = '2' and filterDs.ScrSze='1';
    filterDs.Dvw='3';
  ElseIf filterDs.Dvw = '2' and filterDs.ScrSze='2';
    filterDs.Dvw='1';
  ElseIf filterDs.Dvw = '3';
    filterDs.Dvw='1';
  Else;
    filterDs.Dvw='2';
  EndIf;

  // Refresh screen
  LoadSFL();

End-Proc;


// Load fields from a file
Dcl-Proc LoadFromFile;

  // Call program to load fields form a file
  DCTFLDDL(dctNme);

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
    Clear DctFldIdn;
    Exec SQL Select dctFldIdn into :DctFldIdn
             From DCTFLD
             Where (dctNme, fldNme) = (:dctNme, :fldNme);
    ProcessLine();
    Clear Sel1;
    Clear line1;
  Else;
    // Process saved SFL options
    SortOptions();
    DoW optionsCount>0;
      Clear sflFields;
      DctFldIdn  = optionsArray(1).key;
      Sel  = optionsArray(1).Option;
      positionToKey=optionsArray(1).key;
      ProcessLine();
      PopOptions();
      If keyPressed = 'F3' or keyPressed = 'F12';
        Leave;
      EndIf;
    EndDo;
  EndIf;

  // Rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


// Process SFL Options
Dcl-Proc ProcessLine;

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
    DCTFLDB0(DctMstIdn:DctFldIdn:Sel:keyPressed);
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
      From  DCTFLD
      Where DctNme = :DctNme
        and FldNme=:FldNme
      Fetch First Row Only;

    // Validate option
    If Sel<>'' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the dictionary name must be provided
    ElseIf not(Sel in %list('8':'1')) and DctNme = '';
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
    ElseIf not ( Sel in %list('1':'8')) and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:FldNme1@:'FldNme1':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    If filterDs.ScrSze='2' and filterDs.Dvw='2';
      Chain(e) sflRcd SFLB2;
    ElseIf filterDs.ScrSze='2';
      Chain(e) sflRcd SFLB1;
    ElseIf filterDs.Dvw='2';
      Chain(e) sflRcd SFLS2;
    ElseIf filterDs.Dvw='3';
      Chain(e) sflRcd SFLS3;
    Else;
      Chain(e) sflRcd SFLS1;
    EndIf;
    If %found;
      Sel@ = '';
      // Left Justify Option
      Sel=%trim(Sel);
      // * validate Option
      If Sel <> '' and not $ValidSFLOption(sel:optDs)
        or Sel = '1' and Maintenance;
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      ElseIf Sel = '4' and AcvDes = 'Inactive';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
        // do not allow delete if in an active production file
      ElseIf Sel = '4';
        found = *off;
        Exec SQL Select '1' Into :found
                From FLEFLD
                Join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme)
                Where (FLEMST.dctNme, FLEFLD.fldNme, FLEMST.prdFle) = (:dctNme,:fldNme,'Y');
        If found;
          $ErrorMessage('':'Error, field cannot be inactivated becasue it is is a production file.'
                        :error:sel@:'Sel':outRow:outCol:psDsPgmNam);
          outRow+=sflRcd-1; // required to move to the correct SFL line
        EndIf;
      ElseIf Sel = '13' and AcvDes = 'Active';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow+=sflRcd-1; // required to move to the correct SFL line
      EndIf;
      If filterDs.ScrSze='2' and filterDs.Dvw='2';
        Update SFLB2;
      ElseIf filterDs.ScrSze='2';
        Update SFLB1;
      ElseIf filterDs.Dvw='2';
        Update SFLS2;
      ElseIf filterDs.Dvw='3';
        Update SFLS3;
      Else;
        Update SFLS1;
      EndIf;
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

  Changed = *Off;

  // Clear all SFL's
  LastRRN = 0;
  SflClr = *on;
  Write SFLCTLB2;
  Write SFLCTLB1;
  Write SFLCTLS2;
  Write SFLCTLS3;
  Write SFLCTLS1;
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
      Sel = GetOption(dta(i).key);
      RRN1 += 1;
      If filterDs.ScrSze='2' and filterDs.Dvw='2';
        Write SFLB2;
      ElseIf filterDs.ScrSze='2';
        Write SFLB1;
      ElseIf filterDs.Dvw='2';
        Write SFLS2;
      ElseIf filterDs.Dvw='3';
        Write SFLS3;
      Else;
        Write SFLS1;
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
    $ErrorMessage('':'No Rows to Display, check filters.');
  EndIf;

End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;

  // build order by first, it is used in the regular and position to SQL
  orderBy = 'Order By ' + %trim(orderByDS.value(filterDs.SrtCde))+',key';

  If schval<>schSav;
    CurrentRow=0;
    dataEntered=*on;
  EndIf;
  SchSav = SchVal;

  sqlStm =
    'Select * +
     From ( +
      Select Distinct +
        DCTFLD.DctNme dctNmeTst, +
        DCTFLD.DctFldIdn as Key, +
        DCTFLD.FldNme, +
        ColTxt, +
        coalesce(DCTVAL.EnmDes,''Error'') AcvDes, +
        case when FldTyp in (''TIMESTAMP'',''DATE'',''TIME'',''INTEGER'',''SMALLINT'', +
                  ''BIGINT'',''REAL'',''DOUBLE PRECISION'') +
            then FldTyp +
            When FldTyp = ''VARCHAR'' +
            Then Trim(FldTyp) concat ''('' +
                  concat trim(Char(FldLen)) Concat '') ALLOCATE('' +
                  concat trim(FldAlc) concat '')'' +
            When FldTyp in (''FLOAT'',''NUMERIC'',''DECIMAL'') +
            Then Trim(FldTyp) concat ''('' +
                  concat trim(Char(FldLen)) Concat '','' +
                  concat trim(Char(FldScl)) concat '')'' +
            Else Trim(FldTyp) concat ''('' concat Trim(Char(FldLen)) concat '')'' +
        end Typ, +
        case when FldEnm=''Y'' then ''Yes'' Else ''No'' end FldEnmD, +
        DftVal, +
        AlwNul +
      From DCTFLD +
      Left Join DCTVAL on (DCTVAL.DctNme,DCTVAL.FldNme,DCTVAL.EnmVal)=(''APLDCT'',''ACVROW'',DCTFLD.AcvRow) +
      Where DCTFLD.DctNme=''' + %trim(DctNme) + ''' +
    )';
  where = 'Where';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // Active Row is
  If filterDs.AcvDes <> '';
    sqlStm += ' ' + where + ' AcvDes = ''' + %trim(filterDs.AcvDes) + '''';
  EndIf;

  // Enumerated is
  If filterDs.FldEnmD <> '';
    sqlStm += ' ' + where + ' FldEnmD = ''' + %trim(filterDs.FldEnmD) + '''';
  EndIf;

  // Field Name Contains
  If filterDs.FldNme > '';
    sqlStm += ' ' + where + ' ucase(FldNme) Like uCase(''%' + %trim(filterDs.FldNme) + '%'')';
  EndIf;

  // Column Text Contains
  If filterDs.ColTxt > '';
    sqlStm += ' ' + where + ' ucase(ColTxt) Like uCase(''%' + %trim(filterDs.ColTxt) + '%'')';
  EndIf;

  // Type Contains
  If filterDs.Typ > '';
    sqlStm += ' ' + where + ' ucase(Typ) Like uCase(''%' + %trim(filterDs.Typ) + '%'')';
  EndIf;

  // Column Heading Contains
  If filterDs.Typ > '';
    sqlStm += ' ' + where + ' ucase(ColHdg) Like uCase(''%' + %trim(filterDs.ColHdg) + '%'')';
  EndIf;

  // Select Search Values
  If SchVal > '';
    sqlStm += ' ' + where + ' ' + $BuildSearch(pgmNme:SchVal);
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


// Saves options entered in the SFL to optionsDs
// **CHANGE, only if the Screen size or view options change
Dcl-Proc SaveOptions;
  Dcl-S i packed(5:0);
  Dcl-S sflRcd packed(5);

  // If in select mode and enter is pressed try to select the line the cursor is on
  If Selects and keyPressed='ENTER' and not selected;
    If filterDs.ScrSze='2' and filterDs.Dvw='2';
      Chain(e) CsrRrn1 SFLB2;
    ElseIf filterDs.ScrSze='2';
      Chain(e) CsrRrn1 SFLB1;
    ElseIf filterDs.Dvw='2';
      Chain(e) CsrRrn1 SFLS2;
    ElseIf filterDs.Dvw='3';
      Chain(e) CsrRrn1 SFLS3;
    Else;
      Chain CsrRrn1 SFLS1;
    EndIf;
    If %found and sel='';
      optionsCount+=1;
      optionsArray(optionsCount).key=Key;
      optionsArray(optionsCount).Option='1';
    EndIf;
  EndIf;

  // Check for entries in the subfile
  For sflRcd = 1 To RRN1SV;
    If filterDs.ScrSze='2' and filterDs.Dvw='2';
      Chain(e) sflRcd SFLB2;
    ElseIf filterDs.ScrSze='2';
      Chain(e) sflRcd SFLB1;
    ElseIf filterDs.Dvw='2';
      Chain(e) sflRcd SFLS2;
    ElseIf filterDs.Dvw='3';
      Chain(e) sflRcd SFLS3;
    Else;
      Chain(e) sflRcd SFLS1;
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
             Where Key='+%char(optionsArray(i).key);
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
    Key Like(dta.Key) value;
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
  If not %open(DCTFLDF1); // **change
    Open DCTFLDF1; // **change
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

  // Get the dictionary name
  Exec SQL
    Select Des, dctMstIdn Into :des, :DctMstIdn
    From  DCTMST
    Where DctNme = :DctNme
    Fetch First Row Only;

  // **CHANGE positition cursor to the perfered field
  $GetFieldLocation(PgmNme:'FldNme1':outRow:outCol);

  // Set filter defaults
  Clear filterDs;
  If #$132OK();
    filterDs.ScrSze = '2';
  Else;
    filterDs.ScrSze = '1';
  EndIf;
  filterDs.Dvw = '1';
  filterDs.SrtCde = 1;


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
  If filterDs.ScrSze='2';
    SFLPage=18;
    optDs=$GetSFLOptions(psdsPgmNam:Option:132);
    options=$NextSFLOption(optDs);
    optionss=options;
    fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:132);
    fncKeys=$NextFunctionKeys(fncDs);
    fncKeyss=fnckeys;
  Else;
    SFLPage=14;
    optDs=$GetSFLOptions(psdsPgmNam:Option:80);
    options=$NextSFLOption(optDs);
    optionss=options;
    fncDs=$GetFunctionKeys(psdsPgmNam:Option:optDs:80);
    fncKeys=$NextFunctionKeys(fncDs);
    fncKeyss=fnckeys;
  EndIf;

  LoadSFL();

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/Copy QSRC,DCTFLDD1_2
