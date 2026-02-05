**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Nightly Scheduled Change Processor

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB8PR   // Update the table
/Copy QSRC,FLEFLDB1PR   // sync FLEMST and physical file

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);
Dcl-S skipped Ind;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB6');
  End-Pi;
  Dcl-S tries packed(2);

  // loop through all tables that have an update scheduled
  // if the file is locked skip it, if one is skipped wait 5 minutes and try again, up to 5 times
  skipped = *on;
  tries = 0;
  DoU not skipped or tries >= 5;

    skipped = *off;
    Exec SQL Declare sqlCrs cursor for
      Select fleLib, fleNme
      from FLEMST
      Where acvRow = '1'
        and chgScd = 'Y';
    Exec SQL Open sqlCrs;
    Exec SQL fetch next from sqlCrs into :fleLib,:fleNme;
    DoW SQLState < '02';
      ProcessFile();
      Exec SQL fetch next from sqlCrs into :fleLib,:fleNme;
    EndDo;
    Exec SQL Close sqlCrs;

    // If any files were skipped, wiat 5 minutes and try again, only try up to five times
    If skipped;
      #$WAIT(300);
      tries += 1;
      // after the 5th try add a log entry for any files that were still skipped
      If tries >= 5;
        LogLocks();
      EndIf;
    EndIf;
  EndDo;

End-Proc;


Dcl-Proc ProcessFile;
  Dcl-S locked Ind;

  // if there is a lock on the file skip it
  Exec SQL
    Select '1' into :locked
    from object_lock_info
    WHERE SYSTEM_OBJECT_SCHEMA = :fleLib
      AND SYSTEM_OBJECT_NAME = :fleNme
      AND OBJECT_TYPE = '*FILE'
    limit 1;
  If locked;
    skipped = *on;
    Return;
  EndIf;

  // update the file and reset the change scheduled flag
  FLEFLDB8(fleLib:fleNme);
  Exec SQL update FLEMST set chgScd = 'N' where (fleLib,fleNme) = (:fleLib,:fleNme);

  // call the fix program to update the status and re-check for errors
  FLEFLDB1(fleLib:fleNme);

End-Proc;


Dcl-Proc LogLocks;
  Dcl-S fleMstIdn like(APLDCT.fleMstIdn);
  Dcl-S lockJobs varChar(300);
  Dcl-S job varChar(30);

  Exec SQL Declare logCrs cursor for
    Select fleLib, fleNme
    from FLEMST
    Where acvRow = '1'
      and chgScd = 'Y';
  Exec SQL Open logCrs;
  Exec SQL fetch next from logCrs into :fleLib,:fleNme;
  DoW SQLState < '02';

    // get the file master Id to put in the log record
    Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

    // get the first few file locks on the file, only include up to 10 of them
    Exec Sql declare lockCrs cursor for
      Select distinct job_name
      FROM OBJECT_LOCK_INFO
      Where SYSTEM_OBJECT_SCHEMA = 'APLLIB'
        and SYSTEM_OBJECT_NAME = 'DBRMST'
        and OBJECT_TYPE = '*FILE'
      limit 10;
    Exec SQL open lockCrs;
    Exec SQL Fetch Next from lockCrs into :job;
    DoW sqlState < '02';
      If lockJobs = '';
        lockJobs = job;
      Else;
        lockJobs += ' &N ' + job;
      EndIf;
      Exec SQL Fetch Next from lockCrs into :job;
    EndDo;
    Exec SQL open lockCrs;

    // Add the log entry
    Exec SQL Insert Into FLELOG
            ( FLELIB, FLENME, FLEMSTIDN, LOGTYP, LOGDES, LOGMSG,
              CRTDTM, CRTUSR, CRTJOB,CRTPGM,
              MNTDTM, MNTUSR, MNTJOB,MNTPGM)
      values( :fleLib,:fleNme,:fleMstIdn,'Scd Chg Error','File not changed, locked.',
              'File ' || trim(:fleLib) || '/' || trim(:fleNme) || ' can not be updated because it is locked. &N The +
              following list contains the jobs that are locking the file. Only the first 10 jobs are included: &N '
              || :lockJobs,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);

    Exec SQL fetch next from logCrs into :fleLib,:fleNme;
  EndDo;
  Exec SQL Close logCrs;

End-Proc;
