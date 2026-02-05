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

  If CRTDTM <> '';
    filterDs.SrtCde = 1;
  ElseIf CRTUSR <> '';
    filterDs.SrtCde = 2;
  ElseIf FLDNME <> '';
    filterDs.SrtCde = 3;
  ElseIf LOGTYP <> '';
    filterDs.SrtCde = 4;
  ElseIf LOGDES <> '';
    filterDs.SrtCde = 5;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.CRTDTM <> '';
    SQLStmPos += ' ' + Where + ' ucase(CRTDTM) < uCase(''' + %trim(pos.CRTDTM) + ''')';
    Where = 'and';
  ElseIf pos.CRTUSR <> '';
    SQLStmPos += ' ' + Where + ' ucase(CRTUSR) < uCase(''' + %trim(pos.CRTUSR) + ''')';
    Where = 'and';
  ElseIf pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.LOGTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(LOGTYP) < uCase(''' + %trim(pos.LOGTYP) + ''')';
    Where = 'and';
  ElseIf pos.LOGDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(LOGDES) < uCase(''' + %trim(pos.LOGDES) + ''')';
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
