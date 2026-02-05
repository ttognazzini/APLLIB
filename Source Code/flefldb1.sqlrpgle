**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

//  Sync file and FLEFLD

// If the file exists and is not in FLEFLD, this should add every field.
// Also calculates the file status, number of fields and number of indexes

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB1PR // Always include the prototype for the current program
/Copy QSRC,FLEMSTB3PR // Update file errors

// Globals for parameters
Dcl-S fleLib Like(APLDCT.fleLib);
Dcl-S fleNme Like(APLDCT.fleNme);
Dcl-S updErr char(1);
Dcl-S synTbl char(1);

// Fields for file master attributes
Dcl-S fleDes like(APLDCT.fleDes);
Dcl-S tblNme like(APLDCT.tblNme);
Dcl-S fleMstIdn like(APLDCT.fleMstIdn);
Dcl-S nteExs like(APLDCT.nteExs);
Dcl-S lngCmt varChar(2000);

// Fields for file field attributes
Dcl-Ds dtaFld;
  ordinal_position packed(9);
  fldNme like(APLDCT.fldNme);
  colNme like(APLDCT.fldNmeSql);
  dctNme like(APLDCT.dctNme);
End-Ds;

// Fields for file field attributes
Dcl-Ds idxDta;
  idxLib like(APLDCT.idxLib);
  idxNme like(APLDCT.idxNme);
  idxTxt like(APLDCT.idxTxt);
  idxUni like(APLDCT.idxUni);
End-Ds;

// Used to build/resequence the level and sequence number
Dcl-S fldLvl like(APLDCT.fldLvl);
Dcl-S fldSeq like(APLDCT.fldSeq);
Dcl-S fleFldIdn like(APLDCT.fleFldIdn);
Dcl-S idxFldIdn like(APLDCT.idxFldIdn);
Dcl-S fldSts like(APLDCT.fldSts);
Dcl-S acvRow like(APLDCT.acvRow);
Dcl-S prdFle like(APLDCT.prdFle);
Dcl-S fleAcvRow like(APLDCT.acvRow);
Dcl-S chgScd like(APLDCT.chgScd);
Dcl-S fileType char(10);
Dcl-S fileFound ind;
Dcl-S sqlObjType char(10);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDB1');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrUpdErr char(1) options(*omit:*nopass) const;
    pmrSynTbl char(1) options(*omit:*nopass) const;
  End-Pi;

  // move parameters to globals
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;
  If %parms() >= 3 and %addr(pmrUpdErr) <> *null;
    updErr = pmrUpdErr;
  Else;
    updErr = 'Y';
  EndIf;
  If %parms() >= 4 and %addr(pmrSynTbl) <> *null;
    synTbl = pmrSynTbl;
  Else;
    synTbl = 'Y';
  EndIf;

  // get table text and long comment
  fleDes = '';
  Exec SQL
    Select Cast(table_text as Varchar(50)), cast(Coalesce(long_comment,'') as varChar(2000) ccsid 37)
    Into   :fleDes, :lngCmt
    From QSYS2.SYSTABLES
    Where (system_table_schema,system_table_name) = (:fleLib,:fleNme)
      and table_type in ('V','T','P');
  // get table alias
  tblNme = '';
  Exec SQL
    Select Cast(table_Name as Varchar(50))
    Into   :tblNme
    From QSYS2.SYSTABLES
    Where (base_table_schema,base_table_name) = (:fleLib,:fleNme)
      and table_type = 'A'
    Limit 1;

  // add FLEMST if not already in the file, ignore it if it exists already
  Exec SQL Insert Into FLEMST
           (acvRow,fleLib,fleNme,tblNme,fleDes,
            crtDtm,crtUsr,crtJob,crtPgm,
            mntDtm,mntUsr,mntJob,mntPgm)
    values ('1',  :fleLib,:fleNme,:tblNme,:fleDes,
            current timestamp,:user,:wsid,:psdsPgmNam,
            current timestamp,:user,:wsid,:psdsPgmNam);
  // if the file did not already exists, force a sync of the table
  If SQLState < '02';
    synTbl = 'Y';
  EndIf;

  // get the fleMstIdn for use in the detail record if adding one
  Exec SQL Select fleMstIdn Into :fleMstIdn From FLEMST Where (fleLib,fleNme) = (:fleLib,:fleNme);

  // Loop through system file and add to FLEFDL if it does not already exist
  If synTbl = 'Y';
    fldSeq = 0;
    Exec SQL Declare sqlCrs Cursor For
      Select
        Ordinal_position,
        system_column_name,
        column_name,
        coalesce(reference_file,'')
      From syscolumns2
      Where (system_table_schema,system_table_name) = (:fleLib,:fleNme)
      Order by Ordinal_Position;
    Exec SQL Open sqlCrs;
    Exec SQL Fetch Next From sqlCrs Into :dtaFld;
    DoW sqlState < '02';
      Process_Field();
      Exec SQL Fetch Next From sqlCrs Into :dtaFld;
    EndDo;
    Exec SQL Close sqlCrs;

    // try to add any existing indexes to the index file, excludes logical file
    Exec SQL Declare idxCrs Cursor For
      Select
        index_schema,
        index_name,
        cast(index_text as char(50)),
        case when unique = 'UNIQUE' then 'Y' else 'N' end unique
      From sysIndexStat
      Where (system_table_schema,system_table_name) = ('APLLIB','FLEMST');
    Exec SQL Open idxCrs;
    Exec SQL Fetch Next From idxCrs Into :idxDta;
    DoW sqlState < '02';
      ProcessIndex();
      Exec SQL Fetch Next From idxCrs Into :idxDta;
    EndDo;
    Exec SQL Close idxCrs;
  EndIf;

  // Set notes exist flag in FLEMST, add them if a long comment exists on the file
  nteExs = 'N';
  Exec SQL Select 'Y' into :nteExs
           from FLENTE
           where (fleLib,fleNme,acvRow)=(fleLib,fleNme,'1')
           Limit 1;
  If nteExs = 'N' and lngCmt <> '';
    AddNotes();
    nteExs = 'Y';
  EndIf;
  Exec SQL Update FLEMST
       set nteExs = :nteExs
       Where (fleLib,fleNme) = (:fleLib,:fleNme);

  // udpate the field count from active FLEFLD records
  Exec SQL Update FLEMST
           Set fldCnt = (Select Count(*) From FLEFLD Where (fleLib,FleNme,acvRow) = (:fleLib,:fleNme,'1'))
           Where (fleLib,FleNme) = (:fleLib,:fleNme);

  // udpate the index count from active FLEIDX records
  Exec SQL Update FLEMST
           Set idxCnt = (Select Count(*) From FLEIDX Where (fleLib,FleNme,acvRow) = (:fleLib,:fleNme,'1'))
           Where (fleLib,FleNme) = (:fleLib,:fleNme);

  // Get fields from the header file and db file for field level status calculation
  Exec SQL Select chgScd, acvRow into :chgScd, :fleAcvRow from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);
  fileFound = *off;
  Exec SQL Select fileType, coalesce(SQL_object_type,''),'1' into :fileType, :sqlObjType, :fileFound
           from sysFiles
           where (system_table_schema,system_table_name) = (:fleLib,:fleNme);

  // resequence fields by field level, calculate the field status and update the note flag
  fldSeq = 0;
  Exec SQL Declare seqCrs Cursor For
    Select fleFldIdn,fldNme From flefld Where (fleLib,fleNme) = (:fleLib,:fleNme) Order by fldLvl, fldSeq;
  Exec SQL Open seqCrs;
  Exec SQL Fetch Next From seqCrs Into :fleFldIdn, :fldNme;
  DoW sqlState < '02';
    fldSeq += 10;
    GetFieldStatus();
    nteExs = 'N';
    Exec SQL Select 'Y' into :nteExs from FLDNTE where (flefldIdn,acvRow)=(:fleFldIdn,'1') limit 1;
    Exec SQL Update FLEFLD Set (fldSeq,fldSts,nteExs) = (:fldSeq,:fldSts,nteExs) Where fleFldIdn = :fleFldIdn;
    Exec SQL Fetch Next From seqCrs Into :fleFldIdn, :fldNme;
  EndDo;
  Exec SQL Close seqCrs;

  // resequence index fields
  fldSeq = 0;
  Exec SQL Declare idxSeqCrs Cursor For
    Select idxFldIdn From IDXFLD Where (fleLib,fleNme) = (:fleLib,:fleNme) Order by idxSeq;
  Exec SQL Open idxSeqCrs;
  Exec SQL Fetch Next From idxSeqCrs Into :idxFldIdn;
  DoW sqlState < '02';
    fldSeq += 10;
    Exec SQL Update IDXFLD Set idxSeq = :fldSeq Where idxFldIdn = :idxFldIdn;
    Exec SQL Fetch Next From idxSeqCrs Into :idxFldIdn;
  EndDo;
  Exec SQL Close idxSeqCrs;

  // calculate the file status
  Exec SQL Select max(fldsts) into :fldSts from FLEFLD where (fleLib,fleNme,acvRow) = (:fleLib,:fleNme,'1');
  Exec SQL Select acvRow,prdFle into :acvRow,:prdFle from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);
  If acvRow = '0'; // inactive
    Exec SQL update FLEMST set fleSts = '9' where (fleLib,fleNme) = (:fleLib,:fleNme);
  ElseIf fldSts in %list('6':'4'); // changes scheduled, delete scheduled
    Exec SQL update FLEMST set fleSts = '5' where (fleLib,fleNme) = (:fleLib,:fleNme);
  ElseIf fldSts in %list('5':'3'); // pending changes, pending delete
    Exec SQL update FLEMST set fleSts = '4' where (fleLib,fleNme) = (:fleLib,:fleNme);
  ElseIf fldSts  = '2' and prdFle <> 'N'; // Production
    Exec SQL update FLEMST set fleSts = '3' where (fleLib,fleNme) = (:fleLib,:fleNme);
  ElseIf fldSts  = '2'; // Development
    Exec SQL update FLEMST set fleSts = '2' where (fleLib,fleNme) = (:fleLib,:fleNme);
  Else;
    Exec SQL update FLEMST set fleSts = '1' where (fleLib,fleNme) = (:fleLib,:fleNme);
  EndIf;

  // update errors
  If updErr = 'Y';
    FLEMSTB3(fleLib:fleNme:'N');
  EndIf;

End-Proc;


// Add field information that is not in FLEFLD
Dcl-Proc Process_Field;
  Dcl-S priKey char(1);
  fldSeq += 10;

  // see if the field name is a primary key for the file
  priKey = 'N';
  Exec SQL Select 'Y' Into :priKey
           From FleMSt
           Where :fldNme in (Select * From Table(keyFldT1(:fleLib,:fleNme)))
           limit 1;

  // determine field level
  If fldNme = 'ACVROW';
    fldLvl = '1';
  ElseIf fldNme = %trim(fleNme) + 'IDN';
    fldLvl = '2';
  ElseIf priKey = 'Y';
    fldLvl = '3';
  ElseIf fldNme in %list('CRTDTM':'CRTUSR':'CRTJOB':'CRTPGM':'MNTDTM':'MNTUSR':'MNTJOB':'MNTPGM');
    fldLvl = '5';
  Else;
    fldLvl = '4';
  EndIf;

  found = *off;
  Exec SQL Select '1' Into :found From FLEFLD Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:FldNme);

  // add a field if it is in the file, but not in FLEFLD
  If not found;
    Exec SQL Insert Into FLEFLD
             (ACVROW, FLEMSTIDN, FLELIB, FLENME, FLDNME, FLDLVL, FLDSEQ, priKey,
              CRTDTM, CRTUSR, CRTJOB, CRTPGM,
              MNTDTM, MNTUSR, MNTJOB, MNTPGM)
       values('1',  :fleMstIdn,:fleLib,:fleNme,:fldNme,:fldLvl,:fldSeq, :priKey,
              current timestamp,:user,:wsid,:psdsPgmNam,
              current timestamp,:user,:wsid,:psdsPgmNam);

    // if it is in the file update the file master id
  Else;
    Exec SQL Update FLEFLD
         Set ( fleMstIdn, FLDLVL)
           = (:fleMstIdn, :fldLvl)
           Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);
  EndIf;

  // set notes exist flag in FLEFLD
  nteExs = 'N';
  Exec SQL Select 'Y' into :nteExs
           from FLDNTE
           where (fleLib,fleNme,fldNme,acvRow)=(:fleLib,:fleNme,:fldNme,'1')
           Limit 1;
  Exec SQL Update FLEFLD
           set nteExs = :nteExs
           Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);

End-Proc;


Dcl-Proc ProcessIndex;
  Dcl-S fleIdxIdn Like(APLDCT.fleIdxIdn);
  Dcl-S fleFldIdn Like(APLDCT.fleFldIdn);

  // Add index to FLEIDX
  Exec SQL Insert into FLEIDX
            (acvRow, idxLib, idxNme, fleMstIdn, fleLib, fleNme, idxtxt, idxUni,
              crtDTM, crtUsr, crtJob, crtPgm,
              mntDTM, mntUsr, mntJob, mntPgm)
       values('1',   :idxLib,:idxNme,:fleMstIdn,:fleLib,:fleNme,:idxtxt,:idxUni,
              current timestamp,:user,:wsid,:psdsPgmNam,
              current timestamp,:user,:wsid,:psdsPgmNam);

  // get fleIdxIdn to use on file records
  Exec SQL Select fleIdxIdn into :fleIdxIdn from FLEIDX where (idxLib,idxNme) = (:idxLib, :idxNme);

  // loop through fields in the index and try to add each one
  Exec SQL Declare idxFldCrs cursor for
    Select fldNme from table(keyFldT1(:idxLib,:idxNme));
  Exec SQL Open idxFldCrs;
  Exec Sql Fetch next from idxFldCrs into :fldNme;
  DoW sqlState < '02';

    // get fleFldIdn to use on field record
    Exec SQL Select fleFldIdn into :fleFldIdn from FLEFLD where (fleLib,fleNme,fldNme) = (:fleLib, :fleNme,:fldNme);

    // add fields to IDXFLD if they do not already exist
    Exec SQL Insert into IDXFLD
               (acvRow, idxLib, idxNme, idxFld, fleIdxIdn, fleLib, fleNme, fleFldIdn,
                crtDTM, crtUsr, crtJob, crtPgm,
                mntDTM, mntUsr, mntJob, mntPgm)
         values('1',   :idxLib,:idxNme,:fldNme,:fleIdxIdn,:fleLib,:fleNme,:fleFldIdn,
                current timestamp,:user,:wsid,:psdsPgmNam,
                current timestamp,:user,:wsid,:psdsPgmNam);

    Exec Sql Fetch next from idxFldCrs into :fldNme;
  EndDo;
  Exec SQL Close idxFldCrs;

End-Proc;


Dcl-Proc AddNotes;
  Dcl-S nteArray char(60) dim(50);
  Dcl-S nte like(APLDCT.nte);
  Dcl-S i packed(5);

  // split the comment into 60 character sections with line wrapping
  nteArray = #$WORDWRP2(lngCmt:60);

  // add each note
  For i = 1 to 50;
    If nteArray(i) <> '';
      nte = nteArray(i);
      Exec SQL Insert into fleNte
                ( acvRow, FleLib, FleNme, NteSeq, fleMstIdn, nte,
                  crtDTM, crtUsr, crtJob, crtPgm,
                  mntDTM, mntUsr, mntJob, mntPgm)
           values('1',   :fleLib,:fleNme,:i*10,  :fleMstIdn,:nte,
                  current timestamp,:user,:wsid,:psdsPgmNam,
                  current timestamp,:user,:wsid,:psdsPgmNam);
    Else;
      Leave;
    EndIf;
  EndFor;

End-Proc;


Dcl-Proc GetFieldStatus;
  Dcl-Ds fldDtlAtr qualified;
    field_type char(10);
    field_length packed(5);
    field_scale packed(2);
  End-Ds;
  Dcl-S encFld like(APLDCT.encFld);
  Dcl-Ds dbFldAtr qualified;
    field_type char(10);
    field_length packed(5);
    field_scale packed(2);
  End-Ds;
  Dcl-S fldAcvRow like(APLDCT.acvRow);


  // see if the field is in the DB file and get it's attributes
  Clear dbFldAtr;
  found = *off;
  Exec SQL Select '1', data_type, length, coalesce(numeric_scale,0) into :found, :dbFldAtr
           from sysColumns2
           where (system_table_schema,system_table_name,system_column_name) = (:fleLib,:fleNme,:fldNme);

  // Get fields from the header file
  Exec SQL Select chgScd, acvRow into :chgScd, :fleAcvRow from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // get fields attributes from the fleFld File
  Exec SQL Select
             FLEFLD.acvRow,
             case fldTyp -- have to override name vairriances
               when 'TIMESTAMP' then 'TIMESTMP'
               else fldTyp end,
             case fldTyp   -- have to override fixed field lengths by type
               when 'INTEGER' then 4
               when 'BIGINT' then 8
               when 'SMALLINT' then 2
               when 'DECFLOAT' then 2
               when 'FLOAT' then 8   -- can also be 4, not sure what the difference is
               when 'TIMESTAMP' then 10
               when 'DATE' then 4
               when 'TIME' then 3
               else fldLen end,
             fldScl,
            encFld
           into :fldAcvRow, :fldDtlAtr, :encFld
           from FLEFLD
           join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme)
           join DCTFLD on (DCTFLD.dctNme, DCTFLD.fldNme) = (FLEMST.dctNme, FLEFLD.fldNme)
           where (FLEFLD.fleLib, FLEFLD.fleNme, FLEFLD.fldNme) = (:fleLib,:fleNme,:fldNme);

  // If the field is flagged to include encrypted data the length needs to be the field length
  // rounded up to the next 16 byte block + 32
  If encFld = 'Y';
    If %rem(fldDtlAtr.field_length:16) <> 0;
      fldDtlAtr.field_length += 16 - %rem(fldDtlAtr.field_length:16);
    EndIf;
    fldDtlAtr.field_length += 32;
  EndIf;


  // set status
  If fileType = 'SOURCE' or (sqlObjType = '' and fileFound);
    fldSts = '2'; // production, for DDS and source files
  ElseIf fldAcvRow = '0' or fleAcvRow = '0'; // deleted
    fldSts = '9';
  ElseIf fldAcvRow = '0' and found and chgScd = 'Y'; // Delete Scheduled
    fldSts = '6';
  ElseIf  fldAcvRow = '0' and found; // Pending Delete
    fldSts = '5';
  ElseIf fldDtlAtr <> dbFldAtr and fileFound and chgScd = 'Y'; // Changes Scheduled
    fldSts = '4';
  ElseIf fldDtlAtr <> dbFldAtr and fileFound; // Pending Changes
    fldSts = '3';
  ElseIf found;
    fldSts = '2'; // production
  Else;
    fldSts = '1'; // default to entry
  EndIf;

End-Proc;
