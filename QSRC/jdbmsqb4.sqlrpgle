**FREE
// This program was set up to test doing incremental updates to tables on the
// MS SQL server.

// This program requires the table to already be built on the MS SQL server.
// The columnnames on the MS SQL server must match the column names in the DB2
// table. Only columns in the sQL server will be imported, ifnot columns are
// added to the DB2 table this will still work, but the new columns will not
// be created or moved over.

// The table must have a unique primary key, perferably an identity column.
// It also needs a last maintained time stamp, preferable updated by the data
// base, not programatically.

// The program does not handle delete rows. An occasional full resynce should
// should resolve this. Also rows should be flagged in-active, not deleted,
// which will be handled by this program.

// Thius program needs the table name, the unqiue key field and the maintenance
// timestamp field to function. If a maintenance timestmap field is not
// included, the program will only add new rows, not update changed rows.

// It is suggested to the MOVTBL command to create the table on the MS SQL
// server. The smae command can be used to do a full recreate of the table
// and data. The MOVTBL command drops the table on the MS SQL server, recreates
// it to mathc the DB2 table and reloads all data into it.

// This progam also uses dynamic column lists. It pulls the list of columns from
// the MS SQL database and only populates those columns. If a column is added to
// one of the tables it will still update all the other columns until the
// nightly refresh is done. At that point all new columns will be added and
// populated.

Ctl-Opt DftActGrp(*No) BndDir('APLLIB/APLLIB') Option(*Srcstmt:*nounref) DatFmt(*ISO) Main(Main) debug actgrp(*new);

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
Dcl-S rs        like(ResultSet);
Dcl-S rsmd      like(ResultSetMetaData);
Dcl-S sqlStm    Varchar(32000);
Dcl-S addStm    Varchar(12000);
Dcl-S updStm    Varchar(12000);
Dcl-S columns   Varchar(10000);
Dcl-S nbrCols   packed(5);
Dcl-S colTyp    char(10) dim(900);
Dcl-S i         packed(5);
Dcl-S rowsExist Ind;
Dcl-S lstIdn    int(20);
Dcl-S idnIdx    packed(3);
Dcl-S lstUpd    char(27);

// Globals for input parms, used to handle optional parms
Dcl-S tblNme varchar(256);
Dcl-S idnCol varchar(256);
Dcl-S updCol varChar(256);

// Escape message type, change to *INFO to keep going, otherwise *ESCAPE to blow up
Dcl-C MSGTYP '*INFO';

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('JDBMSQB4');
    pmrTblNme char(256);
    pmrIdnCol char(256);
    pmrUpdCol Char(256);
  End-Pi;

  If %parms() = 0;
    tblNme = 'system_status_info_log';
    idnCol = 'system_statistic_log_id';
    updCol = 'maintenance_time_stamp';
  ElseIf %parms <= 2;
    tblNme = %trim(pmrTblNme);
    idnCol = %trim(pmrIdnCol);
    updCol = '';
  Else;
    tblNme = %trim(pmrTblNme);
    idnCol = %trim(pmrIdnCol);
    updCol = %trim(pmrUpdCol);
  EndIf;

  // Setup the Java environment for MS SQL
  JDBMSQB1();

  // Try to connect to MS SQL,
  If not connectDB();
    #$SNDMSG('Error - Could not connect to MS SQL Database':'*ESCAPE');
    Return;
  EndIf;

  // Get the last identity column and the last update date in the table on the MS SQL server
  Clear lstIdn;
  Clear lstUpd;
  If updCol <> '';
    sqlStm = 'Select max(' + idnCol + '), max(' + updCol + ') From ' + tblnme + '';
    rs = JDBC_ExecQry( conn : sqlStm );  // run query and return result set
    If (rs = *null);  // If no result set is returned error out
      #$SNDMSG('Error running SELECT statement: "' + sqlStm + '"':MSGTYP);
      Return;
    EndIf;
    // Get the last identity value on the MS SQL server
    Monitor; // return null oif there are no records, in which case start with 0 updates all
      DoW (JDBC_NextRow(rs));
        lstIdn = %int(JDBC_GetCol(rs: 1));
        lstUpd = JDBC_GetCol(rs: 1);
      EndDo;
    On-Error;
    EndMon;
    JDBC_FreeResult(rs);
  Else;
    sqlStm = 'Select max(' + idnCol + ') From ' + tblnme + '';
    rs = JDBC_ExecQry( conn : sqlStm );  // run query and return result set
    If (rs = *null);  // If no result set is returned error out
      #$SNDMSG('Error running SELECT statement: "' + sqlStm + '"':MSGTYP);
      Return;
    EndIf;
    // Get the last identity value on the MS SQL server
    Monitor; // return null if there are no records, in which case start with 0 updates all
      DoW (JDBC_NextRow(rs));
        lstIdn = %int(JDBC_GetCol(rs: 1));
      EndDo;
    On-Error;
    EndMon;
    JDBC_FreeResult(rs);
  EndIf;


  // This section pulls the meta data for the table on the MS SQL server,
  // it builds a column list and an array of column types.
  Clear colTyp;
  Clear idnIdx;
  Clear columns;
  // run query and return result set
  sqlStm = 'Select top 1 * From ' + tblnme + '';
  rs = JDBC_ExecQry( conn : sqlStm );
  // If no result set is returned error out
  If (rs = *null);
    #$SNDMSG('Error getting table details on the SQL server, SQL statement: "' + sqlStm + '"':MSGTYP);
    Return;
  EndIf;
  // Add columns to update/add, dave index of the identity column
  rsmd = JDBC_GetMetaData(rs);
  nbrCols = JDBC_GetColCount(rsmd);
  For i = 1 to nbrCols;
    If i <> 1;
      columns += ',';
    EndIf;
    columns += JDBC_GetColName(rsmd:i);
    If JDBC_GetColName(rsmd:i) = idnCol;
      idnIdx = i;
    EndIf;
    colTyp(i) = JDBC_GetColTypName(rsmd:i);
  EndFor;
  JDBC_FreeResult(rs);


  // This section updates existing rows, these are rows that are before the last
  // identity value and are after the last update timestamp. Updates have to be
  // done one row at a time.
  // TODO - a better way to do it in SQL server is to build a temp table, batch
  // load all changed records into it, do a merge update to the final table, and
  // drop the temp table. This allows writing in batch instead of one record at
  // a time.
  If updCol <> '';
    // get all values for updated rows
    updStm = 'Select ' + columns + ' +
              From APLLIB.' + tblnme + ' +
              Where ' + idnCol + ' <= ' + %char(lstIdn) + ' +
                 or ' + updCol + ' >= ''' + lstUpd + '''';
    Exec SQL Prepare updStm from :updStm;
    Exec SQL Declare updCrs cursor for updStm;
    Exec SQL Open updCrs;
    Monitor;
      Exec SQL Fetch Next From updCrs Into :MYDS :nulls;
    On-Error;
    EndMon;
    // this removes the MCH1210 escape message that is always sent
    QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
    DoW sqlState < '02';
      Monitor;
        Exec SQL Fetch Next From updCrs Into :MYDS :nulls;
      On-Error;
      EndMon;
      sqlStm = 'Update ' + tblnme + ' +
                Set (' + columns + ') = ' + RowOfValues() + ' +
                Where ' + idnCol + ' = ' + %trim(val(idnIdx));

      // this removes the MCH1210 escape message that is always sent
      QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
    EndDo;
    Exec SQL Close updCrs;
  EndIf;



  // This adds rows to the table in batches. The batches are based on the size
  // of the SQL variable. It is a lot quicker to add many rows at once then
  // adding each row individually. So the SQL statment is started here, and then
  // each row is appended till the length is over 30,000. Then it runs the
  // statement and starts a new one.


  // This section adds new rows, these are rows after the last identity value

  // Creates statement to pull new data that does not exist in SM SQL table
  // and the updated data if applicable
  addStm = 'Select ' + columns + ' +
            From APLLIB.' + tblnme + ' +
            Where ' + idnCol + ' > ' + %char(lstIdn);

  // Start SQL statment to add data into the MS SQL table
  sqlStm = 'Insert into ' + tblnme + ' (' + columns + ') values';
  rowsExist = *off;

  // loop through entries in the DB2 table and add them to the MS SQL table
  Exec SQL Prepare addStm from :addStm;
  Exec SQL Declare addCrs cursor for addStm;
  Exec SQL Open addCrs;
  Monitor;
    Exec SQL Fetch Next From addCrs Into :MYDS :nulls;
  On-Error;
  EndMon;
  // this removes the MCH1210 escape message that is always sent
  QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
  DoW sqlState < '02';
    // add one row to the statement
    sqlStm += RowOfValues() + ',';
    rowsExist = *on;
    // if the length of the statement is over 30,000, remove the last comma, run the statement and start a new one
    If %len(sqlStm) > 30000;
      sqlStm = %subst(sqlStm:1:%len(sqlStm)-1); // remove the last comma
      If JDBC_ExecUpd( conn : sqlStm ) < 0;
        #$SNDMSG('Error - Could not insert data, see job log for details.');
      Else;
        #$SNDMSG('Rows inserted.');
      EndIf;
      sqlStm = 'Insert into ' + tblnme + ' (' + columns + ') values';
      rowsExist = *off;
    EndIf;
    Monitor;
      Exec SQL Fetch Next From addCrs Into :MYDS :nulls;
    On-Error;
    EndMon;
    // this removes the MCH1210 escape message that is always sent
    QMHRCVPM (MsgInfo: %size(MsgInfo): 'RCVM0100':'*': *zero: '*ESCAPE': *blanks: *zero:'*REMOVE': ErrorCode);
  EndDo;
  Exec SQL Close addCrs;

  // Add the last rows
  If rowsExist;
    sqlStm = %subst(sqlStm:1:%len(sqlStm)-1); // remove the last comma
    If JDBC_ExecUpd( conn : sqlStm ) < 0;
      #$SNDMSG('Error - Could not insert data, sqlStm: "'+ sqlStm+ '".');
    Else;
      #$SNDMSG('Rows inserted, sqlStm: "'+ sqlStm+ '".');
    EndIf;
  EndIf;

End-Proc;


// Return a string of all values in the record
Dcl-Proc RowOfValues;
  Dcl-Pi *n varchar(5000);
  End-Pi;
  Dcl-S values varchar(5000);

  values = '(';
  For i = 1 to nbrCols;
    If i <> 1;
      values += ',';
    EndIf;
    If colTyp(i) = 'datetime2';
      values += '''' + CvtTimeStamp(val(i)) + '''';
    ElseIf nulls(i) < 0;
      values += 'null';
    Else;
      values += '''' + #$DBLQ(%trim(val(i))) + '''';
    EndIf;
  EndFor;
  values += ')';

  Return values;

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


// Convert DB2 timestamps to MS SQL format
Dcl-Proc CvtTimeStamp;
  Dcl-Pi *n varchar(100);
    input varchar(1000) const;
  End-Pi;
  // timestampformat in MS SQL is '2004-10-19 10:23:54.0000000', in DB2 is '2024-03-28-10.10.33.3358214',
  // so for timestamp the third dash has to be rmeoved, and the periods to must be changed to colons
  // Ruler   123456789012345678901234567890
  // input  '2024-03-28-10.10.33.3358214'
  // output '2004-10-19 10:23:54.3358214'
  Return %subst(input:1:10) + ' '
       + %subst(input:12:2) + ':'
       + %subst(input:15:2) + ':'
       + %subst(input:18:2) + '.'
       + %subst(input:21:7);

End-Proc;
