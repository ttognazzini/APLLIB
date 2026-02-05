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

  If FLDLVL <> '';
    filterDs.SrtCde = 1;
  ElseIf FLDSEQ <> 0;
    filterDs.SrtCde = 2;
  ElseIf PRIKEY <> '';
    filterDs.SrtCde = 3;
  ElseIf FLDNME <> '';
    filterDs.SrtCde = 4;
  ElseIf COLTXT <> '';
    filterDs.SrtCde = 5;
  ElseIf STSDES <> '';
    filterDs.SrtCde = 6;
  ElseIf TYP <> '';
    filterDs.SrtCde = 7;
  ElseIf FLDENMD <> '';
    filterDs.SrtCde = 8;
  ElseIf ALWNUL <> '';
    filterDs.SrtCde = 9;
  ElseIf NTEEXS <> '';
    filterDs.SrtCde = 10;
  ElseIf AUDFLD <> '';
    filterDs.SrtCde = 11;
  ElseIf COLNME <> '';
    filterDs.SrtCde = 12;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLDLVL <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDLVL) < uCase(''' + %trim(pos.FLDLVL) + ''')';
    Where = 'and';
  ElseIf pos.FLDSEQ <> 0;
    SQLStmPos += ' ' + Where + ' FLDSEQ < ' + %char(pos.FLDSEQ);
    Where = 'and';
  ElseIf pos.PRIKEY <> '';
    SQLStmPos += ' ' + Where + ' ucase(PRIKEY) < uCase(''' + %trim(pos.PRIKEY) + ''')';
    Where = 'and';
  ElseIf pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.COLTXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(COLTXT) < uCase(''' + %trim(pos.COLTXT) + ''')';
    Where = 'and';
  ElseIf pos.STSDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(STSDES) < uCase(''' + %trim(pos.STSDES) + ''')';
    Where = 'and';
  ElseIf pos.TYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(TYP) < uCase(''' + %trim(pos.TYP) + ''')';
    Where = 'and';
  ElseIf pos.FLDENMD <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDENMD) < uCase(''' + %trim(pos.FLDENMD) + ''')';
    Where = 'and';
  ElseIf pos.ALWNUL <> '';
    SQLStmPos += ' ' + Where + ' ucase(ALWNUL) < uCase(''' + %trim(pos.ALWNUL) + ''')';
    Where = 'and';
  ElseIf pos.NTEEXS <> '';
    SQLStmPos += ' ' + Where + ' ucase(NTEEXS) < uCase(''' + %trim(pos.NTEEXS) + ''')';
    Where = 'and';
  ElseIf pos.AUDFLD <> '';
    SQLStmPos += ' ' + Where + ' ucase(AUDFLD) < uCase(''' + %trim(pos.AUDFLD) + ''')';
    Where = 'and';
  ElseIf pos.COLNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(COLNME) < uCase(''' + %trim(pos.COLNME) + ''')';
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
