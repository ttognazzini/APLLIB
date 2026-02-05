**FREE
ctl-Opt DftActGrp(*no) option(*srcstmt:*nodebugio) ;

// Program Description: Get Field Data for a Message ID
//
// Input Paraeters:
//    Message File Library   Char(10)
//    Message File Name      Char(10)
//    Message ID             Char(7)
//
// Example Call:
//    Select *
//    From Table(APLLIB/MSGDTAT2('QSYS','QCPFMSG','CPF9898'))

dcl-s EOF Ind;
dcl-s Pos Int(5);
dcl-s End Int(5);
dcl-s MsgDta varchar(512);
dcl-s selMsfLib char(10);
dcl-s selMsfNme char(10);
dcl-s selMsgIdn char(7);

//dcl-ds Dct ExtName('DATADICT') Qualified Template end-ds;

//  UDTF call parameter constants
dcl-s UDTF_FirstCall  Int(10) Inz(-2);
dcl-s UDTF_Open Int(10) Inz(-1);
dcl-s UDTF_Fetch Int(10) Inz(0);
dcl-s UDTF_Close Int(10) Inz(1);
dcl-s UDTF_LastCall Int(10) Inz(2);

//  SQL States
dcl-c SQLSTATEOK '00000';
dcl-c ENDOFTABLE '02000';
dcl-c UDTF_ERROR 'US001';
dcl-c Tic x'7D';

// NULL Constants
dcl-c ISNULL -1;
dcl-c NOTNULL 0;
dcl-c NULL X'00';


// System Data Structure
//Copy DEVAPL/QRPGLESRC,D$SDS;
dcl-ds sds PSDS Qualified;
  PgmNme char(10)   Pos(1);
  PgmLib char(10)   Pos(81);
  Job    char(10)   Pos(244);
  Usr    char(10)   Pos(254);
  JobNbr zoned(6:0) Pos(264);
  SrcLib char(10)   Pos(314);
  SrcMbr char(10)   Pos(324);
  CurUsr char(10)   Pos(358);
  NbrPmr *Parms;
  Rtn    *Routine;
  Sts    *Status;
    end-ds;


dcl-pr MSGDTAT1 ExtPgm('MSGDTAT1');
  // Incoming parameters
  pmrMsfLib char(10);
  pmrMsfNme char(10);
  pmrMsgIdn char(7);

  //  Outgoing parameters
  MsfLib char(10);
  MsfNme char(10);
  MsgIdn char(7);
  MsdLne packed(3);
  MsdTyp char(8);
  MsdLen char(5);
  MsdVry packed(5);

  // Null Indicators
  pmrMsfLib_NI Int(5);
  pmrMsfNme_NI Int(5);
  pmrMsgIdn_NI Int(5);
  MsfLib_NI Int(5);
  MsfNme_NI Int(5);
  MsgIdn_NI Int(5);
  MsgLne_NI Int(5);
  MsdTyp_NI Int(5);
  MsdLen_NI Int(5);
  MsdVry_NI Int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
  end-pr;


dcl-pr SETNULIND;
  NulInd Int(5) Const;
  end-pr;

dcl-pi MSGDTAT1;
  // Incoming parameters
  pmrMsfLib char(10);
  pmrMsfNme char(10);
  pmrMsgIdn char(7);

  //  Outgoing parameters
  MsfLib char(10);
  MsfNme char(10);
  MsgIdn char(7);
  MsdLne packed(3);
  MsdTyp char(8);
  MsdLen char(5);
  MsdVry packed(5);

  // Null Indicators
  pmrMsfLib_NI Int(5);
  pmrMsfNme_NI Int(5);
  pmrMsgIdn_NI Int(5);
  MsfLib_NI Int(5);
  MsfNme_NI Int(5);
  MsgIdn_NI Int(5);
  MsgLne_NI Int(5);
  MsdTyp_NI Int(5);
  MsdLen_NI Int(5);
  MsdVry_NI Int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
  end-pi;

Exec SQL
  Set Option Commit    = *none,
             CloSQLCsr = *endactgrp,
             UsrPrf    = *owner,
             DynUsrPrf = *owner,
             DatFmt    = *iso;

SQL_State=SQLSTATEOK;

Select;
When CallType = UDTF_Open;

  EOF = *off;
  selMsfLib = pmrMsfLib;
  selMsfNme = pmrMsfNme;
  selMsgIdn = pmrMsgIdn;

  Exec SQL
    Select trim(char(Message_Data))
    Into :MsgDta
    From Msgf_data
    Where (Msgf_Lib, MsgF, Message_ID) = (:selMsfLib, :selMsfNme, :selMsgIdn)
    Fetch First Row Only;

  Pos = %scan('&':MsgDta:1);

When CallType=UDTF_Fetch;

  If Pos = *zeros or Pos >= %len(%trim(MsgDta));
     SQL_State    = ENDOFTABLE;
     SETNULIND(NULL);
  Else;
      Clear MsdLne;
      Clear MsdTyp;
      Clear MsdLen;
      Clear MsdVry;
      MsfLib = selMsfLib;
      MsfNme = selMsfNme;
      MsgIdn = selMsgIdn;
    Monitor;
      End = %scan(' ':MsgDta:Pos);
      MsdLne = %uns(%subst(MsgDta:Pos + 1: End - Pos - 1));

      Pos = %check(' ':MsgDta:End);
      End = %scan(' ':MsgDta:Pos);
      If Pos > End;
         End = %len(%trim(MsgDta)) + 1;
      EndIf;
      MsdTyp = %subst(MsgDta:Pos: End - Pos);

      Pos = %check(' ':MsgDta:End);
      End = %scan(' ':MsgDta:Pos);
      If Pos > End;
         End = %len(%trim(MsgDta)) + 1;
      EndIf;
      MsdLen = %subst(MsgDta:Pos: End - Pos );

      Pos = %check(' ':MsgDta:End);
      End = %scan(' ':MsgDta:Pos);
      If Pos > End;
         End = %len(%trim(MsgDta)) + 1;
      EndIf;
      If %subst(MsgDta:Pos:1) = '&';
         Return;
      Else;
         MsdVry = %uns(%subst(MsgDta:Pos: End - Pos));
         Pos = %scan('&':MsgDta:End);
      ENDIF;

    On-Error;
       Clear Pos;
    EndMon;
  EndIf;

When CallType = UDTF_Close;

   *inlr = *on;
EndSl;

Return;
// ------------------------------------------------
// Process error.
BegSr *PSSR;
    SQL_State=UDTF_ERROR;
    Msg_Text='General Program Error';
    *inlr=*On;
    Return;
EndSr;
//-------------------------------------------------------------------------
//  Set Null Returns
//-------------------------------------------------------------------------
dcl-proc SETNULIND;
dcl-pi SETNULIND;
  NulInd Int(5) Const;
  end-pi;

    pmrMsfLib_NI  = NulInd;
    pmrMsfNme_NI  = NulInd;
    pmrMsgIdn_NI  = NulInd;
    MsfLib_NI  = NulInd;
    MsfNme_NI  = NulInd;
    MsgIdn_NI  = NulInd;
    MsgLne_NI  = NulInd;
    MsdTyp_NI  = NulInd;
    MsdLen_NI  = NulInd;
    MsdVry_NI  = NulInd;
end-proc SETNULIND;
