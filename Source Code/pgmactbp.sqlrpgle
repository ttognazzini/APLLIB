**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Program Actions
// Validate or Prompt Program Actions

// If the option passed only returns one result return it will return it
// Else call the prompt program

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,PGMACTBPPR // Always include the prototype for the current program
/Copy QSRC,PGMACTDPPR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PGMACTBP');
    pmrPgmNme Like(APLDCT.PgmNme);
    pmrActCde Like(APLDCT.actCde) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S actCde Like(APLDCT.actCde);
  Dcl-S likeActCde varchar(3);
  Dcl-S count packed(9);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 2 and pmrActCde<>'';
    likeActCde=%upper(%trim(pmrActCde))+'%';
    Exec SQL Select Count(*) Into :count
             From PGMACT
             Where pgmNme=Upper(:pmrPgmNme)
               and Upper(actCde) like (:likeActCde);
    If count=1;
      Exec SQL Select ActCde Into :actCde
               From PGMACT
             Where pgmNme=Upper(:pmrPgmNme)
               and Upper(actCde) like (:likeActCde);
      pmrKeyPressed='';
      pmrActCde=actCde;
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  Callp(e) PGMACTDP(pmrPgmNme:pmrActCde:pmrKeyPressed);

End-Proc;
