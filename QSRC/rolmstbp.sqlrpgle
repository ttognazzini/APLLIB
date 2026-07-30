**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Role Master Prompt

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,ROLMSTBPPR // Always include the prototype for the current program
/Copy QSRC,ROLMSTD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ROLMSTBP');
    pmrRolNme Like(APLDCT.RolNme) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S rolMstIdn like(APLDCT.rolMstIdn);
  Dcl-S likeDes Varchar(31);
  Dcl-S Count packed(9);
  Dcl-S Option like(APLDCT.Option) Inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a name is passed and only one option matches it, use it and leave
  If %parms >= 1 and pmrRolNme<>'';
    likeDes=#$UPIFY(%trim(pmrRolNme))+'%';
    Exec SQL Select Count(*) Into :Count
             From ROLMST
             Where upper(RolNme) like (:likeDes);
    If Count=1;
      Exec SQL Select RolNme
               Into  :pmrRolNme
               From ROLMST
               Where upper(RolNme) like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  schVal = pmrRolNme;
  ROLMSTD1(pmrRolNme:Option:pmrKeyPressed:schVal);

  // if an Id is passed, get the name to return
  If rolMstIdn<>0;
    Exec SQL Select rolNme Into :pmrRolNme
             From ROLMST
             Where rolNme = :pmrRolNme;
  EndIf;

End-Proc;
