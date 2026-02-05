**Free
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) dftactgrp(*no);

// List Printer Devices
//
// must have authority, change the onwer to QSYSOPR
// CHGOBJOWN OBJ(ERPLIB/LSTPRTT1) OBJTYPE(*PGM) NEWOWN(QSYSOPR)

// To call example:
//    Select * From Table(LSTPRTT1()) as x

Dcl-S EOF Ind;
Dcl-S FldCur Char(120);
Dcl-S FldNxt Char(20);

//dcl-ds Dct ExtName('DATADICT') Qualified Template end-ds;

//  UDTF call parameter constants
Dcl-S UDTF_FirstCall  Int(10) Inz(-2);
Dcl-S UDTF_Open Int(10) Inz(-1);
Dcl-S UDTF_Fetch Int(10) Inz(0);
Dcl-S UDTF_Close Int(10) Inz(1);
Dcl-S UDTF_LastCall Int(10) Inz(2);

//  SQL States
Dcl-C SQLSTATEOK '00000';
Dcl-C ENDOFTABLE '02000';
Dcl-C UDTF_ERROR 'US001';
Dcl-C Tic x'7D';

// NULL Constants
Dcl-C ISNULL -1;
Dcl-C NOTNULL 0;
Dcl-C Null2 X'00';


// API Error Data Structure
Dcl-Ds ApiError;
  AeBytPro int(10) Inz( %size( apierror ));
  AeBytAvl int(10) Inz;
End-Ds;

//-- API error data structure:
dcl-ds ERRC0100 qualified;
  BytPrv int(10) inz( %size( errc0100 ));
  BytAvl int(10);
  MsgId char(7);
  *n char(1);
  MsgDta char(128);
end-ds;

// Global variables
Dcl-S MsgKey Char(4);
Dcl-S entry packed(5);
Dcl-S devds Ind;

// Create User Space Parameter
Dcl-Ds CuUsrSpcQ;
  CuUsrSpcNam Char(10) Inz( 'CFGLST   ' );
  CuUsrSpcLib Char(10) Inz( 'QTEMP ' );
End-Ds;

// API format CFGD0200: List information
Dcl-Ds CfgLst200 based( plstent );
  C2CurStsNam int(10);
  C2CfgDscNam Char(10);
  C2CfgDscCat Char(10);
  C2CurStsTxt Char(20);
  C2TxtDsc Char(50);
  C2JobNam Char(10);
  C2JobUsr Char(10);
  C2JobNbr Char(6);
  C2PasTdev Char(10);
  C2RtvApiNam Char(8);
  C2CfgCmdSfx Char(4);
End-Ds;

// API format CFGD0200: Header information
Dcl-Ds HdrInf based( phdrinf );
  ClCfgTypU Char(10);
  ClObjQualU Char(40);
  ClStsQualU Char(20);
  *n Char(2);
  ClUspNamU Char(10);
  ClUspLibU Char(10);
End-Ds;

// User Space Generic Header
Dcl-Ds UsrSpc based( pusrspc );
  UsOfsHdr int(10) pos( 117 );
  UsOfsLst int(10) pos( 125 );
  UsNumLstEnt int(10) pos( 133 );
  UsSizLstEnt int(10) pos( 137 );
End-Ds;

// Pointers
Dcl-S pUsrSpc pointer Inz( *null );
Dcl-S pHdrInf pointer Inz( *null );
Dcl-S pLstEnt pointer Inz( *null );

// List configuration descriptions
Dcl-Pr LstCfgDsc extpgm( 'QDCLCFGD' );
  *n Char(20) const; // LcSpcNamQ
  *n Char(8) const; // LcFmtNam
  *n Char(10) const; // LcCfgDscTyp
  *n Char(40) const; // LcObjQual
  *n Char(20) const; // LcStsQual
  *n Char(32767) options( *nopass: *varsize ); // LcError
End-Pr;

// Retrieve device description:
dcl-pr RtvDevDsc extpgm( 'QDCRDEVD' );
  RcvVar LikeDs(DEVD1100);
  RcvVarLen int(10) Const;
  FmtNam char(8) Const;
  DevNam char(10) Const;
  Error  likeds(ERRC0100);
End-Pr;

// Device information for *PRT Devices, not all included
dcl-ds DEVD1100 qualified;
  BytRtn    int(10);
  BytAvl    int(10);
  InfRtvDat char(7);
  InfRtvTim char(6);
  DevNam    char(10);
  DevCtg    char(10);
  OnlIpl    char(10);
  TxtDsc    char(50);
  *n        char(3);
  FontId    int(10);
  Port      int(10) pos(  149 );
  DevCls    char(10) pos(  153 );
  DevTyp    char(10) pos(  163 );
  DevMod    char(10) pos(  173 );
  MsgQueNam char(10) pos(  263 );
  MsgQueLib char(10) pos(  273 );
  wsCstNme  char(10) pos(  323 );
  wsCstLib  char(10) pos(  333 );
  htpMdl    char(20) pos(  573 );
  RmtLocNam char(255) pos( 1065 );
  RmtLocTyp char(10) pos( 1331 );
  IpAddr    char(15) pos( 1406 );
  CurMsgCue char(10) pos( 1456 );
  CurMsgLib char(10) pos( 1466 );
  SvrNtwPtc char(1) pos( 1476 );
  SvrNtwPtcAdr char(18) pos( 1477 );
  SvrIpAddr char(15) pos( 1495 );
end-ds;

// Create user space
Dcl-Pr CrtUsrSpc extpgm( 'QUSCRTUS' );
  *n Char(20) const; // CsSpcNamQ
  *n Char(10) const; // CsExtAtr
  *n int(10) const; // CsInzSiz
  *n Char(1) const; // CsInzVal
  *n Char(10) const; // CsPubAut
  //-- Optional 1:
  *n Char(50) const; // CsText
  *n Char(10) const options( *nopass ); // CsReplace
  //-- Optional 2:
  *n Char(32767) options( *nopass: *varsize ); // CsError
  *n Char(10) const options( *nopass ); // CsDomain
End-Pr;

// Retrieve pointer to user space
Dcl-Pr RtvPtrSpc extpgm( 'QUSPTRUS' );
  *n Char(20) const; // RpSpcNamQ
  *n pointer; // RpPointer
  *n Char(32767) options( *nopass: *varsize ); // RpError
End-Pr;

// Delete user space
Dcl-Pr DltUsrSpc extpgm( 'QUSDLTUS' );
  *n Char(20) const; // DsSpcNamQ
  *n Char(32767) options( *varsize ); // DsError
End-Pr;


// Data Structure to read from the outq cursor
dcl-ds outqDta qualified;
  Lib char(10);
  Name char(10);
  Desc char(50);
  htpMfg char(20);
  wsCstLib char(10);
  WsCstNme char(10);
  rmtSysNme char(255);
  PrtQ char(100);
end-ds;


Dcl-Pr LSTPRTT1 ExtPgm('LSTPRTT1');
  // Incoming parameters

  //  Outgoing parameters
  Type  Char(10);
  Lib   char(10);
  Name  char(10);
  Desc  char(50);
  htpMfg char(10);
  wsCstLib char(10);
  wsCstNme char(10);
  rmtSysNme char(256);
  rmtPrtQ char(100);
  devPort packed(5);

  // Null Indicators
  Type_NI  Int(5);
  Lib_NI  Int(5);
  Name_NI  Int(5);
  Desc_NI  Int(5);
  htpMfg_NI  Int(5);
  wsCstLib_NI  Int(5);
  wsCstNme_NI  Int(5);
  rmtSysNme_NI  Int(5);
  rmtPrtQ_NI  Int(5);
  devPort  Int(5);

  // DB2SQL Style Parms
  SQL_State Char(5);
  Function_Name Char(517);
  Specific_Name Char(128);
  Msg_Text Varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
End-Pr;


Dcl-Pr SETNULIND;
  NulInd Int(5) Const;
End-Pr;

Dcl-Pi LSTPRTT1;
  // Incoming parameters

  //  Outgoing parameters
  Type  Char(10);
  Lib   char(10);
  Name  char(10);
  Desc  char(50);
  htpMfg char(10);
  wsCstLib char(10);
  wsCstNme char(10);
  rmtSysNme char(256);
  rmtPrtQ char(100);
  devPort packed(5);

  // Null Indicators
  Type_NI  Int(5);
  Lib_NI  Int(5);
  Name_NI  Int(5);
  Desc_NI  Int(5);
  htpMfg_NI  Int(5);
  wsCstLib_NI  Int(5);
  wsCstNme_NI  Int(5);
  rmtSysNme_NI  Int(5);
  rmtPrtQ_NI  Int(5);
  devPort_NI  Int(5);

  // DB2SQL Style Parms
  SQL_State Char(5);
  Function_Name Char(517);
  Specific_Name Char(128);
  Msg_Text Varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
End-Pi;

Exec SQL
  Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso;

SQL_State=SQLSTATEOK;

Select;
When CallType = UDTF_Open;

  // Create a user space to store the list of *prt Devd's in
  CrtUsrSpc( CuUsrSpcQ : *Blanks : 65535 : x'00' : '*CHANGE' : *Blanks : '*YES' : ApiError );
  // Get a list of device description and store it in the user space
  LstCfgDsc( CuUsrSpcQ : 'CFGD0200' : '*DEVD' : '*PRT     ' : '*GE       *VARYOFF' : ApiError );
  // If there is no error, get a pointer to the user space and get the list, otherwise flag the end of devd's
  If AeBytAvl    = *Zero;
    RtvPtrSpc( CuUsrSpcQ : pUsrSpc);
    pLstEnt     = pUsrSpc + UsOfsLst;
    devds = *on;
  Else;
    devds = *off;
  EndIf;

  // setup a cursor for remote outq's
  Exec SQL
    Declare outqCrs Cursor For
    Select
      coalesce(OUTPUT_QUEUE_LIBRARY_NAME,''),
      coalesce(output_queue_NAME,''),
      coalesce(TEXT_DESCRIPTION,''),
      coalesce(MANUFACTURER_TYPE_AND_MODEL,''),
      coalesce(WORKSTATION_CUSTOMIZING_OBJECT_LIBRARY,''),
      coalesce(WORKSTATION_CUSTOMIZING_OBJECT_NAME,''),
      coalesce(REMOTE_SYSTEM_NAME,''),
      coalesce(REMOTE_PRINTER_QUEUE,'')
    from OUTPUT_QUEUE_INFO
    Where REMOTE_SYSTEM_NAME <> '';

  Exec SQL Open outqCrs;

  EOF = *off;

When CallType=UDTF_Fetch;

  // If there are are devices left, get the next one and send it
  if devds;
    // Retrieve the devd information
    RtvDevDsc( DEVD1100 : %Size( DEVD1100 ) : 'DEVD1100' : C2CfgDscNam : ERRC0100 );
    Type      = '*DEVD';
    Lib       = outqDta.Lib;
    Name      = C2CfgDscNam;
    Desc      = C2TxtDsc;
    htpMfg    = DEVD1100.htpMdl;
    wsCstLib  = DEVD1100.wsCstLib;
    wsCstNme  = DEVD1100.WsCstNme;
    rmtSysNme = DEVD1100.rmtLocNam;
    rmtPrtQ   = '';
    devPort   = DEVD1100.port;
    // move pointer to the next list entry
    entry +=1;
    if Entry =  UsNumLstEnt;
      devds = *off;
    Else;
      pLstEnt = pLstEnt + UsSizLstEnt;
    EndIf;
  // Otherwise get the next outq
  Else;
    Exec SQL Fetch Next From outqCrs Into :outqDta;
    if SQLState >= '02';
      SQL_State    = ENDOFTABLE;
      SETNULIND(Null2);
    Else;
      Type      = '*RMTOUTQ';
      Lib       = outqDta.Lib;
      Name      = outqDta.Name;
      Desc      = outqDta.Desc;
      htpMfg    = outqDta.htpMfg;
      wsCstLib  = outqDta.wsCstLib;
      wsCstNme  = outqDta.WsCstNme;
      rmtSysNme = outqDta.rmtSysNme;
      rmtPrtQ   = outqDta.PrtQ;
      devPort   = 0;
    ENDIF;
  ENDIF;

When CallType = UDTF_Close;

  // Delete the Devd User Space
  DltUsrSpc( CuUsrSpcQ : ApiError);

  // Close the outq cursor
  Exec SQL Close outqCrs;

  *inlr = *on;
EndSl;

Return;


// Process error.
BegSr *PSSR;
  SQL_State=UDTF_ERROR;
  Msg_Text='General Program Error';
  *inlr=*On;
  Return;
EndSr;


//  Set Null Returns
Dcl-Proc SETNULIND;
  Dcl-Pi SETNULIND;
    NulInd Int(5) Const;
  End-Pi;

  Type_NI = NulInd;
  Lib_NI = NulInd;
  Name_NI = NulInd;
  Desc_NI = NulInd;
  htpMfg_NI = NulInd;
  wsCstLib_NI = NulInd;
  wsCstNme_NI = NulInd;
  rmtSysNme_NI = NulInd;
  rmtPrtQ_NI = NulInd;
  devPort_NI = NulInd;


End-Proc;
