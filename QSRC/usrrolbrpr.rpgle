**Free
Dcl-Pr USRROLBR ExtPgm;
  pmrKeyPressed like(keyPressed) options(*nopass:*omit);
  pmrUsrRolBrDs like(usrRolBrDs) options(*nopass:*omit);
End-Pr;

// Report parameters
Dcl-Ds usrRolBrDs qualified;
  srtCde    like(APLDCT.srtCde) inz(1);
  rptTtl    like(APLDCT.rptTtl) inz('User Role List');
  usrNme    like(APLDCT.usrNme) inz('');
  rolNme    like(APLDCT.rolNme) inz('');
  acvRow    like(APLDCT.acvRow) inz('1');
End-Ds;

