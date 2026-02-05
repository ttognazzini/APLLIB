**free
Ctl-Opt Option(*srcStmt) DftActGrp(*NO) BndDir('APLLIB/APLLIB') Main(Main) ActGrp(*new);

// Check Status of Batch Jobs - Example data seed

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Data structure to reference all fields from dictionaries
Dcl-Ds APLDCT extname('APLLIB/APLDCT') Qualified Template End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;

  Exec SQL Delete From APLLIB.CHKBJB;
  Exec SQL Insert Into APLLIB.CHKBJB
        ( jobNme,      sbsNme,      sbsLib,  jobTtl,
          strCmd,
          lngCmt)
  Values('AUTOITP'   ,'ASJ',       'QGPL16','VoicePick Export Program',
         'SBMJOB CMD(CALL PGM(MRPS38S/IMPVPTB1)) JOB(VOICEPICK) JOBD(QGPL16/VOICEPICK) USER(ZZWINCHTAG)',
         ''),
        ('REPORT2WEB','BACKGROUND','QGPL',  'Report to web export program',
         'SBMJOB CMD(CALL PGM(RPWDRVC1)) JOB(REPORT2WEB) JOBD(QGPL/REPORT2WEB) OUTQ(*JOBD) INLLIBL(*JOBD)',
         ''),
        ('VOICEPICK' ,'BACKGROUND','QGPL',  'VoicePick Import Program',
         'SBMJOB CMD(CALL PGM(MRPS38S/IMPVPTB1)) JOB(VOICEPICK) JOBD(QGPL16/VOICEPICK) USER(ZZWINCHTAG)',
         ''),
        ('IFSMONITOR' ,'BACKGROUND','QGPL',  'IFS Monitor, moves files to other folders',
         'SBMJOB CMD(CALL APLLIB/IFMDRVB1) JOB(IFSMONITOR) USER(ZZWINCHTAG) JOBD(QGPL/IFSMONITOR) ',
         '');

End-Proc;
