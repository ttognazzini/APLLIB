**Free
Dcl-Pr AUDLOGD1 ExtPgm('AUDLOGD1');
  pmrFleNme Like(APLDCT.FleNme) const;
  pmrFleLib Like(APLDCT.FleLib) const;
  pmrFldNme Like(APLDCT.FldNme) const;
  pmrRcdIdn Like(APLDCT.RcdIdn) const;
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
End-Pr;
