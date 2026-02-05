**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB') Main(Main);

// Create a JSON file from an SQL Statement
// Command processing program for command SQL2JSON

Dcl-Ds dsColumnList Qualified dim(500);
  Heading Varchar(128);
  Column_Name Varchar(128);
  Column_Type Varchar(128);
  Label_Text Varchar(50);
  Length int(10);
  Precision int(10);
  Scale int(10);
  NULLABLE int(10);
  CCSID int(10);
End-Ds;

Dcl-S No_Columns int(5);
Dcl-S DataTypeCode Char(5);
Dcl-S Column_Name Varchar(128);
Dcl-S Column_Type Varchar(128);
Dcl-S Base_Column Varchar(128);
Dcl-S Base_Schema Varchar(128);
Dcl-S Base_Table Varchar(128);
Dcl-S Data_Type int(10);
Dcl-S Headings Varchar(60);
Dcl-S Label_Text Varchar(50);
Dcl-S Length int(10);
Dcl-S Scale int(10);
Dcl-S Precision int(10);
Dcl-S DateTimeInt int(10);
Dcl-S CCSID int(10);
Dcl-S NULLABLE int(10);
Dcl-S ERRMSG Varchar(500);
Dcl-S SQLCMD2 Char(5200);
Dcl-S rowAdded ind;
Dcl-S multipleQueries ind;

Dcl-Ds columns LikeDs(#$SQLColumns);

// Input parameters so they are global
Dcl-S SQLCmd Char(5000);
Dcl-S file Char(128);
Dcl-S empty Char(4);
Dcl-S readable Char(4);
Dcl-S UseText Char(4);
Dcl-S title1 Char(80);
Dcl-S title2 Char(80);
Dcl-S title3 Char(80);
Dcl-S title4 Char(80);
Dcl-S title5 Char(80);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/copy YAJL/QRPGLESRC,YAJL_H
/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command

Exec SQL Set Option Commit = *NONE;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('EMLSQLB3');
    pmrSQLCmd Char(5000);
    pmrFile Char(128);
    pmrEmpty Char(4);
    pmrReadable Char(4);
    pmrUseText Char(4);
    pmrTitle1 Char(80);
    pmrTitle2 Char(80);
    pmrTitle3 Char(80);
    pmrTitle4 Char(80);
    pmrTitle5 Char(80);
    pmrQueries likeds(queries) dim(300);
  End-Pi;
  Dcl-S i packed(5);

  // Move input paramaters to global variables
  SQLCmd =pmrSQLCmd;
  file = pmrFile;
  empty = pmrEmpty;
  readable = pmrReadable;
  UseText = pmrUseText;
  title1 = pmrTitle1;
  title2 = pmrTitle2;
  title3 = pmrTitle3;
  title4 = pmrTitle4;
  title5 = pmrTitle5;
  queries = pmrQueries;

  // if *none is passed in the title, clear it out1
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

  // if the file name does not have the correct extension, add it
  If #$UPIFY(#$LAST(file:5)) <> '.JSON';
    file=%trim(file)+'.json';
  EndIf;

  // indicator to see if any detail lines are added
  rowAdded = *OFF;

  // see if more than one query is passed
  multipleQueries = *off;
  For i = 1 To 300;
    If queries(i).sql <> '';
      multipleQueries = *on;
      Leave;
    EndIf;
  EndFor;

  // start json object
  If readable='*YES';
    yajl_genOpen(*ON);
  Else;
    yajl_genOpen(*OFF);
  EndIf;

  // if more than one query is passed we create an array of results with each set
  If multipleQueries;
    yajl_beginObj();
    yajl_beginArray('datasets');
  EndIf;

  // Add object for the primary query
  AddQuery(SQLCmd:title1:title2:title3:title4:title5);

  // Add objects for any additional queries
  For i = 1 To 300;
    If queries(i).sql <> '';
      AddQuery(queries(i).sql:queries(i).title1:queries(i).title2:queries(i).title3
              :queries(i).title4:queries(i).title5);
    EndIf;
  EndFor;

  // if more than one query is passed we have to open a new master object so each output query
  // is a child object under the master, this is required becasue YAJL will not create 2 master
  // objects in one JSON document.
  If multipleQueries;
    yajl_endArray();
    yajl_endObj();
  EndIf;

  // close the json file
  yajl_saveBuf(%trim(file):ERRMSG);

  // emtpy = *no and no detail lines added, delete the output file
  If empty='*NO' and not rowAdded;
    #$CMD('DEL ''' + %trim(file)+'''':1);
    #$SNDMSG('NO DETAIL RECORDS FOUND, FILE not CREATED.');
  Else;
    #$SNDMSG('FILE ''' + %trim(file) + ''' CREATED.');
  EndIf;

End-Proc;


// add a JSON object to the file for one query
Dcl-Proc AddQuery;
  Dcl-Pi *n;
    psSQL Char(5000);
    psTitle1 Char(80);
    psTitle2 Char(80);
    psTitle3 Char(80);
    psTitle4 Char(80);
    psTitle5 Char(80);
  End-Pi;

  // build column headers
  columns = #$SQLGetColumns(psSQL);

  yajl_beginObj();

  // add any titles that were passed
  If psTitle1<>' ';
    yajl_addChar('title_1':%trim(psTitle1));
  EndIf;
  If psTitle2<>' ';
    yajl_addChar('title_2':%trim(psTitle2));
  EndIf;
  If psTitle3<>' ';
    yajl_addChar('title_3':%trim(psTitle3));
  EndIf;
  If psTitle4<>' ';
    yajl_addChar('title_4':%trim(psTitle4));
  EndIf;
  If psTitle5<>' ';
    yajl_addChar('title_5':%trim(psTitle5));
  EndIf;

  yajl_beginArray('data');

  // prepare select, declare and open a cursor
  Exec SQL Prepare sqlStm From :psSQL;

  Exec SQL Declare SQLCRS Cursor For sqlStm;
  Exec SQL Open SQLCRS;

  // loop through the table and add each record to the excel file
  Monitor;
    Exec SQL Fetch Next From SQLCRS Into :MYDS :nulls;
  On-Error;
  EndMon;
  DoW SQLCODE = 0 or SQLCODE=326;
    addDetail();
    Monitor;
      Exec SQL Fetch Next From SQLCRS Into :MYDS :nulls;
    On-Error;
    EndMon;
  EndDo;

  // Close SQL cursor
  Exec SQL Close SQLCRS;

  yajl_endArray();
  yajl_endObj();

End-Proc;


// add a detail line to the json object
Dcl-Proc addDetail;
  Dcl-S i packed(5);

  rowAdded = *ON;

  yajl_beginObj();

  // add detail record
  For i=1 To columns.count;
    If columns.Col(i).Type ='DECFLOAT' or
          columns.Col(i).Type ='NUMERIC'  or
          columns.Col(i).Type ='DECIMAL'  or
          columns.Col(i).Type ='FLOAT'  or
          columns.Col(i).Type ='REAL'  or
          columns.Col(i).Type ='DOUBLE';
      If val(i)='.0' or val(i)='.00' or
            val(i)='.000' or val(i)='.0000' or
            val(i)='.00000' or val(i)='.000000';
        val(i)='0';
      EndIf;
      yajl_addNum(
          %trim(columns.Col(i).name):
          %trim(val(i)));
    Else;
      yajl_addChar(
          %trim(columns.Col(i).name):
          %trim(val(i)));
    EndIf;
  EndFor;

  yajl_endObj();

End-Proc;
