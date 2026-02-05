**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// File Log List

Dcl-F FLELOGF2 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLELOGD1_@ // auto generated data structures for field attribute fields
/Copy QSRC,FLELOGD1PR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL

Dcl-S Option  like(APLDCT.Option); // global variable to store the option parameter in
Dcl-S fleLogIdn like(APLDCT.fleLogIdn);
Dcl-S lines char(131) dim(100);
Dcl-S lastLine packed(5);
Dcl-S logMsg like(APLDCT.logMsg);


// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLELOGD2');
    pmrFleLogIdn Like(APLDCT.fleLogIdn);
  End-Pi;

  fleLogIdn = pmrFleLogIdn;
  Option = '5';

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
    ElseIf keyPressed = 'F12';
      Leave;
    ElseIf keyPressed = 'F24';
      fncKeys=$NextFunctionKeys(fncDs);
    Else;
      Leave;
    EndIf;

  EndDo;

  Close FLELOGF2;

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

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL
  $ClearMessages();

  // Set field attributes fields to the defaults
  Clear FldAtrDta;

End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
Dcl-Proc ProgramInitialization;
  Dcl-S i packed(5);

  // Open the screen DSPF if it is not already open
  If not %open(FLELOGF2); // **change
    Open FLELOGF2; // **change
  EndIf;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  $GetFieldLocation(PgmNme:'fldNme':outRow:outCol);

  mde='Inquiry';

  // load page header information
  Exec SQL
    Select trim(FLELOG.fleLib) || '/' || trim(FLELOG.fleNme),
           FLELOG.FldNme,logTyp,logDes,logMsg,
           to_char(FLELOG.crtDtm, 'YYYY-MM-DD HH24:MI:SS'), FLELOG.crtusr, FLELOG.crtjob, FLELOG.crtpgm,
           Coalesce(fleDes,''), coalesce(colTxt,'')
    into  :fleLibCmb,
          :fldNme,:logTyp,:logDes,:logMsg,
          :crtDtmTxt, :crtUsr,:crtJob,:crtPgm,
          :fleDes, :coltxt
    from  FLELOG
    left join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLELOG.fleLib,FLELOG.fleNme)
    left join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLELOG.fldNme)
    where fleLogIdn = :fleLogIdn;

  idnTxt = %char(fleLogIdn);

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option:*omit:132);
  fncKeys=$NextFunctionKeys(fncDs);

  // Clear SFL
  SflClr = *on;
  Write SFLCTL;
  SflClr = *off;
  SflDsp = *on;

  // parse the log entry into an array of 131 byte fields
  SplitMsg(); // populates Lines and lastLine;

  // Load SFL from the array
  RRN1=0;
  For i = 1 To lastLine;
    detail=lines(i);
    RRN1 += 1;
    Write SFL;
  EndFor;
  OutRRN1 = 1;

  // if there is no data, don't display the SFL
  If RRN1 = 0;
    SflDsp  = *Off;
  EndIf;

End-Proc;



// split lines from one message, handles break on '&N ' inserting a blank line
Dcl-Proc SplitMsg;
  Dcl-S i packed(5);
  Dcl-S start packed(5);
  Dcl-S space packed(5);
  Dcl-S trimLength packed(5);
  Dcl-S end packed(5);
  Dcl-S length packed(5);
  Dcl-S lengthCounter packed(5);
  Dcl-S stringInLen packed(5);

  start = 1;
  trimLength = 131;
  space = trimLength;
  end = 0;
  length = 0;
  lastLine = 0;
  lengthCounter = 0;
  Clear lines;

  i = 1;
  stringInLen = %len(logMsg);

  DoW i <= stringInLen and %subst(logMsg:i) <> ' ';

    // Check to see if it is a space
    If %subst(logMsg:i:1) = ' ';
      space = i;
    EndIf;

    // if the next 3 characters are '&N ', add the line, skip a space and advance the pointer 2 characters
    If i < stringInLen - 3 and %subst(logMsg:i:3) = '&N ';
      space = i;
      ExSr AdvanceLine;
      i += 3;
      start += 3;
      lastLine += 1;

      // if past the trim length add line
    ElseIf lengthCounter >= trimLength;
      ExSr AdvanceLine;
    EndIf;

    i += 1;
    lengthCounter += 1;
  EndDo;

  end = i;
  ExSr AddString;

  // AdvanceLine - Add a line to the array
  BegSr AdvanceLine;
    end = space - 1;
    ExSr AddString;
    If %subst(logMsg:space:1) = ' ';
      start = space + 1;
    Else;
      start = space;
    EndIf;
    lengthCounter = (1 + (i - start + 1));
    space += trimLength;
  EndSr;

  // AddString - Add the line to the array
  BegSr AddString;

    lastLine += 1;
    length = end - start + 1;

    If length < 1;
      length = trimLength;
    EndIf;

    If ((start + length) < stringInLen);
      lines(lastLine) = %subst(logMsg:start:length);
    Else;
      lines(lastLine) = %subst(logMsg:start);
    EndIf;
  EndSr;

End-Proc;
