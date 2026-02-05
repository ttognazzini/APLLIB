**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp('DCTFLDB9') Main(Main);

// Re-Build Dictionary From DCTFLD

Dcl-S sqlStm Varchar(5120);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR
/Copy QSRC,DCTFLDB8PR // Always include the prototype for the current program
/Copy QSRC,DCTFLDB9PR

Dcl-Ds dta Qualified;
  DctNme Like(APLDCT.DctNme);
  FldNme Like(APLDCT.FldNme);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDB8');
    DctNme Like(APLDCT.DctNme);
  End-Pi;

  If %parms() = *zeros or DctNme = *blanks;
    Return;
  EndIf;

  // delete the file first if doing a full rebuild,
  // this makes it drop any field that has been removed from DCTFLD
  sqlStm='Drop Table APLLIB/'+%trim(DctNme);
  Exec SQL Execute Immediate :sqlStm;

  Exec SQL
    Declare DCTFLD Cursor For
    Select DctNme, FldNme
    From DCTFLD
    Where DctNme = ucase(:DctNme)
      and AcvRow = '1'
    Order by FldNme;

  Exec SQL Open DCTFLD;
  DoW sqlState < '02';
    Exec SQL
      Fetch Next From DCTFLD Into :dta;
    If sqlState < '02';
      DCTFLDB9(dta.DctNme:dta.FLdNme);
    EndIf;
  EndDo;

  Exec SQL Close DCTFLD;

End-Proc;
