**free
// Enumerated Value List, Selection/Maintenance/Inquiry
// Parameters
//   1. Dictionary Name, Required
//   2. Field Name, Required
//   3. Value, must be a variable
//   4. Option, 1=Selection,2=Maintenance, 5=Inquiry
//   5. Keypressed, Returns how the program was exited
Dcl-Pr DCTVALD1 ExtPgm('DCTVALD1');
  pmrDctNme Like(APLDCT.DctNme) Const;
  pmrFldNme Like(APLDCT.FldNme) Const;
  pmrEnmVal Like(APLDCT.EnmVal) Options(*nopass);
  pmrOption Like(APLDCT.Option) Const Options(*nopass);
  pmrKeyPressed Like(keyPressed) Options(*nopass);
  pmrEnmDes Like(APLDCT.EnmDes) Options(*nopass);
End-Pr;
