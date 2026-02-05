**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(main);

// Display Help text for a HLPMST record

// This program creates a panel group in QTEMP and displays it using IBM's PNL display API

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Dcl-S des like(APLDCT.des);
Dcl-S sqlStm Varchar(500);
Dcl-S dctNme like(APLDCT.dctNme);
Dcl-S fldNme like(APLDCT.fldNme);
Dcl-S tpFldNme like(APLDCT.fldNme);
Dcl-S dspFle like(APLDCT.dspFle);
Dcl-S val    like(APLDCT.val);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc main;
  Dcl-Pi *n ExtPgm('HLPMSTB4');
    pmrDctNme Like(APLDCT.dctNme);
    pmrFldNme Like(APLDCT.fldNme);
    pmrDspFle Like(APLDCT.dspFle);
    pmrVal    Like(APLDCT.val);
  End-Pi;

  // Move input parms to globals
  dctNme = pmrDctNme;
  fldNme = pmrFldNme;
  dspFle = pmrDspFle;
  val = pmrVal;

  // Make sure the HLPMST record exists
  Exec SQL Select '1' Into :found From HLPMST
    Where (dctNme,fldNme,dspfle,val) = (:dctNme,:fldNme,:dspFle,:val);
  If not found;
    #$DSPWIN('Error member HLPMST record not found.');
    Return;
  EndIf;

  // Create source file in QTEMP
  #$CMD('CRTSRCPF QTEMP/QSRC':1);

  // create the source member
  #$CMD('RMVM QTEMP/QSRC HLPMSTP4':1);
  #$CMD('ADDPFM FILE(QTEMP/QSRC) MBR(HLPMSTP4)':1);

  // Make the source type PNLGRP and make the text the program name
  #$CMD('CHGPFM FILE(QTEMP/QSRC) +
                MBR(HLPMSTP4) +
                SRCTYPE(PNLGRP) +
                Text(''Temp PNLGRP For HLPMSTB4'')':1);

  // Create an alias to the source member
  Exec SQL Drop Alias QTEMP/TMP318ALS;
  sqlStm='Create or Replace Alias QTEMP/TMP318ALS For +
        QTEMP/QSRC("HLPMSTP4")';
  Exec SQL Execute Immediate :sqlStm;

  // clear the source member if it already exists
  Exec SQL Delete From QTEMP/TMP318ALS;

  // Translate some characters that are invalid in help group names
  tpFldNme = %xlate('#':'_':fldNme);
  tpFldNme = %xlate('@':'_':tpFldNme);
  tpFldNme = %xlate('$':'/':tpFldNme);

  // if the passed field is blank, make it header
  If tpFldNme = '';
    tpFldNme = 'HEADER';
  EndIf;

  // get field description
  des = '';
  Exec SQL Select des Into :des From HLPMST
    Where (dctNme,fldNme,dspFle,val) = (:dctNme,:fldNme,:dspFle,:val)
    Fetch First Row Only;
  If des = ''; // if no name found, generate a fake one
    des = 'Error name not found (' + %trim(fldNme)+')';
  EndIf;

  // Start the panel group
  writeLine(':PNLGRP.');

  writeLine('.*---------------------------------------------------------------------');
  writeLine(':HELP   NAME='''+%trim(tpFldNme) + '''.'+%trim(des));

  // If the field is FNCKEYS or OPTIONS, add a paragraph starter, this is needed
  // becasue these fields normally are in lists and the paragraph start is not included
  If fldNme in %list('FNCKEYS':'OPTIONS');
    writeLine(':P.');
  EndIf;

  writeHlpTxt(dctNme:fldNme:dspFle:val);

  writeLine(':EHELP.');

  // End the panel group
  writeLine('.*---------------------------------------------------------------------');
  writeLine(':EPNLGRP.');

  Monitor;
    // Create the panel group
    #$CMD('CRTPNLGRP +
             PNLGRP(QTEMP/HLPMSTP4) +
             SRCFILE(QTEMP/QSRC) +
             SRCMBR(HLPMSTP4) +
             REPLACE(*YES)':2);
    // delete the splf from the CRTPNLGRP
    #$CMD('DLTSPLF FILE(HLPMSTP4) SPLNBR(*LAST)':1);
  On-Error;
    #$DSPWIN('An error occured creating the panel group. View the compilation listing +
              to resolve the issue.');
  EndMon;


  // Display the panel group
  #$CMD('DSPPNLGRP HELP((QTEMP/HLPMSTP4 '+%trim(tpFldNme)+'))');

End-Proc;


// write help text from HLPDTL into the output member for the passed key fields
Dcl-Proc writeHlpTxt;
  Dcl-Pi *n;
    pmDctNme like(APLDCT.dctNme) const;
    pmFldNme like(APLDCT.fldNme) const;
    pmDspFle like(APLDCT.dspFle) const;
    pmVal    like(APLDCT.val) const;
  End-Pi;
  Dcl-S hlpTxt like(APLDCT.hlpTxt);

  Exec SQL Declare hlpCrs Cursor For
    Select HlpTxt
    From HLPDTL
    Where (dctNme,fldNme,dspFle,val) = (:pmDctNme,:pmFldNme,:pmDspFle,:pmVal)
      and AcvRow = '1'
    Order by seqNbr;
  Exec SQL Open hlpCrs;
  Exec SQL Fetch Next From hlpCrs Into :hlpTxt;
  DoW sqlState < '02';
    writeLine(hlpTxt);
    Exec SQL Fetch Next From hlpCrs Into :hlpTxt;
  EndDo;
  Exec SQL Close hlpCrs;

End-Proc;


// write one line to the source member
Dcl-Proc writeLine;
  Dcl-Pi *n;
    data Varchar(250) const;
  End-Pi;
  Dcl-S srcSeq zoned(6:2);

  // add the string into the source file
  srcSeq+=1;
  Exec SQL Insert Into QTEMP/TMP318ALS
                 (srcSeq,srcDta)
           values(:srcSeq,:data);

End-Proc;
