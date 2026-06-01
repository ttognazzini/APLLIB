**free
Ctl-Opt OPTION(*SrcStmt) DFTACTGRP(*NO) BNDDIR('APLLIB') Main(Main);

// this run the job log for all active jobs for a workstation, adds the entries
// into a temp file and queries the file

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO,
         DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n;
    jobNme char(10);
  End-Pi;
  Dcl-S job varchar(28);

  // Create a temporary job log table
  Exec SQL
  Create or replace table QTEMP.QJOBLOGTP as (
    Select JOB, MSGID, MSGTYPE, SEVERITY, POSTED, MSGTEXT, FROM_USER,
           SENDER, TO_PGM, SECLVL, ORDINAL_POSITION
    from table(QJOBLOG())
  ) Definition Only;

  // loop through the active jobs for this workstation
  Exec SQL Declare sqlCrs cursor for
  SELECT JOB_NAME
  FROM TABLE(QSYS2.ACTIVE_JOB_INFO(
              JOB_NAME_FILTER => :jobNme)) X
  ORDER BY ELAPSED_TOTAL_DISK_IO_COUNT DESC;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch next from sqlCrs into :job;
  DoW sqlState < '02';
    // add records for this job into the temporary table
    Exec SQL Insert into QTEMP.QJOBLOGTP
          (JOB, MSGID, MSGTYPE, SEVERITY, POSTED, MSGTEXT, FROM_USER,
           SENDER, TO_PGM, SECLVL, ORDINAL_POSITION)
    Select JOB, MSGID, MSGTYPE, SEVERITY, POSTED, MSGTEXT, FROM_USER,
           SENDER, TO_PGM, SECLVL, ORDINAL_POSITION
    from table(qjoblog(:job));
    Exec SQL Fetch next from sqlCrs into :job;
  EndDo;
  Exec SQL Close sqlCrs;

  // run a query over the temp file
  #$CMD('SQL ''SELECT JOB, MSGID, MSGTYPE, SEVERITY, POSTED, MSGTEXT +
             FROM qtemp.QJObLOGtp +
             where msgId = ''''CPF5027'''' '' ');

End-Proc;
