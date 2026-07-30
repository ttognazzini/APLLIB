**FREE
Ctl-Opt ActGrp(*New);
/copy APLLIB/QSRC,$ctlopt  // Default Ctl-Opt's, does not include activation group

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

  // populate file master entries with dictionary, file, and program master files
  // To generate values from production table use:
  // Select '(''' || trim(fleLib) || ''','''
  //              || trim(fleNme) || ''','''
  //              || trim(replace(fleDes,'''','''''')) || ''','''
  //              || trim(tblNme) || ''','''
  //              || trim(dctNme) || ''',''N''),'
  // From FLEMST
  // Where fleLib = 'APLLIB'
  // Order by fleNme;
  Exec SQL
Merge into APLLIB.FLEMST as Target
Using(
  Values
('APLLIB','APLLIB','Application Libraries','application_libraries','APLDCT','N'),
('APLLIB','AUDLOG','Application Libraries','application_libraries','APLDCT','N'),
('APLLIB','CHKBJB','Check Batch Jobs','check_batch_jobs','APLDCT','N'),
('APLLIB','DCTFLD','Dictionary Fields','dictionary_fields','APLDCT','N'),
('APLLIB','DCTMST','Dictionary Master','dictionaries','APLDCT','N'),
('APLLIB','DCTSEG','Dictionary Segments','dictionary_segments','APLDCT','N'),
('APLLIB','DCTVAL','Dictionary Values','dictionary_values','APLDCT','N'),
('APLLIB','FLDNTE','Field Notes','field_notes','APLDCT','N'),
('APLLIB','FLDTYP','Field Types','field_types','APLDCT','N'),
('APLLIB','FLEERR','File Errors','file_errors','APLDCT','N'),
('APLLIB','FLEFLD','File Fields','file_fields','APLDCT','N'),
('APLLIB','FLEIDX','File Indexes','file_indexes','APLDCT','N'),
('APLLIB','FLELOG','File Log','file_log','APLDCT','N'),
('APLLIB','FLEMST','File Master','files','APLDCT','N'),
('APLLIB','FLENTE','File Notes','file_notes','APLDCT','N'),
('APLLIB','HLPDTL','Help Detail','help_detail','APLDCT','N'),
('APLLIB','HLPMST','Help Master','help_master','APLDCT','N'),
('APLLIB','IDXFLD','Index Fields','index_fields','APLDCT','N'),
('APLLIB','IFMDRV','IFS Monitor Driver Table','ifs_monitor_driver','APLDCT','N'),
('APLLIB','IFMLOG','IFS Monitor Log','ifs_monitor_log','APLDCT','N'),
('APLLIB','PGMACT','Program Actions','program_actions','APLDCT','N'),
('APLLIB','PGMFNC','Program Function Keys','program_function_keys','APLDCT','N'),
('APLLIB','PGMMST','Program Master','programs','APLDCT','N'),
('APLLIB','PGMOPT','Program Options','program_options','APLDCT','N'),
('APLLIB','ROLAPR','Role Approvals','role_approvals','APLDCT','N'),
('APLLIB','ROLMST','Role Master','roles','APLDCT','N'),
('APLLIB','USRMST','User Master File','users','APLDCT','N'),
('APLLIB','USRROL','User Roles','user_roles','APLDCT','N')
) as source (fleLib, fleNme, fleDes, tblNme, dctNme,prdFle)
on (target.fleLib,target.fleNme) = (source.fleLib,source.fleNme)

When Matched Then Update Set
    target.fleLib = source.fleLib,
    target.fleNme = source.fleNme,
    target.fleDes = source.fleDes,
    target.tblNme = source.tblNme,
    target.dctNme = source.dctNme,
    target.prdFle = source.prdFle

When not Matched Then
    Insert (fleLib, fleNme, fleDes, tblNme, dctNme, prdFle)
    Values (source.fleLib, source.fleNme, source.fleDes, source.tblNme, source.dctNme, source.prdFle);

  #$SQLSTT(sqlState);

  Exec SQL Update FLEMST set chgScd = 'N';

  // populate FLEFLD
  // To generate values from production table use:
  // Select '(''' || trim(fleLib) || ''','''
  //              || trim(fleNme) || ''','''
  //              || trim(fldNme) || ''','''
  //              || trim(priKey) || ''','''
  //              || trim(audFld) || ''','''
  //              || trim(encFld) || '''),'
  // From FLEFLD
  // Where fleLib = 'APLLIB'
  // Order by fleNme;
  Exec SQL
Merge into APLLIB.FLEFLD as Target
Using(
  Values
('APLLIB','APLLIB','ACVROW','N','N','N'),
('APLLIB','APLLIB','APLLIBIDN','N','N','N'),
('APLLIB','APLLIB','CRTDTM','N','N','N'),
('APLLIB','APLLIB','CRTJOB','N','N','N'),
('APLLIB','APLLIB','CRTPGM','N','N','N'),
('APLLIB','APLLIB','CRTUSR','N','N','N'),
('APLLIB','APLLIB','DEVUSR','N','N','N'),
('APLLIB','APLLIB','LIBDES','N','N','N'),
('APLLIB','APLLIB','LIBNME','Y','N','N'),
('APLLIB','APLLIB','LIBTYP','N','N','N'),
('APLLIB','APLLIB','MNTDTM','N','N','N'),
('APLLIB','APLLIB','MNTJOB','N','N','N'),
('APLLIB','APLLIB','MNTPGM','N','N','N'),
('APLLIB','APLLIB','MNTUSR','N','N','N'),
('APLLIB','AUDLOG','ACVROW','N','N','N'),
('APLLIB','AUDLOG','AFTVAL','N','N','N'),
('APLLIB','AUDLOG','AUDLOGIDN','Y','N','N'),
('APLLIB','AUDLOG','BFRVAL','N','N','N'),
('APLLIB','AUDLOG','CRTDTM','N','N','N'),
('APLLIB','AUDLOG','CRTJOB','N','N','N'),
('APLLIB','AUDLOG','CRTPGM','N','N','N'),
('APLLIB','AUDLOG','CRTUSR','N','N','N'),
('APLLIB','AUDLOG','FLDNME','N','N','N'),
('APLLIB','AUDLOG','FLEFLDIDN','N','N','N'),
('APLLIB','AUDLOG','FLELIB','Y','N','N'),
('APLLIB','AUDLOG','FLEMSTIDN','N','N','N'),
('APLLIB','AUDLOG','FLENME','N','N','N'),
('APLLIB','AUDLOG','MNTDTM','N','N','N'),
('APLLIB','AUDLOG','MNTJOB','N','N','N'),
('APLLIB','AUDLOG','MNTPGM','N','N','N'),
('APLLIB','AUDLOG','MNTUSR','N','N','N'),
('APLLIB','AUDLOG','RCDIDN','Y','N','N'),
('APLLIB','CHKBJB','ACVROW','','',''),
('APLLIB','CHKBJB','CHKBJBIDN','','',''),
('APLLIB','CHKBJB','CRTDTM','','',''),
('APLLIB','CHKBJB','CRTJOB','','',''),
('APLLIB','CHKBJB','CRTPGM','','',''),
('APLLIB','CHKBJB','CRTUSR','','',''),
('APLLIB','CHKBJB','JOBNME','Y','N','N'),
('APLLIB','CHKBJB','JOBTTL','N','N','N'),
('APLLIB','CHKBJB','LNGCMT','N','N','N'),
('APLLIB','CHKBJB','MNTDTM','','',''),
('APLLIB','CHKBJB','MNTJOB','','',''),
('APLLIB','CHKBJB','MNTPGM','','',''),
('APLLIB','CHKBJB','MNTUSR','','',''),
('APLLIB','CHKBJB','SBSLIB','N','N','N'),
('APLLIB','CHKBJB','SBSNME','N','N','N'),
('APLLIB','CHKBJB','STRCMD','N','N','N'),
('APLLIB','DCTFLD','ACVROW','N','N','N'),
('APLLIB','DCTFLD','ALWNUL','N','N','N'),
('APLLIB','DCTFLD','COLHDG','N','N','N'),
('APLLIB','DCTFLD','COLTXT','N','N','N'),
('APLLIB','DCTFLD','CRTDTM','N','N','N'),
('APLLIB','DCTFLD','CRTJOB','N','N','N'),
('APLLIB','DCTFLD','CRTPGM','N','N','N'),
('APLLIB','DCTFLD','CRTUSR','N','N','N'),
('APLLIB','DCTFLD','DCTFLDIDN','N','N','N'),
('APLLIB','DCTFLD','DCTNME','Y','N','N'),
('APLLIB','DCTFLD','DES','N','N','N'),
('APLLIB','DCTFLD','DFTVAL','N','N','N'),
('APLLIB','DCTFLD','FLDALC','N','N','N'),
('APLLIB','DCTFLD','FLDENM','N','N','N'),
('APLLIB','DCTFLD','FLDLEN','N','N','N'),
('APLLIB','DCTFLD','FLDNME','Y','N','N'),
('APLLIB','DCTFLD','FLDNMESQL','N','N','N'),
('APLLIB','DCTFLD','FLDPMP','N','N','N'),
('APLLIB','DCTFLD','FLDSCL','N','N','N'),
('APLLIB','DCTFLD','FLDTYP','N','N','N'),
('APLLIB','DCTFLD','MNTDTM','N','N','N'),
('APLLIB','DCTFLD','MNTJOB','N','N','N'),
('APLLIB','DCTFLD','MNTPGM','N','N','N'),
('APLLIB','DCTFLD','MNTUSR','N','N','N'),
('APLLIB','DCTFLD','PCDFLG','N','N','N'),
('APLLIB','DCTFLD','PRJNBR','N','N','N'),
('APLLIB','DCTMST','ACVROW','N','N','N'),
('APLLIB','DCTMST','CRTDTM','N','N','N'),
('APLLIB','DCTMST','CRTJOB','N','N','N'),
('APLLIB','DCTMST','CRTPGM','N','N','N'),
('APLLIB','DCTMST','CRTUSR','N','N','N'),
('APLLIB','DCTMST','DCTMSTIDN','N','N','N'),
('APLLIB','DCTMST','DCTNME','Y','N','N'),
('APLLIB','DCTMST','DES','N','N','N'),
('APLLIB','DCTMST','MNTDTM','N','N','N'),
('APLLIB','DCTMST','MNTJOB','N','N','N'),
('APLLIB','DCTMST','MNTPGM','N','N','N'),
('APLLIB','DCTMST','MNTUSR','N','N','N'),
('APLLIB','DCTMST','NTE','N','N','N'),
('APLLIB','DCTSEG','ACVROW','N','N','N'),
('APLLIB','DCTSEG','CNFEXS','N','N','N'),
('APLLIB','DCTSEG','COLHDGSEG','N','N','N'),
('APLLIB','DCTSEG','COLTXT','N','N','N'),
('APLLIB','DCTSEG','CRTDTM','N','N','N'),
('APLLIB','DCTSEG','CRTJOB','N','N','N'),
('APLLIB','DCTSEG','CRTPGM','N','N','N'),
('APLLIB','DCTSEG','CRTUSR','N','N','N'),
('APLLIB','DCTSEG','DCTSEGIDN','N','N','N'),
('APLLIB','DCTSEG','DES','N','N','N'),
('APLLIB','DCTSEG','DTASEG','Y','N','N'),
('APLLIB','DCTSEG','MNTDTM','N','N','N'),
('APLLIB','DCTSEG','MNTJOB','N','N','N'),
('APLLIB','DCTSEG','MNTPGM','N','N','N'),
('APLLIB','DCTSEG','MNTUSR','N','N','N'),
('APLLIB','DCTSEG','NTE','N','N','N'),
('APLLIB','DCTVAL','ACVROW','N','N','N'),
('APLLIB','DCTVAL','CRTDTM','N','N','N'),
('APLLIB','DCTVAL','CRTJOB','N','N','N'),
('APLLIB','DCTVAL','CRTPGM','N','N','N'),
('APLLIB','DCTVAL','CRTUSR','N','N','N'),
('APLLIB','DCTVAL','DCTNME','Y','N','N'),
('APLLIB','DCTVAL','DCTVALIDN','N','N','N'),
('APLLIB','DCTVAL','ENMDES','N','N','N'),
('APLLIB','DCTVAL','ENMVAL','Y','N','N'),
('APLLIB','DCTVAL','FLDNME','Y','N','N'),
('APLLIB','DCTVAL','MNTDTM','N','N','N'),
('APLLIB','DCTVAL','MNTJOB','N','N','N'),
('APLLIB','DCTVAL','MNTPGM','N','N','N'),
('APLLIB','DCTVAL','MNTUSR','N','N','N'),
('APLLIB','FLDNTE','ACVROW','N','N','N'),
('APLLIB','FLDNTE','CRTDTM','N','N','N'),
('APLLIB','FLDNTE','CRTJOB','N','N','N'),
('APLLIB','FLDNTE','CRTPGM','N','N','N'),
('APLLIB','FLDNTE','CRTUSR','N','N','N'),
('APLLIB','FLDNTE','FLDNME','Y','N','N'),
('APLLIB','FLDNTE','FLDNTEIDN','N','N','N'),
('APLLIB','FLDNTE','FLEFLDIDN','N','N','N'),
('APLLIB','FLDNTE','FLELIB','Y','N','N'),
('APLLIB','FLDNTE','FLEMSTIDN','N','N','N'),
('APLLIB','FLDNTE','FLENME','Y','N','N'),
('APLLIB','FLDNTE','MNTDTM','N','N','N'),
('APLLIB','FLDNTE','MNTJOB','N','N','N'),
('APLLIB','FLDNTE','MNTPGM','N','N','N'),
('APLLIB','FLDNTE','MNTUSR','N','N','N'),
('APLLIB','FLDNTE','NTE','N','N','N'),
('APLLIB','FLDNTE','NTESEQ','Y','N','N'),
('APLLIB','FLDTYP','ACVROW','N','N','N'),
('APLLIB','FLDTYP','ALWALC','N','N','N'),
('APLLIB','FLDTYP','ALWDEC','N','N','N'),
('APLLIB','FLDTYP','ALWLEN','N','N','N'),
('APLLIB','FLDTYP','CRTDTM','N','N','N'),
('APLLIB','FLDTYP','CRTJOB','N','N','N'),
('APLLIB','FLDTYP','CRTPGM','N','N','N'),
('APLLIB','FLDTYP','CRTUSR','N','N','N'),
('APLLIB','FLDTYP','DES','N','N','N'),
('APLLIB','FLDTYP','DFTVAL','N','N','N'),
('APLLIB','FLDTYP','FLDTYP','Y','N','N'),
('APLLIB','FLDTYP','FLDTYPIDN','N','N','N'),
('APLLIB','FLDTYP','FRCLEN','N','N','N'),
('APLLIB','FLDTYP','FRCLEN1','N','N','N'),
('APLLIB','FLDTYP','FRCLEN2','N','N','N'),
('APLLIB','FLDTYP','FRCLEN3','N','N','N'),
('APLLIB','FLDTYP','FRCLEN4','N','N','N'),
('APLLIB','FLDTYP','FRCLEN5','N','N','N'),
('APLLIB','FLDTYP','LRGVAL','N','N','N'),
('APLLIB','FLDTYP','MAXLEN','N','N','N'),
('APLLIB','FLDTYP','MNTDTM','N','N','N'),
('APLLIB','FLDTYP','MNTJOB','N','N','N'),
('APLLIB','FLDTYP','MNTPGM','N','N','N'),
('APLLIB','FLDTYP','MNTUSR','N','N','N'),
('APLLIB','FLDTYP','NMR','N','N','N'),
('APLLIB','FLDTYP','REQALC','N','N','N'),
('APLLIB','FLDTYP','REQLEN','N','N','N'),
('APLLIB','FLDTYP','SMLVAL','N','N','N'),
('APLLIB','FLDTYP','SYSLEN','N','N','N'),
('APLLIB','FLDTYP','SYSTYP','N','N','N'),
('APLLIB','FLEERR','ACVROW','N','N','N'),
('APLLIB','FLEERR','CRTDTM','N','N','N'),
('APLLIB','FLEERR','CRTJOB','N','N','N'),
('APLLIB','FLEERR','CRTPGM','N','N','N'),
('APLLIB','FLEERR','CRTUSR','N','N','N'),
('APLLIB','FLEERR','DES','N','N','N'),
('APLLIB','FLEERR','ERRMSG','N','N','N'),
('APLLIB','FLEERR','FLDNME','N','N','N'),
('APLLIB','FLEERR','FLEERRIDN','Y','N','N'),
('APLLIB','FLEERR','FLEFLDIDN','N','N','N'),
('APLLIB','FLEERR','FLEIDXIDN','N','N','N'),
('APLLIB','FLEERR','FLELIB','N','N','N'),
('APLLIB','FLEERR','FLENME','N','N','N'),
('APLLIB','FLEERR','IDXLIB','N','N','N'),
('APLLIB','FLEERR','IDXNME','N','N','N'),
('APLLIB','FLEERR','MNTDTM','N','N','N'),
('APLLIB','FLEERR','MNTJOB','N','N','N'),
('APLLIB','FLEERR','MNTPGM','N','N','N'),
('APLLIB','FLEERR','MNTUSR','N','N','N'),
('APLLIB','FLEFLD','ACVROW','N','N','N'),
('APLLIB','FLEFLD','AUDFLD','N','N','N'),
('APLLIB','FLEFLD','CRTDTM','N','N','N'),
('APLLIB','FLEFLD','CRTJOB','N','N','N'),
('APLLIB','FLEFLD','CRTPGM','N','N','N'),
('APLLIB','FLEFLD','CRTUSR','N','N','N'),
('APLLIB','FLEFLD','ENCFLD','N','N','N'),
('APLLIB','FLEFLD','FLDLVL','N','N','N'),
('APLLIB','FLEFLD','FLDNME','Y','N','N'),
('APLLIB','FLEFLD','FLDSEQ','N','N','N'),
('APLLIB','FLEFLD','FLDSTS','N','N','N'),
('APLLIB','FLEFLD','FLEFLDIDN','N','N','N'),
('APLLIB','FLEFLD','FLELIB','Y','N','N'),
('APLLIB','FLEFLD','FLEMSTIDN','N','N','N'),
('APLLIB','FLEFLD','FLENME','Y','N','N'),
('APLLIB','FLEFLD','IDNICM','N','N','N'),
('APLLIB','FLEFLD','MNTDTM','N','N','N'),
('APLLIB','FLEFLD','MNTJOB','N','N','N'),
('APLLIB','FLEFLD','MNTPGM','N','N','N'),
('APLLIB','FLEFLD','MNTUSR','N','N','N'),
('APLLIB','FLEFLD','NTEEXS','N','N','N'),
('APLLIB','FLEFLD','PRIKEY','N','N','N'),
('APLLIB','FLEFLD','STRIDN','N','N','N'),
('APLLIB','FLEIDX','ACVROW','N','N','N'),
('APLLIB','FLEIDX','CRTDTM','N','N','N'),
('APLLIB','FLEIDX','CRTJOB','N','N','N'),
('APLLIB','FLEIDX','CRTPGM','N','N','N'),
('APLLIB','FLEIDX','CRTUSR','N','N','N'),
('APLLIB','FLEIDX','FLEIDXIDN','N','N','N'),
('APLLIB','FLEIDX','FLELIB','N','N','N'),
('APLLIB','FLEIDX','FLEMSTIDN','N','N','N'),
('APLLIB','FLEIDX','FLENME','N','N','N'),
('APLLIB','FLEIDX','IDXLIB','Y','N','N'),
('APLLIB','FLEIDX','IDXNME','Y','N','N'),
('APLLIB','FLEIDX','IDXTXT','N','N','N'),
('APLLIB','FLEIDX','IDXUNI','N','N','N'),
('APLLIB','FLEIDX','MNTDTM','N','N','N'),
('APLLIB','FLEIDX','MNTJOB','N','N','N'),
('APLLIB','FLEIDX','MNTPGM','N','N','N'),
('APLLIB','FLEIDX','MNTUSR','N','N','N'),
('APLLIB','FLELOG','ACVROW','N','N','N'),
('APLLIB','FLELOG','CRTDTM','N','N','N'),
('APLLIB','FLELOG','CRTJOB','N','N','N'),
('APLLIB','FLELOG','CRTPGM','N','N','N'),
('APLLIB','FLELOG','CRTUSR','N','N','N'),
('APLLIB','FLELOG','FLDNME','N','N','N'),
('APLLIB','FLELOG','FLEFLDIDN','N','N','N'),
('APLLIB','FLELOG','FLELIB','N','N','N'),
('APLLIB','FLELOG','FLELOGIDN','Y','N','N'),
('APLLIB','FLELOG','FLEMSTIDN','N','N','N'),
('APLLIB','FLELOG','FLENME','N','N','N'),
('APLLIB','FLELOG','LOGDES','N','N','N'),
('APLLIB','FLELOG','LOGMSG','N','N','N'),
('APLLIB','FLELOG','LOGTYP','N','N','N'),
('APLLIB','FLELOG','MNTDTM','N','N','N'),
('APLLIB','FLELOG','MNTJOB','N','N','N'),
('APLLIB','FLELOG','MNTPGM','N','N','N'),
('APLLIB','FLELOG','MNTUSR','N','N','N'),
('APLLIB','FLEMST','ACVROW','N','N','N'),
('APLLIB','FLEMST','CHGSCD','N','N','N'),
('APLLIB','FLEMST','CRTDTM','N','N','N'),
('APLLIB','FLEMST','CRTJOB','N','N','N'),
('APLLIB','FLEMST','CRTPGM','N','N','N'),
('APLLIB','FLEMST','CRTUSR','N','N','N'),
('APLLIB','FLEMST','DCTNME','N','N','N'),
('APLLIB','FLEMST','FLDCNT','N','N','N'),
('APLLIB','FLEMST','FLEDES','N','N','N'),
('APLLIB','FLEMST','FLEERR','N','N','N'),
('APLLIB','FLEMST','FLELIB','Y','N','N'),
('APLLIB','FLEMST','FLEMSTIDN','N','N','N'),
('APLLIB','FLEMST','FLENME','Y','N','N'),
('APLLIB','FLEMST','FLESTS','N','N','N'),
('APLLIB','FLEMST','IDXCNT','N','N','N'),
('APLLIB','FLEMST','MNTDTM','N','N','N'),
('APLLIB','FLEMST','MNTJOB','N','N','N'),
('APLLIB','FLEMST','MNTPGM','N','N','N'),
('APLLIB','FLEMST','MNTUSR','N','N','N'),
('APLLIB','FLEMST','NTEEXS','N','N','N'),
('APLLIB','FLEMST','PRDFLE','N','N','N'),
('APLLIB','FLEMST','TBLNME','N','N','N'),
('APLLIB','FLENTE','ACVROW','N','N','N'),
('APLLIB','FLENTE','CRTDTM','N','N','N'),
('APLLIB','FLENTE','CRTJOB','N','N','N'),
('APLLIB','FLENTE','CRTPGM','N','N','N'),
('APLLIB','FLENTE','CRTUSR','N','N','N'),
('APLLIB','FLENTE','FLELIB','Y','N','N'),
('APLLIB','FLENTE','FLEMSTIDN','N','N','N'),
('APLLIB','FLENTE','FLENME','Y','N','N'),
('APLLIB','FLENTE','FLENTEIDN','Y','N','N'),
('APLLIB','FLENTE','MNTDTM','N','N','N'),
('APLLIB','FLENTE','MNTJOB','N','N','N'),
('APLLIB','FLENTE','MNTPGM','N','N','N'),
('APLLIB','FLENTE','MNTUSR','N','N','N'),
('APLLIB','FLENTE','NTE','N','N','N'),
('APLLIB','FLENTE','NTESEQ','Y','N','N'),
('APLLIB','HLPDTL','ACVROW','N','N','N'),
('APLLIB','HLPDTL','CRTDTM','N','N','N'),
('APLLIB','HLPDTL','CRTJOB','N','N','N'),
('APLLIB','HLPDTL','CRTPGM','N','N','N'),
('APLLIB','HLPDTL','CRTUSR','N','N','N'),
('APLLIB','HLPDTL','DCTNME','Y','N','N'),
('APLLIB','HLPDTL','DSPFLE','Y','N','N'),
('APLLIB','HLPDTL','FLDNME','Y','N','N'),
('APLLIB','HLPDTL','HLPDTLIDN','N','N','N'),
('APLLIB','HLPDTL','HLPTXT','N','N','N'),
('APLLIB','HLPDTL','MNTDTM','N','N','N'),
('APLLIB','HLPDTL','MNTJOB','N','N','N'),
('APLLIB','HLPDTL','MNTPGM','N','N','N'),
('APLLIB','HLPDTL','MNTUSR','N','N','N'),
('APLLIB','HLPDTL','SEQNBR','Y','N','N'),
('APLLIB','HLPDTL','VAL','Y','N','N'),
('APLLIB','HLPMST','ACVROW','N','N','N'),
('APLLIB','HLPMST','CRTDTM','N','N','N'),
('APLLIB','HLPMST','CRTJOB','N','N','N'),
('APLLIB','HLPMST','CRTPGM','N','N','N'),
('APLLIB','HLPMST','CRTUSR','N','N','N'),
('APLLIB','HLPMST','DCTNME','Y','N','N'),
('APLLIB','HLPMST','DES','N','N','N'),
('APLLIB','HLPMST','DSPFLE','Y','N','N'),
('APLLIB','HLPMST','FLDNME','Y','N','N'),
('APLLIB','HLPMST','HLPMSTIDN','N','N','N'),
('APLLIB','HLPMST','HLPREF','N','Y','N'),
('APLLIB','HLPMST','HLPTYP','N','N','N'),
('APLLIB','HLPMST','LNECNT','N','N','N'),
('APLLIB','HLPMST','MNTDTM','N','N','N'),
('APLLIB','HLPMST','MNTJOB','N','N','N'),
('APLLIB','HLPMST','MNTPGM','N','N','N'),
('APLLIB','HLPMST','MNTUSR','N','N','N'),
('APLLIB','HLPMST','VAL','Y','N','N'),
('APLLIB','IDXFLD','ACVROW','N','N','N'),
('APLLIB','IDXFLD','CRTDTM','N','N','N'),
('APLLIB','IDXFLD','CRTJOB','N','N','N'),
('APLLIB','IDXFLD','CRTPGM','N','N','N'),
('APLLIB','IDXFLD','CRTUSR','N','N','N'),
('APLLIB','IDXFLD','FLEFLDIDN','N','N','N'),
('APLLIB','IDXFLD','FLEIDXIDN','N','N','N'),
('APLLIB','IDXFLD','FLELIB','N','N','N'),
('APLLIB','IDXFLD','FLENME','N','N','N'),
('APLLIB','IDXFLD','IDXFLD','Y','N','N'),
('APLLIB','IDXFLD','IDXFLDIDN','N','N','N'),
('APLLIB','IDXFLD','IDXLIB','Y','N','N'),
('APLLIB','IDXFLD','IDXNME','Y','N','N'),
('APLLIB','IDXFLD','IDXSEQ','N','N','N'),
('APLLIB','IDXFLD','MNTDTM','N','N','N'),
('APLLIB','IDXFLD','MNTJOB','N','N','N'),
('APLLIB','IDXFLD','MNTPGM','N','N','N'),
('APLLIB','IDXFLD','MNTUSR','N','N','N'),
('APLLIB','IFMDRV','ACVROW','','',''),
('APLLIB','IFMDRV','CRTDTM','','',''),
('APLLIB','IFMDRV','CRTJOB','','',''),
('APLLIB','IFMDRV','CRTPGM','','',''),
('APLLIB','IFMDRV','CRTUSR','','',''),
('APLLIB','IFMDRV','DSTPTH','N','N','N'),
('APLLIB','IFMDRV','FRMPTH','Y','N','N'),
('APLLIB','IFMDRV','IFMDRVIDN','','',''),
('APLLIB','IFMDRV','MNTDTM','','',''),
('APLLIB','IFMDRV','MNTJOB','','',''),
('APLLIB','IFMDRV','MNTPGM','','',''),
('APLLIB','IFMDRV','MNTUSR','','',''),
('APLLIB','IFMLOG','ACVROW','','',''),
('APLLIB','IFMLOG','CRTDTM','','',''),
('APLLIB','IFMLOG','CRTJOB','','',''),
('APLLIB','IFMLOG','CRTPGM','','',''),
('APLLIB','IFMLOG','CRTUSR','','',''),
('APLLIB','IFMLOG','DSTPTH','N','N','N'),
('APLLIB','IFMLOG','FRMPTH','N','N','N'),
('APLLIB','IFMLOG','IFMLOGIDN','Y','N','N'),
('APLLIB','IFMLOG','IFMSTS','N','N','N'),
('APLLIB','IFMLOG','LNGCMT','N','N','N'),
('APLLIB','IFMLOG','MNTDTM','','',''),
('APLLIB','IFMLOG','MNTJOB','','',''),
('APLLIB','IFMLOG','MNTPGM','','',''),
('APLLIB','IFMLOG','MNTUSR','','',''),
('APLLIB','PGMACT','ACTCDE','Y','N','N'),
('APLLIB','PGMACT','ACVROW','N','N','N'),
('APLLIB','PGMACT','CRTDTM','N','N','N'),
('APLLIB','PGMACT','CRTJOB','N','N','N'),
('APLLIB','PGMACT','CRTPGM','N','N','N'),
('APLLIB','PGMACT','CRTUSR','N','N','N'),
('APLLIB','PGMACT','DES','N','N','N'),
('APLLIB','PGMACT','FNCKEY','N','N','N'),
('APLLIB','PGMACT','MNTDTM','N','N','N'),
('APLLIB','PGMACT','MNTJOB','N','N','N'),
('APLLIB','PGMACT','MNTPGM','N','N','N'),
('APLLIB','PGMACT','MNTUSR','N','N','N'),
('APLLIB','PGMACT','OPTION','Y','N','N'),
('APLLIB','PGMACT','PGMACTIDN','N','N','N'),
('APLLIB','PGMACT','PGMNME','Y','N','N'),
('APLLIB','PGMACT','SEQNBR','N','N','N'),
('APLLIB','PGMFNC','ACVROW','N','N','N'),
('APLLIB','PGMFNC','CRTDTM','N','N','N'),
('APLLIB','PGMFNC','CRTJOB','N','N','N'),
('APLLIB','PGMFNC','CRTPGM','N','N','N'),
('APLLIB','PGMFNC','CRTUSR','N','N','N'),
('APLLIB','PGMFNC','DES','N','N','N'),
('APLLIB','PGMFNC','FNCKEY','Y','N','N'),
('APLLIB','PGMFNC','MNTDTM','N','N','N'),
('APLLIB','PGMFNC','MNTJOB','N','N','N'),
('APLLIB','PGMFNC','MNTPGM','N','N','N'),
('APLLIB','PGMFNC','MNTUSR','N','N','N'),
('APLLIB','PGMFNC','OPTION','Y','N','N'),
('APLLIB','PGMFNC','PGMFNCIDN','N','N','N'),
('APLLIB','PGMFNC','PGMNME','Y','N','N'),
('APLLIB','PGMFNC','SEQNBR','N','N','N'),
('APLLIB','PGMMST','ACVROW','N','N','N'),
('APLLIB','PGMMST','APL','N','N','N'),
('APLLIB','PGMMST','CRTDTM','N','N','N'),
('APLLIB','PGMMST','CRTJOB','N','N','N'),
('APLLIB','PGMMST','CRTPGM','N','N','N'),
('APLLIB','PGMMST','CRTUSR','N','N','N'),
('APLLIB','PGMMST','DES','N','N','N'),
('APLLIB','PGMMST','DFTAUT','N','N','N'),
('APLLIB','PGMMST','DSPFLE','N','N','N'),
('APLLIB','PGMMST','HLPCNT','N','N','N'),
('APLLIB','PGMMST','MNTDTM','N','N','N'),
('APLLIB','PGMMST','MNTJOB','N','N','N'),
('APLLIB','PGMMST','MNTPGM','N','N','N'),
('APLLIB','PGMMST','MNTUSR','N','N','N'),
('APLLIB','PGMMST','MNUNME','N','N','N'),
('APLLIB','PGMMST','MNUOBJ','N','N','N'),
('APLLIB','PGMMST','OBJTYP','N','N','N'),
('APLLIB','PGMMST','PGMMSTIDN','N','N','N'),
('APLLIB','PGMMST','PGMNME','Y','N','N'),
('APLLIB','PGMMST','PGMTYP','N','N','N'),
('APLLIB','PGMMST','REQDBA','N','N','N'),
('APLLIB','PGMMST','REQITR','N','N','N'),
('APLLIB','PGMMST','REQOWN','N','N','N'),
('APLLIB','PGMMST','SECAUT','N','N','N'),
('APLLIB','PGMMST','SECPGM','N','N','N'),
('APLLIB','PGMMST','TOTCNT','N','N','N'),
('APLLIB','PGMMST','WEBAPL','N','N','N'),
('APLLIB','PGMOPT','ACVROW','N','N','N'),
('APLLIB','PGMOPT','CRTDTM','N','N','N'),
('APLLIB','PGMOPT','CRTJOB','N','N','N'),
('APLLIB','PGMOPT','CRTPGM','N','N','N'),
('APLLIB','PGMOPT','CRTUSR','N','N','N'),
('APLLIB','PGMOPT','DES','N','N','N'),
('APLLIB','PGMOPT','MNTDTM','N','N','N'),
('APLLIB','PGMOPT','MNTJOB','N','N','N'),
('APLLIB','PGMOPT','MNTPGM','N','N','N'),
('APLLIB','PGMOPT','MNTUSR','N','N','N'),
('APLLIB','PGMOPT','OPT','Y','N','N'),
('APLLIB','PGMOPT','OPTION','Y','N','N'),
('APLLIB','PGMOPT','PGMNME','Y','N','N'),
('APLLIB','PGMOPT','PGMOPTIDN','N','N','N'),
('APLLIB','ROLAPR','ACVROW','N','N','N'),
('APLLIB','ROLAPR','CRTDTM','N','N','N'),
('APLLIB','ROLAPR','CRTJOB','N','N','N'),
('APLLIB','ROLAPR','CRTPGM','N','N','N'),
('APLLIB','ROLAPR','CRTUSR','N','N','N'),
('APLLIB','ROLAPR','MNTDTM','N','N','N'),
('APLLIB','ROLAPR','MNTJOB','N','N','N'),
('APLLIB','ROLAPR','MNTPGM','N','N','N'),
('APLLIB','ROLAPR','MNTUSR','N','N','N'),
('APLLIB','ROLAPR','ROLAPRIDN','Y','N','N'),
('APLLIB','ROLMST','ACVROW','N','N','N'),
('APLLIB','ROLMST','CRTDTM','N','N','N'),
('APLLIB','ROLMST','CRTJOB','N','N','N'),
('APLLIB','ROLMST','CRTPGM','N','N','N'),
('APLLIB','ROLMST','CRTUSR','N','N','N'),
('APLLIB','ROLMST','LNGCMT','N','N','N'),
('APLLIB','ROLMST','MNTDTM','N','N','N'),
('APLLIB','ROLMST','MNTJOB','N','N','N'),
('APLLIB','ROLMST','MNTPGM','N','N','N'),
('APLLIB','ROLMST','MNTUSR','N','N','N'),
('APLLIB','ROLMST','ROLMSTIDN','N','N','N'),
('APLLIB','ROLMST','ROLNME','Y','N','N'),
('APLLIB','USRMST','AARFLR','N','Y','N'),
('APLLIB','USRMST','ACGCDE','N','Y','N'),
('APLLIB','USRMST','ACVROW','','',''),
('APLLIB','USRMST','ARCFLR','N','Y','N'),
('APLLIB','USRMST','ARCOUT','N','Y','N'),
('APLLIB','USRMST','ATAFMT','N','Y','N'),
('APLLIB','USRMST','ATATYP','N','Y','N'),
('APLLIB','USRMST','CRTDTM','','',''),
('APLLIB','USRMST','CRTJOB','','',''),
('APLLIB','USRMST','CRTPGM','','',''),
('APLLIB','USRMST','CRTUSR','','',''),
('APLLIB','USRMST','EMLOUT','N','Y','N'),
('APLLIB','USRMST','EMPNBR','N','Y','N'),
('APLLIB','USRMST','FAXOUT','N','Y','N'),
('APLLIB','USRMST','FSTNME','N','Y','N'),
('APLLIB','USRMST','GRPPRF','N','Y','N'),
('APLLIB','USRMST','HLDOUT','N','Y','N'),
('APLLIB','USRMST','LSTNME','N','Y','N'),
('APLLIB','USRMST','MNTDTM','','',''),
('APLLIB','USRMST','MNTJOB','','',''),
('APLLIB','USRMST','MNTPGM','','',''),
('APLLIB','USRMST','MNTUSR','','',''),
('APLLIB','USRMST','OTOEML','N','Y','N'),
('APLLIB','USRMST','OTONME','N','Y','N'),
('APLLIB','USRMST','PHNEXT','N','Y','N'),
('APLLIB','USRMST','PHNNBR','N','Y','N'),
('APLLIB','USRMST','PRTDEV','N','Y','N'),
('APLLIB','USRMST','PRTOTQ','N','Y','N'),
('APLLIB','USRMST','PRTOUT','N','Y','N'),
('APLLIB','USRMST','SAVOUT','N','Y','N'),
('APLLIB','USRMST','USRCLS','N','Y','N'),
('APLLIB','USRMST','USRDPT','N','Y','N'),
('APLLIB','USRMST','USREML','N','Y','N'),
('APLLIB','USRMST','USREMP','N','Y','N'),
('APLLIB','USRMST','USRINT','N','Y','N'),
('APLLIB','USRMST','USRMSTIDN','N','N','N'),
('APLLIB','USRMST','USROQL','N','N','N'),
('APLLIB','USRMST','USROQN','N','Y','N'),
('APLLIB','USRMST','USRPRF','Y','N','N'),
('APLLIB','USRMST','USRSTS','N','Y','N'),
('APLLIB','USRMST','USRTTL','N','Y','N'),
('APLLIB','USRMST','USRTXT','N','Y','N'),
('APLLIB','USRROL','ACVROW','N','N','N'),
('APLLIB','USRROL','CRTDTM','N','N','N'),
('APLLIB','USRROL','CRTJOB','N','N','N'),
('APLLIB','USRROL','CRTPGM','N','N','N'),
('APLLIB','USRROL','CRTUSR','N','N','N'),
('APLLIB','USRROL','MNTDTM','N','N','N'),
('APLLIB','USRROL','MNTJOB','N','N','N'),
('APLLIB','USRROL','MNTPGM','N','N','N'),
('APLLIB','USRROL','MNTUSR','N','N','N'),
('APLLIB','USRROL','ROLAPR','N','Y','N'),
('APLLIB','USRROL','ROLAPRIDN','N','Y','N'),
('APLLIB','USRROL','ROLMSTIDN','Y','Y','N'),
('APLLIB','USRROL','USRMSTIDN','Y','Y','N'),
('APLLIB','USRROL','USRROLIDN','N','N','N')
) as source (fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
on (target.fleLib,target.fleNme,target.fldNme) = (source.fleLib,source.fleNme,source.fldNme)

When Matched Then Update Set
    target.fleLib = source.fleLib,
    target.fleNme = source.fleNme,
    target.fldNme = source.fldNme,
    target.priKey = source.priKey,
    target.audFld = source.audFld,
    target.encFld = source.encFld

When not Matched Then
    Insert (fleLib,  fleNme, fldNme,   priKey,audFld,encFld)
    Values (source.fleLib,source.fleNme,source.fldNme,source.priKey,source.audFld,source.encFld);


  // populate FLEIDX, for now just the Identity indexes
  // To generate values from production table use:
  // Select '(''' || trim(fleLib) || ''','''
  //              || trim(fleNme) || ''','''
  //              || trim(idxLib) || ''','''
  //              || trim(idxNme) || ''','''
  //              || trim(replace(idxTxt,'''','''''')) || ''','''
  //              || trim(idxUni) || '''),'
  // From FLEIDX
  // Where fleLib = 'APLLIB'
  // Order by fleNme, idxNme;

  Exec SQL
Merge into APLLIB.FLEIDX as Target
Using(
  Values
('APLLIB','APLLIB','APLLIB','APLLIBIDN','Application Libraries - Id','U'),
('APLLIB','AUDLOG','APLLIB','AUDLOGIDN','Audit Log - Id','U'),
('APLLIB','CHKBJB','APLLIB','CHKBJBIDN','Check Batch Jobs - Id','Y'),
('APLLIB','DCTFLD','APLLIB','DCTFLDIDN','Dictionary Fields - Id','U'),
('APLLIB','DCTMST','APLLIB','DCTMSTIDN','Dictionary Master - Id','U'),
('APLLIB','DCTSEG','APLLIB','DCTSEGIDN','Dictionary Segments   - Id','U'),
('APLLIB','DCTVAL','APLLIB','DCTVALIDN','Dictionary Values - Id','U'),
('APLLIB','FLDNTE','APLLIB','FLDNTEIDN','Field Notes - Id','U'),
('APLLIB','FLDTYP','APLLIB','FLDTYPIDN','Field Types - Id','U'),
('APLLIB','FLEERR','APLLIB','FLEERRIDN','File Errors - Id','U'),
('APLLIB','FLEFLD','APLLIB','FLEFLDIDN','File Fields - Id','U'),
('APLLIB','FLEIDX','APLLIB','FLEIDXIDN','File Indexes - Id','U'),
('APLLIB','FLELOG','APLLIB','FLELOGIDN','File Log - Id','U'),
('APLLIB','FLEMST','APLLIB','FLEMSTIDN','File Master - Id','U'),
('APLLIB','FLENTE','APLLIB','FLENTEIDN','File Notes - Id','U'),
('APLLIB','HLPDTL','APLLIB','HLPDTLIDN','Help Detail - Id','U'),
('APLLIB','HLPMST','APLLIB','HLPMSTIDN','Help Master - Id','U'),
('APLLIB','IDXFLD','APLLIB','IDXFLDIDN','Index Fields - Id','U'),
('APLLIB','IFMDRV','APLLIB','IFMDRVIDN','IFS Monitor Driver Table - Id','Y'),
('APLLIB','IFMLOG','APLLIB','IFMLOGIDN','IFS Monitor Log - Id','Y'),
('APLLIB','PGMACT','APLLIB','PGMACTIDN','Program Actions - Id','U'),
('APLLIB','PGMFNC','APLLIB','PGMFNCIDN','Program Function Keys - Id','U'),
('APLLIB','PGMMST','APLLIB','PGMMSTIDN','Program Master - Id','U'),
('APLLIB','PGMOPT','APLLIB','PGMOPTIDN','Program Options - Id','U'),
('APLLIB','ROLAPR','APLLIB','ROLAPRIDN','Role Approvals - Id','U'),
('APLLIB','ROLMST','APLLIB','ROLMSTIDN','Role Master - Id','U'),
('APLLIB','USRMST','APLLIB','USRMSTIDN','User Master File - Id','Y'),
('APLLIB','USRROL','APLLIB','USRROLIDN','User Roles - Id','U')
) as source (fleLib , fleNme , idxLib , idxNme, idxTxt, idxUni)
on (target.fleLib,target.fleNme,target.idxLib,target.idxNme) = (source.fleLib,source.fleNme,source.idxLib,source.idxNme)

When Matched Then Update Set
    target.fleLib = source.fleLib,
    target.fleNme = source.fleNme,
    target.idxLib = source.idxLib,
    target.idxNme = source.idxNme,
    target.idxTxt = source.idxTxt,
    target.idxUni = source.idxUni

When not Matched Then
    Insert (fleLib, fleNme, idxLib, idxNme, idxTxt, idxUni)
    Values (source.fleLib ,source.fleNme,source.idxLib,source.idxNme,source.idxTxt,source.idxUni);
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
  // To generate values from production table use:
  // Select '(''' || trim(idxLib) || ''','''
  //              || trim(idxNme) || ''','''
  //              || trim(idxFld) || ''','
  //              || idxSeq || ','''
  //              || trim(fleLib) || ''','''
  //              || trim(fleNme) || '''),'
  // From IDXFLD
  // Where fleLib = 'APLLIB'
  // Order by idxNme;
  Exec SQL
Merge into APLLIB.IDXFLD as Target
Using(
  Values
      ('APLLIB','APLLIBIDN','APLLIBIDN',10,'APLLIB','APLLIB'),
      ('APLLIB','AUDLOGIDN','AUDLOGIDN',10,'APLLIB','AUDLOG'),
      ('APLLIB','CHKBJBIDN','CHKBJBIDN',10,'APLLIB','CHKBJB'),
      ('APLLIB','DCTFLDIDN','DCTFLDIDN',10,'APLLIB','DCTFLD'),
      ('APLLIB','DCTMSTIDN','DCTMSTIDN',10,'APLLIB','DCTMST'),
      ('APLLIB','DCTSEGIDN','DCTSEGIDN',10,'APLLIB','DCTSEG'),
      ('APLLIB','DCTVALIDN','DCTVALIDN',10,'APLLIB','DCTVAL'),
      ('APLLIB','FLDNTEIDN','FLDNTEIDN',10,'APLLIB','FLDNTE'),
      ('APLLIB','FLDTYPIDN','FLDTYPIDN',10,'APLLIB','FLDTYP'),
      ('APLLIB','FLEERRIDN','FLEERRIDN',10,'APLLIB','FLEERR'),
      ('APLLIB','FLEFLDIDN','FLEFLDIDN',10,'APLLIB','FLEFLD'),
      ('APLLIB','FLEIDXIDN','FLEIDXIDN',10,'APLLIB','FLEIDX'),
      ('APLLIB','FLELOGIDN','FLELOGIDN',10,'APLLIB','FLELOG'),
      ('APLLIB','FLEMSTIDN','FLEMSTIDN',10,'APLLIB','FLEMST'),
      ('APLLIB','FLENTEIDN','FLENTEIDN',10,'APLLIB','FLENTE'),
      ('APLLIB','HLPDTLIDN','HLPDTLIDN',10,'APLLIB','HLPDTL'),
      ('APLLIB','HLPMSTIDN','HLPMSTIDN',10,'APLLIB','HLPMST'),
      ('APLLIB','IDXFLDIDN','IDXFLDIDN',10,'APLLIB','IDXFLD'),
      ('APLLIB','IFMDRVIDN','IFMDRVIDN',10,'APLLIB','IFMDRV'),
      ('APLLIB','IFMLOGIDN','IFMLOGIDN',10,'APLLIB','IFMLOG'),
      ('APLLIB','PGMACTIDN','PGMACTIDN',10,'APLLIB','PGMACT'),
      ('APLLIB','PGMFNCIDN','PGMFNCIDN',10,'APLLIB','PGMFNC'),
      ('APLLIB','PGMMSTIDN','PGMMSTIDN',10,'APLLIB','PGMMST'),
      ('APLLIB','PGMOPTIDN','PGMOPTIDN',10,'APLLIB','PGMOPT'),
      ('APLLIB','ROLAPRIDN','ROLAPRIDN',10,'APLLIB','ROLAPR'),
      ('APLLIB','ROLMSTIDN','ROLMSTIDN',10,'APLLIB','ROLMST'),
      ('APLLIB','USRMSTIDN','USRMSTIDN',10,'APLLIB','USRMST'),
      ('APLLIB','USRROLIDN','USRROLIDN',10,'APLLIB','USRROL')
) as source (idxLib, idxNme, idxFld, idxSeq, fleLib, fleNme)
on (target.idxLib,target.idxNme,target.idxFld) = (source.idxLib,source.idxNme,source.idxFld)

When Matched Then Update Set
    target.idxLib = source.idxLib,
    target.idxNme = source.idxNme,
    target.idxFld = source.idxFld,
    target.idxSeq = source.idxSeq,
    target.fleLib = source.fleLib,
    target.fleNme = source.fleNme

When not Matched Then
    Insert (idxLib, idxNme, idxFld, idxSeq, fleLib, fleNme)
    Values (source.idxLib,source.idxNme,source.idxFld,source.idxSeq,source.fleLib,source.fleNme);
  #$SQLSTT(sqlState);

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
