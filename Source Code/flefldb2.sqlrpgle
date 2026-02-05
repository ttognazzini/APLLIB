**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - full rebuild all files from dictionary

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB7PR // full rebuild file, delete and copy data back

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDB2');
  End-Pi;

  // Run FLEFLDB8 for all files
  // It cannot do any file used by FLEFLDB8 or the program blows up
  Exec SQL Declare sqlCrs Cursor For
    Select FleLib,fleNme
    From FLEMST
    Where acvRow = '1'
    Order by fleNme;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs Into :fleLib, :fleNme;
  DoW sqlState < '02';
    FLEFLDB7(fleLib:fleNme);
    Exec SQL Fetch Next From sqlCrs Into :fleLib, :fleNme;
  EndDo;
  Exec SQL Close sqlCrs;

End-Proc;
