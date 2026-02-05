**FREE
ctl-Opt DftActGrp(*no) option(*srcstmt:*nodebugio) ;
//----------------------------------------------------------------------*
//                                                                      *
// Program Name:        MSGDTAT1                                        *
// Program Description: Parse the Message Data from the Message File
//                                                                      *
// To create SQL Function:                                              *
// CRTPGM PGM(APLLIB/MSGDTAT1)
//
// Call MSGDTAT1FN
//                                                                      *
// To call example:                                                     *
//    Select * From Table(APLLIB/MSGDTAT1('&1 *char 1024')) as d        *
//                                                                      *
//                                                                       *
//-----------------------------------------------------------------------*

dcl-s EOF Ind;
dcl-s Dta char(512);
dcl-s Pos Int(5);
dcl-s End Int(5);

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
  MsgDta varchar(512);

  //  Outgoing parameters
  MsdLne packed(3);
  MsdTyp char(8);
  MsdLen char(5);
  MsdVry packed(5);

  // Null Indicators
  MsgDta_NI Int(5);
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
  MsgDta varchar(512);

  //  Outgoing parameters
  MsdLne packed(3);
  MsdTyp char(8);
  MsdLen char(5);
  MsdVry packed(5);

  // Null Indicators
  MsgDta_NI Int(5);
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
  Dta = MsgDta;
  Pos = %scan('&':Dta:1);

When CallType=UDTF_Fetch;

  If Pos = *zeros or Pos >= %len(%trim(MsgDta));
     SQL_State    = ENDOFTABLE;
     SETNULIND(NULL);
  Else;
      Clear MsdLne;
      Clear MsdTyp;
      Clear MsdLen;
      Clear MsdVry;
    Monitor;
      End = %scan(' ':Dta:Pos);
      MsdLne = %uns(%subst(Dta:Pos + 1: End - Pos - 1));

      Pos = %check(' ':Dta:End);
      End = %scan(' ':Dta:Pos);
      MsdTyp = %subst(Dta:Pos: End - Pos);

      Pos = %check(' ':Dta:End);
      End = %scan(' ':Dta:Pos);
      MsdLen = %subst(Dta:Pos: End - Pos );

      Pos = %check(' ':Dta:End);
      End = %scan(' ':Dta:Pos);
      If %subst(Dta:Pos:1) = '&';
         Return;
      Else;
         MsdVry = %uns(%subst(Dta:Pos: End - Pos));
         Pos = %scan('&':Dta:End);
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

    MsgDta_NI  = NulInd;
    MsgLne_NI  = NulInd;
    MsdTyp_NI  = NulInd;
    MsdLen_NI  = NulInd;
    MsdVry_NI  = NulInd;
end-proc SETNULIND;
