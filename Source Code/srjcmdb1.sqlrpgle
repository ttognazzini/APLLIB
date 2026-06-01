**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB') Main(Main) ActGrp(*new);

// Submit Restore Journal - SRJ CPP

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// This option turns off commitment control
Exec SQL Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, datfmt = *ISO;

// procedure interface and protype for *entry plist
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('SRJCMDB1');
    obj char(20);
    objTyp char(10);
    frmDte Char(10);
    outF Char(20);
    jobNme Char(10);
  End-Pi;
  Dcl-S objNme char(10);
  Dcl-S objLib char(10);
  Dcl-S outFNme char(10);
  Dcl-S outFLib char(10);
  Dcl-S toDte Char(10);

  objNme = %subst(obj:1:10);
  objLib = %subst(obj:11:10);
  outFNme = %subst(outF:1:10);
  outFLib = %subst(outF:11:10);

  // If no file is passed, default it to the file name + RJ
  If outFNme = '';
    If #$last(objNme:2) = 'PF';
      outFNme = %trim(%subst(objNme:1:%len(objNme)-2)) + 'RJ';
    Else;
      outFNme = %trim(%subst(objNme:1:8)) + 'RJ';
    EndIf;
  EndIf;

  // If no out file library is passed, default it to the user profile
  If outFLib = '';
    outFLib = user;
  EndIf;

  // If no job name is passed, default it
  If jobNme = '';
    jobNme = 'SRJ_' + %subst(objNme:1:6);
  EndIf;

  // get from date, if less than 6 chars, assume it is a number of dayts from today
  If %len(%trim(frmDte)) < 6;
    frmDte = %char(%date() - %days(%dec(frmDte:5:0)):*mdy0);
  EndIf;
  toDte = %char(%date():*mdy0);

  // Try to add TK to the end of the library list, ignore errors
  #$CMD('ADDLIBLE TK *LAST':1);

  // Set global variables for parameters passed
  #$CMD('SBMJOB CMD(+
            EXPJRNE OBJ(' + %trim(objLib) + '/' + %trim(objNme) + ') +
                    OBJTYPE(' + %trim(objTyp) + ') +
                    FROMDATE(' + %trim(frmDte) + ') +
                    FROMTIME(000000) +
                    TODATE(' + %trim(toDte) + ') +
                    TOTIME(235959) +
                    OUTFILE(' + %trim(outFLib) + '/' + %trim(outFNme) + ')+
            ) +
            JOB(' + %trim(jobNme) + ')');

End-Proc;
