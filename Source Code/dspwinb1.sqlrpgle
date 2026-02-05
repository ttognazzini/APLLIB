**free
Ctl-Opt Option(*srcStmt) DftActGrp(*NO) BndDir('APLLIB/APLLIB') Main(Main);

// Display text in a window, CPP for DSPWIN command

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DSPWINB1');
    winTxt char(2000);
  End-Pi;

  // Display the text in a window
  #$DSPWIN(winTxt);

End-Proc;
