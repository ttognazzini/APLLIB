**Free
Dcl-Pr SYSVEWD1 ExtPgm('SYSVEWD1');
  pmrLibNme Like(APLDCT.LibNme);
  pmrFleNme Like(APLDCT.FleNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
