**Free
Dcl-Pr FLEFLDB1 ExtPgm('FLEFLDB1');
  pmrFleLib Like(APLDCT.fleLib);
  pmrFleNme Like(APLDCT.fleNme);
  pmrUpdErr char(1) options(*omit:*nopass) const;
  pmrSynTbl char(1) options(*omit:*nopass) const;
End-Pr;
