**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Master Prompt
// Validate or Prompt Dictionary Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTMSTBPPR // Always include the prototype for the current program
/Copy QSRC,DCTMSTD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTMSTBP');
    pmrDctNme Like(APLDCT.DctNme) Options(*nopass);
    pmrDes Like(APLDCT.Des) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S dctMstIdn like(APLDCT.dctMstIdn);
  Dcl-S likeDes Varchar(31);
  Dcl-S Count packed(9);
  Dcl-S Option like(APLDCT.Option) Inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 2 and pmrDes<>'';
    likeDes=#$UPIFY(%trim(pmrDes))+'%';
    Exec SQL Select Count(*) Into :Count
             From DCTMST
             Where Des like (:likeDes);
    If Count=1;
      Exec SQL Select DctNme, Des
               Into  :pmrDctNme, :pmrDes
               From DCTMST
               Where Des like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // If a name is passed and only one option matches it, use it and leave
  If %parms >= 1 and pmrDctNme<>'';
    likeDes=#$UPIFY(%trim(pmrDctNme))+'%';
    Exec SQL Select Count(*) Into :Count
             From DCTMST
             Where DctNme like (:likeDes);
    If Count=1;
      Exec SQL Select DctNme, Des
               Into  :pmrDctNme, :pmrDes
               From DCTMST
               Where DctNme like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  schVal = pmrDes;
  Callp DCTMSTD1(pmrDctNme:Option:pmrKeyPressed:schVal);

  // if an Id is passed, get the name to return
  If dctMstIdn<>0;
    Exec SQL Select dctNme,Des Into :pmrDctNme,:pmrDes
             From DCTMST
             Where dctNme = :pmrDctNme;
  EndIf;

End-Proc;
