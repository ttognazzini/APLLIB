**free
// Error data structure
Dcl-Ds #$DTAQERR; //Qus EC
  #$ERBPRV       Bindec(9)  Pos(1) INZ(512); //Bytes Provided
  #$ERBAVL       Bindec(9)  Pos(5) INZ(0); //Bytes Available
  #$EREI         Char(7)    Pos(9); //Exception Id
  #$ERERVED      Char(1)    Pos(16); //Reserved
  #$ERED01       Char(496)  Pos(17); //Error Text
End-Ds;

// Sender info data structure
Dcl-Ds #$DTAQSNDINF;
  #$SIBYTESRET   Bindec(9)  Pos(1) INZ(44);
  #$SIBYTESAVL   Bindec(9)  Pos(5);
  #$SIUSER       Char(10)   Pos(9);
  #$SIJOB        Char(10)   Pos(19);
  #$SIJOBNO      Char(6)    Pos(29);
  #$SICRUSER     Char(10)   Pos(35);
End-Ds;

// Prototype for clear data queue api
Dcl-Pr #$CLRDTAQ  EXTPGM('QCLRDTAQ');
  DATAQUEUE      Char(10)   CONST;
  DATAQUEUELIB   Char(10)   CONST;
  // OPTIONAL PARAMETER GROUP
  KEYORDER       Char(2)    CONST OPTIONS(*NOPASS);
  KEYLENGTH      Packed(3:0) CONST OPTIONS(*NOPASS);
  KEYDATA        Char(32766) CONST OPTIONS(*NOPASS:*VARSIZE);
  ERRORCODE                 LIKEDS(#$DTAQERR) OPTIONS(*NOPASS);
End-Pr;

// Prototype for send data queue api
Dcl-Pr #$SNDDTAQ  EXTPGM('QSNDDTAQ');
  DATAQUEUE      Char(10)   CONST;
  DATAQUEUELIB   Char(10)   CONST;
  DATAQUEUELEN   Packed(5:0) CONST;
  QUEUEDATA      Char(32766) CONST OPTIONS(*VARSIZE);
  // Optional parameter group 1
  KEYLENGTH      Packed(3:0) CONST OPTIONS(*NOPASS);
  KEYDATA        Char(32766) CONST OPTIONS(*NOPASS:*VARSIZE);
  // Optional parameter group 2
  ASYNCREQ       Char(10)   CONST OPTIONS(*NOPASS);
  // Optional parameter group 3
  FROMJE         Char(10)   CONST OPTIONS(*NOPASS);
End-Pr;

// Prototype for receive data queue api
Dcl-Pr #$RCVDTAQ  EXTPGM('QRCVDTAQ');
  DATAQUEUE      Char(10)   CONST;
  DATAQUEUELIB   Char(10)   CONST;
  DATAQUEUELEN   Packed(5:0) CONST;
  QUEUEDATA      Char(32766) CONST OPTIONS(*VARSIZE);
  DATAWAIT       Packed(5:0) CONST;
  // Optional parameter group 1
  KEYORDER       Char(2)    CONST OPTIONS(*NOPASS);
  KEYLEN         Packed(3:0) CONST OPTIONS(*NOPASS);
  KEYDATA        Char(32766) CONST OPTIONS(*NOPASS:*VARSIZE);
  SENDERKEYLEN   Packed(3:0) CONST OPTIONS(*NOPASS);
  SENDERINFO                LIKEDS(#$DTAQSNDINF) OPTIONS(*NOPASS);
  // Optional parameter group 2
  REMOVEMSGS     Char(10)   CONST OPTIONS(*NOPASS);
  SIZEDTARECV    Packed(5:0) CONST OPTIONS(*NOPASS);
  ERRORCODE                 LIKEDS(#$DTAQERR) OPTIONS(*NOPASS);
End-Pr;

// Prototype for change data queue description api
Dcl-Pr #$CHGDTAQ  EXTPGM('QMHQCDQ');
  #$DTAQ         Char(20)   CONST;
  #$REQCHG       Char(2000) OPTIONS(*VARSIZE);
  ERRORCODE                 LIKEDS(#$DTAQERR) OPTIONS(*NOPASS);
End-Pr;
// Data structure for requested change
Dcl-Ds #$REQCHG;
  #$KEY          Int(10);
  #$NEWVALLEN    Int(10);
  #$NEWVALUE     Varchar(10);
End-Ds;
// As of the time of writing the only keys are:
//     Key  Type    Attribute                 Values
//     100  Char(1) Automatic reclaim         0=*NO, 1=*YES
//     200  Char(1) Enforce data Queue locks  0=*NO, 1=*YES
// To change object attributes like the text use chgobjd

// Prototype for retreive data queue description api
Dcl-Pr #$RTVDTAQD  EXTPGM('QMHQRDQD');
  #$RTNVAR       Char(2000) OPTIONS(*VARSIZE);
  #$RTNVARLEN    Int(10)    CONST;
  #$APIFMT       Char(8)    CONST;
  #$DTAQ         Char(20)   CONST;
End-Pr;

// Data structure for #$RTNVAR in RTVDTAQD format RDQD0100
Dcl-Ds #$DATAF1  INZ;
  #$BYTESRTN     Int(10);
  #$BYTESAVL     Int(10)    INZ(%size(#$DATAF1));
  #$MAX_LEN      Int(10);
  #$KEY_LEN      Int(10);
  #$Q_SEQ        Char(1);
  #$SENDER_ID    Char(1);
  #$FORCE_WRITE  Char(1);
  #$TEXTDESC     Char(50);
  #$DTAQ_TYPE    Char(1);
  #$AUTO_RCL     Char(1);
  #$RESERVED1    Char(1);
  #$CUR_MSGS     Int(10);
  #$CURENTRY_CA  Int(10);
  #$DTAQNAME     Char(10);
  #$DTAQLIB      Char(10);
  #$MAX_ENTRY    Int(10);
  #$INIT_ENTRY   Int(10);
End-Ds;

// Data structure for #$RTNVAR in RTVDTAQD format RDQD0200
Dcl-Ds #$DATAF2  INZ;
  #$BYTESRTN2    Int(10);
  #$BYTESAVL2    Int(10)    INZ(%size(#$DATAF2));
  #$APPCDEVD     Char(10);
  #$MODENAME     Char(10);
  #$RMTLOCNM     Char(10);
  #$LCLLOCNM     Char(10);
  #$RMTNETID     Char(10);
  #$RMTDTAQNAM   Char(10);
  #$RMTDTAQLIB   Char(10);
  #$DTAQNAME2    Char(10);
  #$DTAQLIB2     Char(10);
End-Ds;

// PROTOTYPE FOR RETREIVE DATA QUEUE MESSAGE API
Dcl-Pr #$RTVDTAQM  EXTPGM('QMHRDQM');
  #$RTNVAR                  LIKE(#$RTVDTAQDS) OPTIONS(*VARSIZE);
  #$RTNVARLEN    Int(10)    CONST;
  #$FORMAT       Char(8)    CONST;
  #$DTAQ         Char(20)   CONST;
  #$KEYINFO                 LIKE(rdqs0200DS) OPTIONS(*VARSIZE) CONST;
  #$KEYILEN      Int(10)    CONST;
  #$INFO         Char(8)    CONST;
  #$ERRORDS                 LIKEDS(#$DTAQERR) OPTIONS(*NOPASS);
End-Pr;

Dcl-Ds #$RTVDTAQDS  QUALIFIED BASED(#$RTVDTAQPTR);
  BytesRet       Int(10);
  BytesAvL       Int(10);
  MsgRtnCount    Int(10);
  MsgAvlCount    Int(10);
  KeyLenRtn      Int(10);
  KeyLenAvl      Int(10);
  MsgTxtRtn      Int(10);
  MsgTxtAvl      Int(10);
  EntryLenRtn    Int(10);
  EntryLenAvl    Int(10);
  OffsetToEntr   Int(10);
  DtaqLib        Char(10);
End-Ds;

// Message selection - RDQS0100 nonkeyed queues  RDQS0200 Keyed data queues
Dcl-Ds rdqs0100DS  QUALIFIED;
  Selection      Char(1)    INZ('A'); //all
  MsgByteRtv     Int(10)    INZ; //message bytes to rt
End-Ds;

Dcl-Ds rdqs0200DS  QUALIFIED;
  Selection      Char(1)    INZ('K'); //Keyed
  KeyOrder       Char(2)    INZ('GE'); //key search order
  RESERVED       Char(1)    INZ(' '); //reserved
  MsgByteRtv     Int(10)    INZ; //message bytes to rtv
  KeyByteRtv     Int(10)    INZ; //keys bytes to rtv
  KeyLen         Int(10)    INZ; //key length
  Key            Varchar(256); //key value
End-Ds;
