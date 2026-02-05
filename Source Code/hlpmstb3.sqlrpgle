**Free
Ctl-Opt Option(*SrcStmt) BndDir('APLLIB')
        DftActGrp(*No) Main(Main) ActGrp(*new);

// CRTDSPF Pre-processor work

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for Template programs
/Copy QSRC,HLPMSTB1PR
/Copy QSRC,HLPMSTB2PR
/Copy QSRC,SCRLOCB1PR

// globals for input parameters
Dcl-S sourceMember Char(10);
Dcl-S pgmNme like(APLDCT.pgmNme);
Dcl-S hlpPnlNme Char(10);

Dcl-Ds optionsDs Qualified Template;
  count int(5) pos(1);
  options char(10) dim(10) pos(3);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner,
                    CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('HLPMSTB3');
    objLibFle Char(20);
    srcLibFle Char(20);
    srcMbr Char(10);
    igcDta Char(4);
    igcExnChr Char(4);
    replace Char(4);
    rstDsp Char(4);
    enhDsp Char(4);
    genLvl Packed(6);
    flag   Packed(6);
    dfrWrt Char(4);
    Text Char(50);
    psOptions likeDs(optionsDs);
  End-Pi;
  Dcl-S objFle Char(10);
  Dcl-S objLib Char(10);
  Dcl-S srcFle Char(10);
  Dcl-S srcLib Char(10);
  Dcl-S text2 Char(52);
  Dcl-S i packed(5);
  Dcl-S optionString varchar(100);


  objLib = %subst(objLibFle:11:10);
  objFle = %subst(objLibFle:1:10);
  srcLib = %subst(srcLibFle:11:10);
  srcFle = %subst(srcLibFle:1:10);

  pgmNme = %subst(sourceMember:1:6) + 'D' + %subst(sourceMember:8:3);
  hlpPnlNme = %subst(sourceMember:1:6) + 'P' + %subst(sourceMember:8:3);

  // the options parameter is passed with a 5i field followed by the array of options,
  // we need to convert that back to a string to pass the the real CRTDSF command.
  optionString = ' ';
  If psOptions.count>0;
    For i=1 To psOptions.count;
      optionString += ' ' + %trim(psOptions.options(i));
    EndFor;
  EndIf;

  // If the source member is *FILE make it the objFle
  If srcMbr = '*FILE';
    srcMbr=objFle;
  EndIf;

  // Make sure the file exists
  If not #$ISMBR(srcLib:srcFle:srcMbr);
    #$SNDMSG('Error member '+%trim(srcLib)+'/'+%trim(srcFle)+','+
              %trim(srcMbr) + ' not found.':'*ESCAPE');
    Return;
  EndIf;

  // if text is not one of the special values, it must be in quotes
  If Text in %list('*SRCMBRTXT':'*BLANK');
    text2 = Text;
  Else;
    text2 = '''' + %trim(Text) + '''';
  EndIf;

  // If help Text is not needed, just run the regular CRTDSPF command
  If not HelpTextNeeded(srcLib:srcFle:srcMbr);
    Exec SQL Drop Alias QTEMP/INPUT;
    #$SNDMSG('Help Text not needed, CRTDSPF being ran from original source.':'*INFO');
    #$CMD('QSYS/CRTDSPF +
             FILE('+%trim(objLib)+'/'+%trim(objFle)+') +
             SRCFILE('+%trim(srcLib)+'/'+%trim(srcFle)+') +
             SRCMBR('+%trim(srcMbr)+') +
             REPLACE('+%trim(replace)+') +
             IGCDTA('+%trim(igcDta)+') +
             IGCEXNCHR('+%trim(igcExnChr)+') +
             RSTDSP('+%trim(rstDsp)+') +
             ENHDSP('+%trim(enhDsp)+') +
             FLAG('+%char(flag)+') +
             GENLVL('+%char(genLvl)+') +
             DFRWRT('+%trim(dfrWrt)+') +
             TEXT('+%trim(text2)+') +
             OPTION('+%char(optionString)+')'
             );
    Return;
  EndIf;

  // Create the help panel group
  HLPMSTB1(srcLib:srcFle:srcMbr);

  // Build the DDS in QTEMP/QSRC
  HLPMSTB2(srcLib:srcFle:srcMbr);

  // Create the display file from the QTEMP source
  #$SNDMSG('Help Text added, CRTDSPF being ran from QTEMP/QSRC.':'*INFO');
  #$CMD('QSYS/CRTDSPF +
           FILE('+%trim(objLib)+'/'+%trim(objFle)+') +
           SRCFILE(QTEMP/QSRC) +
           SRCMBR('+%trim(srcMbr)+') +
           REPLACE('+%trim(replace)+') +
           IGCDTA('+%trim(igcDta)+') +
           IGCEXNCHR('+%trim(igcExnChr)+') +
           RSTDSP('+%trim(rstDsp)+') +
           ENHDSP('+%trim(enhDsp)+') +
           FLAG('+%char(flag)+') +
           GENLVL('+%char(genLvl)+') +
           DFRWRT('+%trim(dfrWrt)+') +
           TEXT('+%trim(text2)+') +
           OPTION('+%char(optionString)+')'
           );

End-Proc;


// Check if help text is needed, must have ALTHELP(CA01) before the first record format
// and be in QSRC source file
Dcl-Proc HelpTextNeeded;
  Dcl-Pi *n Ind;
    sourceLibrary Char(10);
    sourceFile    Char(10);
    sourceMember  Char(10);
  End-Pi;
  Dcl-S sqlStm Varchar(500);

  // Data structure to read a source line into
  Dcl-Ds src Qualified;
    seq zoned(6:2);
    dat zoned(6:0);
    dta Char(80);
    type Char(1) overlay(dta:6);
    comment Char(1) overlay(dta:7);
    record Char(1) overlay(dta:17);
    name Char(10) overlay(dta:19);
    ref Char(1) overlay(dta:29);
    length Char(1) overlay(dta:32);
    hidden Char(1) overlay(dta:38);
    rowNumber Char(3) overlay(dta:39);
    colNumber Char(3) overlay(dta:42);
    function Char(36) overlay(dta:45);
  End-Ds;

  If sourceLibrary = 'QTEMP';
    Return *off;
  EndIf;

  // Create an Alias To the source member
  Exec SQL Drop Alias QTEMP/INPUT;
  sqlStm='Create or Replace Alias QTEMP/INPUT For ' +
          %trim(sourceLibrary) +'/' + %trim(sourceFile) + '("' +
          %trim(sourceMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // Loop through the Alias and look for ALTHELP(CA01) before the first record format
  Exec SQL Declare sqlCrs Cursor For Select srcSeq,srcDat,srcDta From QTEMP/INPUT;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs Into :src;
  DoW sqlState<'02';
    If src.comment<>'*' and src.type='A';
      If src.record='R';
        Leave;
      ElseIf #$UPIFY(%trim(src.function))='ALTHELP(CA01)';
        Exec SQL Close sqlCrs;
        Exec SQL Drop Alias QTEMP/INPUT;
        Return *on;
      EndIf;
    EndIf;
    Exec SQL Fetch Next From SQLCRS Into :src;
  EndDo;
  Exec SQL Close sqlCrs;
  Exec SQL Drop Alias QTEMP/INPUT;

  Return *off;

End-Proc;
