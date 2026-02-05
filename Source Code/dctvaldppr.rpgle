**Free
// Dictionary value prompt
// Parameters
//   1. Dictionary Name, Required
//   2. Field Name, Required
//   3. Value, Required, must be a variable
//   4. Values Description, Required, must be a variable
//   5. Keypressed, Required, must be a variable, Returns how the program was exited
Dcl-Pr DCTVALDP ExtPgm('APLLIB/DCTVALDP');
  pmrDctNme Like(APLDCT.DctNme) Const;
  pmrFldNme Like(APLDCT.FldNme) Const;
  pmrEnmVal Like(APLDCT.EnmVal) Options(*nopass);
  pmrEnmDes Like(APLDCT.EnmDes) Options(*nopass);
  pmrKeyPressed Like(keyPressed) Options(*nopass);
End-Pr;
