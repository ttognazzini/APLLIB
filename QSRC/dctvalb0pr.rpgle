**Free
// Enumerated Value Maintenance/Inquiry
// Parameters
//   1. Segment Name, Required, must be a variable
//   2. Option, Required, 1=Add,2=Update,5=Inquiry...
//   3. Keypressed, Required, Returns how the program was exited
Dcl-Pr DCTVALB0 ExtPgm('DCTVALB0');
  pmrDctNme Like(APLDCT.DctNme);
  pmrFldNme Like(APLDCT.FldNme);
  pmrEnmVal Like(APLDCT.EnmVal);
  pmrSel Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
