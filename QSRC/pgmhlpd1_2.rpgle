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

  If FLDROW <> 0;
    filterDs.SrtCde = 1;
  ElseIf FLDCOL <> 0;
    filterDs.SrtCde = 2;
  ElseIf FLDNME <> '';
    filterDs.SrtCde = 3;
  ElseIf VAL <> '';
    filterDs.SrtCde = 4;
  ElseIf HLPTYPD <> '';
    filterDs.SrtCde = 5;
  ElseIf LNECNT <> 0;
    filterDs.SrtCde = 6;
  ElseIf TXT <> '';
    filterDs.SrtCde = 7;
  ElseIf REFFLE <> '';
    filterDs.SrtCde = 8;
  ElseIf REFFLD <> '';
    filterDs.SrtCde = 9;
  ElseIf FLDDES <> '';
    filterDs.SrtCde = 10;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLDROW <> 0;
    SQLStmPos += ' ' + Where + ' FLDROW < ' + %char(pos.FLDROW);
    Where = 'and';
  ElseIf pos.FLDCOL <> 0;
    SQLStmPos += ' ' + Where + ' FLDCOL < ' + %char(pos.FLDCOL);
    Where = 'and';
  ElseIf pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.VAL <> '';
    SQLStmPos += ' ' + Where + ' ucase(VAL) < uCase(''' + %trim(pos.VAL) + ''')';
    Where = 'and';
  ElseIf pos.HLPTYPD <> '';
    SQLStmPos += ' ' + Where + ' ucase(HLPTYPD) < uCase(''' + %trim(pos.HLPTYPD) + ''')';
    Where = 'and';
  ElseIf pos.LNECNT <> 0;
    SQLStmPos += ' ' + Where + ' LNECNT < ' + %char(pos.LNECNT);
    Where = 'and';
  ElseIf pos.TXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(TXT) < uCase(''' + %trim(pos.TXT) + ''')';
    Where = 'and';
  ElseIf pos.REFFLE <> '';
    SQLStmPos += ' ' + Where + ' ucase(REFFLE) < uCase(''' + %trim(pos.REFFLE) + ''')';
    Where = 'and';
  ElseIf pos.REFFLD <> '';
    SQLStmPos += ' ' + Where + ' ucase(REFFLD) < uCase(''' + %trim(pos.REFFLD) + ''')';
    Where = 'and';
  ElseIf pos.FLDDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDDES) < uCase(''' + %trim(pos.FLDDES) + ''')';
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
