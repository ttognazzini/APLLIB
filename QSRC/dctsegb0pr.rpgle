**free
// Data Segment Maintenance/Inquiry
// Parameters
//   1. Segment Name, Required, must be a variable
//   2. Option, Required, 1=Add,2=Update,5=Inquiry...
//   3. Keypressed, Required, Returns how the program was exited
Dcl-Pr DCTSEGB0 ExtPgm('DCTSEGB0');
  pmrDtaSeg Like(APLDCT.DtaSeg);
  pmrSel Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
