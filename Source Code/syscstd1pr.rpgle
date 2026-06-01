**Free
Dcl-Pr SYSCSTD1 ExtPgm('SYSCSTD1');
  pmrLibNme Like(APLDCT.LibNme);
  pmrFleNme Like(APLDCT.FleNme);
  pmrCstNme Like(APLDCT.CstNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
