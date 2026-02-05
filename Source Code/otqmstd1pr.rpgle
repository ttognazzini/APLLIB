**Free
// prototype for OTQMSTd1

Dcl-Pr OTQMSTD1 ExtPgm('OTQMSTD1');
  pmrOtqNme Like(APLDCT.otqNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
