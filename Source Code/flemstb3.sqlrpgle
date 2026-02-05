**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Build Errors

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);
Dcl-S chkSrc char(1);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB3');
    pmrFleLib like(APLDCT.fleLib);
    pmrFleNme like(APLDCT.fleNme);
    pmrChkSrc char(1) Options(*nopass); // send a Y or N, defaults to Y
  End-Pi;
  Dcl-S fldNme like(APLDCT.fldNme);
  Dcl-S fleFldIdn like(APLDCT.fleFldIdn);
  Dcl-S srcLib char(10);
  Dcl-S srcFle char(10);
  Dcl-S errCnt packed(9);

  // move parameters to globals
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  If %parms >= 3 and %addr(pmrChkSrc) <> *null;
    chkSrc = pmrChkSrc;
  Else;
    chkSrc = 'Y';
  EndIf;

  // delete all error message this program updates
  Exec SQL Delete from FLEERR where (fleLib,fleNme) = (:fleLib,:fleNme)
           and des in ('Table missing acvRow column',
                       'Table missing id',
                       'Table missing primary key',
                       'File missing dictionary reference',
                       'File missing table name',
                       'Field not in dictionary',
                       'Table not in APLLIB',
                       'Id unique index missing',
                       'Table missing crtDtm column',
                       'Table missing crtUsr column',
                       'Table missing crtJob column',
                       'Table missing crtPgm column',
                       'Table missing mntDtm column',
                       'Table missing mntUsr column',
                       'Table missing mntJob column',
                       'Table missing mntPgm column',
                       'Trigger program missing'
                       );

  // Only add errors for non-view type files
  found = *off;
  Exec SQL select '1' into :found from sysTables where (system_table_schema,system_table_name,table_type)
                                                     = (:fleLib,:fleNme,'V');
  If not found;

    CheckField('acvRow');
    CheckField('crtDtm');
    CheckField('crtUsr');
    CheckField('crtJob');
    CheckField('crtPgm');
    CheckField('mntDtm');
    CheckField('mntUsr');
    CheckField('mntJob');
    CheckField('mntPgm');

    // delete file missing id error and add it back if it still exists
    found = *off;
    Exec SQL select '1' into :found from FLEFLD where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,trim(:fleNme) || 'IDN');
    If not found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Table missing id',
              'Every table should have and identity field. The field name must be the file name followed by IDN. +
              For example the FLEMST file must contain a field called FLEMSTIDN.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

    // delete file missing primary key error and add it back if it still exists
    found = *off;
    Exec SQL select '1' into :found from FLEFLD where (fleLib,fleNme,prikey) = (:fleLib,:fleNme,'Y') limit 1;
    If not found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Table missing primary key',
              'Every table should have at least one field flagged as a primary key. The primary key must be unique. +
               For files where this does not make sense, like a log file, use the identity field as the primary key.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

    // make sure the file references a dictionary
    found = *off;
    Exec SQL Select '1' into :found from FLEMST where (fleLib,fleNme,dctNme) = (:fleLib,:fleNme,'');
    If found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'File missing dictionary reference',
              'Every table should reference a dictionary.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

    // make sure the file has a table name/alais
    found = *off;
    Exec SQL Select '1' into :found from FLEMST where (fleLib,fleNme,tblNme) = (:fleLib,:fleNme,'');
    If found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'File missing table name',
              'Every table should have a table name.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

    // Make sure each field exists in the dictionary
    Exec SQL Declare dctCrs cursor for
      Select FLEFLD.fldNme, FLEFLD.fleFldIdn
      from FLEFLD
      join FLEMST on (FLEMST.fleLib, FLEMST.fleNme) = (FLEFLD.fleLib, FLEFLD.fleNme)
      left join DCTFLD on (DCTFLD.dctNme, DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
      left join sysTables on (system_table_schema, system_table_name) = (FLEFLD.fleLib, FLEFLD.fleNme)
      Where (FLEFLD.fleLib, FLEFLD.fleNme) = (:fleLib,:fleNme)
        and DCTFLD.fldNme is null -- not in dictionary
        and table_type <> 'V'; -- exclude views
    Exec SQL open dctCrs;
    Exec SQL Fetch next from dctCrs into :fldNme, :fleFldIdn;
    DoW sqlState < '02';
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des, fldNme, fleFldIdn,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Field not in dictionary', :fldNme, :fleFldIdn,
              'Every field in every table should be referenced from the dictionary. When creating new tables this +
               happens no matter what, but for imported tables they may be missing.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
      Exec SQL Fetch next from dctCrs into :fldNme, :fleFldIdn;
    EndDo;

    // SQL table not in APLLIB, only if it is an SQL table
    If not(fleLib in %list('APLLIB'));
      found = *off;
      Exec SQL Select '1' into :found from sysTables where (system_table_schema,system_table_name,table_type)
                                                        = (:fleLib, :fleNme, 'T');
      If found;
        Exec SQL insert into FLEERR
              ( fleLib, fleNme, Des,
                errMsg,
                crtDtm, crtUsr, crtJob, crtPgm,
                mntDtm, mntUsr, mntJob, mntPgm)
        values(:fleLib,:fleNme, 'Table not in APLLIB',
                'All SQL tables should be in APLLIB.',
                Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
                Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
      EndIf;
    EndIf;

    // table has source code
    If chkSrc = 'Y';
      Exec SQL
        Select system_table_schema, table_name into :srcLib, :srcFle
        from sysPartitionStat
        join APLLIB on libNme = system_table_schema
        where table_partition = :fleNme
          and table_name in ('QSRC','QDDSSRC')
        limit 1;
      If SQLstate < '02';
        Exec SQL insert into FLEERR
              ( fleLib, fleNme, Des,
                errMsg,
                crtDtm, crtUsr, crtJob, crtPgm,
                mntDtm, mntUsr, mntJob, mntPgm)
        values(:fleLib,:fleNme, 'Has source code',
                'No SQL table should have source code. Source code for this table exists in ' || trim(:srcLib) ||
                '/' || Trim(:srcFle) || '.',
                Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
                Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
      EndIf;
    EndIf;

    // index exists on id
    found = *off;
    Exec SQL
      Select '1' into :found
      From FLEIDX
      left join IDXFLD on (IDXFLD.idxLib, IDXFLD.idxNme) = (FLEIDX.idxLib, FLEIDX.idxNme)
      where (FLEIDX.fleLib, FLEIDX.fleNme) = ('APLLIB','FLEMST')
      Group by FLEIDX.fleLib, FLEIDX.fleNme, FLEIDX.idxLib,FLEIDX.idxNme
      Having listagg(idxfld) = trim(FLEIDX.fleNme) || 'IDN';
    If not found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Id unique index missing',
              'All tables should have a unique index on id.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

    // Make sure the trigger exists for the table
    found = *off;
    Exec SQL
      Select '1' into :found
      From sysTriggers
      Where trigger_program_library = :fleLib
        and trigger_program_name = trim(:fleNme) || 'TRG'
        and event_object_schema = :fleLib
        and event_object_table = :fleNme;
    If not found;
      Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Trigger program missing',
              'All tables should have a trigger autocreated for them.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
    EndIf;

  EndIf;

  // set the error flag in FLEMST
  Exec SQL Select count(*) into :errCnt from FLEERR where (fleLib,fleNme) = (:fleLib,:fleNme);
  If errCnt <> 0;
    Exec SQL update FLEMST set fleErr = 'Y' where (fleLib,fleNme) = (:fleLib, :fleNme);
  Else;
    Exec SQL update FLEMST set fleErr = 'N' where (fleLib,fleNme) = (:fleLib, :fleNme);
  EndIf;


End-Proc;


// check for a missing field
Dcl-Proc CheckField;
  Dcl-Pi *n;
    pmrFldNme like(APLDCT.fldNme) const;
  End-Pi;

  found = *off;
  Exec SQL select '1' into :found from FLEFLD where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,upper(:pmrFldNme));
  If not found;
    Exec SQL insert into FLEERR
            ( fleLib, fleNme, Des,
              errMsg,
              crtDtm, crtUsr, crtJob, crtPgm,
              mntDtm, mntUsr, mntJob, mntPgm)
      values(:fleLib,:fleNme, 'Table missing ' || trim(:pmrFldNme) || ' column',
              'Every SQL table should have an ' || trim(:pmrFldNme) || ' field.',
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
              Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  EndIf;

End-Proc;

