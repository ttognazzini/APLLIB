**Free
Ctl-Opt Option(*SrcStmt) BndDir('APLLIB') DftActGrp(*No) Main(Main) ActGrp(*new);

// CRTDSPF Pre-processor work

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for Template programs
/Copy QSRC,SCRLOCB1PR

// Data structure to read a source line into
Dcl-Ds src Qualified;
  seq zoned(6:2);
  dat zoned(6:0);
  dta Char(80);
  type       Char(1)  overlay(dta:6);
  comment    Char(1)  overlay(dta:7);   // also used for And/Or
  SDA        Char(3)  overlay(dta:7);   // Used to test for SDA comment
  Indicators Char(9)  overlay(dta:8);   // format N01N02N03
  record     Char(1)  overlay(dta:17);
  name       Char(10) overlay(dta:19);
  ref        Char(1)  overlay(dta:29);
  length     Char(1)  overlay(dta:32);
  hidden     Char(1)  overlay(dta:38);
  rowNumber  Char(3)  overlay(dta:39);
  colNumber  Char(3)  overlay(dta:42);
  function   Char(36) overlay(dta:45);
End-Ds;

// data structure to hold information about the current record format
// used while looping through the file
Dcl-Ds record Qualified;
  name Char(10) Inz('');
  beforeDisplay Ind Inz(*on);
  AddHelp Ind Inz(*on);
  SFLName Char(10) Inz('');
  SFLPage packed(4) Inz(0);
  dspMod  Char(4) Inz('');
  sflCtl  Char(10) Inz('');
End-Ds;

// Data structure to read one field into from SCRLOC
Dcl-Ds fldDta;
  fldRow like(APLDCT.fldRow);
  fldCol like(APLDCT.fldCol);
  fldNme like(APLDCT.fldNme);
  fldLen like(APLDCT.fldLen);
End-Ds;

// globals for input parameters
Dcl-S sourceLibrary Char(10);
Dcl-S sourceFile Char(10);
Dcl-S sourceMember Char(10);
Dcl-S pgmNme like(APLDCT.pgmNme);
Dcl-S hlpPnlNme Char(10);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner,
                    CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('HLPMSTB2');
    pmrSourceLibrary Char(10) Options(*nopass);
    pmrSourceFile Char(10) Options(*nopass);
    pmrSourceMember Char(10) Options(*nopass);
  End-Pi;
  Dcl-S sqlStm Varchar(500);
  Dcl-S des like(APLDCT.des);
  Dcl-S inHelpText Ind;
  Dcl-S inHelpTitle Ind;
  Dcl-S inHelpField Ind;

  // If no parameters are passed, use defaults, just for testing
  If %parms=0;
    sourceLibrary='APLLIB';
    sourceFile='QSRC';
    sourceMember='DCTMSTF1';
  Else;
    sourceLibrary=pmrSourceLibrary;
    sourceFile=pmrSourceFile;
    sourceMember=pmrSourceMember;
  EndIf;
  If sourceFile = 'QSRC';
    // If  new program change the FXX to DXX
    pgmNme = %subst(sourceMember:1:6) + 'D' + %subst(sourceMember:8:3);
    hlpPnlNme = %subst(sourceMember:1:6) + 'P' + %subst(sourceMember:8:3);
  Else;
    // if old program remove the FM at the end
    pgmNme = %subst(sourceMember:1:%len(%trim(sourceMember)) - 2);
    hlpPnlNme = %trim(pgmNme) + 'PM';
  EndIf;

  // Make sure the file exists
  If not #$ISMBR(sourceLibrary:sourceFile:sourceMember);
    #$SNDMSG('Error member '+%trim(sourceLibrary)+'/'+%trim(sourceFile)+','+
              %trim(sourceMember) + ' not found.':'*ESCAPE');
    Return;
  EndIf;

  // Refresh the screen locations for cursor positioning, also used for help text fields
  SCRLOCB1(sourceLibrary:sourceFile:sourceMember);

  // Create an Alias To the source member
  Exec SQL Drop Alias QTEMP/INPUT;
  sqlStm='Create or Replace Alias QTEMP/INPUT For ' +
  %trim(sourceLibrary) +'/' + %trim(sourceFile) + '("' +
  %trim(sourceMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // Create temporary source member To build the display file from
  #$SNDMSG('Help Text needed, creating temporary source file QTEMP/QSRC,'+
            %trim(sourceMember)+'.':'*INFO');

  // Create a temporary output member
  #$CMD('CRTSRCPF QTEMP/QSRC':1);
  #$CMD('RMVM QTEMP/QSRC '+%trim(sourceMember):1);
  #$CMD('CPYSRCF '+%trim(sourceLibrary)+'/'+%trim(sourceFile)+
                 ' qtemp/QSRC '+
                 %trim(sourceMember):1);
  #$CMD('CLRPFM QTEMP/QSRC '+%trim(sourceMember):1);

  // Create an Alias To the output member
  Exec SQL Drop Alias QTEMP/OUTPUT;
  sqlStm='Create or Replace Alias QTEMP/OUTPUT For +
  QTEMP/QSRC ("' + %trim(sourceMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // Write out all lines before the first record format, excluding the HLPTITLE
  Exec SQL Declare sqlCrs2 Cursor For Select srcSeq,srcDat,srcDta From QTEMP/INPUT;
  Exec SQL Close SQLCrs2;
  Exec SQL Open SQLCrs2;
  Exec SQL Fetch Next From SQLCRS2 Into :src;
  DoW sqlState<'02';
    If src.comment<>'*' and src.type='A' and src.record='R';
      Leave;
    EndIf;
    // Do not copy SDA comments
    If src.sda = '*%%';
      Exec SQL Fetch Next From SQLCRS2 Into :src;
      Iter;
    EndIf;
    If %subst(src.function:1:9) = 'HLPTITLE(' and #$LAST(src.function:2) <> ')';
      inHelpTitle = *on;
    ElseIf inHelpTitle;
      inHelpTitle = *off;
    ElseIf %subst(src.function:1:9) <> 'HLPTITLE(';
      Exec SQL Insert Into QTEMP/OUTPUT values(:src);
    EndIf;
    Exec SQL Fetch Next From SQLCRS2 Into :src;
  EndDo;

  // write out the help file title
  Exec SQL Select des Into :des From pgmmst Where pgmNme = :pgmNme;
  If des = '';
    des = #$RtvMbrD(sourceLibrary:sourceFile:sourceMember);
  EndIf;
  If %len(%trim(#$DBLQ(des))) > 24;
    AddHeader('HLPTITLE('''+%subst(%trim(#$DBLQ(des)):1:24)+'-');
    AddHeader(%subst(%trim(#$DBLQ(des)):25:%len(%trim(#$DBLQ(des)))-24)+''')');
  Else;
    AddHeader('HLPTITLE('''+%trim(#$DBLQ(des))+''')');
  EndIf;

  // Write out all lines of each record format, insert help variables before the
  // first non-header field, do not add help text on SFL records or Message SFL's
  inHelpText = *off;
  DoW sqlState<'02';
    // Do not copy SDA comments
    If src.sda = '*%%';
      Exec SQL Fetch Next From SQLCRS2 Into :src;
      Iter;
    EndIf;
    // Skip any line between the automated help text comments
    If src.dta = '     A*                                     Start automated help text informatio';
      inHelpText = *on;
    ElseIf src.dta = '     A*                                     End Automated help text information';
      inHelpText = *off;
    ElseIf not inHelpText and (%subst(src.function:1:10) = 'HLPPNLGRP(' or %subst(src.function:1:7) = 'HLPARA(')
        and #$LAST(src.function:2) = ')';
      inHelpField = *off;
    ElseIf not inHelpText and (%subst(src.function:1:10) = 'HLPPNLGRP(' or %subst(src.function:1:7) = 'HLPARA(')
        and #$LAST(src.function:2) <> ')';
      inHelpField = *on;
    ElseIf inHelpField;
      inHelpField = *off;
    ElseIf not inHelpText and not inHelpField;
      If src.comment<>'*' and src.type='A';
        // If the record format name changes, set the record DS to the new one
        If src.record='R';
          NewRecordFormat();
        EndIf;
        // Save of the DSPMOD if it is entered, this has to be used as the indicator on the HLPARA keyword
        If (%subst(src.function:1:6) = 'DSPMOD');
          record.dspMod = %subst(%trim(src.function):8:4);
        EndIf;
        // Save of the SFL record format if this is a SFLCTL record
        If (%subst(src.function:1:6) = 'SFLCTL');
          record.sflCtl = %subst(%trim(src.function):8:%scan(')':src.function)-8);
        EndIf;
        // If this is the first display, hidden, or program field, add help if needed and set beforeDisplay=*off
        If (src.rowNumber<>' ' or src.hidden in %list('H':'P'))
        and record.beforeDisplay and record.AddHelp;
          AddHelp();
          // test if help text is needed and check for SFL
        ElseIf record.beforeDisplay and record.AddHelp;
          TestIfHelpNeeded();
        EndIf;
      EndIf;
      Exec SQL Insert Into QTEMP/OUTPUT values(:src);
    EndIf;
    Exec SQL Fetch Next From SQLCRS2 Into :src;
  EndDo;
  Exec SQL Close SQLCrs2;

  // Drop the Aliases
  Exec SQL Drop Alias QTEMP/INPUT;
  Exec SQL Drop Alias QTEMP/OUTPUT;

End-Proc;


// Add a line with just the a and a passed value in the function section
Dcl-Proc AddHeader;
  Dcl-Pi *n;
    header Char(36) Const;
  End-Pi;
  Dcl-Ds srcDs likeds(src);

  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.function=header;
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

End-Proc;


// Reset the record DS for a new record format
Dcl-Proc NewRecordFormat;
  Reset record;
  record.name=src.name;
End-Proc;


// Get SFL name from function
// Example: getSFLName('SFLCTL(SCREEN)') = 'SCREEN'
Dcl-Proc GetSFLName;
  Dcl-Pi *n Char(10);
    function Char(36) Const;
  End-Pi;
  Dcl-S startPosition int(5);
  Dcl-S endPosition int(5);

  // strip SFL name out of SFLCTL(NAME)
  startPosition=%scan('SFLCTL(':function) +7;
  endPosition=%scan(')':function:startPosition)-1;
  Return %subst(function:startPosition:endPosition-startPosition+1);

End-Proc;


// Get SFL Page from function
// Example: getSFLPage('SFLPAG(0008)') = 8
Dcl-Proc GetSFLPAge;
  Dcl-Pi *n Packed(4);
    function Char(36) Const;
  End-Pi;
  Dcl-S startPosition int(5);
  Dcl-S endPosition int(5);
  Dcl-S returnValue packed(4);

  // strip SFL page out of SFLPAG(0008)
  startPosition = %scan('SFLPAG(':function) +7;
  endPosition = %scan(')':function:startPosition)-1;
  returnValue = #$RVL(%subst(function:startPosition:endPosition-startPosition+1));
  Return returnValue;

End-Proc;


// Add help text for a record
Dcl-Proc AddHelp;
  Dcl-Ds srcDs likeds(src);

  // flag the record as after display so the remaining source lines just get written out
  record.beforeDisplay=*off;

  // Add start of automated help text
  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.comment='*';
  srcDs.function='Start automated help text information';
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

  // add screen header entry
  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.record='H';
  srcDs.function='HLPPNLGRP('+%trim(pgmNme) + ' ' + %trim(hlpPnlNme) + ')';
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.function='HLPARA(01 001 01 001)';
  If record.dspMod <> '';
    srcDs.Indicators = ' *DS3';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    srcDs.Indicators = ' *DS4';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
  Else;
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
  EndIf;


  // Loop through all displayed fields on the screen
  Exec SQL Declare fldCrs Cursor For
    Select
      fldRow,
      fldCol,
      fldNme,
      fldLen
    From SCRLOC
    Where mbr = :sourceMember
      and RcdFmt = :record.name
      and lib = :sourceLibrary
      and fldCol <> 0
    Order by fldRow,fldCol;
  Exec SQL Open fldcrs;
  Exec SQL Fetch Next From fldCrs Into :fldDta;
  DoW sqlState < '02';
    AddHelpField();
    Exec SQL Fetch Next From fldCrs Into :fldDta;
  EndDo;
  Exec SQL Close fldcrs;

  // If this is a SFL control and there are SFL columns that do not have position to fields, they need to be added
  If record.sflCtl <> '';
    Exec SQL Declare sflFldCrs Cursor For
      Select
        SFL.fldRow,
        SFL.fldCol,
        SFL.fldNme,
        SFL.fldLen
      From SCRLOC as SFL
      Exception join SCRLOC as CTL on ctl.mbr = sfl.mbr and ctl.rcdFmt = :record.name
                       and ctl.lib = sfl.lib and ctl.fldCol <> 0
                       and ctl.fldnme = trim(sfl.fldNme) concat '1'
      Where sfl.mbr = :sourceMember
      and sfl.RcdFmt = :record.sflCtl
      and sfl.lib = :sourceLibrary
      and sfl.fldCol <> 0;
    Exec SQL Open sflFldCrs;
    Exec SQL Fetch Next From sflFldCrs Into :fldDta;
    DoW sqlState < '02';
      AddSFLHelpField();
      Exec SQL Fetch Next From sflFldCrs Into :fldDta;
    EndDo;
    Exec SQL Close sflFldcrs;
  EndIf;

  // Add end of automated help text
  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.comment='*';
  srcDs.function='End Automated help text information';
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

End-Proc;


// Add one help field to the record
Dcl-Proc AddHelpField;
  Dcl-Ds srcDs likeds(src);
  Dcl-S tpFldNme like(APLDCT.fldNme);
  Dcl-S t2FldNme like(APLDCT.fldNme);
  Dcl-S begRow packed(2);
  Dcl-S endRow packed(2);
  Dcl-S begCol packed(3);
  Dcl-S endCol packed(3);
  Dcl-S isPositionTo Ind;

  // if a position to field, strip the 1 off
  tpFldNme = fldNme;
  Clear isPositionTo;
  If record.SFLName<>'' and #$LAST(fldNme:1) = '1';
    Exec SQL
      Select '1' into :isPositionTo
      from SCRLOC
      Where mbr = :sourceMember
        and RcdFmt = :record.SFLName
        and lib = :sourceLibrary
        and fldNme = substr(:fldNme,1,length(trim(:fldNme)) - 1);
    If isPositionTo;
      tpFldNme = %subst(fldnme:1:%len(%trimr(fldNme))-1);
    EndIf;
  EndIf;

  // Add help specification line
  If tpFldNme = 'SEL';
    tpFldNme='OPTIONS';
  EndIf;

  // Translate some characters that are invalid in help group names
  t2FldNme = %xlate('#':'_':tpFldNme);
  t2FldNme = %xlate('@':'_':t2FldNme);
  t2FldNme = %xlate('$':'/':t2FldNme);

  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.record='H';
  srcDs.function='HLPPNLGRP('''+%trim(t2FldNme) + ''' ' + %trim(hlpPnlNme) + ')';
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

  // if this is a position to field, add a range that covers the SFL
  If isPositionTo;
    begRow = fldRow;
    begCol = fldCol;
    endRow = fldRow + record.SFLPage;
    endCol = fldCol + fldLen - 1;
    // if a SFL has multiple entries per row the endCol can be set after the end of the screen, this causes
    // the dspf compiltion to blow. A  temporary fix this code just uses the screen size to set the end column
    // 2 lines before the end of the screen if it is passed the end of the screen.
    If record.dspMod = '*DS4' and endRow>27;
      endRow = 25;
    ElseIf record.dspMod <> '*DS4' and endRow>24;
      endRow = 22;
    EndIf;
    Clear srcDs;
    src.seq+=.01;
    srcDs.seq=src.seq;
    srcDs.type='A';
    srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                       ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
    If record.dspMod <> '';
      srcDs.Indicators = ' *DS4';
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
      // if the field is outside 80 characters on a 132 column display in a duel size format, the *DS3
      // entry must be with in 80 columns, if the row is past 24 set it to 24
      If record.dspMod = '*DS4' and (fldCol + fldLen - 1 > 80 or fldRow > 24);
        If FldRow > 24;
          begRow = 24;
          endRow = 24;
        Else;
          begRow = fldRow;
          endRow = fldRow;
        EndIf;
        If fldCol + fldLen - 1 > 80;
          begCol = 80;
          endCol = 80;
        EndIf;
        srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                           ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
      EndIf;
      srcDs.Indicators = ' *DS3';
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    Else;
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    EndIf;
    // If the field is in a duel size display file and this is a 132 column screen and the
    // field goes outside of 80 columns, then the field cannot be referecned by name becasue it
    // will blow up in compliation. The field must be referenced by location for the *DS4 entry,
    // and then by a valid location for the *DS3 entry, the *DS3 entry must be with in 80 columns
  ElseIf record.dspMod = '*DS4' and (fldCol + fldLen - 1 > 80 or fldRow > 24);
    begRow = fldRow;
    begCol = fldCol;
    endRow = fldRow;
    endCol = fldCol + fldLen - 1;
    Clear srcDs;
    src.seq+=.01;
    srcDs.seq=src.seq;
    srcDs.type='A';
    srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                       ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
    srcDs.Indicators = ' *DS4';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    If FldRow > 24;
      begRow = 24;
      endRow = 24;
    EndIf;
    If fldCol + fldLen - 1 > 80;
      begCol = 80;
      endCol = 80;
    EndIf;
    srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                       ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
    srcDs.Indicators = ' *DS3';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

    // Otherwise just a field reference
  Else;
    Clear srcDs;
    src.seq+=.01;
    srcDs.seq=src.seq;
    srcDs.type='A';
    srcDs.Indicators = ' ' + record.dspMod;
    srcDs.function='HLPARA(*FLD '+%trim(tpFldNme)+')';
    If record.dspMod <> '';
      srcDs.Indicators = ' *DS3';
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
      srcDs.Indicators = ' *DS4';
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    Else;
      Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    EndIf;
  EndIf;

End-Proc;


// Add one SFL help field to the record
// These are only SFL fields that do not have a position to field, position to fields already
// include the range for the SFL.
Dcl-Proc AddSFLHelpField;
  Dcl-Ds srcDs likeds(src);
  Dcl-S tpFldNme like(APLDCT.fldNme);
  Dcl-S t2FldNme like(APLDCT.fldNme);
  Dcl-S begRow packed(2);
  Dcl-S endRow packed(2);
  Dcl-S begCol packed(3);
  Dcl-S endCol packed(3);

  // Add help specification line
  tpFldNme = fldNme;
  If tpFldNme = 'SEL';
    tpFldNme='OPTIONS';
  EndIf;

  // Translate some characters that are invalid in help group names
  t2FldNme = %xlate('#':'_':tpFldNme);
  t2FldNme = %xlate('@':'_':t2FldNme);
  t2FldNme = %xlate('$':'/':t2FldNme);

  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.record='H';
  srcDs.function='HLPPNLGRP('''+%trim(t2FldNme) + ''' ' + %trim(hlpPnlNme) + ')';
  Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);

  // Calcualte renage for SFL field
  begRow = fldRow;
  begCol = fldCol;
  endRow = fldRow + record.SFLPage;
  endCol = fldCol + fldLen - 1;

  // if a SFL has multiple entries per row the endCol can be set after the end of the screen, this causes
  // the dspf compiltion to blow. A  temporary fix this code just uses the screen size to set the end column
  // 2 lines before the end of the screen if it is passed the end of the screen.
  If record.dspMod = '*DS4' and endRow>27;
    endRow = 25;
  ElseIf record.dspMod <> '*DS4' and endRow>24;
    endRow = 22;
  EndIf;

  Clear srcDs;
  src.seq+=.01;
  srcDs.seq=src.seq;
  srcDs.type='A';
  srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                     ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
  If record.dspMod <> '';
    srcDs.Indicators = ' *DS4';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
    // if the field is outside 80 characters on a 132 column display in a duel size format, the *DS3
    // entry must be with in 80 columns, if the row is past 24 set it to 24
    If record.dspMod = '*DS4' and (fldCol + fldLen - 1 > 80 or fldRow > 24);
      If FldRow > 24;
        begRow = 24;
        endRow = 24;
      Else;
        begRow = fldRow;
        endRow = fldRow;
      EndIf;
      If fldCol + fldLen - 1 > 80;
        begCol = 80;
        endCol = 80;
      EndIf;
      srcDs.function='HLPARA('+%editc(begRow:'X') + ' ' + %editc(begCol:'X') +
                         ' ' + %editc(endRow:'X') + ' ' + %editc(endCol:'X') + ')';
    EndIf;
    srcDs.Indicators = ' *DS3';
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
  Else;
    Exec SQL Insert Into QTEMP/OUTPUT values(:srcDs);
  EndIf;

End-Proc;


// See if help text is needed for this record format.
// Help text is needed by default, if the record contains a SFL or SFLPGMQ
// record help text is not needed so the flag is turned off.
// Also save the name of the SFL if a SFLCTL option exists.
Dcl-Proc TestIfHelpNeeded;

  // Save SFL record name if this is a SFL control record
  If %scan('SFLCTL':#$UPIFY(src.function))<>0;
    record.SFLName=GetSFLName(src.function);
  EndIf;

  // Save SFLPAG value if this is a SFL control record
  If %scan('SFLPAG':#$UPIFY(src.function))<>0;
    record.SFLPage=GetSFLPAge(src.function);
  EndIf;

  // if the record format is a SFL or message SFL do not include help text
  If %scan('SFL ':#$UPIFY(src.function))<>0 or
     %scan('SFLPGMQ':#$UPIFY(src.function))<>0;
    record.AddHelp=*off;
  EndIf;

End-Proc;
