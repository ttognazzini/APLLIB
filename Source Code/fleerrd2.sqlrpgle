**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// File Error Detail

Dcl-F FLEERRF2 WorkStn SFile(SFL:RRN1) InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEERRD2_@ // auto generated data structures for field attribute fields
/Copy QSRC,FLEERRD1PR // Always include the prototype for the current program

Dcl-S RRN1   Like(OutRRN1); // the relative record number for the SFL

Dcl-S Option  like(APLDCT.Option); // global variable to store the option parameter in
Dcl-S fleErrIdn like(APLDCT.fleErrIdn);
Dcl-S lines char(131) dim(100);
Dcl-S lastLine packed(5);
Dcl-S errMsg like(APLDCT.errMsg);


// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEERRD2');
    pmrFleErrIdn Like(APLDCT.fleErrIdn);
  End-Pi;

  fleErrIdn = pmrFleErrIdn;
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

  Close FLEERRF2;

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
  If not %open(FLEERRF2); // **change
    Open FLEERRF2; // **change
  EndIf;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  $GetFieldLocation(PgmNme:'fldNme':outRow:outCol);

  mde='Inquiry';

  // load page header information
  Exec SQL
    Select trim(FLEERR.fleLib) || '/' || trim(FLEERR.fleNme),
           FLEERR.FldNme, fleErr.des, errMsg,
           to_char(FLEERR.crtDtm, 'YYYY-MM-DD HH24:MI:SS'), FLEERR.crtusr, FLEERR.crtjob, FLEERR.crtpgm,
           Coalesce(fleDes,''), coalesce(colTxt,''),
           case when FLEERR.idxNme <> '' then trim(FLEERR.idxLib) || '/' || trim(FLEERR.idxNme)
                else '' end,
           Coalesce(idxTxt,'')
    into  :fleLibCmb,
          :fldNme,:Des,:errMsg,
          :crtDtmTxt, :crtUsr,:crtJob,:crtPgm,
          :fleDes, :coltxt,
          :idxLibCmb,
          :idxTxt
    from  FLEERR
    left join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEERR.fleLib,FLEERR.fleNme)
    left join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEERR.fldNme)
    left join FLEIDX on (FLEIDX.idxLib,FLEIDX.idxNme) = (FLEERR.idxLib,FLEERR.idxNme)
    where fleErrIdn = :fleErrIdn;

  idnTxt = %char(fleErrIdn);

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
  Dcl-S startPos packed(5);
  Dcl-S space packed(5);
  Dcl-S trimLength packed(5);
  Dcl-S endPos packed(5);
  Dcl-S length packed(5);
  Dcl-S lengthCounter packed(5);
  Dcl-S stringInLen packed(5);

  startPos = 1;
  trimLength = 131;
  space = trimLength;
  endPos = 0;
  length = 0;
  lastLine = 0;
  lengthCounter = 0;
  Clear lines;

  i = 1;
  stringInLen = %len(errMsg);

  DoW i <= stringInLen and %subst(errMsg:i) <> ' ';

    // Check to see if it is a space
    If %subst(errMsg:i:1) = ' ';
      space = i;
    EndIf;

    // if the next 3 characters are '&N ', add the line, skip a space and advance the pointer 2 characters
    If i < stringInLen - 3 and %subst(errMsg:i:3) = '&N ';
      space = i;
      ExSr AdvanceLine;
      i += 3;
      startPos += 3;
      lastLine += 1;

      // if past the trim length add line
    ElseIf lengthCounter >= trimLength;
      ExSr AdvanceLine;
    EndIf;

    i += 1;
    lengthCounter += 1;
  EndDo;

  endPos = i;
  ExSr AddString;

  // AdvanceLine - Add a line to the array
  BegSr AdvanceLine;
    endPos = space - 1;
    ExSr AddString;
    If %subst(errMsg:space:1) = ' ';
      startPos = space + 1;
    Else;
      startPos = space;
    EndIf;
    lengthCounter = (1 + (i - startPos + 1));
    space += trimLength;
  EndSr;

  // AddString - Add the line to the array
  BegSr AddString;

    lastLine += 1;
    length = endPos - startPos + 1;

    If length < 1;
      length = trimLength;
    EndIf;

    If ((startPos + length) < stringInLen);
      lines(lastLine) = %subst(errMsg:startPos:length);
    Else;
      lines(lastLine) = %subst(errMsg:startPos);
    EndIf;
  EndSr;

End-Proc;
