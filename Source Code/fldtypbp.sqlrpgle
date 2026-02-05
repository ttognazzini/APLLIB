**FREE
Ctl-Opt option(*srcstmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(Main);

// Field Type Prompt

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLDTYPBPPR // Always include the prototype for the current program
/Copy QSRC,FLDTYPD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLDTYPBP');
    pmrFldTyp Like(APLDCT.fldTyp) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S likeFldTyp varchar(31);
  Dcl-S count packed(9);
  Dcl-S Option like(APLDCT.Option) inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a value is passed and only one option matches it, use it and leave
  If %parms >= 1 and pmrFldTyp<>'';
    // if the passed name is an exact match use if
    Exec Sql Select Count(*) into :count
             from FLDTYP
             Where fldTyp = uCase(:pmrFldTyp);
    If count=1;
      Exec Sql Select fldTyp
               into  :pmrFldTyp
               from FLDTYP
               Where fldTyp = uCase(:pmrFldTyp);
      pmrKeyPressed='';
      Return;
    EndIf;

    likeFldTyp=#$UPIFY(%trim(pmrFldTyp))+'%';
    Exec Sql Select Count(*) into :count
             from FLDTYP
             Where FldTyp like (:likeFldTyp);
    If count=1;
      Exec Sql Select fldTyp
               into  :pmrFldTyp
               from FLDTYP
               Where FldTyp like (:likeFldTyp);
      pmrKeyPressed='';
      Return;
    EndIf;


  EndIf;

  // if no value is already returned, call the prompt program
  schVal = pmrFldTyp;
  Callp FLDTYPD1(pmrFldTyp:Option:pmrKeyPressed:schVal);

End-Proc;
