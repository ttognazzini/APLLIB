     /*-                                                                            +
      * Copyright (c) 2006-2010 Scott C. Klement                                    +
      * All rights reserved.                                                        +
      *                                                                             +
      * Redistribution and use in source and binary forms, with or without          +
      * modification, are permitted provided that the following conditions          +
      * are met:                                                                    +
      * 1. Redistributions of source code must retain the above copyright           +
      *    notice, this list of conditions and the following disclaimer.            +
      * 2. Redistributions in binary form must reproduce the above copyright        +
      *    notice, this list of conditions and the following disclaimer in the      +
      *    documentation and/or other materials provided with the distribution.     +
      *                                                                             +
      * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND      +
      * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       +
      * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  +
      * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE     +
      * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL  +
      * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS     +
      * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)       +
      * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT  +
      * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY   +
      * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF      +
      * SUCH DAMAGE.                                                                +
      *                                                                             +
      */                                                                            +

      /if defined(JDBC_H_DEFINED)
      /eof
      /endif
      /define JDBC_H_DEFINED

     D Statement       s               O   CLASS(*JAVA:
     D                                     'java.sql.Statement')
     D Connection      s               O   CLASS(*JAVA:
     D                                     'java.sql.Connection')
     D ResultSet       s               O   CLASS(*JAVA:
     D                                     'java.sql.ResultSet')
     D ResultSetMetaData...
     D                 s               O   CLASS(*JAVA:
     D                                     'java.sql.ResultSetMetaData')
     D PreparedStatement...
     D                 s               O   CLASS(*JAVA:
     D                                     'java.sql.PreparedStatement')
     D CallableStatement...
     D                 s               O   CLASS(*JAVA:
     D                                     'java.sql.CallableStatement')
     D Properties      s               O   CLASS(*JAVA:
     D                                     'java.util.Properties')

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * MySQL_Connect(): Create a connection to a MYSQL server
      *
      *    server = (input) mysql server to connect to
      *  database = (input) database to use on server
      *    userid = (input) userid to log in with
      *  password = (input) password to log in with
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D MySQL_Connect   PR                  like(Connection)
     D   server                     256A   varying const options(*varsize)
     D   database                   256A   varying const options(*varsize)
     D   userid                      50A   varying const options(*varsize)
     D   password                    50A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_Connect(): Create a connection using JDBC driver
      *
      *    driver = (input) Java class name of JDBC driver to use
      *       url = (input) JDBC URL of database to connect to
      *    userid = (input) userid to log in with
      *  password = (input) password to log in with
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Connect    PR                  like(Connection)
     D   driver                     256A   varying const options(*varsize)
     D   url                        256A   varying const options(*varsize)
     D   userid                      50A   varying const options(*varsize)
     D   password                    50A   varying const options(*varsize)

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ConnProp(): Connect to database w/properties object
      *
      *    driver = (input) Java class name of JDBC driver to use
      *       url = (input) JDBC URL to connect to
      *      prop = (input) properties to use when connecting
      *
      * Returns a connection handle or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ConnProp   PR                  like(Connection)
     D   driver                     256A   varying const options(*varsize)
     D   url                        256A   varying const options(*varsize)
     D   prop                              like(Properties)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Properties():  Create new properties object
      *
      *  returns the object.
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Properties...
     D                 PR                  like(Properties)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_setProp():  Set one property in Properties object
      *
      *     prop = (i/o) Properties object to set property in
      *      key = (input) property to set
      *    value = (input) value to assign to property
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_setProp    PR
     D   prop                              like(Properties)
     D   key                        256A   varying const options(*varsize)
     D   value                      256A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_freeProp():  Release properties object
      *
      *     prop = (i/o) Properties object to release
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_freeProp   PR
     D   prop                              like(Properties)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_ExecUpd():  Execute a Query that doesn't return results
      *
      *     conn = (input) database connection
      *      sql = (input) SQL Code to execute
      *
      *  returns a row count, or 0 where a row count is not applicable
      *        or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ExecUpd    PR            10I 0
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_ExecQry():  Execute a Query that returns a result
      *
      *     conn = (input) database connection
      *      sql = (input) SQL code to execute
      *
      *  Returns a result handle, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ExecQry    PR                  like(ResultSet)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetMetaData():  Get ResultSet MetaData
      *
      *       rs = (input) Result handle to get metadata for
      *
      *  Returns a resultset metadata, or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetMetaData...
     D                 PR                  like(ResultSetMetaData)
     D   rs                                like(ResultSet)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColCount():  Get ResultSet Column Count
      *
      *       rsmd = (input) ResultSet MetaData handle
      *
      *  Returns column count
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColCount...
     D                 PR            10I 0
     D   rsmd                              like(ResultSetMetaData)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColName():  Get column name from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column name if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColName...
     D                 PR           256A   varying
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColDspSize():  Get column display size from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column display size
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColDspSize...
     D                 PR            10I 0
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColTypName():  Get column SQL type name from ResultSet MetaData
      *
      *     rsmd = (input) ResultSet MetaData handle to use
      *      col = (input) column number to retrieve
      *
      *  Returns column SQL type name
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColTypName...
     D                 PR           256A   varying
     D   rsmd                              like(ResultSetMetaData)
     D   col                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_ NextRow():  Position result to next row
      *
      *       rs = (input) Result handle to move
      *
      *  Returns *ON if successful, *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_NextRow    PR             1N
     D   rs                                like(ResultSet)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetCol():  Get column from current row
      *
      *       rs = (input) Result handle to use
      *      col = (input) column number to retrieve
      *  nullInd = (output/optional) will be set to *ON if the
      *             field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetCol     PR         32767A   varying
     D   rs                                like(ResultSet)
     D   col                         10I 0 value
     D   nullInd                      1N   options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColC():  Get column from current row in Unicode
      *
      *       rs = (input) Result handle to use
      *      col = (input) column number to retrieve
      *  nullInd = (output/optional) will be set to *ON if the
      *             field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColC    PR         16383C   varying
     D   rs                                like(ResultSet)
     D   col                         10I 0 value
     D   nullInd                      1N   options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_FreeResult(): Free result handle
      *
      *     rs = (input) Result handle to free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_FreeResult...
     D                 PR
     D   rs                                like(ResultSet)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Commit():  Commit transaction
      *
      *     conn = (input) Connection to commit on
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Commit     PR
     D   conn                              like(Connection)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Rollback():  Rollback transaction
      *
      *     conn = (input) Connection to rollback on
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Rollback   PR
     D   conn                              like(Connection)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_Close():  Close connection to Server
      *                   and free connection handle
      *
      *     conn = (input) Connection to close
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Close      PR
     D   conn                              like(Connection)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepStmt(): Create a Prepared Statement
      *
      *    conn = (input) Connection to prepare statement for
      *     sql = (input) SQL statement to prepare
      *
      * Returns a prepared statement object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_PrepStmt   PR                  like(PreparedStatement)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepCall(): Create a Callable Statement
      *
      *    conn = (input) Connection to prepare call statement for
      *     sql = (input) SQL call statement to prepare
      *
      * Returns a callable statement object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_PrepCall   PR                  like(CallableStatement)
     D   conn                              like(Connection) const
     D   sql                      32767A   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepCallC(): Create a Prepared Call
      *                   using a Unicode string
      *
      *    conn = (input) Connection to prepare call for
      *     sql = (input) SQL call to prepare
      *
      * Returns a prepared call object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_PrepCallC  PR                  like(CallableStatement)
     D   conn                              like(Connection) const
     D   sql                      16383C   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_PrepStmtC(): Create a Prepared Statement
      *                   from a Unicode String
      *
      *    conn = (input) Connection to prepare statement for
      *     sql = (input) SQL statement to prepare
      *
      * Returns a prepared statement object, or *NULL upon error
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_PrepStmtC  PR                  like(PreparedStatement)
     D   conn                              like(Connection) const
     D   sql                      16383c   varying const options(*varsize)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetString(): Set a string in a prepared statement
      *
      *    prep = (input) Prepared statement to set string in
      *     idx = (input) Parameter index to set
      *     str = (input) String to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetString...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   str                      32767A   varying const options(*varsize)
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetStringC(): Set a string in a prepared statement
      *                    using Unicode input
      *
      *    prep = (input) Prepared statement to set string in
      *     idx = (input) Parameter index to set
      *     str = (input) String to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetStringC...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   str                      16383C   varying const options(*varsize)
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetInt(): Set an integer in a prepared statement
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *     int = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetInt     PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   int                         10I 0 value
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDouble(): Set a floating point value in a prepared
      *                    statement
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *  double = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetDouble...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   double                       8F   value
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDecimal(): Set a decimal value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *     dec = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetDecimal...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   dec                         30P 9 value
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetDate(): Set a date value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *    date = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetDate...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   date                          D   datfmt(*iso) const
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetTime(): Set a time value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *    time = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetTime...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   time                          T   timfmt(*hms) const
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_SetTimestamp(): Set a timestamp value in a prepared stmt
      *
      *    prep = (input) Prepared statement to set value in
      *     idx = (input) Parameter index to set
      *      ts = (input) value to set
      *    null = (input/optional) set field to NULL in database
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_SetTimestamp...
     D                 PR             1N
     D   prep                              like(PreparedStatement) const
     D   idx                         10I 0 value
     D   ts                            Z   const
     D   null                         1N   const options(*nopass)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_RegisterOutParameter(): Register an output parameter
      *                           returned from a stored-proc call
      *
      *    call = (input) Callable statement to register output for
      *     idx = (input) Parameter index to register
      *    type = (input) Data type to register
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_RegisterOutParameter...
     D                 PR
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value
     D   type                        10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetString():  Get string from Callable Statement
      *
      *     call = (input) Callable Statement handle to use
      *      idx = (input) parameter index to retrieve
      *
      *  Returns string value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetString...
     D                 PR         32767A   varying
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetInt():  Get integer from Callable Statement
      *
      *     call = (input) Callable Statement handle to use
      *      idx = (input) parameter index to retrieve
      *
      *  Returns int value if successful, or 0 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetInt...
     D                 PR            10I 0
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetShort():  Get short from Callable Statement
      *
      *     call = (input) Callable Statement handle to use
      *      idx = (input) parameter index to retrieve
      *
      *  Returns int value if successful, or 0 otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetShort...
     D                 PR            10I 0
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetBoolean():  Get boolean from Callable Statement
      *
      *     call = (input) Callable Statement handle to use
      *      idx = (input) parameter index to retrieve
      *
      *  Returns a boolean value if successful, or *OFF otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetBoolean...
     D                 PR             1N
     D   call                              like(CallableStatement) const
     D   idx                         10I 0 value


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecPrepQry(): Execute a query from a prepared statement
      *
      *      prep = (input) prepared statement to execute
      *
      * Returns ResultSet object or *NULL upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ExecPrepQry...
     D                 PR                  like(ResultSet)
     D   prep                              like(PreparedStatement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecPrepUpd(): Execute SQL that doesn't return data
      *                     from a prepared statement
      *
      *      prep = (input) prepared statement to execute
      *
      * Returns 0 or a row count if successful
      *     or -1 upon failure
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ExecPrepUpd...
     D                 PR            10I 0
     D   prep                              like(PreparedStatement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_ExecCall(): Execute SQL statement that calls a stored
      *                     procedure
      *
      *      call = (input) callable statement to execute
      *
      * Returns *ON if first result is a ResultSet
      *      or *OFF if first result is an update count
      *
      * Use JDBC_moreResults(), JDBC_getUpdateCount() and
      *     JDBC_getResultSet() to get results of this function
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_ExecCall...
     D                 PR             1N
     D   call                              like(CallableStatement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_FreePrepStmt(): Free prepared statement
      *
      *    prep = (input) Prepared Statement to Free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_FreePrepStmt...
     D                 PR
     D   prep                              like(PreparedStatement)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_FreeCallStmt(): Free callable statement
      *
      *    call = (input) Callable Statement to Free
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_FreeCallStmt...
     D                 PR
     D   call                              like(CallableStatement)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColByName():  Get column from current row by
      *                        column name
      *
      *          rs = (input) Result handle to use
      *  columnName = (input) column name to retrieve
      *     nullInd = (output/optional) will be set to *ON if the
      *               field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColByName...
     D                 PR         32767a   varying
     D  rs                                 Like(ResultSet)
     D  ColumnName                32767a   varying Const options(*varsize)
     D  nullInd                       1N   options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_GetColByNameC():  Get column data in Unicode from the
      *                         current row by column name.
      *
      *          rs = (input) Result handle to use
      *  columnName = (input) column name to retrieve
      *     nullInd = (output/optional) will be set to *ON if the
      *               field is null, or *OFF otherwise.
      *
      *  Returns column value if successful, or '' otherwise
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_GetColByNameC...
     D                 pr         16383c   varying
     D  rs                                 Like(ResultSet)
     D  ColumnName                16383c   varying Const options(*varsize)
     D  nullInd                       1N   options(*nopass:*omit)


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getUpdateCount(): Get the number of rows modified
      *         by the last call to JDBC_ExecCall()
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns number of modified rows, or -1 if the current
      *          result is a ResultSet or if there are no results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_getUpdateCount...
     D                 pr            10i 0
     D  stmt                               Like(Statement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getResultSet(): Get the first/next ResultSet
      *         returned by JDBC_ExecCall()
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns the ResultSet or *NULL if the current result is
      *          not a ResultSet or if there are no more results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_getResultSet...
     D                 pr                  like(ResultSet)
     D  stmt                               Like(Statement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  JDBC_getMoreResults(): Move the results of this statement
      *         to the next result returned.
      *
      *        stmt = (input) PreparedStatement or CallableStatement
      *
      *  Returns *ON if the next result is a ResultSet object,
      *          or *OFF if it's an update count or there are no
      *          more results
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_getMoreResults...
     D                 pr             1n
     D  stmt                               Like(Statement) const


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      * JDBC_Execute(): Execute Prepared SQL Statement
      *
      *      stmt = (input) prepared statement to execute
      *
      * Returns *ON if first result is a ResultSet
      *      or *OFF if first result is an update count
      *
      * Use JDBC_moreResults(), JDBC_getUpdateCount() and
      *     JDBC_getResultSet() to get results of this function
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     D JDBC_Execute...
     D                 PR             1N
     D   stmt                              like(PreparedStatement) const
