**FREE
//  Swaps a user profile from the current job from one user to another
//
//     If a user is not passed, it will set the job back to the user
//     initally signed on.
//     A password is not needed, but will be used if passed.

Ctl-Opt option(*srcstmt) DftActGrp(*NO) Main(Main);

Dcl-S Handle char(12);
Dcl-S RC int(10);

//  Get Profile Handle API
Dcl-Pr GetProfile extpgm('QSYGETPH');
  UserID char(10)   const; // userid to retrieve a profile handle for
  Password char(10) const; // password of the user-id above
  Handle    char(12);      // the profile handle that's returned
  ErrorCode char(32766) options(*varsize: *nopass); // API error code, used to return any errors.
End-Pr;

//  Set User Profile API:
Dcl-Pr SetProfile extpgm('QWTSETP');
  Handle    char(12) const; // User Profile handle (returned by QSYGETPH API)
  ErrorCode char(32766) options(*varsize: *nopass); // standard API error code structure
End-Pr;

Dcl-Ds ErrDs;
  BytesPrv int(10) inz(256) pos(1);
  BytesAvl int(10) inz(0) pos(5);
  ErrMsgID char(7) pos(9);
  Reserved char(1) pos(16);
  ErrMsgDta char(240) pos(17);
End-Ds;



Dcl-Ds sds PSDS Qualified;
  Usr    char(10)   Pos(254);
End-Ds;

Dcl-S ToUser char(10);
Dcl-S ToPassWord   char(10) Inz('*NOPWDCHK');

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('CHGUSRB1');
    pmrToUser      char(10);
    pmrToPassWord  char(10);
  End-Pi;

  If %parms = *zeros or (%parms > 0 and %addr(pmrToUser) <> *null and pmrToUser = '');
    ToUser = sds.Usr;
  ElseIf %parms > 0 and %addr(pmrToUser) <> *null;
    ToUser = pmrToUser;
  ElseIf %parms >= 1;
    ToUser = 'ZWINCHTAG'; // *Change change this to a user with NFS access
  EndIf;

  If %parms >= 2 and pmrToPassWord > '';
    ToPassWord = pmrToPassWord;
  EndIf;

  // Retrieve the User Profile Handle
  RC = RtvProfile(ToUser:ToPassWord);
  If  RC <> 0;
    // Now Set the Job Profile to a NEW User Profile
    RC = SetUProf(Handle);
  EndIf;

End-Proc;


//  Get User Profile Handle SubProcedure
Dcl-Proc RtvProfile;
  Dcl-Pi RtvProfile int(10);
    userid char(10) value;
    password char(10) value;
  End-Pi;

  userid = %upper(userid);
  password = %upper(password);

  callp     GetProfile(userid: password: Handle: ErrDs);
  If  BytesAvl > 0;
    Return 0;
  Else;
    Return 1;
  EndIf;

End-Proc;


// Set User Profile To New User Profile SubProcedure
Dcl-Proc SetUProf;
  Dcl-Pi SetUProf int(10);
    HandleIn char(12) value;
  End-Pi;

  Callp SetProfile(HandleIn: ErrDs);
  If BytesAvl > 0;
    Return 0;
  Else;
    Return 1;
  EndIf;

End-Proc;
