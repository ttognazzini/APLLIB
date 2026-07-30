**FREE
Ctl-Opt option(*srcstmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// User Master Maintenance - Auto Prompt
// Validate or Prompt User Profile, Initials and/or Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTB0PR // Always include the prototype for the current program
/Copy QSRC,USRMSTD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTBP');
    pmrAcNo Like(APLLIB.ACNO) Options(*nopass);
    pmrSchVal like(APLLIB.SchVal) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S likeSchVal varchar(61);
  Dcl-S count packed(9);

  // If a value and an account numberare passed in and they match, use it and leave
  // this prevetn an infinite loop for user with the same name.
  If %parms >= 2 and pmrSchVal<>'' and pmrAcNo <> 0;
    likeSchVal='%' + #$UPIFY(%trim(pmrSchVal))+'%';
    Exec Sql Select Count(*) into :count
             from ACCESSPF
             Where (trim(acFNam) concat ' ' concat trim(acLNam)) like (:likeSchVal)
                or acUPrf like (:likeSchVal)
                or acInit like (:likeSchVal)
               and acNo = :pmrAcNo;
    If count=1;
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 2 and pmrSchVal<>'';
    likeSchVal='%' + #$UPIFY(%trim(pmrSchVal))+'%';
    Exec Sql Select Count(*) into :count
             from ACCESSPF
             Where (trim(acFNam) concat ' ' concat trim(acLNam)) like (:likeSchVal)
                or acUPrf like (:likeSchVal)
                or acInit like (:likeSchVal);
    If count=1;
      Exec Sql Select acNo into :pmrAcNo
               from ACCESSPF
             Where (trim(acFNam) concat ' ' concat trim(acLNam)) like (:likeSchVal)
                or acUPrf like (:likeSchVal)
                or acInit like (:likeSchVal);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // If a value is passed as 3 characters and it matches initials exactly auto select that user
  If %parms >= 2 and pmrSchVal<>'' and %len(%trim(pmrSchVal)) = 3;
    Exec Sql Select Count(*) into :count
             from ACCESSPF
             Where acInit = upper(:pmrSchVal);
    If count=1;
      Exec Sql Select acNo into :pmrAcNo
               from ACCESSPF
               Where acInit = upper(:pmrSchVal);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  USRMSTD1(pmrAcNo:'1':pmrKeyPressed:pmrSchVal);

End-Proc;
