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

  If TRGLIB <> '';
    filterDs.SrtCde = 1;
  ElseIf TRGPGM <> '';
    filterDs.SrtCde = 2;
  ElseIf FLELIB <> '';
    filterDs.SrtCde = 3;
  ElseIf TRGFLE <> '';
    filterDs.SrtCde = 4;
  ElseIf TRGUPD <> '';
    filterDs.SrtCde = 5;
  ElseIf TRGADD <> '';
    filterDs.SrtCde = 6;
  ElseIf TRGDEL <> '';
    filterDs.SrtCde = 7;
  ElseIf LIBTYPD <> '';
    filterDs.SrtCde = 8;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.TRGLIB <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGLIB) < uCase(''' + %trim(pos.TRGLIB) + ''')';
    Where = 'and';
  ElseIf pos.TRGPGM <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGPGM) < uCase(''' + %trim(pos.TRGPGM) + ''')';
    Where = 'and';
  ElseIf pos.FLELIB <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLELIB) < uCase(''' + %trim(pos.FLELIB) + ''')';
    Where = 'and';
  ElseIf pos.TRGFLE <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGFLE) < uCase(''' + %trim(pos.TRGFLE) + ''')';
    Where = 'and';
  ElseIf pos.TRGUPD <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGUPD) < uCase(''' + %trim(pos.TRGUPD) + ''')';
    Where = 'and';
  ElseIf pos.TRGADD <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGADD) < uCase(''' + %trim(pos.TRGADD) + ''')';
    Where = 'and';
  ElseIf pos.TRGDEL <> '';
    SQLStmPos += ' ' + Where + ' ucase(TRGDEL) < uCase(''' + %trim(pos.TRGDEL) + ''')';
    Where = 'and';
  ElseIf pos.LIBTYPD <> '';
    SQLStmPos += ' ' + Where + ' ucase(LIBTYPD) < uCase(''' + %trim(pos.LIBTYPD) + ''')';
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
