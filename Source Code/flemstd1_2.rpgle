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

  If FLELIB <> '';
    filterDs.SrtCde = 1;
  ElseIf FLENME <> '';
    filterDs.SrtCde = 2;
  ElseIf FLEDES <> '';
    filterDs.SrtCde = 3;
  ElseIf TBLTYP <> '';
    filterDs.SrtCde = 4;
  ElseIf STSDES <> '';
    filterDs.SrtCde = 5;
  ElseIf FLDCNT <> 0;
    filterDs.SrtCde = 6;
  ElseIf IDXCNT <> 0;
    filterDs.SrtCde = 7;
  ElseIf NTEEXS <> '';
    filterDs.SrtCde = 8;
  ElseIf DCTNME <> '';
    filterDs.SrtCde = 9;
  ElseIf FLEERR <> '';
    filterDs.SrtCde = 10;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLELIB <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLELIB) < uCase(''' + %trim(pos.FLELIB) + ''')';
    Where = 'and';
  ElseIf pos.FLENME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLENME) < uCase(''' + %trim(pos.FLENME) + ''')';
    Where = 'and';
  ElseIf pos.FLEDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLEDES) < uCase(''' + %trim(pos.FLEDES) + ''')';
    Where = 'and';
  ElseIf pos.TBLTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(TBLTYP) < uCase(''' + %trim(pos.TBLTYP) + ''')';
    Where = 'and';
  ElseIf pos.STSDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(STSDES) < uCase(''' + %trim(pos.STSDES) + ''')';
    Where = 'and';
  ElseIf pos.FLDCNT <> 0;
    SQLStmPos += ' ' + Where + ' FLDCNT < ' + %char(pos.FLDCNT);
    Where = 'and';
  ElseIf pos.IDXCNT <> 0;
    SQLStmPos += ' ' + Where + ' IDXCNT < ' + %char(pos.IDXCNT);
    Where = 'and';
  ElseIf pos.NTEEXS <> '';
    SQLStmPos += ' ' + Where + ' ucase(NTEEXS) < uCase(''' + %trim(pos.NTEEXS) + ''')';
    Where = 'and';
  ElseIf pos.DCTNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(DCTNME) < uCase(''' + %trim(pos.DCTNME) + ''')';
    Where = 'and';
  ElseIf pos.FLEERR <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLEERR) < uCase(''' + %trim(pos.FLEERR) + ''')';
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
