**Free
Dcl-Pr PGMMSTB1 ExtPgm('PGMMSTB1');
  frmPgm Like(APLDCT.pgmNme);
  frmLib Like(APLDCT.frmLib);
  frmDsp Like(APLDCT.dspFle);
  toPgm  Like(APLDCT.pgmNme);
  toLib  Like(APLDCT.lib);
  toDsp  Like(APLDCT.dspFle);
  cpyFnc Char(1);
  cpyOpt Char(1);
  cpyDsp Char(1);
  cpyPgmMst Char(1) Const;
  error  Ind; // if any errors occure set this on
End-Pr;

