**FREE
// This program was set up to test more function in a postgres data base
// It will create a table and test CRUD options (Create,Read,Update,Delete)
// The program will:
//   connect to a postgress database
//   Create a new table
//   add records to the table
//   update a record, in several ways
//   delete a record
//   read the data back from the table
//

Ctl-Opt DftActGrp(*No) BndDir('APLLIB/APLLIB') Option(*Srcstmt) DatFmt(*ISO) main(Main);

/copy QSRC,JDBSRVV1PR // Scott Klements JDBCR4 service program headers
/copy QSRC,JDBPSTB1PR // Set up Java environment for Postgress, also contains postgress connection stuff
/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Program variable definitions
Dcl-S sqlStm       Varchar(32767);

// Escape message type, change to *INFO to keep going, otherwise *ESCAPE to blow up
// Dcl-C msgTyp msgTyp;
Dcl-C MSGTYP '*INFO';

Dcl-Proc Main;

  // Setup the Java environment for Postgres
  JDBPSTB1();

  // Try to connect to postgress,
  If not connectDB();
    #$SNDMSG('Error - Could not connect to Postgres':'*ESCAPE');
    Return;
  EndIf;

  // Create a table
  CreateTable();

  // Test CRUD options
  WriteRows();
  UpdateRows();
  DeleteRows();
  ReadRows();

  // close the JDBC connection
  JDBC_Close(conn);

End-Proc;


// Connect to the database
Dcl-Proc connectDB;
  Dcl-Pi *n Ind;
  End-Pi;

  conn = JDBC_Connect( 'org.postgresql.Driver' : %trim(url) : %trim(UserId) : %trim(Passwrd));

  If conn  = *null;
    Return *off;
  Else;
    Return *on;
  EndIf;

End-Proc;


// Create new table
Dcl-Proc CreateTable;

  // Delete the table first, ignore error if it doesn't exist
  sqlStm = 'Drop Table TIMPSTB2';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Table TIMPSTB2 not deleted.');
  Else;
    #$SNDMSG('Table TIMPSTB2 deleted.');
  EndIf;

  // Create the table
  sqlStm = '+
    create table TIMPSTB2 ( +
      id bigint GENERATED ALWAYS AS IDENTITY, +
      active char(1) default ''1'', +
      name varchar(50) +
    )';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not create table.':MSGTYP);
  Else;
    #$SNDMSG('Table TIMPSTB2 created.');
  EndIf;

End-Proc;


// Add data to the table
Dcl-Proc WriteRows;

  // Insert some rows
  insertName('Tim Tognazzini');
  insertName('Brian Younger');
  insertName('Joe Courtney');
  insertName('Hollye Moore');
  insertName('Myrtis Kirk');
  insertName('Stacy Grady');
  insertName('Vicky Lowe');
  insertName('Mickey Mouse');
  insertName('Joe Joseph');
  insertName('Mike Benningfield');

End-Proc;


// used for insert to DRY up the code
Dcl-Proc insertName;
  Dcl-Pi *n;
    name varchar(50) const;
  End-Pi;

  // Insert some rows
  sqlStm = 'insert into TIMPSTB2 (name) values(''' + #$DBLQ(name) + ''')';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not insert name '+ name +', sqlStm: "'+ sqlStm+ '".':MSGTYP);
  Else;
    #$SNDMSG('Name ' + name + ' added to table TIMPSTB2.');
  EndIf;

End-Proc;


// Update some rows
Dcl-Proc UpdateRows;

  // update some of the entered rows, flag to entries as inactive
  sqlStm = 'Update TIMPSTB2 +
            Set active = ''0'' +
            Where name = ''Joe Joseph''';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not update Joe Joseph.':MSGTYP);
  Else;
    #$SNDMSG('Joe Joseph inactivated.');
  EndIf;

  sqlStm = 'Update TIMPSTB2 +
            Set active = ''0'' +
            Where name = ''Mike Benningfield''';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not update Mike Benningfield.':MSGTYP);
  Else;
    #$SNDMSG('Mike Benningfield inactivated.');
  EndIf;

  sqlStm = 'Update TIMPSTB2 +
            Set active = ''0'' +
            Where name = ''Hollye Moore''';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not update Hollye Moore.':MSGTYP);
  Else;
    #$SNDMSG('Hollye Moore inactivated.');
  EndIf;

End-Proc;


// Delete some rows
Dcl-Proc DeleteRows;

  // Delete a row, really should not be done, data should only be inactivated in a live environment,
  // inlcuded for CRUD example
  sqlStm = 'Delete From TIMPSTB2 +
            Where name = ''Mickey Mouse''';
  If JDBC_ExecUpd( conn : sqlStm ) < 0;
    #$SNDMSG('Error - Could not delete Mickey Mouse.':MSGTYP);
  Else;
    #$SNDMSG('Mickey Mouse deleted.');
  EndIf;


End-Proc;


// Read some rows, just add to job log for viewing
// This also inludes an example of retriving metadata for the result set,
// this really is not used much, but I just wanted to document it
Dcl-Proc ReadRows;
  Dcl-Ds rsDta qualified;
    id packed(20);
    active char(1);
    name varchar(50);
  End-Ds;
  Dcl-S rs   like(ResultSet);
  Dcl-S rsmd like(ResultSetMetaData);
  Dcl-S i packed(9);

  sqlStm = 'Select id, active, name From TIMPSTB2 order by id';

  // run query and return result set
  rs = JDBC_ExecQry( conn : sqlStm );

  // If no result set is retutnred error out
  If (rs = *null);
    #$SNDMSG('Error running SELECT statement: "' + sqlStm + '"':MSGTYP);
    Return;
  EndIf;

  // retrieve the metat data for the resultset
  rsmd = JDBC_GetMetaData(rs);
  // output the number of columns in the result set
  #$SNDMSG('Number of columns in result set: ' + %char(JDBC_GetColCount(rsmd)));
  // output each columns attributres
  For i = 1 to JDBC_GetColCount(rsmd);
    #$SNDMSG('  Column:' + %char(i) +
             ', Name: ' + JDBC_GetColName(rsmd:i) +
             ', Display Size: ' + %char(JDBC_GetColDspSize(rsmd:i)) +
             ', Type: ' + JDBC_GetColTypName(rsmd:i)
             );
  EndFor;


  DoW (JDBC_NextRow(rs));
    // example using column index, starts at 1
    rsDta.id     = %int(JDBC_GetCol(rs: 1));
    rsDta.active = JDBC_GetCol(rs: 2);
    rsDta.name   = JDBC_GetCol(rs: 3);

    // Example using column name, does the same thing as the index example, only one is needed, included for example
    rsDta.id     = %int(JDBC_GetColByName(rs: 'id'));
    rsDta.active = JDBC_GetColByName(rs: 'active');
    rsDta.name   = JDBC_GetColByName(rs: 'name');

    // Write code to print the data, the scope was to just test
    // the connection and see the data is returned.
    #$SNDMSG('id: ' + %char(rsDta.id) + ', name: ' + %trim(rsDta.name) + ', active: ' + rsDta.active);

  EndDo;

  JDBC_FreeResult(rs);

End-Proc;
