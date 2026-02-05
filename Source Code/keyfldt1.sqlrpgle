**FREE
ctl-opt option(*srcstmt) dftactgrp(*no) bnddir('APLLIB') decedit('0.');

// List key fields for a file, table, logical, index or view

// To call example:
//    Select * From Table(KEYFLDT1('APLLIB','FLEMST'))

dcl-s EOF Ind;
dcl-s currentIndex Int(5);

/copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

//  User Defined Table Function (UDTF) call parameter constants
dcl-c UDTF_FIRSTCALL -2;
dcl-c UDTF_OPEN -1;
dcl-c UDTF_FETCH 0;
dcl-c UDTF_CLOSE 1;
dcl-c UDTF_LASTCALL 2;

//  SQL States
dcl-c SQLSTATEOK '00000';
dcl-c ENDOFTABLE '02000';
dcl-c UDTF_ERROR 'US001';

// NULL Constants
dcl-c ISNULL -1;
dcl-c NOTNULL 0;

dcl-pi FLDLSTT1 ExtPgm('KEYFLDT1');
  // Incoming parameters
  pmrFleLib char(10);
  pmrFleNme char(10);

  //  Outgoing parameters
  keyFld char(10);

  // Null Indicators
  pmrFleLib_ni int(5);
  pmrFleNme_ni int(5);
  keyFld_ni    int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  callType Int(10);
end-pi;

dcl-s i packed(5);
dcl-s k packed(5);
dcl-s s packed(5);
dcl-s a packed(5);
dcl-s b packed(5);
Dcl-s keys char(10) dim(50);
Dcl-S rtnFleNme char(20);


dcl-ds ERRORDS len(116) inz;
  bytesProvides int(10) inz(116) pos(1);
  bytesAavailable int(10) pos(5);
  messageID char(7) pos(9);
  errNbr char(1) pos(16);
  messageDta char(100) pos(17);
end-ds;

dcl-ds receiverVariable len(4096);
  fileType char(1) pos(9);
  attribs char(1) pos(10);
  nbrOfMbrs int(5) pos(48);
  nbrOfFormats int(5) pos(62);
  filDsc char(40) pos(85);
  dbFileOffset int(10) pos(317);
  dbPhyOffset int(10) pos(365);
  dbJrnOffset int(10) pos(379);
end-ds;

dcl-ds findSelDs len(139);
  otherStuff char(116) pos(1);
  nbrOfKeys int(5) pos(117);
  keyOffset int(10) pos(136);
end-ds;

// Retrieve database file description:
Dcl-Pr RtvDbfDsc extpgm( 'QDBRTVFD' );
  *n char(32767) options( *varsize ); // RdRcvVar
  *n int(10) const; // RdRcvVarLen
  *n char(20); // RdFilRtnQ
  *n char(8) const; // RdFmtNam
  *n char(20) const; // RdFilNamQ
  *n char(10) const; // RdRcdFmtNam
  *n char(1) const; // RdOvrPrc
  *n char(10) const; // RdSystem
  *n char(10) const; // RdFmtTyp
  *n char(32767) options( *varsize ); // RdError
End-Pr;

Exec SQL Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso;

SQL_State=SQLSTATEOK;

Select;
When callType = UDTF_OPEN;

  // get array containing the keyFlds
  rtnfleNme = (pmrFleNme + pmrFleLib);
  RtvDbfDsc(receiverVariable:4096:rtnfleNme:'FILD0100':rtnFleNme:'          ':'0':'*LCL':'*EXT':ERRORDS);

  if messageId = '' and dbFileOffset <> 0;
    I = dbFileOffset;
    for a = 1 to nbrOfFormats;
      findSelDs = %subst(receiverVariable:I:%len(findSelDs));
      S = (keyOffset + 1);
      for b = 1 to nbrOfKeys;
        k += 1;
        keys(k) = %subst(receiverVariable:s:10);
        S = (S + 32);
      EndFor;
      I = (I + 160);
    EndFor;
  endIf;

  currentIndex=0;
  EOF = *off;

When callType=UDTF_FETCH;

  currentIndex+=1;

  SetNulInd(NOTNULL);
  If currentIndex>k;
    SetNulInd(ISNULL);
    SQL_State = ENDOFTABLE;
  Else;
    keyfld = keys(currentIndex);
  EndIf;

When callType = UDTF_CLOSE;
  *inlr=*on;
EndSl;

return;


//  Set Null Returns
dcl-proc SetNulInd;
  dcl-pi SetNulInd;
    nulInd Int(5) Const;
  end-pi;

  pmrFleLib_ni = nulInd;
  pmrFleNme_ni = nulInd;
  keyFld_ni    = nulInd;
end-proc;
