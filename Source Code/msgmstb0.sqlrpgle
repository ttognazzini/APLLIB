**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB/APLLIB') Main(Main);

// Message Master Navigator

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,MSGMSTB0PR // Always include the prototype for the current program
/Copy QSRC,MSGDTLD1PR


Dcl-S Option like(APLDCT.Option);
Dcl-S MsgIdn Like(APLDCT.MsgIdn);
Dcl-S pmOption like(APLDCT.Option);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;
// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('MSGMSTB0');
    pmrMsfLib Like(APLDCT.MsfLib);
    pmrMsfNme Like(APLDCT.MsfNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  Option = pmrOption;

  // this program differs form a noirmal dirver becasuse it uses IBM commands to
  // process most functions, all options are handled one at a time, there is no
  // screen progression

  // 1=Add
  If Option = '1';
    #$CMD('CRTMSGF');
    Return;
  EndIf;

  // 2=Update
  If Option = '2';
    #$CMD('?CHGMSGF ?*MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')');
    Return;
  EndIf;

  // 5=View
  If Option = '5';
    pmOption='5';
    CallP MSGDTLD1(pmrMsfLib:pmrMsfNme:MsgIdn:pmOption:keyPressed);
    Return;
  EndIf;

  // 6=Messages
  If Option = '6';
    pmOption='2';
    CallP MSGDTLD1(pmrMsfLib:pmrMsfNme:MsgIdn:pmOption:keyPressed);
    Return;
  EndIf;

End-Proc;
