**free
Ctl-Opt Option(*srcStmt:*nounref) DftActGrp(*NO) BndDir('APLLIB/APLLIB') Main(Main);

// Display URL on users computer

// This program creates the local command from the passed url

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DSPURLB1');
    URL char(499);
  End-Pi;

  // escape & with ^&, add more as needed
  url = %scanrpl('&':'^&':URL);

  // Append Start to the beginning
  URL = 'start ' + URL;

End-Proc;
