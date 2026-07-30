**FREE
/copy APLLIB/QSRC,$CTLOPT

// List Help variables for a program

// To call example:
//    Select * From Table(PGMHLPT1('INVINQD2','INVINQF2','APLLIB')) as x

/copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

//  User Defined Table Function (UDTF) call parameter constants
Dcl-C UDTF_FIRSTCALL -2;
Dcl-C UDTF_OPEN -1;
Dcl-C UDTF_FETCH 0;
Dcl-C UDTF_CLOSE 1;
Dcl-C UDTF_LASTCALL 2;

//  SQL States
Dcl-C SQLSTATEOK '00000';
Dcl-C ENDOFTABLE '02000';
Dcl-C UDTF_ERROR 'US001';

// NULL Constants
Dcl-C ISNULL -1;
Dcl-C NOTNULL 0;

Exec SQL Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso;

//  Used for SQL Fetch
Dcl-Ds dta qualified;
  Key    Char(20);
  fldRow Packed(3);
  fldCol Packed(3);
  fldNme Char(10);
  val    Char(10);
  hlpTypD Char(20);
  lneCnt Packed(5);
  txt    Char(25);
  refFle Char(10);
  refFld Char(10);
  fldDes Char(22);
End-Ds;

Dcl-Pi PGMHLPT1;
  // Incoming parameters
  pmrPgmNme Char(10);
  pmrDspFle Char(10);
  pmrLib Char(10);

  //  Outgoing parameters
  Key    Char(20);
  fldRow Packed(3);
  fldCol Packed(3);
  fldNme Char(10);
  val    Char(10);
  hlpTypD Char(20);
  lneCnt Packed(5);
  txt    Char(25);
  refFle Char(10);
  refFld Char(10);
  fldDes Char(22);

  // Null Indicators
  pmrPgmNme_ni int(5);
  pmrDspFle_ni int(5);
  pmrLib_ni int(5);
  Key_ni int(5);
  fldRow_ni int(5);
  fldCol_ni int(5);
  fldNme_ni int(5);
  val_ni int(5);
  hlpTypD_ni int(5);
  lneCnt_ni int(5);
  txt_ni int(5);
  refFle_ni int(5);
  refFld_ni int(5);
  fldDes_ni int(5);

  // DB2SQL Style Parms
  SQL_State char(5);
  Function_Name char(517);
  Specific_Name char(128);
  Msg_Text varchar(70);

  //  UDTF CallType flag parm  (Open,Fetch,Close)
  callType Int(10);
End-Pi;

SQL_State=SQLSTATEOK;

Select;
  When callType = UDTF_OPEN;

    // delcare and open cursor
  Exec SQL Declare SQLCrs Cursor for
  With
    -- default one line for the screen header
    header(Key,fldRow,fldCol,fldNme,val,hlpTypD,refFle,refFld) as (
      Values('',0,0,'','','Screen Header','','')
    ),
    -- pull every field except FNCKEYS and OPTIONS, they are added below so each option/key has thier own text
    -- also exclude position to fields in a SFLCTL record, those are added under the column name
    -- does a summary becasue a screen have multiple views
    UniqueFields as (
      SELECT
        scrLoc.fldNme concat '          ' KEY,
        min(fldrow) fldRow,
        min(fldcol) fldCol,
        SCRLOC.fldNme fldNme,
        '          ' val,
        'Screen Field' as hlpTypD,
        max(refFle) refFle,
        max(refFld) refFld
      From SCRLOC
      where mbr = :pmrDspFle
        and lib = :pmrLib
        and fldCol <> 0
        and SCRLOC.fldNme not in ('OPTIONS','FNCKEYS','SEL','SEL1')
        -- the following logic removes position to fields for the SLF it used to just
        -- check if the field ended in a 1 but that crashed when an address line 1 field was
        -- added to the SFL control record. Now it excludes fields that are in the SFL and
        -- have a 1 appended to them.
        and not ( SCRLOC.rcdFmtTyp='SFLCTL' and SCRLOC.fldNme in
          ( Select trim(fldNme) || '1'
            FROM SCRLOC
            where rcdFmtTyp = 'SFL'
              and mbr = :pmrDspFle
              and lib = :pmrLib
              and fldCol <> 0) )
      group by SCRLOC.fldNme
    ),
    -- get SFL options from PGMOPT
    options as (
      SELECT
        'OPTIONS   ' concat char(opt) key,
        min(fldrow) as fldRow,
        min(fldcol) as fldCol,
        'OPTIONS' fldnme,
        char(opt) val,
        'Screen SFL Option' hlpTypD,
        '' Reffle,
        '' RefFld
      FROM PGMOPT
      join scrloc on LIB=:pmrLib AND MBR=:pmrDspFle and SCRLOC.fldNme = 'OPTIONS'
      where PGMNME = :pmrPgmNme
        and PGMOPT.acvRow = '1'
      group by OPT
    ),
    -- get function keys from PGMFNC
    fnckeys as (
      SELECT
        'FNCKEYS   '  concat fncKey key,
        min(fldrow) as fldRow,
        min(fldcol) as fldCol,
        'FNCKEYS' fldnme,
        fnckey val,
        'Screen Function Key' hlpTypD,
        '' Reffle,
        '' RefFld
      FROM PGMFNC
      join scrloc on LIB=:pmrLib AND MBR=:pmrDspFle and SCRLOC.fldNme = 'FNCKEYS'
      where PGMNME = :pmrPgmNme and PGMFNC.acvRow = '1'
      group by fnckey
    )

  SELECT
    SL.KEY,
    SL.fldRow,
    SL.fldCol,
    SL.fldNme,
    SL.val,
    SL.hlpTypD,
    case
      -- pull count from referenced field where referenced field is in this file
      when coalesce(ms.hlpRef,'') <> '' and coalesce(RM.lneCnt,0) <> 0 then coalesce(RM.lneCnt,0)
      -- pull count from referenced field where referenced is found in the dictionary
      when coalesce(ms.hlpRef,'') <> '' and refFld <> '' and coalesce(RD.lneCnt,0) <> 0 then coalesce(RD.lneCnt,0)
      -- pull count from referenced field where referenced is found in a system default
      when coalesce(ms.hlpRef,'') <> '' and coalesce(RS.lneCnt,0) <> 0 then coalesce(RS.lneCnt,0)
      -- pull 0 if a referenced field is entered and not found
      When coalesce(ms.hlpRef,'') <> '' then 0
      -- pull line count if entered directly
      when coalesce(ms.lneCnt,0) <> 0 then coalesce(ms.lneCnt,0)
      -- pull line count if from the dictionary
      when coalesce(Dt.lneCnt,0) <> 0 then coalesce(Dt.lneCnt,0)
      -- pull line count if from a system default
      when coalesce(sy.lneCnt,0) <> 0 then coalesce(sy.lneCnt,0)
      else 0 end lneCnt,
    case
      when coalesce(ms.hlpRef,'') <> '' and coalesce(RM.lneCnt,0) <> 0
        then 'Ref: ' concat trim(ms.hlpRef) concat ' Local'
      when coalesce(ms.hlpRef,'') <> '' and refFld <> '' and coalesce(RD.lneCnt,0) <> 0
        then 'Ref: ' concat trim(ms.hlpRef) concat ' Dictionary'
      when coalesce(ms.hlpRef,'') <> ''  and coalesce(RS.lneCnt,0) <> 0
        then 'Ref: ' concat trim(ms.hlpRef) concat ' System Default'
      When coalesce(ms.hlpRef,'') <> '' then 'Ref: ' concat trim(ms.hlpRef)
      when coalesce(ms.lneCnt,0) <> 0 then 'Locally Defined'
      when coalesce(Dt.lneCnt,0) <> 0 then 'Dictionary '
      when coalesce(sy.lneCnt,0) <> 0 then 'System Default'
      else 'Not Defined' end txt,
      refFle,
      refFld,
    case
      when coalesce(ms.hlpRef,'') <> '' and coalesce(RM.lneCnt,0) <> 0 then coalesce(RM.Des,'')
      when coalesce(ms.hlpRef,'') <> '' and refFld <> '' and coalesce(RD.lneCnt,0) <> 0 then coalesce(RD.Des,'')
      when coalesce(ms.hlpRef,'') <> '' and coalesce(RS.lneCnt,0) <> 0 then coalesce(RS.Des,'')
      When coalesce(ms.hlpRef,'') <> '' then ''
      when coalesce(ms.lneCnt,0)  <> 0  then coalesce(ms.Des,'')
      when coalesce(Dt.lneCnt,0)  <> 0  then coalesce(Dt.Des,'')
      when coalesce(sy.lneCnt,0)  <> 0  then coalesce(sy.Des,'')
      else '' end FldDes
  From (
    select * from header
    union select * from uniquefields
    union select * from options
    union select * from fnckeys) SL
  left join hlpMst as Ms on (Ms.DctNme,Ms.fldNme,Ms.dspFle,Ms.val) = ('', SL.fldNme, :pmrDspFle, SL.val)
  left join hlpMst as RM on (RM.DctNme,RM.fldNme,RM.dspFle,RM.val) = ('', Ms.hlpRef, :pmrDspFle, SL.val)
  left join hlpMst as RD on (RD.DctNme,RD.fldNme,RD.dspFle,RD.val) = (reffle, Ms.hlpref, '', SL.val)
  left join hlpMst as RS on (RS.DctNme,RS.fldNme,RS.dspFle,RS.val) = ('', Ms.hlpRef, '', SL.val)
  left join hlpMst as Dt on (Dt.DctNme,Dt.fldNme,Dt.dspFle,Dt.val) = (refFle, refFld, '', SL.val)
  left join hlpMst as Sy on (Sy.DctNme,Sy.fldNme,Sy.dspFle,Sy.val) = ('', SL.fldNme, '', SL.val);

    Exec SQL Open SQLCrs;

  When callType=UDTF_FETCH;

    Exec SQL Fetch Next from SQLCrs into :dta;

    If SqlState >= '02';
      SetNulInd(ISNULL);
      SQL_State = ENDOFTABLE;
    Else;
      Key    = dta.Key;
      fldRow = dta.fldRow;
      fldCol = dta.fldCol;
      fldNme = dta.fldNme;
      val    = dta.val;
      hlpTypD = dta.hlpTypD;
      lneCnt = dta.lneCnt;
      txt    = dta.txt;
      refFle = dta.refFle;
      refFld = dta.refFld;
      fldDes = dta.fldDes;
    EndIf;

  When callType = UDTF_CLOSE;
    Exec SQL Close SQLCrs;
    *inlr=*on;
EndSl;

Return;


//  Set Null Returns
Dcl-Proc SetNulInd;
  Dcl-Pi SetNulInd;
    nulInd Int(5) Const;
  End-Pi;

  pmrPgmNme_ni = nulInd;
  pmrDspFle_ni = nulInd;
  pmrLib_ni = nulInd;
  Key_ni = nulInd;
  fldRow_ni = nulInd;
  fldCol_ni = nulInd;
  fldNme_ni = nulInd;
  val_ni = nulInd;
  hlpTypD_ni = nulInd;
  lneCnt_ni = nulInd;
  txt_ni = nulInd;
  refFle_ni = nulInd;
  refFld_ni = nulInd;
  fldDes_ni = nulInd;

End-Proc;
