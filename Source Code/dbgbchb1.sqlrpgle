**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// START DEBUG FOR BATCH JOBS
// compile as QSECOFR and USRPRF(*OWNER)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DBGBCHB1');
    usrPrf char(10);
  End-Pi;
  Dcl-S dbgPgm    char(10);
  Dcl-S dbgPgmLib char(10);
  Dcl-S dbgDqNm   char(10);
  Dcl-S dbgDqLb   char(10);
  Dcl-S dbgJbNm   char(10);
  Dcl-S dbgJbUs   char(10);
  Dcl-S dbgJbNo   char(6);

  // If user is *CURRENT replace with the current user
  If usrPrf = '*CURRENT';
    usrPrf = user;
  EndIf;

  // Get the data for the user
  Exec SQL
    Select dbgPgm, dbgPgmLib, dbgDqNm, dbgDqLb, dbgJbNm, dbgJbUs, dbgJbNo
    Into  :dbgPgm,:dbgPgmLib,:dbgDqNm,:dbgDqLb,:dbgJbNm,:dbgJbUs,:dbgJbNo
    From DBGBCH
    Where dbgUser = :usrPrf;
  If sqlState = '02000';
    #$SNDMSG('Debug information not found for user':'*INFO');
    Return;
  ElseIf sqlState > '02000';
    #$SNDMSG('Error in SQL, text = ' + #$SQLMessage(sqlCode):'*INFO');
    Return;
  EndIf;

  // righ justify and zero pad job number
  evalr dbgJbNo = '000000' + %trim(dbgJbNo);

  // end and restart the service job and debug in case they were already started
  #$CMD('ENDDBG':1);
  #$CMD('ENDSRVJOB':1);
  #$CMD('STRSRVJOB '+%trim(dbgJbNo)+'/'+%trim(dbgJbUs)+'/'+%trim(dbgJbNm):1);
  #$CMD('STRDBG PGM('+%trim(dbgPgmLib)+'/'+%trim(dbgPgm)+') UPDPROD(*YES)':1);

  // send an entry to the data queue so the program is released
  #$CMD('CALL PGM(QSNDDTAQ) PARM('+dbgDqNm+' '+ dbgDqLb+' x''00001F'' Y)');

End-Proc;
