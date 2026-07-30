**Free
// CVTOSPEC - Validity checking program

Ctl-Opt dftactgrp(*no) option(*srcStmt:*nounref) BndDir('APLLIB') Main(Main);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('CVTOSPB2');
    ddsMbr char(10);
    ddsFleLib char(20);
    rpgMbr char(10);
    rpgFleLib char(20);
    p_RefFields char(4);
  End-Pi;
  Dcl-S rpgFle char(10);
  Dcl-S rpgLib char(10);
  Dcl-S ddsFle char(10);
  Dcl-S ddsLib char(10);
  Dcl-S Error Ind;

  rpgFle = %subst(rpgFleLib:1:10);
  rpgLib = %subst(rpgFleLib:11:10);
  ddsFle = %subst(ddsFleLib:1:10);
  ddsLib = %subst(ddsFleLib:11:10);
  error = *off;

  If not #$IsObj(rpgFle:'*FILE':rpgLib);
    snd-msg *diag
      %msg('CPF9898':'*LIBL/QCPFMSG':'    RPG source file ' + %trim(rpgLib) + '/' + %trim(rpgFle)  + ' not Found.')
      %target(*caller:1);
    error = *on;
  EndIf;

  If not (#$RtvMbrTyp(rpgLib:rpgFle:rpgMbr) in %list('RPGLE':'SQLRPGLE'));
    snd-msg *diag
      %msg('CPF9898':'*LIBL/QCPFMSG':'    Member ' + %trimr(rpgMbr) + ' is not type RPGLE or SQLRPGLE.')
      %target(*caller:1);
    error = *on;
  EndIf;

  If not #$IsObj(ddsFle:'*FILE':ddsLib);
    #$SndMsg('PRTF source file ' + %trim(ddsLib) + '/' + %trim(ddsFle)  + ' not Found.':'*ESCAPE');
    snd-msg *diag
      %msg('CPF9898':'*LIBL/QCPFMSG':'    PRTF source file ' + %trim(ddsLib) + '/' + %trim(ddsFle)  + ' not Found.')
      %target(*caller:1);
    error = *on;
  EndIf;

  // Todo this does not handle *LIBL or *CURLIB. Really it ineeds to pull the member desc and compare
  // The JCR command version did, but I do not have a #$ function to do the same thing yet.
  If rpgFleLib = ddsFleLib and rpgMbr = ddsMbr;
    snd-msg *diag
      %msg('CPF9898':'*LIBL/QCPFMSG':'    RPGLE file/lib/mbr cannot be same as DDS file/lib/mbr name.')
      %target(*caller:1);
    error = *on;
  EndIf;

  // If out member does not exists, create one, else change and clear
  If not error;
    If not #$ISMBR(ddsLib:ddsFle:ddsMbr);
      Monitor;
        #$Cmd('ADDPFM FILE(' + %trim(ddsLib) + '/' + %trim(ddsFle) +') +
                      MBR(' + %trim(ddsMbr) + ') +
                      SRCTYPE(PRTF) +
                      TEXT(''' + #$DBLQ(%trim(#$rtvMbrD(ddsLib:ddsFle:ddsMbr))) + ''')':2);
      On-Error;
        snd-msg *diag
          %msg('CPF9898':'*LIBL/QCPFMSG':'    Error creating PRTF member.')
          %target(*caller:1);
        error = *on;
      EndMon;
    Else;
      Monitor;
        #$CMD('CHGPFM FILE(' + %trim(ddsLib) + '/' + %trim(ddsFle) +') +
                      MBR(' + %trim(ddsMbr) + ') +
                      SRCTYPE(PRTF) +
                      TEXT(''' + #$DBLQ(%trim(#$rtvMbrD(ddsLib:ddsFle:ddsMbr))) + ''')':2);
        #$CMD('CLRPFM FILE(' + %trim(ddsLib) + '/' + %trim(ddsFle) +') +
                      MBR(' + %trim(ddsMbr) + ')':2);
      On-Error;
        snd-msg *diag
          %msg('CPF9898':'*LIBL/QCPFMSG':'    Error with PRTF member.')
          %target(*caller:1);
        error = *on;
      EndMon;
    EndIf;
  EndIf;

  If error;
    snd-msg *escape %msg('CPF0002':'*LIBL/QCPFMSG':'') %target(*caller:1);
  EndIf;

End-Proc;
