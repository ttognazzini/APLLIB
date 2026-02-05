**FREE
Ctl-Opt Dftactgrp(*No) Actgrp(*Caller) Option(*SrcStmt:*NoDebugIO) Main(Main);

// Create XML Attribute File

/copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default sql options
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTOPRCB1');
    pmrPath char(266);
  End-Pi;
  Dcl-S path varchar(265);
  Dcl-S data         Char(266);

  path = %trim(%subst(pmrPath:1:265));

  // Open file to create it, then close it an open it in write mode
  filedesc = open( %addr( path ) : o_creat + o_wronly + o_trunc + o_codepage : s_irwxu + s_iroth : asciicodepage );
  returnint = close( filedesc );
  filedesc = open( %addr( path ) : o_textdata + o_rdwr );

  // add header line
  data = '<DOCSTAR>' + EOR;
  byteswrt = write(filedesc : %addr(data) : %len(%trimr(data)));

  // add year
  data = '   <year>' + %subst(%char(%date():*iso):1:4) + '</year>';
  byteswrt = write(filedesc : %addr(data) : %len(%trimr(data)));

  // End header
  data = '</DOCSTAR>' + EOR;
  byteswrt = write(filedesc : %addr(data) : %len(%trimr(data)));

  // Close file
  returnint = close(filedesc);

End-Proc;
