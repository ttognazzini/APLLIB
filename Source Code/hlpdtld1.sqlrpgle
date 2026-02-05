**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Master List

Dcl-F HLPDTLF1 WorkStn SFile(SFL:rrn1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,HLPDTLD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,HLPDTLD1PR // Always include the prototype for the current program
/Copy QSRC,HLPMSTB4PR // Display Help Text

Dcl-S rrn1   Like(OutRRN1);
Dcl-S LastRrn  Like(OutRRN1);
Dcl-S currentRow packed(9);
Dcl-S numberOfRows packed(9);

Dcl-S option  like(APLDCT.Option);

Dcl-S sqlStm Varchar(5120);
Dcl-S Changed     Ind;
Dcl-S Create      Ind;
Dcl-S Display     Ind;
Dcl-S Maintenance Ind;
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('HLPDTLD1');
    pmrDctNme Like(APLDCT.dctNme);
    pmrFldNme Like(APLDCT.fldNme);
    pmrDspFle Like(APLDCT.dspFle);
    pmrVal    Like(APLDCT.val   );
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  dctNme=pmrDctNme;
  fldNme=pmrFldNme;
  dspFle=pmrDspFle;
  val   =pmrVal;

  // Sets the Option if passed
  If %parms >= 5;
    option = pmrOption;
  EndIf;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$Security(psdsPgmNam:psdsUsrPrf:option);
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
    ElseIf keyPressed = 'F6';
      InsertLine();
    ElseIf keyPressed = 'F10';
      CopyLine();
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F14';
      DeleteLine();
    ElseIf keyPressed = 'F15';
      SplitLine();
    ElseIf keyPressed = 'F16';
      CombineLine();
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
      // process f9 here, the screen has to be validated and updated before it is processed
      If keyPressed = 'F9';
        DisplayHelpText();
      EndIf;
    EndIf;

  EndDo;

  Close HLPDTLF1;

  // delete the work file
  Exec SQL Drop Table QTEMP/WORK;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 6;
    pmrKeyPressed = keyPressed;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

  // Load message SFL
  Write MSGCTL;

  // set drop/fold option, change the comand key text
  sflDrop = (SFLmode = *off);
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
  If keypressed='PAGEDOWN' and CsrRRN1=0 and EOF;
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
  SetAttributes();

End-Proc;


// Set Field Attributes
Dcl-Proc SetAttributes;

  If ProtectDta;
    FldAtrDta = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrDta;
  EndIf;

  If ProtectKey;
    FldAtrKey = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrKey;
  EndIf;

  If ProtectCpy;
    FldAtrCpy = *allx'A7';    // @PrND
  Else;
    FldAtrCpy = *allx'A2';    // @PrWht
    // $SetAttribute(frmKeys@:'');
  EndIf;

End-Proc;


// Refresh the screen back to how it was when the program was first called
Dcl-Proc RefreshScreen;

  // Set field attributes fields to the defaults
  SetAttributes();

  LoadSFL();

End-Proc;


// Display Help Text
Dcl-Proc DisplayHelpText;

  CallP HLPMSTB4(dctNme:fldNme:dspFle:val);

End-Proc;


// Update anything entered on the screen
Dcl-Proc UpdateScreen;
  Dcl-S lneCnt like(APLDCT.lneCnt);
  Dcl-S hlpTyp like(APLDCT.hlpTyp);

  // update changes to the SFL
  UpdateSFL();

  // Find the last seqNbr with data populated, this is used for the number of rows
  // and to include blank lines in the file without the trailing blank lines
  Exec SQL Select max(seqNbr) Into :lneCnt From QTEMP/WORK Where hlpTxt<>'';

  // calculate the help type value for the line
  If dctNme<>'' and FldNme<>'' and dspFle='';
    hlpTyp='1';
  ElseIf dctNme='' and FldNme<>'' and dspFle<>'';
    hlpTyp='2';
  ElseIf dctNme='' and FldNme='FNCKEYS' and dspFle<>'';
    hlpTyp='3';
  ElseIf dctNme='' and FldNme='OPTIONS' and dspFle<>'';
    hlpTyp='4';
  ElseIf dctNme='' and FldNme='' and dspFle<>'';
    hlpTyp='5';
  ElseIf dctNme='' and dspFle='';
    hlpTyp='6';
  Else;
    hlpTyp=' ';
  EndIf;

  // Update or add the help text header file
  Exec SQL Update HLPMST
           set hlpTyp=:hlpTyp,
               lneCnt=:lneCnt,
               hlpRef = :hlpRef,
               des = :des
           Where dctnme=:dctnme and fldNme=:fldNme and dspFle=:dspFle and val=:val;
  If sqlState>='02';
    Exec SQL Insert Into HLPMST
                 (acvRow, dctnme, fldNme, dspFle, val, hlpTyp, lneCnt, des)
           values('1',   :dctnme,:fldNme,:dspFle,:val,:hlpTyp,:lneCnt,:des);

  EndIf;

  // Clear the existing file
  Exec SQL
    Delete from HLPDTL
    Where ( dctNme, fldNme, dspFle, val) =
          (:dctNme,:fldNme,:dspFle,:val);

  // Add rows to the live file
  Exec SQL
    Insert Into HLPDTL
           (acvRow,dctNme, fldNme, dspFle, val,seqNbr,hlpTxt)
      Select '1',:dctNme,:fldNme,:dspFle,:val,seqNbr,hlpTxt
      From QTEMP/WORK w
      Where w.seqNbr<=:lneCnt;

End-Proc;


// Just updates the temp file
// The main file will not be updated till the program is exited
Dcl-Proc UpdateSFL;
  Dcl-S sflRcd packed(5);

  // Process saved SFL options
  For sflRcd = 1 To RRN1SV;
    Chain(e) sflRcd SFL;
    If %found;
      Exec SQL Update QTEMP/WORK
        set hlpTxt=:hlpTxt
        Where seqNbr=:seqNbr;
    EndIf;
  EndFor;

End-Proc;


// Insert a line after the line the cursor is on
Dcl-Proc InsertLine;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // add 1 to all lines greater than the seqNbr
  Exec SQL Update QTEMP/WORK set seqNbr=seqNbr+1 Where seqNbr>:seqnbr;

  // add a line
  Exec SQL Insert Into QTEMP/WORK values(:seqNbr+1,'');

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Copy the line the cursor is on
Dcl-Proc CopyLine;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // add 1 to all lines greater than the seqNbr
  Exec SQL Update QTEMP/WORK set seqNbr=seqNbr+1 Where seqNbr>:seqnbr;

  // add a line
  Exec SQL Insert Into QTEMP/WORK values(:seqNbr+1,:hlpTxt);

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Insert  line after the line the cursor is on
Dcl-Proc DeleteLine;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // delete the line the cursor is on
  Exec SQL Delete QTEMP/WORK Where seqNbr=:seqNbr;

  // Sub 1 from all lines greater than the seqNbr
  Exec SQL Update QTEMP/WORK set seqNbr=seqNbr-1 Where seqNbr>:seqnbr;

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Split this line to a new line based on the cursor position
Dcl-Proc SplitLine;
  Dcl-S curTxt like(APLDCT.hlpTxt);
  Dcl-S nxtTxt like(APLDCT.hlpTxt);

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number and help text of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // Split the hlpTxt into curTxt and nxtTxt based on the cursor position
  curTxt = %subst(hlpTxt:1:csrcol-2);
  nxtTxt = %subst(hlpTxt:csrCol-1:79-csrCol-1);

  // Add 1 to all lines greater than the seqNbr
  Exec SQL Update QTEMP/WORK set seqNbr=seqNbr+1 Where seqNbr>:seqNbr;

  // update the line the cursor is on with just the current text
  Exec SQL Update QTEMP/WORK set hlpTxt=:curTxt Where seqNbr=:seqNbr;

  // add a line after the current line with the next text
  Exec SQL Insert Into QTEMP/WORK values(:seqNbr+1,:nxtTxt);

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Combine this line with the next line, both lines together have to fit on one line
Dcl-Proc CombineLine;
  Dcl-S curTxt like(APLDCT.hlpTxt);
  Dcl-S nxtTxt like(APLDCT.hlpTxt);
  Dcl-S newTxt Char(160);
  Dcl-S error ind;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // get help txt from this line and the next line
  Exec SQL Select hlpTxt Into :curTxt From QTEMP/WORK Where seqNbr=:seqNbr;
  Exec SQL Select hlpTxt Into :nxtTxt From QTEMP/WORK Where seqNbr=:seqNbr+1;

  // see if the line will fit together
  newTxt= %trimr(curTxt) + ' ' + %trim(nxtTxt);
  If %len(%trimr(newTxt))>79;
    $ErrorMessage('':'Error - Lines will not fit on one line.':error:
                  hlpTxt@:'hlpTxt':outRow:outCol:psdsPgmNam);
    Return;
  EndIf;

  // update the current line with combined text
  Exec SQL Update QTEMP/WORK set hlpTxt=:newTxt Where seqNbr=:seqNbr;

  // delete the next line
  Exec SQL Delete QTEMP/WORK Where seqNbr=:seqNbr+1;

  // Sub 1 from all lines greater than the seqNbr
  Exec SQL Update QTEMP/WORK set seqNbr=seqNbr+1 Where seqNbr>:seqNbr;

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  RRN1  = 1;
  error = *Off;

  // Validate header fields if in entry, just make sure that something is entered and they don't
  // already exist
  If Create and dctNme='' and dspFle='' and fldNme='' and val='';
    $ErrorMessage('':'Error, you must enter at least one value.'
                  :error:dctNme@:'dctNme':outRow:outCol:psdsPgmNam:dspFle@:fldNme@:val@);
  EndIf;

  // Make sure a field description is entered if there is not a referecne help field
  If Des = '' and hlpRef = '';
    $ErrorMessage('':'Error, you must enter a field description.'
                  :error:des@:'des':outRow:outCol:psdsPgmNam);
  EndIf;

  Return error;

End-Proc;


// Load the previous page of data
Dcl-Proc PageUp;

  // save anything change on this screen
  UpdateSFL();

  // Calculate the next starting sequence number
  If currentRow-SFLPage<0;
    currentRow=0;
  Else;
    currentRow-=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Load the next page of data
Dcl-Proc PageDown;

  // save anything change on this screen
  UpdateSFL();

  // Calculate the next starting sequence number
  If currentRow+SFLPage<NumberOfRows;
    currentRow+=SFLPage;
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
  sflClr = *on;
  Write SFLCTL;
  sflClr = *off;
  sflDsp = *on;

  // Position Cursor
  Exec SQL Fetch Relative :CurrentRow From SQLCrs;

  // load one page of information into the array data structure
  Clear dta;
  Exec SQL Fetch SQLCrs For :SFLPage rows Into :dta;

  // Load SFL from the array
  rrn1=0;
  For i = 1 To SFLPage;
    If Dta(i).seqNbr>0;
      seqNbr  = Dta(i).seqNbr;
      hlpTxt  = Dta(i).hlpTxt;
      RRN1 += 1;
      Write SFL;
    EndIf;
  EndFor;

  OutRRN1 = 1;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    SflDsp  = *Off;
  EndIf;

End-Proc;


// Build the SQl Statement
Dcl-Proc BuildSQLStatement;

  sqlStm = 'Select +
              seqNbr, +
              hlpTxt +
            From QTEMP/WORK +
            Order by seqNbr';

  // Create and open cursor for selected records
  Exec SQL Close SQLCrs;
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;

  // Get total number of records for selected data
  Exec SQL Get DIAGNOSTICS :numberOfRows = DB2_NUMBER_ROWS;

End-Proc;


// This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;
  Dcl-S i Packed(3);
  Dcl-S lastSeq like(APLDCT.seqNbr);

  Exec SQL
       Declare HLPDTL Asensitive Scroll Cursor For DYNSQLStm;

  Open HLPDTLF1;

  // create workfile in qtemp, drop it first if it already exists
  Exec SQL Drop Table QTEMP/WORK;
  Exec SQL
    Create Table QTEMP/WORK as (
      Select
        seqNbr,
        hlpTxt
      From HLPDTL
      )
      Definition Only;

  // insert data from live file into work file, instead of using the seqNbr from the
  // file re-number them, this will prevent an issue where the file may have been DFU'ed
  // and now could skip a number
  Exec SQL
    Insert Into QTEMP/WORK
      Select
        ROW_NUMBER() over (Order by seqNbr) seqNbr,
        hlpTxt
      From HLPDTL
      Where dctNme=:dctNme
        and FldNme=:fldNme
        and dspFle=:dspFle
        and val=:val;


  // add 500 more rows just to have room to work with
  Exec SQL Select max(seqnbr) Into :lastSeq From QTEMP/WORK;
  For i = 1 To 500;
    Exec SQL Insert Into QTEMP/WORK
             (seqNbr, hlpTxt)
             values(:i+:lastSeq,'');
  EndFor;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Sets on indicators for the mode and the mode name
  ProtectCpy = *on;
  ProtectKey = *on;
  ProtectDta = *on;
  Display = *Off;
  Maintenance = *Off;
  If Option = '1';
    ProtectKey = *off;
    ProtectDta = *off;
    Create = *On;
    mode='Create';
  ElseIf Option = '5';
    Display = *On;
    mode='Revise';
  Else;
    Maintenance = *On;
    ProtectDta = *off;
    mode='Update';
  EndIf;

  // Set field attributes fields to the defaults
  SetAttributes();

  // Get Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$NextFunctionKeys(fncDs);

  // get the field name from the master file
  Exec SQL Select des,hlpRef into :des,:hlpRef from HLPMST
    Where ( DCTNME, FLDNME, DSPFLE, VAL)
        = (:DCTNME,:FLDNME,:DSPFLE,:VAL);

  // If a field name is not found and the field references a dictionary,
  // get the field name form the dictionary.
  If des = '' and dctNme <> '';
    Exec SQL Select colTxt into :des from DCTFLD Where (DCTNME, FLDNME) = (:DCTNME,:FLDNME);
  EndIf;

  // build the help text type
  If dctNme<>'' and fldNme<>'' and dspFle='';
    hlpTypD='Dictionary Field';
  ElseIf dctNme='' and fldNme<>'' and dspFle<>'';
    hlpTypD='Screen Field';
  ElseIf dctNme='' and fldNme='FNCKEYS' and dspFle<>'';
    hlpTypD='Screen Function Key';
  ElseIf dctNme='' and fldNme='OPTIONS' and dspFle<>'';
    hlpTypD='Screen SFL Option';
  ElseIf dctNme='' and fldNme='' and dspFle<>'';
    hlpTypD='Screen Header';
  ElseIf dctNme='' and fldNme='' and dspFle='' and val <> '';
    hlpTypD='System Default, Option/Function';
  ElseIf dctNme='' and fldNme<>'' and dspFle='' and val = '';
    hlpTypD='System Default, Field';
  Else;
    hlpTypD='Error';
  EndIf;

  LoadSFL();

End-Proc;
