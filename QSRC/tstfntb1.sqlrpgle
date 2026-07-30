**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*New) BndDir('APLLIB') Main(Main);

// Test printing IBM raster fonts

Dcl-F TSTFNTP1 PRINTER usropn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('TSTFNTB1');
  End-Pi;

  #$CMD('OVRPRTF TSTFNTP1 DEVTYPE(*AFPDS) HOLD(*YES)');

  Open TSTFNTP1;

  Write HEADER;
  Write FNT1;

  Write HEADER;
  Write FNT2;

  Write HEADER;
  Write FNT3;

  Write HEADER;
  Write CDE1;

  Write HEADER;
  Write CDE2;

  Write HEADER;
  Write CDE3;

  Write HEADER;
  Write CDE4;

  Write HEADER;
  Write CDE5;

  Write HEADER;
  Write CDE6;

  Write HEADER;
  Write CLR1;

  Close TSTFNTP1;

  #$CMD('DLTOVR TSTFNTP1');

End-Proc;
