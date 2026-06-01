**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Return the status of a wtr

// API error data structure:
Dcl-Ds ERRC0100 qualified;
  BytPrv int(10) inz( %size( ERRC0100 ));
  BytAvl int(10);
  MsgId char(7);
  *n char(1);
  MsgDta char(128);
End-Ds;

// Writer information format:
Dcl-Ds WTRI0100 qualified;
  BytRtn int(10);
  BytAvl int(10);
  StrUsrPrf char(10);
  WrtSts char(1);
  MsgWaitSts char(1);
  HldSts char(1);
  EndPndSts char(1);
  HldPndSts char(1);
  BtwFilSts char(1);
  BtwCpySts char(1);
  DtaWaitSts char(1);
  DevWaitSts char(1);
  OnJobqSts char(1);
  TypWtr char(1);
  *n char(3);
  WtrJobNam char(10);
  WtrJobUsrPrf char(10);
  WtrJobNbr char(6);
  PrtDevTyp char(10);
  NbrSep int(10);
  DrwSep int(10);
  AlgForm char(10);
  OutQueNam char(10);
  OutQueLib char(10);
  OutQueSts char(1);
  *n char(1);
  FrmTyp char(10);
  MsgOpt char(10);
  AutEntWtr char(10);
  AlwDirPrt char(10);
  MsgQueNam char(10);
  MsgQueLib char(10);
  *n char(2);
  ChgEfc char(10);
  NxtOutQueNam char(10);
  NxtOutQueLib char(10);
  NxtFrmTyp char(10);
  NxtMsgOpt char(10);
  NxtFilSep int(10);
  NxtSepDrw int(10);
  SplFilNam char(10);
  JobNam char(10);
  UsrPrf char(10);
  JobNbr char(6);
  SplFilNbr int(10);
  PagWrt int(10);
  PagTot int(10);
  CpyLeft int(10);
  CpyTot int(10);
  MsgKey char(4);
  InzPrt char(1);
  PrtDevNam char(10);
  JobSysNam char(8);
  SpfCrtDat char(7);
  SpfCrtTim char(6);
End-Ds;

// Retrieve writer information:
Dcl-Pr RtvWtrInf extpgm( 'QSPRWTRI' );
  *n char(65535) options( *varsize ); // RcvVar
  *n int(10) const; // RcvVarLen
  *n char(8) const; // FmtNam
  *n char(10) const; // PrtNam
  *n char(32767) options( *varsize ); // Error
  *n char(10) const  options( *nopass ); // WtrNam
End-Pr;

// Entry parameters:
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm;
    wtrNme char(10);
    pmrWtrSts char(10) options(*nopass:*omit);
    pmrFrmTyp char(10) options(*nopass:*omit);
  End-Pi;
  Dcl-S wtrSts like(pmrWtrSts);
  Dcl-S frmTyp like(pmrFrmTyp);

  RtvWtrInf( WTRI0100
           : %size( WTRI0100 )
           : 'WTRI0100'
           : '*WRITER'
           : ERRC0100
           : wtrNme
           );

  If ERRC0100.BytAvl > *Zero And (ERRC0100.MsgId  in %list('CPF3313':'CPF33C8'));
    wtrSts = 'END';
    frmTyp = 'Unknown';
  ElseIf  ERRC0100.BytAvl > *Zero;
    wtrSts = 'ERR';
    frmTyp = 'Unknown';
  ElseIf WTRI0100.msgWaitSts = 'Y';
    wtrSts = 'MSGW';
    frmTyp = WTRI0100.frmTyp;
  ElseIf WTRI0100.hldSts = 'Y';
    wtrSts = 'HLD';
    frmTyp = WTRI0100.frmTyp;
  ElseIf WTRI0100.wrtSts = 'N';
    wtrSts = 'STR';
    frmTyp = WTRI0100.frmTyp;
  Else;
    wtrSts = 'END';
    frmTyp = WTRI0100.frmTyp;
  EndIf;

  If %parms >= 2 and %addr(pmrWtrSts) <> *null;
    pmrWtrSts = wtrSts;
  EndIf;
  If %parms >= 3 and %addr(pmrFrmTyp) <> *null;
    pmrFrmTyp = frmTyp;
  EndIf;

End-Proc;
