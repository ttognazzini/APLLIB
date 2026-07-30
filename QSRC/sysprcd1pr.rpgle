**Free
Dcl-Pr SYSPRCD1 ExtPgm('SYSPRCD1');
  pmrLibNme Like(APLDCT.LibNme);
  pmrPrcNme Like(APLDCT.PrcNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
