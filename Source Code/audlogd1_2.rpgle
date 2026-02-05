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

  If CRTUSR <> '';
    filterDs.SrtCde = 1;
  ElseIf CRTDTM <> '';
    filterDs.SrtCde = 2;
  ElseIf FLDNME <> '';
    filterDs.SrtCde = 3;
  ElseIf COLTXT <> '';
    filterDs.SrtCde = 4;
  ElseIf BFRVAL <> '';
    filterDs.SrtCde = 5;
  ElseIf AFTVAL <> '';
    filterDs.SrtCde = 6;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.CRTUSR <> '';
    SQLStmPos += ' ' + Where + ' ucase(CRTUSR) < uCase(''' + %trim(pos.CRTUSR) + ''')';
    Where = 'and';
  ElseIf pos.CRTDTM <> '';
    SQLStmPos += ' ' + Where + ' ucase(CRTDTM) < uCase(''' + %trim(pos.CRTDTM) + ''')';
    Where = 'and';
  ElseIf pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.COLTXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(COLTXT) < uCase(''' + %trim(pos.COLTXT) + ''')';
    Where = 'and';
  ElseIf pos.BFRVAL <> '';
    SQLStmPos += ' ' + Where + ' ucase(BFRVAL) < uCase(''' + %trim(pos.BFRVAL) + ''')';
    Where = 'and';
  ElseIf pos.AFTVAL <> '';
    SQLStmPos += ' ' + Where + ' ucase(AFTVAL) < uCase(''' + %trim(pos.AFTVAL) + ''')';
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
