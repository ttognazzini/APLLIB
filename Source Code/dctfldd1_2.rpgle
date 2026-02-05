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

  If FLDNME <> '';
    filterDs.SrtCde = 1;
  ElseIf COLTXT <> '';
    filterDs.SrtCde = 2;
  ElseIf ACVDES <> '';
    filterDs.SrtCde = 3;
  ElseIf TYP <> '';
    filterDs.SrtCde = 4;
  ElseIf FLDENMD <> '';
    filterDs.SrtCde = 5;
  ElseIf DFTVAL <> '';
    filterDs.SrtCde = 6;
  ElseIf ALWNUL <> '';
    filterDs.SrtCde = 7;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.COLTXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(COLTXT) < uCase(''' + %trim(pos.COLTXT) + ''')';
    Where = 'and';
  ElseIf pos.ACVDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(ACVDES) < uCase(''' + %trim(pos.ACVDES) + ''')';
    Where = 'and';
  ElseIf pos.TYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(TYP) < uCase(''' + %trim(pos.TYP) + ''')';
    Where = 'and';
  ElseIf pos.FLDENMD <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDENMD) < uCase(''' + %trim(pos.FLDENMD) + ''')';
    Where = 'and';
  ElseIf pos.DFTVAL <> '';
    SQLStmPos += ' ' + Where + ' ucase(DFTVAL) < uCase(''' + %trim(pos.DFTVAL) + ''')';
    Where = 'and';
  ElseIf pos.ALWNUL <> '';
    SQLStmPos += ' ' + Where + ' ucase(ALWNUL) < uCase(''' + %trim(pos.ALWNUL) + ''')';
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
