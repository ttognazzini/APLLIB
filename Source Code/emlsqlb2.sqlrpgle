**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB') Main(Main) ActGrp(*caller);

// Create a PC (Excel,CSV,XML) file from an SQL Statement

// Uses command SQL2XLS, also called from the SQL command which should be the only one used going fo

Dcl-S words Char(100) dim(10);
Dcl-S longestWord packed(9: 2);
Dcl-S width packed(9);
Dcl-S FreezeRows packed(2);
Dcl-S detailFound Ind;
Dcl-S sheetOpen Ind;

Dcl-Ds columns LikeDs(#$SQLColumns);

// Input parameters so they are global
Dcl-S SQLCmd Char(5000);
Dcl-S file Char(128);
Dcl-S fileType Char(5);
Dcl-S empty Char(4);
Dcl-S UseText Char(4);
Dcl-S sheet Char(32);
Dcl-S title1 Char(80);
Dcl-S title2 Char(80);
Dcl-S title3 Char(80);
Dcl-S title4 Char(80);
Dcl-S title5 Char(80);

/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command
/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,OUTFLEV1PR

// Retreive message
Dcl-Pr QMHRCVPM  EXTPGM('QMHRCVPM');
  MsgInfo        Char(8);
  MsgInfoLen     Int(10)    CONST;
  FormatName     Char(8)    CONST;
  CallStackEntr  Char(10)   CONST;
  CallStackCtr   Int(10)    CONST;
  MsgType        Char(10)   CONST;
  MsgKey         Char(4)    CONST;
  WaitTime       Int(10)    CONST;
  MsgAction      Char(10)   CONST;
  ErrorStruct               LIKE(ErrorCode);
End-Pr;

Dcl-S MsgInfo      Char(8);
Dcl-S ErrorCode    Char(8)    INZ(X'0000000000001000');

// This option turns off commitment control
Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('EMLSQLB2');
    pmrSQLCmd Char(5000);
    pmrFile Char(128);
    pmrFileType Char(5);
    pmrEmpty Char(4);
    pmrUseText Char(4);
    pmrSheet Char(32);
    pmrTitle1 Char(80);
    pmrTitle2 Char(80);
    pmrTitle3 Char(80);
    pmrTitle4 Char(80);
    pmrTitle5 Char(80);
    pmrQueries likeds(queries) dim(300) options(*nopass);
  End-Pi;
  Dcl-S i int(5);

  // Move input paramaters to global variables
  SQLCmd =pmrSQLCmd;
  file = pmrFile;
  fileType =pmrFileType;
  empty = pmrEmpty;
  UseText = pmrUseText;
  sheet = pmrSheet;
  title1 = pmrTitle1;
  title2 = pmrTitle2;
  title3 = pmrTitle3;
  title4 = pmrTitle4;
  title5 = pmrTitle5;
  If %parms() >= 12;
    queries = pmrQueries;
  Else;
    Clear queries;
  EndIf;


  // If a sheet name is not passed, make it sheet 1
  If sheet=' ' or sheet='*NO';
    sheet='SHEET1';
  EndIf;

  // If *none is passed in the title, clear it out1
  If title1='*NONE';
    title1=' ';
  EndIf;
  If title2='*NONE';
    title2=' ';
  EndIf;
  If title3='*NONE';
    title3=' ';
  EndIf;
  If title4='*NONE';
    title4=' ';
  EndIf;
  If title5='*NONE';
    title5=' ';
  EndIf;

  // If the file name does not have the correct extension, add it
  If fileType='*XML' AND #$UPIFY(#$LAST(file:4)) <> '.XML';
    file=%trim(file)+'.xml';
  EndIf;
  If fileType='*CSV' AND #$UPIFY(#$LAST(file:4)) <> '.CSV';
    file=%trim(file)+'.csv';
  EndIf;
  If fileType='*XLS' AND #$UPIFY(#$LAST(file:5)) <> '.XLSX';
    file=%trim(file)+'.xlsx';
  EndIf;

  // Start the excel file
  detailFound = *OFF;
  sheetOpen = *off;

  // Add object for the primary query
  AddQuery(SQLCmd:sheet:title1:title2:title3:title4:title5);

  // Add objects for any additional queries
  For i = 1 To 300;
    If queries(i).sql <> '';
      AddQuery(queries(i).sql:queries(i).TAB
              :queries(i).title1:queries(i).title2:queries(i).title3
              :queries(i).title4:queries(i).title5);
    EndIf;
  EndFor;

  // Close the file
  #$CloseOut();

  // Emtpy = *No and no detail lines added, delete the output file
  If empty='*NO' AND not detailFound;
    #$CMD('DEL ''' + %trim(file)+'''':1);
    #$SNDMSG('No detail records found, file not created.');
  Else;
    #$SNDMSG('File ''' + %trim(file) + ''' created.');
  EndIf;

End-Proc;


// Add a tab for a query
Dcl-Proc AddQuery;
  Dcl-Pi *n;
    psSQL Char(5000);
    psSheet char(32);
    psTitle1 Char(80);
    psTitle2 Char(80);
    psTitle3 Char(80);
    psTitle4 Char(80);
    psTitle5 Char(80);
  End-Pi;

  // Add column headers to the excel file
  AddHeaders(psSQL:psSheet:psTitle1:psTitle2:psTitle3:psTitle4:psTitle5);

  // Prepare select, declare and open a cursor
  Exec SQL Prepare sqlStm From :psSQL;

  Exec SQL Declare SQLCrs Cursor For sqlStm;
  Exec SQL Open SQLCrs;

  // Loop through the table and add each record to the excel file
  Monitor;
    Exec SQL Fetch Next From SQLCrs Into :MYDS :nulls;
  On-Error;
  EndMon;
  // this removes the MCH1210 escape message that is always sent
  QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':
                '*': *zero: '*ESCAPE': *blanks: *zero:
                '*REMOVE': ErrorCode);
  DoW SQLCode = 0 OR SQLCode=326;
    AddDetail();
    Monitor;
      Exec SQL Fetch Next From SQLCrs Into :MYDS :nulls;
    On-Error;
    EndMon;
    // this removes the MCH1210 escape message that is always sent
    QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':
                  '*': *zero: '*ESCAPE': *blanks: *zero:
                  '*REMOVE': ErrorCode);
  EndDo;

  // Close SQL cursor
  Exec SQL Close SQLCrs;

End-Proc;


// Add column headers to the excel file
Dcl-Proc AddHeaders;
  Dcl-Pi *n;
    psSQL Char(5000);
    psSheet Char(32);
    psTitle1 Char(80);
    psTitle2 Char(80);
    psTitle3 Char(80);
    psTitle4 Char(80);
    psTitle5 Char(80);
  End-Pi;
  Dcl-S i int(5);
  Dcl-S j int(5);

  columns = #$SQLGetColumns(psSQL);

  // Build the column width array
  For i=1 To columns.count;
    // Instead of using the column name width, it now uses the width of the
    // longest word in the column name. This way the header will wrap. This
    // next section breaks the column name to seperate words and finds the
    // longest word length
    If columns.col(i).text='';
      columns.col(i).text=columns.col(i).name;
    EndIf;
    words=#$SPLIT(columns.col(i).text);
    longestWord=0;
    For j = 1 To 10;
      If %len(%trim(words(j)))> longestWord;
        longestWord=%len(%trim(words(j)));
      EndIf;
    EndFor;
    // Add 15% percent to the longest word because the headers use a larger bolded font
    longestWord=#$RNDUP(longestWord*1.5);
    // Get column width, the greater of length or precision, precision must be checked for
    // packed field because the length is one half the size
    width=0;
    If columns.col(i).dec> longestWord;
      width=columns.col(i).dec;
    ElseIf columns.col(i).Len> longestWord;
      width=columns.col(i).Len;
    Else;
      width=longestWord;
    EndIf;
    // This tries to make the field one longer, this fixes a problem where Excel wraps if the text
    // is right on the border. It makes it 3 longer for titles because of the larger font.
    If i<=100;
      If width>longestWord;
        If width > 100;
          #$OutFWidths(i)=100;
        Else;
          #$OutFWidths(i)=width+1;
        EndIf;
      Else;
        #$OutFWidths(i)=longestWord+1;
      EndIf;
    EndIf;
  EndFor;

  // Get the number of title lines passed to calcualate the number of rows to freeze.
  FreezeRows=1;
  If psTitle1<>'' or psTitle2<>'' or psTitle3<>'' or psTitle4<>'' or psTitle5<>'';
    If psTitle1<>' ';
      FreezeRows+=1;
    EndIf;
    If psTitle2<>' ';
      FreezeRows+=1;
    EndIf;
    If psTitle3<>' ';
      FreezeRows+=1;
    EndIf;
    If psTitle4<>' ';
      FreezeRows+=1;
    EndIf;
    If psTitle5<>' ';
      FreezeRows+=1;
    EndIf;
    FreezeRows+=1;
  EndIf;

  // if the file is not open, open it which adds a new sheet, otherwise just add a new sheet
  If not sheetOpen;
    If fileType='*XML';
      #$OpenOut(file:'XML':#$OutFWidths:sheet:FreezeRows);
    ElseIf fileType='*CSV';
      #$OpenOut(file:'CSV':#$OutFWidths:sheet:FreezeRows);
    Else;
      #$OpenOut(file:'XLS':#$OutFWidths:sheet:FreezeRows);
    EndIf;
  Else;
    #$NewSheet(psSheet:#$OutFWidths:FreezeRows);
  EndIf;
  sheetOpen = *on;

  // If any titles are passed, add them to the file and skip a line
  If psTitle1<>'' or psTitle2<>'' or psTitle3<>'' or psTitle4<>'' or psTitle5<>'';
    If psTitle1<>' ';
      #$AddChar(%trim(psTitle1):'T');
      #$NextRec();
    EndIf;
    If psTitle2<>' ';
      #$AddChar(%trim(psTitle2):'B');
      #$NextRec();
    EndIf;
    If psTitle3<>' ';
      #$AddChar(%trim(psTitle3):'B');
      #$NextRec();
    EndIf;
    If psTitle4<>' ';
      #$AddChar(%trim(psTitle4):'B');
      #$NextRec();
    EndIf;
    If psTitle5<>' ';
      #$AddChar(%trim(psTitle5):'B');
      #$NextRec();
    EndIf;
    #$NextRec();
  EndIf;

  // Add column headers to the excel file
  For i=1 To columns.count;
    If #$IN(#$UPIFY(columns.col(i).TYPE):'DECFLOAT':'NUMERIC':'DECIMAL':'INTEGER':'SMALLINT'
          :'FLOAT':'REAL':'DOUBLE':'BIGINT');
      #$AddChar(columns.col(i).text:'HR');
    Else;
      #$AddChar(columns.col(i).text:'H');
    EndIf;
  EndFor;

End-Proc;


// Add a detail line to the excel file
Dcl-Proc AddDetail;
  Dcl-S i int(5);

  detailFound = *ON;

  // Add detail record
  #$NextRec();
  For i=1 To columns.count;
    If %len(%trim(val(i)))=10 AND #$TESTN(%subst(%trim(val(i)):1:4)) AND
       %subst(%trim(val(i)):5:1)='/' AND #$TESTN(%subst(%trim(val(i)):6:2)) AND
       %subst(%trim(val(i)):8:1)='/' AND #$TESTN(%subst(%trim(val(i)):9:2)) AND
       not #$VDAT(#$RVL(val(i)));
      #$AddDate(#$RVL(val(i)));
    ElseIf #$IN(#$UPIFY(columns.col(i).TYPE):'DECFLOAT':'NUMERIC':'DECIMAL':'INTEGER':'SMALLINT'
          :'FLOAT':'REAL':'DOUBLE':'BIGINT');
      If columns.col(i).Dec=2;
        #$AddNum2(#$RVL(val(i)));
      ElseIf columns.col(i).Dec=0;
        #$AddNum0(#$RVL(val(i)));
      Else;
        #$AddNum(#$RVL(val(i)));
      EndIf;
    Else;
      #$AddChar(val(i));
    EndIf;
  EndFor;

End-Proc;
