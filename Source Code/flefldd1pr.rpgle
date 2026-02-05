**free
Dcl-Pr FLEFLDD1 ExtPgm('FLEFLDD1');
  pmrFleLib Like(APLDCT.fleLib) const;
  pmrFleNme Like(APLDCT.fleNme) const;
  pmrFldNme Like(APLDCT.FldNme);
  pmrOption Like(APLDCT.Option);
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
