**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Email File Error List

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTB3PR   // rebuild errors for one file

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB8');
  End-Pi;

  // run FLEMSTB3 for all files
  Exec SQL Declare sqlCrs Cursor For
    Select FleLib,fleNme
    From FLEMST
    Where acvRow = '1';
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs Into :fleLib, :fleNme;
  DoW sqlState < '02';
    FLEMSTB3(fleLib:fleNme);
    Exec SQL Fetch Next From sqlCrs Into :fleLib, :fleNme;
  EndDo;
  Exec SQL Close sqlCrs;

End-Proc;
