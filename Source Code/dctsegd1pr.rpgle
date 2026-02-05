**Free
// Data Segement List, Maintain/Inquiry/Select a field
// Parameters
//   1. Data Segment, Required, must be a variable
//   2. Option, Required, 1=Select,2=Maintenace,5=Inquiry
//   3. Keypressed, Required, Returns how the program was exited
Dcl-Pr DCTSEGD1 ExtPgm('DCTSEGD1');
  pmrDctSeg Like(APLDCT.dtaSeg);
  pmrOption Like(APLDCT.Option) Const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
