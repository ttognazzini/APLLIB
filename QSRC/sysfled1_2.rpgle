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
  ElseIf FLENME <> '';
    filterDs.SrtCde = 2;
  ElseIf FLEDES <> '';
    filterDs.SrtCde = 3;
  ElseIf NATTYP <> '';
    filterDs.SrtCde = 4;
  ElseIf FLETYP <> '';
    filterDs.SrtCde = 5;
  ElseIf SQLTYP <> '';
    filterDs.SrtCde = 6;
  ElseIf TRGCNT <> 0;
    filterDs.SrtCde = 7;
  ElseIf LIBTYPD <> '';
    filterDs.SrtCde = 8;
  ElseIf CMTEXS <> '';
    filterDs.SrtCde = 9;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.LIBNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(LIBNME) < uCase(''' + %trim(pos.LIBNME) + ''')';
    Where = 'and';
  ElseIf pos.FLENME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLENME) < uCase(''' + %trim(pos.FLENME) + ''')';
    Where = 'and';
  ElseIf pos.FLEDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLEDES) < uCase(''' + %trim(pos.FLEDES) + ''')';
    Where = 'and';
  ElseIf pos.NATTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(NATTYP) < uCase(''' + %trim(pos.NATTYP) + ''')';
    Where = 'and';
  ElseIf pos.FLETYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLETYP) < uCase(''' + %trim(pos.FLETYP) + ''')';
    Where = 'and';
  ElseIf pos.SQLTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(SQLTYP) < uCase(''' + %trim(pos.SQLTYP) + ''')';
    Where = 'and';
  ElseIf pos.TRGCNT <> 0;
    SQLStmPos += ' ' + Where + ' TRGCNT < ' + %char(pos.TRGCNT);
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
