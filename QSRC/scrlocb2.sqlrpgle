**Free
Ctl-Opt Option(*SrcStmt) Actgrp(*new) DftActGrp(*No) BndDir('APLLIB') Main(Main);

// Update SCRLOC File for a DSPF Source Member
// Also creates the XXXXXXDX_Q member for the screen


Dcl-Ds SCRLOC extname('SCRLOC') Qualified Template End-Ds;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,HLPMSTB1PR // build help panel group
/Copy QSRC,HLPMSTB2PR // build temp DSPF DDS in QTEMP with help stuff
/Copy QSRC,SCRLOCB1PR // Update SCRLOC file

// globals for input parameters
Dcl-S srcLib char(10);
Dcl-S srcFle char(10);
Dcl-S srcMbr char(10);

Dcl-S pnlMbr varchar(10);

Dcl-S sqlStm Varchar(500);



Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n extPgm('SCRLOCB2');
    pmrSrcLib Char(10) const;
    pmrSrcFle    Char(10) const;
    pmrSrcMbr  Char(10) const;
  End-Pi;
  srcLib = pmrSrcLib;
  srcFle = pmrSrcFle;
  srcMbr = pmrSrcMbr;

  // Make sure the file exists
  If not #$ISMBR(srcLib:srcFle:srcMbr);
    #$SNDMSG('Error member '+%trim(srcLib)+'/'+%trim(srcFle)+','+
              %trim(srcMbr) + ' not found, SCRLOC not updated.':'*INFO');
  EndIf;

  // If help Text is not needed, just skip the rest
  If not HelpTextNeeded(srcLib:srcFle:srcMbr);
    #$SNDMSG('Help Text not needed, must have ALTHELP(CA01) befoer the first record.':'*INFO');
    Return;
  EndIf;

  pnlMbr = %trim(%subst(srcMbr:1:6) + 'P' + %subst(srcMbr:8:3));

  // Create the help panel group
  HLPMSTB1(srcLib:srcFle:srcMbr);

  // Build the DDS in QTEMP/QSRC
  HLPMSTB2(srcLib:srcFle:srcMbr);

  // Copy the QTEMP DDS over the exiting DDS, make a back up in QTEMP first
  #$CMD('RMVM FILE(QTEMP/'+%trim(srcFle)+') MBR('+%trim(srcMbr)+'SV)':1);
  #$CMD('CPYSRCF FROMFILE('+%trim(srcLib)+'/'+%trim(srcFle)+') +
                 TOFILE(QTEMP/QSRC) +
                 FROMMBR('+%trim(srcMbr)+') +
                 TOMBR('+%trim(srcMbr)+'SV)');
  #$CMD('RMVM FILE('+%trim(srcLib)+'/'+%trim(srcFle)+') MBR('+%trim(srcMbr)+')');
  #$CMD('CPYSRCF FROMFILE(QTEMP/QSRC) +
                 TOFILE('+%trim(srcLib)+'/'+%trim(srcFle)+') +
                 FROMMBR('+%trim(srcMbr)+') +
                 TOMBR('+%trim(srcMbr)+')');
  #$CMD('RMVM FILE(QTEMP/QSRC) MBR('+%trim(pnlMbr)+'SV)':1);
  #$CMD('CPYSRCF FROMFILE('+%trim(srcLib)+'/'+%trim(srcFle)+') +
                 TOFILE(QTEMP/QSRC) +
                 FROMMBR('+%trim(pnlMbr)+') +
                 TOMBR('+%trim(pnlMbr)+'SV)':1);
  #$CMD('RMVM FILE('+%trim(srcLib)+'/'+%trim(srcFle)+') MBR('+%trim(pnlMbr)+')':1);
  #$CMD('CPYSRCF FROMFILE(QTEMP/QSRC) +
                 TOFILE('+%trim(srcLib)+'/'+%trim(srcFle)+') +
                 FROMMBR('+%trim(pnlMbr)+') +
                 TOMBR('+%trim(pnlMbr)+')');

  // Create the display file from the QTEMP source
  #$SNDMSG('Help Text added, CRTDSPF being ran from QTEMP/QSRC.':'*INFO');

End-Proc;




// Check if help text is needed, must have ALTHELP(CA01) before the first record format
// and be in QSRC source file
Dcl-Proc HelpTextNeeded;
  Dcl-Pi *n Ind;
    srcLib Char(10);
    srcFle    Char(10);
    srcMbr  Char(10);
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

  If srcLib = 'QTEMP';
    Return *off;
  EndIf;

  // Create an Alias To the source member
  Exec SQL Drop Alias QTEMP/INPUT;
  sqlStm='Create or Replace Alias QTEMP/INPUT For ' +
          %trim(srcLib) +'/' + %trim(srcFle) + '("' +
          %trim(srcMbr) + '")';
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
