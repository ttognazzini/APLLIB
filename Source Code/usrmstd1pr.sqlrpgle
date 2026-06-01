**FREE
Dcl-Pr USRMSTD1 ExtPgm('USRMSTD1');
  pmrUsrPRf Like(APLDCT.UsrPrf);
  pmrOption Like(APLDCT.Option) const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal Like(APLDCT.SchVal) options(*nopass);
End-Pr;
