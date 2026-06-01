**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// User Master Maintenance - Update/Add SPYView Profile

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

// globals
Dcl-S usrPrf Like(APLDCT.usrPrf);

Dcl-Ds dta;
  acFNam  like(APLLIB.acFnam);
  acLNam  like(APLLIB.acLnam);
  acDept  like(APLLIB.acDept);
  acPExt  like(APLLIB.acPExt);
  acEmaiL like(APLLIB.acEmail);
End-Ds;


Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTB3');
    pmrUsrPrf Like(APLDCT.UsrPrf);
  End-Pi;

  // Move Parms to globals
  usrPrf = pmrUsrPrf;

  // Get User names, dept, email, phone extension, output q, and outq library
  Clear dta;
  Exec SQL Select acFNam, acLNam, acDept, acPExt, AcEmail Into :dta
           From ACCESSPF Where acUPrf = :usrPrf;

  // override phone extension with the main number if it is not populated
  If acPExt = 0;
    acPext = 7700;
  EndIf;

  // Try to add the RPT entry
  Exec SQL Insert Into RSUBSCR
          ( SUBSID, SNAME,  SUSER, SEADDR)
    Values( :usrPrf,Trim(#$c1st(:acFnam)) || ' ' || Trim(#$c1st(:acLNam)),:usrPrf,lower(:acEmail));
  // try to update an existing entry if the add failed
  If sqlState >= '02';
  Exec SQL update RSUBSCR
    set (SNAME, SEADDR)
    =   (Trim(#$c1st(:acFnam)) || ' ' || Trim(#$c1st(:acLNam)),lower(:acEmail))
    Where subSid = :usrPrf;
  EndIf;

End-Proc;
