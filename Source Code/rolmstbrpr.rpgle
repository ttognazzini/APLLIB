**Free
Dcl-Pr ROLMSTBR ExtPgm;
  pmrKeyPressed like(keyPressed) options(*nopass:*omit);
  pmrRolMstBrDs like(rolMstBrDs) options(*nopass:*omit);
End-Pr;

// Report parameters
Dcl-Ds rolMstBrDs qualified;
  srtCde    like(APLDCT.srtCde) inz(1);
  rptTtl    like(APLDCT.rptTtl) inz('Role Master List');
  acvRow    like(APLDCT.acvRow) inz('1');
End-Ds;

