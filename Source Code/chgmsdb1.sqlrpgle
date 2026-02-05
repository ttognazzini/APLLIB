**free
Ctl-Opt Option( *SrcStmt ) dftactgrp(*no) actgrp(*new) Main(Main);

// CPP for CHGMSD - Change Message Desription

// This pulls the current message values and then calls the CHGMSGD
// command with most of the previous values populated.

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Globals for parameters
Dcl-S msgId char(7);
Dcl-S msgLib char(10);
Dcl-S msgFle char(10);

// Message description values Output DS
Dcl-Ds msg qualified;
  msgSeverity     Int(10);             // Message Severity
  alertIndex      Int(10);             // Alert Index
  alertOption     Char(9);             // Alert Option
  logIndicator    Char(1);             // Log Indicator
  messageId       Char(7);             // Message ID
  nbrRplDtaFmt    Int(10);             // Number Replace Data Formats
  txtCCSIDRtn     Int(10);             // Text CCSID Returned
  rplTyp          Char(10);            // Reply Type
  maxRplLen       Int(10);             // Maximum Reply Length
  maxRplDec       Int(10);             // Maximum Reply Dec Positions
  msgCrtDte       Char(7);             // Message Creation Date
  msgCrtLvl       Int(10);             // Message Creation Level
  msgModDte       Char(7);             // Message Modification Date
  msgModLvl       Int(10);             // Message Modification Level
  strMsgCCSID     Int(10);             // Stored Message CCSID
  dftPgmNme       Char(10);            // Default Program Name
  dftPgmLib       Char(10);            // Default Program Library
  rplTxt          varchar(1000);       // reply text
  msgTxt          varchar(1000);       // messge text
  hlpRtn          varchar(10000);      // second level text
  subFmtCnt       packed(3);           // number of substition formats
  subFmtLen       packed(5) dim(20);   // length of each substitution format
  subFmtDec       packed(5) dim(20);   // decimal positions of each substitution format
  subFmtTyp       char(10) dim(20);    // type of each substitution format
  vldRplCnt       packed(3);           // number of valid replies
  vldRpl          varchar(10) dim(20); // valid replies
  spcValCnt       packed(3);           // number of special value entries
  spcValFrm       char(32) dim(20);    // list of from special vlaues
  spcValTo        char(32) dim(20);    // list of to special values
  rplValLwrRng    varchar(100);        // Reply value Lower Range
  rplValUprRng    varchar(100);        // Reply value Upper Range
  rplRelOpr       char(10);            // relationship for valid replies entry operator
  rplRelLen       packed(5);           // relationship for valid replies entry length
  rplRelVal       varchar(100);        // relationship for valid replies entry value
  dmpLstCnt       packed(3);           // number of data to be dumped entries
  dmpLstVal       int(10) dim(20);     // data to be dumped entries values
End-Ds;

// Prototype for qcmdexc
Dcl-Pr QCMDEXC EXTPGM;
  COMMAND        Char(32768) CONST;
  LENGTH         Packed(15:5) CONST;
End-Pr;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('CHGMSDB1');
    pmrMsgId char(7);
    pmrMsgF char(20);
  End-Pi;
  Dcl-S CMD Varchar(32768);
  Dcl-S x   packed(5);

  // move parameters to globals
  msgId = pmrMsgId;
  msgFle = %subst(pmrMsgF:1:10);
  msgLib = %subst(pmrMsgF:11:10);

  // populate the msg DS with the message attributes
  rtvMsg();

  // Build command adding in found values
  CMD = '? CHGMSGD MSGID('+%trim(msgId)+') +
                   MSGF('+%trim(msgLib)+'/'+%trim(msgFle)+')';

  // Add in each value found
  If msg.msgTxt <> '';
    CMD += ' MSG('''+%trim(msg.msgTxt)+''')';
  EndIf;
  If msg.hlpRtn <> '';
    CMD += ' SECLVL('''+%trim(msg.hlpRtn)+''')';
  EndIf;
  If msg.msgSeverity <> 0;
    CMD += ' SEV('+%char(msg.msgSeverity)+')';
  EndIf;
  If msg.subFmtCnt > 0;
    CMD += ' FMT(';
    For x = 1 to msg.subFmtCnt;
      If msg.subFmtTyp(x) = '*CHAR' and msg.subFmtLen(x) = -1;
        CMD += ' (' + %trim(msg.subFmtTyp(x)) + ' *VARY)';
      ElseIf msg.subFmtTyp(x) = '*CHAR';
        CMD += ' (' + %trim(msg.subFmtTyp(x)) + ' ' + %char(msg.subFmtLen(x)) + ')';
      Else;
        CMD += ' (' + %trim(msg.subFmtTyp(x)) + ' ' + %char(msg.subFmtLen(x)) + ' ' + %char(msg.subFmtDec(x)) + ')';
      EndIf;
    EndFor;
    CMD += ')';
  EndIf;
  If msg.rplTyp <> '';
    CMD += ' TYPE('+%trim(msg.rplTyp)+')';
  EndIf;
  If msg.rplTyp = '*NONE';
    CMD += ' LEN(*NONE)';
  ElseIf msg.maxRplLen <> 0;
    CMD += ' LEN('+%char(msg.maxRplLen)+' '+%char(msg.maxRplDec)+')';
  EndIf;
  If msg.vldRplCnt > 0;
    CMD += ' VALUES(';
    For x = 1 to msg.vldRplCnt;
      CMD += ' ' + %trim(msg.vldRpl(x));
    EndFor;
    CMD += ')';
  EndIf;
  If msg.spcValCnt > 0;
    CMD += ' SPCVAL(';
    For x = 1 to msg.spcValCnt;
      CMD += ' (''' + %trim(msg.spcValFrm(x)) + ''' ''' + %char(msg.spcValTo(x)) + ''')';
    EndFor;
    CMD += ')';
  EndIf;
  If msg.rplValLwrRng <> '';
    CMD += ' RANGE(''' + %trim(msg.rplValLwrRng) + ''' ''' + %trim(msg.rplValUprRng) + ''')';
  EndIf;
  If msg.rplRelOpr <> '';
    CMD += ' REL(' + %trim(msg.rplRelOpr) + ' ''' + %trim(msg.rplRelVal) + ''')';
  EndIf;
  If msg.rplTxt <> '';
    CMD += ' REL(' + %trim(msg.rplTxt) + ''')';
  EndIf;
  If msg.dftPgmNme <> '' and msg.dftPgmLib <> '';
    CMD += ' DFTPGM(' + %trim(msg.dftPgmLib) + '/' + %trim(msg.dftPgmNme) + ')';
  ElseIf msg.dftPgmNme <> '';
    CMD += ' DFTPGM(' + %trim(msg.dftPgmNme) + ')';
  EndIf;
  If msg.dmpLstCnt <> 0;
    CMD += ' DMPLST(';
    For x = 1 to msg.dmpLstCnt;
      If msg.dmpLstVal(x) = -1;
        CMD += ' *JOBDMP';
      ElseIf msg.dmpLstVal(x) = -2;
        CMD += ' *JOBINT';
      ElseIf msg.dmpLstVal(x) = -4;
        CMD += ' *JOB';
      Else;
        CMD += ' ' + %char(msg.dmpLstVal(x));
      EndIf;
    EndFor;
    CMD += ')';
  EndIf;
  If msg.alertOption <> '' and msg.alertIndex <> 0;
    CMD += ' ALROPT('+ %trim(msg.alertOption) + ' ' + %char(msg.alertIndex) + ')';
  ElseIf msg.alertOption <> '';
    CMD += ' ALROPT('+ %trim(msg.alertOption) + ' *NONE)';
  EndIf;
  If msg.logIndicator = 'Y';
    CMD += ' LOGPRB(*YES)';
  ElseIf msg.logIndicator = 'N';
    CMD += ' LOGPRB(*NO)';
  EndIf;
  If msg.txtCCSIDRtn <> 0;
    CMD += ' CCSID('+%char(msg.txtCCSIDRtn)+')';
  EndIf;

  // Run the command
  Monitor;
    QCMDEXC(CMD:%len(CMD));
  On-Error;
  EndMon;

End-Proc;


Dcl-Proc rtvMsg;

  // API Error Ds
  Dcl-Ds apiError qualified len(256) inz;
    bytesProvides int(10) inz(256) pos(1);
    bytesAvailable int(10) pos(5);
    messageID char(7) pos(9);
    errNbr char(1) pos(16);
    messageDta char(100) pos(17);
  End-Ds;

  // IBM API to Retrieve Message Text or Full Description (depending on chosen format)
  Dcl-Pr RtvMsgDesc extpgm('QMHRTVM');
    msgDesc  likedS(msgInfo); // Message information
    msgDscL  int(10)    const; // Length of message information
    msgDFmt  char(8)    const; // Format name
    msgId    char(7)    const; // Message identifier
    msgMsgF  char(20)   const; // Qualified message file name
    msgData  varchar(3000) const; // Replacement data
    msgDatL  int(10)    const; // Length of replacement data
    msgROpt  char(10)   const; // Replace substitution values
    msgFCtl  char(10)   const; //       Return format control characters
    msgErrC  likeds(apiError); // Error code
    // optional parm group
    msgRtvO  char(10)   const options(*nopass); // Retrieve Option
    msgToCss int(10)    const options(*nopass); // CCSID to convert to
    msgRCss  int(10)    const options(*nopass); // CCSID of replacement data
  End-Pr;

  // Type Definition for the RTVM0400 format.
  Dcl-Ds msgInfo    len(12000) qualified;             // Qmh Rtvm RTVM0400
    bytesReturned   Int(10)    Pos(1);      // Bytes Return
    bytesAvaiable   Int(10)    Pos(5);      // Bytes Available
    msgSeverity     Int(10)    Pos(9);      // Message Severity
    alertIndex      Int(10)    Pos(13);     // Alert Index
    alertOption     Char(9)    Pos(17);     // Alert Option
    logIndicator    Char(1)    Pos(26);     // Log Indicator
    messageId       Char(7)    Pos(27);     // Message ID
    reserved1       Char(3)    Pos(34);     // Reserved
    nbrRplDtaFmt    Int(10)    Pos(37);     // Number Replace Data Formats
    txtCCSIDCnvSts  Int(10)    Pos(41);     // Text CCSID Convert Status
    dtaCCSIDCnvSts  Int(10)    Pos(45);     // Data CCSID Convert Status
    txtCCSIDRtn     Int(10)    Pos(49);     // Text CCSID Returned
    rplTxtOff       Int(10)    Pos(53);     // Offset Default Reply Text
    rplTxtLen       Int(10)    Pos(57);     // Length Default Reply Returned
    rplTxtAvl       Int(10)    Pos(61);     // Length Default Reply Available
    msgTxtOff       Int(10)    Pos(65);     // Offset Message Text Returned
    msgTxtLen       Int(10)    Pos(69);     // Length Message Text Returned
    msgTxtAvl       Int(10)    Pos(73);     // Length Message Text Available
    hlpRtnOff       Int(10)    Pos(77);     // Offset Message Help Returned
    hlpRtnLen       Int(10)    Pos(81);     // Length Message Help Returned
    hlpRtnAvl       Int(10)    Pos(85);     // Length Message Help Available
    subFmtOff       Int(10)    Pos(89);     // Offset Substitution Formats
    subFmtLen       Int(10)    Pos(93);     // Length Substitution Formats Returned
    subFmtAvl       Int(10)    Pos(97);     // Length Substitution Formats Available
    subFmtElmLen    Int(10)    Pos(101);    // Length Substitution Format Element
    rplTyp          Char(10)   Pos(105);    // Reply Type
    reserved2       Char(2)    Pos(115);    // Reserved2
    maxRplLen       Int(10)    Pos(117);    // Maximum Reply Length
    maxRplDec       Int(10)    Pos(121);    // Maximum Reply Dec Positions
    vldRplOff       Int(10)    Pos(125);    // Offset Valid Replies
    vldRplCnt       Int(10)    Pos(129);    // Number Valid Replies
    vldRplLen       Int(10)    Pos(133);    // Length Valid Replies Returned
    vldRplAvl       Int(10)    Pos(137);    // Length Valid Replies Available
    vldRplEntLen    Int(10)    Pos(141);    // Length Valid Reply Entry
    spcValOff       Int(10)    Pos(145);    // Offset Special Reply Value
    spcValCnt       Int(10)    Pos(149);    // Number Special Reply Value
    spcValLenh      Int(10)    Pos(153);    // Length Special Reply Value Returned
    spcValAvl       Int(10)    Pos(157);    // Length Special Reply Value Available
    spcValEntLen    Int(10)    Pos(161);    // Length Special Reply Value Entry Length
    lwrRngOff       Int(10)    Pos(165);    // Offset Lower Range
    lwrRngLen       Int(10)    Pos(169);    // Length Lower Range Returned
    lwrRngAvl       Int(10)    Pos(173);    // Length Lower Range Available
    uprRngOff       Int(10)    Pos(177);    // Offset Upper Range
    uprRngLen       Int(10)    Pos(181);    // Length Upper Range Returned
    uprRngAvl       Int(10)    Pos(185);    // Length Upper Range Available
    relTstOff       Int(10)    Pos(189);    // Offset Relationship for valid replies
    relTstLen       Int(10)    Pos(193);    // Length Relationship for valid replies Returned
    relTstAvl       Int(10)    Pos(197);    // Length Relationship for valid replies Available
    msgCrtDte       Char(7)    Pos(201);    // Message Creation Date
    reserved3       Char(1)    Pos(208);    // Reserved3
    msgCrtLvl       Int(10)    Pos(209);    // Message Creation Level
    msgModDte       Char(7)    Pos(213);    // Message Modification Date
    reserved4       Char(1)    Pos(220);    // Reserved4
    msgModLvl       Int(10)    Pos(221);    // Message Modification Level
    strMsgCCSID     Int(10)    Pos(225);    // Stored Message CCSID
    dmpLstOff       Int(10)    Pos(229);    // Offset Dump List
    dmpLstCnt       Int(10)    Pos(233);    // Number Dump List Entries
    dmpLstLen       Int(10)    Pos(237);    // Length Dump List Returned
    dmpLstAvl       Int(10)    Pos(241);    // Length Dump List Available
    dftPgmNme       Char(10)   Pos(245);    // Default Program Name
    dftPgmLib       Char(10)   Pos(255);    // Default Program Library
  End-Ds;

  // Temp variables
  Dcl-Ds subFmt qualified;
    len  int(10);
    dec  int(10);
    type char(10);
  End-Ds;
  Dcl-S x packed(5);

  Dcl-Ds relTstEnt qualified;
    opr    Char(10)     pos(1);
    rsv    Char(2)      pos(11);
    length int(10)      pos(13);
    val    varChar(100) pos(17);
  End-Ds;
  Dcl-Ds dmpLstDs qualified;
    val int(10);
  End-Ds;

  // all the API to get message details
  RtvMsgDesc ( msgInfo          // Message information
             : %len(msgInfo)    // Length of message information
             : 'RTVM0400'       // Format name
             : msgId            // Message identifier
             : msgFle + msgLib  // Qualified message file name
             : ''               // Replacement data
             : 0                // Length of replacement data
             : '*NO'            // Replace substitution values
             : '*YES'           // Return format control characters
             : apiError         // Error code
             : '*MSGID'         // Retrieve Option
             : 37               // CCSID to convert to
             : 0                // CCSID of replacement data
  );

  // move exact match fields to output ds
  Clear msg;
  Eval-Corr msg = msgInfo;

  // Parse varrying length fields
  msg.rplTxt = %subst(msgInfo:msgInfo.rplTxtOff+1:msgInfo.rplTxtLen);
  msg.msgTxt = %subst(msgInfo:msgInfo.msgTxtOff+1:msgInfo.msgTxtLen);
  msg.hlpRtn = %subst(msgInfo:msgInfo.hlpRtnOff+1:msgInfo.hlpRtnLen);
  msg.rplValLwrRng = %subst(msgInfo:msgInfo.lwrRngOff+1:msgInfo.lwrRngLen);
  msg.rplValUprRng = %subst(msgInfo:msgInfo.uprRngOff+1:msgInfo.uprRngLen);

  // Parse substitution fields
  If msgInfo.subFmtElmLen > 0;
    msg.subFmtCnt = %int(msgInfo.subFmtLen/msgInfo.subFmtElmLen);
    For x = 1 to msg.subFmtCnt;
      subFmt = %subst(msgInfo:msgInfo.subFmtOff + 1 + (x-1) * msgInfo.subFmtElmLen:msgInfo.subFmtElmLen);
      msg.subFmtDec(x) = subFmt.dec;
      msg.subFmtLen(x) = subFmt.len;
      msg.subFmtTyp(x) = subFmt.type;
    EndFor;
  EndIf;

  // Parse valid reply list
  For x = 1 to msg.vldRplCnt;
    msg.vldRpl(x) = %subst(msgInfo:msgInfo.vldRplOff + 1 + (x-1) * msgInfo.vldRplEntLen:msgInfo.vldRplEntLen);
  EndFor;

  // Parse special values
  If msg.spcValCnt > 0;
    For x = 1 to msg.spcValCnt;
      msg.spcValFrm(x) = %subst(msgInfo:msgInfo.spcValOff + 1 + (x-1) * msgInfo.spcValEntLen:32);
      msg.spcValTo(x) = %subst(msgInfo:msgInfo.spcValOff + 33 + (x-1) * msgInfo.spcValEntLen:32);
    EndFor;
  EndIf;

  // Parse Relational Tests
  If msgInfo.relTstOff > 0 and msgInfo.relTstLen > 0;
    relTstEnt = %subst(msgInfo:msgInfo.relTstOff + 1:msgInfo.relTstLen);
    msg.rplRelOpr = relTstEnt.opr;
    msg.rplRelLen = relTstEnt.length;
    msg.rplRelVal = relTstEnt.val;
  EndIf;

  // parse data to be dumped values
  If msg.dmpLstCnt > 0;
    For x = 1 to msg.dmpLstCnt;
      dmpLstDs = %subst(msgInfo:msgInfo.dmpLstOff + 1 + (x-1) * 4:4);
      msg.dmpLstVal(x) = dmpLstDs.val;
    EndFor;
  EndIf;


End-Proc;
