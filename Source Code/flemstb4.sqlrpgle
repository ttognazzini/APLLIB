**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// File Master - Build RLA Errors

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs

Dcl-Ds mbrDta;
  libNme like(APLDCT.libNme);
  fleNme like(APLDCT.fleNme);
  mbrNme char(10);
  mbrTyp char(10);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB4');
  End-Pi;

  // delete all RLA errors
  Exec SQL Delete from FLEERR where des = 'RLA error';

  // Look through all the RPGLE source code, find all F specs and DCL-F statements to see if the
  // program references SQL tables

  // Create temp file to hold the results of RLAErrors
  Exec SQL drop table qtemp/temp2;
  Exec SQL
    Create table qtemp/srcError as (
      Select
        libNme,
        fleNme as srcFle,
        mbr as srcMbr,
        fleNme
      From APLDCT)
    Definition Only
    Including Identity
    Including Column Defaults;


  // loop through all RPG source code
  Exec SQL Declare mbrCrs cursor for
    Select
      LibNme,
      sysTables.table_name,
      table_partition,
      source_type
    from SYSTABLES
    join APLLIB on libNme = SYSTABLES.system_table_schema
    join SYSPARTITIONSTAT on (SYSPARTITIONSTAT.system_table_schema,SYSPARTITIONSTAT.system_table_name)
                           = (SYSTABLES.system_table_schema,SYSTABLES.system_table_name)
    where libTyp = 1
      and file_type = 'S'
      and SYSTABLES.table_name not like 'FF%'
      and SYSTABLES.table_name <> 'QRPGSRCSV'
      and source_type in ('RPG','RPGLE','SQLRPGLE','RPT');
  Exec SQL Open mbrCrs;
  Exec SQL fetch next from mbrCrs into :mbrDta;
  DoW SQLState < '02';
    ProcessMember();
    Exec SQL fetch next from mbrCrs into :mbrDta;
  EndDo;
  Exec SQL Close mbrCrs;

  // drop the last alias created
  Exec SQL Drop Alias qtemp/temp;

End-Proc;


// check each source member for which files are being used,
// if the file is an SQL table, log an error message
Dcl-Proc ProcessMember;
  Dcl-S srcDta varChar(256);
  Dcl-S sqlStm varChar(512);

  // create an alias to look at the source code in the member
  sqlStm='Create or Replace Alias qtemp/temp for ' +
       %trim(libNme) +'/' + %trim(fleNme) + '("' + %trim(mbrNme) + '")';
  Exec SQL Execute Immediate :sqlStm;
  If SQLState < '02';

    // loop through each record, only, selecting lines that have an F in position 6 or a DCL-f line
    Exec SQL Declare srcCrs cursor for
      Select srcDta
      from QTEMP/temp
      Where (substr(srcDta,6,1) = 'F' and subStr(srcDta,7,10) <> '')
         or upper(srcDta) like ('%DCL-F%');
    Exec SQL Open srcCrs;
    Exec SQL Fetch next from srcCrs into :srcDta;
    DoW SQLstate < '02';
      checkLine(srcDta);
      Exec SQL Fetch next from srcCrs into :srcDta;
    EndDo;
    Exec SQL Close srcCrs;

  EndIf;

End-Proc;


// check each source member for wich files are being used,
// if the file is an SQL table, log an error message
Dcl-Proc checkLine;
  Dcl-Pi *n;
    srcDta varChar(256);
  End-Pi;
  Dcl-S words char(20) dim(20);
  Dcl-S fileName char(10);

  // if the line has an F in position 6 assume it is fixed format and try to get the file name
  If %subst(srcDta:6:1) = 'F';
    fileName = %subst(srcDta:7:10);
    CheckFile(fileName);

    // if the line contains DCL-F the next word is a file name, check it.
  ElseIf %scan('DCL-F':%upper(srcDta)) > 0;
    // DCl-F has to be the first thing on the line, so the second word it always the file name
    words = %split(srcDta);
    fileName = words(2);
    CheckFile(fileName);

  EndIf;

End-Proc;


// Check if a file is a table and add to error file if it is
Dcl-Proc CheckFile;
  Dcl-Pi *n;
    fileName char(10);
  End-Pi;
  Dcl-S tblTyp char(1);
  Dcl-S fileLib char(10);

  // see if the file is an SQL table or DDS file
  Exec SQL
    Select table_type, system_table_schema into :tblTyp, :fileLib
    From sysTables
    join APLLIB on libNme = system_table_schema
    where system_table_name = :fileName
    Order by libTyp
    limit 1;

  // if the table is an SQL table log error
  If SQLState = '00000' and tblTyp = 'T';
    Exec SQL insert into FLEERR
          ( fleLib, fleNme, Des,
            errMsg,
            crtDtm, crtUsr, crtJob, crtPgm,
            mntDtm, mntUsr, mntJob, mntPgm)
    values(:fileLib,:fileName, 'RLA error',
            'SQL tables should not be used for RLA (record level access). This means that they should +
             never appear on an RPG f spec for Dcl-F statement. Source member ' || trim(:libNme) ||
             '/' || trim(:fleNme) || '.' || trim(:mbrNme) || ' references this file.',
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
            Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  EndIf;


End-Proc;
