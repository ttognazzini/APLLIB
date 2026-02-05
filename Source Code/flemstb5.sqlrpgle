**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Add all SQL tables in production libraries fo FLEMST
// This should only need to be run one time

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB1PR   // sync FLEMST and physical file

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB5');
  End-Pi;

  // loop through all SQL tables in production libraries and add each one
  Exec SQL Declare sqlCrs cursor for
    Select
     libNme,
     system_table_name
    from APLLIB
    join sysTables on system_table_schema = libNme
    Where libTyp = '1'
      and table_type = 'T';
  Exec SQL Open sqlCrs;
  Exec SQL fetch next from sqlCrs into :fleLib,:fleNme;
  DoW SQLState < '02';
    FLEFLDB1(fleLib:fleNme);
    Exec SQL fetch next from sqlCrs into :fleLib,:fleNme;
  EndDo;
  Exec SQL Close sqlCrs;


End-Proc;
