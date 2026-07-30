**free
Dcl-Pr USRMSTC2 ExtPgm('USRMSTC2');
  usrPrf Like(APLDCT.usr);
  acgCde Like(APLDCT.acgCde);
  usrNme Like(APLDCT.usrNme);
  usroqn Like(APLDCT.usroqN);
  usroqL Like(APLDCT.usroqL);
  grpPrf Like(APLDCT.grpPrf);
  smptUsr char(30) options(*nopass);
  smtpDmn char(30) options(*nopass);
End-Pr;
