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

  If FLDTYP <> '';
    filterDs.SrtCde = 1;
  ElseIf DES <> '';
    filterDs.SrtCde = 2;
  ElseIf NMR <> '';
    filterDs.SrtCde = 3;
  ElseIf ALWDEC <> '';
    filterDs.SrtCde = 4;
  ElseIf REQLEN <> '';
    filterDs.SrtCde = 5;
  ElseIf ALWALC <> '';
    filterDs.SrtCde = 6;
  ElseIf FRCLEN <> '';
    filterDs.SrtCde = 7;
  ElseIf ACVDES <> '';
    filterDs.SrtCde = 8;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLDTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDTYP) < uCase(''' + %trim(pos.FLDTYP) + ''')';
    Where = 'and';
  ElseIf pos.DES <> '';
    SQLStmPos += ' ' + Where + ' ucase(DES) < uCase(''' + %trim(pos.DES) + ''')';
    Where = 'and';
  ElseIf pos.NMR <> '';
    SQLStmPos += ' ' + Where + ' ucase(NMR) < uCase(''' + %trim(pos.NMR) + ''')';
    Where = 'and';
  ElseIf pos.ALWDEC <> '';
    SQLStmPos += ' ' + Where + ' ucase(ALWDEC) < uCase(''' + %trim(pos.ALWDEC) + ''')';
    Where = 'and';
  ElseIf pos.REQLEN <> '';
    SQLStmPos += ' ' + Where + ' ucase(REQLEN) < uCase(''' + %trim(pos.REQLEN) + ''')';
    Where = 'and';
  ElseIf pos.ALWALC <> '';
    SQLStmPos += ' ' + Where + ' ucase(ALWALC) < uCase(''' + %trim(pos.ALWALC) + ''')';
    Where = 'and';
  ElseIf pos.FRCLEN <> '';
    SQLStmPos += ' ' + Where + ' ucase(FRCLEN) < uCase(''' + %trim(pos.FRCLEN) + ''')';
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
