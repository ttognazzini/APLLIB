**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Dictionary Field Prompt
// Validate or Prompt Dictionary Field Name

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDBPPR // Always include the prototype for the current program
/Copy QSRC,DCTFLDD1PR

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

// Program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDBP');
    pmrDctNme Like(APLDCT.DctNme) Options(*nopass);
    pmrFldNme Like(APLDCT.FldNme) Options(*nopass);
    pmrColTxt Like(APLDCT.ColTxt) Options(*nopass);
    pmrKeyPressed Like(keyPressed) Options(*nopass);
  End-Pi;
  Dcl-S likeColTxt Varchar(31);
  Dcl-S Count packed(9);
  Dcl-S Option like(APLDCT.Option) Inz('1');
  Dcl-S schVal like(APLDCT.schVal);

  // If a value is passed and only one option matches it, use it and leave
  If %Parms >= 2 and pmrColTxt<>'';
    likeColTxt=#$Upify(%Trim(pmrColTxt))+'%';
    Exec SQL Select Count(*) Into :Count
             From DCTFLD
             Where dctNme=:pmrDctNme and ColTxt like (:likeColTxt);
    If Count=1;
      Exec SQL Select fldNme, ColTxt
               Into  :pmrFldNme, :pmrColTxt
               From DCTFLD
               Where dctNme=:pmrDctNme and ColTxt like (:likeColTxt);
      pmrKeyPressed='';
      Return;
    EndIf;
  EndIf;

  // if no value is already returned, call the prompt program
  schVal = pmrColTxt;
  Callp DCTFLDD1(pmrDctNme:pmrFldNme:Option:pmrKeyPressed:schVal);

  // if an Id is passed, get the name to return
  If pmrFldNme<>'';
    Exec SQL Select ColTxt Into :pmrColTxt
             From DCTFLD
             Where DctNme = :pmrDctNme and fldNme=:pmrFldNme;
  EndIf;

End-Proc;
