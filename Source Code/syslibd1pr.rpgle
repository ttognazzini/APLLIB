**Free
Dcl-Pr SYSLIBD1 ExtPgm('SYSLIBD1');
  pmrLibNme Like(APLDCT.LibNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
