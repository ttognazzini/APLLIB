**Free
// Validate or Prompt Enumerated Value
// This validates a value, returns the correct value if only one entry mathes it.
// If more than one entry match it the prompt is dispalyed. It can be called for
// a value or the description. For example AvcRow is enumerated, 1=Active, 2=Inactive.
// 1 and 2 are values and Active and Inactive are the descriptions. For a regular prompt
// send empty variables in the value and description field, the program will return both.
// To test an existing value send either the entered value or the the entered description.
// Parameters
//   1. Dictionary Name, Required
//   2. Field Name, Required
//   3. Value, Required, must be a variable
//   4. Values Description, Required, must be a variable
//   5. Keypressed, Required, must be a variable, Returns how the program was exited
Dcl-Pr DCTVALBP ExtPgm('DCTVALBP');
  pmrDctNme Like(APLDCT.DctNme) Const;
  pmrFldNme Like(APLDCT.FldNme) Const;
  pmrEnmVal Like(APLDCT.EnmVal) Options(*nopass);
  pmrEnmDes Like(APLDCT.EnmDes) Options(*nopass);
  pmrKeyPressed Like(keyPressed) Options(*nopass);
End-Pr;
