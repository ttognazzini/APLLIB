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

  If USRPRF <> '';
    filterDs.SrtCde = 1;
  ElseIf USRNME <> '';
    filterDs.SrtCde = 2;
  ElseIf ROLNME <> '';
    filterDs.SrtCde = 3;
  ElseIf APRDES <> '';
    filterDs.SrtCde = 4;
  ElseIf ACVDES <> '';
    filterDs.SrtCde = 5;
  ElseIf CMPDES <> '';
    filterDs.SrtCde = 6;
  EndIf;

End-Proc;


// Find the record number of the entered position to data
Dcl-Proc PositionSFL;
  Dcl-S SQLStmPos Varchar(10000);

  SQLStmPos = sqlStm;

  If pos.USRPRF <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRPRF) < uCase(''' + %trim(pos.USRPRF) + ''')';
    Where = 'and';
  ElseIf pos.USRNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(USRNME) < uCase(''' + %trim(pos.USRNME) + ''')';
    Where = 'and';
  ElseIf pos.ROLNME <> '';
    SQLStmPos += ' ' + Where + ' ucase(ROLNME) < uCase(''' + %trim(pos.ROLNME) + ''')';
    Where = 'and';
  ElseIf pos.APRDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(APRDES) < uCase(''' + %trim(pos.APRDES) + ''')';
    Where = 'and';
  ElseIf pos.ACVDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(ACVDES) < uCase(''' + %trim(pos.ACVDES) + ''')';
    Where = 'and';
  ElseIf pos.CMPDES <> '';
    SQLStmPos += ' ' + Where + ' ucase(CMPDES) < uCase(''' + %trim(pos.CMPDES) + ''')';
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
