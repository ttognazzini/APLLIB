**Free
Dcl-Pr SYSTRGD1 ExtPgm('SYSTRGD1');
  pmrLibNme Like(APLDCT.LibNme);
  pmrTrgPgm Like(APLDCT.trgPgm);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
