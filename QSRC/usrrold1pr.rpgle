**Free
Dcl-Pr USRROLD1 ExtPgm;
  pmrUsrRolIdn Like(APLDCT.usrRolIdn);
  pmrUsrMstIdn Like(APLDCT.usrMstIdn);
  pmrRolMstIdn Like(APLDCT.rolMstIdn);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
