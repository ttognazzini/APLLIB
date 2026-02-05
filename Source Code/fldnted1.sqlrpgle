**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Field Notes Maintenance

Dcl-F FLDNTEF1 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLDNTED1_@ // auto generated data structures for field attribute fields
/Copy QSRC,FLDNTED1PR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1);
Dcl-S LastRRN  Like(OutRRN1);
Dcl-S CurrentRow packed(9);
Dcl-S NumberOfRows packed(9);

Dcl-S Option  like(APLDCT.Option);
Dcl-S fleLib  like(APLDCT.fleLib);
Dcl-S fleNme  like(APLDCT.fleNme);

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
  Dcl-Pi *n ExtPgm('FLDNTED1');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrFldNme Like(APLDCT.fldNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  fleLib=pmrFleLib;
  fleNme=pmrFleNme;
  fldNme=pmrFldNme;

  // Sets the Option if passed
  If %parms >= 3;
    Option = pmrOption;
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
    EndIf;

  EndDo;

  Close FLDNTEF1;

  // delete the work file
  Exec SQL Drop Table QTEMP/WORK;

  // Handle return options

  // Send back Key pressed if passed
  If %parms >= 4;
    pmrKeyPressed=keyPressed;
  EndIf;

End-Proc;


// Write message SFL, Display the screen, reset errors
Dcl-Proc DisplayScreen;

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


// Update anything entered on the screen
Dcl-Proc UpdateScreen;
  Dcl-S lneCnt like(APLDCT.lneCnt);
  Dcl-S fleFldIdn like(APLDCT.fleFldIdn);
  Dcl-S notes varchar(10000);
  Dcl-S sqlStm varchar(10000);

  // update changes to the SFL
  UpdateSFL();

  // get the file field id
  Exec SQL Select fleFldIdn into :fleFldIdn from FLEFLD where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);

  // Find the last sequence number with data populated, this is used for the number of rows
  // and to include blank lines in the file without the trailing blank lines
  Exec SQL Select max(nteSeq) Into :lneCnt From QTEMP/WORK Where nte<>'';

  // Clear the existing file
  Exec SQL Delete from FLDNTE Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);

  // Add rows to the live file
  Exec SQL
    Insert Into FLDNTE
             (fleLib, fleNme, fldNme, nteSeq, fleFldIdn, nte,
              CrtDtm, CrtUsr, CrtJob, CrtPgm,
              MntDtm, MntUsr, MntJob, MntPgm)
      Select :fleLib,:fleNme,:fldNme, nteSeq,:fleFldIdn, nte,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
      From QTEMP/WORK w
      Where w.nteSeq <= :lneCnt;

  // Get all the notes concatenated into one big field and update the long comment on the file
  Exec SQl Select listagg(trim(nte),' ') within group(order by nteSeq)
            into :notes
            from FLDNTE
            where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);
  sqlStm = 'Comment on Column ' + %trim(fleLib) + '/' + %trim(fleNme) +
             ' (' + %trim(fldNme) + ' is ''' + #$DBLQ(notes) + ''')';
  Exec SQL execute immediate :sqlStm;

  // update the notes exist flag in FLEFLD
  Exec SQL
    Update FLEFLD
    Set nteExs =
      Case when (
          Select count(*)
          From FLDNTE
          Where (FLDNTE.fleLib,FLDNTE.FleNme,FLDNTE.fldNme)
              = (:fleLib,:fleNme,:fldNme)
        ) >= 1 then 'Y'
      Else 'N' end
    Where (FLEFLD.fleLib,FLEFLD.FleNme,FLEFLD.fldNme)
        = (:fleLib,:fleNme,:fldNme);

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
        set nte=:nte
        Where nteSeq=:nteSeq;
    EndIf;
  EndFor;

End-Proc;


// Insert a line after the line the cursor is on
Dcl-Proc InsertLine;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // add 1 to all lines greater than the sequence number
  Exec SQL Update QTEMP/WORK set nteSeq=nteSeq+1 Where nteSeq>:nteSeq;

  // add a line
  Exec SQL Insert Into QTEMP/WORK values(:nteSeq+1,'');

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Copy the line the cursor is on
Dcl-Proc CopyLine;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // add 1 to all lines greater than the sequence number
  Exec SQL Update QTEMP/WORK set nteSeq=nteSeq+1 Where nteSeq>:nteSeq;

  // add a line
  Exec SQL Insert Into QTEMP/WORK values(:nteSeq+1,:nte);

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
  Exec SQL Delete QTEMP/WORK Where nteSeq=:nteSeq;

  // Sub 1 from all lines greater than the nteSeq
  Exec SQL Update QTEMP/WORK set nteSeq=nteSeq-1 Where nteSeq>:nteSeq;

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Split this line to a new line based on the cursor position
Dcl-Proc SplitLine;
  Dcl-S curTxt like(APLDCT.nte);
  Dcl-S nxtTxt like(APLDCT.nte);

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number and help text of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // Split the nte into curTxt and nxtTxt based on the cursor position
  curTxt = %subst(nte:1:csrcol-2);
  nxtTxt = %subst(nte:csrCol-1:60-csrCol-1);

  // Add 1 to all lines greater than the nteSeq
  Exec SQL Update QTEMP/WORK set nteSeq=nteSeq+1 Where nteSeq>:nteSeq;

  // update the line the cursor is on with just the current text
  Exec SQL Update QTEMP/WORK set nte=:curTxt Where nteSeq=:nteSeq;

  // add a line after the current line with the next text
  Exec SQL Insert Into QTEMP/WORK values(:nteSeq+1,:nxtTxt);

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Combine this line with the next line, both lines together have to fit on one line
Dcl-Proc CombineLine;
  Dcl-S curTxt like(APLDCT.nte);
  Dcl-S nxtTxt like(APLDCT.nte);
  Dcl-S newTxt Char(160);
  Dcl-S error ind;

  // Save any changes to the screen first
  UpdateSFL();

  // Get the sequence number of the line the cursor is on
  Chain(e) csrRrn1 SFL;

  // get help txt from this line and the next line
  Exec SQL Select nte Into :curTxt From QTEMP/WORK Where nteSeq=:nteSeq;
  Exec SQL Select nte Into :nxtTxt From QTEMP/WORK Where nteSeq=:nteSeq+1;

  // see if the line will fit together
  newTxt= %trimr(curTxt) + ' ' + %trim(nxtTxt);
  If %len(%trimr(newTxt))>60;
    $ErrorMessage('':'Error - Lines will not fit on one line.':error:
                  nte@:'nte':outRow:outCol:psDsPgmNam);
    Return;
  EndIf;

  // update the current line with combined text
  Exec SQL Update QTEMP/WORK set nte=:newTxt Where nteSeq=:nteSeq;

  // delete the next line
  Exec SQL Delete QTEMP/WORK Where nteSeq=:nteSeq+1;

  // Sub 1 from all lines greater than the nteSeq
  Exec SQL Update QTEMP/WORK set nteSeq=nteSeq+1 Where nteSeq>:nteSeq;

  // reload the SFL from the work file
  LoadSFL();

End-Proc;


// Validate anything entered on the screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  error = *Off;

  Return error;

End-Proc;


// Load the previous page of data
Dcl-Proc PageUp;

  // save anything change on this screen
  UpdateSFL();

  // Calculate the next starting sequence number
  If CurrentRow-SFLPage<0;
    CurrentRow=0;
  Else;
    CurrentRow-=SFLPage;
  EndIf;

  LoadSFL();

End-Proc;


// Load the next page of data
Dcl-Proc PageDown;

  // save anything change on this screen
  UpdateSFL();

  // Calculate the next starting sequence number
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

  // Position Cursor
  Exec SQL Fetch Relative :CurrentRow From SQLCrs;

  // load one page of information into the array data structure
  Clear dta;
  Exec SQL Fetch SQLCrs For :SFLPage rows Into :dta;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To SFLPage;
    If dta(i).nteSeq>0;
      nteSeq  = dta(i).nteSeq;
      nte  = dta(i).nte;
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
              nteSeq, +
              nte +
            From QTEMP/WORK +
            Order by nteSeq';

  // Create and open cursor for selected records
  Exec SQL Close SQLCrs;
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare SQLCrs Insensitive Scroll Cursor For sqlStm;
  Exec SQL Open  SQLCrs;

  // Get total number of records for selected data
  Exec SQL Get DIAGNOSTICS :NumberOfRows = DB2_NUMBER_ROWS;

End-Proc;


// This routine gets run when the program is first started
Dcl-Proc ProgramInitialization;
  Dcl-S i Packed(3);
  Dcl-S lastSeq like(APLDCT.nteSeq);
  Dcl-S dctNme like(APLDCT.dctNme);

  If not %open(FLDNTEF1);
    Open FLDNTEF1;
  EndIf;

  // create workfile in qtemp, drop it first if it already exists
  Exec SQL Drop Table QTEMP/WORK;
  Exec SQL
    Create Table QTEMP/WORK as (
      Select
        nteSeq,
        nte
      From FLDNTE
      )
      Definition Only;

  // insert data from live file into work file, instead of using the nteSeq from the
  // file re-number them, this will prevent an issue where the file may have been DFU'ed
  // and now could skip a number
  Exec SQL
    Insert Into QTEMP/WORK
      Select
        ROW_NUMBER() over (Order by nteSeq) nteSeq,
        nte
      From FLDNTE
      Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);


  // add 500 more rows just to have room to work with
  Exec SQL Select max(nteSeq) Into :lastSeq From QTEMP/WORK;
  For i = 1 To 500;
    Exec SQL Insert Into QTEMP/WORK
             (nteSeq, nte)
             values(:i+:lastSeq,'');
  EndFor;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Sets on indicators for the mode and the mode name
  // * protect fields
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

  // get the file name and dictionary from the master file
  Exec SQL Select fleDes, dctNme into :fleDes,:dctNme from FLEMST Where ( fleLib, fleNme) = (:fleLib,:fleNme);

  // get the field column text from the dictionary
  Exec SQL Select colTxt into :colTxt from DCTFLD where (dctNme,fldNme) = (:dctNme,:fldNme);

  // Build the short lib/file text for the screen
  libNme = %trim(fleLib) + '/' + %trim(fleNme);

  LoadSFL();

End-Proc;
