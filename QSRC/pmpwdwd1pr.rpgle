**Free
// Displays a prompt window
// Parameters
//   1. Question to ask
//   2. variable to return the answer in, char(1)
//   3. list of valid values for the answer, Ex: 'YN'
//   4. Prompt text for the answers, Ex: 'Y=Es, N=No'
//   5. Variable for the key pressed, could return F3 or F12 if thye did not answer the question
// Example:
//   PMPWDWD1('Are you sure?':ans:'YN':'Y=Yes, N=No':keyPressed);
//   If keyPressed='F3' or keyPressed='F12';
//      // redisplay the previous screen.
//   ElseIf ans='Y';
//     // do whatever they said yes to
//   ElseIf ans='N';
//     // don't do what you asked about
//   EndIf;
Dcl-Pr PMPWDWD1 ExtPgm('PMPWDWD1');
  pmrText Varchar(400) const;
  pmrAns Char(1);
  pmrValues Varchar(10) const;
  pmrValDes Varchar(40) const;
  pmrKeyPressed Like(keyPressed);
End-Pr;
