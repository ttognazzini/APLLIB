**FREE
Ctl-Opt debug option(*srcstmt:*nodebugio) dftactgrp(*no);
// ----------------------------------------------------------------------*
//                                                                      *
// Program Name:        LSTCOLT1                                        *
// Program Description: List Columns for SQL Build
//                      Table Update Process                            *
// To create SQL Function:                                              *
// CRTPGM PGM(APLLIB/LSTCOLT1)
//
// Call LSTCOLT1FN
//                                                                      *
// To call example:                                                     *
//    Select * From Table(APL/LSTCOLT1('HDWHD',                         *
//                                     'CUSORDDW',                      *
//                                     60,                              *
//                                     ':ord.')) as x                   *
//                                                                      *
// -----------------------------------------------------------------------*
// Program Modification Log  (Reverse Chronological Order, Please!)      *
//  ------------------------                                             *
//                                                                       *
//  Date   Programmer Tkt Id  Summary of Modification                    *
// -------- ---------- ------- ----------------------------------------- *
// 09/19/17 Mark Mays          Initial Creation                          *
// -----------------------------------------------------------------------*

Dcl-S EOF Ind;
Dcl-S FldCur char(120);
Dcl-S FldNxt char(20);

// dcl-ds Dct ExtName('DATADICT') Qualified Template end-ds;

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
Dcl-C TIC x'7D';

// NULL Constants
Dcl-C ISNULL -1;
Dcl-C NOTNULL 0;
Dcl-C NULL X'00';


// System Data Structure
// Copy APLLIB/QRPGLESRC,D$SDS;
Dcl-Ds sds PSDS Qualified;
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
End-Ds;


Dcl-Pr LSTCOLT1 ExtPgm('LSTCOLT1');
  // Incoming parameters
  Lib varchar(10);
  Tbl varchar(10);
  Len packed(5:0);
  Pfx varchar(10);

  //  Outgoing parameters
  Fld char(120);

  // Null Indicators
  Lib_NI Int(5);
  Tbl_NI Int(5);
  Len_NI Int(5);
  Pfx_NI Int(5);
  Fld_NI Int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
End-Pr;


Dcl-Pi LSTCOLT1;
  // Incoming parameters
  Lib varchar(10);
  Tbl varchar(10);
  Len packed(5:0);
  Pfx varchar(10);

  //  Outgoing parameters
  Fld char(120);

  // Null Indicators
  Lib_NI Int(5);
  Tbl_NI Int(5);
  Len_NI Int(5);
  Pfx_NI Int(5);
  Fld_NI Int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  CallType Int(10);
End-Pi;

Exec SQL
  Set Option Commit    = *none,
             CloSQLCsr = *endactgrp,
             UsrPrf    = *owner,
             DynUsrPrf = *owner,
             DatFmt    = *iso;

SQL_State=SQLSTATEOK;

Select;
  When CallType = UDTF_Open;

    Exec SQL
    Declare FLDS Cursor For
    Select trim(:Pfx) || trim(System_Column_Name)
    From SYSCOLUMNS
    Where Table_Schema = ucase(:Lib)
      and Table_Name   = ucase(:Tbl)
    Order By Ordinal_Position;
    // Select trim(:Pfx) || dbiFld
    // From QADBIFLD
    // Where DbiLib = ucase(:Lib)
    //   and dbiFil = ucase(:Tbl)
    // Order By dbiPos;

    Exec SQL Open FLDS;

    FldNxt = '(';
    EOF = *off;

  When CallType=UDTF_Fetch;

    If FldNxt = *blanks;
      SQL_State    = ENDOFTABLE;
      SETNULIND(NULL);
    Else;
      FldCur = FldNxt;
      DoU EOF;
        Exec SQL
        Fetch Next From FLDS Into :FldNxt;

        If SQLState > '02';
          SETNULIND(NOTNULL);
          Fld = %trim(FldCur) + ')';
          Clear FldNxt;
          Leave;
        ElseIf %len(%trim(FldCur)+ ',' + %trim(FldNxt)) > Len - 1;
          Fld = %trim(FldCur) + ',';
          Clear FldCur;
          SETNULIND(NOTNULL);
          Leave;
        ElseIf FldCur = '(';
          SETNULIND(NOTNULL);
          FldCur = '(' + FldNxt;
          Iter;
        Else;
          FldCur = %trim(FldCur) + ',' + FldNxt;
          SETNULIND(NOTNULL);
          Iter;
        EndIf;
      EndDo;
    EndIf;


  When CallType = UDTF_Close;
    Exec SQL Close FLDS;
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
// -------------------------------------------------------------------------
//  Set Null Returns
// -------------------------------------------------------------------------
Dcl-Proc SETNULIND;
  Dcl-Pi SETNULIND;
    NulInd Int(5) Const;
  End-Pi;

  Lib_NI  = NulInd;
  Tbl_NI  = NulInd;
  Len_NI  = NulInd;
  Pfx_NI  = NulInd;
  Fld_NI  = NulInd;
End-Proc SETNULIND;
