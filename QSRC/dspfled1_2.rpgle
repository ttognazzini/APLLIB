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

  If FLDSEQ <> 0;
    filterDs.SrtCde = 1;
  ElseIf FLDNME <> '';
    filterDs.SrtCde = 2;
  ElseIf FLDTYP <> '';
    filterDs.SrtCde = 3;
  ElseIf FLDTXT <> '';
    filterDs.SrtCde = 4;
  ElseIf NMESQL <> '';
    filterDs.SrtCde = 5;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.FLDSEQ <> 0;
    SQLStmPos += ' ' + Where + ' FLDSEQ < ' + %char(pos.FLDSEQ);
    Where = 'and';
  ElseIf pos.FLDNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDNME) < uCase(''' + %trim(pos.FLDNME) + ''')';
    Where = 'and';
  ElseIf pos.FLDTYP <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDTYP) < uCase(''' + %trim(pos.FLDTYP) + ''')';
    Where = 'and';
  ElseIf pos.FLDTXT <> '';
    SQLStmPos += ' ' + Where + ' ucase(FLDTXT) < uCase(''' + %trim(pos.FLDTXT) + ''')';
    Where = 'and';
  ElseIf pos.NMESQL <> '';
    SQLStmPos += ' ' + Where + ' ucase(NMESQL) < uCase(''' + %trim(pos.NMESQL) + ''')';
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
