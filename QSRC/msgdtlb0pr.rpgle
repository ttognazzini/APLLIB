**Free
// Calls the navigator program
Dcl-Pr MSGDTLB0 ExtPgm('MSGDTLB0');
  pmrMsfLib Like(APLDCT.MsfLib);
  pmrMsfNme Like(APLDCT.MsfNme);
  pmrMsgIdn Like(APLDCT.MsgIdn);
  pmrSel Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
