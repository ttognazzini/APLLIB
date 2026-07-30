**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// User Master Maintenance - Update/Add RPT Profile

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
  Dcl-Pi *n ExtPgm('USRMSTB2');
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
  Exec SQL Insert Into QUSRIJS/QAIJSRCP
          ( RCPDAT, RCPTIM, RCPJOB,  RCPUSR, RCPNBR, RCPNM,
            RCPTXT,
            RCPCMP, RCPDIV, RCPLOC,  RCPDPT, RCPMGR,
            RCPPHO, RCPOQ , RCPOQL,  RCPSUN, RCPMON, RCPTUE,
            RCPWED, RCPTHU, RCPFRI,  RCPSAT, RCPESC, RCPBNDL,
            RCPONS, RCPAVS, RCPOPT )
    Values( dec(VARCHAR_FORMAT(CURRENT TIMESTAMP, 'YYMMDD'),6,0),dec(current time), :psJob, :user,:psdsJobNbr,:usrPrf,
            'Email for ' || Trim(#$c1st(:acFnam)) || ' ' || Trim(#$c1st(:acLNam)) || ' - ' || :acDept,
            '*NONE','*NONE','*NONE','*NONE','*NONE',
            '918 392-' Concat digits(:acPExt),:usrPrf,'QGPL','X','X','X',
            'X','X','X','X','*NONE','*NO',
            '*NONE','*NONE','*YES');
  // try to update an existing entry if the add failed
  If sqlState >= '02';
  Exec SQL Update QUSRIJS/QAIJSRCP
    Set ( RCPTXT,
          RCPPHO, RCPOQ , RCPOQL)
    =   ('Email for ' || Trim(#$c1st(:acFnam)) || ' ' || Trim(#$c1st(:acLNam)) || ' - ' || :acDept,
         '918 392-' Concat digits(:acPExt),:usrPrf,'QGPL')
    Where RCPNM = :usrPrf;

  EndIf;

End-Proc;
