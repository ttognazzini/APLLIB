**Free
Dcl-Pr ROLMSTD1 ExtPgm;
  pmrRolNme Like(APLDCT.RolNme) options(*nopass);
  pmrOption Like(APLDCT.Option) Const options(*nopass);
  pmrKeyPressed Like(keyPressed) options(*nopass);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
