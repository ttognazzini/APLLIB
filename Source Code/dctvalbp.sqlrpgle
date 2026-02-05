**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Value
// Validate or Prompt Enumerated Value

// If the option passed only returns one result return it
// Else call the prompt program
// Handles value or description

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTVALBPPR // Always include the prototype for the current program
/Copy QSRC,DCTVALDPPR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTVALBP');
    pmrDctNme Like(APLDCT.DctNme) Const;
    pmrFldNme Like(APLDCT.FldNme) Const;
    pmrEnmVal Like(APLDCT.EnmVal) Options(*nopass);
    pmrEnmDes Like(APLDCT.EnmDes) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S EnmVal Like(APLDCT.EnmVal);
  Dcl-S EnmDes Like(APLDCT.EnmDes);
  Dcl-S likeEnmVal varchar(10);
  Dcl-S likeEnmDes varchar(40);
  Dcl-S count packed(9);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 3 and pmrEnmVal<>'';
    likeEnmVal=#$UPIFY(%trim(pmrEnmVal))+'%';
    Exec SQL Select Count(*) Into :count
             From DCTVAL
             Where DctNme=Ucase(:pmrDctNme)
               and FldNme=Ucase(:pmrFldNme)
               and Ucase(EnmVal) like (:likeEnmVal);
    If count=1;
      Exec SQL Select EnmVal, EnmDes
               Into  :EnmVal,:EnmDes
               From DCTVAL
               Where DctNme=Ucase(:pmrDctNme)
                 and FldNme=Ucase(:pmrFldNme)
                 and Ucase(EnmVal) like (:likeEnmVal);
      pmrKeyPressed='';
      pmrEnmVal=EnmVal;
      pmrEnmDes=EnmDes;
      Return;
    EndIf;
  EndIf;

  // If a description is passed and only one option matches it, use it and leave
  If %parms >= 4 and pmrEnmDes<>'';
    likeEnmDes=#$UPIFY(%trim(pmrEnmDes))+'%';
    Exec SQL Select Count(*) Into :count
             From DCTVAL
             Where DctNme=Ucase(:pmrDctNme)
               and FldNme=Ucase(:pmrFldNme)
               and Ucase(EnmDes) like (:likeEnmDes);
    If count=1;
      Exec SQL Select EnmVal, EnmDes
               Into  :EnmVal,:EnmDes
               From DCTVAL
               Where DctNme=Ucase(:pmrDctNme)
                 and FldNme=Ucase(:pmrFldNme)
                 and Ucase(EnmDes) like (:likeEnmDes);
      pmrKeyPressed='';
      pmrEnmVal=EnmVal;
      pmrEnmDes=EnmDes;
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  Callp(e) DCTVALDP(pmrDctNme:pmrFldNme:pmrEnmVal:pmrEnmDes:pmrKeyPressed);

End-Proc;
