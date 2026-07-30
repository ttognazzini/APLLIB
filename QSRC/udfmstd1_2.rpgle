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

  If PGMNME <> '';
    filterDs.SrtCde = 1;
  ElseIf UDFKEY <> '';
    filterDs.SrtCde = 2;
  ElseIf UDFDES <> '';
    filterDs.SrtCde = 3;
  ElseIf USRCNF <> '';
    filterDs.SrtCde = 4;
  ElseIf UDFOPT <> '';
    filterDs.SrtCde = 5;
  ElseIf UDFDFT <> '';
    filterDs.SrtCde = 6;
  ElseIf ACVROW <> '';
    filterDs.SrtCde = 7;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.PGMNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(PGMNME) < uCase(''' + %trim(pos.PGMNME) + ''')';
    Where = 'and';
  ElseIf pos.UDFKEY <> '';
    SQLStmPos += ' ' + Where + ' ucase(UDFKEY) < uCase(''' + %trim(pos.UDFKEY) + ''')';
    Where = 'and';
  ElseIf pos.UDFDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(UDFDES) < uCase(''' + %trim(pos.UDFDES) + ''')';
    Where = 'and';
  ElseIf pos.USRCNF <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRCNF) < uCase(''' + %trim(pos.USRCNF) + ''')';
    Where = 'and';
  ElseIf pos.UDFOPT <> '';
    SQLStmPos += ' ' + Where + ' ucase(UDFOPT) < uCase(''' + %trim(pos.UDFOPT) + ''')';
    Where = 'and';
  ElseIf pos.UDFDFT <> '';
    SQLStmPos += ' ' + Where + ' ucase(UDFDFT) < uCase(''' + %trim(pos.UDFDFT) + ''')';
    Where = 'and';
  ElseIf pos.ACVROW <> '';
    SQLStmPos += ' ' + Where + ' ucase(ACVROW) < uCase(''' + %trim(pos.ACVROW) + ''')';
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
