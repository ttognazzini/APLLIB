**free
Ctl-Opt option(*SrcStmt) Main(Main);

// Get an email Address, processes command GETEML

// program status data structure, used to get current user
Dcl-Ds psds  psds; //Pgm status DS
  psdsdata  Char(429); //The data
  user      Char(10)   OVERLAY(PSDSDATA:254);
End-Ds;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('GETEMLB1');
    emlAdd char(50);
    pmrUsrPrf char(10);
  End-Pi;
  Dcl-S usrPrf char(10);

  // if a user is not passed, use the current user
  If %parms() >= 2 and %addr(pmrUsrPrf) <> *null and pmrUsrPRf <> '';
    usrPrf = pmrUsrPrf;
  Else;
    usrPrf = user;
  EndIf;

  If usrPrf = 'TTOGNAZZIN';
    emlAdd = 'tim.tognazzini@arrowheadwinch.com';
  Else;
    Exec SQL
      Select fkEml
      Into :emlAdd
      From FKUSREML
      Where fkUSr = :usrPrf;
  EndIf;

End-Proc;
