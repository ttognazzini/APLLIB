**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Test #$DBGBCH system

// To test submit this to batch, the shoudl go on hold
//   SBMJOB CMD('call DBGBCHB2')
// Then use command DBGBCH to make sure it works
//   DBGBCH
// This should start a service job to the submitted job and start a debug session.

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DBGBCHB2');
  End-Pi;
  Dcl-S x packed(3);

  #$DbgBch(User);

  // just do some stuff to debug through
  For x = 1 to 5;
    #$DSPWIN(%char(x));
  EndFor;

End-Proc;
