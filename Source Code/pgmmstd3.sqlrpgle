**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Program Master - Detail Copy

dcl-f PGMMSTF3 WorkStn InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMMSTD3_@ // auto generated data structures for field attribute fields
/Copy QSRC,pgmmstd3PR // Always include the prototype for the current program

Dcl-S Option  like(APLDCT.Option);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
// **CHANGE the parameters change as well as any custom command keys
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMMSTD3');
    pmrFrmPgm Like(APLDCT.pgmNme);
    pmrToPgm Like(APLDCT.pgmNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Sets the Option if passed
  // **CHANGE - match pmrOption to the parm number, add any passed parms to globals vars if required
  If %Parms >= 2;
    Option = pmrOption;
  EndIf;

  // If the option is anything other than 3, just leave
  If option <> '3';
    return;
  EndIf;

  // move parameteres to global variables so other procedures can access them
  frmPgm=pmrFrmPgm;
  toPgm=pmrToPgm;

  // Figure out authority stuff, downgrade Option if higher than allowed, set Option if 0
  $securityDs=$security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed and Option<>'1'; //allow selection even if not allowed in program
    #$SndMsg('Not authorized to program');
    Return;
  EndIf;

  ProgramInitialization();

  DoU keyPressed='F3' and KeyPressed='F12';
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
      fncKeys=$nextFunctionKeys(fncDs);
    ElseIf ValidateScreen();
      Iter;
    Else;
      UpdateScreen();
      leave;
    EndIf;

  EndDo;

  Close PGMMSTF3;

  // Handle return options

  // Send back Key pressed if passed
  // **CHANGE parm numbers
  If %Parms >= 3;
    pmrKeyPressed=KeyPressed;
  EndIf;

End-Proc;


// Display Screen
// *** Do not change anything in here ***
Dcl-Proc DisplayScreen;

  // Load SFL options if needed
  Write MSGCTL;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRow and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields otuRowScr and outRowCol which means we
  // have to move the values into those fields before we display the screen.
  outRowScr=outRow;
  outColScr=outCol;

  ExFmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  SetAttributes();

End-Proc;


// Set Field Attributes
// *** Do not change anything in here ***
Dcl-Proc SetAttributes;

  Clear FldAtrDta;

End-Proc;


// Update anything entered on the screen
// This only processes the position to, the only other option is 1 and that is processed in Copy()
Dcl-Proc UpdateScreen;
  Dcl-S Error Ind; // set if any errors occure

  // Copy main source
  if cpySrc='Y';
    Monitor;
      #$cmd('CPYSRCF FROMFILE('+%trim(frmLib)+'/QSRC) +
                     TOFILE('+%trim(toLib)+'/QSRC) +
                     FROMMBR('+%trim(frmPgm)+') +
                     TOMBR('+%trim(topgm)+')':2);
    On-Error;
      #$sndMsg('*** Member '+%TRIM(frmLib)+'/QSRC,'+%trim(frmPgm)+' not copied.');
      error=*on;
    EndMon;
  EndIf;

  // Copy Function keys
  if cpyFnc='Y';
    Exec SQL
      Insert into PGMFNC
       ( ACVROW, PGMNME, FNCKEY, OPTION, SEQNBR, DES,
         CRTDTM, CRTUSR, CRTJOB, CRTPGM,
         MNTDTM, MNTUSR, MNTJOB, MNTPGM)
       (Select
         '1',   :TOPGM,  FNCKEY, OPTION, SEQNBR, DES,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
       from PGMFNC
       where pgmnme = :frmPgm
       );
    if SQLState>'02000';
      #$sndMsg('*** PGMFNC entry not copied, SQLSTATE = '+%trim(SQLSTATE)+', SQLERRMC='+%TRIM(SQLErrMC) + '.');
      error=*on;
    ENDIF;
  ENDIF;

  // Copy SFL Options
  if cpyOpt='Y';
    Exec SQL
      Insert into PGMOPT
       ( ACVROW, PGMNME, OPT, OPTION, DES,
         CRTDTM, CRTUSR, CRTJOB, CRTPGM,
         MNTDTM, MNTUSR, MNTJOB, MNTPGM)
       (Select
         '1',   :TOPGM,  OPT, OPTION, DES,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
       from PGMOPT
       where pgmnme = :frmPgm
       );
    if SQLState>'02000';
      #$sndMsg('*** PGMOPT entry not copied, SQLSTATE = '+%trim(SQLSTATE)+', SQLERRMC='+%TRIM(SQLErrMC) + '.');
      error=*on;
    ENDIF;
  ENDIF;

  // Copy display file if it exists
  if cpyDsp='Y';
    Monitor;
      #$cmd('CPYSRCF FROMFILE('+%trim(frmDlb)+'/QSRC) +
                     TOFILE('+%trim(toDlb)+'/QSRC) +
                     FROMMBR('+%trim(frmDsp)+') +
                     TOMBR('+%trim(toDsp)+')':2);
    On-Error;
      #$sndMsg('*** Member '+%TRIM(frmDlb)+'/QSRC,'+%trim(frmDsp)+' not copied.');
      error=*on;
    EndMon;
  ENDIF;

  // Copy prototype if it exists
  if cpyPrt='Y';
    Monitor;
      #$cmd('CPYSRCF FROMFILE('+%trim(frmPlb)+'/QSRC) +
                     TOFILE('+%trim(toPlb)+'/QSRC) +
                     FROMMBR('+%trim(frmPrt)+') +
                     TOMBR('+%trim(toPrt)+')':2);
    On-Error;
      #$sndMsg('*** Member '+%TRIM(frmPlb)+'/QSRC,'+%trim(frmPrt)+' not copied.');
      error=*on;
    EndMon;
  ENDIF;

  // Copy view if it exists
  if cpyViw='Y';
    Monitor;
      #$cmd('CPYSRCF FROMFILE('+%trim(frmVlb)+'/QSRC) +
                     TOFILE('+%trim(toVlb)+'/QSRC) +
                     FROMMBR('+%trim(frmViw)+') +
                     TOMBR('+%trim(toViw)+')':2);
    On-Error;
      #$sndMsg('*** Member '+%TRIM(frmVlb)+'/QSRC,'+%trim(frmViw)+' not copied.');
      error=*on;
    EndMon;
  ENDIF;

  // If any errors occured show a window stating that the user should check the job log
  if error;
    #$DspWin('Some errors occured during copy. Check the job log for the errors.');
  EndIf;

End-Proc;


// Validate anything entered on the screen
// **CHANGE Add validation
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;

  Error = *Off;

  // validate copy function keys
  if not #$in(cpyFnc:'Y':'N');
    $ErrorMessage('':'Error - Copy Function Keys must be a Y or an N.':error:cpyFnc@:'cpyFnc':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate copy SFL option
  if not #$in(cpyOpt:'Y':'N');
    $ErrorMessage('':'Error - Copy SFL Options must be a Y or an N.':error:cpyOpt@:'cpyOpt':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate copy source file
  if not #$in(cpySrc:'Y':'N');
    $ErrorMessage('':'Error - Copy Program Source must be a Y or an N.'
                    :error:cpySrc@:'cpySrc':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate copy display file
  if not #$in(cpyDsp:'Y':'N');
    $ErrorMessage('':'Error - Copy Display File must be a Y or an N.':error:cpyDsp@:'cpyDsp':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate copy prototype
  if not #$in(cpyPrt:'Y':'N');
    $ErrorMessage('':'Error - Copy Prototype must be a Y or an N.':error:cpyPrt@:'cpyPrt':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate copy view
  if not #$in(cpyViw:'Y':'N');
    $ErrorMessage('':'Error - Copy View must be a Y or an N.':error:cpyViw@:'cpyViw':outRow:outCol:psDsPgmNam);
  EndIf;

  // validate from and to libraries if copying program source
  if cpySrc='Y';
    if frmLib='';
      $ErrorMessage('':'Error - From Library is required.':error:frmLib@:'frmLib':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(frmLib);
      $ErrorMessage('':'Error - From Library is invalid.':error:frmLib@:'frmLib':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':frmLib);
      $ErrorMessage('':'Error - From Library does not contain file QSRC.'
                      :error:frmLib@:'frmLib':outRow:outCol:psDsPgmNam);
    ElseIf not #$isMbr(frmLib:'QSRC':frmPgm);
      $ErrorMessage('':'Error - Library '+%trim(frmLib)+', file QSRC does not contain member ' +%trim(frmPgm) + '.'
                      :error:frmLib@:'frmLib':outRow:outCol:psDsPgmNam);
    EndIf;
    if toLib='';
      $ErrorMessage('':'Error - To library is required.':error:toLib@:'toLib':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(toLib);
      $ErrorMessage('':'Error - To library is invalid.':error:toLib@:'toLib':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':toLib);
      $ErrorMessage('':'Error - To Library does not contain file QSRC.'
                      :error:frmLib@:'frmLib':outRow:outCol:psDsPgmNam);
    ElseIf #$isMbr(frmLib:'QSRC':toPgm);
      $ErrorMessage('':'Error - Library '+%trim(frmLib)+', file QSRC already not contains member ' +%trim(toPgm) + '.'
                      :error:toLib@:'toLib':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate from and to libraries if copying display file source
  if cpyDsp='Y';
    if frmDlb='';
      $ErrorMessage('':'Error - From Library is required.':error:frmDlb@:'frmDlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(frmDlb);
      $ErrorMessage('':'Error - From Library is invalid.':error:frmDlb@:'frmDlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':frmDlb);
      $ErrorMessage('':'Error - From Library does not contain file QSRC.'
                      :error:frmDlb@:'frmDlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isMbr(frmDlb:'QSRC':frmDsp);
      $ErrorMessage('':'Error - Library '+%trim(frmDlb)+', file QSRC does not contain member ' +%trim(frmDsp) + '.'
                      :error:frmDlb@:'frmDlb':outRow:outCol:psDsPgmNam);
    EndIf;
    if toDlb='';
      $ErrorMessage('':'Error - To library is required.':error:toDlb@:'toDlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(toDlb);
      $ErrorMessage('':'Error - To library is invalid.':error:toDlb@:'toDlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':toDlb);
      $ErrorMessage('':'Error - To Library does not contain file QSRC.'
                      :error:toDlb@:'toDlb':outRow:outCol:psDsPgmNam);
    ElseIf #$isMbr(toDlb:'QSRC':toDsp);
      $ErrorMessage('':'Error - Library '+%trim(toDlb)+', file QSRC already not contains member ' +%trim(toDsp) + '.'
                      :error:toDlb@:'toDlb':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate from and to libraries if copying prototype source
  if cpyPrt='Y';
    if frmPlb='';
      $ErrorMessage('':'Error - From Library is required.':error:frmPlb@:'frmPlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(frmPlb);
      $ErrorMessage('':'Error - From Library is invalid.':error:frmPlb@:'frmPlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':frmPlb);
      $ErrorMessage('':'Error - From Library does not contain file QSRC.'
                      :error:frmPlb@:'frmPlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isMbr(frmPlb:'QSRC':frmPrt);
      $ErrorMessage('':'Error - Library '+%trim(frmPlb)+', file QSRC does not contain member ' +%trim(frmPrt) + '.'
                      :error:frmPlb@:'frmPlb':outRow:outCol:psDsPgmNam);
    EndIf;
    if toPlb='';
      $ErrorMessage('':'Error - To library is required.':error:toPlb@:'toPlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(toPlb);
      $ErrorMessage('':'Error - To library is invalid.':error:toPlb@:'toPlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':toPlb);
      $ErrorMessage('':'Error - To Library does not contain file QSRC.'
                      :error:frmPlb@:'frmPlb':outRow:outCol:psDsPgmNam);
    ElseIf #$isMbr(toPlb:'QSRC':toPrt);
      $ErrorMessage('':'Error - Library '+%trim(toPlb)+', file QSRC already not contains member ' +%trim(toPrt) + '.'
                      :error:toPlb@:'toPlb':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  // validate from and to libraries if copying view source
  if cpyViw='Y';
    if frmVlb='';
      $ErrorMessage('':'Error - From Library is required.':error:frmVlb@:'frmVlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(frmVlb);
      $ErrorMessage('':'Error - From Library is invalid.':error:frmVlb@:'frmVlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':frmVlb);
      $ErrorMessage('':'Error - From Library does not contain file QSRC.'
                      :error:frmVlb@:'frmVlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isMbr(frmVlb:'QSRC':frmviw);
      $ErrorMessage('':'Error - Library '+%trim(frmVlb)+', file QSRC does not contain member ' +%trim(frmViw) + '.'
                      :error:frmVlb@:'frmVlb':outRow:outCol:psDsPgmNam);
    EndIf;
    if toVlb='';
      $ErrorMessage('':'Error - To library is required.':error:toVlb@:'toVlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$islib(toVlb);
      $ErrorMessage('':'Error - To library is invalid.':error:toVlb@:'toVlb':outRow:outCol:psDsPgmNam);
    ElseIf not #$isfile('QSRC':toVlb);
      $ErrorMessage('':'Error - To Library does not contain file QSRC.'
                      :error:frmVlb@:'frmVlb':outRow:outCol:psDsPgmNam);
    ElseIf #$isMbr(toVlb:'QSRC':toViw);
      $ErrorMessage('':'Error - Library '+%trim(toVlb)+', file QSRC already not contains member ' +%trim(toViw) + '.'
                      :error:toVlb@:'toVlb':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  Return error;

End-Proc;


// This routine gets run when the program is first started, this gets called again if F5=Refresh is used
// **CHANGE The cursor name and display file name needs to be changed as well as the initial field to set the cursor to
Dcl-Proc ProgramInitialization;

  Exec SQL
       Declare PGMMST Asensitive Scroll Cursor For DYNSQLStm;

  // Open the screen DSPF if it is not already open
  if not %open(PGMMSTF3); // **CHANGE
    Open PGMMSTF3; // **CHANGE
  Endif;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main.PgmNme2 is used in the screen headers.
  callStk='MAIN';
  pgmNme2=psdsPgmNam;

  // positition cursor to the dictionary position to field
  $getFieldLocation(PgmNme2:'pgmNme1':outRow:OutCol);

  // Sets on indicators for the mode and the mode name
  mode='Copy';

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$nextFunctionKeys(fncDs);

  // set default header fields
  cpyFnc = 'Y';
  cpyOpt = 'Y';
  cpySrc = 'Y';
  cpyDsp = 'N';
  cpyPrt = 'N';
  cpyViw = 'N';

  // get to library, it is the first library with QSRC in the library list
  Exec SQL
    Select table_SCHEMA into :toLib
    from systables as t
    join liblistsv as l on l.SCHEMA_name = t.table_schema
    where Table_Name = 'QSRC'
    Order By Ordinal_Position
    Fetch First Row Only;

  // Get from library, it is the first QSRC file in the library that has the program member in it
  Exec SQL
    SELECT SCHEMA_NAME into :frmLib
    From LIBLISTSV
    Join TABLE (QSYS2.PARTITION_STATISTICS(cast(Schema_Name as char(10)), cast('QSRC ' as char(10))) ) on 1=1
    Where Table_Partition = :FrmPgm and type='USER'
    Order By Ordinal_Position
    fetch first row only;

  // get the from dspf name, if it exists set the to dspf name and library
  Clear frmDsp;
  Exec SQL
    select dspFle into :frmDsp
    From PGMMST
    where pgmNme=:frmPgm;
  if frmDsp<>'';
    toDsp=%subst(toPgm:1:6)+'F'+%subst(toPgm:8:3);
    cpyDsp = 'Y';
    toDlb=toLib;
    // Get display file from library, it is the first QSRC file in the library list that has the display file member in
    Exec SQL
      SELECT SCHEMA_NAME into :frmDlb
      From LIBLISTSV
      Join TABLE (QSYS2.PARTITION_STATISTICS(cast(Schema_Name as char(10)), cast('QSRC ' as char(10))) ) on 1=1
      Where Table_Partition = :FrmDsp and type='USER'
      Order By Ordinal_Position
      fetch first row only;
  EndIf;

  // get the from prototype name, if it exists set the to prototype name and library
  frmPrt = %trim(frmPgm) + 'PR';
  toPrt = '';
  cpyPrt = 'N';
  toPlb='';
  frmPlb='';
  // Get prototype from library, it is the first QSRC file in the library list that has member in it
  Exec SQL
    SELECT SCHEMA_NAME into :frmPlb
    From LIBLISTSV
    Join TABLE (QSYS2.PARTITION_STATISTICS(cast(Schema_Name as char(10)), cast('QSRC ' as char(10))) ) on 1=1
    Where Table_Partition = :frmPrt and type='USER'
    Order By Ordinal_Position
    fetch first row only;
  if sqlState >= '02' or frmPlb = '';
    frmPrt = '';
  Else;
    toPrt = %trim(toPgm) + 'PR';
    cpyPrt = 'Y';
    toPlb=toLib;
  EndIf;

  // get the from view name, if it exists set the to prototype name and library
  frmViw = %trim(frmPgm) + 'VW';
  toViw = '';
  cpyViw = 'N';
  toVlb='';
  frmVlb='';
  // Get view from library, it is the first QSRC file in the library list that has member in it
  Exec SQL
    SELECT SCHEMA_NAME into :frmVlb
    From LIBLISTSV
    Join TABLE (QSYS2.PARTITION_STATISTICS(cast(Schema_Name as char(10)), cast('QSRC ' as char(10))) ) on 1=1
    Where Table_Partition = :frmViw and type='USER'
    Order By Ordinal_Position
    fetch first row only;
  if sqlState >= '02' or frmVlb = '';
    frmViw = '';
  Else;
    toViw = %trim(toPgm) + 'VW';
    cpyViw = 'Y';
    toVlb=toLib;
  EndIf;

End-Proc;
