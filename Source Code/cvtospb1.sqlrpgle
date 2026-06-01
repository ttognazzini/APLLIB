**Free
Ctl-Opt option(*srcStmt:*nodebugio:*nounref) dftactgrp(*no) BndDir('APLLIB') Main(Main);
// CVTOSPECS Command - Generate external print file from RPGLE Ospecs

// Shamelessly borrowed from Craig Rutledge, www.jcrcmds.com, see JCRPRTF
// TRT - Started converting to APLLIB coding conventions, but ran out of time.

// Suggested PDM shortcut CP = ?APLLIB/CVTOSPEC RPGMBR(&N) RPGSRCFIL(&L/&F) PRTFSRCFIL(&L/QDDSSRC)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Used to store fields from the printed program compile
Dcl-S FieldsArryCnt uns(10);
Dcl-Ds FieldsArry dim(5000) qualified;
  Name char(100);
  Attr like(FieldsAttrDS);
End-Ds;
Dcl-Ds FieldsAttrDS qualified inz;
  Length uns(10);
  DecimalPos char(2);
  DecimalPosN zoned(2) overlay(DecimalPos);
  DataType char(1);
  FromFile char(10);
  Text char(25);
End-Ds;

Dcl-Ds SrcDS Len(112)qualified inz;
  CompileArray char(3) pos(13);
  SpecType char(1) pos(18);
  Asterisk char(1) pos(19);
  Commentln char(73) pos(20);
  oAndOr char(4) pos(28);
  oLineType char(1) pos(29);
  oIndicator char(9) pos(33);
  oSpaceB char(1) pos(54);
  oSpaceA char(1) pos(57);
  oSkipB char(2) pos(59);
  oSkipA char(2) pos(62);
  oEname char(14) pos(42);
  oEditCode char(1) pos(56);
  oEndPos char(5) pos(59);
  oEndPosN zoned(5) pos(59);
  oConstant char(28) pos(65);
  UpperCase char(51) pos(13);
End-Ds;

Dcl-Ds OutDS qualified inz;
  SrcSeq zoned(6:2) pos(1) inz(0);
  SrcType char(1) pos(18);
  oAndOr char(1) pos(19);
  CommentLine char(73) pos(20);
  Indicator char(9) pos(20);
  FormatR char(1) pos(29);
  FormatName char(10) pos(31);
  Referenced char(1) pos(41);
  Length char(4) pos(43);
  DataType char(1) pos(47);
  DecimalPos char(1) pos(49);
  LinePosition char(3) pos(54);
  Keyword char(36) pos(57);
End-Ds;

Dcl-Ds inputDS len(132);
  iNotReferenced char(1) pos(1);
  iCheckComplete char(20) pos(1);
  iCheckCompleteSql char(20) pos(4);
  iMsgSummary char(7) pos(2);
  iEqual char(1) pos(7);
  iGlobalRef char(24) pos(7);
  iFileType char(1) pos(8);
  iExternalForma char(30) pos(9);
  iDFieldName char(10) pos(10);
  iFldShort char(17) pos(10);
  iFldLong char(123) pos(10);
  iOFieldName char(10) pos(32);
  iGlobAttr1 char(1) pos(28);
  iGlobAttr3 char(3) pos(27);
  iGlobLen char(17) pos(29);
  iFSname char(92) pos(41);
  iReference char(31) pos(50);
  iIFieldName char(15) pos(51);
  iDiagSeverity char(2) pos(31);
  iDiagSeveritySql char(2) pos(1);
  iFieldText char(39) pos(83);
  iFileSeq char(3) pos(122);
End-Ds;

Dcl-S DiagSeverity char(2);
Dcl-S aa uns(5);
Dcl-S bb uns(5);
Dcl-S KeywordSkipa like(OutDS.Keyword);
Dcl-S KeywordSkipb like(OutDS.Keyword);
Dcl-S KeywordSpacea like(OutDS.Keyword);
Dcl-S KeywordSpaceb like(OutDS.Keyword);
Dcl-S LinePosSav like(OutDS.LinePosition);
Dcl-S oooFMT like(SrcDS.oConstant);
Dcl-S Commas char(1);
Dcl-S DDsSrcFile char(10);
Dcl-S DDsSrcLib char(10);
Dcl-S EditCodeArry char(1) dim(16) ctdata perrcd(1);
Dcl-S EditDataArry char(2) dim(16) alt(EditCodeArry);
Dcl-S Field char(15);
Dcl-S FloatDollar char(3) inz('''$''');
Dcl-S HaveFields char(27);
Dcl-S JustDidFmt char(27);
Dcl-S LastExceptName char(15);
Dcl-S LookupName char(15);
Dcl-S NegativeType char(1);
Dcl-S RpgSrcFile char(10);
Dcl-S RpgSrcLib char(10);
Dcl-S DimSizeA char(5);
Dcl-S WriteLine char(1);
Dcl-S vspos int(5);
Dcl-S vswork int(5);
Dcl-S DecimalPos zoned(1);
Dcl-S CommaRemainder uns(5);
Dcl-S CommaResult uns(5);
Dcl-S DetailLineCnt uns(5);
Dcl-S ExceptLineCnt uns(5);
Dcl-S HeaderLineCnt uns(5);
Dcl-S jj uns(5);
Dcl-S kk uns(5);
Dcl-S LenActual uns(5);
Dcl-S NewEndingPos uns(5);
Dcl-S pe uns(5);
Dcl-S ps uns(5);
Dcl-S pStart uns(5);
Dcl-S TotalLineCnt uns(5);
Dcl-S xd uns(5);
Dcl-S xx uns(5);
Dcl-S yy uns(5);
Dcl-S IsWrite ind;
Dcl-S PepCnt packed(3);
Dcl-S LineCount packed(6: 2) inz(0);
Dcl-S readcount uns(10);
Dcl-S ii uns(10);
Dcl-S xOpen uns(3);
Dcl-S xComma uns(3);
Dcl-S xAster uns(3);
Dcl-S xClose uns(3);
Dcl-S FileNameArry char(10) dim(12767);
Dcl-S FileFldsArry char(15) dim(12767);
Dcl-S FileFldTxtArry dim(12767) like(ifieldtext);
Dcl-S FileName char(10);
Dcl-S FileSeq char(3);
Dcl-S IsGlobalRef ind inz(*off);
Dcl-S SavName char(100);
Dcl-S SavProcName char(100);
Dcl-S SavQualified char(100);
Dcl-S SavDim char(15);
Dcl-S IsUnReferenced ind;
Dcl-S IsQualified ind;
Dcl-S IsLookForSeverity ind;
Dcl-S IsServicePgm ind;
Dcl-S char8 char(8);


// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('CVTOSPB1');
    p_DDsMbr char(10);
    p_DDsFileQual char(20);
    p_RpgMbr char(10);
    p_RpgFileQual char(20);
    p_RefFields char(4);
  End-Pi;
  Dcl-S ExtIfile varchar(21);
  Dcl-S ExtOFile varchar(21);
  Dcl-F RPGSRC disk(112) extfile(extifile) extmbr(p_rpgmbr) usropn;
  Dcl-F DDSSRC disk(92) usage(*output) extfile(extofile) extmbr(p_ddsmbr) usropn;


  RpgSrcFile = %subst(p_RpgFileQual: 1: 10);
  RpgSrcLib = %subst(p_RpgFileQual: 11: 10);
  DDsSrcFile = %subst(p_DDsFileQual: 1: 10);
  DDsSrcLib = %subst(p_DDsFileQual: 11: 10);
  extIfile = %trimr(%subst(p_RpgFileQual: 11: 10)) + '/' +
        %trimr(%subst(p_RpgFileQual: 1: 10));
  extOfile = %trimr(%subst(p_DDsFileQual: 11: 10)) + '/' +
        %trimr(%subst(p_DDsFileQual: 1: 10));

  // Get program field attributes
  // Load clipboard array with field names and attributes
  getFieldDef(p_RpgFileQual:p_RpgMbr:DiagSeverity:PepCnt);
  If DiagSeverity > '20';
    Snd-Msg *escape '*ERROR*  Diagnostic severity ' + DiagSeverity + '. Please check listing for errors.';
  EndIf;

  // open input file and output
  Open RPGSRC;
  Open DDSSRC;
  Read RPGSRC SrcDS;
  DoW not %eof;

    If SrcDS.CompileArray in %list('** ':'**C':'**c') // Compile time array
    or SrcDS.SpecType in %list('P':'p');              // procedure
      Leave;
    EndIf;

    If    SrcDS.Asterisk <> '/'     // Eject
      and SrcDS.SpecType in %list('O':'o');

      // If comment lines, then translate over as is
      If SrcDS.Asterisk = '*';  // Comment line
        OutDS.oAndOr = SrcDS.Asterisk;  // Load ds
        OutDS.CommentLine = SrcDS.Commentln;  // Load ds
        ExSr srWriteSrcCode;
      Else;
        SrcDS.UpperCase = %upper(SrcDS.UpperCase);
        If SrcDS.oLineType > *blanks   and //IPO LINES D,E,H
                   SrcDS.oAndOr <> 'OR'  and     //IPO LINES D,E,H
                   SrcDS.oAndOr <> 'AND';  //IPO LINES D,E,H
          ExSr srFormatLine;
        Else;  //FIELD/LITERAL
          ExSr srFieldLine;
        EndIf;
      EndIf;
    EndIf;

    *in01 = *off;
    *in03 = *off;
    Read RPGSRC SrcDS;
  EndDo;
  // all processed
  ExSr srSpaceAfter;
  Close RPGSRC;
  Close DDSSRC;
  Snd-Msg 'CVTOSPEC for ' + %trimr(p_DDsMbr) + ' in ' + %trimr(extOfile) + ' - completed.';
  *inlr = *on;
  Return;

  // Generate record format code for either except lines
  // or when new line is coded in original RPG.
  BegSr srFormatLine;
    IsWrite = *on;

    // If previous record format had no printable fields
    // or constants defined, then generate space/skip
    // BEFORE code at record format level.
    If HaveFields = 'Record Format had no fields';
      ExSr srSpaceBefore;
    EndIf;
    ExSr srSpaceAfter;

    If SrcDS.oLineType = 'E';  //EXCPT
      If SrcDS.oEname > *blanks
             and SrcDS.oEname = LastExceptName;  //SAME NAMED LINE
        IsWrite = *off;
      Else;
        If SrcDS.oEname = *blanks;
          ExceptLineCnt += 1;
          SrcDS.oEname = %trimr('EXP') +
                %triml(%editc(ExceptLineCnt:'3'));
        EndIf;

        OutDS.FormatName = SrcDS.oEname;
        LastExceptName = SrcDS.oEname;
      EndIf;

    ElseIf SrcDS.oLineType = 'H';  //HEADER LINE
      HeaderLineCnt += 1;  //HEADER LINE CNT
      OutDS.FormatName = %trimr('HDR') +
          %triml(%editc(HeaderLineCnt:'3'));
      LastExceptName = *blanks;

    ElseIf SrcDS.oLineType = 'D';  //DETAIL
      DetailLineCnt += 1;
      OutDS.FormatName = %trimr('DTL') +
          %triml(%editc(DetailLineCnt:'3'));
      LastExceptName = *blanks;

    ElseIf SrcDS.oLineType = 'T';  //TOTAL
      TotalLineCnt += 1;
      OutDS.FormatName = %trimr('TOT') +
          %triml(%editc(TotalLineCnt:'3'));
      LastExceptName = *blanks;
    EndIf;

    If IsWrite;
      OutDS.FormatR = 'R';
      ExSr srWriteSrcCode;
    EndIf;

    // Space or Skip before must after first field
    // (or constant) defined after record format record.
    // They are saved for after first field in rcdfmt.
    If SrcDS.oSpaceB > ' ';  //SPACE BEFORE
      KeywordSpaceb = %trimr('SPACEB(') + SrcDS.oSpaceB+')';
    EndIf;
    If SrcDS.oSkipB > ' ';  //SKIP BEFORE
      KeywordSkipb = %trimr('SKIPB(') + SrcDS.oSkipB + ')';
    EndIf;

    // Space or Skip after must go at end of each group.
    // Checked at beginning of each record format.
    If SrcDS.oSpaceA > ' ';  //SPACE AFTER
      KeywordSpacea = %trimr('SPACEA(') + SrcDS.oSpaceA+')';
    EndIf;

    If SrcDS.oSkipA > ' ';  //SKIP AFTER
      KeywordSkipa = %trimr('SKIPA(') + SrcDS.oSkipA+')';
    EndIf;

    vspos = 0;
    HaveFields = 'Record Format had no fields';
    JustDidFmt = 'Just did record format';
  EndSr;

  // Generate Skip or Space before DDs code
  BegSr srSpaceBefore;
    If KeywordSpaceb > *blanks;  //SPACE BEFORE
      OutDS.Keyword = KeywordSpaceb;
      ExSr srWriteSrcCode;
    EndIf;

    If KeywordSkipb > *blanks;  //SKIP BEFORE
      OutDS.Keyword = KeywordSkipb;
      ExSr srWriteSrcCode;
    EndIf;

    KeywordSpaceb = *blanks;
    KeywordSkipb = *blanks;
  EndSr;

  // Generate Skip or Space after DDs code
  BegSr srSpaceAfter;
    If KeywordSpacea > *blanks;  //SPACE AFTER
      OutDS.Keyword = KeywordSpacea;
      ExSr srWriteSrcCode;
    EndIf;

    If KeywordSkipa > *blanks;  //SKIP AFTER
      OutDS.Keyword = KeywordSkipa;
      ExSr srWriteSrcCode;
    EndIf;

    KeywordSpacea = *blanks;
    KeywordSkipa = *blanks;
  EndSr;

  // Determine whether field name or constant is to be loaded
  BegSr srFieldLine;  //IPP SPECS
    LenActual = 0;
    HaveFields = 'Record Format has fields';

    If SrcDS.oEname > *blanks;  //FIELD NAMES
      WriteLine = 'N';  //SET TO NO

      Field = SrcDS.oEname;

      // There could be indexed array name as output field.
      // Do lookup with array name to get attributes
      LookupName = SrcDS.oEname;
      aa = %scan('(': LookupName: 1);
      If aa <> 0;
        LookupName = %subst(LookupName: 1: aa - 1);
      EndIf;
      aa = %lookup(LookupName: FieldsArry(*).Name: 1: FieldsArryCnt);
      If aa > 0;
        FieldsAttrDS = FieldsArry(aa).Attr;
        If FieldsAttrDS.DecimalPos = *blanks;
          DecimalPos = 0;
        Else;
          DecimalPos = FieldsAttrDS.DecimalPosN;
        EndIf;
        OutDS.FormatName = SrcDS.oEname;

        // Back to array fun!  It could be that
        // that un-indexed array name was on a O spec.
        // JCRGETFLDR program loads array definitions
        // in two parts.  Multiply element length by num elements.
        ps = %scan('DIM(': FieldsAttrDS.Text: 1);
        If ps <> 0                    //start of DIM(
                and LookupName = SrcDS.oEname;  //not indexed
          pe = %scan(')': FieldsAttrDS.Text: ps);

          If pe <> 0;  //end of )
            xd = (pe - 1) - 4;
            pStart = 6 - xd;
            DimSizeA = *blanks;
            %subst(dimsizea: pStart: xd) =
                   %subst(FieldsAttrDS.Text: 5: xd);
            If DimSizeA = *blanks;
              DimSizeA = '00000';
            EndIf;
            FieldsAttrDS.Length = FieldsAttrDS.Length * %uns(DimSizeA);
          EndIf;
        EndIf;
        OutDS.Indicator = SrcDS.oIndicator;

        // If field was defined via external file definition and
        // user specified that field references are to be used,
        // use REFFLD keyword, otherwise hardcode actual field attributes.
        If FieldsAttrDS.FromFile <> ' ' and  //INTERNALLY DESC
                p_RefFields = '*YES';  //USE REFERENCES
          OutDS.Referenced = 'R';

          OutDS.Keyword = 'REFFLD(' + %trimr(OutDS.FormatName) +
                ' *LIBL/' + %trimr(FieldsAttrDS.FromFile) + ')';
        Else;
          // Hard code fields that are not referenced
          If FieldsAttrDS.DataType = 'A';
            evalr OutDS.Length = %editc(FieldsAttrDS.Length:'4');
            Clear OutDS.DataType;
            Clear OutDS.DecimalPos;

          ElseIf FieldsAttrDS.DataType = 'D'
                   or FieldsAttrDS.DataType = 'T'
                   or FieldsAttrDS.DataType = 'Z';
            Clear OutDS.Length;
            If FieldsAttrDS.DataType = 'D';
              OutDS.DataType = 'L';
            Else;
              OutDS.DataType = FieldsAttrDS.DataType;
            EndIf;
            Clear OutDS.DecimalPos;
          Else;
            evalr OutDS.Length = %editc(FieldsAttrDS.Length:'4');
            Clear OutDS.DataType;
            OutDS.DecimalPos = %editc(DecimalPos:'3');
          EndIf;
          WriteLine = 'Y';
        EndIf;
      EndIf;

      // Calculate starting Position of either field or constant
      LenActual = FieldsAttrDS.Length;
      If SrcDS.oEditCode > ' ';
        ExSr srAllowForEditCode;
      ElseIf SrcDS.oConstant > *blanks;  //GET CONST LENGT
        If FieldsAttrDS.DataType = 'D'
                or FieldsAttrDS.DataType = 'T'
                or FieldsAttrDS.DataType = 'Z';
          ExSr srMakeLikeAnEditWord;
        EndIf;

        kk = %checkr(' ': SrcDS.oConstant);
        LenActual = kk - 2;  //CALC LENGTH
      EndIf;
      ExSr srBlankOrPlusSign;
      vswork = vswork - LenActual;
      vswork += 1;
      evalr OutDS.LinePosition = %editc(vswork:'4');

      // Handle exception of UDATE.  Entire line is cleared and
      // starting Position and new DATE keyword are written.
      If OutDS.FormatName = 'UDATE';
        LinePosSav = OutDS.LinePosition;
        WriteLine = 'N';
        Clear OutDS;
        OutDS.LinePosition = LinePosSav;
        OutDS.Keyword = 'DATE';
      EndIf;

      If WriteLine <> 'Y';
        ExSr srWriteSrcCode;
      EndIf;

      // If floating dollar sign, include in EDTCDE keyword)
      If SrcDS.oEditCode > ' ';
        OutDS.Keyword = 'EDTCDE(' + SrcDS.oEditCode + ')';
        If SrcDS.oConstant = FloatDollar;
          OutDS.Keyword = 'EDTCDE(' + SrcDS.oEditCode + ' $)';
        EndIf;
        ExSr srWriteSrcCode;
        Clear WriteLine;

      ElseIf SrcDS.oConstant > *blanks;  //EDTWRD SPECIFID
        If FieldsAttrDS.DataType = 'D'
                or FieldsAttrDS.DataType = 'T'
                or FieldsAttrDS.DataType = 'Z';
          OutDS.Keyword = oooFMT;
        Else;
          OutDS.Keyword = 'EDTWRD(' + %trimr(SrcDS.oConstant) + ')';
        EndIf;
        ExSr srWriteSrcCode;
        Clear WriteLine;
      EndIf;

      If WriteLine = 'Y';
        ExSr srWriteSrcCode;
      EndIf;

    ElseIf SrcDS.oConstant > *blanks;  //CONSTANTS
      jj = %checkr(' ': SrcDS.oConstant);
      OutDS.Indicator = SrcDS.oIndicator;
      ExSr srBlankOrPlusSign;
      vswork -= jj;
      vswork += 3;
      evalr OutDS.LinePosition = %editc(vswork:'4');  //LOAD FLD LENGTH
      OutDS.Keyword = SrcDS.oConstant;  //LOAD CONSTANT
      ExSr srWriteSrcCode;
    EndIf;

    If JustDidFmt = 'Just did record format';
      ExSr srSpaceBefore;
      JustDidFmt = 'Not';
    EndIf;
  EndSr;

  // If ending Position is blank, load +0 and let
  // the calc ending subroutine handle it.  If there
  //  is + sign in end position, then calc ending pos.
  BegSr srBlankOrPlusSign;
    If SrcDS.oEndPos = *blanks;
      SrcDS.oEndPos = '   +0';
    EndIf;
    bb = %scan('+': SrcDS.oEndPos: 1);
    If bb <> 0;

      // load zeros into any spaces between + and value, ie +   1 = +0001
      For yy = bb to 5;
        If %subst(SrcDS.oEndPos: yy: 1) = ' ';
          %subst(SrcDS.oEndPos: yy: 1) = '0';
        EndIf;
      EndFor;

      // Calculate ending positions
      yy = 2;
      xx = 0;
      If SrcDS.oEname <> ' '
             and %subst(SrcDS.oConstant: 1: 1) <> ' '
             and SrcDS.oConstant <> FloatDollar;
        DoW %subst(SrcDS.oConstant: yy: 1) <> '''';
          xx += 1;
          yy += 1;
        EndDo;

      ElseIf SrcDS.oEname = ' '
             and %subst(SrcDS.oConstant: 1: 1) <> ' ';
        DoW yy < 29
                and %subst(SrcDS.oConstant: yy: 1) <> '''';
          xx += 1;
          yy += 1;
        EndDo;
      EndIf;
      NewEndingPos = vspos + %uns(%subst(SrcDS.oEndPos: bb + 1)) + xx;

      If xx = 0;  //no edit word
        NewEndingPos += LenActual;
      EndIf;
      SrcDS.oEndPosN = NewEndingPos;
    EndIf;

    vspos = SrcDS.oEndPosN;
    vswork = vspos;
  EndSr;

  // New to O specs is ability to format date, time and and timestamp fields.
  // Build an edit word based on type field and formatting settings.
  BegSr srMakeLikeAnEditWord;
    Clear oooFMT;
    If FieldsAttrDS.DataType = 'Z';
    Else;
      SrcDS.oConstant = %upper(SrcDS.oConstant);

      If FieldsAttrDS.DataType = 'T';
        oooFMT = 'TIMFMT(' + %trimr(SrcDS.oConstant) + ')';

      ElseIf FieldsAttrDS.DataType = 'D';
        oooFMT = 'DATFMT(' + %trimr(SrcDS.oConstant) + ')';
      EndIf;
    EndIf;
    SrcDS.oConstant =
       f_BuildEditWord(SrcDS.oConstant: FieldsAttrDS.DataType);
  EndSr;

  // Allow for effects of edit codes on overall field length
  BegSr srAllowForEditCode;
    If SrcDS.oEditCode = 'Y';
      If FieldsAttrDS.Length = 3
             or FieldsAttrDS.Length = 4;
        LenActual += 1;
      ElseIf FieldsAttrDS.Length >= 5
             and FieldsAttrDS.Length <= 9;
        LenActual += 2;
      EndIf;
    Else;
      jj = %lookup(SrcDS.oEditCode: EditCodeArry: 1);
      If jj > 0;
        Commas = %subst(EditDataArry(jj): 1: 1);  //USE COMMAS?
        NegativeType = %subst(EditDataArry(jj): 2: 1);  //WHAT TYPE NEG

        If SrcDS.oConstant = FloatDollar;  //FLOATING $
          LenActual += 1;
        EndIf;

        If DecimalPos > 0;  //ADJUST FOR DEC
          LenActual += 1;
        EndIf;

        If NegativeType = '-';  //MINUS SIGN
          LenActual += 1;
        ElseIf NegativeType = 'C';  //CR SIGN
          LenActual += 2;
        EndIf;

        If Commas = 'Y';  //ALLOW FOR COMMA
          CommaResult = FieldsAttrDS.Length - DecimalPos;
          CommaResult = %div(CommaResult: 3);  //HOW MANY COMMAS
          CommaRemainder = %rem(CommaResult: 3);  //HOW MANY COMMAS

          If CommaRemainder = 0 and CommaResult > 0;  //EVENLY DIVIDED
            CommaResult -= 1;
          EndIf;
          LenActual += CommaResult;
        EndIf;
      EndIf;
    EndIf;
  EndSr;

  // Write records to DDS member
  BegSr srWriteSrcCode;
    OutDS.SrcType = 'A';
    linecount += .01;
    OutDS.SrcSeq = linecount;
    Write ddssrc OutDS;
    Clear OutDS;
  EndSr;

End-Proc;


// return edit for date/time format printing
Dcl-Proc f_BuildEditWord;
  Dcl-Pi *n char(28);
    p_String char(28) const;
    p_DateType char(1) const;
  End-Pi;

  Dcl-S string varchar(28);

  If p_DateType = 'Z';
    Return '''    -  -  -  .  .  .      ''';

  ElseIf p_DateType = 'T';
    string = %upper(p_String);

    If string = 'TIMFMT(*USA)'
              or string = '*USA';
      Return '''  .   XM''';

    ElseIf string = 'TIMFMT(*HMS)'
              or string = 'TIMFMT(*JIS)'
              or string = '*HMS'
              or string = '*JIS';
      Return '''  :  :  ''';

    ElseIf string = 'TIMFMT(*ISO)'
              or string = 'TIMFMT(*EUR)'
              or string = '*ISO'
              or string = '*EUR';
      Return '''  .  .  ''';
    Else;
      Return '''  :  :  ''';
    EndIf;

  ElseIf p_DateType = 'L'
           or p_DateType = 'D';
    string = %upper(p_String);

    If string = 'DATFMT(*MDY)'
              or string = 'DATFMT(*YMD)'
              or string = 'DATFMT(*DMY)'
              or string = '*MDY'
              or string = '*YMD'
              or string = '*DMY';
      Return '''  /  /  ''';

    ElseIf string = 'DATFMT(*JUL)'
              or string = '*JUL';
      Return '''  /    ''';

    ElseIf string = 'DATFMT(*ISO)'
              or string = 'DATFMT(*JIS)'
              or string = '*ISO'
              or string = '*JIS';
      Return '''    -  -  ''';

    ElseIf string = 'DATFMT(*USA)'
              or string = '*USA'
              or string = '    ';
      Return '''  /  /    ''';

    ElseIf string = 'DATFMT(*EUR)'
              or string = '*EUR';
      Return '''  .  .    ''';

      // if no hit return *ISO Default
    Else;
      Return '''    -  -  ''';
    EndIf;
  EndIf;
  Return p_String;
End-Proc;


// load EXPORT array with field name and attributes
//  Generate diagnostic source listing
//   Read spooled file
//    Load clipboard array with field names and attributes
Dcl-Proc getFieldDef;
  Dcl-Pi *n;
    p_SrcFilQual char(20);
    p_SrcMbr char(10);
    p_DiagSeverity char(2);
    p_PepCnt packed(3);
  End-Pi;
  Dcl-F CVTOSP disk(132) usropn;
  Dcl-S srcFle varchar(10);
  Dcl-S srcLib varchar(10);
  Dcl-S srcMbr varchar(10);
  srcFle = %trim(%subst(p_srcFilQual:1:10));
  srcLib = %trim(%subst(p_srcFilQual:11:10));
  srcMbr = %trim(p_srcMbr);
  p_PepCnt = 0;

  // generate diagnostic listing and copy to data file
  p_DiagSeverity = '00';
  If #$IsObj('CVTOSP':'*FILE':'QTEMP');
    #$Cmd('CLRPFM QTEMP/CVTOSP');
  Else;
    #$Cmd('CRTPF FILE(QTEMP/CVTOSP) RCDLEN(132) SIZE(*NOMAX)');
  EndIf;

  #$CMD('OVRPRTF FILE(' + srcMbr + ') HOLD(*YES)');

  If #$RtvMbrTyp(srcLib:srcFle:srcMbr) = 'SQLRPGLE';
    #$Cmd('CRTSQLRPGI OBJ(QTEMP/' + srcMbr + ') +
                      SRCFILE('+ srcLib +'/' + srcFle +') +
                      OPTION(*NOXREF *GEN) +
                      OUTPUT(*PRINT) +
                      COMPILEOPT(''DFTACTGRP(*NO)'')':2);
  Else;
    // weird. the compiler list will not show the pep unless *GEN the program
    #$Cmd('CRTBNDRPG PGM(QTEMP/' + srcMbr + ') +
                     SRCFILE('+ srcLib +'/' + srcFle +') +
                     OPTION(*XREF *NOSECLVL *SHOWCPY *EXPDDS +
                     *NOEXT *NOSHOWSKP *NOSRCSTMT *NOEVENTF) DFTACTGRP(*NO)');
  EndIf;

  #$Cmd('CPYSPLF FILE(' + srcMbr +') TOFILE(QTEMP/CVTOSP) SPLNBR(*LAST)');
  #$Cmd('DLTOVR FILE(' + srcMbr + ')');
  #$Cmd('DLTPGM PGM(QTEMP/' + SrcMbr+')');

  // read listing
  Open CVTOSP;
  Read CVTOSP inputDS;
  readCount += 1;
  DoW not %eof;

    If iGlobLen = 'ASED(_QRNL_PRM+)';
      p_PepCnt += 1;
    EndIf;

    If iGlobalRef = 'Indicator References:';
      IsLookForSeverity = *on;
    EndIf;

    If not IsLookForSeverity;
      If IsGlobalRef;
        ExSr srGlobalDefinitions;
      Else;
        ExSr srFileFieldDefinitions;
      EndIf;

      If iGlobalRef = 'Global Field References:';
        IsGlobalRef = *on;
      EndIf;
    EndIf;

    If IMsgSummary = 'RNF1304';
      IsServicePgm = *on;
    EndIf;

    If not IsServicePgm;
      If iCheckComplete = 'Compilation stopped.';
        p_DiagSeverity = iDiagSeverity;
        Leave;
      EndIf;

      If iCheckCompleteSql = 'level severity error';
        p_DiagSeverity = iDiagSeveritySql;
        Leave;
      EndIf;
    EndIf;

    Read CVTOSP inputDS;
    readCount += 1;
  EndDo;

  If p_DiagSeverity <= '20';
    #$Cmd('DLTSPLF FILE(' + p_SrcMbr + ') SPLNBR(*LAST)');
  EndIf;

  If ii > 1;
    sorta %subarr(FieldsArry(*).Name: 1: ii);
  EndIf;

  FieldsArryCnt = ii;
  Close CVTOSP;

  Return;

  // Load up all the file field sequence numbers to reference later
  BegSr srFileFieldDefinitions;
    If iExternalForma = '* External format  . . . . . :';
      aa = %scan('/':iFSname);
      FileName = %subst(iFSname: aa+1);
      FileSeq = iFileSeq;
      DoU iEqual = '=';
        Read CVTOSP inputDS;
        readCount += 1;
        If iGlobalRef = 'Global Field References:';
          Leave;
        EndIf;
        If iGlobalRef = 'Indicator References:';
          IsLookForSeverity = *on;
          LeaveSr;
        EndIf;
      EndDo;
    EndIf;

    If iEqual = '=';
      xx += 1;
      FileNameArry(xx) = FileName;
      If iFileType = 'D';
        FileFldsArry(xx) = iDFieldName;

      ElseIf iFileType = 'I';
        FileFldsArry(xx) = iIFieldName;
      ElseIf iFileType = 'O';
        FileFldsArry(xx) = iOFieldName;
      EndIf;
      FileFldTxtArry(xx) = iFieldText;
    EndIf;
  EndSr;

  BegSr srGlobalDefinitions;
    If iGlobalRef = 'Field References for sub';
      SavProcName = iFSname;
    EndIf;

    If iFldLong = 'No references in the source.';
      IsLookForSeverity = *on;
      LeaveSr;
    EndIf;

    If iGlobAttr3 = ' A('
          or iGlobAttr3 = ' B('
          or iGlobAttr3 = ' F('
          or iGlobAttr3 = ' G('
          or iGlobAttr3 = ' I('
          or iGlobAttr3 = ' N('
          or iGlobAttr3 = ' P('
          or iGlobAttr3 = ' S('
          or iGlobAttr3 = ' D('
          or iGlobAttr3 = ' T('
          or iGlobAttr3 = ' U('
          or iGlobAttr3 = ' Z('
          or iGlobAttr3 = ' *('
          or iGlobAttr3 = ' DS'
          or iGlobAttr3 = ' CO';
      IsUnReferenced = *off;
      // Extract the field name for these attributes.
      // The field name could be on the same line
      // RULER1ARRY(19)    A(10)
      // or read backwards a line
      // FieldsArryCnt...
      //                    U(5,0)           384D   1252
      // or if on a page break, spread across several lines
      //
      // If field name is not on same line, save rrn, read backwards
      // until ... is found for long field name
      Savname = *blanks;
      If iDFieldName > *blanks;
        IsQualified = (%subst(iFldShort:1 :1) = ' ');
        SavName = %triml(iFldShort);
        If iNotReferenced = '*';
          IsUnReferenced = *on;
        EndIf;
      Else;

        // find long field name reading backwards
        readp CVTOSP inputDS;
        DoW not %eof;
          aa = %scan('...': iFldLong);
          If aa > 0;
            SavName = %triml(%subst(iFldLong: 1: aa - 1));
            If iNotReferenced = '*';
              IsUnReferenced = *on;
            EndIf;
            Chain readcount CVTOSP inputDS; // reposition
            Leave;
          EndIf;
          readp CVTOSP inputDS;
        EndDo;
      EndIf;

      // load attributes from current record before looking for field name
      Clear FieldsAttrDS;
      FieldsAttrDS.DecimalPos = *blanks;

      If iGlobAttr3 = ' DS';
        FieldsAttrDS.DataType = 'A';
      ElseIf iGlobAttr3 = ' CO';
        FieldsAttrDS.DataType = 'C';
      Else;
        FieldsAttrDS.DataType = iGlobAttr1;
      EndIf;

      // Alpha sizes are (6) Numeric are (6,0) Date&Time are (8*ISO-)
      If iGlobAttr3 <> ' CO';
        xOpen = %scan('(': iGlobLen);
        xComma = %scan(',': iGlobLen);
        xAster = %scan('*': iGlobLen);
        xClose = %scan(')': iGlobLen);

        If xAster > 0;  // date or time
          char8 =
                %subst(iGlobLen: xOpen + 1: (xAster - xOpen) - 1);
          FieldsAttrDS.Length = %uns(char8);
          FieldsAttrDS.Text =
                %subst(iGlobLen: xAster + 1: (xClose - xAster)- 1);

        ElseIf xComma > 0; // numeric
          char8 =
                %subst(iGlobLen: xOpen + 1: (xComma - xOpen) - 1);
          FieldsAttrDS.Length = %uns(char8);
          evalr FieldsAttrDS.DecimalPos = '  ' +
                %subst(iGlobLen: xComma + 1: (xClose - xComma)- 1);

        Else; // alpha
          char8 =
                %subst(iGlobLen: xOpen + 1: (xClose - xOpen) - 1);
          FieldsAttrDS.Length = %uns(char8);
        EndIf;
      EndIf;

      If iGlobAttr3 = ' DS';
        FieldsAttrDS.Text = 'DS';
        SavQualified = SavName;
      ElseIf iGlobAttr3 = ' CO';
        FieldsAttrDS.Text = 'CONST';
        FieldsAttrDS.DecimalPos = *blanks;

        // Constants do not show as unreferenced (thanks IBM).
        // Also the reference numbers are in variable position
        //  based on the number of source statements in the code (Thanks Again).
        // 0123456789012345
        // 3000016M     012900M    7000016
        //  Start in pos 50, look for first non-blank, then first blank
        //  and check everything after that for blanks.
        //  In above example, look for the first space after the 3, position 8
        // if everything after position 8 is blank, then unreferenced.
        aa = %check(' ':iReference);
        aa = %scan(' ':iReference: aa);
        If %subst(iReference: aa) = *blanks;
          LeaveSr;
        EndIf;
      EndIf;

      If IsQualified;
        FieldsAttrDS.Text = SavQualified;
      EndIf;

      // Now that the name is extracted, see if file defined field
      If Savname > *blanks;
        aa = %lookup(SavName: FileFldsArry: 1: xx);
        If aa > 0;
          FieldsAttrDS.FromFile = FileNameArry(aa);
          FieldsAttrDS.Text = FileFldTxtArry(aa);
        EndIf;
      EndIf;

      // DIM values are stored in field names between (10) = DIM 10
      // compress the DIM out of the field name
      SavDim = *blanks;
      xOpen = %scan('(': SavName);
      If xOpen > 0;
        xClose = %scan(')': SavName);
        SavDim =
             'DIM' + %subst(SavName: xOpen: (xClose - xOpen)+1);
        SavName = %subst(SavName:1: xOpen - 1);
        FieldsAttrDS.Text = SavDim;
      EndIf;

      If SavProcName > *blanks;
        FieldsAttrDS.Text = SavProcName;
      EndIf;

      // The JCRCALL (generate call prompt) may need the unreferenced
      // field definitions as an unreferenced field could be in the PR.
      If IsUnreferenced;
        FieldsAttrDS.Text = '*NOT REFERENCED';
      EndIf;

      If %subst(SavName:1:1) <> '*';  // skip indicatiors
        If ii = 0 or
                %lookup(SavName: FieldsArry(*).Name: 1: ii) = 0;
          ii += 1;
          FieldsArry(ii).Name = SavName;
          FieldsArry(ii).Attr = FieldsAttrDS;
        EndIf;
      EndIf;
    EndIf;
  EndSr;

End-Proc;

// edit code  commas (y/n)  type sign(none,cr,or -)
**
1YN             1
2YN             2
3NN             3
4NN             4
AYC             5
BYC             6
CNC             7
DNC             8
JY-             9
KY-            10
LN-            11
MN-            12
NY-            13
OY-            14
PN-            15
QN-            16
