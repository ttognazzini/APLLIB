**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Application Library Master Prompt
// Validate or Prompt Library Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,APLLIBBPPR // Always include the prototype for the current program
/Copy QSRC,APLLIBD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('APLLIBBP');
    pmrLibNme Like(APLDCT.LibNme) Options(*nopass);
    pmrDes Like(APLDCT.Des) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S aplLibIdn like(APLDCT.aplLibIdn);
  Dcl-S likeDes Varchar(31);
  Dcl-S Count packed(9);
  Dcl-S Option like(APLDCT.Option) Inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 2 and pmrDes<>'';
    likeDes=#$UPIFY(%trim(pmrDes))+'%';
    Exec SQL Select Count(*) Into :Count
             From APLLIB
             Where libDes like (:likeDes);
    If Count=1;
      Exec SQL Select LibNme, libDes
               Into  :pmrLibNme, :pmrDes
               From APLLIB
               Where libDes like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // If a name is passed and only one option matches it, use it and leave
  If %parms >= 1 and pmrLibNme<>'';
    likeDes=#$UPIFY(%trim(pmrLibNme))+'%';
    Exec SQL Select Count(*) Into :Count
             From APLLIB
             Where LibNme like (:likeDes);
    If Count=1;
      Exec SQL Select LibNme, libDes
               Into  :pmrLibNme, :pmrDes
               From APLLIB
               Where LibNme like (:likeDes);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  schVal = pmrDes;
  Callp APLLIBD1(pmrLibNme:Option:pmrKeyPressed:schVal);

  // if an Id is passed, get the name to return
  If pmrLibNme <> '';
    Exec SQL Select libNme, libDes Into :pmrLibNme,:pmrDes
             From APLLIB
             Where libNme = :pmrLibNme;
  EndIf;

End-Proc;
