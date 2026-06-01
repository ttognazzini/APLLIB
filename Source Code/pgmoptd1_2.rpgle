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

  If OPT <> 0;
    filterDs.SrtCde = 1;
  ElseIf OPTION <> '';
    filterDs.SrtCde = 2;
  ElseIf DES <> '';
    filterDs.SrtCde = 3;
  ElseIf ACVDES <> '';
    filterDs.SrtCde = 4;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.OPT <> 0;
    SQLStmPos += ' ' + Where + ' OPT < ' + %char(pos.OPT);
    Where = 'and';
  ElseIf pos.OPTION <> '';
    SQLStmPos += ' ' + Where + ' ucase(OPTION) < uCase(''' + %trim(pos.OPTION) + ''')';
    Where = 'and';
  ElseIf pos.DES <> '';
    SQLStmPos += ' ' + Where + ' ucase(DES) < uCase(''' + %trim(pos.DES) + ''')';
    Where = 'and';
  ElseIf pos.ACVDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(ACVDES) < uCase(''' + %trim(pos.ACVDES) + ''')';
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
