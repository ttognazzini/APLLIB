**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Output Queue Master Prompt
// Validate or Prompt Output Queue Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTQMSTBPPR // Always include the prototype for the current program
/Copy QSRC,OTQMSTD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTQMSTBP');
    pmrOtqNme Like(APLDCT.OtqNme) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S otqMstIdn like(APLDCT.otqMstIdn);
  Dcl-S likeDes Varchar(31);
  Dcl-S Count packed(9);
  Dcl-S Option like(APLDCT.Option) Inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a name is passed and only one option matches it, use it and leave
  If %parms >= 1 and pmrotqNme<>'';
    likeDes=#$UPIFY(%Trim(pmrotqNme))+'%';
    Exec SQL Select Count(*) Into :Count
             From OTQMST
             Where otqNme like (:likeDes);
    If Count=1;
      Exec SQL Select otqNme
               Into  :pmrOtqNme
               From OTQMST
               Where otqNme like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  schVal = ' ';
  Callp OTQMSTD1(pmrOtqNme:Option:pmrKeyPressed:schVal);

  // if an Id is passed, get the name to return
  If OTQMSTIdn<>0;
    Exec SQL Select otqNme Into :pmrOtqNme
             From OTQMST
             Where otqMstIdn = :otqMstIdn;
  EndIf;

End-Proc;
