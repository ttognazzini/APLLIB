**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Safely rebuild a file, like fmtopt(*map)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB8PR // Rebuild-update a file, it's indexes and trigger
/Copy QSRC,FLEMSTB3PR // Rebuild file errors

Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);
Dcl-S fleMstIdn like(APLDCT.fleMstIdn);
Dcl-S sqlStm Varchar(10000);
Dcl-S lstIdn int(20);
Dcl-S rcdCnt packed(15);

Dcl-Ds idxDta;
  idxLib    like(APLDCT.idxLib);
  idxNme    like(APLDCT.idxNme);
End-Ds;
Dcl-Ds vewDta;
  vewLib    like(APLDCT.fleLib);
  vewNme    like(APLDCT.fleNme);
End-Ds;


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n extPgm('FLEFLDB7');
    pmrFleLib like(APLDCT.fleLib);
    pmrFleNme like(APLDCT.fleNme);
  End-Pi;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;

  // get the file master id, used for log entry
  Exec SQL Select fleMstIdn Into :fleMstIdn From fleMst Where (fleLib,fleNme) = (:fleLib,:fleNme);

  // Delete the table indexes
  Exec SQL Declare idxCrs Cursor For
    Select idxLib, idxNme From FLEIDX
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
  Exec SQL Open idxCrs;
  Exec SQL Fetch Next From idxCrs Into :idxDta;
  DoW sqlState < '02';
    sqlStm = 'Drop Index ' + %trim(idxLib) + '.' + %trim(idxNme);
    Exec SQL Execute Immediate :sqlStm;
    Exec SQL Fetch Next From idxCrs Into :idxDta;
  EndDo;
  Exec SQL Close idxCrs;

  // Delete the trigger program
  sqlStm = 'Drop Trigger ' + %trim(fleLib) + '.' + %trim(fleNme) + 'TRG';
  Exec SQL Execute Immediate :sqlStm;

  // Add the temporary library to the library list incase a requried file is being rebuilt
  // for example if rebuild FELMST, it still needs to be accessable, so when it is moved to
  // the temporary lbirary, it still needs to eb in the library list.
  #$CMD('CRTLIB APLLIBFLED':1);
  #$CMD('RMVLIBLE APLLIBFLED':1);
  #$CMD('ADDLIBLE APLLIBFLED':1);

  // move all views into the temp library, save them to a temp file so we know where to put them back to
  SaveViews();

  // move the existing table into a temp library
  Monitor;
    #$CMD('MOVOBJ OBJ('+%trim(fleLib)+'/'+%trim(fleNme)+') OBJTYPE(*FILE) TOLIB(APLLIBFLED)':2);
  On-Error;
    #$DSPWIN('Rebuild canceled, the file could not be moved to a save library. +
              View the job log For more inFormation.');
    AddLog('Full File Rebuild Error':'File ' +%trim(fleLib) + '.'+ %trim(fleNme) +' was not fully recreated.':
           'The file was not able to be moved to the temporary location. +
            This could have been because of a file lock. +
            Review the job log of the rebuild job for more information.');
    // create views in their original libraries, this re-attaches them to the new file
    RestoreViews();
    ResetIdn();
    #$CMD('RMVLIBLE APLLIBFLED':1);
    // rebuild file system errors
    FLEMSTB3(fleLib:fleNme);
    Return;
  EndMon;

  // recreate the table, indexes and trigger program
  FLEFLDB8(fleLib:fleNme);

  // see if there is any data in the file before copying the data back
  Clear rcdCnt;
  sqlStm = 'Select count(*) from APLLIBFLED/'+%trim(fleNme);
  Exec SQL Prepare cntStm From :sqlStm;
  Exec SQL Declare cntCrs Cursor For cntStm;
  Exec SQL Open cntCrs;
  Exec SQL Fetch Next From cntCrs Into :rcdCnt;
  Exec SQL Close cntCrs;

  // copy the data back in, must use the OVERIDDING SYSTEM VALUES option to perserve the identities
  If rcdCnt > 0;
    BuildCopyStatement();
    Exec SQL Execute Immediate :sqlStm;
    // only delete the temp file if there are no errors, otherwise through a big error message
    If sqlState >= '02';
      #$DSPWIN('MAJOR ERROR, data not copied back. View the job log for more information. The +
                existing data is still in file APLLIBFLED/' +%trim(fleNme) + '.');
      AddLog('Full Rebuild Error':'File ' +%trim(fleLib) + '.'+ %trim(fleNme) +' rebuild error, data loss.':
              'MAJOR ERROR, data not copied back. View the job log for more information. The +
              existing data is still in file APLLIBFLED/' +%trim(fleNme) + '.' +
              'SQLState  . . . :   ' + sqlState +
              '&N SQLStm  . . . . :   ' + sqlStm +
              '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
            #$SQLMessageHelp(sqlCode:sqlErrMc));
    ElseIf sqlState > '00000';
      #$DSPWIN('Minor error, data was copied back, however some errors occrued. +
                View the job log For more inFormation. The +
                original data is still in file APLLIBFLED/' +%trim(fleNme) + '.');
      AddLog('Full Rebuild Error':'File ' +%trim(fleLib) + '.'+ %trim(fleNme) +' rebuild error, data loss.':
              'Minor error, data was copied back, however errors were logged. View the job log for more information. +
               The existing data is still in file APLLIBFLED/' +%trim(fleNme) + '.' +
              'SQLState  . . . :   ' + sqlState +
              '&N SQLStm  . . . . :   ' + sqlStm +
              '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
              #$SQLMessageHelp(sqlCode:sqlErrMc));
    Else;
      AddLog('Full File Rebuild':'File ' +%trim(fleLib) + '.'+ %trim(fleNme) +' was fully recreated.':
              'The file was renamed, rebuilt from scratch and all data was copied back in.');
      // delete file in the temp library
      sqlStm = 'Drop Table APLLIBFLED.' + %trim(fleNme);
      Exec SQL Execute Immediate :sqlStm;
    EndIf;
  Else;
    AddLog('Full File Rebuild':'File ' +%trim(fleLib) + '.'+ %trim(fleNme) +' was fully recreated.':
          'There was no data so the file was just rebuilt from scratch.');
    // delete file in the temp library
    sqlStm = 'Drop Table APLLIBFLED.' + %trim(fleNme);
    Exec SQL Execute Immediate :sqlStm;
  EndIf;

  // create views in their original libraries, this re-attaches them to the new file
  RestoreViews();

  ResetIdn();

  #$CMD('RMVLIBLE APLLIBFLED':1);

  // rebuild file system errors
  FLEMSTB3(fleLib:fleNme);

End-Proc;


// Save views
// move all views into the temp library, save them to a temp file so we know where to put them back to
Dcl-Proc SaveViews;

  Exec SQL Create or replace table QTEMP/VEWTBL ( vewLib char(10), vewNme char(10));
  Exec SQL Delete from QTEMP/VEWTBL;
  Exec SQL Declare vewCrs Cursor For
    Select system_view_schema, system_view_name
    From sysviewdep
    Where (system_table_schema,system_table_name) = (:fleLib,:fleNme);
  Exec SQL Open vewCrs;
  Exec SQL Fetch Next From vewCrs Into :vewDta;
  DoW sqlState < '02';
    // move view to temp library
    #$CMD('MOVOBJ OBJ('+%trim(vewLib)+'/'+%trim(vewNme)+') OBJTYPE(*FILE) TOLIB(APLLIBFLED)');
    Exec SQL insert into QTEMP.VEWTBL (vewLib,vewNme) values(:vewLib,:vewNme);
    Exec SQL Fetch Next From vewCrs Into :vewDta;
  EndDo;
  Exec SQL Close vewCrs;

End-Proc;


// Restore views
// create views in their original libraries, this re-attaches them to the new file
Dcl-Proc RestoreViews;

  Exec SQL Declare vewCrs2 Cursor For Select vewLib,vewNme From QTEMP/VEWTBL;
  Exec SQL Open vewCrs2;
  Exec SQL Fetch Next From vewCrs2 Into :vewDta;
  DoW sqlState < '02';
    #$CMD('CRTDUPOBJ OBJ('+%trim(vewNme)+') FROMLIB(APLLIBFLED) OBJTYPE(*FILE) TOLIB('+%trim(vewLib)+')');
    #$CMD('DLTF APLLIBFLED/'+%trim(vewNme));
    Exec SQL Fetch Next From vewCrs2 Into :vewDta;
  EndDo;
  Exec SQL Close vewCrs2;

End-Proc;


// reset the next identity field
Dcl-Proc ResetIdn;

  sqlStm = 'select max('+%trim(fleNme)+'Idn) from '+%trim(fleLib) + '.' + %trim(fleNme);
  Exec SQL Prepare sqlStm From :sqlStm;
  Exec SQL Declare idnCrs Cursor For sqlStm;
  Exec SQL Open idnCrs;
  Exec SQL Fetch Next From idnCrs Into :lstIdn;
  Exec SQL Close idnCrs;
  sqlStm = 'Alter Table '+%trim(fleLib)+'.'+%trim(fleNme)+
  ' Alter Column '+%trim(fleNme)+'Idn Restart with '+%char(lstIdn+1);
  Exec SQL Execute Immediate :sqlStm;

End-Proc;


// Add log entry
Dcl-Proc AddLog;
  Dcl-Pi *n;
    logTyp Like(APLDCT.logTyp) const;
    logDes Like(APLDCT.logDes) const;
    logMsg Like(APLDCT.logMsg) const;
  End-Pi;

  Exec SQL Insert Into FLELOG
  ( FLELIB, FLENME, FLEMSTIDN, LOGTYP, LOGDES, LOGMSG)
  values(:fleLib,:fleNme,:fleMstIdn,:logTyp,:logDes,:logMsg);

End-Proc;


Dcl-Proc BuildCopyStatement;
  Dcl-S different Ind;
  Dcl-S frmFlds varchar(5000);
  Dcl-S toFlds varchar(5000);

  // we need to either map each field or map field1 to field1, field2 to field2
  // the deciding factor is if the each file has the same number of columns of the same type.
  // Sizes will be mapped if they changed.
  // If they do then we map the fields in the same order even if they have different names, similar to a CPYF *NOCHK
  // if the fields do not match, then we only copy back the fields with the same name, simlar to a CPYF *MAP *DROP

  // figure out if all the columns match. This is done joining the new file to the old by ordinal positoin
  // (the order the fields are in the file), then selecting any that do not have the same type
  Exec SQL
    with n as ( Select ordinal_position, data_type
             From sysColumns2
             where (system_table_schema,system_table_name) = (:fleLib,:fleNme) ),
         o as (Select ordinal_position, data_type
            From sysColumns2
            where (system_table_schema,system_table_name) = ('APLLIBFLED',:fleNme) )
    Select '1' into :different
    from n
    full outer join o on o.ordinal_position = n.ordinal_position
    Where n.data_type <> o.data_type or n.data_type is null or o.data_type is null;

  // Get to and from field lists
  If different;
    // If the files are different, only include fields with the same name in each file
    Exec SQL
      with
        n as (
          Select system_column_name
          From sysColumns2
          where (system_table_schema,system_table_name) = (:fleLib,:fleNme)
        ),
        o as (
          Select system_column_name
          From sysColumns2
          where (system_table_schema,system_table_name) = ('APLLIBFLED',:fleNme)
        )
      Select listagg(trim(n.system_column_name),',') into :frmFlds
      from n
      join o on o.system_column_name = n.system_column_name;
    toFlds = frmFlds;
  Else;
    // if the files are the same, get the full list of fields from each file
    Exec SQL Select listagg(trim(system_column_name),',') Within Group (Order by ordinal_position) into :frmFlds
      From sysColumns2
      where (system_table_schema,system_table_name) = ('APLLIBFLED',:fleNme);
    Exec SQL Select listagg(trim(system_column_name),',') Within Group (Order by ordinal_position) into :toFlds
      From sysColumns2
      where (system_table_schema,system_table_name) = (:fleLib,:fleNme);
  EndIf;

  // build the SQL statement
  sqlStm = 'Insert Into ' + %trim(fleLib) + '.' + %trim(fleNme) +
            ' (' + toFlds + ') Overriding System Value +
            Select '+frmFlds+' From APLLIBFLED/'+%trim(fleNme);

End-Proc;
