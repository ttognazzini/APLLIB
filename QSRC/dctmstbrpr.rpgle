**Free
Dcl-Pr DCTMSTBR ExtPgm;
  pmrKeyPressed like(keyPressed) options(*nopass:*omit);
  pmrDctMstBrDs like(dctMstBrDs) options(*nopass:*omit);
End-Pr;

// Report parameters
Dcl-Ds dctMstBrDs qualified;
  srtCde    like(APLDCT.srtCde) inz(1);
  rptTtl    like(APLDCT.rptTtl) inz('Dictionary Master List');
  acvRow    like(APLDCT.acvRow) inz('1');
End-Ds;

