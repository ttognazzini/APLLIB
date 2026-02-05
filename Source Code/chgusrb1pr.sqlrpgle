**FREE
//  Swaps a user profile from the current job from one user to another
//
//     If a user is not passed, it will set the job back to the user
//     initally signed on.
//     A password is not needed, but will be used if passed.
Dcl-Pr CHGUSRB1 extpgm;
  pmrToUser      char(10) const options(*nopass);
  pmrToPassWord  char(10) const options(*nopass);
End-Pr;
