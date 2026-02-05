**free
Dcl-Pr FLEIDXD1 ExtPgm('FLEIDXD1');
  pmr1FleLib Like(APLDCT.fleLib) const;
  pmr1FleNme Like(APLDCT.fleNme) const;
  pmrFldNme Like(APLDCT.IdxLib);
  pmrFldNme Like(APLDCT.IdxNme);
  pmrOption Like(Option);
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
