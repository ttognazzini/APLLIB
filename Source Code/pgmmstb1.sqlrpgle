**FREE
Ctl-Opt option(*srcstmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Program Master - Copy Program

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMMSTB1PR // Always include the prototype for the current program

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMMSTB1');
    frmPgm Like(APLDCT.pgmNme);
    frmLib Like(APLDCT.frmLib);
    frmDsp Like(APLDCT.dspFle);
    toPgm  Like(APLDCT.pgmNme);
    toLib  Like(APLDCT.lib);
    toDsp  Like(APLDCT.dspFle);
    cpyFnc Char(1);
    cpyOpt Char(1);
    cpyDsp Char(1);
    cpyPgmMst Char(1) Const;
    error  Ind; // if any errors occure set this on
  End-Pi;

  // Copy PGMMST Entry
  If cpyPgmMst='Y';
    Exec SQL
      Insert into PGMMST
       ( ACVROW, PGMNME, DES,    DSPFLE, APL,    OBJTYP, PGMTYP, MNUOBJ,
         SECAUT, DFTAUT, WEBAPL, MNUNME, REQITR, REQOWN, REQDBA, SECPGM,
         CRTDTM, CRTUSR, CRTJOB, CRTPGM,
         MNTDTM, MNTUSR, MNTJOB, MNTPGM)
       (Select
         '1',   :toPgm,  DES,   :toDsp,  APL,    OBJTYP, PGMTYP, MNUOBJ,
         SECAUT, DFTAUT, WEBAPL, MNUNME, REQITR, REQOWN, REQDBA, SECPGM,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
         Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
       from PGMMST
       where pgmnme = :frmPgm
       );
    If SQLState>='02';
      #$SNDMSG('*** PGMMST entry not copied for ' + %trim(frmPgm) +
               ', SQLSTATE = ' + %trim(SQLSTATE) + ', SQLERRMC=' + %trim(SQLErrMC) + '.');
      error=*on;
    EndIf;
  EndIf;

  // Copy main source
  Monitor;
    #$CMD('CPYSRCF FROMFILE('+%trim(frmLib)+'/QSRC) +
                   TOFILE('+%trim(toLib)+'/QSRC) +
                   FROMMBR('+%trim(frmPgm)+') +
                   TOMBR('+%trim(toPgm) + ')' : 2);
  On-Error;
    #$SNDMSG('*** Member '+%trim(frmLib)+'/QSRC,'+%trim(frmPgm)+' not copied.');
    error=*on;
  EndMon;

  // Copy Function keys
  Exec SQL
    Insert into PGMFNC
     ( ACVROW, PGMNME, FNCKEY, OPTION, SEQNBR, DES,
       CRTDTM, CRTUSR, CRTJOB, CRTPGM,
       MNTDTM, MNTUSR, MNTJOB, MNTPGM)
     (Select
       '1',   :toPgm,  FNCKEY, OPTION, SEQNBR, DES,
       Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
       Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
     from PGMFNC
     where pgmnme = :frmPgm
     );
  If SQLState>='02';
    #$SNDMSG('*** PGMFNC entry not copied, SQLSTATE = '+%trim(SQLSTATE)+', SQLERRMC='+%trim(SQLErrMC) + '.');
    error=*on;
  EndIf;

  // Copy SFL Options
  Exec SQL
    Insert into PGMOPT
     ( ACVROW, PGMNME, OPT, OPTION, DES,
       CRTDTM, CRTUSR, CRTJOB, CRTPGM,
       MNTDTM, MNTUSR, MNTJOB, MNTPGM)
     (Select
       '1',   :toPgm,  OPT, OPTION, DES,
       Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
       Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam
     from PGMOPT
     where pgmnme = :frmPgm
     );
  If SQLState>='02';
    #$SNDMSG('*** PGMFNC entry not copied, SQLSTATE = '+%trim(SQLSTATE)+', SQLERRMC='+%trim(SQLErrMC) + '.');
    error=*on;
  EndIf;

  // Copy display file if it exists
  Monitor;
    #$CMD('CPYSRCF FROMFILE('+%trim(frmLib)+'/QSRC) +
                   TOFILE('+%trim(toLib)+'/QSRC) +
                   FROMMBR('+%trim(frmDsp)+') +
                   TOMBR('+%trim(toDsp)+')':2);
  On-Error;
    #$SNDMSG('*** Member '+%trim(frmLib)+'/QSRC,'+%trim(frmDsp)+' not copied.');
    error=*on;
  EndMon;

End-Proc;
