**Free
Dcl-Pr ROLAPRD1 ExtPgm;
  pmrRolAprIdn Like(APLDCT.rolAprIdn);
  pmrUsrMstIdn Like(APLDCT.usrMstIdn);
  pmrRolMstIdn Like(APLDCT.rolMstIdn);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
