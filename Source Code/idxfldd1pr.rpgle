**free
Dcl-Pr IDXFLDD1 ExtPgm('IDXFLDD1');
  pmrFleLib Like(APLDCT.fleLib) const;
  pmrFleNme Like(APLDCT.fleNme) const;
  pmrIdxLib Like(APLDCT.idxLib);
  pmrIdxNme Like(APLDCT.idxNme);
  pmrOption Like(APLDCT.Option);
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
