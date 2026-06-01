**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Validate an email address, processes command valemail

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

Dcl-Proc Main;
  Dcl-Pi *n ExtPGm('VALEMLB1');
    email char(60);
    pass char(1);
  End-Pi;

  pass = 'F';
  If #$VEML(email);
    pass = 'Y';
  EndIf;

End-Proc;
