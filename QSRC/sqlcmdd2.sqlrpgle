**free
Ctl-Opt Option(*SrcStmt) srtseq(*langidshr) DftActGrp(*No) BndDir('APLLIB') alwnull(*usrctl) ActGrp(*Caller);

// SQL Query Manager - Display Query

Dcl-F SQLCMDF2 workstn sfile(F1S:RRNF1) sfile(F11S:RRNF1)
       sfile(F2S:RRNF2) sfile(F3S:RRNF3) infds(SCRDS);
Dcl-S EOF ind;

Dcl-Ds columns LikeDs(#$SQLColumns);

Dcl-S j int(5);
Dcl-S i int(5);
Dcl-S x int(5);
Dcl-S NumRows2 packed(15);
Dcl-S Offset packed(15);
Dcl-S ScreenRows packed(2);
Dcl-S F21Extn Char(5);
Dcl-S F21FileNo Char(65);
Dcl-S F21Path Char(132);
Dcl-S isBigOk Ind;
Dcl-S MaxWidth packed(5);
Dcl-S message varchar(800);
Dcl-S NumRcF1 packed(5);
Dcl-S NumRcF2 packed(5);
Dcl-S NumRcF3 packed(5);
Dcl-S RRNF1 packed(5);
Dcl-S RRNF2 packed(5);
Dcl-S RRNF3 packed(5);
Dcl-S SplitCol packed(5);
Dcl-S SplitWidth packed(5);
Dcl-S RowLen packed(5);
Dcl-S CurCol packed(5);
Dcl-S CurWidth packed(5);
Dcl-S Version packed(5);
Dcl-S #date packed(8);
Dcl-S #time packed(6);
Dcl-S topRow packed(15);
Dcl-S Row2 Char(20000);
Dcl-S ObjPath Char(128);
Dcl-S psFile Char(60);
Dcl-S svSrch Char(50);
Dcl-S svSrch2 Char(19);
Dcl-S cmd varChar(10000);
Dcl-S splitScreen Ind;
Dcl-S bigScreen Ind;

Dcl-S LINES Char(78) dim(1000);

// The following two structures are used to control the cursor location on a screen
Dcl-Ds SCRDS len(512);
  #$ROW Char(1) pos(370);
  #$COL Char(1) pos(371);
End-Ds;
Dcl-Ds *n Inz;
  #$BINC Char(1) pos(2);
  #$BIN2 int(5) pos(1);
End-Ds;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command

Dcl-Ds Fields2 Likeds(MYDS) dim(17);
Dcl-Ds Nulls2 Qualified Dim(17);
  Null int(5) Dim(900);
End-Ds;
Dcl-Ds Fields Qualified Dim(17);
  val Char(1000) Dim(900);
End-Ds;

Dcl-S sqlStmOriginal varchar(32000);
Dcl-S sqlStmTest varchar(32000);
Dcl-S sqlStm varchar(32000);
Dcl-S SQLSTMP2 varchar(32000);

// Procedure interface and protype for *entry plist
Dcl-Pi SQLCMDD2;
  #$SQLSTM varchar(32000) const;
End-Pi;

// Used to return the value from #$split2
Dcl-S WORD Char(100) dim(1000);

// Convert character to hex data
Dcl-S Char Char(1);
Dcl-S HEXCHAR Char(2);
Dcl-S HEX1 Char(132);
Dcl-S HEX2 Char(132);
Dcl-Pr CharToHex extproc( 'cvthc' );
  *n pointer Value; // CTHHex
  *n pointer Value; // CTHChar
  *n int(10) Value; // CTHCharSize
End-Pr;

Dcl-S #$VARS Char(500);
Dcl-S #$OUTQ Char(10);
Dcl-S #$OQLB Char(10);
Dcl-S #$COPY packed(3);
Dcl-S #$HOLD Char(5);
Dcl-S #$SAVE Char(5);
Dcl-S #$USDT Char(10);
Dcl-S #$FRLN packed(3);
Dcl-S #$FRWD packed(3);
Dcl-S #$INVR Char(4);
Dcl-S #$INQY Char(4);
Dcl-S #$TITLE1 Char(80);
Dcl-S #$TITLE2 Char(80);
Dcl-S #$TITLE3 Char(80);
Dcl-S #$TITLE4 Char(80);
Dcl-S #$TITLE5 Char(80);
Dcl-S #$PNAME Char(10);


// This option turns off commitment control
Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;

ScreenRows=14;
CurCol=1;
MaxWidth=72;
CurWidth=MaxWidth;
SplitWidth=0;
SplitCol=0;
Row=3;
col=21;

isBigOk=#$132Ok();

columns=#$SQLGetColumns(#$SQLSTM);
RowLen=columns.headerWidth;
f2Columns=columns.count;

If isBigOk;
  BIGF1();
EndIf;

// Try to create a view to run eveything else on, This allows CTE's but prevents use of
// logical files and the order by clause. If the view does not work, try doing a subquerry.
// If the subqery does not work, turn off searhcing and use the regular select.
*in95 = *off; // allow searching
Monitor;
  sqlStm='Create or Replace View QTEMP/SQLTMPVIEW as ('+%trim(#$SQLSTM)+')';
  Exec SQL Execute immediate :sqlStm;
  #$SQLSTT();
  sqlStmOriginal='SELECT * FROM QTEMP/SQLTMPVIEW';
On-Error;
  Monitor;
    sqlStmTest='SELECT * FROM (' + %trim(#$SQLSTM) + ')';
    Exec SQL prepare sqlStmTest from :sqlStmTest;
    #$SQLSTT();
    sqlStmOriginal=%trim(#$SQLSTM);
  On-Error;
    sqlStmOriginal=%trim(#$SQLSTM);
    *in95 = *on; // prevent searching
  EndMon;
EndMon;

PROCF1();

// Try to delete the temporary view if it exists
Exec SQL Drop View QTEMP/SQLTMPVIEW;
*INLR = *ON;
Return;


// Process screen 1
Dcl-Proc PROCF1;

  PRPSQLF1();
  *IN94 = *OFF;
  MOVEF1();
  svRows=NumRows;
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF1=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF1<=0 OR CRNF1>RRNF1;
      CrnF1=1;
    EndIf;
    If bigScreen;
      Write F11F;
      Exfmt F11C;
    Else;
      Write F1F;
      Exfmt F1C;
    EndIf;
    %subarr(*IN:50:9) = *OFF;
    Erm='';
    If CSRF1=0;
      If *in46;
        Crnf1=NumRcF1;
      Else;
        CrnF1=1;
      EndIf;
    Else;
      CsrF1=CrnF1;
    EndIf;

    // Get the row and column the cursor is on
    #$bin2=0;
    #$BinC=#$Row;
    Row=#$bin2;
    #$binc=#$col;
    col=#$bin2;

    // If the search field is changed reload the sql statement
    If SVSRCH<>F1SRCH OR SVSRCH2<>F1SRCH2;
      CLSSQLF1();
      PRPSQLF1();
    EndIf;

    If *IN47; // handle paging
      PAGEUP();
      MOVEF1();
    ElseIf *IN46;
      PAGEDOWN();
      MOVEF1();

    ElseIf *IN03; // f3=exit
      Leave;

    ElseIf *IN04; // f4=shift to column
      SHIFTF1();
      MOVEF1();

    ElseIf *IN05; // f5=column details
      PROCF2();

    ElseIf *IN06; // f6=view sql
      PROCF3();

    ElseIf *IN19; // f19,f7=left
      LEFTF1();
      MOVEF1();

    ElseIf *IN20; // f20,f8=right
      RIGHTF1();
      MOVEF1();

    ElseIf *IN21; // f9/21=split
      SPLITF1();
      MOVEF1();

    ElseIf *IN10; // f10/22=width toggle
      BIGF1();
      CLSSQLF1();
      PRPSQLF1();
      MOVEF1();

    ElseIf *IN11; // f11=display hex
      If *IN85;
        *IN85=*OFF;
      Else;
        *IN85=*ON;
      EndIf;
      If not bigScreen;
        If *in85;
          ScreenRows=3;
        Else;
          ScreenRows=14;
        EndIf;
      Else;
        If *in85;
          ScreenRows=4;
        Else;
          ScreenRows=17;
        EndIf;
      EndIf;
      CLSSQLF1();
      PRPSQLF1();
      MOVEF1();

    ElseIf *IN12; // f12=cancel
      Leave;

    ElseIf *IN13; // f13=email
      PROCF8();
      *IN25 = *ON;

    ElseIf *IN14; // f14=print
      PROCF9();
      *IN25 = *ON;

    ElseIf *IN15; // f15=save ifs
      PROCF21();
      *IN25 = *ON;

    ElseIf *IN16; // f16=shift to row
      SHIFTRF1();

    ElseIf *IN17; // f17=save pf
      PROCF23();
      *IN25 = *ON;

    ElseIf *IN27; // fxx=any other function key so the screen doesnt lock up
      ERM=#$Cntr('Error - invalid function key.':50);
      ITER;

    Else;
      VALDF1();
      If not *in50;
        UPDTF1();
        If not *IN25;
          Leave;
        EndIf;
        MOVEF1();
      EndIf;
    EndIf;
  EndDo;

  CLSSQLF1();

End-Proc;


// Move Screen 1
Dcl-Proc MOVEF1;

  // Setup command keys
  If splitScreen;
    F9CMDK='F9=No Split';
  Else;
    F9CMDK='F9=Split';
  EndIf;

  // Clear sfl
  *IN44 = *ON;
  If bigScreen;
    Write F11C;
  Else;
    Write F1C;
  EndIf;
  *IN44 = *OFF;

  RRNF1=0;

  If NUMROWS=0;
    ERM=#$Cntr('Error - query returned no rows.':50);
    *IN50 = *ON;
    Return;
  EndIf;

  If splitScreen;
    If bigScreen;
      F11HDR1=%subst(columns.RULER :SplitCol:SplitWidth) +
                           ' | '+%subst(columns.RULER :CurCol:CurWidth);
      F11HDR2=%subst(columns.headers:SplitCol:SplitWidth) +
                           ' | '+%subst(columns.headers:CurCol:CurWidth);
    Else;
      F1HDR1=%subst(columns.RULER :SplitCol:SplitWidth) +
                             ' | '+%subst(columns.RULER :CurCol:CurWidth);
      F1HDR2=%subst(columns.headers:SplitCol:SplitWidth) +
                             ' | '+%subst(columns.headers:CurCol:CurWidth);
    EndIf;
  Else;
    If bigScreen;
      F11HDR1=%subst(columns.RULER :CurCol:MaxWidth);
      F11HDR2=%subst(columns.headers:CurCol:MaxWidth);
    Else;
      F1HDR1=%subst(columns.RULER :CurCol:MaxWidth);
      F1HDR2=%subst(columns.headers:CurCol:MaxWidth);
    EndIf;
  EndIf;

  SF1SEQ = topRow;

  // Fill sfl
  GETSQLF1();
  For i=1 To ScreenRows;
    If topRow+i-1<=NUMROWS;
      BLDROW();
      If splitScreen;
        If bigScreen;
          SF11LINE=%subst(Row2:SplitCol:SplitWidth) +
                  ' | '+%subst(Row2:CurCol:CurWidth);
        Else;
          SF1LINE=%subst(Row2:SplitCol:SplitWidth)+
                  ' | '+%subst(Row2:CurCol:CurWidth);
        EndIf;
      Else;
        If bigScreen;
          SF11LINE=%subst(Row2:CurCol:MaxWidth);
        Else;
          SF1LINE=%subst(Row2:CurCol:MaxWidth);
        EndIf;
      EndIf;
      RRNF1+=1;
      *IN86 = *ON;
      If bigScreen;
        Write F11S;
      Else;
        Write F1S;
      EndIf;
      If *in85;
        ADDHEX();
      EndIf;
      SF1Seq+=1;
    Else;
      Leave;
    EndIf;
  EndFor;

  // set bottom of sfl indicator
  If topRow+SCREENROWS>=NUMROWS;
    *IN81 = *ON;
  Else;
    *IN81 = *OFF;
  EndIf;

  NumRcF1=RRNF1;

End-Proc;


// Add Hex Values
Dcl-Proc ADDHEX;

  // This subroutine converts the last row into hex, adds the hex as under
  // over columns and skips a line so it doesn't blur together

  *IN86 = *OFF;

  // handle 80 char screen size
  If not bigScreen;
    For j=1 To 72;
      Char=%subst(SF1LINE:i:1);
      CharToHex(%addr(HEXCHAR):%addr(Char):2);
      %subst(HEX1:j:1)=%subst(HEXCHAR:1:1);
      %subst(HEX2:j:1)=%subst(HEXCHAR:2:1);
    EndFor;
    SF1LINE=HEX1;
    RRNF1+=1;
    Write F1S;
    SF1LINE=HEX2;
    RRNF1+=1;
    Write F1S;
    SF1LINE=' ';
    RRNF1+=1;
    Write F1S;
  EndIf;

  // handle 132 char screen size
  If bigScreen;
    For j=1 To 124;
      Char=%subst(SF11LINE:j:1);
      CharToHex(%addr(HEXCHAR):%addr(Char):2);
      %subst(HEX1:j:1)=%subst(HEXCHAR:1:1);
      %subst(HEX2:j:1)=%subst(HEXCHAR:2:1);
    EndFor;
    SF11LINE=HEX1;
    RRNF1+=1;
    Write F11S;
    SF11LINE=HEX2;
    RRNF1+=1;
    Write F11S;
    SF11LINE=' ';
    RRNF1+=1;
    Write F11S;
  EndIf;

End-Proc;


// Build Row
Dcl-Proc BLDROW;
  Dcl-S trmFld varchar(100);
  Dcl-S isNeg ind;

  x=0;
  Row2='';
  For x = 1 To columns.count;

    // if numeric, format and right justify
    If #$in(#$upify(columns.col(x).TYPE):'DECFLOAT':'NUMERIC':'DECIMAL':'INTEGER':'SMALLINT'
          :'FLOAT':'REAL':'DOUBLE':'BIGINT');

      // use the value passed by SQL, strip the - sign so it can be added to the end later.
      trmFld = %trim(Fields(i).val(x));
      Clear isNeg;
      If trmFld <> %scanrpl('-':'':trmFld);
        trmFld = %scanrpl('-':'':trmFld);
        isNeg = *on;
      EndIf;
      // the starting postion is the column offest + column length
      //                                           - 1 (for the negative sign)
      //                                           - field length
      // The length is just the length of the trimmed field
      %subst(Row2:columns.col(x).Offset + columns.col(x).COLWIDTH - 1 - %len(trmFld)
                 :%len(trmFld))=trmFld;
      If isNeg;
        %subst(Row2:columns.col(x).Offset+columns.col(x).COLWIDTH-1:1)='-';
      EndIf;
    Else;
      %subst(Row2:columns.col(x).Offset:columns.col(x).COLWIDTH)=
        %xlate(IChar:OChar:Fields(i).val(x));
    EndIf;

  EndFor;

End-Proc;


// Process Page Up
Dcl-Proc PAGEUP;

  If topRow=1;
    ERM=#$Cntr('You are already at the top.':50);
    Return;
  EndIf;

  // calculate the new top row
  topRow=topRow-ScreenRows;
  If TOPROW<1;
    topRow=1;
  EndIf;

End-Proc;


// Process Page Down
Dcl-Proc PAGEDOWN;

  If topRow+SCREENROWS>NUMROWS;
    ERM=#$Cntr('You are already at the bottom.':50);
    Return;
  EndIf;

  // calculate the new top row
  topRow=topRow+ScreenRows;

End-Proc;


// Validate the Screen
Dcl-Proc VALDF1;
End-Proc;


// Show 132
Dcl-Proc BIGF1;

  If not isBigOk;
    ERM=#$Cntr('Error - Workstation not configured for wide format.':50);
    Return;
  EndIf;

  If bigScreen;
    bigScreen = *OFF;
    If *in85;
      ScreenRows=3;
    Else;
      ScreenRows=14;
    EndIf;
    MaxWidth=72;
  Else;
    bigScreen = *ON;
    If *in85;
      ScreenRows=4;
    Else;
      ScreenRows=17;
    EndIf;
    MaxWidth=124;
  EndIf;
  // force split off
  If splitScreen;
    CurCol=SplitCol;
  EndIf;
  CurWidth=MaxWidth;
  SplitWidth=0;
  SplitCol=0;
  splitScreen = *OFF;

End-Proc;


// Shift Screen Left
Dcl-Proc LEFTF1;

  CurCol-=CurWidth;
  If CURCOL<=0;
    CurCol=1;
  EndIf;

End-Proc;


// Shift Screen Right
Dcl-Proc RIGHTF1;

  If CurCol+CURWIDTH<ROWLEN;
    CurCol+=CurWidth;
  EndIf;

End-Proc;


// Split Screen at cursor
Dcl-Proc SPLITF1;

  If splitScreen;
    splitScreen = *OFF;
    CurCol=SplitCol;
    CurWidth=MaxWidth;
    Return;
  EndIf;

  If COL<10;
    ERM=#$Cntr('Error move cursor to where you want the data split.':50);
    Return;
  EndIf;

  splitScreen = *ON;

  // When in split curcol is for split side, splitcol and splitwidth
  // are for the static section, curwidth becomes maxwidth-3-splitwidth

  SplitCol=CurCol;
  SplitWidth=COL-8;
  CurWidth=MaxWidth-SplitWidth-3;
  CurCol=SplitCol+SplitWidth+3;

End-Proc;


// Shift Screen
Dcl-Proc SHIFTF1;

  // If in split give error if on the right side of the screen
  If splitScreen AND COL<SPLITWIDTH + 12;
    ERM=#$Cntr('Error move cursor to where you want the data split.':50);
    Return;
  EndIf;

  If splitScreen;
    CurCol+=COL-SplitWidth-12;
  Else;
    CurCol+=COL-9;
  EndIf;

End-Proc;


// Shift ????
Dcl-Proc SHIFTRF1;

  // Chain the row the sfl is on
  If bigScreen;
    Chain CsrF1 F11S;
  Else;
    Chain CsrF1 F1S;
  EndIf;
  If %found;
    F1PSTOL=%char(SF1SEQ);
  EndIf;

  *IN25 = *ON;

End-Proc;


// Update any entry on the screen
Dcl-Proc UPDTF1;

  // Handle position to line
  If F1PSTOL<>' ';

    // Handle top
    If %trim(F1PSTOL)='T' OR
          %trim(F1PSTOL)='TOP' OR
          %trim(F1PSTOL)='*TOP' OR
          %trim(F1PSTOL)='1';
      topRow=1;
    EndIf;

    // Handle bottom
    If %trim(F1PSTOL)='B' OR
          %trim(F1PSTOL)='*BOT' OR
          %trim(F1PSTOL)='*BOTTOM' OR
          %trim(F1PSTOL)='BOT' OR
          %trim(F1PSTOL)='BOTTOM' OR
          %trim(F1PSTOL)='999999999';
      If %rem(NUMROWS:ScreenRows)=0;
        topRow=(%div(NUMROWS:ScreenRows) - 1) *
            ScreenRows + 1;
      Else;
        topRow=%div(NUMROWS:ScreenRows) *
            ScreenRows + 1;
      EndIf;
    EndIf;

    // If all numberic, position to the specific record
    If #$TESTN(F1PSTOL:1:1);
      topRow=#$RVL(F1PSTOL);
      If TOPROW>NUMROWS;
        topRow=NUMROWS;
      EndIf;
    EndIf;

    // If has a negative sign go back that many rows
    If %scan('-':F1PSTOL)>0;
      If #$TESTN(F1PSTOL:1:1:1);
        topRow=topRow+#$RVL(F1PSTOL);
        If TOPROW>NUMROWS;
          topRow=NUMROWS;
        EndIf;
      EndIf;
    EndIf;

    // If has a plus sign go forward that many rows
    If %scan('+':F1PSTOL)>0;
      F1PSTOL=%scanrpl('+':'':F1PSTOL);
      If #$TESTN(F1PSTOL:1:1);
        topRow=topRow+#$RVL(F1PSTOL);
        If TOPROW>NUMROWS;
          topRow=NUMROWS;
        EndIf;
      EndIf;
    EndIf;

    F1PSTOL='';
  EndIf;

  // Handle position to column
  If F1PSTOC<>' ';

    // If all numberic, position to the specific column
    If #$TESTN(F1PSTOC:1:1);
      CurCol=#$RVL(F1PSTOC);
      If CURCOL>ROWLEN;
        CurCol=RowLen-71;
      EndIf;
    EndIf;

    // If has a negative sign go back that many rows
    If %scan('-':F1PSTOC)>0;
      If #$TESTN(F1PSTOC:1:1:1);
        CurCol=CurCol+#$RVL(F1PSTOC);
        If CURCOL<1;
          CurCol=1;
        EndIf;
      EndIf;
    EndIf;

    // If has a plus sign go forward that many rows
    If %scan('+':F1PSTOC)>0;
      F1PSTOC=%scanrpl('+':'':F1PSTOC);
      If #$TESTN(F1PSTOC:1:1);
        CurCol=CurCol+#$RVL(F1PSTOC);
        If CURCOL>ROWLEN;
          CurCol=RowLen-71;
        EndIf;
      EndIf;
    EndIf;

    F1PSTOC ='';
  EndIf;

End-Proc;


// Prepare SQL Statement
Dcl-Proc PRPSQLF1;
  Dcl-S sqlCntStm like(sqlStm);

  EOF=*OFF;

  // Setup sql select statement
  sqlStm=sqlStmOriginal;

  // If a search string is entered add a where clause
  *IN94 = *OFF;
  If (F1SRCH<>' ' AND bigScreen) OR
     (F1SRCH2<>' ' AND not bigScreen);
    ADDSRCH();
    *IN94 = *ON;
  EndIf;

  // Prepare the statement, setup the cursor and open it
  Exec SQL Prepare SQLF1 From :sqlStm;
  #$SQLSTT();
  Exec SQL Declare SQLCRSF1 INSENSITIVE SCROLL Cursor For SQLF1;
  #$SQLSTT();
  Exec SQL Open SQLCRSF1;
  #$SQLSTT();

  // Get the number of rows
  NumRows2=0;
  sqlCntStm = 'Select count(*) from (' + sqlStm + ')';
  Exec SQL Prepare SQLCNTF1 From :sqlCntStm;
  Exec SQL Declare SQLCNTCRSF1 Cursor For SQLCntF1;
  Exec SQL Open SQLCNTCRSF1;
  Exec SQL Fetch Next from SQLCNTCRSF1 into :numRows2;
  Exec SQL Close SQLCNTCRSF1;

  numRows=NumRows2;
  topRow=1;
  svSrch=F1Srch;
  svSrch2=f1Srch2;

End-Proc;


// Add Search
Dcl-Proc ADDSRCH;
  Dcl-S comma varchar(1);

  // Add fields to search array
  For i=1 To columns.count;
    If columns.col(i).TYPE<>'DATE/TIME/TIMESTAMP'
          AND columns.col(i).TYPE<>'DATE'
          AND columns.col(i).TYPE<>'TIME'
          AND columns.col(i).TYPE<>'TIMESTAMP'
          AND columns.col(i).TYPE<>'';
      #$BLDSCHF(i)='"'+%trim(columns.col(i).name)+'"';
    EndIf;
  EndFor;

  // Split search string to words array
  If bigScreen;
    sqlStm='Select * from('+%trim(sqlStmOriginal) + ')';
    // add variable in case some were defaulted
    sqlStm += ' VARIABLES(';
    comma = '';
    For i = 1 to columns.count;
      sqlStm += comma +'"'+ columns.col(i).name +'"';
      comma = ',';
    EndFor;
    sqlStm += ')';
    sqlStm += ' WHERE ' + #$BLDSCH(F1SRCH:#$BLDSCHF);
  Else;
    sqlStm='Select * from('+%trim(sqlStm) + ')';
    // add variable in case some were defaulted
    sqlStm += ' VARIABLES(';
    comma = '';
    For i = 1 to columns.count;
      sqlStm += comma +'"'+ columns.col(i).name +'"';
      comma = ',';
    EndFor;
    sqlStm += ')';
    sqlStm += ' WHERE ' + #$BLDSCH(F1SRCH2:#$BLDSCHF);
  EndIf;

End-Proc;


// Fecth Next Screen
Dcl-Proc GETSQLF1;

  // Position to before the first record
  Monitor;
    Exec SQL Fetch FIRST From SQLCRSF1 Into :MYDS :nulls;
  On-Error;
  EndMon;
  #$SQLSTT();

  // Calcualte the rows to skip, the cursor should be on row one
  // from previous fetch
  Offset=0;
  Offset=topRow-1;

  // fetch one pages worth of rows into the data structure
  Clear fields2;
  Monitor;
    Exec SQL Fetch RELATIVE :Offset From SQLCRSF1
             For :ScreenRows ROWS Into :Fields2 :Nulls2;
    If #$SQLSTT();
      EOF = *ON;
    EndIf;
  On-Error;
    EOF = *ON;
  EndMon;

  EVAL Fields=Fields2;

End-Proc;


// Close Cursor for F1
Dcl-Proc CLSSQLF1;

  Exec SQL Close SQLCRSF1;

End-Proc;


// Process Screen 2
Dcl-Proc PROCF2;

  MOVEF2();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF2=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF2<=0 OR CRNF2>RRNF2;
      CrnF2=1;
    EndIf;
    Write F2F;
    Exfmt F2C;
    %subarr(*IN:50:9) = *OFF;
    Erm='';
    If CSRF2=0;
      If *in46;
        CrnF2=NumRcF2;
      Else;
        CrnF2=1;
      EndIf;
    Else;
      CrnF2=CsrF2;
    EndIf;

    // If paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':50);
      ITER;
    EndIf;

    // If paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
          BOTTOM.':50);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      *INLR = *ON;
      // Try to delete the temporary view if it exists
      Exec SQL Drop View QTEMP/SQLTMPVIEW;
      Return;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
          KEY.':50);
      ITER;
    EndIf;

    VALDF2();
    If *in50;
      Iter;
    EndIf;

    UPDTF2();

    Leave;
  EndDo;

End-Proc;


// Populate Screen F2
Dcl-Proc MOVEF2;

  // clear sfl
  *IN44 = *ON;
  Write F2C;
  *IN44 = *OFF;

  RRNF2=0;

  // fill sfl
  For x=1 To columns.count;
    SF2Seq=x;
    SF2CLMNM=columns.col(x).NAME;
    SF2LEN  =columns.col(x).LEN;
    SF2TYPE =columns.col(x).TYPE;
    If columns.col(x).DEC<>0;
      SF2LEN =columns.col(x).DEC;
      EVALR SF2DECA=%editc(columns.col(x).SCALE:'Z');
      If SF2DECA=' ';
        EVALR SF2DECA='0';
      EndIf;
    Else;
      SF2LEN =columns.col(x).LEN;
      EVALR SF2DECA='   ';
    EndIf;
    SF2WID =columns.col(x).COLWIDTH;
    SF2OFFSET =columns.col(x).Offset;
    RRNF2+=1;
    Write F2S;
  EndFor;

  NumRcF2=RRNF2;

End-Proc;


// Validate Screen F2
Dcl-Proc VALDF2;

End-Proc;


// Update Screen f2
Dcl-Proc UPDTF2;

End-Proc;


// Display Screen F3
Dcl-Proc PROCF3;

  MOVEF3();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF3= 0;
      *in45 = *off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF3<=0 OR CRNF3>RRNF3;
      CRNF3=1;
    EndIf;
    Write F3F;
    Exfmt F3C;
    %subarr(*IN:50:9) = *OFF;
    erm='';
    If CSRF3=0;
      If *in43;
        CrnF3=NumRcF3;
      Else;
        CrnF3=1;
      EndIf;
    Else;
      CrnF3=CsrF3;
    EndIf;

    // If paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':50);
      ITER;
    EndIf;

    // If paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
          BOTTOM.':50);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      *INLR = *ON;
      // Try to delete the temporary view if it exists
      Exec SQL Drop View QTEMP/SQLTMPVIEW;
      Return;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF3();
    If *in50;
      Iter;
    EndIf;

    UPDTF3();

    Leave;
  EndDo;

End-Proc;


// Load Screen F3
Dcl-Proc MOVEF3;

  BLDLINES();

  // clear sfl
  *IN44 = *ON;
  Write F3C;
  *IN44 = *OFF;

  RRNF3=0;

  // fill sfl
  For i=1 To 1000;
    RRNF3=i;
    If LINES(i)<>' ';
      Sf3Line=LINES(i);
      Write F3S;
      NumRcF3=RRNF3;
    EndIf;
  EndFor;

End-Proc;


// Validate Screen F3
Dcl-Proc VALDF3;

End-Proc;


// Update Screen F3
Dcl-Proc UPDTF3;

End-Proc;


// Process Screen F8
Dcl-Proc PROCF8;

  MOVEF8();
  DoW not *INLR;

    Exfmt F8;
    %subarr(*IN:50:13) = *OFF;
    ERM = '';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF8();
    If *in50;
      Iter;
    EndIf;

    UPDTF8();

    Leave;
  EndDo;

End-Proc;


// Load Screen F8
Dcl-Proc MOVEF8;

  If F8EM01=' ';
    Exec SQL Select ACEMAIL Into :F8EM01 From ACCESSPF Where ACUPRF=:USER;
  EndIf;

  If F8ATTY=' ';
    F8ATTY='*XLS';
  EndIf;

  If F8ATTY=' ';
    F8ATTY='*XLS';
  EndIf;

End-Proc;


// Validate Screen F8
Dcl-Proc VALDF8;

  // If * current is used in any of the email addresses replace it with
  // the email address from accesspf
  If %trim(F8EM01)='*USER' OR %trim(F8EM01)='*CURRENT';
    Exec SQL Select ACEMAIL Into :F8EM01 From ACCESSPF Where ACUPRF=:USER;
  EndIf;
  If %trim(F8EM02)='*USER' OR %trim(F8EM02)='*CURRENT';
    Exec SQL Select ACEMAIL Into :F8EM02 From ACCESSPF Where ACUPRF=:USER;
  EndIf;
  If %trim(F8EM03)='*USER' OR %trim(F8EM03)='*CURRENT';
    Exec SQL Select ACEMAIL Into :F8EM03 From ACCESSPF Where ACUPRF=:USER;
  EndIf;
  If %trim(F8EM04)='*USER' OR %trim(F8EM04)='*CURRENT';
    Exec SQL Select ACEMAIL Into :F8EM04 From ACCESSPF Where ACUPRF=:USER;
  EndIf;

  // Entry make sure the email address is valid
  If F8EM01<>' ' AND #$VEML(F8EM01);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        EMAIL.':50);
    Return;
  EndIf;

  If F8EM02<>' ' AND #$VEML(F8EM02);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        EMAIL.':50);
    Return;
  EndIf;

  If F8EM03<>' ' AND #$VEML(F8EM03);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        EMAIL.':50);
    Return;
  EndIf;

  If F8EM04<>' ' AND #$VEML(F8EM04);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        EMAIL.':50);
    Return;
  EndIf;

  // Make sure an email address or report dist id is entered
  If F8EM01=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER AN +
        EMAIL ADDRESS.':50);
    Return;
  EndIf;

  // Validate the attachment type
  If F8ATTY<>'*XLS' AND F8ATTY<>'*CSV' AND
        F8ATTY<>'*XML' AND F8ATTY<>'*PDF' AND
        F8ATTY<>'*JSON';
    *IN56 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID ATTACHEMNT +
        TYPE.':50);
    Return;
  EndIf;

End-Proc;


// Update Screen F8
Dcl-Proc UPDTF8;

  If F8ATTY='*PDF';
    UPDTF8PDF();
    Return;
  EndIf;

  // build a command to email the query
  cmd='EMLSQL SQL(''' + %trim(%scanrpl('''':'''''':#$SQLSTM)) + ''') +
            FILE(''' + %trim(F8FILE) + ''') +
            TYPE(' + %trim(F8ATTY) + ') +
            EMAIL( ';

  If F8EM01<>' ';
    cmd+=' (' + %trim(F8EM01) + ')';
  EndIf;
  If F8EM02<>' ';
    cmd+=' (' + %trim(F8EM02) + ')';
  EndIf;
  If F8EM03<>' ';
    cmd+=' (' + %trim(F8EM03) + ')';
  EndIf;
  If F8EM04<>' ';
    cmd+=' (' + %trim(F8EM04) + ')';
  EndIf;
  cmd+=' )';

  If F8SUBJ<>' ';
    cmd+=' SUBJECT(''' + %trim(#$DBLQ(F8SUBJ))+''')';
  EndIf;

  message='';
  If F8MS01<>' ';
    message+=%trimr(#$DblQ(F8MS01))+'<br>';
  EndIf;
  If F8MS02<>' ';
    message+=%trimr(#$DblQ(F8MS02))+'<br>';
  EndIf;
  If F8MS03<>' ';
    message+=%trimr(#$DblQ(F8MS03))+'<br>';
  EndIf;
  If F8MS04<>' ';
    message+=%trimr(#$DblQ(F8MS04))+'<br>';
  EndIf;
  If F8MS05<>' ';
    message+=%trimr(#$DblQ(F8MS05))+'<br>';
  EndIf;
  If F8MS06<>' ';
    message+=%trimr(#$DblQ(F8MS06))+'<br>';
  EndIf;
  If F8MS07<>' ';
    message+=%trimr(#$DblQ(F8MS07))+'<br>';
  EndIf;
  If F8MS08<>' ';
    message+=%trimr(#$DblQ(F8MS08))+'<br>';
  EndIf;
  If F8MS09<>' ';
    message+=%trimr(#$DblQ(F8MS09))+'<br>';
  EndIf;
  If F8MS10<>' ';
    message+=%trimr(#$DblQ(F8MS10))+'<br>';
  EndIf;
  If message<>'';
    cmd=%trim(cmd) + ' MESSAGE('''+%trim(message)+''' *TEXTHTML)';
  EndIf;

  #$Cmd(cmd:2);

End-Proc;


// Create PDF to email
Dcl-Proc UPDTF8PDF;

  // Override and hard code some of the print variables
  #date=%dec(%char(%date():*ISO0):8:0);
  #time=%dec(%char(%time():*HMS0):6:0);

  #$OQLB  = 'QGPL';
  #$OUTQ  = 'TRASH';
  #$COPY  = 1;
  #$HOLD  = '*YES';
  #$SAVE  = '*NO ';
  #$USDT  = 'SQL'+%trim(%char(#date));
  #$FRLN  = 66;
  #$FRWD  = 132;
  #$INVR  = '*NO ';
  #$INQY  = '*NO ';
  #$PNAME = '';

  // Print the SQL Statement
  SQLCMDB1(#$SQLSTM:
      #$VARS:
      #$OUTQ:
      #$OQLB:
      #$COPY:
      #$HOLD:
      #$SAVE:
      #$USDT:
      #$FRLN:
      #$FRWD:
      #$INVR:
      #$INQY:
      #$TITLE1:
      #$TITLE2:
      #$TITLE3:
      #$TITLE4:
      #$TITLE5:
      #$PNAME);

  // Build a file name
  psFile='SQL'+%trim(WSID) +
      %trim(%char(#date))+%trim(%char(#time));

  ObjPath='/ACOM/EMAIL/TMP/'+%trim(psFile);

  // Add .pdf extension if not already on there
  If #$UPIFY(#$LAST(ObjPath:4)) <>'.PDF';
    ObjPath=%trim(ObjPath)+'.pdf';
  EndIf;

  // convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMDO1) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
         %trim(ObjPath) + ''') WSCST(*PDF)':2);

  // Delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMDO1) SPLNBR(*LAST)':2);

  // Build a command to email the query
  cmd='GUMBOMAIL/GSENDMAIL TOSMTPNAME(';

  If F8EM01<>' ';
    cmd+=' (' + %trim(F8EM01) + ')';
  EndIf;
  If F8EM02<>' ';
    cmd+=' (' + %trim(F8EM02) + ')';
  EndIf;
  If F8EM03<>' ';
    cmd+=' (' + %trim(F8EM03) + ')';
  EndIf;
  If F8EM04<>' ';
    cmd+=' (' + %trim(F8EM04) + ')';
  EndIf;
  cmd+=' )';

  If F8SUBJ<>' ';
    cmd=' SUBJECT(''' + %trim(#$DblQ(F8SUBJ)) + ''')';
  EndIf;

  message='';
  If F8MS01<>' ';
    message+=%trimr(#$DblQ(F8MS01))+'<br>';
  EndIf;
  If F8MS02<>' ';
    message+=%trimr(#$DblQ(F8MS02))+'<br>';
  EndIf;
  If F8MS03<>' ';
    message+=%trimr(#$DblQ(F8MS03))+'<br>';
  EndIf;
  If F8MS04<>' ';
    message+=%trimr(#$DblQ(F8MS04))+'<br>';
  EndIf;
  If F8MS05<>' ';
    message+=%trimr(#$DblQ(F8MS05))+'<br>';
  EndIf;
  If F8MS06<>' ';
    message+=%trimr(#$DblQ(F8MS06))+'<br>';
  EndIf;
  If F8MS07<>' ';
    message+=%trimr(#$DblQ(F8MS07))+'<br>';
  EndIf;
  If F8MS08<>' ';
    message+=%trimr(#$DblQ(F8MS08))+'<br>';
  EndIf;
  If F8MS09<>' ';
    message+=%trimr(#$DblQ(F8MS09))+'<br>';
  EndIf;
  If F8MS10<>' ';
    message+=%trimr(#$DblQ(F8MS10))+'<br>';
  EndIf;
  If message<>' ';
    cmd+=' MSG(''' + message+''' *TEXTHTML)';
  EndIf;

  // Append created pdf file
  cmd+=' OBJ( (''' +%trim(ObjPath) + ''' *ATTACHPDF ) )';

  #$Cmd(cmd:2);

End-Proc;


// Process Screen F9
Dcl-Proc PROCF9;

  MOVEF9();
  DoW not *INLR;

    Exfmt F9;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF9();
    If *in50;
      Iter;
    EndIf;

    UPDTF9();

    Leave;
  EndDo;

End-Proc;


// Load Screen F9
Dcl-Proc MOVEF9;

  Clear F9;

  F9Copy=1;
  F9Hold='*NO';
  F9Save='*NO';
  F9FrLn=66;
  F9FrWd=132;
  F9pInQy='*NO';

  // get the jobs output queue
  GetOutQ(F9OutQ:F9OQLb);

End-Proc;


// Validate Screen F9
Dcl-Proc VALDF9;

  If F9TITLE1=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
        REPORT TITLE.':50);
    Return;
  EndIf;

  // Make sure the output queue is valid
  If F9OUTQ<>' ' AND F9OUTQ<>'*JOB';
    If F9OQLB=' ';
      F9OQLB='*LIBL';
    EndIf;
    If not #$ISOUTQ(F9OUTQ:F9OQLB);
      *IN52 = *ON;
      *IN50 = *ON;
      ERM=#$Cntr('ERROR - INVALID OR MISSING +
          OUTPUT QUEUE.':50);
      Return;
    EndIf;
  EndIf;

  If F9COPY<1 OR F9COPY>255;
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - COPIES MUST BE +
        BETWEEN 1 AND 255.':50);
    Return;
  EndIf;

  If F9HOLD<>'*YES' AND F9HOLD<>'*NO';
    *IN54 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - MUST BE *YES OR +
        *NO.':50);
    Return;
  EndIf;

  If F9SAVE<>'*YES' AND F9SAVE<>'*NO';
    *IN55 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - MUST BE *YES OR +
        *NO.':50);
    Return;
  EndIf;

End-Proc;


// Update Screen F9
Dcl-Proc UPDTF9;

  #$VARS  = ' ';
  #$OUTQ  = F9OUTQ;
  #$OQLB  = F9OQLB;
  #$COPY  = F9COPY;
  #$HOLD  = F9HOLD;
  #$SAVE  = F9SAVE;
  #$USDT  = F9USDT;
  #$FRLN  = F9FRLN;
  #$FRWD  = F9FRWD;
  #$INVR  = '*NO';
  #$INQY  = F9PINQY;
  #$TITLE1 = F9TITLE1;
  #$TITLE2 = F9TITLE2;
  #$TITLE3 = F9TITLE3;
  #$TITLE4 = F9TITLE4;
  #$TITLE5 = F9TITLE5;

  // Print report
  SQLCMDB1(#$SQLSTM:
      #$VARS:
      #$OUTQ:
      #$OQLB:
      #$COPY:
      #$HOLD:
      #$SAVE:
      #$USDT:
      #$FRLN:
      #$FRWD:
      #$INVR:
      #$INQY:
      #$TITLE1:
      #$TITLE2:
      #$TITLE3:
      #$TITLE4:
      #$TITLE5:
      #$PNAME);

End-Proc;


// Process Screen F21
Dcl-Proc PROCF21;

  MOVEF21();
  DoW not *INLR;

    Exfmt F21;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF21();
    If *in50 or *in12 or *in03;
      iter;
    EndIf;

    UPDTF21();

    Leave;
  EndDo;

End-Proc;


// Load Screen F21
Dcl-Proc MOVEF21;

  Clear F21;

  If F21FOLD=' ';
    F21FOLD=#$USRHOME;
  EndIf;

  F21ATTY='*XLS';
  F21EMPTY='*YES';
  F21USETEXT='*YES';

  F21Sheet='Sheet 1';

End-Proc;


// Validate Screen F21
Dcl-Proc VALDF21;

  // Make sure the folder is valid and exists
  If F21FOLD=' ' OR #$VPATH(F21FOLD);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        FOLDER.':50);
    Return;
  EndIf;

  // Validate that a file name is entered
  If F21FILE=' ';
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
        A FILE NAME.':50);
    Return;
  EndIf;

  // Validate the attachment type
  If F21ATTY<>'*XLS' AND F21ATTY<>'*CSV' AND
        F21ATTY<>'*XML' AND F21ATTY<>'*PDF' AND
        F21ATTY<>'*JSON';
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID FILE +
        TYPE.':50);
    Return;
  EndIf;

  // Validate the create empty file option
  If F21EMPTY<>'*YES' AND F21EMPTY<>'*NO';
    *IN54 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':50);
    Return;
  EndIf;

  // Validate the use field text option
  If F21USETEXT<>'*YES' AND F21USETEXT<>'*NO';
    *IN55 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':50);
    Return;
  EndIf;

  // Get the file name without an extension if one is already entered
  F21FileNo=F21File;
  If F21ATTY='*XLS' AND #$UPIFY(#$LAST(F21FILE:5)) = '.XLSX';
    F21FileNo = %subst(F21FILE:1:%len(%trim(F21FILE))-5);
  EndIf;
  If F21ATTY='*CSV' AND #$UPIFY(#$LAST(F21FILE:4)) = '.CSV';
    F21FileNo = %subst(F21FILE:1:%len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*XML' AND #$UPIFY(#$LAST(F21FILE:4)) = '.XML';
    F21FileNo = %subst(F21FILE:1:%len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*PDF' AND #$UPIFY(#$LAST(F21FILE:4)) = '.PDF';
    F21FileNo = %subst(F21FILE:1:%len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*JSON' AND #$UPIFY(#$LAST(F21FILE:5)) = '.JSON';
    F21FileNo = %subst(F21FILE:1:%len(%trim(F21FILE))-5);
  EndIf;

  // Default the extension
  F21Extn='';
  If F21ATTY = '*XLS';
    F21Extn = '.xlsx';
  ElseIf F21ATTY = '*CSV';
    F21Extn = '.csv';
  ElseIf F21ATTY = '*XML';
    F21Extn = '.xml';
  ElseIf F21ATTY = '*PDF';
    F21Extn = '.pdf';
  ElseIf F21ATTY = '*JSON';
    F21Extn = '.json';
  EndIf;

  // Build the full path with extension and see if it already exists
  F21Path=%trim(F21fold) + '/' + %trim(F21FileNo) + %trim(F21Extn);
  If not #$VPATH(F21Path);
    PROCF22();
  EndIf;

End-Proc;


// Update Screen F21
Dcl-Proc UPDTF21;

  If F21ATTY='*PDF';
    UPDTF21PDF();
  ElseIf F21ATTY='*JSON';
    UPDTF21JSON();
  Else;
    UPDTF21OTHR();
  EndIf;

End-Proc;


// Update Non PDF nd JSO options
Dcl-Proc UPDTF21OTHR;

  // Build a command to save the query
  cmd='SQL2XLS SQL(''' + %trim(#$DblQ(#$SQLSTM)) + ''') +
            FILE(''' + %trim(F21Path) + ''') +
            TYPE(' + %trim(F21ATTY) + ') +
            EMPTY(' + %trim(F21EMPTY) + ') +
            USETEXT(' + %trim(F21USEText) + ') +
            SHEET(''' + %trim(F21SHEET) + ''') +
            TITLE1(''' + %trim(F21TITL1) + ''') +
            TITLE2(''' + %trim(F21TITL2) + ''') +
            TITLE3(''' + %trim(F21TITL3) + ''') +
            TITLE4(''' + %trim(F21TITL4) + ''') +
            TITLE5(''' + %trim(F21TITL5) + ''')';

  #$Cmd(cmd:2);

End-Proc;


// Update F21 with JSON Option
Dcl-Proc UPDTF21JSON;

  // Build a command to save the query
  cmd='SQL2JSON SQL(''' + %trim(#$DblQ(#$SQLSTM)) + ''') +
            FILE(''' + %trim(F21Path) + ''') +
            EMPTY(' + %trim(F21EMPTY) + ') +
            USETEXT(' + %trim(F21USEText) + ') +
            TITLE1(''' + %trim(F21TITL1) + ''') +
            TITLE2(''' + %trim(F21TITL2) + ''') +
            TITLE3(''' + %trim(F21TITL3) + ''') +
            TITLE4(''' + %trim(F21TITL4) + ''') +
            TITLE5(''' + %trim(F21TITL5) + ''')';

  #$Cmd(cmd:2);

End-Proc;


// Update Screen F21 with PDF Option
Dcl-Proc UPDTF21PDF;

  // Override and hard code some of the print variables
  #date=%dec(%char(%date():*ISO0):8:0);
  #time=%dec(%char(%time():*hms0):6:0);

  #$OUTQ  = 'TRASH';
  #$OQLB  = 'QGPL';
  #$COPY  = 1;
  #$HOLD  = '*NO ';
  #$SAVE  = '*NO ';
  #$USDT  = 'SQL'+%trim(%char(#date));
  #$FRLN  = 66;
  #$FRWD  = 132;
  #$INVR  = '*NO ';
  #$INQY  = '*NO ';
  #$TITLE1 = F21TITL1;
  #$TITLE2 = F21TITL2;
  #$TITLE3 = F21TITL3;
  #$TITLE4 = F21TITL4;
  #$TITLE5 = F21TITL5;

  // Print the report
  SQLCMDB1(#$SQLSTM:
      #$VARS:
      #$OUTQ:
      #$OQLB:
      #$COPY:
      #$HOLD:
      #$SAVE:
      #$USDT:
      #$FRLN:
      #$FRWD:
      #$INVR:
      #$INQY:
      #$TITLE1:
      #$TITLE2:
      #$TITLE3:
      #$TITLE4:
      #$TITLE5:
      #$PNAME);

  // If the file name is blank build one
  If F21FILE=' ';
    F21FILE='SQL'+%trim(WSID) +
        %trim(%char(#date))+%trim(%char(#time));
  EndIf;

  // Convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMDO1) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
         %trim(F21Path) + ''') WSCST(*PDF)':2);

  // Delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMDO1) SPLNBR(*LAST)':2);

End-Proc;


// Process Screen F22;
Dcl-Proc PROCF22;

  MOVEF22();
  DoW not *INLR;

    Exfmt F22;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF22();
    If *in50;
      Iter;
    EndIf;

    UPDTF22();

    Leave;
  EndDo;

End-Proc;


// Load Screen F22
Dcl-Proc MOVEF22;

  Clear F22;

  // build text string
  F22TEXT = 'File ' + %trim(F21Path) +
      ' already exists. Use F12 to go back +
      and change the file name, enter +
      a Y below To replace the file or +
      enter a B To keep both files.';

  // wrap the string to not break lines on words
  F22TEXT=#$WORDWRAP(F22TEXT:80);

End-Proc;


// Validate Screen F22
Dcl-Proc VALDF22;

  // Validate the option
  If F22REPL<>'Y' AND F22REPL<>'N' AND
        F22REPL<>'B';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':50);
    Return;
  EndIf;

End-Proc;


// Update Screen F22
Dcl-Proc UPDTF22;

  // If replace is issued delete the existing file
  If F22REPL='Y';
    #$Cmd('DEL '''+%trim(F21Path)+'''':2);
  EndIf;

  // If keep both is selected, rename the path to include (xxx)
  If F22REPL='B';

    Version=0;
    DoW not *INLR;
      Version+=1;
      F21Path=%trim(F21FOLD) + '/' +
          %trim(F21FileNo) +
          ' (' + %trim(%editc(Version:'Z')) + ')' +
          %trim(F21Extn);
      If not #$VPATH(F21Path);
        ITER;
      Else;
        Leave;
      EndIf;
    EndDo;
  EndIf;

End-Proc;


// Process Screen F23
Dcl-Proc PROCF23;

  MOVEF23();
  DoW not *INLR;

    Exfmt F23;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // Fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    VALDF23();
    If *in50 or *in12 or *in03;
      Iter;
    EndIf;

    UPDTF23();
    If *in50;
      Iter;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen F23
Dcl-Proc MOVEF23;

  Clear F23;

End-Proc;


// Validate Screen F23
Dcl-Proc VALDF23;

  // Make sure the library is valid and exists
  If F23LIB=' ' OR not #$ISLIB(F23LIB);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
        LIBRARY.':50);
    Return;
  EndIf;

  // Validate that a file name is entered
  If F23FILE=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
        A FILE NAME.':50);
    Return;
  EndIf;

  // See if the file already exists
  If #$ISFILE(F23FILE:F23LIB);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THIS FILE ALREADY +
        EXISTS.':50);
    Return;
  EndIf;

End-Proc;


// Update Screen F23
Dcl-Proc UPDTF23;

  SQLSTMP2='CREATE TABLE ' + %trim(F23LIB) + '/' + %trim(F23FILE) +
          ' AS ('+%trim(#$SQLSTM) + ') WITH DATA';
  Exec SQL Execute Immediate :SQLSTMP2;
  If #$SQLSTT();
    *IN50 = *ON;
    ERM=#$Cntr(PSDSEXCDTA:50);
    Return;
  EndIf;

End-Proc;


// build lines array from a passed sql statement
Dcl-Proc BLDLINES;

  // run through the sql statement one word at a time and try to format it
  // into the lines array, basically add full words to a line and don't
  // break the words, also skips to new lines on keywords
  // (select,from,join,where,order by, group by, having)

  // indicator 71 is used for the select group, if in the select group
  // each variable after the first will be on its own line and spaced
  // over 7 characters

  // example input string
  // select nvfno as sku, nvpanm, nvcnam from inven where nvfno=2272301

  // example output
  // select nvfno as sku,
  //        nvpnam,
  //        nvcnam
  // from inven
  // where nvfno=2272301

  WORD=#$SPLIT2(sqlStm);
  Clear LINES;
  x=1;

  For i=1 To 1000;

    // Start select group
    If #$UPIFY(WORD(i))='SELECT';
      *IN71 = *ON;
    EndIf;

    // End select group
    If #$UPIFY(WORD(i))='FROM';
      *IN71 = *OFF;
    EndIf;

    // If the word does not fit on a line, automatically go to the next line
    If %len(%trim(WORD(i)))+1>
          78-%len(%trim(LINES(x)));
      x+=1;
      If *in71;
        LINES(x)='       ' + %trim(WORD(i));
      Else;
        LINES(x)=%trim(WORD(i));
      EndIf;
      ITER;
    EndIf;

    // If one of the split keywords start a new line
    If #$UPIFY(WORD(i))='SELECT' OR
          #$UPIFY(WORD(i))='FROM' OR
          (#$UPIFY(WORD(i))='JOIN'
          AND #$UPIFY(WORD(i-1))<>'LEFT'
          AND #$UPIFY(WORD(i-1))<>'INNER'
          AND #$UPIFY(WORD(i-1))<>'RIGHT'
          AND #$UPIFY(WORD(i-1))<>'OUTER'
          AND #$UPIFY(WORD(i-1))<>'FULL') OR
          #$UPIFY(WORD(i))='WHERE' OR
          #$UPIFY(WORD(i))='LEFT' OR
          #$UPIFY(WORD(i))='INNER' OR
          #$UPIFY(WORD(i))='RIGHT' OR
          #$UPIFY(WORD(i))='OUTER' OR
          #$UPIFY(WORD(i))='FULL' OR
          #$UPIFY(WORD(i))='ORDER' OR
          #$UPIFY(WORD(i))='GROUP' OR
          #$UPIFY(WORD(i))='HAVING';
      If LINES(x)<>' ';
        x+=1;
      EndIf;
      LINES(x)=%trim(WORD(i));
      ITER;
    EndIf;

    // Apend the word to the current line
    If *IN71 AND LINES(x)=' ';
      LINES(x)=%trimr(LINES(x)) + '       ' +
          %trim(WORD(i));
    Else;
      LINES(x)=%trimr(LINES(x)) + ' ' +
          %trim(WORD(i));
    EndIf;

    // If in a select group and the work ends with a , go to the next line
    If *IN71 AND #$LAST(WORD(i):1)=',';
      x+=1;
    EndIf;

  EndFor;

End-Proc;


// Split a String into an array
Dcl-Proc #$SPLIT2 export;
  Dcl-Pi #$SPLIT2 Char(100) dim(1000);
    DATA Char(8000) const;
  End-Pi;
  Dcl-S RETURNARRAY Char(100) dim(1000);
  Dcl-S STARTPOS int(10);
  Dcl-S FOUNDPOS int(10);
  Dcl-S INDEX int(5) Inz(1);

  If DATA <> *blanks;
    STARTPOS = 1;
    DoU FOUNDPOS = %len(%trim(DATA)) + 1;
      FOUNDPOS = %scan(' ':%trim(DATA):STARTPOS);
      If FOUNDPOS = 0;
        FOUNDPOS = %len(%trim(DATA)) + 1;
      EndIf;
      RETURNARRAY(INDEX) = %subst(%trim(DATA):STARTPOS:FOUNDPOS - STARTPOS);
      INDEX += 1;
      STARTPOS = FOUNDPOS + 1;
    EndDo;
  EndIf;

  Return RETURNARRAY;

End-Proc;

