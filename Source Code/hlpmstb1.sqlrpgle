**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') Main(main);

// Create Help Panel Group for a Program

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Dcl-S pgmNme like(APLDCT.pgmNme);
Dcl-S srcLib like(APLDCT.lib);
Dcl-S srcFle like(APLDCT.fle);
Dcl-S srcMbr like(APLDCT.mbr);
Dcl-S des    like(APLDCT.des);
Dcl-S sqlStm Varchar(500);
Dcl-S dspFle like(APLDCT.dspFle);

Dcl-Ds fldDta Qualified;
  fldNme like(APLDCT.fldNme);
  refFld like(APLDCT.refFld);
  refFle like(APLDCT.refFle);
  fldTyp like(APLDCT.fldTyp);
  fldLen like(APLDCT.fldLen);
  fldScl like(APLDCT.fldScl);
  fldRow like(APLDCT.fldRow);
  fldCol like(APLDCT.fldCol);
  extTyp like(APLDCT.extTyp);
  rcdFmtTyp like(APLDCT.rcdFmtTyp);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc main;
  Dcl-Pi *n ExtPgm('HLPMSTB1');
    pmrSourceLibrary Char(10) Options(*nopass);
    pmrSourceFile Char(10) Options(*nopass);
    pmrSourceMember Char(10) Options(*nopass);
  End-Pi;

  // Set defaults for testing if data not passed
  If %parms() >=1;
    srcLib = pmrSourceLibrary;
    srcFle = pmrSourceFile;
    dspFle = pmrSourceMember;
  Else;
    srcLib = 'TOGLIB';
    srcFle = 'QSRC';
    dspFle = 'INVINQF2';
  EndIf;

  // Make sure the input source file exists
  If not #$ISMBR(srcLib:srcFle:srcMbr);
    #$SNDMSG('Error member '+%trim(srcLib)+'/'+%trim(srcFle)+','+
              %trim(dspFle) + ' not found.':'*ESCAPE');
    Return;
  EndIf;

  // Set the program name and panel group name based on the display file
  If #$LAST(dspFle:2) = 'FM';
    pgmNme = %subst(dspFle:1:%scan('FM':dspFle)-1);
    srcMbr = %subst(dspFle:1:%scan('FM':dspFle)-1)+'PM';
  Else;
    pgmNme = %subst(dspFle:1:6) + 'D' + %subst(dspFle:8:3);
    srcMbr = %subst(dspFle:1:6) + 'P' + %subst(dspFle:8:3);
  EndIf;

  // Get the program name for the source member description
  Exec SQL Select des Into :des From PGMMST Where pgmNme = :pgmNme;

  // Create source file in QTEMP
  #$CMD('CRTSRCPF QTEMP/QSRC':1);

  // create the source member
  #$CMD('RMVM QTEMP/QSRC '+%trim(srcMbr):1);
  #$CMD('ADDPFM FILE(QTEMP/QSRC) MBR('+%trim(srcMbr)+')':1);

  // make the source type PNLGRP and make the text the program name
  #$CMD('CHGPFM FILE(QTEMP/QSRC) +
                MBR('+%trim(srcMbr)+') +
                SRCTYPE(PNLGRP) +
                Text('''+%trim(#$DBLQ(des))+''')':1);

  // Create an alias to the source member
  Exec SQL Drop Alias QTEMP/TMP318ALS;
  sqlStm='Create or Replace Alias QTEMP/TMP318ALS For +
        QTEMP/QSRC("' + %trim(srcMbr) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // clear the source member if it already exists
  Exec SQL Delete From QTEMP/TMP318ALS;

  // Start the panel group
  writeLine(':PNLGRP.');

  // add the header information
  writeLine('.*---------------------------------------------------------------------');
  writeLine(':HELP   NAME='+%trim(pgmNme) + '.'+%trim(des));
  writeHlpTxt('':'':dspFle:'');
  writeLine(':EHELP.');

  // loop through all fields on the screen and add each one
  Exec SQL Declare fldCrs Cursor For
    With
      Fields as (
        Select
          min(fldrow) fldRow,
          min(fldcol) fldCol,
          SCRLOC.fldNme fldNme,
          max(refFld) refFld,
          max(refFle) refFle,
          max(fldTyp) fldTyp,
          max(fldLen) fldLen,
          max(fldScl) fldScl,
          max(extTyp) extTyp,
          max(rcdFmtTyp) rcdFmtTyp
        From SCRLOC
        Where mbr = :dspFle
          and lib = :srcLib
          and fldCol <> 0
          and fldNme not in ('SEL','SEL1')
        group by SCRLOC.fldNme
      )
    Select fldNme,refFld,refFle,fldTyp,fldLen,fldScl,fldRow,fldCol
    From fields
    Order by fldRow,fldCol;
  Exec SQL Open fldCrs;
  Exec SQL Fetch Next From fldCrs Into :fldDta;
  DoW sqlState < '02';
    If fldDta.fldNme = 'OPTIONS';
      AddOptions();
    ElseIf fldDta.fldNme = 'FNCKEYS';
      AddFunctionKeys();
    Else;
      AddField();
    EndIf;
    Exec SQL Fetch Next From fldCrs Into :fldDta;
  EndDo;
  Exec SQL Close fldCrs;


  // End the panel group
  writeLine('.*---------------------------------------------------------------------');
  writeLine(':EPNLGRP.');

  // Create the panel group
  #$CMD('CRTPNLGRP +
           PNLGRP('+%trim(srcLib)+'/'+%trim(srcMbr)+') +
           SRCFILE(QTEMP/QSRC) +
           SRCMBR('+%trim(srcMbr)+') +
           REPLACE(*YES)');

  // Update PGMMST with the number of fields and number that have help text
  Exec SQL update PGMMST
           set totCnt = (Select Count(*) from Table(PGMHLPT1(:pgmNme,:dspFle,:srcLib))),
               hlpCnt = (Select Count(*) from Table(PGMHLPT1(:pgmNme,:dspFle,:srcLib)) where lneCnt<>0)
           where pgmNme = :pgmNme;

End-Proc;


// Add SQL options section to the panel group
Dcl-Proc AddOptions;
  Dcl-S opt like(APLDCT.opt);
  Dcl-S des like(APLDCT.des);
  Dcl-S fieldFound ind;
  Dcl-S defaultFound ind;

  // function keys loo through each key setup in the PGMFNC file and
  // adds an entry for each one.
  // For each key it first checks if there is specific help text setup for it,
  // if not some defualt text is added for common keys.

  // Add header section for fucntion keys
  writeLine('.*---------------------------------------------------------------------');
  writeLine(':HELP   NAME=OPTIONS.Program Options');
  writeLine(':XH3.Program Options');
  writeLine(':P.Program options are entered in front of any entry in the list or on the');
  writeLine('entry line at the top of the list.');
  writeLine(':P.This program includes the following options.');
  writeLine(':UL.');

  // loop through the options for this program
  Exec SQL
    Declare optionsCrs Cursor For
      Select opt,des
      From PGMOPT
      Where pgmNme = :pgmNme
        and acvRow = '1'
      Order by opt;
  Exec SQL Open optionsCrs;
  Exec SQL Fetch Next From optionsCrs Into :opt,:des;
  DoW sqlState<'02';
    writeLine(':LI.:HP2.'+%trim(des)+':EHP2.');
    // see if there is help text entered for the field or defaults
    fieldFound = *off;
    defaultFound = *off;
    Exec SQL Select '1' Into :fieldFound From HLPDTL
        Where (dctNme,fldNme,dspFle,val) = ('','OPTIONS',:dspFle,Char(:opt))
        Fetch First Row Only;
    Exec SQL Select '1' Into :defaultFound From HLPDTL
        Where (dctNme,fldNme,dspFle,val) = ('','OPTIONS','',Char(:opt))
        Fetch First Row Only;
    // get help text defined for screen if it exists, else use default, else use not entered
    If fieldFound;
      writeHlpTxt('':'OPTIONS':dspFle:%char(opt));
    ElseIf defaultFound;
      writeHlpTxt('':'OPTIONS':'':%char(opt));
    Else;
      writeLine(':P.Help text not entered.');
    EndIf;
    Exec SQL Fetch Next From optionsCrs Into :opt,:des;
  EndDo;
  Exec SQL Close optionsCrs;

  writeLine(':EUL.');
  writeLine(':EHELP.');

End-Proc;


// Add function keys section to the panel group
Dcl-Proc AddFunctionKeys;
  Dcl-S fnckey like(APLDCT.fnckey);
  Dcl-S des like(APLDCT.des);
  Dcl-S fieldFound ind;
  Dcl-S defaultFound ind;

  // function keys loo through each key setup in the PGMFNC file and
  // adds an entry for each one.
  // For each key it first checks if there is specific help text setup for it,
  // if not some defualt text is added for common keys.

  // Add header section for fucntion keys
  writeLine('.*---------------------------------------------------------------------');
  writeLine(':HELP   NAME=FNCKEYS.Function Keys');
  writeLine(':XH3.Function Keys');
  writeLine(':P.This screen has the following function keys');
  writeLine(':UL.');

  // loop through the function keys for this program
  Exec SQL
    Declare fncKeysCrs Cursor For
      Select FNCKEY, DES
      From pgmfnc
      Where PGMNME = :pgmNme
        and ACVROW = '1'
      Order by SEQNBR;
  Exec SQL Open fncKeysCrs;
  Exec SQL Fetch Next From fncKeysCrs Into :fnckey, :des;
  DoW sqlState<'02';
    writeLine(':LI.:HP2.'+%trim(des)+':EHP2.');
    // see if there is help text entered for the field or defaults
    fieldFound = *off;
    defaultFound = *off;
    Exec SQL Select '1' Into :fieldFound From HLPDTL
        Where (dctNme,fldNme,dspFle,val) = ('','FNCKEYS',:dspFle,:fnckey)
        Fetch First Row Only;
    Exec SQL Select '1' Into :defaultFound From HLPDTL
        Where (dctNme,fldNme,dspFle,val) = ('','FNCKEYS','',:fnckey)
        Fetch First Row Only;
    // get help text defined for screen if it exists, else use default, else use not entered
    If fieldFound;
      writeHlpTxt('':'FNCKEYS':dspFle:fnckey);
    ElseIf defaultFound;
      writeHlpTxt('':'FNCKEYS':'':fnckey);
    Else;
      writeLine(':P.Help text not entered.');
    EndIf;
    Exec SQL Fetch Next From fncKeysCrs Into :fnckey, :des;
  EndDo;
  Exec SQL Close fncKeysCrs;

  writeLine(':EUL.');
  writeLine(':EHELP.');

End-Proc;


// Add a field to the panel group
Dcl-Proc AddField;
  Dcl-S fieldFound ind;
  Dcl-S dictFound ind;
  Dcl-S defaultFound ind;
  Dcl-S fieldText like(APLDCT.fldNme);
  Dcl-S des like(APLDCT.des);

  // if the field is a SFL field and there is a position to field for it, skip it, the position to field will
  // cover the entire length of the SFL fields
  If fldDta.rcdFmtTyp = 'SFL';
    Exec SQL Select '1' Into :found
             From SCRLOC
             Where (mbr,lib,rcdFmtTyp,fldnme) = (:dspFle,:srcLib,'SFLCTL',trim(:fldDta.fldNme) Concat '1')
             Limit 1;
    If found;
      Return;
    EndIf;
  EndIf;

  // If the field is referenced, change the field name to get text from to the referenced name
  fieldText = '';
  Exec SQL Select hlpRef Into :fieldText From HLPMST Where (dctNme,fldNme,dspFle,val) = ('',:fldDta.fldNme,:dspFle,'');
  If fieldText = '';
    fieldText = fldDta.fldNme;
  EndIf;

  // See if there is help text entered for the field, the dictionary or defaults
  Exec SQL Select '1' Into :fieldFound From HLPDTL
    Where (dctNme,fldNme,dspFle,val) = ('',:fieldText,:dspFle,'')
    Fetch First Row Only;
  Exec SQL Select '1' Into :dictFound From HLPDTL
    Where (dctNme,fldNme,dspFle,val) = (:fldDta.refFle,:fldDta.refFld,'','')
    Fetch First Row Only;
  Exec SQL Select '1' Into :defaultFound From HLPDTL
    Where (dctNme,fldNme,dspFle,val) = ('',:fieldText,'','')
    Fetch First Row Only;

  // Get field description
  des = '';
  If fieldFound; // Help text for the field if found
    Exec SQL Select des Into :des From HLPMST
      Where (dctNme,fldNme,dspFle,val) = ('',:fieldText,:dspFle,'')
      Fetch First Row Only;
  ElseIf dictFound; // Add help text from the dictionary if found
    Exec SQL Select des Into :des From HLPMST
      Where (dctNme,fldNme,dspFle,val) = (:fldDta.refFle,:fldDta.refFld,'','')
      Fetch First Row Only;
  ElseIf defaultFound; // add default help text if found
    Exec SQL Select des Into :des From HLPMST
      Where (dctNme,fldNme,dspFle,val) = ('',:fieldText,'','')
      Fetch First Row Only;
  EndIf;
  If des = '' and fldDta.refFle<>''; // try to get the descrition from the dta dictionary
    Exec SQL Select COLTXT Into :des From DCTFLD Where (dctNme,fldNme) = (:fldDta.refFle,:fldDta.refFld);
  EndIf;
  If des = ''; // if no name found, generate a fake one
    des = 'Error name not found (' + %trim(fldDta.fldNme)+')';
  EndIf;

  // Translate some characters that are invalid in help group names
  fldDta.fldNme = %xlate('#':'_':fldDta.fldNme);
  fldDta.fldNme = %xlate('@':'_':fldDta.fldNme);
  fldDta.fldNme = %xlate('$':'/':fldDta.fldNme);


  writeLine('.*---------------------------------------------------------------------');
  writeLine(':HELP   NAME='''+%trim(fldDta.fldNme) + '''.'+%trim(des));
  writeLine(':XH3.'+%trim(des));

  If fieldFound; // Help text for the field if found
    writeHlpTxt('':fieldText:dspFle:'');
  ElseIf dictFound; // Add help text from the dictionary if found
    writeHlpTxt(fldDta.refFle:fldDta.refFld:'':'');
  ElseIf defaultFound; // add default help text if found
    writeHlpTxt('':fieldText:'':'');
  Else; // add help text not entered message
    writeLine(':P.Help text not entered.');
  EndIf;

  // add field name, type, length and scale
  writeLine(':P.Screen: ' + %trim(dspFle) + ' Field: ' + fldDta.fldNme);

  // if a field is referenced, pull the type length and scale from the data dictionary
  If fldDta.fldTyp = 'REFERENCED';
    Exec SQL
      Select FLDTYP, FLDLEN, FLDSCL
      Into :fldDta.fldTyp,:fldDta.fldLen,:fldDta.fldScl
      From dctfld
      Where (dctNme,fldNme)  = (:fldDta.refFle,:fldDta.refFld);
  EndIf;

  // Add fields that need a scale
  If fldDta.fldTyp in %list('DECIMAL':'ZONED':'NUMERIC':'PACKED');
    writeLine('Type: '+%trim(fldDta.fldTyp) + '(' + %char(fldDta.fldLen) + ',' + %char(fldDta.fldScl) + ')');
    // Add fields that need a length
  ElseIf fldDta.fldTyp in %list('CHAR');
    writeLine('Type: '+%trim(fldDta.fldTyp) + '(' + %char(fldDta.fldLen) + ')');
    // Add jsut the type
  ElseIf fldDta.fldTyp<>'';
    writeLine('Type: '+%trim(fldDta.fldTyp));
  EndIf;

  writeLine('Location: ('+%char(fldDta.fldRow)+','+%char(fldDta.fldCol)+')');

  writeLine(':EHELP.');

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
