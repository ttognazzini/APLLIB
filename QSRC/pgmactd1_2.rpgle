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

  If SEQNBR <> '';
    filterDs.SrtCde = 1;
  ElseIf ACTCDE <> '';
    filterDs.SrtCde = 2;
  ElseIf OPTION <> '';
    filterDs.SrtCde = 3;
  ElseIf DES <> '';
    filterDs.SrtCde = 4;
  ElseIf FNCKEY <> '';
    filterDs.SrtCde = 5;
  ElseIf ACVDES <> '';
    filterDs.SrtCde = 6;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.SEQNBR <> '';
    SQLStmPos += ' ' + Where + ' ucase(SEQNBR) < uCase(''' + %trim(pos.SEQNBR) + ''')';
    Where = 'and';
  ElseIf pos.ACTCDE <> '';
    SQLStmPos += ' ' + Where + ' ucase(ACTCDE) < uCase(''' + %trim(pos.ACTCDE) + ''')';
    Where = 'and';
  ElseIf pos.OPTION <> '';
    SQLStmPos += ' ' + Where + ' ucase(OPTION) < uCase(''' + %trim(pos.OPTION) + ''')';
    Where = 'and';
  ElseIf pos.DES <> '';
    SQLStmPos += ' ' + Where + ' ucase(DES) < uCase(''' + %trim(pos.DES) + ''')';
    Where = 'and';
  ElseIf pos.FNCKEY <> '';
    SQLStmPos += ' ' + Where + ' ucase(FNCKEY) < uCase(''' + %trim(pos.FNCKEY) + ''')';
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
