**free
Ctl-Opt NOMAIN Option(*NoDebugIO:*NoShowCpy:*SrcStmt);

// Service program for #$SQL functions

// If you add procedures to this source you need to update the binder language in QSRC/SQLCMDN1
// Do not change the order of these procedures, only add to the bottom. If you need to change
// parameters, all programs will have to be recompiled.

// To compile:
// CRTSQLRPGI OBJ(QTEMP/SQLCMDV1) SRCFILE(APLLIB/QSRC)
//            OBJTYPE(*MODULE) DBGVIEW(*SOURCE)
// CRTSRVPGM  SRVPGM(APLLIB/SQLCMDV1) MODULE(QTEMP/SQLCMDV1)
//            TEXT('SQL Command Functions') EXPORT(*SRCFILE)
//            STGMDL(*INHERIT) SRCFILE(QSRC) SRCMBR(SQLCMDN1)
// DLTMOD     MODULE(QTEMP/SQLCMDV1)

/copy QSRC,SQLCMDV1PR

// This option turns off commitment control
Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;

// #$PREVWORD - Returns the previous word in a string
Dcl-Proc #$PreviousWord Export;
  Dcl-Pi *n Char(10);
    string Varchar(500) const;
    position packed(3) Value;
  End-Pi;
  Dcl-S last packed(3);
  Dcl-S First packed(3);
  Dcl-S prevword Char(10);

  last=0;
  First=0;
  prevword='';

  // find first non-blank character before the start position
  For last = position DOWNTO 1;
    If %subst(string:last:1)<>' ';
      Leave;
    EndIf;
  EndFor;

  // if none are found leave
  If last = 0;
    Return '';
  EndIf;

  // find first blank position before the first non-blank position
  For First = last downto 1;
    If %subst(string:First:1)=' ';
      First+=1;
      Leave;
    EndIf;
  EndFor;

  // if the next blank is not found set first to the start
  If First = 0;
    First=1;
  EndIf;

  // substring out the first word
  prevword = %subst(string:First:last-First+1);

  Return prevword;

End-Proc;


// build lines array from a passed sql statement
Dcl-Proc #$FormatSQL Export;
  Dcl-Pi *n Char(250) Dim(1000);
    SQL Varchar(32000) const;
    psLineLength packed(3) Value options(*nopass);
  End-Pi;
  Dcl-S lineLength packed(3);
  Dcl-S currentIndent packed(3);
  Dcl-S indentLevel packed(3) dim(20);
  Dcl-S indentLevelType Char(30) dim(20);
  Dcl-S currentIndentLevel packed(3);
  Dcl-S currentPosition int(5);
  Dcl-S lines Char(250) Dim(1000);
  Dcl-S lineNumber int(5);
  Dcl-S linePosition int(5);
  Dcl-S word Varchar(250);
  Dcl-S i int(5);
  Dcl-S isKeyword ind;
  Dcl-S inBetween Ind;

  // If a line length is passed use it, otherwise use 78
  If %parms>=2 and %addr(psLineLength)<>*null;
    lineLength=psLineLength;
  EndIf;
  If lineLength=0;
    lineLength=78;
  EndIf;

  // Initialize work fields
  Clear lines;
  lineNumber=1;
  linePosition=1;
  Clear indentLevel;
  Clear indentLevelType;
  currentIndentLevel=0;
  currentIndent=0;
  currentPosition=1;
  inBetween=*off;

  // Run through the sql statement one word at a time and try to format it
  // into the lines array, basically add full words to a line and don't
  // break the words, also skips to new lines on keywords
  word=#$FormatSQLGetNextWord(SQL:currentPosition);
  DoW word<>'';

    // this logic is to that the first AND after a BETWEEN is not split to a new line
    If not inBetween and Upper(word)='BETWEEN';
      inBetween=*on;
    EndIf;

    // loop through each keyword and see if this word matches one of them
    If inBetween and Upper(word)='AND';
      inBetween=*off;
    Else;
      isKeyword=*off;
      For i = 1 To #$FormatSQLds.keywordCount;
        If Upper(word)=#$FormatSQLds.Keyword(i).word;
          isKeyword=*on;
          Leave;
        EndIf;
      EndFor;
    EndIf;

    // Handle break before
    If isKeyword and #$FormatSQLds.keyword(i).breakBefore='Y'
      and lines(lineNumber)<>'';
      lineNumber+=1;
    EndIf;

    // Return to a previous named indent level
    If isKeyword and #$FormatSQLds.keyword(i).returnToIndentLevel<>'';
      DoW currentIndentLevel>0;
        If indentLevelType(currentIndentLevel)=#$FormatSQLds.keyword(i).returnToIndentLevel;
          currentIndent=indentLevel(currentIndentLevel);
          If word=')';
            Clear indentLevel(currentIndentLevel);
            Clear indentLevelType(currentIndentLevel);
          EndIf;
          Leave;
        Else;
          Clear indentLevel(currentIndentLevel);
          Clear indentLevelType(currentIndentLevel);
          currentIndentLevel-=1;
        EndIf;
      EndDo;
    EndIf;

    // Handle indent before
    If isKeyword and #$FormatSQLds.keyword(i).indentBefore='D';
      currentIndent-=1;
    ElseIf isKeyword and #$FormatSQLds.keyword(i).indentBefore='I';
      currentIndent+=1;
    EndIf;

    // Set the current indent level if the keyword says to
    If isKeyword and #$FormatSQLds.keyword(i).newIndentLevel='Y';
      currentIndentLevel+=1;
      indentLevel(currentIndentLevel)=currentIndent;
      indentLevelType(currentIndentLevel)=Upper(word);
    EndIf;

    // if the word does not fit on a line, automatically go to the next line and set the indent
    If %len(word)+1>lineLength-%len(%trim(lines(lineNumber)));
      lineNumber+=1;
    EndIf;

    // If a new line set the indent level
    If lines(lineNumber)='';
      If currentIndent>0;
        linePosition=currentIndent*2;
      Else;
        linePosition=1;
      EndIf;
    EndIf;

    // Add the current word to the line
    If word=',';
      %subst(lines(lineNumber):linePosition-1:%len(word))=word;
      linePosition+=%len(word)+1;
    Else;
      %subst(lines(lineNumber):linePosition:%len(word))=word;
      linePosition+=%len(word)+1;
    EndIf;

    // Handle break after
    If isKeyword and #$FormatSQLds.keyword(i).breakAfter='Y';
      lineNumber+=1;
    EndIf;

    // Handle indent after
    If isKeyword and #$FormatSQLds.keyword(i).indentAfter='D';
      currentIndent-=1;
    ElseIf isKeyword and #$FormatSQLds.keyword(i).indentAfter='I';
      currentIndent+=1;
    EndIf;

    word=#$FormatSQLGetNextWord(SQL:currentPosition);
  EndDo;

  Return lines;
End-Proc;


// Get Next word from SQL Statement
Dcl-Proc #$FormatSQLGetNextWord;
  Dcl-Pi *n Varchar(250);
    SQL Varchar(32000) const;
    currentPosition int(5);
  End-Pi;
  Dcl-S word Varchar(250);
  Dcl-S i int(5);

  // if the rest of the line is blanks return blank
  If currentPosition >= %len(%trimr(SQL));
    Return '';
  EndIf;

  // if the current position is a blank, move it to the first non-blank
  DoW %subst(SQL:currentPosition:1)=' ';
    currentPosition+=1;
  EndDo;

  // if the rest of the line is blanks return blank
  If currentPosition >= %len(%trimr(SQL));
    Return '';
  EndIf;

  // first see if the next word is a keyword, this has to be done because
  // keywords are multiple words and have to be returned as one word
  For i = 1 To #$FormatSQLds.keywordCount;
    If Upper(%subst(SQL:currentPosition:#$FormatSQLds.keyword(i).length))=
       #$FormatSQLds.keyword(i).word and
       (
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)=' ' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)='(' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)=')' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)='=' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)='>' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)='<' or
         %subst(SQL:currentPosition+#$FormatSQLds.keyword(i).length:1)=','
       );
      word=%subst(SQL:currentPosition:#$FormatSQLds.keyword(i).length);
      currentPosition+=#$FormatSQLds.keyword(i).length;
      Return word;
    EndIf;
  EndFor;

  // if the next character is a ", search for the next one and return the quoted
  // string as a single word so it doesn't get split.
  If %subst(SQL:currentPosition:1) = '"';
    word+=%subst(SQL:currentPosition:1);
    currentPosition+=1;
    DoU %subst(SQL:currentPosition:1) = '"';
      word+=%subst(SQL:currentPosition:1);
      currentPosition+=1;
    EndDo;
    word+=%subst(SQL:currentPosition:1);
    currentPosition+=1;
    Return word;
  EndIf;

  // if the next character is a ', search for the next one and return the quoted
  // string as a single word so it doesn't get split.
  If %subst(SQL:currentPosition:1) = '''';
    word+=%subst(SQL:currentPosition:1);
    currentPosition+=1;
    DoU %subst(SQL:currentPosition:1) = '''';
      word+=%subst(SQL:currentPosition:1);
      currentPosition+=1;
    EndDo;
    word+=%subst(SQL:currentPosition:1);
    currentPosition+=1;
    Return word;
  EndIf;

  // Hand duplicate comparisons, they need to be returned as one word even though
  // each character is a break character
  If %subst(SQL:currentPosition:2)='<>'
  or %subst(SQL:currentPosition:2)='<='
  or %subst(SQL:currentPosition:2)='>=';
    word = %subst(SQL:currentPosition:2);
    currentPosition+=2;
  Else;

    // start pulling the word until a break character is reached
    word='';
    DoU %subst(SQL:currentPosition:1) = ' ' or
      %subst(SQL:currentPosition:1) = ',' or
      %subst(SQL:currentPosition:1) = '(' or
      %subst(SQL:currentPosition:1) = ')' or
      %subst(SQL:currentPosition:1) = '=' or
      %subst(SQL:currentPosition:1) = '<' or
      %subst(SQL:currentPosition:1) = '>' or
      %subst(SQL:currentPosition:1) = '"' or
      %subst(SQL:currentPosition:1) = '''';
      word+=%subst(SQL:currentPosition:1);
      currentPosition+=1;
    EndDo;
  EndIf;

  Return word;

End-Proc;

// build columns array
Dcl-Proc #$SQLGetColumns Export;
  Dcl-Pi *n likeDs(#$SQLColumns);
    SQL Varchar(32000) const;
  End-Pi;
  Dcl-Ds columns LikeDs(#$SQLColumns);
  Dcl-S Count int(5);
  Dcl-S sqlStm Varchar(32000);
  Dcl-S i Int(5);
  Dcl-S j int(5);
  Dcl-S DataTypeCode Char(5);
  Dcl-S Column_Name Varchar(128);
  Dcl-S Column_Type Varchar(128);
  Dcl-S Base_Column Varchar(128);
  Dcl-S Base_Schema Varchar(128);
  Dcl-S Base_Table Varchar(128);
  Dcl-S Name Varchar(128);
  Dcl-S Data_Type Int(10);
  Dcl-S Length int(10);
  Dcl-S Scale int(10);
  Dcl-S Precision int(10);
  Dcl-S DateTimeInt int(10);
  Dcl-S CCSID int(10);
  Dcl-S nullable int(10);
  Dcl-S Headings char(64);
  Dcl-S Label_Text Varchar(50);
  Dcl-S Temp10 packed(5);
  Dcl-S Temp11 packed(5);

  // used to shift the heading left 1 space to line up
  // with numeric columns that can have a negative sign
  Dcl-S leftShift packed(1);

  // delete temp file if it exists
  Exec SQL Drop Table Qtemp/WorkTable;

  // create a temp file in qtemp
  // sqlStm='CREATE TABLE QTEMP/WORKTABLE AS ('+%trim(SQL)+') DEFINITION ONLY';
  // Exec SQL Execute Immediate :sqlStm;
  // #$SQLSTT();

  Clear columns;

  // sqlStm='SELECT * FROM QTEMP/WORKTABLE';
  sqlStm=SQL;
  Exec SQL Prepare sqlStm From :sqlStm;
  #$SQLSTT();

  // Allocate descriptor (set aside memory for DESCRIBE to use)
  Exec SQL Allocate SQL Descriptor 'COLUMNS' With MAX 5000;
  #$SQLSTT();

  // Collect metadata from prepared query statement and place the result in the descriptor
  Exec SQL Describe sqlStm Using SQL Descriptor 'COLUMNS';
  #$SQLSTT();
  Exec SQL Get SQL Descriptor 'COLUMNS' :Count=Count;
  #$SQLSTT();

  // Limit the columns to 900
  If Count>900;
    Count=900;
  EndIf;
  columns.Count=Count;

  // Get information from each column returned
  For i=1 To Count;
    Exec SQL
      Get SQL Descriptor 'COLUMNS'
      Value :i :Headings=DB2_LABEL,
      :Column_Name=DB2_COLUMN_NAME,
      :Base_Column=DB2_BASE_COLUMN_NAME,
      :Base_Schema=DB2_BASE_SCHEMA_NAME,
      :Base_Table =DB2_BASE_TABLE_NAME,
      :Name       =NAME,
      :Length     =LENGTH,
      :Data_Type  =TYPE,
      :Scale      =SCALE,
      :Precision  =PRECISION,
      :nullable   =NULLABLE,
      :DateTimeInt=DATETIME_INTERVAL_CODE,
      :CCSID      =DB2_CCSID;

    If DateTimeInt=1;
      Column_Type='DATE';
    ElseIf DateTimeInt=2;
      Column_Type='TIME';
    ElseIf DateTimeInt=3;
      Column_Type='TIMESTAMP';
    Else;
      j=*Zero;
      DataTypeCode=%char(Data_Type);
      j=%lookup(DataTypeCode:SQLDataCodes);
      If j>*Zero;
        Column_Type=%trimr(SQLDataTypes(j));
      Else;
        Column_Type='UDT';
      EndIf;
    EndIf;
    If Base_Column>' ' and Column_Name = '';
      Exec SQL
      Select RTrim(Coalesce( +
        Cast(LabelText as Varchar(32)),:Column_Name))
        Into :Label_Text
          From SysColumns
          Where Table_Name=:Base_Table
            and Table_Schema=:Base_Schema
          and Column_Name=:Base_Column;
    Else;
      Label_Text=Column_Name;
    EndIf;
    columns.col(i).Name=%trimr(Column_Name);
    If columns.col(i).Name = '';
      columns.col(i).Name = 'Col ' + %char(i);
      Headings = 'Col ' + %char(i);
    EndIf;
    If Headings = '';
      Headings = Label_Text;
    EndIf;
    // Remove double spaces in headings, this happens if the file has multiple colhdr entries
    DoW %scan('  ':%trim(Headings))<>0;
      Headings=%scanrpl('  ':' ':%trim(Headings));
    EndDo;
    columns.col(i).type=Column_Type;
    columns.col(i).text=%trimr(Label_Text);
    If precision<>0;
      columns.col(i).len=Precision;
    Else;
      columns.col(i).len=Length;
    EndIf;
    columns.col(i).dec=Scale;
    columns.col(i).Scale=Scale;
    columns.col(i).nullable=nullable;
    columns.col(i).CCSID=CCSID;
    If scale<>0;
      If scale>10;
        Length=Length-Scale+10;
      EndIf;
      Length=Length+1;
    EndIf;
    leftShift = 0;
    If columns.col(i).type='TIMESTAMP';
      columns.col(i).colwidth=26;
    ElseIf columns.col(i).type='DATE' OR columns.col(i).type='TIME';
      columns.col(i).colwidth=10;
    Else;
      columns.col(i).colwidth=columns.col(i).len;
      // if signed numeric add 1 for a negative sign
      If columns.col(i).TYPE='DECFLOAT' or
         columns.col(i).TYPE='NUMERIC' or
         columns.col(i).TYPE='DECIMAL' or
         columns.col(i).TYPE='INTEGER' or
         columns.col(i).TYPE='SMALLINT' or
         columns.col(i).TYPE='FLOAT' or
         columns.col(i).TYPE='REAL' or
         columns.col(i).TYPE='DOUBLE' or
         columns.col(i).TYPE='BIGINT';
        columns.col(i).colwidth+=1;
        // if has a sign, the colum header eneds to be one space to the left,
        // so the column header lines up to the number without the negative sign.
        leftShift = 1;
        // if there are decimal positions, add 1 for the decimal point.
        If columns.col(i).dec<>0;
          columns.col(i).colwidth+=1;
        EndIf;
      EndIf;
    EndIf;
    If %len(%trim(Headings)) > columns.col(i).colwidth;
      columns.col(i).colwidth=%len(%trim(Headings));
    EndIf;
    If columns.headerWidth>0;
      columns.col(i).offset=columns.headerWidth+2;
    Else;
      columns.col(i).offset=1;
    EndIf;
    columns.headerwidth+=columns.col(i).colwidth + 2;
    // Build column header string, right justify if numeric
    If precision<>0 and columns.col(i).colwidth>%len(%trimr(Headings));
      Temp10=columns.col(i).colwidth - %len(%trim(Headings)) + 1;
      Temp11=%len(%trim(Headings));
      %subst(Headings:Temp10:Temp11) = %trim(Headings);
      %subst(Headings:1:Temp10-1) = ' ';
    EndIf;
    If leftShift = 1 and %subst(Headings:1:1) = ' ';
      Headings = %subst(Headings:2);
    EndIf;
    %subst(columns.headers:columns.col(i).offset:columns.col(i).colwidth)
      = %trimr(Headings);
  EndFor;

  // Cleanup descriptor area
  Exec SQL Deallocate Descriptor 'COLUMNS';

  // Build ruller line
  For i=1 to columns.headerwidth;
    If %rem(i:10)=1 or %rem(i:10)=2 or %rem(i:10)=3 or %rem(i:10)=4;
      columns.ruler=%trim(columns.ruler)+'.';
    ElseIf %rem(i:10)=5;
      columns.ruler=%trim(columns.ruler)+'+';
    ElseIf i<98 and (%rem(i:10)=6 or %rem(i:10)=7 or %rem(i:10)=8 or%rem(i:10)=9);
      columns.ruler=%trim(columns.ruler)+'.';
    ElseIf i<98 and %rem(i:10)=0;
      columns.ruler=%trim(columns.ruler)+%char(%div(i:10));
    ElseIf i<998 and (%rem(i:10)=6 or %rem(i:10)=7 or %rem(i:10)=8);
      columns.ruler=%trim(columns.ruler)+'.';
    ElseIf i<998 and %rem(i:10)=9;
      columns.ruler=%trim(columns.ruler)+%char(%div(i+1:10));
    ElseIf i<9998 and (%rem(i:10)=6 or %rem(i:10)=7);
      columns.ruler=%trim(columns.ruler)+'.';
    ElseIf i<9998 and %rem(i:10)=8;
      columns.ruler=%trim(columns.ruler)+%char(%div(i+2:10));
    EndIf;
  EndFor;

  Return columns;

End-Proc;


// Upper - Convert to all upper case
Dcl-Proc Upper;
  Dcl-Pi *n varchar(32767);
    data varchar(32767) const options(*varsize);
  End-Pi;
  Dcl-C ENGLOW 'abcdefghijklmnopqrstuvwxyz';
  Dcl-C ENGUP 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Return %xlate(ENGLOW:ENGUP:data);
End-Proc;


// #$SQLSTT checks the last SQL statement for an error. It
// returns *ON if an error occured or an end of file is reached,
// otherwise it returns off. If an error occures it throws an
// escape message by default so it can be monitored for in a
// monitor group or allowed to crash if it is not monitored for.
//
// Use this after an SQL statment like this:
// EXEC SQL SELECT * FROM XYZ;
// #$SQLSTT();
//
// Or use it to loop through fetch statements like this:
// EXEC SQL FECTH ...
// DOW NOT #$SQLSTT();
//    // DO SOMETHING HERE
//    EXEC SQL FECTH ...
// ENDDO;
//
//  INPUT: SQLSTT  = Optional, pass the SQLSTT variable.
//         MSGTYPE = Optional, pass a 1 to send a diagnostic
//                   message instead of an escape message.
//                   Default is 0 for an escape message.
// RETURN:         = *ON if an error or EOF occures
//
Dcl-Proc #$SQLSTT;
  Dcl-Pi *n ind;
    PSSQLSTT char(5) const options(*nopass : *omit);
    PSTYPE zoned(1) const options(*nopass : *omit);
  End-Pi;

  // PROTOTYPE FOR ERROR DATA STRUCTURE
  Dcl-Ds ERRORCODE;
    BYTESPROV int(10) inz(0);
    BYTESAVAIL int(10) inz(0);
  End-Ds;

  // PROTOTYPE TO SEND MESSAGE
  Dcl-Pr QMHSNDPM extpgm('QMHSNDPM');
    *n char(7) const; // MESSAGEID
    *n char(20) const; // QUALMSGF
    *n char(256) const; // MSGDATA
    *n int(10) const; // MSGDTALEN
    *n char(10) const; // MSGTYPE
    *n char(10) const; // CALLSTKENT
    *n int(10) const; // CALLSTKCNT
    *n char(4); // MESSAGEKEY
    *n likeds(ERRORCODE); // ERRCODE
  End-Pr;

  // STAND ALONE VARIABLES
  Dcl-S STATE char(5);
  Dcl-S MSGTEXT char(256);
  Dcl-S TYPE zoned(1) inz(0);
  Dcl-S MSGTYPE char(10) inz(*blanks);
  Dcl-S MSGKEY char(4);
  Dcl-S ERROR ind inz(*on);

  // GET THE LAST SQLSTT AND MESSAGE TEXT
  Exec SQL
    GET DIAGNOSTICS CONDITION 1
    :MSGTEXT = MESSAGE_TEXT,
    :STATE = RETURNED_SQLSTATE;

  // OVERRIDE THE STATE IF IT WAS PASSED
  If %parms() > 1;
    STATE = PSSQLSTT;
  EndIf;

  Select;
      // NO ERROR
    When %subst(STATE:1:2) = '00';
      ERROR = *OFF;
      // ERROR, COMMAND NOT PROCEESED
    When %subst(STATE:1:2) = '02';
      ERROR = *ON;
      // WARNING, COMMAND PROCESSED
    When %subst(STATE:1:2) = '01';
      MSGTYPE = '*DIAG';
      ERROR = *OFF;
    OTHER;
      MSGTYPE = '*ESCAPE';
      ERROR = *ON;
  ENDSL;

  // SEND MESSAGE IF SELECTED
  If MSGTYPE <> *BLANKS;
    QMHSNDPM( 'CPF9897'
    : 'QCPFMSG   *LIBL'
    : %trim(MSGTEXT)
      : %len(%trim(MSGTEXT))
      : MSGTYPE
      : '*'
      : 1
      : MSGKEY
      : ERRORCODE );
  EndIf;
  Return ERROR;

End-Proc;
