**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

//  Dictionary Field Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,MSGDTLB0PR // Always include the prototype for the current program

Dcl-S Option like(APLDCT.Option);
Dcl-S NxtScr int(5) Inz(2);
Dcl-C LASSCR const(3);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('MSGDTLB0');
    pmrMsfLib Like(APLDCT.MsfLib);
    pmrMsfNme Like(APLDCT.MsfNme);
    pmrMsgIdn Like(APLDCT.MsgIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;

  // Handle 1=Add
  If pmrOption = '1';
    #$CMD('ADDMSD MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')':1);
    Return;
  EndIf;

  // Handle 2=Change
  If pmrOption = '2';
    #$CMD('CHGMSD MSGID('+%trim(pmrMsgIdn)+') +
                  MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')':1);
    Return;
  EndIf;

  // Handle 3=Copy
  If pmrOption = '3';
    #$CMD('CPYMSD MSGID('+%trim(pmrMsgIdn)+') +
                  MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')':1);
    Return;
  EndIf;

  // Handle 4=Delete
  If pmrOption = '4';
    #$CMD('RMVMSGD MSGID('+%trim(pmrMsgIdn)+') +
                  MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')':1);
    Return;
  EndIf;

  // Handle 5=Display
  If pmrOption = '5';
    #$CMD('DSPMSGD RANGE('+%trim(pmrMsgIdn)+') +
                   MSGF('+%trim(pmrMsfLib)+'/'+%trim(pmrMsfNme)+')':1);
    Return;
  EndIf;

End-Proc;
