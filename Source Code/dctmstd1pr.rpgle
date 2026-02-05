**Free
dcl-pr DCTMSTD1 ExtPgm;
  pmrDctNem Like(APLDCT.DctNme);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
  pmrSchVal like(APLDCT.schVal) options(*nopass);
end-pr;
