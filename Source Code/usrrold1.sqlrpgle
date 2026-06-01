**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Role Master List

Dcl-F USRROLF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRROLD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,USRROLD1PR // Always include the prototype for the current program
/Copy QSRC,USRROLDZPR // Dictionary master - filters
/Copy QSRC,USRROLB0PR // Dictionary master - navigator
/Copy QSRC,USRROLBRPR // Dictionary master - print list driver
/Copy QSRC,USRMSTD5PR // Prompt for user

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL
Dcl-S RRN1SV Like(OutRRN1); // the relative record number for the SFL
Dcl-S CurrentRow packed(9); // the postion in the data set for the start of the current screen
Dcl-S NumberOfRows packed(9); // the total number of rows in the data set
Dcl-S totalNumberOfRows packed(9); // the total number of rows in the dataset before the the filters are applied

Dcl-S schSav Like(schVal); // used to see if the search field changed, which forces a SFL reload
Dcl-Ds filterDsSave Likeds(filterDs); // used to see if the filter options changed, which forces a SFL reload
Dcl-Ds filterDs ExtName('USRROLFZ') Qualified Inz End-Ds; // contains the filter and sort options from DZ

Dcl-S option  like(APLDCT.option); // global variable to store the option parameter in

Dcl-S sqlStm Varchar(5120); // used for the select statment for the fields
Dcl-S orderBy Varchar(1024); // used to build the order by clause
Dcl-S Where Char(5); // used to change the first where to an and after the first use
Dcl-S usrRolIdn like(APLDCT.usrRolIdn);
Dcl-S usrMstIdn like(APLDCT.usrMstIdn);
Dcl-S rolMstIdn like(APLDCT.rolMstIdn);

Dcl-S dataEntered Ind; // set on if anything is entered on the screen
Dcl-S Changed     Ind; // set on if any of the SFL entries are changed, forces a reload of the SFL
Dcl-S Display     Ind; // set on if the program is in inquiry mode, option parameter=5
Dcl-S Selects     Ind; // set on if the program is in select mode, option parameter=1
Dcl-S Maintenance Ind; // set on if the program is in update mode, option parameter=2

// Used for selection if in select mode
Dcl-S selected  Ind;
Dcl-S selUsrRolIdn Like(APLDCT.usrRolIdn);

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
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


// Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRROLD1');
    pmrUsrRolIdn Like(APLDCT.usrRolIdn);
    pmrUsrMstIdn Like(APLDCT.usrMstIdn);
    pmrRolMstIdn Like(APLDCT.rolMstIdn);
    pmrOption Like(APLDCT.option);
    pmrKeyPressed Like(keyPressed);
    pmrSchVal like(APLDCT.schVal) options(*nopass);
  End-Pi;

  If %parms >= 2 and %addr(pmrUsrMstIdn) <> *null;
    usrMstIdn = pmrUsrMstIdn;
  Else;
    Clear usrMstIdn;
  EndIf;
  If %parms >= 3 and %addr(pmrRolMstIdn) <> *null;
    rolMstIdn = pmrRolMstIdn;
  Else;
    Clear rolMstIdn;
  EndIf;

  // Sets the Option if passed
  If %parms >= 4;
    option = pmrOption;
  EndIf;

  // see if the user has permission to use this program
  If not #$HasRole('Developer');
    #$DSPWIN('User not authorized to this program.');
    Return;
  EndIf;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs = $Security(psDsPgmNam:psDsUsrPrf:option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  // if a search value was passed, force it into the search parameter
  If %parms >= 6 and %addr(pmrSchVal) <> *null;
    schVal = pmrSchVal;
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
    ElseIf keyPressed = 'F7';
      ImportFromUser();
    ElseIf keyPressed = 'F9';
      CompareToUser();
    ElseIf keyPressed = 'F11';
      ToggleInactive();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F13';
      Filter();
    ElseIf keyPressed = 'F21';
      USRROLBR();
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

  Close USRROLF1;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 5;
    pmrKeyPressed = keyPressed;
  EndIf;

  // If used as a prompt program we have to return the selected value and description
  If selected;
    If %parms >= 1;
      pmrUsrRolIdn = selUsrRolIdn;
    EndIf;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

  // Set the text for F11=Show/Hide Deleted
  If filterDs.acvDes = '';
    fncKeys=$ChangeFunctionKey(fncDs:'F11':'F11=Hide Inactive');
  Else;
    fncKeys=$ChangeFunctionKey(fncDs:'F11':'F11=Show Inactive');
  EndIf;

  // If there is no comparison user, hide the comparison fields
  If filterDs.cmpUsr = '';
    $SetAttribute(cmpDes1@:'PR,ND');
    $SetAttribute(cmpDesH@:'ND');
  Else;
    $SetAttribute(cmpDes1@:'CS,UL');
    $SetAttribute(cmpDesH@:'HI,UL');
  EndIf;

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
Dcl-Proc Filter;

  filterDsSave = filterDs;
  USRROLDZ(filterDs:keyPressed);

  If keyPressed = 'F3';
  ElseIf keyPressed = 'F12';
    keyPressed = '';
  ElseIf filterDsSave <> filterDs;
    LoadSFL();
  EndIf;

End-Proc;


// Toggle between showing and hiding inactive
Dcl-Proc ToggleInactive;

  If filterDs.acvDes = '';
    filterDs.acvDes = 'Active';
  Else;
    filterDs.acvDes = '';
  EndIf;

  LoadSFL();

End-Proc;


// Update anything entered on the screen
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
    Clear usrRolIdn;
    Exec SQL
      Select usrRolIdn, USRROL.usrMstIdn, USRROL.rolMstIdn
      into  :usrRolIdn,:usrMstIdn,:rolMstIdn
      From USRROL
      Left Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn
      Left Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn
      left join ACCESSPF on acNo = accNbr
      Where rolNme = :rolNme
        and trim(acFNam) || ' ' || trim(acLNam) = :usrNme
      Fetch First Row Only;
    ProcessLine();
    Clear Sel1;
    Clear line1;
  Else;
    // Process saved SFL options
    SortOptions();
    DoW optionsCount>0;
      Clear sflFields;
      usrRolIdn  = %dec(%subst(optionsArray(1).key:1:19):19:0);
      usrMstIdn  = %dec(%subst(optionsArray(1).key:20:19):19:0);
      rolMstIdn  = %dec(%subst(optionsArray(1).key:39:19):19:0);
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
Dcl-Proc ProcessLine;
  If sel <> '';
    dataEntered = *on;
  EndIf;

  // get the user rol id for the rolMstIdn

  // Handle position to
  If Sel = '8';
    pos=sflFields;
    SetSrtCde();

    // Handle Select
  ElseIf sel = '1' and Selects;
    selected = *on;
    selUsrRolIdn = usrRolIdn;

    // Handle Add if in front of an entry that has a role from the comparison user, but an entry does not not exists
  ElseIf sel = '1' and not Selects and usrRolIdn = 0 and filterDs.usrMstIdn <> 0 and rolMstIdn <> 0;
    usrMstIdn = filterDs.usrMstIdn;
    Exec SQL
      Insert Into USRROL
            ( usrMstIdn, rolMstIdn)
      Values(:usrMstIdn,:rolMstIdn);

    // Handle all other options via the B0 program
  ElseIf Sel <> '';
    USRROLB0(usrRolIdn:usrMstIdn:rolMstIdn:Sel:keyPressed);
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
  Dcl-S pmIdn like(APLDCT.idn);
  Dcl-S pmOption like(APLDCT.option);
  Dcl-S pmUsrMstIdn like(APLDCT.usrMstIdn);
  Dcl-S pmRolMstIdn like(APLDCT.rolMstIdn);
  pmOption = '1';

  Clear pmIdn;
  pmUsrMstIdn = filterDs.usrMstIdn;
  pmRolMstIdn = filterDs.rolMstIdn;
  USRROLB0(pmIdn:pmUsrMstIdn:pmRolMstIdn:pmOption:keyPressed);

  filterDs.SrtCde = 1;
  LoadSFL();

End-Proc;


Dcl-Proc CompareToUser;
  Dcl-S cmpUsr like(APLDCT.usrNme);
  Dcl-S cmpUsrPrf like(APLDCT.usrPrf);

  // Prompt for user
  USRMSTD5('Select User to Compare To':cmpUsrPrf:keyPressed);

  // get users name if populated and add to the filter comparison user field
  Clear cmpUsr;
  If cmpUsrPrf <> '';
    Clear cmpUsr;
    Exec SQL Select trim(acFNam) || ' ' || trim(acLNam) into :cmpUsr
             from ACCESSPF where acUprf = :cmpUsrPrf;
  EndIf;
  filterDs.cmpUsr = cmpUsr;

  CurrentRow=0;

  // rebuild subfile so the options are set correct again
  LoadSFL();

End-Proc;


Dcl-Proc ImportFromUser;
  Dcl-S toUsrMstIdn like(APLDCT.usrMstIdn);
  Dcl-S frmUsrMstIdn like(APLDCT.usrMstIdn);
  Dcl-S usrNme like(APLDCT.usrNme);
  Dcl-S impUsr like(APLDCT.usrPrf);

  // make sure a iflter user is populated or we do not have a user id to import to
  If filterDs.usrNme = '';
    $ErrorMessage('':'Error, list must be filtered to a single user so there is a suer to import the entries to.');
  EndIf;

  // Get the user master Id for the filtered name
  Clear toUsrMstIdn;
  usrNme = filterDs.usrNme;
  Exec SQL Select usrMStIdn into :toUsrMstIdn
    from USRMST
    join ACCESSPF on acNo = accNbr
    Where trim(acFNam) || ' ' || trim(acLNam) = :usrNme;

  // Prompt for user
  impUsr = '';
  USRMSTD5('Select User to Import From':impUsr:keyPressed);

  // Import from user if selected
  If impUsr <> '';
    Exec Sql Select usrMstIdn into :frmUsrMstIdn from USRMST where usrPrf = :impUsr;
    If frmUsrMstIdn <> 0;
      Exec SQL insert into USRROL (usrMstIdn, rolMstIdn, rolApr)
        Select :toUsrMstIdn, rolMstIdn, '0'
        from USRROL
        where usrMstIdn = :frmUsrMstIdn
          and rolMstIdn not in (Select rolMstIdn from USRROL where usrMstIdn = :toUsrMstIdn);
      $ErrorMessage('':'Import Complete.');
    Else;
      $ErrorMessage('':'Import not done, invalid user or no entries found.');
    EndIf;
  EndIf;

  CurrentRow=0;

  // rebuild subfile so the options are set correct again
  LoadSFL();

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
  If Sel1 <> '';

    // Check record in file, move top line entries into SFL fields
    Sel = Sel1;
    sflFields = line1;

    // get found and active status
    Clear found;
    Clear tsAcvRow;
    Exec SQL
      Select trim(acFNam) || ' ' || trim(acLNam),USRROL.acvRow Into :found,:tsAcvRow
      From USRROL
      Left Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn
      Left Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn
      left join ACCESSPF on acNo = accNbr
      Where rolNme = :rolNme
        and trim(acFNam) || ' ' || trim(acLNam) = :usrNme
      Fetch First Row Only;

    // Validate option
    If Sel <> '' and not $ValidSFLOption(sel:optDs);
      $ErrorMessage('DCT1002':'':error:Sel@:'Sel':outRow:outCol:psDsPgmNam);

      // for any option but add and position to, the dictionary name must be provided
    ElseIf not (sel in %list('8':'1')) and RolNme = '';
      $ErrorMessage('DCT1001':'':error:RolNme1@:'RolNme1':outRow:outCol:psDsPgmNam);

      // If deleting make sure the row is active
    ElseIf Sel = '4' and tsAcvRow <> '1';
      $ErrorMessage('DCT1004':'':error:RolNme1@:'RolNme1':outRow:outCol:psDsPgmNam);

      // If reinstating make sure the row is inactive
    ElseIf Sel = '13' and tsAcvRow <> '0';
      $ErrorMessage('DCT1013':'':error:Sel1@:'Sel1':outRow:outCol:psDsPgmNam:RolNme1@);

      // If adding make sure the entry does not exist
    ElseIf Sel = '1' and not Maintenance and found;
      $ErrorMessage('DCT1101':'':error:RolNme1@:'RolNme1':outRow:outCol:psDsPgmNam);

      // If any option but add or position to, make sure the entry exists
    ElseIf not (Sel in %list('1':'8')) and not found and not Maintenance;
      $ErrorMessage('DCT1102':'':error:RolNme1@:'RolNme1':outRow:outCol:psDsPgmNam);
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
      If Sel <> '' and not $ValidSFLOption(sel:optDs);
        $ErrorMessage('DCT1002':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow += sflRcd - 1; // required to move to the correct SFL line
      ElseIf Sel = '4' and AcvDes = 'Inactive';
        $ErrorMessage('DCT1004':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow += sflRcd - 1; // required to move to the correct SFL line
      ElseIf Sel = '13' and AcvDes = 'Active';
        $ErrorMessage('DCT1013':'':error:sel@:'Sel':outRow:outCol:psDsPgmNam);
        outRow += sflRcd - 1; // required to move to the correct SFL line
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
  RRN1 = 0;
  For i = 1 To SFLPage;
    If dta(i).RolNme <> '';
      Eval-Corr sflFields = dta(i);
      Sel = GetOption(dta(i).key);
      // make the row red if inactive
      If acvDes = 'Inactive';
        $SetAttribute(rowClr@:'Red');
      Else;
        $SetAttribute(rowClr@:'');
      EndIf;
      If filterDs.cmpUsr = '';
        cmpDes = '';
      EndIf;
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


// Build the SQl Statement
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

  // build sql statement
  // this cannot be in a view or it would have to compare every user to every other user and that would take forever,
  // so un fortunately you get this ugly sql statment in the code.
  sqlStm = '+
      Select +
        digits(coalesce(usr.usrRolIdn,cmp.usrRolIdn)) || +
          digits(coalesce(usr.usrMstIdn,0)) || +
          digits(coalesce(usr.rolMstIdn,cmp.rolMstIdn)) as key, +
        coalesce(usr.usrMstIdn,0) usrIdn, +
        coalesce(usr.rolMstIdn,cmp.rolMstIdn) rolIdn, +
        coalesce(usr.usrPrf,'''') usrPrf, +
        coalesce(usr.usrNme,''' + %trim(usrNme) + ''') usrNme, +
        coalesce(usr.rolNme,cmp.rolNme) as rolNme, +
        coalesce(usr.aprDes,''N/A'') as aprDes, +
        coalesce(usr.acvDes,''N/A'') as acvDes, +
        case when usr.rolNme is null then ''User missing'' +
            when cmp.rolNme is null then ''Comparison user missing'' +
            else ''Both have.'' end cmpDes +
      from ( +
          Select +
            usrRolIdn, +
            USRROL.usrMstIdn, +
            USRROL.rolMstIdn, +
            usrPrf, +
            case when coalesce(acFNam,'''') <> '''' and coalesce(acLNam,'''') <> '''' +
                 then trim(acFNam) || '' '' || trim(acLNam) +
                 when coalesce(acFNam,'''') <> '''' then acFNam +
                 when coalesce(acLNam,'''') <> '''' then acLNam +
                 Else usrPrf +
            end usrNme, +
            rolNme, +
            case when rolApr = ''1'' then ''Approved'' Else ''Pending'' end aprDes, +
            coalesce(acv.enmDes,''Error'') acvDes +
          From USRROL +
          Left Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn +
          Left Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn +
          left join ACCESSPF on acNo = accNbr +
          left join DCTVAL as acv on (acv.dctNme,acv.fldNme,acv.enmVal) = (''APLDCT'',''ACVROW'',USRROL.AcvRow) +
          Where '''+ %trim(filterDs.usrNme) + ''' in (trim(acFNam) || '' '' || trim(acLNam), '''') +
            and ''' + %trim(filterDs.rolNme) + ''' in (rolNme, '''') +
      ) as usr +
      full outer join ( +
          Select +
            cast(0 as bigint) usrRolIdn, +
            cast(' + %char(filterDs.usrMstIdn) + ' as bigint) usrMstIdn, +
            USRROL.rolMstIdn, +
            case when coalesce(acFNam,'''') <> '''' and coalesce(acLNam,'''') <> '''' +
                 then trim(acFNam) || '' '' || trim(acLNam) +
                 when coalesce(acFNam,'''') <> '''' then acFNam +
                 when coalesce(acLNam,'''') <> '''' then acLNam +
                 Else usrPrf +
            end usrNme, +
            rolNme, +
            coalesce(acv.enmDes,''Error'') acvDes +
          From USRROL +
          Left Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn +
          Left Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn +
          left join ACCESSPF on acNo = accNbr +
          left join DCTVAL as acv on (acv.dctNme,acv.fldNme,acv.enmVal) = (''APLDCT'',''ACVROW'',USRROL.AcvRow) +
          Where  trim(acFNam) || '' '' || trim(acLNam) = ''' + %trim(filterDs.cmpUsr) + ''' +
            and ''' + %trim(filterDs.rolNme) + ''' in (rolNme, '''') +
            and usrRol.acvRow = ''1'' +
      ) as cmp on cmp.rolNme = usr.rolNme';

  // Get the total number of records before any filters, this is used for a message at the bottom
  Exec SQL Prepare sqlStm3 From :sqlStm;
  Exec SQL Declare SQLCrs3 Cursor For sqlStm3;
  Exec SQL Open  SQLCrs3;
  Exec SQL Get DIAGNOSTICS :totalNumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs3;

  // AcvRow
  If filterDs.AcvDes <> '';
    sqlStm += ' ' + Where + ' uCase(coalesce(usr.acvDes,''N/A'')) = Ucase(''' + %trim(filterDs.AcvDes) + ''')';
    Where = 'and';
  EndIf;

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

  // Get total number of records for selected data
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrs;

End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
// **ChangedFromMassReplace-The cursor name and display file name needs to be changed as well as the initial
//   field to set the cursor to
Dcl-Proc ProgramInitialization;
  Dcl-S usrNme like(APLDCT.usrNme);
  Dcl-S rolNme like(APLDCT.rolNme);

  // Open the screen DSPF if it is not already open
  If not %open(USRROLF1); // **change
    Open USRROLF1; // **change
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
    $GetFieldLocation(PgmNme:'rolNme1':outRow:outCol);
  EndIf;

  // Sets the default filter options
  Clear filterDs;
  filterDs.SrtCde = 1;
  // filterDs.acvDes = 'Active';

  // If a user id is passed in, fill in the user name filter
  If usrMstIdn <> 0;
    Exec SQL
      Select trim(acFNam) || ' ' || trim(acLNam)
      Into :usrNme
      From USRMST
      Join ACCESSPF on acNo = accNbr
      Where usrMstIdn = :usrMstIdn;
    filterDs.usrNme = usrNme;
    filterDs.usrMstIdn = usrMstIdn;
  EndIf;

  // If a role id is passed in, fill in the role name filter
  If rolMstIdn <> 0;
    Exec SQL
      Select rolNme
      Into :rolNme
      From ROLMST
      Where rolMstIdn = :rolMstIdn;
    filterDs.rolNme = rolNme;
    filterDs.rolMstIdn = rolMstIdn;
  EndIf;

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

  LoadSFL();

End-Proc;


// Copies in procedures SetSrtCde and PositionSFL, these get built automatically by the screen pre-processor
/copy QSRC,USRROLD1_2


// Copies in procedures SaveOptions, PopOptions, SoprtOptions and Get Options
// These never change so no point in duplicating the code in each program
/Copy QSRC,$options
