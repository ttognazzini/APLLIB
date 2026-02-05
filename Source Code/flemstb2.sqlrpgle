**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Email File Error List

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTB4PR   // rebuild RLA errors
/Copy QSRC,FLEMSTB8PR   // rebuild errors for all files

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB2');
  End-Pi;
  Dcl-S emails Varchar(1000);
  Dcl-S sqlStm varchar(1000);

  // update all RLA errors
  FLEMSTB4();

  // run FLEMSTB3 for all files
  FLEMSTB8();

  // Get email addresses for all users that have an error
  Exec SQL
    With
      crt as (
        Select distinct acEmail
        from FLEERR
        join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEERR.fleLib,FLEErr.fleNme)
        join ACCESSPF on acUPrf = FLEMST.crtUsr
      ),
      mnt as (
        Select distinct acEmail
        from FLEERR
        join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEERR.fleLib,FLEErr.fleNme)
        join ACCESSPF on acUPrf = FLEMST.mntUsr
      )
    Select listagg(distinct '(' || trim(acEmail) || ')',' ') emails
    into :emails
    from (Select * from crt
          union all
          Select * from mnt
         );

  sqlStm = '+
  Select +
    FLEERR.fleLib "Library", +
    FLEERR.fleNme "File", +
    Des "Description", +
    fldNme "Field", +
    idxNme "Index", +
    errMsg "Message" +
  from fleerr +
  join flemst on (FLEMST.fleLib, FLEMST.fleNme) = (FLEERR.fleLib,FLEERR.fleNme) +
  where FLEMST.acvRow = ''1''';


  // email the report
  #$CMD('SQL ''' + #$DBLQ(sqlStm) + ''' +
         ACTION(*EMAIL) +
         EMAIL(' + emails +') +
         FILENAME(''File Errors'') +
         TYPE(*XLS) +
         SHEET(''File Errors'') +
         TITLE1(''File System Errors'') +
         TITLE2(''Program: FLEMSTB2VW'') +
         TITLE3(''Ran on: '+ %char(%date():*USA)+''') +
         SUBJECT(''File System Errros (FLEMSTB2)'') +
         MESSAGE(''Attached is a list of file system errors. You are receiving this report because +
                   you were the user that created one of the files with an error or you are the +
                   user that last updated one of the files with an error.<br><br>+
                   Please reveiw the report and correct any errors you are responsible for.'' *TEXTHTML)');

End-Proc;
