**FREE
// This program was set up to test automaing moving data into MS SQL
// The program is passed 2 parameter, the name of a table or view and the library it is in
// It will then create a table in the MS SQL database with the same name and columns
// Then it inserts all the data into that table from the passed table
// If the table already exists, it is deleted first and rebuilt
// If a comment exists at the field or table level, it is added to the MS SQL DB as well.

// Example Calls:
// CALL JDBMSQB3 (CGROUPS ARRLIB)
//   This just creates and populates customer groups file. Since this is a DDS file
//   column names are replaced with an augmented version of the column text.
//   Specail characters and spaces are replaced with an underscore. If the
//   the column name stars with a number, then an underscore is added as the first character.
// CALL JDBMSQB3 (ACPTRM ERPLIB)
//   This creates and populates the A/P terms file in the MS SQL database, one benefit
//   of using a new type file is better column names, since that system supports
//   long column names.
// CALL JDBMSQB3 (VNDDTAB2VW DTAMDL)
//   This is an example using view, this view is the flattened vendor file from the
//   data modeling project. since the view uses human readable column names, specail
//   characters and spcaes in column names are replaced with an underscore. If the
//   the column name stars with a number, then an underscore is added as the first character

Ctl-Opt DftActGrp(*No) BndDir('APLLIB/APLLIB') Option(*Srcstmt) DatFmt(*ISO) Main(Main) debug actgrp(*new);

/copy QSRC,JDBSRVV1PR // Scott Klements JDBCR4 service program headers
/copy QSRC,JDBMSQB1PR // Set up Java environment for MS SQL, also contains MS SQL connection stuff
/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,SQLCMDV1PR // borrowing the DS to read a bunch of columns into from here

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
  ErrorStruct    LIKE(ErrorCode);
End-Pr;
Dcl-S MsgInfo      Char(8);
Dcl-S ErrorCode    Char(8)    INZ(X'0000000000001000');

// Globals for program paramteres
Dcl-S tblNme varchar(10);
Dcl-S libNme varchar(10);
Dcl-S newTblNme varchar(128);

// Program variable definitions
Dcl-S sqlStm Varchar(32000);
Dcl-S dtlStm Varchar(1000);
Dcl-S nbrCols packed(5);
Dcl-S columns varchar(10000);
Dcl-S colTyp char(10) dim(900);

Dcl-S password varchar(127);

// Escape message type, change to *INFO to keep going, otherwise *ESCAPE to blow up
// Dcl-C msgTyp msgTyp;
Dcl-C MSGTYP '*INFO';

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('JDBMSQB3');
    pmrTblNme char(10) options(*nopass);
    pmrLibNme char(10) options(*nopass);
    pmrNewTblNme char(128) options(*nopass);
  End-Pi;

  // populate passed table or use default for testing
  If %parms() >= 1 and %addr(pmrTblNme) <> *null;
    tblNme = %trim(pmrTblNme);
  Else;
    tblNme = 'ACPCMP';
  EndIf;

  // populate passed library or use default for testing
  If %parms() >= 1 and %addr(pmrTblNme) <> *null;
    libNme = %trim(pmrLibNme);
  Else;
    libNme = 'APLLIB';
  EndIf;

  // populate passed table name or use default
  If %parms() >= 3 and %addr(pmrTblNme) <> *null and pmrNewTblNme = '*TABLE';
    // get the table name from the system metadata
    Clear newTblNme;
    Exec SQL
      Select lower(table_name)
      Into :newTblNme
      From systables
      Where system_table_schema = :libNme
        and system_table_name = :tblNme;
    If newTblNme = '';
      newTblNme = tblNme;
    EndIf;
  ElseIf %parms() >= 3 and %addr(pmrTblNme) <> *null;
    newTblNme = %trim(pmrNewTblNme);
    // If the new table name contains a null, trim eveything after it
    If %scan(x'00':newTblNme) <> 0;
      %subst(newTblNme:%scan(x'00':newTblNme)) = *blank;
    EndIf;
  Else;
    newTblNme = tblNme;
  EndIf;
  newTblNme = %trim(newTblNme);

  // Setup the Java environment for MS SQL
  JDBMSQB1();

  // Try to connect to MS SQL,
  If not connectDB();
    #$SNDMSG('Error - Could not connect to MS SQL Database':'*ESCAPE');
    Return;
  EndIf;

  // Create a table
  If CreateTable();
    // Add data to table
    WriteRows();
  EndIf;

  // close the JDBC connection
  JDBC_Close(conn);

End-Proc;


// Connect to the database
Dcl-Proc connectDB;
  Dcl-Pi *n Ind;
  End-Pi;

  conn = JDBC_Connect( 'com.microsoft.sqlserver.jdbc.SQLServerDriver' : %trim(url) : %trim(UserId) : %trim(Passwrd));

  If conn  = *null;
    Return *off;
  Else;
    Return *on;
  EndIf;

End-Proc;


// Create new table
Dcl-Proc CreateTable;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S colNme varchar(100);
  Dcl-S colType char(10);
  Dcl-S fldStr varchar(200);
  Dcl-S lngCmt varchar(2000);

  // Delete the table first, ignore error if it doesn't exist
  sqlStm = 'Drop Table ' + newTblNme;
  If JDBC_ExecUpd( conn : sqlStm ) >= 0;
    #$SNDMSG('MS SQL database table ' + newTblNme + ' deleted.');
  EndIf;

  // Start SQL statement for the table
  sqlStm = 'Create Table ' + newTblNme + ' (';
  #$SNDMSG('Sql Statement for MS SQL table:');
  #$SNDMSG('  ' + sqlStm);

  Clear nbrCols;
  Clear columns;
  Clear colTyp;

  // Get row and column infomration for the table,
  // add each column to the new create table statement
  Exec SQL Declare sqlCrs Cursor For
    With dta as (
        Select
          table_schema,
          table_name,
          ordinal_position,
          system_column_name,
          -- This case statement does the column name magic.
          --   First it sees if the column name is the same as the system column name,
          --   if so it will use the column text instead.
          --   Then for either the column text or the column name it does these:
          --     if the text starts with a number, it addes an underscore,
          --     it replaces spaces, slashes, single and double quotes with an underscore */
          REPLACE(REPLACE(REPLACE(
            case when right(column_name,1) not in ('1','2','3','4','5','6','7','8','9','0')
                 then column_name
                 when column_name = system_column_name and column_text is not null
                 then case when left(trim(char(column_text)),1) in ('1','2','3','4','5','6','7','8','9','0')
                      then '_' || translate(trim(char(column_text)),'_____',' /\''"')
                      else translate(trim(char(column_text)),'_____',' /\''"') end
            else case when left(column_name,1) in ('1','2','3','4','5','6','7','8','9','0')
                      then '_' || translate(column_name,'_____',' /\''"')
                      else translate(column_name,'_____',' /\''"') end
            end
          ,';',''),':',''),'-','') column_name,
          scale,
          length,
          /* if the colun type is TIMESTMP, change it to DATETIME2, this is MS SQL version
             of a data/time field */
          Case when data_type = 'TIMESTMP' then 'DATETIME2'
              else data_type end data_type,
          coalesce(char(long_comment),'') long_comment
        from QSYS2.syscolumns2
        Where system_table_schema = :libNme
          and system_table_name = :tblNme
      )
    Select
      trim(lower(column_name)),
      data_type,
      /* This section builds the SQL code requried to create a column from the
         information in the CTE. It is formatted in the standard SQL format for
         a create table statement */
      trim(lower(column_name)) || ' ' ||
      Case When data_type in ('BIGINT','INTEGER','DATE','TIME','DATETIME2') -- these types do not use a size
           Then trim(lower(data_type))
           When scale is not null and scale <> 0 -- if there is a scale, use it
           Then trim(lower(data_type)) || '(' || trim(char(length)) || ',' || trim(char(scale)) || ')'
           Else trim(lower(data_type)) || '(' || trim(char(length)) || ')'
      end
      || ',',
      long_comment
    from dta
    Order by ordinal_position;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next from sqlCrs into :colNme,:colType,:fldStr,:lngCmt;
  DoW sqlState < '02';
    // Add the column to the create table statement
    #$SNDMSG('    ' + fldStr);
    sqlStm += ' ' + fldStr;
    // get number of columns and a list of the columns for the insert
    nbrCols += 1;
    If nbrCols <> 1;
      columns += ',';
    EndIf;
    columns += %trim(colNme);
    colTyp(nbrCols) = colType;
    Exec SQL Fetch Next from sqlCrs into :colNme,:colType,:fldStr,:lngCmt;
  EndDo;
  Exec SQL Close sqlCrs;

  // Remove the last , There is one after the last row that should not be there
  sqlStm = %subst(sqlStm:1:%len(sqlStm)-1);

  // End SQL statement for the table
  sqlStm += ')';
  #$SNDMSG('  )');

  // Try to build the table in the MS SQL database
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not create table ' + newTblNme + '.':MSGTYP);
    dump;
    Return *off;
  Else;
    #$SNDMSG('Table ' + newTblNme + ' created.');
    Return *on;
  EndIf;

  // See if there is a long comment on the table, if so, add it to the MS SQL DB
  Clear lngCmt;
  Exec SQL
    Select coalesce(char(long_comment),'')
    Into :lngCmt
    From SYSTABLES
    Where table_schema = :libNme
      and table_name = :tblNme;
  If lngCmt <> '';
    sqlStm = 'Comment on Table ' + newTblNme + ' is ''' + lngCmt +'''';
    If JDBC_ExecUpd( conn : sqlStm ) < 0;
      #$SNDMSG('Error - Long table comment not added, sqlStm = "' + sqlStm + '".');
    EndIf;
  EndIf;

  // using the same statement above, try to add long comments to the columns in the MS SQL DB
  // This has done after the table is created so it cannot be in the loop above.
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next from sqlCrs into :colNme,:colType,:fldStr,:lngCmt;
  DoW sqlState < '02';
    If lngCmt <> '';
      sqlStm = 'Comment on Column ' + newTblNme + '.' + colNme + ' is ''' + lngCmt +'''';
      If JDBC_ExecUpd( conn : sqlStm ) < 0;
        #$SNDMSG('Error - Long column comment not added, sqlStm = "' + sqlStm + '".');
      EndIf;
    EndIf;
    Exec SQL Fetch Next from sqlCrs into :colNme,:colType,:fldStr,:lngCmt;
  EndDo;
  Exec SQL Close sqlCrs;


End-Proc;


// Add data to the table
Dcl-Proc WriteRows;
  Dcl-S i packed(5);
  Dcl-S rowsExist Ind;

  // this adds rows to the table in batches. The batches are based on the size the
  // SQL variable. It is a lot quicker to add many rows at once then add each row
  // individually. So the SQL statment is started here, and then each row ais appended
  // till the length is over 30,000. Then it runs the statement and starts a new one.
  sqlStm = 'Insert into ' + newTblNme + ' ('+ columns + ')' + ' values';
  rowsExist = *off;

  // Fetch all rows from the table
  dtlStm = 'Select * From ' + libNme + '/' + tblNme;
  Exec SQL Prepare dtlStm from :dtlStm;
  Exec SQL Declare dtaCrs cursor for dtlStm;
  Exec SQL Open dtaCrs;
  Monitor;
    Exec SQL Fetch Next From dtaCrs Into :MYDS :nulls;
  On-Error;
  EndMon;
  // this removes the MCH1210 escape message that is always sent
  QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
  DoW sqlState < '02';
    // add one row to the statement
    sqlStm += '(';
    For i = 1 to nbrCols;
      If i <> 1;
        sqlStm += ',';
      EndIf;
      If colTyp(i) = 'DATETIME2';
        sqlStm += '''' + CvtTimeStamp(val(i)) + '''';
      ElseIf nulls(i) < 0;
        sqlStm += 'null';
      Else;
        sqlStm += '''' + #$DBLQ(%trim(val(i))) + '''';
      EndIf;
    EndFor;
    sqlStm += '),';
    rowsExist = *on;
    // if the length of the statment is over 9,000, remove the last comma, run the statmen and start a new one
    If %len(sqlStm) > 30000;
      sqlStm = %subst(sqlStm:1:%len(sqlStm)-1); // remove the last comma
      If JDBC_ExecUpd( conn : sqlStm ) < 0;
        #$SNDMSG('Error - Could not insert data, sqlStm: "'+ sqlStm+ '".');
        dump;
      Else;
        #$SNDMSG('Rows inserted, sqlStm: "'+ sqlStm+ '".');
      EndIf;
      sqlStm = 'Insert into ' + newTblNme + ' ('+ columns + ')' + ' values';
      rowsExist = *off;
    EndIf;
    Monitor;
      Exec SQL Fetch Next From dtaCrs Into :MYDS :nulls;
    On-Error;
    EndMon;
    // this removes the MCH1210 escape message that is always sent
    QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
  EndDo;
  Exec SQL Close dtaCrs;

  // Add the last rows
  If rowsExist;
    sqlStm = %subst(sqlStm:1:%len(sqlStm)-1); // remove the last comma
    If JDBC_ExecUpd( conn : sqlStm ) < 0;
      #$SNDMSG('Error - Could not insert data, sqlStm: "'+ sqlStm+ '".');
      dump;
    Else;
      #$SNDMSG('Rows inserted, sqlStm: "'+ sqlStm+ '".');
    EndIf;
  EndIf;


End-Proc;


Dcl-Proc CvtTimeStamp;
  Dcl-Pi *n varchar(100);
    input varchar(1000) const;
  End-Pi;

  //                               1234567890123456789012345689             1234567890123456789012345689
  // timestampformat in MS SQL is '2004-10-19 10:23:54.0000000', in DB2 is '2024-03-28-10.10.33.3358214',
  // so if timestamp we have to remove the third dash, and change the periods to colons
  // Ruller  123456789012345678901234567890
  // input  '2024-03-28-10.10.33.3358214'
  // output '2004-10-19 10:23:54.3358214'
  Return %subst(input:1:10) + ' '
       + %subst(input:12:2) + ':'
       + %subst(input:15:2) + ':'
       + %subst(input:18:2) + '.'
       + %subst(input:21:7);

End-Proc;
