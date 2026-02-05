**Free
// Calls the navigator program
Dcl-Pr MSGMSTB0 ExtPgm('MSGMSTB0');
  pmrMsfLib Like(APLDCT.MsfLib);
  pmrMsfNme Like(APLDCT.MsfNme);
  pmrSel Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
