**FREE
Ctl-Opt option(*srcstmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Dictionary Segment
// Validate or Prompt Segment Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTSEGB0PR // Always include the prototype for the current program
/Copy QSRC,DCTSEGD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTSEGBP');
    pmrDtaSeg Like(APLDCT.DtaSeg) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S DtaSeg Like(APLDCT.DtaSeg);
  Dcl-S likeDtaSeg varchar(10);
  Dcl-S count packed(9);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 2 and pmrDtaSeg<>'';
    likeDtaSeg=#$UPIFY(%trim(pmrDtaSeg))+'%';
    Exec Sql Select Count(*) into :count
             from DCTSEG
             Where DtaSeg like (:likeDtaSeg);
    If count=1;
      Exec Sql Select DtaSeg
               into  :DtaSeg
               from DCTSEG
               Where DtaSeg like (:likeDtaSeg);
      pmrKeyPressed='';
      pmrDtaSeg=DtaSeg;
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  Callp(e) DCTSEGD1(pmrDtaSeg:'1':pmrKeyPressed);

End-Proc;
