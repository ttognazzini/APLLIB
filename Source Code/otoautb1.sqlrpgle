**Free
Ctl-Opt Dftactgrp(*No) Actgrp(*Caller) Main(Main) Option(*SrcStmt)  BndDir('APLLIB');

// Output Options - Preform auto prompt if system is setup to do so

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR // prototypes for output options procedures

// Default sql options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOAUTB1');
    oto likeds(otoDs);
    pass char(1);
  End-Pi;
  Clear pass;

  // Get System options
  in OTODFT;

  // Display prompt screen it system says to
  If sysAutOpt = 'Y';
    OTOPMTD1(oto:keyPressed);
    If keyPressed <> 'ENTER';
      pass = 'L';
    EndIf;
  EndIf;

End-Proc;
