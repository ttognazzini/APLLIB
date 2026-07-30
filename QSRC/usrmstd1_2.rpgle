**free
// ************************************************************************************
// *                              *** Warning ***                                     *
// ************************************************************************************
// * Do not manually build or change this, it is rebuilt from the screen, any changes *
// * will be overridden. It can be rebuilt manually using custom PDM option SC in     *
// * front of the display file. If SC is not setup add it with the following command  *
// *    call scrlocb1 (&l &f &n)                                                      *
// ************************************************************************************


// Sets the sort code based on which position to field is entered
Dcl-Proc SetSrtCde;

  If USRPRF <> '';
    filterDs.SrtCde = 1;
  ElseIf USRTXT <> '';
    filterDs.SrtCde = 2;
  ElseIf USRINT <> '';
    filterDs.SrtCde = 3;
  ElseIf USRDPT <> '';
    filterDs.SrtCde = 4;
  ElseIf USRTTL <> '';
    filterDs.SrtCde = 5;
  ElseIf USRCLS <> '';
    filterDs.SrtCde = 6;
  ElseIf USROQN <> '';
    filterDs.SrtCde = 7;
  ElseIf USRSTS <> '';
    filterDs.SrtCde = 8;
  ElseIf GRPPRF <> '';
    filterDs.SrtCde = 9;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.USRPRF <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRPRF) < uCase(''' + %trim(pos.USRPRF) + ''')';
    Where = 'and';
  ElseIf pos.USRTXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRTXT) < uCase(''' + %trim(pos.USRTXT) + ''')';
    Where = 'and';
  ElseIf pos.USRINT <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRINT) < uCase(''' + %trim(pos.USRINT) + ''')';
    Where = 'and';
  ElseIf pos.USRDPT <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRDPT) < uCase(''' + %trim(pos.USRDPT) + ''')';
    Where = 'and';
  ElseIf pos.USRTTL <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRTTL) < uCase(''' + %trim(pos.USRTTL) + ''')';
    Where = 'and';
  ElseIf pos.USRCLS <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRCLS) < uCase(''' + %trim(pos.USRCLS) + ''')';
    Where = 'and';
  ElseIf pos.USROQN <> '';
    SQLStmPos += ' ' + Where + ' ucase(USROQN) < uCase(''' + %trim(pos.USROQN) + ''')';
    Where = 'and';
  ElseIf pos.USRSTS <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRSTS) < uCase(''' + %trim(pos.USRSTS) + ''')';
    Where = 'and';
  ElseIf pos.GRPPRF <> '';
    SQLStmPos += ' ' + Where + ' ucase(GRPPRF) < uCase(''' + %trim(pos.GRPPRF) + ''')';
    Where = 'and';
  EndIf;

  // Add order by
  SQLStmPos += ' ' + OrderBy;

  Exec SQL Prepare SQLStmPos From :SQLStmPos;
  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;
  Exec SQL Open SQLCrsPos;
  Exec SQL Get DIAGNOSTICS :currentRow = DB2_NUMBER_ROWS;
  Exec SQL Close SQLCrsPos;

  Clear Pos;

End-Proc;
