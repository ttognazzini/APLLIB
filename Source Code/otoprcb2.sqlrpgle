**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// Output options - Fix File Name

// This program removes or converts any special characters in a file name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR // prototypes for output options procedures

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOPRCB2');
    pmrOtoDs char(4096);
  End-Pi;

  otoDs = pmrOtoDs;

  ataNme = %scanrpl('/':'-':ataNme);
  ataNme = %scanrpl('\':'-':ataNme);
  ataNme = %scanrpl('*':'':ataNme);
  ataNme = %scanrpl('?':'':ataNme);
  ataNme = %scanrpl('"':'':ataNme);
  ataNme = %scanrpl('''':'':ataNme);
  ataNme = %scanrpl('>':'':ataNme);
  ataNme = %scanrpl('<':'':ataNme);
  ataNme = %scanrpl('|':'':ataNme);

  pmrOtoDs = otoDs;

End-Proc;
