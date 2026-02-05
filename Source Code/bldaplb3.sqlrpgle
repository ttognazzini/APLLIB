**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Build APLLIB - File Master Seeds

// This program creates all files for the file master system and seeds the files
// with some required data the intent is to allow the file master system to be
// moved to a new library and started from scratch.
//
// For testing the system has been move the library APLLIB. This member hard references
// that library, change it to where you want this to run.
//
// create the file master system files

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

Dcl-S id packed(15);
Dcl-S seq packed(6);

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;

Dcl-Proc Main;

  // FLEMST - File Master
  Exec SQL Alter Table APLLIB.FLEMST drop Constraint APLLIB.FLEMST;
  Exec SQL Drop Index APLLIB.FLEMSTIDN;
  Exec SQL Drop Table APLLIB.FLEMST;
  Exec SQL
    Create or Replace Table APLLIB.FLEMST as (
      Select
        acvRow,
        idn as fleMStIdn,
        fleLib,
        fleNme,
        fleDes,
        tblNme,
        dctNme,
        prdFle,
        chgScd,
        nteExs,
        fleErr,
        fldCnt,
        idxCnt,
        fleSts,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;
  #$SQLSTT(sqlState);

  Exec SQL Alter Table APLLIB.FLEMST add Constraint APLLIB.FLEMST Primary Key(fleLib,fleNme);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLEMST is 'File Master';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLEMSTIDN on APLLIB.FLEMST(fleMstIdn);
  #$SQLSTT(sqlState);

  // fldNme - File Fields
  Exec SQL Alter Table APLLIB.fleFld Drop Constraint APLLIB.fleFld;
  Exec SQL Drop Index APLLIB.FLEFLDIDN;
  Exec SQL Drop Table APLLIB.FLEFLD;
  Exec SQL
    Create or Replace Table APLLIB.fleFld as (
      Select
        acvRow,
        idn as fleFldIdn,
        fleLib,
        fleNme,
        fldNme,
        fldSeq,
        fldLvl,
        fldSts,
        fleMstIdn,
        priKey,
        audFld,
        encFld,
        nteExs,
        strIdn,
        idnIcm,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;

  Exec SQL Alter Table APLLIB.fleFld add Constraint APLLIB.fleFld Primary Key(fleLib,fleNme,fldNme);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.fleFld is 'File Fields';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.fleFldIDN on APLLIB.fleFld(fleFldIdn);
  #$SQLSTT(sqlState);


  // FLEIDX - File Indexes
  Exec SQL Alter Table APLLIB.FLEIDX drop Constraint APLLIB.FLEIDX;
  Exec SQL Drop Index APLLIB.FLEIDXIDN;
  Exec SQL Drop Table APLLIB.FLEIDX;
  Exec SQL
    Create or Replace Table APLLIB.FLEIDX as (
      Select
        acvRow,
        idn as fleIdxIdn,
        fleLib,
        fleNme,
        fleMstIdn,
        idxLib,
        idxNme,
        idxTxt,
        idxUni,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;
  #$SQLSTT(sqlState);

  Exec SQL Alter Table APLLIB.FLEIDX add Constraint APLLIB.FLEIDX Primary Key(idxLib,idxNme);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLEIDX is 'File Indexes';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLEIDXIDN on APLLIB.FLEIDX(fleIdxIdn);
  #$SQLSTT(sqlState);

  // IDXFLD - Index Fields */
  Exec SQL Alter Table APLLIB.IDXFLD Drop Constraint APLLIB.IDXFLD;
  Exec SQL Drop Index APLLIB.IDXFLDIDN;
  Exec SQL Drop Table APLLIB.IDXFLD;
  Exec SQL
    Create or Replace Table APLLIB.IDXFLD as (
      Select
        acvRow,
        idn as idxFldIdn,
        idxLib, idxNme, idxFld, idxSeq, fleIdxIdn, fleLib, fleNme, fleFldIdn,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;
  #$SQLSTT(sqlState);

  Exec SQL Alter Table APLLIB.IDXFLD add Constraint APLLIB.IDXFLD Primary Key(idxLib,idxNme,idxFld);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.IDXFLD is 'Index Fields';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.IDXFLDIDN on APLLIB.IDXFLD(idxFldIdn);
  #$SQLSTT(sqlState);


  // FLELOG - File Master Log
  Exec SQL Alter Table APLLIB.FLELOG Drop Constraint APLLIB.FLELOG;
  Exec SQL Drop Index APLLIB.FLELOGIDN;
  Exec SQL Drop Table APLLIB.FLELOG;
  Exec SQL
    Create or Replace Table APLLIB.FLELOG as (
      Select
        acvRow,
        idn as fleLogIdn,
        fleLib, fleNme, fleMstIdn, fldNme, fleFldIdn, logTyp, logDes, logMsg,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;
  #$SQLSTT(sqlState);

  Exec SQL Alter Table APLLIB.FLELOG add Constraint APLLIB.FLELOG Primary Key(fleLib,fleNme,fleLogIdn);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLELOG is 'File Log';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLELOGIDN on APLLIB.FLELOG(fleLogIdn);
  #$SQLSTT(sqlState);

  // FLENTE - File Master Notes
  Exec SQL Alter Table APLLIB.FLENTE Drop Constraint APLLIB.FLENTE;
  Exec SQL Drop Index APLLIB.FLENTEIDN;
  Exec SQL Drop Table APLLIB.FLENTE;
  Exec SQL
    Create or Replace Table APLLIB.FLENTE as (
      Select
        acvRow,
        idn as fleNteIdn,
        FleLib, FleNme, NteSeq, fleMstIdn, nte,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;

  Exec SQL Alter Table APLLIB.FLENTE add Constraint APLLIB.FLENTE Primary Key(fleLib,fleNme,nteSeq);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLENTE is 'File Notes';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLENTEIDN on APLLIB.FLENTE(fleNteIdn);
  #$SQLSTT(sqlState);

  // FLEERR - File Master Errors
  Exec SQL Alter Table APLLIB.FLEERR Drop Constraint APLLIB.FLEERR;
  Exec SQL Drop Index APLLIB.FLEERRIDN;
  Exec SQL Drop Table APLLIB.FLEERR;
  Exec SQL
    Create or Replace Table APLLIB.FLEERR as (
      Select
        acvRow,
        idn as fleErrIdn,
        fleLib, fleNme, Des, idxNme, fldNme, fleFldIdn, idxLib, fleIdxIdn, errMsg,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;

  Exec SQL Alter Table APLLIB.FLEERR add Constraint APLLIB.FLEERR Primary Key(fleLib,fleNme,fleErrIdn);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLEERR is 'File Errors';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLEERRIDN on APLLIB.FLEERR(fleErrIdn);
  #$SQLSTT(sqlState);

  // FLDNTE - Field Notes
  Exec SQL Alter Table APLLIB.FLDNTE Drop Constraint APLLIB.FLDNTE;
  Exec SQL Drop Index APLLIB.FLDNTEIDN;
  Exec SQL Drop Table APLLIB.FLDNTE;
  Exec SQL
    Create or Replace Table APLLIB.FLDNTE as (
      Select
        acvRow,
        idn as fldNteIdn,
        FleLib, FleNme, fldNme, NteSeq, fleMstIdn, fleFldIdn, nte,
        crtDtm, crtUsr, crtJob, crtPgm, mntDtm, mntUsr, mntJob, mntPgm
      From APLLIB.APLDCT
    )
    definition only
    Including Identity
    Including Column Defaults
    RcdFmt FLEMSTR;

  Exec SQL Alter Table APLLIB.FLDNTE add Constraint APLLIB.FLDNTE Primary Key(fleLib,fleNme,fldNme,nteSeq);
  #$SQLSTT(sqlState);
  Exec SQL Label on Table APLLIB.FLDNTE is 'File Notes';
  #$SQLSTT(sqlState);
  Exec SQL Create Unique Index APLLIB.FLDNTEIDN on APLLIB.FLDNTE(fldNteIdn);
  #$SQLSTT(sqlState);


  // populate file master entries with dictionary, file, and program master files
  Exec SQL
    Insert into APLLIB.FLEMST
           ( fleLib,  fleNme,      fleDes,             tblNme,                 dctNme,prdFle )
    values ('APLLIB','FLEMST','File Master'          ,'files'                ,'APLDCT','N'),
           ('APLLIB','FLEFLD','File Fields'          ,'file_fields'          ,'APLDCT','N'),
           ('APLLIB','FLEIDX','File Indexes'         ,'file_indexes'         ,'APLDCT','N'),
           ('APLLIB','IDXFLD','Index Fields'         ,'index_fields'         ,'APLDCT','N'),
           ('APLLIB','FLELOG','File Log'             ,'file_log'             ,'APLDCT','N'),
           ('APLLIB','FLENTE','File Notes'           ,'file_notes'           ,'APLDCT','N'),
           ('APLLIB','FLDNTE','Field Notes'          ,'field_notes'          ,'APLDCT','N'),
           ('APLLIB','FLEERR','File Errors'          ,'file_errors'          ,'APLDCT','N'),
           ('APLLIB','DCTMST','Dictionary Master'    ,'dictionaries'         ,'APLDCT','N'),
           ('APLLIB','DCTFLD','Dictionary Fields'    ,'dictionary_fields'    ,'APLDCT','N'),
           ('APLLIB','DCTSEG','Dictionary Segments  ','dictionary_segments'  ,'APLDCT','N'),
           ('APLLIB','DCTVAL','Dictionary Values'    ,'dictionary_values'    ,'APLDCT','N'),
           ('APLLIB','FLDTYP','Field Types'          ,'field_types'          ,'APLDCT','N'),
           ('APLLIB','PGMMST','Program Master'       ,'programs'             ,'APLDCT','N'),
           ('APLLIB','PGMACT','Program Actions'      ,'program_actions'      ,'APLDCT','N'),
           ('APLLIB','PGMFNC','Program Function Keys','program_function_keys','APLDCT','N'),
           ('APLLIB','PGMOPT','Program Options'      ,'program_options'      ,'APLDCT','N'),
           ('APLLIB','HLPMST','Help Master'          ,'help_master'          ,'APLDCT','N'),
           ('APLLIB','HLPDTL','Help Detail'          ,'help_detail'          ,'APLDCT','N'),
           ('APLLIB','APLLIB','Application Libraries','application_libraries','APLDCT','N'),
           ('APLLIB','AUDLOG','Application Libraries','application_libraries','APLDCT','N'),
           ('APLLIB','USRROL','User Roles'           ,'user_roles'           ,'APLDCT','N'),
           ('APLLIB','USRMST','User Master'          ,'users'                ,'APLDCT','N'),
           ('APLLIB','ROLAPR','Role Approvals'       ,'role_approvals'       ,'APLDCT','N'),
           ('APLLIB','ROLMST','Role Master'          ,'roles'                ,'APLDCT','N')
    ;
  #$SQLSTT(sqlState);

  Exec SQL Update FLEMST set chgScd = 'N';

  // populate fldNme for FLEMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLEMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLELIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLENME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLEDES'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','TBLNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','DCTNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','PRDFLE'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','CHGSCD'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','NTEEXS'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLEERR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLDCNT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','IDXCNT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','FLESTS'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fleFld for fleFld
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLEFLD','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLELIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLENME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLDSEQ'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLDLVL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLDSTS'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','PRIKEY'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','AUDFLD'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','ENCFLD'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','NTEEXS'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','STRIDN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','IDNICM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEFLD','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLEIDX
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLEIDX','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','FLEIDXIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','FLELIB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','FLENME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','IDXLIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','IDXNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','IDXTXT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','IDXUNI'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEIDX','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for IDXFLD
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','IDXFLD','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','IDXFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','IDXLIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','IDXNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','IDXFLD'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','IDXSEQ'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','FLEIDXIDN','N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','FLELIB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','FLENME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','IDXFLD','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLELOG
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLELOG','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLELOGIDN','Y'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLELIB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLENME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLDNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','LOGTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','LOGDES'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','LOGMSG'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLELOG','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLENTE
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLENTE','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','FLENTEIDN','Y'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','FLELIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','FLENME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','NTESEQ'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','NTE'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLENTE','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLDNTE
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLDNTE','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLDNTEIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLELIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLENME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','NTESEQ'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','NTE'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDNTE','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLEERR
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLEERR','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLEERRIDN','Y'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLELIB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLENME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','IDXLIB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','IDXNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLDNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','FLEIDXIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','ERRMSG'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLEERR','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for DCTMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','DCTMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','DCTMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','DCTNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','NTE'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for DCTFLD
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','DCTFLD','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','DCTFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','DCTNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDNMESQL','N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDSCL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDALC'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','PRJNBR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','COLTXT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','COLHDG'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','PCDFLG'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDPMP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','ALWNUL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','DFTVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','FLDENM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTFLD','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for DCTSEG
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','DCTSEG','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','DCTSEGIDN','N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','DTASEG'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','COLTXT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','COLHDGSEG','N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','CNFEXS'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','NTE'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTSEG','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);


  // populate fldNme for DCTVAL
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','DCTVAL','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','DCTVALIDN','N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','DCTNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','ENMVAL'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','ENMDES'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','DCTVAL','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for FLDTYP
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','FLDTYP','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FLDTYPIDN','N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FLDTYP'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','NMR'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','ALWDEC'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','ALWLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','REQLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','ALWALC'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','REQALC'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','MAXLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','LRGVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','SMLVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN1'  ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN2'  ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN3'  ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN4'  ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','FRCLEN5'  ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','DFTVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','SYSTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','SYSLEN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','FLDTYP','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for PGMMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','PGMMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','PGMMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','PGMNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','APL'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','OBJTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','PGMTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNUOBJ'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','SECAUT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','DFTAUT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','WEBAPL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNUNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','DSPFLE'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','REQITR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','REQOWN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','REQDBA'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','SECPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','TOTCNT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','HLPCNT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for PGMACT
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','PGMACT','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','PGMACTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','PGMNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','ACTCDE'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','OPTION'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','FNCKEY'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','SEQNBR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMACT','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for PGMFNC
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','PGMFNC','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','PGMFNCIDN','N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','PGMNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','FNCKEY'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','OPTION'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','SEQNBR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMFNC','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for PGMOPT
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','PGMOPT','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','PGMOPTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','PGMNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','OPT'      ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','OPTION'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','PGMOPT','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for HLPMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','HLPMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','HLPMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','DCTNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','DSPFLE'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','HLPREF'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','VAL'      ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','HLPTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','LNECNT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','DES'      ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for HLPDTL
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','HLPDTL','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','HLPDTLIDN','N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','DCTNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','FLDNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','DSPFLE'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','VAL'      ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','SEQNBR'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','HLPTXT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','HLPDTL','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for APLLIB
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','APLLIB','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','APLLIBIDN','N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','LIBNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','LIBDES'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','LIBTYP'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','DEVUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','APLLIB','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for AUDLOG
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','AUDLOG','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','AUDLOGIDN','N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','FLELIB'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','RCDIDN'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','FLENME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','FLDNME'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','FLEMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','FLEFLDIDN','N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','BFRVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','AFTVAL'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','AUDLOG','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for USRROL
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','USRROL','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','USRROLIDN','N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','USRMSTIDN','Y'  ,'Y'   ,'N'),
            ('APLLIB','USRROL','ROLMSTIDN','Y'  ,'Y'   ,'N'),
            ('APLLIB','USRROL','ROLAPR'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRROL','ROLAPRIDN','N'  ,'Y'   ,'N'),
            ('APLLIB','USRROL','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRROL','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for USRMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','USRMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','USRMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','USRPRF'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','USRMST','FSTNME'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','LSTNME'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRTXT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRDPT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRINT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRTTL'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRCLS'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USRSTS'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USROQN'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USROQL'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','GRPPRF'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','EMPNBR'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USREMP'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','USREML'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','PHNNBR'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','PHNEXT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','ACGCDE'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','ARCFLR'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','PRTDEV'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','PRTOTQ'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','AARFLR'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','OTOEML'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','OTONME'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','HLDOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','SAVOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','ATATYP'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','ATAFMT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','PRTOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','EMLOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','ARCOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','FAXOUT'   ,'N'  ,'Y'   ,'N'),
            ('APLLIB','USRMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','USRMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for ROLAPR
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','ROLAPR','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','ROLAPRIDN','Y'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLAPR','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate fldNme for ROLMST
  Exec SQL
    Insert into APLLIB.fleFld
            ( fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    values  ('APLLIB','ROLMST','ACVROW'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','ROLMSTIDN','N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','ROLNME'   ,'Y'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','LNGCMT'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','CRTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','CRTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','CRTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','CRTPGM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','MNTDTM'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','MNTUSR'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','MNTJOB'   ,'N'  ,'N'   ,'N'),
            ('APLLIB','ROLMST','MNTPGM'   ,'N'  ,'N'   ,'N')
    ;
  #$SQLSTT(sqlState);

  // populate FLEIDX, for now just the Identity indexes
  Exec SQL
    Insert into APLLIB.FLEIDX
            ( fleLib , fleNme , idxLib  , idxNme    , idxTxt           ,idxUni)
    values  ('APLLIB','FLEMST','APLLIB','FLEMSTIDN','File Master - Id','U'),
            ('APLLIB','FLEFLD','APLLIB','FLEFLDIDN','File Fields - Id','U'),
            ('APLLIB','FLEIDX','APLLIB','FLEIDXIDN','File Indexes - Id','U'),
            ('APLLIB','IDXFLD','APLLIB','IDXFLDIDN','Index Fields - Id','U'),
            ('APLLIB','FLELOG','APLLIB','FLELOGIDN','File Log - Id','U'),
            ('APLLIB','FLENTE','APLLIB','FLENTEIDN','File Notes - Id','U'),
            ('APLLIB','FLDNTE','APLLIB','FLDNTEIDN','Field Notes - Id','U'),
            ('APLLIB','FLEERR','APLLIB','FLEERRIDN','File Errors - Id','U'),
            ('APLLIB','DCTMST','APLLIB','DCTMSTIDN','Dictionary Master - Id','U'),
            ('APLLIB','DCTFLD','APLLIB','DCTFLDIDN','Dictionary Fields - Id','U'),
            ('APLLIB','DCTSEG','APLLIB','DCTSEGIDN','Dictionary Segments   - Id','U'),
            ('APLLIB','DCTVAL','APLLIB','DCTVALIDN','Dictionary Values - Id','U'),
            ('APLLIB','FLDTYP','APLLIB','FLDTYPIDN','Field Types - Id','U'),
            ('APLLIB','PGMMST','APLLIB','PGMMSTIDN','Program Master - Id','U'),
            ('APLLIB','PGMACT','APLLIB','PGMACTIDN','Program Actions - Id','U'),
            ('APLLIB','PGMFNC','APLLIB','PGMFNCIDN','Program Function Keys - Id','U'),
            ('APLLIB','PGMOPT','APLLIB','PGMOPTIDN','Program Options - Id','U'),
            ('APLLIB','HLPMST','APLLIB','HLPMSTIDN','Help Master - Id','U'),
            ('APLLIB','HLPDTL','APLLIB','HLPDTLIDN','Help Detail - Id','U'),
            ('APLLIB','APLLIB','APLLIB','APLLIBIDN','Application Libraries - Id','U'),
            ('APLLIB','AUDLOG','APLLIB','AUDLOGIDN','Audit Log - Id','U'),
            ('APLLIB','USRROL','APLLIB','USRROLIDN','User Roles - Id','U'),
            ('APLLIB','USRMST','APLLIB','USRMSTIDN','Users - Id','U'),
            ('APLLIB','ROLAPR','APLLIB','ROLAPRIDN','Role Approvals - Id','U'),
            ('APLLIB','ROLMST','APLLIB','ROLMSTIDN','Role Master - Id','U')
    ;
  #$SQLSTT(sqlState);

  // get the file master IDN's for FLEIDX
  Exec SQL
    Update APLLIB.FLEIDX
    Set    fleMStIdn = (
      Select FLEMST.fleMstIdn
      From APLLIB.FLEMST
      Where (FLEMST.fleLib,FLEMST.fleNme) = (FLEIDX.fleLib,FLEIDX.fleNme)
    );
  #$SQLSTT(sqlState);

  // populate IDXFLD
  Exec SQL
    Insert into APLLIB.IDXFLD
            ( idxLib,  idxNme,  idxFld,    idxSeq, fleLib, fleNme)
    values  ('APLLIB','FLEMSTIDN','FLEMSTIDN',1,  'APLLIB','FLEMST'),
            ('APLLIB','FLEFLDIDN','FLEFLDIDN',1,  'APLLIB','FLEFLD'),
            ('APLLIB','FLEIDXIDN','FLEIDXIDN',1,  'APLLIB','FLEIDX'),
            ('APLLIB','IDXFLDIDN','IDXFLDIDN',1,  'APLLIB','IDXFLD'),
            ('APLLIB','FLELOGIDN','FLELOGIDN',1,  'APLLIB','FLELOG'),
            ('APLLIB','FLENTEIDN','FLENTEIDN',1,  'APLLIB','FLENTE'),
            ('APLLIB','FLDNTEIDN','FLDNTEIDN',1,  'APLLIB','FLDNTE'),
            ('APLLIB','FLEERRIDN','FLEERRIDN',1,  'APLLIB','FLEERR'),
            ('APLLIB','DCTMSTIDN','DCTMSTIDN',1,  'APLLIB','DCTMST'),
            ('APLLIB','DCTFLDIDN','DCTFLDIDN',1,  'APLLIB','DCTFLD'),
            ('APLLIB','DCTSEGIDN','DCTSEGIDN',1,  'APLLIB','DCTSEG'),
            ('APLLIB','DCTVALIDN','DCTVALIDN',1,  'APLLIB','DCTVAL'),
            ('APLLIB','FLDTYPIDN','FLDTYPIDN',1,  'APLLIB','FLDTYP'),
            ('APLLIB','PGMMSTIDN','PGMMSTIDN',1,  'APLLIB','PGMMST'),
            ('APLLIB','PGMACTIDN','PGMACTIDN',1,  'APLLIB','PGMACT'),
            ('APLLIB','PGMFNCIDN','PGMFNCIDN',1,  'APLLIB','PGMFNC'),
            ('APLLIB','PGMOPTIDN','PGMOPTIDN',1,  'APLLIB','PGMOPT'),
            ('APLLIB','HLPMSTIDN','HLPMSTIDN',1,  'APLLIB','HLPMST'),
            ('APLLIB','HLPDTLIDN','HLPDTLIDN',1,  'APLLIB','HLPDTL'),
            ('APLLIB','APLLIBIDN','APLLIBIDN',1,  'APLLIB','APLLIB'),
            ('APLLIB','AUDLOGIDN','AUDLOGIDN',1,  'APLLIB','AUDLOG'),
            ('APLLIB','USRROLIDN','USRROLIDN',1,  'APLLIB','USRROL'),
            ('APLLIB','USRMSTIDN','USRMSTIDN',1,  'APLLIB','USRMST'),
            ('APLLIB','ROLAPRIDN','ROLAPRIDN',1,  'APLLIB','ROLAPR'),
            ('APLLIB','ROLMSTIDN','ROLMSTIDN',1,  'APLLIB','ROLMST')
    ;
  #$SQLSTT(sqlState);

  // get the file master IDN's for FLEFLD
  Exec SQL
    Update APLLIB.FLEFLD
    Set    fleMstIdn = (
      Select FLEMST.fleMstIdn
      From APLLIB.FLEMST
      Where (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme)
    );
  #$SQLSTT(sqlState);

  // get the file master and file field IDN's for IDXFLD
  Exec SQL
    Update APLLIB.IDXFLD
    Set    fleIdxIdn = (
      Select FLEIDX.fleIdxIdn
      From APLLIB.FLEIDX
      Where (FLEIDX.idxLib,FLEIDX.idxNme) = (IDXFLD.idxLib,IDXFLD.idxNme)
    );
  #$SQLSTT(sqlState);
  Exec SQL
    Update APLLIB.IDXFLD
    Set    fleFldIdn = (
      Select FLEFLD.fleFldIdn
      From APLLIB.FLEFLD
      Where (FLEFLD.fleLib,FLEFLD.fleNme,FLEFLD.fldNme) = (IDXFLD.fleLib,IDXFLD.fleNme,IDXFLD.idxFld)
    );
  #$SQLSTT(sqlState);

  // Update FLEFLD.fldLvl
  Exec SQL
    Update FLEFLD
    Set fldLvl = Case when fldNme = 'ACVROW'
                      then '1'
                      When fldNme = trim(fleNme) || 'IDN'
                      then '2'
                      when priKey = 'Y'
                      then '3'
                      when fldNme in ('CRTDTM','CRTUSR','CRTJOB','CRTPGM','MNTDTM','MNTUSR','MNTJOB','MNTPGM')
                      then '5'
                      Else
                      '4'
                 end;
  #$SQLSTT(sqlState);

  // populate the field sequence number
  Exec SQL Declare fldSeqCrs Cursor for
    Select
      fleFldIdn,
      ROW_NUMBER() over (partition by fleNme
        order by fleNme, fldLvl, fleFldIdn ) * 10
    From FLEFLD
    Order By fleNme, fldLvl, fldSeq;
  Exec SQL Open fldSeqCrs;
  Exec SQL Fetch Next FRom fldSeqCrs into :id,:seq;
  DoW sqlState < '02';
    Exec SQL Update FLEFLD set fldSeq = :seq Where fleFldIdn = :id;
    Exec SQL Fetch Next FRom fldSeqCrs into :id,:seq;
  EndDo;
  Exec SQL Close fldSeqCrs;

  // TODO, Add as needed, populate FLENTE

  // TODO, Add as needed, populate FLDNTE

  // TODO, add call to caclulate the errors, populate FLEERR



End-Proc;
