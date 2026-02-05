**free
Dcl-Pr DCTFLDD1 ExtPgm;
  pmrDctNme Like(APLDCT.DctNme) const;
  pmrFldNme Like(APLDCT.FldNme);
  pmrOption Like(APLDCT.Option);
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
