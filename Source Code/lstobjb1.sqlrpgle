**Free
Ctl-Opt Option(*SrcStmt:*nounref) DftActGrp(*No) actgrp(*New) BndDir('APLLIB/APLLIB') Main(Main);

// Build Tables of Objects and Libraries with Sizes


/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs


// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('TMP023');
    library char(10);
    EmailTo char(50);
  End-Pi;

  Dcl-S sqlStm varchar(2000);

  // Add APLLIB to LIBL to use the SQL command, ignore errors
  #$CMD('ADDLIBLE APLLIB *LAST':1);

  // build table of all objects
  Exec SQL Drop Table APLLIB.LSTOBJOBJ;
  sqlStm = '+
    Create Table APLLIB/LSTOBJOBJ as ( +
        Select +
          objLib "Library", +
          objName "Object", +
          objType "Object Type", +
          dec(objSize/1000000,10,3) "Object Size(mb)", +
          objCreated "Created Date", +
          objText "Text", +
          date(last_used_timestamp) "Last Used" +
        From Table (QSYS2.OBJECT_STATISTICS('''+ %trim(library) + ''',''*ALL'')) +
        ) With Data';
  Exec SQL Execute Immediate :sqlStm;

  // build summary table of libraries
  Exec SQL Drop Table APLLIB.LSTOBJLIB;
  Exec SQL
    Create table APLLIB.LSTOBJLIB as (
    Select
      "Library",
      coalesce(schema_text,'') "Library Description",
      sum("Object Size(mb)") "Library Size(mb)",
      max("Last Used") "Last Used",
      date(creation_timestamp) "Created"
    From APLLIB/LSTOBJOBJ
    Left Join sysSchemas on system_schema_name = "Library"
    Group by "Library",coalesce(schema_text,''), creation_timestamp
    ) With Data;


  // Email the results as an Excel file
  #$cmd('+
    SQL ''Select * From APLLIB/LSTOBJLIB Order by "Library"'' +
        ACTION(*EMAIL) +
        EMAIL(''' + %trim(emailTo) + ''') +
        FILENAME(''Libraries and Objects With Sizes'') +
        TYPE(*XLS) +
        SHEET(Libraries) +
        TITLE1(''Libraries with Sizes'') +
        TITLE2(''For Library ' + %trim(library) + ''') +
        TITLE3(''Run at ' + %char(%timestamp():*iso) + ''') +
        SUBJECT(''Libraries and Objects with sizes (LSTOBJ)'') +
        MESSAGE(''Attached is a list of recteiver to auto close.'' *TEXTHTML) +
        ADDSQL((''Select * From APLLIB.LSTOBJOBJ'' +
                OBJECTS +
                ''List of objects with sizes'' ''For library ' + %trim(library) +'''))');

End-Proc;
