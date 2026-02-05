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

  If MSFLIB <> '';
    filterDs.SrtCde = 1;
  ElseIf MSFNME <> '';
    filterDs.SrtCde = 2;
  ElseIf MSFDES <> '';
    filterDs.SrtCde = 3;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.MSFLIB <> '';
    SQLStmPos += ' ' + Where + ' ucase(MSFLIB) < uCase(''' + %trim(pos.MSFLIB) + ''')';
    Where = 'and';
  ElseIf pos.MSFNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(MSFNME) < uCase(''' + %trim(pos.MSFNME) + ''')';
    Where = 'and';
  ElseIf pos.MSFDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(MSFDES) < uCase(''' + %trim(pos.MSFDES) + ''')';
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
