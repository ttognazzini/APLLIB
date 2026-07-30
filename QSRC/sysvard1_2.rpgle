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

  If LIBNME <> '';
    filterDs.SrtCde = 1;
  ElseIf VARNME <> '';
    filterDs.SrtCde = 2;
  ElseIf VARDES <> '';
    filterDs.SrtCde = 3;
  ElseIf LIBTYPD <> '';
    filterDs.SrtCde = 4;
  ElseIf CMTEXS <> '';
    filterDs.SrtCde = 5;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.LIBNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(LIBNME) < uCase(''' + %trim(pos.LIBNME) + ''')';
    Where = 'and';
  ElseIf pos.VARNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(VARNME) < uCase(''' + %trim(pos.VARNME) + ''')';
    Where = 'and';
  ElseIf pos.VARDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(VARDES) < uCase(''' + %trim(pos.VARDES) + ''')';
    Where = 'and';
  ElseIf pos.LIBTYPD <> '';
    SQLStmPos += ' ' + Where + ' ucase(LIBTYPD) < uCase(''' + %trim(pos.LIBTYPD) + ''')';
    Where = 'and';
  ElseIf pos.CMTEXS <> '';
    SQLStmPos += ' ' + Where + ' ucase(CMTEXS) < uCase(''' + %trim(pos.CMTEXS) + ''')';
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
