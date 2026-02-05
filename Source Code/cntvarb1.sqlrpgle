**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Validate an email address, processes command valemail

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures


Dcl-Proc Main;
  Dcl-Pi *n ExtPGm('VALEMLB1');
    psIn  char(50);
    psOut char(50);
  End-Pi;

  psOut = #$CNTR(psIn:50);

End-Proc;
