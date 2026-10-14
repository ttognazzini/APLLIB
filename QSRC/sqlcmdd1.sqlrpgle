**free
Ctl-Opt Option(*SrcStmt) srtseq(*langidshr) DftActGrp(*No) BndDir('APLLIB') actgrp(*new);

// SQL Query Manager

Dcl-F SQLCMDF1 workstn sfile(F1S:RRNF1) sfile(F2S:RRNF2) sfile(F4S:RRNF4)
sfile(F5S:RRNF5) sfile(F10S:RRNF10) sfile(F11S:RRNF11) sfile(F12S:RRNF12)
sfile(F13S:RRNF13) sfile(F15S:RRNF15) sfile(F20S:RRNF20) infds(SCRDS)
usropn;

Dcl-F SQLLSTPF keyed usage(*update: *delete: *output);
Dcl-F SQLDETPF keyed usage(*update: *delete: *output);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command

Dcl-Ds FILDS;
  fleNme char(10);
  fleLib char(10);
  fleDes char(50);
End-Ds;
Dcl-S EOF ind;
Dcl-S First ind;
Dcl-S WORDS Char(100) dim(50);
Dcl-Ds SQLLSTDS extname('SQLLSTPF') End-Ds;
Dcl-Ds SQLLSTSV extname('SQLLSTPF') prefix('SV_':3) End-Ds;

Dcl-Ds LINESDS;
  LINES Char(78) dim(1000);
End-Ds;

Dcl-Ds SVLINESDS;
  SVLINES Char(78) dim(1000);
End-Ds;

Dcl-Ds cols LikeDs(#$SQLColumns);

Dcl-S i Int(5);
Dcl-S x Int(5);
Dcl-S y Int(5);
Dcl-S tempLine Varchar(120);
Dcl-S Default Varchar(32);
Dcl-S var Varchar(11);
Dcl-S sqlStm Varchar(3000);
Dcl-S SQLSTMF1 Varchar(3000);
Dcl-S SQLSTMF12 Varchar(3000);
Dcl-S SQLSTMF13 Varchar(3000);
Dcl-S SQLSTMP Varchar(5000);
Dcl-S SQLSTMP2 Varchar(5000);
Dcl-S cmd Varchar(32000);
Dcl-S xF1 Int(5);
Dcl-S xF4 Int(5);
Dcl-S xF10 Int(5);
Dcl-S xF11 Int(5);
Dcl-S xF12 Int(5);
Dcl-S xF13 Int(5);
Dcl-S xF15 Int(5);
Dcl-S xF20 Int(5);
Dcl-S tpEmail Char(50);
Dcl-S F1Sort packed(1);
Dcl-S RRNF1 packed(4);
Dcl-S RRNF2 packed(4);
Dcl-S RRNF4 packed(4);
Dcl-S RRNF5 packed(4);
Dcl-S RRNF10 packed(4);
Dcl-S RRNF11 packed(4);
Dcl-S RRNF12 packed(4);
Dcl-S RRNF13 packed(4);
Dcl-S RRNF15 packed(4);
Dcl-S RRNF20 packed(4);
Dcl-S NumRcF1 packed(5);
Dcl-S NumRcF2 packed(5);
Dcl-S NumRcF4 packed(5);
Dcl-S NumRcF5 packed(5);
Dcl-S NumRcF10 packed(5);
Dcl-S NumRcF11 packed(5);
Dcl-S NumRcF12 packed(5);
Dcl-S NumRcF13 packed(5);
Dcl-S NumRcF15 packed(5);
Dcl-S NumRcF20 packed(5);
Dcl-S againF1 Char(1);
Dcl-S againF2 Char(1);
Dcl-S againF4 Char(1);
Dcl-S againF5 Char(1);
Dcl-S againF10 Char(1);
Dcl-S againF11 Char(1);
Dcl-S againF12 Char(1);
Dcl-S againF19 Char(1);
Dcl-S F15Show Char(1);
Dcl-S tpType Char(4);
Dcl-S Temp31 Char(31);
Dcl-S Temp10 Char(10);
Dcl-S Len Packed(3);
Dcl-S Dec Packed(3);
Dcl-S Row Packed(3);
Dcl-S Col Packed(3);
Dcl-S cpi Packed(3);
Dcl-S tpLib Char(10);
Dcl-S tpFile Char(10);
Dcl-S crLib Char(10);
Dcl-S crFile Char(10);
Dcl-S lnFile Char(10);
Dcl-S lnLib Char(10);
Dcl-S F12File2 Char(10);
Dcl-S F12Lib2 Char(10);
Dcl-S temp21 Char(21);
Dcl-S temp50 packed(5);
Dcl-S FILECNT packed(5);
Dcl-S strPos packed(5);
Dcl-S endPos packed(5);
Dcl-S CsrPos Packed(4);
Dcl-S Emails Char(2048);
Dcl-S message Varchar(5000);
Dcl-S objPath Char(128);
Dcl-S Where Char(5);
Dcl-S CurLast packed(5);
Dcl-S version packed(5);
Dcl-S Sf12Len2 packed(6);
Dcl-S prvWrd Char(10);
Dcl-S F21FileNo Char(65);
Dcl-S F21Extn Char(5);
Dcl-S F21Path Char(132);
Dcl-S Break Char(4);
Dcl-S ifsFile Char(256);
Dcl-S srcDta Char(250);

Dcl-S FILES Char(10) dim(50);
Dcl-S LIBS Char(10) dim(50);
Dcl-S FILDSC Char(60) dim(50);

// the following two structures are used to control the
// cursor location on a screen
Dcl-Ds SCRDS len(512);
  #$ROW Char(1) pos(370);
  #$COL Char(1) pos(371);
End-Ds;
Dcl-Ds *n Inz;
  #$BINC Char(1) pos(2);
  #$BIN2 int(5) pos(1);
End-Ds;

Dcl-S #$VARS Char(500);
Dcl-S #$OUTQ Char(10);
Dcl-S #$OQLB Char(10);
Dcl-S #$COPY packed(3);
Dcl-S #$HOLD Char(5);
Dcl-S #$SAVE Char(5);
Dcl-S #$USDT Char(10);
Dcl-S #$FRLN packed(3);
Dcl-S #$FRWD packed(3);
Dcl-S #$INVR Char(4);
Dcl-S #$INQY Char(4);
Dcl-S #$TITLE1 Char(80);
Dcl-S #$TITLE2 Char(80);
Dcl-S #$TITLE3 Char(80);
Dcl-S #$TITLE4 Char(80);
Dcl-S #$TITLE5 Char(80);
Dcl-S #$PNAME Char(10);

// Program Entry Parameters
Dcl-Pi SQLCMDD1;
  psName Char(5000);
  psActn Char(10);
  psUser Char(10);
  psQryDfn likeDs(qryDfnDS);
  psEMls likeDs(emlsDs);
  psFile Char(123);
  psType Char(5);
  psSheet Char(32);
  psTitle1 Char(80);
  psTitle2 Char(80);
  psTitle3 Char(80);
  psTitle4 Char(80);
  psTitle5 Char(80);
  psSubject Char(128);
  psMess likeDs(messDs);
  psObjects likeDs(objectsDs);
  psInVr Char(4);
  psRpId Char(10);
  psIfsFl Char(123);
  psIfsF Char(123);
  psIfsT Char(5);
  psOutQ likeDs(outQDS);
  psCopy packed(3);
  psHold Char(4);
  psSave Char(4);
  psUsDt Char(10);
  psFrWd packed(3);
  psFrLn packed(3);
  psPInVr Char(4);
  psPInQy Char(4);
  psPName Char(10);
  psOutF likeDs(outFDS);
  psVrIn LikeDs(vrInDs);
  psQueries likeDs(queriesDs);
End-Pi;

// this option turns off commitment control
Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;

psEMLCNT = psEMls.EMLCNTTM;
psEM     = psEMls.EMTM;

// the objects parameter is passed with a 5i field followed by
// an array of 6 bytes for each element, then the data
// we have to trim off the First part to get the real data
If psObjects.count>0;
  For i=1 To psObjects.count;
    objects(i)=%subst(%subst(psObjects.data:(psObjects.count*2)+1:9000):(i-1)*140+1:140);
  EndFor;
EndIf;

// The variable overide parameter is passed with a 5i field followed by
// an array of 6 bytes for each element, then the data
// we have to trim off the First part to get the real data
If psVrIn.count>0;
  For i=1 To psVrIn.Count;
    vr(i)=%subst(%subst(psVrIn.data:(psVrIn.Count*2)+1:500):(i-1)*42+1:42);
  EndFor;
EndIf;

// the queries parameter is passed with a 5i field followed by
// an array of 6 bytes for each element, then the data
// we have to trim off the First part to get the real data
If psQueries.count>0;
  For i=1 To psQueries.count;
    queries(psQueries.count-i+1)=%subst(psQueries.data:((i-1)*5432)+1+(psQueries.count*2)+(i*2)
                                        :5432);
  EndFor;
EndIf;

// If the message is left *dft them only one value is passed, this messes up the pointer for
// the next field. To handle this we only use psMess.Type if 2 values are passed, we use messageType
// to hold the default value if nothing is passed.
If psMess.count>=2;
  messageType=psMess.type;
Else;
  messageType='*TEXTPLAIN';
EndIf;

If psUser='*CURRENT' or psUser=' ';
  psUser=User;
EndIf;

// if a query definition is passed, convert it to psname and process
// it like a passed query
If psName='*QRYDFN';
  PROCQRYDFN();
EndIf;

// valdiate entry parameters
VALDPARM();
If *inlr;
  Return;
EndIf;

// perform the passed option if it is a batch option so the screen
// is not opened
If psActn='*PRINT';
  PROCPRINT();

ElseIf psActn='*EMAIL' and PSTYPE<>'*PDF';
  PROCEMAIL();

ElseIf psActn='*EMAIL' and psType='*PDF';
  PROCEMAILPDF();

ElseIf psActn='*OUTFILE';
  PROCOUTF();

ElseIf psActn='*IFSFILE' and PSIFST<>'*PDF'
and PSIFST<>'*JSON';
  PROCIFS();

ElseIf psActn='*IFSFILE' and psIfsT='*PDF';
  PROCIFSPDF();

ElseIf psActn='*IFSFILE' and psIfsT='*JSON';
  PROCIFSJSON();
EndIf;

// if this is a batch job send an error if a prompted option is
If #$INTACT()<>'I';
  #$SndMsg('Error - this option cannot be run in batch.');
  *INLR = *ON;
  Return;
EndIf;

// open the display file
Open SQLCMDF1;

// process non batch options after the screen file is opened
If psActn='*VIEW';
  SF1Name=psName;
  Sf1Enus=psUser;
  PROCF2();

ElseIf psActn='*EDIT';
  SF1Name=psName;
  Sf1Enus=psUser;
  PROCF3();

ElseIf psActn='*DISPLAY';
  PROCDISPLAY();

ElseIf psActn='*ADHOC' and psName<>' ';
  If %len(%trim(psName))<=10;
    LINES(1)='SELECT *';
    LINES(2)='FROM ' + %trim(psName);
  Else;
    Lines=#$FormatSQL(psName);
  EndIf;
  PROCF10();

Else;
  PROCF1();
EndIf;

Close SQLCMDF1;
*INLR = *ON;
Return;


// validate entry parameters
Dcl-Proc VALDPARM;

  // if psname is longer than 10 characters it must be an sql
  // statement, so variable overrides are not allowed,
  // the option to view or edit is not allowed either
  // and the query must be valid if not action *adhoc
  If %len(%trim(psName))>10;
    If psVrIn.Count<>0;
      #$SndMsg('Error - Cannot use variable overrides with passed query.');
      *INLR = *ON;
      Return;
    EndIf;
    If psActn='*VIEW';
      #$SndMsg('Error - Cannot view a definition with passed query.');
      *INLR = *ON;
      Return;
    EndIf;
    If psActn='*EDIT';
      #$SndMsg('Error - Cannot edit a definition with passed query.');
      *INLR = *ON;
      Return;
    EndIf;
    // make sure the passed query is valid
    If PSACTN<>'*ADHOC';
      Monitor;
        Exec SQL prepare sqlStm from :psName;
        #$SQLSTT();
      On-Error;
        #$SndMsg(PSDSEXCDTA);
        #$SndMsg('Error - invalid passed query, must be a select query.');
        EVAL *INLR = *ON;
        Return;
      EndMon;
    EndIf;
  EndIf;

  // if *view or *edit, make sure a valid query name is passed
  If psActn='*VIEW' or psActn='*EDIT';
    SF1Name=psName;
    Sf1Enus=psUser;
    Chain (SF1ENUS:SF1NAME) SQLLSTPF;
    If not %found;
      #$SndMsg('Error - query name not found.');
      *INLR = *ON;
      Return;
    EndIf;
  EndIf;

  // if a query name is passed validate the variable overrides
  If %len(%trim(psName))<=10
  and PSACTN<>'*ADHOC';
    SF1Name=psName;
    Sf1Enus=psUser;
    Chain (SF1ENUS:SF1NAME) SQLLSTPF;
    If not %found;
      #$SndMsg('Error - query name not found.');
      *INLR = *ON;
      Return;
    EndIf;
    LOADLINES();
    VarDs=SQLVars;

    // test that variable overrides exists and are the correct type
    // also override the varaible name if found and valid
    If psVrIn.Count>0;
      For i=1 To psVrIn.Count;
        If vr(i).var<>' ' and vr(i).value<>' ';
          *IN50 = *ON;
          For x=1 To 10;
            *IN50 = *OFF;
            If VRNAME(x)=#$Upify(vr(i).var);
              If VRTYPE(x)='1' and
                not #$TESTN(%trim(vr(i).value));
                #$SndMsg('Error - Value for variable '+%trim(vr(i).var)+
                         ' must be numeric.' );
                *INLR = *ON;
                Return;
              ElseIf VRTYPE(x)='2' and #$RVL(VRLEN(x))<>0 and
                %len(%trim(vr(i).value))>#$RVL(VRLEN(x));
                #$SndMsg('ERROR - VALUE For VARIABLE '+
                %trim(vr(i).var)+' MUST BE LESS THAN +
                  or EQUAL To ' + %trim(VRLEN(x)) +
                    ' CHARACTERS LONG.');
                *INLR = *ON;
                Return;
              ElseIf VRTYPE(x)='3' and
                #$VDAT(#$RVL(%trim(vr(i).value)));
                #$SndMsg('ERROR - VALUE For VARIABLE '+
                %trim(vr(i).var)+' MUST BE A VALID DATE.' );
                *INLR = *ON;
                Return;
              EndIf;
              VRDFT(x)=vr(i).value;
            EndIf;
          EndFor;
          If *IN50;
            #$SndMsg('ERROR - THERE IS NO VARIABLE +
            SETUP For ' +  %trim(vr(i).var) );
            *INLR = *ON;
            Return;
          EndIf;
        EndIf;
      EndFor;
    EndIf;
  Else;
    Clear *ALL SQLLSTR;
  EndIf;

  // if the action is email, make sure a valid email address exists
  If psActn='*EMAIL';
    // if a report distribution queue is passed try to get the email
    // addresses from it and add them to the array
    // If PSRPID<>' ';
    //   tpEmail='';
    //   Exec SQL Declare SQLCRS2 Cursor For
    //   Select ACEMAIL From QUSRIJS/QAIJS2RD
    //   JOIN ACCESSPF on R2RCP=ACUPRF
    //     Where  R2NAME=:psRpId   and
    //   R2SPLF='EMAIL' and ACEMAIL<>' ';
    //   Exec SQL Open SQLCRS2;
    //   Exec SQL Fetch Next From SQLCRS2 Into :tpEmail;
    //   DoW not #$SQLSTT();
    //     psEMLCNT+=1;
    //     psEM(psEMLCNT)=tpEmail;
    //     Exec SQL Fetch Next From SQLCRS2 Into :tpEmail;
    //   EndDo;
    //   Exec SQL Close SQLCRS2;
    // EndIf;

    For i=1 To psEMLCNT;
      // // if *current is used in any of the email addresses replace it with
      // // the email address from accesspf
      // If %trim(psEM(i))='*USER' or
      // %trim(psEM(i))='*CURRENT';
      //   Exec SQL Select ACEMAIL Into :F8EM01 From ACCESSPF Where ACUPRF=:USER;
      //   psEM(i)=F8Em01;
      // EndIf;

      // if *rptdstid is used get rid of it and roll up the addresses
      // If %trim(psEM(i))='*RPTDSTID';
      //   For x=i To 49;
      //     psEM(x)=psEM(x+1);
      //   EndFor;
      //   psEM(50)='';
      //   psEMLCNT-=1;
      // EndIf;

      // if *dft is used and a query name is not passed giver error
      If %trim(psEM(i))='*DFT' and
        %len(%trim(psName))>10;
        #$SndMsg('ERROR - CANNOT USE *DFT For +
        AN EMAIL ADDRESS If not PASSING A +
        QUERY NAME.');
        *INLR = *ON;
        Return;
      EndIf;

      // if *dft is used in any of the email addresses replace it with
      // the email address from sqllstpf, add extras to end of array
      If %trim(psEM(i))='*DFT';
        psEM(i)=sqlEm01;
        If SQLEM02<>' ';
          psEMLCNT+=1;
          psEM(psEMLCNT)=sqlEm02;
        EndIf;
        If SQLEM03<>' ';
          psEMLCNT+=1;
          psEM(psEMLCNT)=sqlEm03;
        EndIf;
        If SQLEM04<>' ';
          psEMLCNT+=1;
          psEM(psEMLCNT)=sqlEm04;
        EndIf;
      EndIf;

      // entry make sure the email address is valid
      If psEM(i)<>' ' and #$VEML(psEM(i));
        #$SndMsg('ERROR - INVALID EMAIL ADDRESS: ' +
          %trim(psEM(i)));
        *INLR = *ON;
        Return;
      EndIf;
    EndFor;

    // make sure an email address or report dist id is entered
    If psEM(1)=' ';
      #$SndMsg('ERROR - NO EMAIL ADDRESSES');
      *INLR = *ON;
      Return;
    EndIf;

  EndIf;

  // if the action is *outfile make sure the file doesn't exists
  If psActn='*OUTFILE';
    If psOutF.outF=' ';
      #$SndMsg('ERROR - YOU SPECIFY THE FILE +
        NAME.');
      *INLR = *ON;
      Return;
    EndIf;
    If psOutF.OUTL=' ';
      psOutF.OUTL='*CURLIB';
    EndIf;
    If #$ISFILE(psOutF.outF:psOutF.OUTL);
      #$SndMsg('ERROR - FILE ' + %trim(psOutF.OutL) +
      '/' + %trim(psOutF.outf) + ' ALREADY EXISTS.');
      *INLR = *ON;
      Return;
    EndIf;
  EndIf;

  // if the action is *ifsfile make a file name is passed
  If psActn='*IFSFILE';
    If psIfsF=' ';
      #$SndMsg('Error - You must specify the file name.');
      *INLR = *ON;
      Return;
    EndIf;
  EndIf;

End-Proc;


// load lines array from sqldetpf
Dcl-Proc LOADLINES;

  Clear LINES;
  x=0;

  SetLL (SF1ENUS:SF1NAME) SQLDETPF;
  ReadE(N) (SF1ENUS:SF1NAME) SQLDETPF;
  DoW not %eof;
    x+=1;
    lines(x)=sqdLine;
    ReadE(N) (SF1ENUS:SF1NAME) SQLDETPF;
  EndDo;

End-Proc;


// *******************************************************************************************
// process screen 1
Dcl-Proc PROCF1;

  // default to current user
  F1USER=USER;

  MOVEF1();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF1=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF1<=0 or CRNF1>RRNF1;
      crnf1=1;
    EndIf;
    Write F1F;
    Exfmt F1C;
    %subarr(*IN:50:9) = *OFF;
    Erm='';
    If CSRF1=0;
      If *in46;
        CRNF1=NumRcF1;
      Else;
        CRNF1=1;
      EndIf;
    Else;
      CRNF1=CSRF1;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
      BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // f4=ad hoc
    If *IN04;
      Clear Lines;
      PROCF10();
      MOVEF1();
      ITER;
    EndIf;

    // f6=add
    If *IN06;
      Clear Sf1Name;
      PROCF3();
      MOVEF1();
      ITER;
    EndIf;

    // f8=toggle sort
    If *IN08;
      F1Sort=1;
      If F1SORT>2;
        F1Sort=0;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // f9=dates
    If *IN09;
      If *IN82;
        *IN82 = *OFF;
      Else;
        *IN82 = *ON;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // f11=show/hide deleted
    If *IN11;
      If *IN49;
        *IN49 = *OFF;
      Else;
        *IN49 = *ON;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // f14=import qrydfn
    If *IN14;
      Clear SF1Name;
      PROCF19();
      MOVEF1();
      ITER;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF1();
    If *in50;
      Iter;
    EndIf;

    UPDTF1();
    If AGAINF1<>'Y' and not *IN25;
      Leave;
    EndIf;

    MOVEF1();
  EndDo;

End-Proc;
// ***************************************************************
Dcl-Proc MOVEF1;

  // build the command keys and date header
  F1CMDS='F1=Help  F3=Exit   +
  F4=Ad Hoc    F6=Add';
  If F1Sort=1;
    F1CMDS=%trim(F1CMDS) + '   F8=Sort by Date';
  ElseIf F1Sort=2;
    F1CMDS=%trim(F1CMDS) + '   F8=Sort by Name';
  Else;
    F1CMDS=%trim(F1CMDS) + '   F8=Sort by Desc';
  EndIf;
  If not *IN82;
    F1CMDS=%trim(F1CMDS) + '  F9=Revised Date';
    F1TITL='------ Entry ------';
  Else;
    F1CMDS=%trim(F1CMDS) + '  F9=Entry Date';
    F1TITL='----- Revised -----';
  EndIf;
  If *IN49;
    F1CMD2='F11=Hide Deleted';
  Else;
    F1CMD2='F11=Show Deleted';
  EndIf;
  F1CMD2=%trim(F1CMD2) + '   F12=Cancel';
  F1CMD2=%trim(F1CMD2) + '   F14=Import QRYDFN';

  // clear sfl
  *IN44 = *ON;
  Write F1C;
  *IN44 = *OFF;

  RRNF1=0;
  Clear Select;

  // fill sfl
  PRPSQLF1();
  GETSQLF1();
  DoW not EOF;
    GETSQLF1();
    If RRNF1>2000;
      Leave;
    EndIf;
  EndDo;
  CLSSQLF1();

  NumRcF1=RRNF1;

End-Proc;


// Validate Screen F1
Dcl-Proc VALDF1;

  againF1='';

  // validate sfl options
  For x = 1 To NumRcF1;
    Chain x F1S;
    If not %found;
      iter;
    EndIf;

    If *in26;
      againF1='Y';
    EndIf;

    If Select<>'X' and Select<>'2' and
      Select<>'C' and Select<>'3' and
    Select<>'I' and Select<>'7' and
    Select<>'R' and Select<>'1' and
      Select<>'D' and Select<>'4' and
      Select<>'V' and Select<>'5' and
      Select<>'A' and Select<>'9' and
      Select<>'P' and Select<>'6' and
      Select<>'E' and Select<>'8' and
      Select<>'F' and Select<>'S' and
      Select<>' ';
      ERM=#$Cntr('ERROR - INVALID OPTION +
        ENTERED.':78);
      *IN50 = *ON;
      *IN51 = *ON;
      If SQLDLT='Y';
        *in48=*on;
      Else;
        *in48=*off;
      EndIf;
      Update F1S;
      Return;
    EndIf;

  EndFor;

End-Proc;


// Update Screen F1
Dcl-Proc UPDTF1;

  // check sfl for options entered
  For xF1 = 1 To NumRcF1;
    Chain xF1 F1S;
    If not %found;
      Iter;
    EndIf;

    If Select='V' or Select='5';
      CrnF1=xF1;
      againF1='Y';
      PROCF2();
    EndIf;

    If Select='X' or Select='2';
      CrnF1=xF1;
      againF1='Y';
      PROCF3();
    EndIf;

    If Select='C' or Select='3';
      CrnF1=xF1;
      againF1='Y';
      PROCF14();
      If not *IN12 and not *IN03;
        PROCF3();
      EndIf;
    EndIf;

    If Select='D' or Select='4';
      CrnF1=xF1;
      againF1='Y';
      DELTF1();
    EndIf;

    If Select='I' or Select='7';
      CrnF1=xF1;
      againF1='Y';
      REINF1();
    EndIf;

    If Select='R' or Select='1';
      CrnF1=xF1;
      againF1='Y';
      Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
      LOADLINES();
      VarDs=SQLVars;
      DSPQUERY();
    EndIf;

    If Select='A' or Select='9';
      CrnF1=xF1;
      againF1='Y';
      OPENADHOC();
    EndIf;

    If Select='E' or Select='8';
      CrnF1=xF1;
      againF1='Y';
      PROCF8();
    EndIf;

    If Select='P' or Select='6';
      CrnF1=xF1;
      againF1='Y';
      PROCF9();
    EndIf;

    If Select='F';
      CrnF1=xF1;
      againF1='Y';
      PROCF23();
    EndIf;

    If Select='S';
      CrnF1=xF1;
      againF1='Y';
      PROCF21();
    EndIf;

    If SQLDLT='Y';
      *in48=*on;
    Else;
      *in48=*off;
    EndIf;
    Update F1S;
  EndFor;

End-Proc;


// Delete Query from F1
Dcl-Proc DELTF1;

  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If %found;
    sqlDlt='Y';
    sqllrUs=User;
    sqlLrWs=wsId;
    sqlLrDt=%dec(%char(%date():*ISO0):8:0);
    sqlLrTm=%dec(%char(%time():*hms0):6:0);
    Update SQLLSTR;
    ERM=#$Cntr('QUERY ' + %trim(SQLNAME) +
    ' DELETED.':78);
  EndIf;

End-Proc;


// Reinstate Query from F1
Dcl-Proc REINF1;

  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If %found;
    sqlDlt=' ';
    sqllrUs=User;
    sqlLrWs=wsId;
    sqlLrDt=%dec(%char(%date():*ISO0):8:0);
    sqlLrTm=%dec(%char(%time():*hms0):6:0);
    Update SQLLSTR;
    ERM=#$Cntr('QUERY ' + %trim(SQLNAME) +
    ' REINSTATED.':78);
  EndIf;

End-Proc;


// Open Query in Adhoc from F1
Dcl-Proc OPENADHOC;

  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If %found;
    LOADLINES();
    PROCF10();
  EndIf;

End-Proc;


// Prepare Sql Statement to fill F1
Dcl-Proc PRPSQLF1;
  // builds an sql statement, and opens a cursor to it

  EOF=*OFF;

  // setup sql select statement
  SQLSTMF1='SELECT * FROM SQLLSTPF WHERE SQLNAME NOT LIKE ''#$LST%''';

  // add customer name selection if entered
  If F1USER<>' ';
    SQLSTMF1+= ' AND SQLENUS = ''' + #$SQLESC(F1USER) + '''';
  EndIf;

  // if a search is entered, parse it into seperate words
  // then add a selection for each one
  If F1SRCH<>' ';
    #$BLDSCHF(01)='SQLNAME';
    #$BLDSCHF(02)='SQLTYPE';
    #$BLDSCHF(03)='SQLDESC';
    #$BLDSCHF(04)='SQLENUS';
    #$BLDSCHF(05)='SQLENDT';
    #$BLDSCHF(06)='SQLLRUS';
    #$BLDSCHF(07)='SQLLRDT';
    SQLSTMF1+= ' AND ' + #$BLDSCH(F1SRCH:#$BLDSCHF);
  EndIf;

  // exclude deleted
  If not *IN49;
    SQLSTMF1+= ' AND SQLDLT<>''Y''';
  EndIf;

  // add order by selection
  // sort 0 = by name
  // sort 1 = by description
  // sort 2 = by entry/last date
  If F1Sort=1;
    SQLSTMF1+=' ORDER BY SQLDESC, SQLNAME';
  ElseIf F1Sort=2 and not *IN82;
    SQLSTMF1+=' ORDER BY SQLENDT, SQLNAME';
  ElseIf F1Sort=2 and *IN82;
    SQLSTMF1+=' ORDER BY SQLLRDT, SQLNAME';
  Else;
    SQLSTMF1+=' ORDER BY SQLNAME';
  EndIf;

  // prepare the statement, setup the cursor and open it
  Exec SQL Prepare SQLF1 From :SQLSTMF1;
  #$SQLSTT();
  Exec SQL Declare SQLCRSF1 Cursor For SQLF1;
  #$SQLSTT();
  Exec SQL Open SQLCRSF1;
  #$SQLSTT();

End-Proc;


// Fetch Next Entry and write it to the SFL for F1
Dcl-Proc GETSQLF1;

  Exec SQL Fetch Next From SQLCRSF1 Into :SQLLSTDS;

  If #$SQLSTT();
    EOF = *ON;
    Return;
  EndIf;

  SF1Name=SqlName;
  If *IN82;
    SF1LrUs=SqlLrUs;
    SF1LrDt=%rem(SqlLrDt:1000000);
  Else;
    SF1LrUs=SqlEnUs;
    SF1LrDt=%rem(SqlEnDt:1000000);
  EndIf;

  SF1Name=SqlName;
  SF1Enus=SqlEnUs;
  SF1Desc=SqlDesc;

  If sqlDlt='Y';
    *in48=*on;
  Else;
    *in48=*off;
  EndIf;

  RRNF1+=1;
  Write F1S;

End-Proc;


// Close Cursor for F1
Dcl-Proc CLSSQLF1;

  Exec SQL Close SQLCRSF1;

End-Proc;


// Process Screen F2
Dcl-Proc PROCF2;

  MOVEF2();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF1=0;
      *in45=*on;
    Else;
      *in45=*off;
    EndIf;
    If CRNF2<=0 or CRNF2>RRNF2;
      CRNF2=1;
    EndIf;
    Write F2F;
    Exfmt F2C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    If CSRF2=0;
      If *in46;
        CRNF2=NumRcF2;
      Else;
        CRNF2=1;
      EndIf;
    Else;
      CRNF2=CSRF2;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
      BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Return;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF2();
    If *in50;
      Iter;
    EndIf;

    UPDTF2();
    If AGAINF2<>'Y' and not *IN25;
      Leave;
    EndIf;

    MOVEF2();
  EndDo;

End-Proc;


// Populate Screen F2
Dcl-Proc MOVEF2;

  // get record
  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVars;

  // clear sfl
  *IN44 = *ON;
  Write F2C;
  *IN44 = *OFF;
  *IN85 = *OFF;

  RRNF2=0;

  // add default output
  SF2LINE='Default Output:';
  If SQLOUTP='2';
    SF2LINE = %trim(SF2LINE) + ' FILE';
  ElseIf SQLOUTP='3';
    SF2LINE = %trim(SF2LINE) + ' REPORT';
  ElseIf SQLOUTP='4';
    SF2LINE = %trim(SF2LINE) + ' EMAIL EXCEL';
  Else;
    SF2LINE = %trim(SF2LINE) + ' SCREEN';
  EndIf;
  RRNF2+=1;
  Write F2S;
  If SQLEM01<>' ';
    SF2LINE='Default Email: ' + SQLEM01;
    RRNF2+=1;
    Write F2S;
  EndIf;
  RRNF2+=1;

  // add long descriptions
  If SQLLD01<>' ' or SQLLD02<>' ' or
     SQLLD03<>' ' or SQLLD04<>' ' or
     SQLLD05<>' ';
    SF2LINE='Long Description';
    *IN85 = *ON;
    RRNF2+=1;
    Write F2S;
    *IN85 = *OFF;
    If SQLLD01<>' ';
      SF2LINE=SQLLD01;
      RRNF2+=1;
      Write F2S;
    EndIf;
    If SQLLD02<>' ';
      SF2LINE=SQLLD02;
      RRNF2+=1;
      Write F2S;
    EndIf;
    If SQLLD03<>' ';
      SF2LINE=SQLLD03;
      RRNF2+=1;
      Write F2S;
    EndIf;
    If SQLLD04<>' ';
      SF2LINE=SQLLD04;
      RRNF2+=1;
      Write F2S;
    EndIf;
    If SQLLD05<>' ';
      SF2LINE=SQLLD05;
      RRNF2+=1;
      Write F2S;
    EndIf;
    RRNF2+=1;
  EndIf;

  // add sql statement
  SF2LINE='SQL Statement';
  *IN85 = *ON;
  RRNF2+=1;
  Write F2S;
  *IN85 = *OFF;
  For x=1 To 1000;
    If LINES(x)<>' ';
      SF2LINE=LINES(x);
      RRNF2+=1;
      Write F2S;
    EndIf;
  EndFor;
  RRNF2+=1;

  // add variables
  If VRNAME(01)<>' ' or VRNAME(02)<>' ' or VRNAME(03)<>' ' or VRNAME(04)<>' ' or
     VRNAME(05)<>' ' or VRNAME(06)<>' ' or VRNAME(07)<>' ' or VRNAME(08)<>' ' or
     VRNAME(09)<>' ' or VRNAME(10)<>' ';
    SF2LINE='Variable    Type  Length  Dec  Wildcards '+
            ' Default Value                        ';
    *IN85 = *ON;
    RRNF2+=1;
    Write F2S;
    *IN85 = *OFF;
    For x=1 To 10;
      If VRNAME(x)<>' ';
        tpType='';
        If VRTYPE(x)='1';
          tpType='DEC';
        ElseIf VRTYPE(x)='2';
          tpType='CHAR';
        Else;
          tpType='DATE';
        EndIf;
        SF2LINE=VRNAME(x) + '  ' + tpType + '    ' + VRLEN(x) + '    ' + VRDEC(x)
                      + '      ' + VRWILD(x) + '       ' + VRDFT(x);
        RRNF2+=1;
        Write F2S;
      EndIf;
    EndFor;
    RRNF2+=1;
  EndIf;

  // add columns
  Monitor;
    BLDSQL();
    cols=#$SQLGetColumns(SQLSTMP);
    SF2LINE='  Seq  Name                             Type     Ovr  Len  Dec           ';
    *IN85 = *ON;
    RRNF2+=1;
    Write F2S;
    *IN85 = *OFF;
    For x=1 To cols.count;
      Temp31=%trim(cols.Col(x).NAME);
      Temp10=%trim(cols.Col(x).TYPE);
      Len=cols.Col(x).Len;
      Dec=cols.Col(x).Dec;
      SF2LINE=%editw(x:'    0') + '  ' + Temp31 + '  ' + Temp10
            + '    ' + %editc(Len:'Z') + '  ' + %editc(Dec:'Z');
      RRNF2+=1;
      Write F2S;
    EndFor;
  On-Error;
    SF2LINE='Error retrieving column descriptions';
    RRNF2+=1;
    *IN85 = *ON;
    Write F2S;
    *IN85 = *OFF;
    SF2LINE='Update the SQL statement to determine the problem.';
    RRNF2+=1;
    Write F2S;
  EndMon;
  RRNF2+=1;

  // add dates
  If SQLENUS<>' ';
    SF2LINE='Entry: ' + SQLENUS +%editw(SQLENDT:'    /  / 0') + %editw(SQLENTM:'  :  : 0') +SQLENWS;
  EndIf;
  If SQLLRUS<>' ';
    SF2LINE='Last:  ' + SQLLRUS +%editw(SQLLRDT:'    /  / 0') +%editw(SQLLRTM:'  :  : 0') +SQLLRWS;
  EndIf;

  NumRcF2=RRNF2;

End-Proc;


// Build SQL
Dcl-Proc BLDSQL;

  // this routine builds an sql statement from the entry in sqllstpf,
  // the record must be chained and loadlines must be run. the new
  // sqlstm field is called sqlstmp and it incldues any declared
  // variables overridden to the default values for the variable.

  SQLSTMP='';

  // loop through each sql line and add them to the new field
  For x=1 To 1000;

    tempLine=Lines(x);

    // loop through variables and overide them in the sql statement if needed
    For y=1 To 10;
      If VRNAME(y)<>' ';
        Default='';
        If VRTYPE(y)='1';
          Default=%trim(%char(#$RVL(VRDFT(y))));
        ElseIf VRTYPE(y)='3';
          Default=%trim(%char(#$RVL(VRDFT(y))));
        Else;
          If VRWILD(y)='Y' and #$Last(VRDFT(y):1)<>'%';
            VRDFT(y)=%trim(VRDFT(y)) + '%';
          EndIf;
          Default='''' + %trim(VRDFT(y)) + '''';
        EndIf;
        var=':' + %trim(VRNAME(y));
        tempLine=%scanrpl(%trim(var):
        %trim(Default):tempLine);
      EndIf;
    EndFor;

    SQLSTMP += ' ' + tempLine;

  EndFor;

End-Proc;


// Validate Screen F2
Dcl-Proc VALDF2;

  againF2='';

End-Proc;


// Update Screen F2
Dcl-Proc UPDTF2;

End-Proc;


// Process Screen F3
Dcl-Proc PROCF3;

  MOVEF3();
  DoW not *INLR;

    Exfmt F3;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f5=email defaults
    If *IN05;
      PROCF17();
      ITER;
    EndIf;

    // f6=print defaults
    If *IN06;
      PROCF18();
      ITER;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
        KEY.':78);
      ITER;
    EndIf;

    VALDF3();
    If *in50;
      Iter;
    EndIf;

    UPDTF3();

    If F3VROV='Y';
      PROCF4();
      If *in03;
        Leave;
      EndIf;
    Else;
      PROCF5();
      If *in03;
        Leave;
      EndIf;
    EndIf;
    If *in12;
      MOVEF3();
    Else;
      Leave;
    EndIf;
  EndDo;

End-Proc;


// Load Screen F3
Dcl-Proc MOVEF3;

  // get record
  If SF1NAME<>' ';
    Chain (SF1ENUS:SF1NAME) SQLLSTPF;

    If not %found;
      Clear *all SQLLSTR;
    EndIf;
    *IN81 = *ON;
  Else;
    *IN81 = *OFF;
    Clear *ALL SQLLSTR;
    SQLTYPE='SELECT';
    SQLOUTP='1';
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  F3NAME = SQLNAME;
  F3DESC = SQLDESC;
  F3TYPE = SQLTYPE;
  F3OUTP = SQLOUTP;
  F3EM01 = SQLEM01;
  F3LD01 = SQLLD01;
  F3LD02 = SQLLD02;
  F3LD03 = SQLLD03;
  F3LD04 = SQLLD04;
  F3LD05 = SQLLD05;
  F3VROV = '';

  For x=1 To 10;
    If VRNAME(x)<>' ';
      F3VROV='Y';
      Leave;
    EndIf;
  EndFor;

End-Proc;


// Validate Screen F3
Dcl-Proc VALDF3;

  // in entry make sure a name is entered
  If SF1NAME=' ' and F3NAME=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
    A NAME.':78);
    Return;
  EndIf;

  // in entry make sure a name does not start with #$lst
  If %subst(F3NAME:1:5)='#$LST' and
  SF1NAME=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE NAME CANNOT +
      Start With #$LST.':78);
    Return;
  EndIf;

  // in entry make sure the entered name does not already exists
  If SF1NAME=' ';
    Chain(N) (USER:F3NAME) SQLLSTPF;
    If %found;
      *IN51 = *ON;
      *IN50 = *ON;
      ERM=#$Cntr('ERROR - THIS NAME ALREADY +
      EXISTS.':78);
      Return;
    EndIf;
  EndIf;

  // entry make sure a description is entered
  If F3DESC=' ';
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
    DESCRIPTION.':78);
    Return;
  EndIf;

  // entry make sure a type is entered
  If F3TYPE=' ';
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
      TYPE.':78);
    Return;
  EndIf;

  // entry make sure a type is entered
  If F3OUTP<>'1' and F3OUTP<>'2' and
  F3OUTP<>'3';
    *IN54 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTIon +
    ENTERED.':78);
    Return;
  EndIf;

  // entry make sure the email address is valid if entered
  If F3EM01<>' ' and F3EM01<>'*USER' and
  F3EM01<>'*CURRENT' and
  F3EM01<>'*RPDDSTQ' and
  F3EM01<>'*PROMPT' and #$VEML(F3EM01);
    *IN55 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID EMAIL or +
    OPTION.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F3
Dcl-Proc UPDTF3;

  // add or update record
  Clear *ALL SQLLSTR;
  *IN81 = *ON;
  If SF1NAME<>' ';
    Chain (SF1ENUS:SF1NAME) SQLLSTPF;
    If not %found;
      Clear *all SQLLSTR;
    Else;
      *in81=*off;
    EndIf;
  EndIf;
  SQLLSTSV=SQLLSTDS;

  // update change flags
  If not *IN81
  and F3NAME  <>  SQLNAME
  and F3DESC  <>  SQLDESC
  and F3TYPE  <>  SQLTYPE
  and F3OUTP  <>  SQLOUTP
  and F3EM01  <>  SQLEM01
  and F3LD01  <>  SQLLD01
  and F3LD02  <>  SQLLD02
  and F3LD03  <>  SQLLD03
  and F3LD04  <>  SQLLD04
  and F3LD05  <>  SQLLD05;
    SQLLRUS = USER;
    SQLLRWS = WSID;
    SQLLRDT = %dec(%char(%date():*ISO0):8:0);
    SQLLRTM = %dec(%char(%time():*hms0):6:0);
  EndIf;

  SQLNAME = F3NAME;
  SQLDESC = F3DESC;
  SQLTYPE = F3TYPE;
  SQLOUTP = F3OUTP;
  SQLEM01 = F3EM01;
  SQLLD01 = F3LD01;
  SQLLD02 = F3LD02;
  SQLLD03 = F3LD03;
  SQLLD04 = F3LD04;
  SQLLD05 = F3LD05;

  If *in81;
    SQLENUS = USER;
    SQLENWS = WSID;
    SQLENDT = %dec(%char(%date():*ISO0):8:0);
    SQLENTM = %dec(%char(%time():*hms0):6:0);
    Write SQLLSTR;
    SF1ENUS=SQLENUS;
    SF1NAME=SQLNAME;
  Else;
    If SQLLSTDS<>SQLLSTSV;
      SQLLRUS = USER;
      SQLLRWS = WSID;
      SQLLRDT = %dec(%char(%date():*ISO0):8:0);
      SQLLRTM = %dec(%char(%time():*hms0):6:0);
    EndIf;
    Update    SQLLSTR;
  EndIf;


End-Proc;


// Process Screen F4
Dcl-Proc PROCF4;

  MOVEF4();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF4=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF4<=0 or CRNF4>RRNF4;
      CRNF4=1;
    EndIf;
    Write F4F;
    Exfmt F4C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    If CSRF4=0;
      If *in46;
        CRNF4=NumRcF4;
      Else;
        CRNF4=1;
      EndIf;
    Else;
      CRNF4=CSRF4;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':78);
      ITER;
    EndIf;

    VALDF4();
    If *in50;
      Iter;
    EndIf;

    UPDTF4();
    If AGAINF4<>'Y' and not *IN25;
      PROCF5();
      If not *in12;
        Leave;
      EndIf;
    EndIf;

    MOVEF4();
  EndDo;

End-Proc;


// Lod Screen F4
Dcl-Proc MOVEF4;

  // get record
  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  // clear sfl
  *IN44 = *ON;
  Write F4C;
  *IN44 = *OFF;

  RRNF4 = 0;
  Clear Select;

  // fill sfl
  For x=1 To 10;
    SF4NAME=VRNAME(x);
    SF4TYPE='    ';
    If VRTYPE(x)='1';
      SF4TYPE='DEC ';
    ElseIf VRTYPE(x)='2';
      SF4TYPE='CHAR';
    ElseIf VRTYPE(x)='3';
      SF4TYPE='DATE';
    EndIf;
    SF4LEN =#$RVL(VRLEN(x));
    SF4DEC =#$RVL(VRDEC(x));
    SF4DFT =VRDFT(x);
    SF4WILD=VRWILD(x);
    RRNF4+=1;
    Write F4S;
  EndFor;

  NumRcF4=RRNF4;

End-Proc;


// Validate Screen F4
Dcl-Proc VALDF4;

  againF4='';

  // validate sfl options
  For x=1 To NumRcF4;
    Chain x F4S;
    If not %found;
      Iter;
    EndIf;

    If *in26;
      againF4='Y';
    EndIf;

    If SF4NAME<>' ';

      If SF4TYPE<>'CHAR' and SF4TYPE<>'DEC' and
      SF4TYPE<>'DATE';
        ERM=#$Cntr('ERROR - TYPE MUST BE CHAR, DEC +
          or DATE':78);
        *IN50 = *ON;
        *IN51 = *ON;
        Update F4S;
        Return;
      EndIf;

      If SF4TYPE='CHAR' and SF4LEN>30;
        ERM=#$Cntr('ERROR - LENGTH CANNOT EXCEED +
        30':78);
        *IN50 = *ON;
        *IN52 = *ON;
        Update F4S;
        Return;
      EndIf;

      If SF4TYPE='DEC' and SF4LEN>20;
        ERM=#$Cntr('ERROR - LENGTH CANNOT EXCEED +
          20':78);
        *IN50 = *ON;
        *IN52 = *ON;
        Update F4S;
        Return;
      EndIf;

      If SF4TYPE='DATE' and SF4LEN<>0 and
      SF4LEN<>8;
        ERM=#$Cntr('ERROR - DATE LENGTH MUST +
        8':78);
        *IN50 = *ON;
        *IN52 = *ON;
        Update F4S;
        Return;
      EndIf;

    EndIf;
  EndFor;

End-Proc;


// Update Screen F4
Dcl-Proc UPDTF4;

  *in81=*off;
  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    *in81=*on;
    Clear *all SQLLSTR;
  EndIf;
  SQLLSTSV = SQLLSTDS;

  // check sfl for options entered
  For xF4=1 To NumRcF4;
    Chain xF4 F4S;
    If not %found;
      Iter;
    EndIf;

    VRNAME(xF4)=SF4NAME;
    VRTYPE(xF4)=' ';
    If SF4TYPE='DEC ';
      VRTYPE(xF4)='1';
    EndIf;
    If SF4TYPE='CHAR';
      VRTYPE(xF4)='2';
    EndIf;
    If SF4TYPE='DATE';
      VRTYPE(xF4)='3';
    EndIf;
    VRLEN(xF4) =%char(SF4LEN);
    VRDEC(xF4) =%char(SF4DEC);
    VRDFT(xF4) =SF4DFT;
    VRWILD(xF4) =SF4WILD;

  EndFor;

  VarDs=SQLVARS;

  If not *in81;
    If SQLLSTDS<>SQLLSTSV;
      SQLLRUS=User;
      SQLLRWs=WsId;
      SQLLRDt=%dec(%char(%date():*ISO0):8:0);
      SQLLRTm=%dec(%char(%time():*hms0):6:0);
    EndIf;
    Update SQLLSTR;
  EndIf;

End-Proc;


// Process Screen F5
Dcl-Proc PROCF5;

  MOVEF5();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF5=0;
      *in45 = *off;
    Else;
      *in45 = *on;
    EndIf;
    If CRNF5<=0 or CRNF5>RRNF5;
      CRNF5=1;
    EndIf;
    Write F5F;
    Exfmt F5C;
    %subarr(*IN:50:9) = *OFF;
    *IN97 = *OFF;
    ERM='';

    If CSRF5=0;
      If *in46;
        CRNF5=NumRcF5;
      Else;
        CRNF5=1;
      EndIf;
    Else;
      CRNF5=CSRF5;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // f4=field list
    If *IN04;
      UPDTF5();
      If *in50;
        Iter;
      EndIf;
      *IN50 = *OFF;
      Erm='';
      DSPFLDF5();
      ITER;
    EndIf;

    // f6=insert line
    If *IN06;
      INSF5();
      ITER;
    EndIf;

    // f7=format
    If *IN07;
      FMTF5();
      ITER;
    EndIf;

    // f10=copy line
    If *IN10;
      CPYF5();
      ITER;
    EndIf;

    // f14=delete line
    If *IN14;
      DELF5();
      POSCUR();
      ITER;
    EndIf;

    // f15=split line
    If *IN15;
      SPLITF5();
      ITER;
    EndIf;

    // f16=un-split line
    If *IN16;
      UNSPLITF5();
      ITER;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':78);
      ITER;
    EndIf;

    VALDF5();
    If *in50;
      Iter;
    EndIf;

    UPDTF5();
    If *in50;
      Iter;
    EndIf;

    // f5=run
    If *IN05;
      againF5='Y';
      DSPQUERY();
    EndIf;

    If AGAINF5<>'Y' and not *IN25;
      Leave;
    EndIf;

    MOVEF5();
  EndDo;

End-Proc;


// Possition Cursor
// this routine moves the cursor back to the same location it was
// on the last read/exfmt of the screen. the #$row and #$col come
// from the display file infds, the #$bin fiels are used to convert
// from binary to numberic, row and col are defined on the display
// file format and on 97 position the cursor.
Dcl-Proc POSCUR;

  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  *IN97 = *ON;
End-Proc;


// Display Field from F5
Dcl-Proc DSPFLDF5;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // get the line the cursor is on
  // use the cursor location to find the word the cursor is on,
  // if the word is a file default to that file, other wise see
  // if there is a file name in any of the words on the line.
  // otherwise scan the query for the First file name, but also
  // build a list of all file names found.


  Clear tpLib;
  Clear tpFile;
  Clear crLib;
  Clear crFile;
  Clear lnFile;
  Clear lnLib;
  Clear temp21;
  Clear FILES;
  Clear FILDSC;
  Clear WORDS;
  Clear FILECNT;
  Clear strPos;
  Clear endPos;

  // find the word the cursor is on
  Chain CSRF5 F5S;
  If %found;
    // skip if the cursor is on a blank space
    // find the file name the cursor is on
    strPos=#$SCANR(' ':SF5LINE:Col-1)+1;
    endPos=%scan(' ':SF5LINE:Col-1);
    If strPos=0;
      strPos=1;
    EndIf;
    If endPos=0;
      endPos=78;
    EndIf;
    If endPos+strPos>78;
      endPos=78-strPos+1;
    EndIf;
    temp21=%subst(SF5LINE:strPos:endPos);
    If %scan('/':temp21)>0;
      crLib=%subst(temp21:1:%scan('/':temp21)-1);
      crFile=%subst(temp21:%scan('/':temp21)+1:10);
    Else;
      crLib='*LIBL';
      crFile=temp21;
    EndIf;
    If not #$ISFILE(crFile:crLib);
      Clear crFile;
    EndIf;

    // find the First file name on the line the cursor is on
    WORDS=#$SPLIT(SF5LINE);
    For x=1 To 50;
      If WORDS(x)<>' ';
        If %scan('/':WORDS(x))>0;
          tpLib=%subst(WORDS(x):1:
          %scan('/':WORDS(x))-1);
          tpFile=%subst(WORDS(x):
            %scan('/':WORDS(x))+1:10);
        Else;
          tpLib='*LIBL';
          tpFile=WORDS(x);
        EndIf;
        If #$ISFILE(tpFile:tpLib);
          lnFile=tpFile;
          lnLib=tpLib;
          Leave;
        EndIf;
      Else;
        Leave;
      EndIf;
    EndFor;
  EndIf;

  // loop through the sfl and find all files in the statement
  For x=1 To NumRcF5;
    Chain x F5S;
    If not %found;
      Iter;
    EndIf;
    WORDS=#$SPLIT(SF5LINE);
    For y=1 To 20;
      If %scan('/':WORDS(y))>0;
        tpLib=%subst(WORDS(y):1:
          %scan('/':WORDS(y))-1);
        tpFile=%subst(WORDS(y):
        %scan('/':WORDS(y))+1:10);
      Else;
        tpLib='*LIBL';
        tpFile=WORDS(y);
      EndIf;
      If #$ISFILE(tpFile:tpLib);
        FILECNT+=1;
        FILES(FILECNT)=tpFile;
        LIBS(FILECNT)=tpLib;
      EndIf;
    EndFor;
  EndFor;

  If CRFILE<>' ';
    F12File=crFile;
    F12Lib=crLib;
  ElseIf LNFILE<>' ';
    F12File=lnFile;
    F12Lib=lnLib;
  Else;
    F12File='*ALL';
    F12Lib='';
  EndIf;

  // move sfl to lines array
  LINES2SF5();

  CsrPos=CSRF5;
  PROCF12();

  // set on 97 to postition the cursor back to the exact place it was
  // when the f4 was pressed
  *IN97 = *ON;

  // move lines array back to sfl
  LINES2SF5();

End-Proc;


// ***************************************************************
Dcl-Proc INSF5;

  // load sfl back into lines
  SF52LINES();

  // use the line the cursor is on and move the rest down one
  For x=999 by 1 DOWNTO CSRF5+1;
    LINES(x+1)=LINES(x);
    LINES(x)=' ';
  EndFor;

  // load lines back into sfl
  LINES2SF5();

End-Proc;


// ***************************************************************
Dcl-Proc CPYF5;

  // load sfl back into lines
  SF52LINES();

  // use the line the cursor is on and move the rest down one
  For x=999 by 1 DOWNTO CSRF5;
    LINES(x+1)=LINES(x);
  EndFor;

  // load lines back into sfl
  LINES2SF5();

End-Proc;


// ***************************************************************
Dcl-Proc DELF5;

  // load sfl back into lines
  SF52LINES();

  // use the line the cursor is on and move the rest up one
  For x=CSRF5 To 999;
    LINES(x)=LINES(x+1);
  EndFor;
  LINES(1000)=' ';

  // load lines back into sfl
  LINES2SF5();

End-Proc;


// ***************************************************************
Dcl-Proc SPLITF5;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // load sfl back into lines
  SF52LINES();

  // insert a line after the cursor
  For x=999 by 1 DOWNTO CSRF5;
    LINES(x+1)=LINES(x);
  EndFor;

  // get the number of spaces on the line to save the indention
  For i=1 To 78;
    If %subst(LINES(CSRF5):i:1)<>' ';
      Leave;
    EndIf;
  EndFor;

  // split the line the cursor is on to the next line
  If i<25;
    %subst(LINES(CSRF5+1):i:78-i)=
    %subst(LINES(CSRF5):(Col-1):(78-Col));
  Else;
    LINES(CSRF5+1)=%subst(LINES(CSRF5):
    (Col-1):(78-Col));
  EndIf;
  LINES(CSRF5)=%subst(LINES(CSRF5):
  1:(Col-2));

  // load lines back into sfl
  LINES2SF5();

  // positions the cursor back to the same spot
  *IN97 = *ON;

End-Proc;


// ***************************************************************
Dcl-Proc UNSPLITF5;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // load sfl back into lines
  SF52LINES();

  // make sure the rest of the line is blanks
  If %subst(LINES(CSRF5):Col-1:78-Col)<>' ';
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE REST OF THE +
    LINE MUST BE BLANK To +
    UN-SPLIT IT':78);
    Return;
  EndIf;

  // make sure the next line will fit on the current line after the cursor
  If (78-Col)<%len(%trim(LINES(CSRF5+1)));
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE NEXT LINE WILL +
    not FIT on THIS LINE':78);
    Return;
  EndIf;

  // add the next line to this line
  %subst(LINES(CSRF5):Col-1:78-Col)=
  %trim(LINES(CSRF5+1));

  // delete the next line
  For x=CSRF5+1 To 999;
    LINES(x)=LINES(x+1);
  EndFor;
  LINES(1000)=' ';

  // load lines back into sfl
  LINES2SF5();

  // positions the cursor back to the same spot
  *IN97 = *ON;

End-Proc;


// ***************************************************************
Dcl-Proc FMTF5;

  // load sfl back into lines
  SF52LINES();

  // build query into psname
  Clear psName;
  For x=1 To 1000;
    psName=%trim(psName) + ' ' +
      %trim(LINES(x));
  EndFor;

  Lines=#$FormatSQL(psName);

  // load lines back into sfl
  LINES2SF5();

End-Proc;


// ***************************************************************
Dcl-Proc SF52LINES;

  // load sfl back into lines
  Clear LINES;
  For x = 1 To NumRcF5;
    Chain x F5S;
    If not %found;
      Iter;
    EndIf;
    LINES(x) = SF5LINE;
  EndFor;

End-Proc;
// ***************************************************************
Dcl-Proc MOVEF5;

  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SqlVars;

  LINES2SF5();

End-Proc;


// *********************************************************************
Dcl-Proc LINES2SF5;

  // clear sfl
  *IN44 = *ON;
  Write F5C;
  *IN44 = *OFF;

  RRNF5=0;

  // fill sfl
  For x=1 To 1000;
    SF5Line=Lines(x);
    RRNF5+=1;
    Write F5S;
  EndFor;

  NumRcF5=RRNF5;

End-Proc;


// Validate Screen F5
Dcl-Proc VALDF5;

  againF5='';

  // validate sfl options
  For x = 1 To NumRcF5;
    Chain x F5S;
    If not %found;
      Iter;
    EndIf;

    If *in26;
      againF5='Y';
    EndIf;

  EndFor;

End-Proc;


// Update Screen F5
Dcl-Proc UPDTF5;
  Dcl-S errorPosition packed(5);
  Dcl-S errorLine packed(5);
  Dcl-S errorColumn packed(5);

  // moves the sfl back into the lines array
  SF52LINES();

  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *ALL SQLLSTR;
  EndIf;

  SQLLSTSV=SQLLSTDS;

  If %found;
    If SQLLSTDS<>SQLLSTSV;
      SQLLRUS=User;
      SQLLRWS=WsId;
      SQLLRDt=%dec(%char(%date():*ISO0):8:0);
      SQLLRTM=%dec(%char(%time():*hms0):6:0);
    EndIf;
    Update    SQLLSTR;
  EndIf;

  // update the sqldetpf file with the lines
  Exec SQL Delete From SQLDETPF
  Where SQDNAME=:SF1NAME and SQDENUS=:SF1ENUS;
  #$SQLSTT();
  // get last entry in lines array
  x=0;
  For i = 1000 DOWNTO 1;
    If LINES(i)<>' ';
      x = i;
      Leave;
    EndIf;
  EndFor;
  For i = 1 To x;
    Clear *ALL SQLDETR;
    SQDENUS=SF1ENUS;
    SQDNAME=SF1NAME;
    SQDSEQ =i;
    SQDLINE=LINES(i);
    Write SQLDETR;
  EndFor;

  // build the sql statement with variable overrides
  BLDSQL();

  If SQLSTMP<>'';
    Monitor;
      Exec SQL prepare sqlstmp from :SQLSTMP;
      #$SQLSTT();
    On-Error;
      // this tries to get the position of the error and set the cursor position to it the
      // db2 offset is the estimated position of the error, the statement is built without trimming
      // the lines so the line number can be calculated. Each line is 79 characters long because
      // we need a space between each one. So the line number is the statement divided by 79 and
      // remainder is the position on that line. We need to set the sfl cursor position to the line
      // number so the correct page is displayed and then set the cursor position.
      Exec SQL Get DIAGNOSTICS condition 1 :errorPosition = DB2_OFFSET;
      If errorPosition > 0;
        errorLine = %int(errorPosition/79) + 1;
        errorColumn = %rem(errorPosition:79);
        crnF5 = errorLine;
        Row = 6 + %rem(errorLine:16);
        Col = errorColumn;
        *in97 = *on;
      EndIf;

      ERM=#$Cntr(%trim(PSDSEXCDTA):78);
      EVAL *IN50=*ON;
    EndMon;
  Else;
    ERM=#$Cntr('ERROR - YOU MUST ENTER AN SQL STATEMENT.':78);
    *IN50 = *ON;
    Return;
  EndIf;

End-Proc;



// Process Screen F7
Dcl-Proc PROCF7;

  MOVEF7();
  DoW not *INLR;

    Exfmt F7;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF7();
    If *in50;
      Iter;
    EndIf;

    UPDTF7();

    Leave;
  EndDo;

End-Proc;


// Load Screen F7
Dcl-Proc MOVEF7;

  Clear F7;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  F7OUTP=SQLOUTP;

  // convert the vrtypes to f7 types
  If VRTYPE01='1';
    F7TYPE01='DEC ';
  ElseIf VRTYPE01='3';
    F7TYPE01='DATE';
  Else;
    F7TYPE01='CHAR';
  EndIf;
  If VRTYPE02='1';
    F7TYPE02='DEC ';
  ElseIf VRTYPE02='3';
    F7TYPE02='DATE';
  Else;
    F7TYPE02='CHAR';
  EndIf;
  If VRTYPE03='1';
    F7TYPE03='DEC ';
  ElseIf VRTYPE03='3';
    F7TYPE03='DATE';
  Else;
    F7TYPE03='CHAR';
  EndIf;
  If VRTYPE04='1';
    F7TYPE04='DEC ';
  ElseIf VRTYPE04='3';
    F7TYPE04='DATE';
  Else;
    F7TYPE04='CHAR';
  EndIf;
  If VRTYPE05='1';
    F7TYPE05='DEC ';
  ElseIf VRTYPE05='3';
    F7TYPE05='DATE';
  Else;
    F7TYPE05='CHAR';
  EndIf;
  If VRTYPE06='1';
    F7TYPE06='DEC ';
  ElseIf VRTYPE06='3';
    F7TYPE06='DATE';
  Else;
    F7TYPE06='CHAR';
  EndIf;
  If VRTYPE07='1';
    F7TYPE07='DEC ';
  ElseIf VRTYPE07='3';
    F7TYPE07='DATE';
  Else;
    F7TYPE07='CHAR';
  EndIf;
  If VRTYPE08='1';
    F7TYPE08='DEC ';
  ElseIf VRTYPE08='3';
    F7TYPE08='DATE';
  Else;
    F7TYPE08='CHAR';
  EndIf;
  If VRTYPE09='1';
    F7TYPE09='DEC ';
  ElseIf VRTYPE09='3';
    F7TYPE09='DATE';
  Else;
    F7TYPE09='CHAR';
  EndIf;
  If VRTYPE10='1';
    F7TYPE10='DEC ';
  ElseIf VRTYPE10='3';
    F7TYPE10='DATE';
  Else;
    F7TYPE10='CHAR';
  EndIf;

  // load variables, in71-80 are for display, 51-60 are for errors
  %subarr(*in:71:10)=*off;
  If VrName01<>'';
    *in71=*on;
  EndIf;
  If VrName02<>'';
    *in72=*on;
  EndIf;
  If VrName03<>'';
    *in73=*on;
  EndIf;
  If VrName04<>'';
    *in74=*on;
  EndIf;
  If VrName05<>'';
    *in75=*on;
  EndIf;
  If VrName06<>'';
    *in76=*on;
  EndIf;
  If VrName07<>'';
    *in77=*on;
  EndIf;
  If VrName08<>'';
    *in78=*on;
  EndIf;
  If VrName09<>'';
    *in79=*on;
  EndIf;
  If VrName10<>'';
    *in80=*on;
  EndIf;

End-Proc;


// Validate Screen F7
Dcl-Proc VALDF7;

  // make sure the output option is entered and valid
  If F7OUTP<>'1' and F7OUTP<>'2' and
  F7OUTP<>'3';
    *IN61 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTIon +
    ENTERED.':78);
    Return;
  EndIf;

  // test variable values
  For x=1 To 10;
    If VRNAME(x)<>' ';
      If VRDFT(x)=' ';
        F7ERRIND();
        ERM=#$Cntr('ERROR - YOU MUST ENTER A +
        VALUE':78);
        Return;
      EndIf;
      If VRTYPE(x)='2' and #$RVL(VRLEN(x))<>0 and
        %len(%trim(VRDFT(x)))>#$RVL(VRLEN(x));
        F7ERRIND();
        ERM=#$Cntr('ERROR - LENGTH MUST BE +
        <= ' + %trim(VRLEN(x)):78);
        Return;
      EndIf;
      If VRTYPE(x)='1' and not #$TESTN(VRDFT(x):1:1:1);
        F7ERRIND();
        ERM=#$Cntr('ERROR - VALUE MUST BE +
        NUMERIC':78);
        Return;
      EndIf;
      If VRTYPE(x)='3' and #$VDAT(#$RVL(VRDFT(x)));
        F7ERRIND();
        ERM=#$Cntr('ERROR - VALUE MUST BE A +
        DATE (YYYYDDMM)':78);
        Return;
      EndIf;
    EndIf;
  EndFor;

End-Proc;


// *********************************************************************
Dcl-Proc F7ERRIND;

  *IN50 = *ON;
  If x = 1;
    *in51=*on;
  ElseIf x = 2;
    *in52=*on;
  ElseIf x = 3;
    *in53=*on;
  ElseIf x = 4;
    *in54=*on;
  ElseIf x = 5;
    *in55=*on;
  ElseIf x = 6;
    *in56=*on;
  ElseIf x = 7;
    *in57=*on;
  ElseIf x = 8;
    *in58=*on;
  ElseIf x = 9;
    *in59=*on;
  ElseIf x = 10;
    *in60=*on;
  EndIf;

End-Proc;


// Update Screen F7
Dcl-Proc UPDTF7;

  If F7OUTP='1';
    DSPQUERY();
  EndIf;

  If F7OUTP='2';
    PROCF9();
  EndIf;

  If F7OUTP='3';
    PROCF8();
  EndIf;

End-Proc;


// *********************************************************************
Dcl-Proc DSPQUERY;

  // build the sql statement with variable overrides
  BLDSQL();

  // call the display program
  SQLCMDD2(SQLSTMP);

End-Proc;


// Process Screen F8
Dcl-Proc PROCF8;

  MOVEF8();
  DoW not *INLR;

    Exfmt F8;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
        KEY.':78);
      ITER;
    EndIf;

    VALDF8();
    If *in50;
      Iter;
    EndIf;

    UPDTF8();

    Leave;
  EndDo;

End-Proc;


// Load Screen F8
Dcl-Proc MOVEF8;

  Clear F8;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  F8EM01 = SQLEM01;
  F8EM02 = SQLEM02;
  F8EM03 = SQLEM03;
  F8EM04 = SQLEM04;
  F8RPID = SQLRPID;
  F8SUBJ = SQLSUBJ;
  F8ATTY = SQLATTY;
  F8MS01 = SQLMS01;
  F8MS02 = SQLMS02;
  F8MS03 = SQLMS03;
  F8MS04 = SQLMS04;
  F8MS05 = SQLMS05;
  F8MS06 = SQLMS06;
  F8MS07 = SQLMS07;
  F8MS08 = SQLMS08;
  F8MS09 = SQLMS09;
  F8MS10 = SQLMS10;
  F8FILE = SQLFILE;

  If F8EM01='*PROMPT';
    F8Em01='';
  EndIf;

  If F8ATTY=' ';
    F8ATTY='*XLS';
  EndIf;

  If F8INVR<'*YES';
    F8INVR='*NO ';
  EndIf;

  // pull default emails
  // If F8EM01='*USER' or F8EM01='*CURRENT'
  // or F8EM01=' ';
  //   Exec SQL Select ACEMAIL Into :F8EM01 From ACCESSPF Where ACUPRF=:USER;
  // EndIf;

End-Proc;


// Validate Acreen F8
Dcl-Proc VALDF8;

  // if * current is used in any of the email addresses replace it with
  // the email address from accesspf
  // If %trim(#$Upify(F8EM01))='*USER' or
  //   %trim(#$Upify(F8EM01))='*CURRENT';
  //   Exec SQL Select ACEMAIL Into :F8EM01 From ACCESSPF Where ACUPRF=:USER;
  // EndIf;
  // If %trim(#$Upify(F8EM02))='*USER' or
  // %trim(#$Upify(F8EM02))='*CURRENT';
  //   Exec SQL Select ACEMAIL Into :F8EM02 From ACCESSPF Where ACUPRF=:USER;
  // EndIf;
  // If %trim(#$Upify(F8EM03))='*USER' or
  // %trim(#$Upify(F8EM03))='*CURRENT';
  //   Exec SQL Select ACEMAIL Into :F8EM03 From ACCESSPF Where ACUPRF=:USER;
  // EndIf;
  // If %trim(#$Upify(F8EM04))='*USER' or
  //   %trim(#$Upify(F8EM04))='*CURRENT';
  //   Exec SQL Select ACEMAIL Into :F8EM04 From ACCESSPF Where ACUPRF=:USER;
  // EndIf;

  // entry make sure the email address is valid
  If F8EM01<>' ' and #$VEML(F8EM01);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
      EMAIL.':78);
    Return;
  EndIf;

  If F8EM02<>' ' and #$VEML(F8EM02);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
      EMAIL.':78);
    Return;
  EndIf;

  If F8EM03<>' ' and #$VEML(F8EM03);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
      EMAIL.':78);
    Return;
  EndIf;

  If F8EM04<>' ' and #$VEML(F8EM04);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    EMAIL.':78);
    Return;
  EndIf;

  // make sure an email address or report dist id is entered
  If F8EM01=' ' and F8RPID=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTERE AN +
    EMAIL or RPT DIST ID.':78);
    Return;
  EndIf;

  // validate the attachment type
  If F8ATTY<>'*XLS' and F8ATTY<>'*CSV' and
        F8ATTY<>'*XML' and F8ATTY<>'*PDF' and
    F8ATTY<>'*JSON';
    *IN56 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID ATTACHEMNT +
      TYPE.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F8
Dcl-Proc UPDTF8;

  If F8ATTY='*PDF';
    UPDTF8PDF();
    Return;
  EndIf;

  // build the sql statement with variable overrides
  BLDSQL();

  // build a command to email the query
  cmd='EMLSQL SQL(''' + %trim(#$DBLQ(SQLSTMP)) + ''') +
              FILE(''' + %trim(F8FILE) + ''') +
              TYPE(' + %trim(F8ATTY) + ') +
              EMAIL( ';

  If F8EM01<>' ';
    cmd+=' (' + %trim(F8EM01) + ')';
  EndIf;
  If F8EM02<>' ';
    cmd+=' (' + %trim(F8EM02) + ')';
  EndIf;
  If F8EM03<>' ';
    cmd+=' (' + %trim(F8EM03) + ')';
  EndIf;
  If F8EM04<>' ';
    cmd+=' (' + %trim(F8EM04) + ')';
  EndIf;
  // add emails from a report distribtuion id if entered
  If F8RPID<>' ';
    GetEmailsFromRPT(F8RpId:Emails);
    cmd+=' ' + %trim(Emails);
  EndIf;

  cmd+=' )';

  If F8SUBJ<>' ';
    cmd+=' SUBJECT(''' + #$DblQ(F8SUBJ) + ''')';
  EndIf;

  Clear message;
  If F8MS01<>' ';
    message+=#$DblQ(F8MS01)+'<br>';
  EndIf;
  If F8MS02<>' ';
    message+=#$DblQ(F8MS02)+'<br>';
  EndIf;
  If F8MS03<>' ';
    message+=#$DblQ(F8MS03)+'<br>';
  EndIf;
  If F8MS04<>' ';
    message+=#$DblQ(F8MS04)+'<br>';
  EndIf;
  If F8MS05<>' ';
    message+=#$DblQ(F8MS05)+'<br>';
  EndIf;
  If F8MS06<>' ';
    message+=#$DblQ(F8MS06)+'<br>';
  EndIf;
  If F8MS07<>' ';
    message+=#$DblQ(F8MS07)+'<br>';
  EndIf;
  If F8MS08<>' ';
    message+=#$DblQ(F8MS08)+'<br>';
  EndIf;
  If F8MS09<>' ';
    message+=#$DBLQ(F8MS09)+'<br>';
  EndIf;
  If F8MS10<>' ';
    message+=#$DblQ(F8MS10)+'<br>';
  EndIf;
  If F8INVR='*YES';
    message+='<br>Variable overrides:<br>';
    For i=1 To 10;
      If VRNAME(i)<>' ';
        message+=VRNAME(i) +' = ' + VRDFT(i) + '<br>';
      EndIf;
    EndFor;
  EndIf;
  If message<>' ';
    cmd+=' MESSAGE(''' + message + ''' *TEXTHTML)';
  EndIf;

  #$Cmd(cmd:2);

End-Proc;


// *********************************************************************
Dcl-Proc UPDTF8PDF;

  // build the sql statement with variable overrides
  BLDSQL();

  // override and hard code some of the print variables
  psUsDt='SQL'+%trim(%char(%date():*ISO0));

  psTitle1=SQLDesc;
  psPInVr=SqlPInVr;
  If PSPINVR<>'*YES';
    psPInVr='*NO ';
  EndIf;

  psPInQy=SqlPInQy;
  If PSPINQY<>'*YES';
    psPInQy='*NO ';
  EndIf;

  psHold='*YES';
  psSave='*NO ';

  psCopy=1;

  psFrWd=SqlFrWd;
  If psFrWd=0;
    psFrWd=132;
  EndIf;


  psFrLn=sqlFrLn;
  If psFrLn=0;
    psFrLn=66;
  EndIf;

  #$VARS=psVrIn;
  #$OUTQ  = 'TRASH';
  #$OQLB  = 'QGPL';
  #$COPY  = psCopy;
  #$HOLD  = psHold;
  #$SAVE  = psSave;
  #$USDT  = psUsDt;
  #$FRLN  = psFrLn;
  #$FRWD  = psFrWd;
  #$INVR  = psPInVr;
  #$INQY  = psPInQy;
  #$TITLE1 = psTitle1;
  #$TITLE2 = psTitle2;
  #$TITLE3 = psTitle3;
  #$TITLE4 = psTitle4;
  #$TITLE5 = psTitle5;
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
    #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME);

  // convert the output file to a pdf
  psFile=F8File;

  // if the file name is blank build one
  If psFile=' ';
    psFile='SQL'+%trim(WSID) +
      %trim(%char(%date():*ISO0))+%trim(%char(%time():*HMS0));
  EndIf;

  objPath='/ACOM/EMAIL/TMP/'+%trim(psFile);

  // add .pdf extension if not already on there
  If #$Upify(#$Last(objPath:4)) <>'.PDF';
    objPath=%trim(objPath)+'.PDF';
  EndIf;

  // convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMDO1) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
  %trim(objPath) + ''') WSCST(*PDF)':2);

  // delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMDO1) SPLNBR(*LAST)':2);

  // build a command to email the query
  cmd='GUMBOMAIL/GSENDMAIL TOSMTPNAME(';

  If F8EM01<>' ';
    cmd+=' (' + %trim(F8EM01) + ')';
  EndIf;
  If F8EM02<>' ';
    cmd+=' (' + %trim(F8EM02) + ')';
  EndIf;
  If F8EM03<>' ';
    cmd+=' (' + %trim(F8EM03) + ')';
  EndIf;
  If F8EM04<>' ';
    cmd+=' (' + %trim(F8EM04) + ')';
  EndIf;
  // add emails from a report distribtuion id if entered
  If F8RPID<>' ';
    GetEmailsFromRPT(f8RpId:Emails);
    cmd+=' ' + %trim(Emails);
  EndIf;
  cmd+=' )';

  If F8SUBJ<>' ';
    cmd+=' SUBJECT(''' + #$DblQ(F8SUBJ) +''')';
  EndIf;

  message='';
  If F8MS01<>' ';
    message+=#$DblQ(F8MS01)+'<br>';
  EndIf;
  If F8MS02<>' ';
    message+=#$DblQ(F8MS02)+'<br>';
  EndIf;
  If F8MS03<>' ';
    message+=#$DblQ(F8MS03)+'<br>';
  EndIf;
  If F8MS04<>' ';
    message+=#$DblQ(F8MS04)+'<br>';
  EndIf;
  If F8MS05<>' ';
    message+=#$DblQ(F8MS05)+'<br>';
  EndIf;
  If F8MS06<>' ';
    message+=#$DblQ(F8MS06)+'<br>';
  EndIf;
  If F8MS07<>' ';
    message+=#$DblQ(F8MS07)+'<br>';
  EndIf;
  If F8MS08<>' ';
    message+=#$DblQ(F8MS08)+'<br>';
  EndIf;
  If F8MS09<>' ';
    message+=#$DblQ(F8MS09)+'<br>';
  EndIf;
  If F8MS10<>' ';
    message+=#$DblQ(F8MS10)+'<br>';
  EndIf;
  If F8INVR='*YES';
    message+='<br>Variable overrides:<br>';
    For i=1 To 10;
      If VRNAME(i)<>' ';
        message+=VRNAME(i) + ' = ' + VRDFT(i) + '<br>';
      EndIf;
    EndFor;
  EndIf;
  If message<>' ';
    cmd+=' MSG(''' + message + ''' *TEXTHTML)';
  EndIf;

  // append created pdf file
  cmd+=' OBJ( (''' + %trim(objPath) + ''' *ATTACHPDF ) )';

  // append from address if it is populate
  // If ACEMAIL<>' ';
  //   cmd+=' FROM(''' + %trim(ACEMAIL) + ''')';
  // EndIf;

  #$Cmd(cmd:2);

End-Proc;


// Process Screen F9
Dcl-Proc PROCF9;

  MOVEF9();
  DoW not *INLR;

    Exfmt F9;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF9();
    If *in50;
      Iter;
    EndIf;

    UPDTF9();

    Leave;
  EndDo;

End-Proc;


// Load Screen F9
Dcl-Proc MOVEF9;

  Clear F9;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *ALL SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs   =  SQLVARS;
  F9OUTQ   =  SQLOUTQ;
  F9OQLB   =  SQLOQLB;
  F9COPY   =  SQLCOPY;
  F9HOLD   =  SQLHOLD;
  F9SAVE   =  SQLSAVE;
  F9USDT   =  SQLUSDT;
  F9FRLN   =  SQLFRLN;
  F9FRWD   =  SQLFRWD;
  F9TITLE1 =  SQLTITL1;
  F9TITLE2 =  SQLTITL2;
  F9TITLE3 =  SQLTITL3;
  F9TITLE4 =  SQLTITL4;
  F9TITLE5 =  SQLTITL5;
  If F9TITLE1=' ';
    F9title1= SQLDESC;
  EndIf;
  f9PinVr = SQLPINVR;
  f9PinQy = SQLPINQY;

  // get the jobs output queue if not already populated
  If F9OUTQ=' ';
    GetOutQ(f9outq:f9oqlb);
  EndIf;
  If F9COPY=0;
    f9copy=1;
  EndIf;
  If F9HOLD<>'*YES';
    F9HOLD= '*NO ';
  EndIf;
  If F9SAVE<>'*YES';
    F9SAVE= '*NO ';
  EndIf;
  If F9USDT=' ';
    F9USDT=SF1NAME;
  EndIf;
  If F9FRLN=0;
    F9FRLN=66;
  EndIf;
  If F9FRWD=0;
    F9FRWD=132;
  EndIf;

End-Proc;


// Validate Screen F9
Dcl-Proc VALDF9;

  If F9TITLE1=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
    REPORT TITLE.':78);
    Return;
  EndIf;

  // make sure the output queue is valid
  If F9OUTQ<>' ' and F9OUTQ<>'*JOB';
    If F9OQLB=' ';
      F9OQLB='*LIBL';
    EndIf;
    If not #$ISOUTQ(F9OUTQ:F9OQLB);
      *IN52 = *ON;
      *IN50 = *ON;
      ERM=#$Cntr('ERROR - INVALID OR MISSING +
      OUTPUT QUEUE.':78);
      Return;
    EndIf;
  EndIf;

  If F9COPY<1 or F9COPY>255;
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - COPIES MUST BE +
    BETWEEN 1 and 255.':78);
    Return;
  EndIf;

  If F9HOLD<>'*YES' and F9HOLD<>'*NO';
    *IN54 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - MUST BE *YES or +
    *NO.':78);
    Return;
  EndIf;

  If F9SAVE<>'*YES' and F9SAVE<>'*NO';
    *IN55 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - MUST BE *YES or +
    *NO.':78);
    Return;
  EndIf;

  // default user data if not passed
  If F9USDT=' ';
    F9UsDt=SqlName;
  EndIf;

End-Proc;


// Update Screen F9
Dcl-Proc UPDTF9;

  // build the sql statement with variable overrides
  BLDSQL();

  #$VARS  = SQLVARS;
  #$OUTQ  = F9OUTQ;
  #$OQLB  = F9OQLB;
  #$COPY  = F9COPY;
  #$HOLD  = F9HOLD;
  #$SAVE  = F9SAVE;
  #$USDT  = F9USDT;
  #$FRLN  = F9FRLN;
  #$FRWD  = F9FRWD;
  #$INVR  = F9PINVR;
  #$INQY  = F9PINQY;
  #$TITLE1 = F9TITLE1;
  #$TITLE2 = F9TITLE2;
  #$TITLE3 = F9TITLE3;
  #$TITLE4 = F9TITLE4;
  #$TITLE5 = F9TITLE5;
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
  #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME);

  Return;

  Exec SQL prepare sqlstmp from :SQLSTMP2;
  #$SQLSTT();

  // override the print file with the print options
  cmd='OVRPRTF QPQUPRFIL';
  If F9OUTQ='*JOB';
    cmd+=' OUTQ(*JOB)';
  Else;
    cmd+=' OUTQ(' + %trim(F9OQLB) +'/'+ %trim(F9OUTQ)+')';
  EndIf;
  If F9FRLN<>0 or F9FRWD<>0;
    cmd+=' PAGESIZE(';
    If F9FRLN<>0;
      cmd+= %trim(%char(F9FRLN));
    Else;
      cmd+='*N';
    EndIf;
    If F9FRWD<>0;
      cmd+=' '+ %trim(%char(F9FRWD));
    Else;
      cmd+=' *N';
    EndIf;
    cmd+=')';
  EndIf;
  If F9COPY<>0;
    cmd+= ' COPIES(' + %trim(%char(F9COPY)) + ')';
  EndIf;
  cmd+=' HOLD(' + %trim(F9HOLD) + ')';
  cmd+=' SAVE(' +  %trim(F9SAVE) + ')';
  If F9USDT=' ';
    cmd+=' USRDTA(' +  %trim(SF1NAME) +')';
  Else;
    cmd+=' USRDTA(' + %scanrpl(' ':'_':%trim(F9USDT)) +')';
  EndIf;
  cmd+=' OVRSCOPE(*JOB)';
  #$Cmd(cmd);

  // build the command to print the report
  cmd='RUNQRY QRYFILE((QTEMP/WORKTABLE)) OUTTYPE(*PRINTER)';

  // run a query over the output file
  #$Cmd(cmd);

  // delete the override of the print file
  #$Cmd('DLTOVR QPQUPRFIL LVL(*JOB)');

End-Proc;


// Process F10
Dcl-Proc PROCF10;


  CurLast=0;

  MOVEF10();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF10=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF10<=0 or CRNF10>RRNF10;
      CRNF10=1;
    EndIf;
    Write F10F;
    Exfmt F10C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    If CSRF10=0;
      If *in46;
        CRNF10=NumRcF10;
      Else;
        CRNF10=1;
      EndIf;
    Else;
      CRNF1-=CSRF10;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // f4=field list
    If *IN04;
      DSPFLDF10();
      ITER;
    EndIf;

    // f6=insert line
    If *IN06;
      INSF10();
      ITER;
    EndIf;

    // f7=format
    If *IN07;
      FMTF10();
      ITER;
    EndIf;

    // f9=last
    If *IN09;
      LOADLAST();
      ITER;
    EndIf;

    // f10=copy line
    If *IN10;
      CPYF10();
      ITER;
    EndIf;

    // f11=save
    If *IN11;
      PROCF16();
      If *in12;
        Iter;
      EndIf;
      PROCF3();
      PROCF1();
      *INLR = *ON;
      Return;
    EndIf;

    // f14=delete line
    If *IN14;
      DELF10();
      POSCUR();
      ITER;
    EndIf;

    // f15=split line
    If *IN15;
      SPLITF10();
      ITER;
    EndIf;

    // f16=un-split line
    If *IN16;
      UNSPLITF10();
      ITER;
    EndIf;

    // f21=lookuplast
    If *IN21;
      PROCF11();
      MOVEF10();
      ITER;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('Error - Invalid function  key.':78);
      ITER;
    EndIf;

    VALDF10();
    If *in50;
      Iter;
    EndIf;

    UPDTF10();
    If *in50;
      Iter;
    EndIf;

    MOVEF10();
  EndDo;

End-Proc;


// ***************************************************************
Dcl-Proc DSPFLDF10;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // get the line the cursor is on
  // use the cursor location to find the word the cursor is on,
  // if the word is a file default to that file, otherwise see
  // if there is a file name in any of the words on the line.
  // otherwise scan the query for the First file name, but also
  // build a list of all file names found.

  Clear tpLib;
  Clear tpFile;
  Clear crLib;
  Clear crFile;
  Clear lnFile;
  Clear lnLib;
  Clear temp21;
  Clear FILES;
  Clear FILDSC;
  Clear WORDS;
  FILECNT=0;
  strPos=0;
  endPos=0;

  // find the word the cursor is on
  Chain CSRF10 F10S;
  If %found;
    // skip if the cursor is on a blank space
    // find the file name the cursor is on
    strPos=#$SCANR(' ':SF10LINE:Col-1)+1;
    endPos=%scan(' ':SF10LINE:Col-1);
    If strPos=0;
      strPos=1;
    EndIf;
    If endPos=0;
      endPos=78;
    EndIf;
    endPos=endPos-strPos+1;
    temp21=%subst(SF10LINE:strPos:endPos);
    If %scan('/':temp21)>0;
      crLib=%subst(temp21:1:%scan('/':temp21)-1);
      crFile=%subst(temp21:%scan('/':temp21)+1:10);
    Else;
      crLib='*LIBL';
      crFile=temp21;
    EndIf;
    If not #$ISFILE(crFile:crLib);
      crFile='';
    EndIf;

    // find the First file name on the line the cursor is on
    WORDS=#$SPLIT(SF10LINE);
    For x=1 To 50;
      If WORDS(x)<>' ';
        If %scan('/':WORDS(x))>0;
          tpLib=%subst(WORDS(x):1:
          %scan('/':WORDS(x))-1);
          tpFile=%subst(WORDS(x):
          %scan('/':WORDS(x))+1:10);
        Else;
          tpLib='*LIBL';
          tpFile=WORDS(x);
        EndIf;
        If #$ISFILE(tpFile:tpLib);
          lnFile=tpFile;
          lnLib=tpLib;
          Leave;
        EndIf;
      Else;
        Leave;
      EndIf;
    EndFor;
  EndIf;

  // loop through the sfl and find all files in the statement
  For x=1 To NumRcF10;
    Chain x F10S;
    If not %found;
      Iter;
    EndIf;
    WORDS=#$SPLIT(SF10LINE);
    For y=1 To 50;
      If WORDS(y)=' ';
        Leave;
      EndIf;
      If %scan('/':WORDS(y))>0;
        tpLib=%subst(WORDS(y):1:
        %scan('/':WORDS(y))-1);
        tpFile=%subst(WORDS(y):
        %scan('/':WORDS(y))+1:10);
      Else;
        tpLib='*LIBL';
        tpFile=WORDS(y);
      EndIf;
      If #$ISFILE(tpFile:tpLib);
        FILECNT+=1;
        FILES(FILECNT)=tpFile;
        LIBS(FILECNT)=tpLib;
      EndIf;
    EndFor;
  EndFor;

  If CRFILE<>' ';
    F12File=crFile;
    F12Lib=crLib;
  ElseIf LNFILE<>' ';
    F12File=lnFile;
    F12Lib=lnLib;
  Else;
    F12File='*ALL';
    F12Lib='';
  EndIf;

  // move sfl to lines array
  SF102LINES();

  CsrPos=CsrF10;
  PROCF12();

  // set on 97 to postition the cursor back to the exact place it was
  // when the f4 was pressed
  *IN97 = *ON;

  // move lines array back to sfl
  MOVEF10();

End-Proc;


// ***************************************************************
Dcl-Proc INSF10;

  // load sfl back into lines
  SF102LINES();

  // use the line the cursor is on and move the rest down one
  For x=999 by 1 DOWNTO CSRF10+1;
    LINES(x+1)=LINES(x);
    LINES(x)=' ';
  EndFor;

  // Position the cursor to the inserted row
  CRNF10 = CSRF10 + 1;

  // load lines back into sfl
  MOVEF10();

End-Proc;


// ***************************************************************
Dcl-Proc CPYF10;

  // load sfl back into lines
  SF102LINES();

  // use the line the cursor is on and move the rest down one
  For x=999 by 1 DOWNTO CSRF10;
    LINES(x+1)=LINES(x);
  EndFor;

  // Position the cursor to the inserted row
  CRNF10 = CSRF10 + 1;

  // load lines back into sfl
  MOVEF10();

End-Proc;


// ***************************************************************
Dcl-Proc DELF10;

  // load sfl back into lines
  SF102LINES();

  // use the line the cursor is on and move the rest up one
  For x=CSRF10 To 999;
    LINES(x)=LINES(x+1);
  EndFor;
  LINES(1000)=' ';

  // Position the cursor
  CRNF10 = CSRF10;

  // load lines back into sfl
  MOVEF10();

End-Proc;


// ***************************************************************
Dcl-Proc SPLITF10;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // load sfl back into lines
  SF102LINES();

  // insert a line after the cursor
  For x=999 by 1 DOWNTO CSRF10;
    LINES(x+1)=LINES(x);
  EndFor;

  // get the number of spaces on the line to save the indention
  For i=1 To 78;
    If %subst(LINES(CSRF10):i:1)<>' ';
      Leave;
    EndIf;
  EndFor;

  // split the line the cursor is on to the next line
  If i<25;
    %subst(LINES(CSRF10+1):i:78-i)=
      %subst(LINES(CSRF10):(Col-1):(78-Col));
  Else;
    LINES(CSRF10+1)=%subst(LINES(CSRF10):
      (Col-1):(78-Col));
  EndIf;
  LINES(CSRF10)=%subst(LINES(CSRF10):
  1:(Col-2));

  // Position the cursor
  CRNF10 = CSRF10;

  // load lines back into sfl
  MOVEF10();

  // positions the cursor back to the same spot
  *IN97 = *ON;

End-Proc;


// ***************************************************************
Dcl-Proc UNSPLITF10;

  // get the row and column the cursor is on
  #$Bin2=0;
  #$BinC=#$Row;
  Row=#$Bin2;
  #$BinC=#$Col;
  Col=#$Bin2;

  // load sfl back into lines
  SF102LINES();

  // make sure the rest of the line is blanks
  If %subst(LINES(CSRF10):Col-1:78-Col)<>' ';
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE REST OF THE +
      LINE MUST BE BLANK To +
    UN-SPLIT IT':78);
    Return;
  EndIf;

  // make sure the next line will fit on the current line after the cursor
  If (78-Col)<%len(%trim(LINES(CSRF10+1)));
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE NEXT LINE WILL +
    not FIT on THIS LINE':78);
    Return;
  EndIf;

  // add the next line to this line
  %subst(LINES(CSRF10):Col-1:78-Col)=
  %trim(LINES(CSRF10+1));

  // delete the next line
  For x=CSRF10+1 To 999;
    LINES(x)=LINES(x+1);
  EndFor;
  LINES(1000)=' ';

  // Position the cursor
  CRNF10 = CSRF10;

  // load lines back into sfl
  MOVEF10();

  // positions the cursor back to the same spot
  *IN97 = *ON;

End-Proc;


// ***************************************************************
Dcl-Proc FMTF10;

  // load sfl back into lines
  SF102LINES();

  // build query into psname
  psName='';
  For x=1 To 300;
    psName=%trim(psName) + ' ' +
    %trim(LINES(x));
  EndFor;

  Lines=#$FormatSQL(psName);

  // load lines back into sfl
  MOVEF10();

End-Proc;


// Load Screen F10
Dcl-Proc MOVEF10;

  // clear sfl
  *IN44 = *ON;
  Write F10C;
  *IN44 = *OFF;

  RRNF10=0;

  // fill sfl
  For x=1 To 300;
    SF10Line=Lines(x);
    RRNF10+=1;
    Write F10S;
  EndFor;

  NumRcF10=RRNF10;

End-Proc;


// Validate Screen F10
Dcl-Proc VALDF10;
  Dcl-S errorPosition packed(5);
  Dcl-S errorLine packed(5);
  Dcl-S errorColumn packed(5);

  againF10='';

  // load sfl into lines array
  SF102LINES();

  // build the sql statement
  Clear SQLSTMP;
  For x=1 To 300;
    SQLSTMP += ' ' + LINES(x);
  EndFor;

  Monitor;
    Exec SQL prepare sqlstmp from :SQLSTMP;
    #$SQLSTT();
  On-Error;
    // this tries to get the position of the error and set the cursor position to it the
    // db2 offset is the estimated position of the error, the statement is built without trimming
    // the lines so the line number can be calculated. Each line is 79 characters long because
    // we need a space between each one. So the line number is the statement divided by 79 and
    // remainder is the position on that line. We need to set the sfl cursor position to the line
    // number so the correct page is displayed and then set the cursor position.
    Exec SQL Get DIAGNOSTICS condition 1 :errorPosition = DB2_OFFSET;
    If errorPosition > 0;
      // subtract 43 posisiton for the CREATE OR REPLACE TABLE... logic
      // errorPosition -= 43;
      errorLine = %int(errorPosition/79) + 1;
      errorColumn = %rem(errorPosition:79);
      crnF10 = errorLine;
      Row = 3 + %rem(errorLine:16);
      Col = errorColumn;
      *in97 = *on;
    EndIf;
    // set error message to the exception data
    ERM=#$Cntr(%trim(PSDSEXCDTA):78);
    EVAL *IN50=*ON;
  EndMon;

End-Proc;


// *********************************************************************
Dcl-Proc SF102LINES;

  // check sfl for options entered
  Clear Lines;
  For xF10= 1 To NumRcF10;
    Chain xF10 F10S;
    If not %found;
      Iter;
    EndIf;
    Lines(xF10)=SF10Line;
  EndFor;

End-Proc;


// Update Screen F10
Dcl-Proc UPDTF10;

  // save the query as the last one run
  CurLast=0;

  svLines=LINES;

  // if the sql statement is not the same as the last run,
  // create a new #$lst save and move the rest down one.
  Sf1EnUs = USER;
  Sf1Name = '#$LST00001';
  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If %found;
    LOADLINES();
  EndIf;
  If not %found or SVLINESDS<>LINESDS;
    SAVELAST();
  EndIf;
  Lines=SvLines;

  // call the display program
  //                  monitor
  SQLCMDD2(SQLSTMP);
  //                  on-error
  //                  eval      *in50=*on
  //                  eval      erm=#$cntr('error occured in display +
  //                                        program':50)
  //                  endmon

End-Proc;


// Save Last AdHoc Query
Dcl-Proc SAVELAST;

  // read backwards through last records and add 1 to each one.
  // delete any numbered over 1000
  Sf1EnUs = USER;
  Sf1Name = '#$LST99999';
  SetGT (SF1ENUS:SF1NAME) SQLLSTPF;
  ReadPE USER SQLLSTPF;
  DoW not %eof;
    If %subst(SQLNAME:1:5)<>'#$LST';
      UNLOCK SQLLSTPF;
      Leave;
    EndIf;
    temp50=#$Rvl(%subst(sqlName:6:5));
    If TEMP50>999;
      Delete SQLLSTR;
    Else;
      temp50+=1;
      %subst(SQLNAME:6:5)=%editc(temp50:'X');
      Update SQLLSTR;
    EndIf;
    ReadPE USER SQLLSTPF;
  EndDo;

  Sf1EnUs = USER;
  Sf1Name = '#$LST99999';
  SetGT (SF1ENUS:SF1NAME) SQLDETPF;
  ReadPE USER SQLDETPF;
  DoW not %eof;
    If %subst(SQDNAME:1:5)<>'#$LST';
      UNLOCK SQLDETPF;
      Leave;
    EndIf;
    temp50=#$Rvl(%subst(sqdName:6:5));
    If TEMP50>999;
      Delete SQLDETR;
    Else;
      temp50+=1;
      %subst(SQDNAME:6:5)=%editc(temp50:'X');
      Update SQLDETR;
    EndIf;
    ReadPE USER SQLDETPF;
  EndDo;

  // add new last entry
  Clear *ALL SQLLSTR;
  SQLDLT='L';
  SQLNAME='#$LST00001';
  SQLDESC='SAVED ADHOC QUERY';
  SQLOUTP='1';
  SQLENUS= USER;
  SQLENWS=WSID;
  SQLENDT=%dec(%char(%date():*ISO0):8:0);
  SQLENTM=%dec(%char(%time():*hms0):6:0);
  Write SQLLSTR;

  // add new last entry detail lines

  // get last entry in lines array
  For i = 1000 DOWNTO 1;
    If SVLINES(i)<>' ';
      x = i;
      Leave;
    EndIf;
  EndFor;

  For i = 1 To x;
    Clear *ALL SQLDETR;
    SQDENUS=SQLENUS;
    SQDNAME=SQLNAME;
    SQDSEQ =i;
    SQDLINE=SVLINES(i);
    Write SQLDETR;
  EndFor;

End-Proc;


// *********************************************************************
Dcl-Proc LOADLAST;

  // read backwards through last records and add 1 to each one.
  // delete any numbered over 1000
  CurLast+=1;
  Sf1EnUs = USER;
  Sf1Name = '#$LST' + %editc(CurLast:'X');
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    ERM=#$Cntr('NO MORE ENTRIES FOUND':78);
    *IN50 = *ON;
    Return;
  EndIf;

  LOADLINES();

  // load lines back into sfl
  MOVEF10();

End-Proc;


// Process F11
Dcl-Proc PROCF11;

  Clear LINES;
  MOVEF11();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF11=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF11<=0 or CRNF11>RRNF11;
      CRNF11=1;
    EndIf;
    Write F11F;
    Exfmt F11C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';
    If CSRF11=0;
      If *in46;
        CRNF11=NumRcF11;
      Else;
        CRNF11=1;
      EndIf;
    Else;
      CRNF11=CSRF11;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
      BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF11();
    If *in50;
      Iter;
    EndIf;

    UPDTF11();
    If *in50;
      Iter;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Lod Screen F11
Dcl-Proc MOVEF11;

  // clear sfl
  *IN44 = *ON;
  Write F11C;
  *IN44 = *OFF;

  RRNF11=0;
  Clear Select;

  // loop through all last entries
  SF1ENUS=USER;
  SF1NAME='#$LST00000';
  SetLL (SF1ENUS:SF1NAME) SQLLSTPF;
  ReadE(N) USER SQLLSTPF;
  DoW not %eof;
    If %subst(SQLNAME:1:5)<>'#$LST';
      Leave;
    EndIf;

    SF11Name=SQLName;
    SF1Name=SQLName;
    // add the First 3 lines
    LOADLINES();
    *IN83 = *OFF;
    SF11LINE= Lines(1);
    RRNF11+=1;
    Write F11S;
    *IN83 = *ON;
    SF11LINE= Lines(2);
    RRNF11+=1;
    Write F11S;
    SF11LINE= Lines(3);
    If LINES(4)<>' ';
      SF11LINE= '...';
    EndIf;
    RRNF11+=1;
    Write F11S;
    RRNF11+=1;

    ReadE(N) USER SQLLSTPF;
  EndDo;

  NumRcF11=RRNF11;

End-Proc;


// Validate Screen F11
Dcl-Proc VALDF11;

  againF11='';

  // validate sfl options
  For x = 1 To NumRcF11;
    Chain x F11S;
    If not %found;
      Iter;
    EndIf;

    If *in26;
      againF11='Y';
    EndIf;

  EndFor;

End-Proc;


// Update Screen F11
Dcl-Proc UPDTF11;

  // check sfl for options entered
  For xF11 = 1 To NumRcF11;
    Chain xF11 F11S;
    If not %found;
      Iter;
    EndIf;

    If Select<>' ';
      SF1Enus=User;
      Sf11Name=Sf1Name;
      Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
      If %found;
        LOADLINES();
        Leave;
      EndIf;
    EndIf;

  EndFor;

End-Proc;


// Process Screen F12
Dcl-Proc PROCF12;

  MOVEF12();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF12=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF12<=0 or CRNF12>RRNF12;
      CRNF12=1;
    EndIf;
    Write F12F;
    Exfmt F12C;
    %subarr(*IN:50:9) = *OFF;
    Erm='';
    If CSRF12=0;
      If *in46;
        CRNF12=NumRcF12;
      Else;
        CRNF12=1;
      EndIf;
    Else;
      CRNF12=CSRF12;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
        BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    // handle all searches
    SRCHF12();
    If againF12='Y';
      MOVEF12();
      ITER;
    EndIf;

    VALDF12();
    If *in50;
      Iter;
    EndIf;
    If *IN25;
      MOVEF12();
      ITER;
    EndIf;

    UPDTF12();
    If RRNF15>0;
      PROCF15();
      If *in12;
        Iter;
      EndIf;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// ***************************************************************
Dcl-Proc SRCHF12;

  againF12='';

  // search file
  If %scan('?':F12FILE)>0;
    PROCF13();
    againF12='Y';
  EndIf;

End-Proc;


// Load Screen F12
Dcl-Proc MOVEF12;

  // clear sfl
  *IN44 = *ON;
  Write F12C;
  *IN44 = *OFF;


  Clear Select;
  RRNF12=0;
  Sf12Len2=0;

  If F12LIB=' ';
    F12LIB='*LIBL';
  EndIf;

  // if the file name is all, add each file in the files array
  If F12FILE='*ALL';
    For i=1 To FILECNT;
      If FILES(i)<>' ';
        F12File2=FILES(i);
        F12Lib2=LIBS(i);
        ADDFILF12();
      EndIf;
    EndFor;
  Else;
    F12File2=F12File;
    F12Lib2=F12Lib;
    ADDFILF12();
  EndIf;

  NumRcF12=RRNF12;

End-Proc;


// *********************************************************************
Dcl-Proc ADDFILF12;

  // skip if not a valid file
  If not #$ISFILE(F12File2:F12Lib2);
    NumRcF12=RRNF12;
    Return;
  EndIf;


  // build field list in qtemp/fieldlist
  #$Cmd('DSPFFD ' + %trim(F12Lib2) + '/' + %trim(F12File2) +
  ' OUTPUT(*OUTFILE) OUTFILE(QTEMP/FIELDLIST)':1);

  SQLSTMF12='SELECT WHFLDE, WHIBO, WHFLDB, WHFLDD, WHFLDP, WHFTXT, +
  WHFLDT, WHFIOB +
  From   QTEMP/FIELDLIST';

  // add search if entered
  If F12SRCH<>' ';
    #$BLDSCHF(01)='WHFLDE';
    #$BLDSCHF(02)='WHIBO';
    #$BLDSCHF(03)='WHFLDB';
    #$BLDSCHF(04)='WHFLDD';
    #$BLDSCHF(05)='WHFLDP';
    #$BLDSCHF(06)='WHFTXT';
    #$BLDSCHF(07)='WHFLDT';
    #$BLDSCHF(08)='WHFIOB';
    SQLSTMF12+=' WHERE ' + #$BLDSCH(F12SRCH:#$BLDSCHF);
  EndIf;

  // populate sfl from qtemp/fieldlist
  Exec SQL Prepare SQLF12 From :SQLSTMF12;
  Exec SQL Declare SQLCRSF12 Cursor For SQLF12;
  Exec SQL Open SQLCRSF12;
  Exec SQL Fetch Next From SQLCRSF12
  Into :SF12FLD,:SF12BUF,:SF12LEN,:Sf12Len2,:SF12DEC,:SF12TXT,
  :SF12TYP,:SF12USE;
  DoW not #$SQLSTT();
    If SF12LEN2<>0;
      SF12LEN=Sf12Len2;
    EndIf;
    If SF12TYP='P' or SF12TYP='S' or SF12TYP='I';
      EVALR SF12DECA=%trim(%char(SF12DEC));
    Else;
      SF12DECA=' ';
    EndIf;
    RRNF12+=1;
    Write F12S;
    Exec SQL Fetch Next From SQLCRSF12
      Into :SF12FLD,:SF12BUF,:SF12LEN,:Sf12Len2,:SF12DEC,:SF12TXT,
    :SF12TYP,:SF12USE;
  EndDo;
  Exec SQL Close SQLCRSF12;

End-Proc;


// Validate Screen F12
Dcl-Proc VALDF12;

  If F12FILE<>'*ALL' and
    F12LIB<>'*LIBL' and not #$ISLIB(F12LIB);
    *IN50 = *ON;
    *IN52 = *ON;
    ERM=#$Cntr('ERROR - LIBRARY NOT FOUND':78);
    Return;
  EndIf;

  If F12FILE<>'*ALL' and
    not #$ISFILE(F12FILE:F12LIB);
    *IN50 = *ON;
    *IN51 = *ON;
    ERM=#$Cntr('ERROR - FILE NOT FOUND':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F12
Dcl-Proc UPDTF12;

  // for all selected option load the sfl for f15
  // clear sfl
  *IN44 = *ON;
  Write F15C;
  *IN44 = *OFF;

  Clear RRNF15;
  Clear F15Show;

  // check sfl for options entered
  For xF12 = 1 To NumRcF12;
    Chain xF12 F12S;
    If not %found;
      Iter;
    EndIf;

    If Select<>' ';
      SF15TXT=%scanrpl(' ':'_':%trim(SF12TXT));
      SF12Select=Select;
      If Select='S' or Select='F';
        F15Show='Y';
      EndIf;
      Clear SF15EDTZ;
      Clear SF15DATE;
      If SF12DEC=0 and SF12LEN=8 and
      (SF12TYP='S' or SF12TYP='P') and
      %scan('DATE':SF12TXT)<>0;
        SF15Date='Y';
      ElseIf SF12DEC=0 and
        (SF12TYP='S' or SF12TYP='P');
        SF15EdtZ='Y';
      EndIf;
      If Sf12Select='S';
        *in87=*on;
      EndIf;
      RRNF15+=1;
      Write F15S;
    EndIf;

  EndFor;

  NumRcF15 = RRNF15;

End-Proc;


// Process SCreen 13
Dcl-Proc PROCF13;

  If FILECNT>0;
    F13SRCH='*STATEMENT';
  EndIf;

  MOVEF13();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF13=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF13<=0 or CRNF13>RRNF13;
      CRNF13=1;
    EndIf;
    Write F13F;
    Exfmt F13C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';
    If CSRF13=0;
      If *in46;
        CRNF13=NumRcF13;
      Else;
        CrnF13=1;
      EndIf;
    Else;
      CRNF13=CSRF13;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f11=toggle workfiles
    If *IN11 = *ON;
      If *IN83;
        *IN83=*OFF;
      Else;
        *IN83=*ON;
      EndIf;
      MOVEF13();
      ITER;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF13();
    If *in50;
      Iter;
    EndIf;

    UPDTF13();
    If *in25;
      MOVEF13();
      ITER;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen F13
Dcl-Proc MOVEF13;

  *IN44 = *ON;
  Write F13C;
  *IN44 = *OFF;

  RRNF13=0;
  Clear Select;

  If F13SRCH='*STATEMENT';
    MOVEF131();
  Else;
    MOVEF132();
  EndIf;

  NumRcF13=RRNF13;

End-Proc;


// ***************************************************************
Dcl-Proc MOVEF131;

  // setup command f11=wk files toggle, use *in83 as the toggle indicator
  F1CMD11=' ';

  // load sfl form files found in query
  For x=1 To 50;
    If FILES(x)=' ';
      Leave;
    EndIf;

    SF13FILE=FILES(x);
    SF13LIB =LIBS(x);
    #$OBJD=#$RTVOBJD(SF13FILE:SF13LIB:'*FILE');
    SF13Desc=#$OdTxt;
    RRNF13+=1;
    Write F13S;
  EndFor;

End-Proc;


// *********************************************************************
Dcl-Proc MOVEF132;

  // setup command f11=wk files toggle, use *in83 as the toggle indicator
  If *IN83;
    F1CMD11='F11=Exclude WK Files';
  Else;
    F1CMD11='F11=Include WK Files';
  EndIf;

  // load sfl from filespf
  PRPSQLF13();
  GETSQLF13();
  DoW not EOF;
    SF13File=fleNme;
    SF13Lib=fleLib;
    SF13Desc=fleDes;
    RRNF13+=1;
    Write F13S;
    If RRNF1>4000;
      Leave;
    EndIf;
    GETSQLF13();
  EndDo;
  CLSSQLF13();

End-Proc;


// Prepare SQL Statement for F13
Dcl-Proc PRPSQLF13;

  EOF=*OFF;

  // setup sql select statement
  SQLSTMF13='Select fleNme, fleLib, fleDes From WRKFLE';

  Where='Where';

  // add library selection if entered
  If F13LIB<>' ' and F13LIB<>'*ALL';
    SQLSTMF13+=' ' + Where + ' ' + ' fleLib = ''' + %trim(F13LIB) + '''';
    Where='and';
  EndIf;

  // if a search is entered
  If F13SRCH<>' ';
    #$BLDSCHF(01)='fleLib';
    #$BLDSCHF(02)='fleNme';
    #$BLDSCHF(03)='fleDes';
    SQLSTMF13+=' ' + Where + ' ' + #$BLDSCH(F13SRCH:#$BLDSCHF);
    Where='and';
  EndIf;

  // add exclude work files on not *in83
  If not *IN83;
    SQLSTMF13+=' ' + Where + ' ' + ' Trim(fleNme) Not Like(''%WK'')';
    Where='and';
  EndIf;

  // add order by selection
  SQLSTMF13+=' Order By fleNme';

  // prepare the statement, setup the cursor and open it
  Exec SQL Prepare SQLF13 From :SQLSTMF13;
  Exec SQL Declare SQLCRSF13 Cursor For SQLF13;
  Exec SQL Open SQLCRSF13;

End-Proc;


// Fecth Record for F13
Dcl-Proc GETSQLF13;

  Exec SQL Fetch Next From SQLCRSF13 Into :FILDS;

  If SQLSTT <> '00000';
    EOF = *ON;
  EndIf;

End-Proc;


// Close cursor for F13
Dcl-Proc CLSSQLF13;

  Exec SQL Close SQLCRSF13;

End-Proc;


// Validate Screen F13
Dcl-Proc VALDF13;


End-Proc;


// Update Screen F13
Dcl-Proc UPDTF13;

  // check sfl for options entered
  For xF13 = 1 To NumRcF13;
    Chain xF13 F13S;
    If not %found;
      Iter;
    EndIf;

    If Select<>' ';
      F12File=Sf13File;
      F12Lib=Sf13Lib;
      Leave;
    EndIf;

  EndFor;

End-Proc;


// Process F14
Dcl-Proc PROCF14;

  MOVEF14();
  DoW not *INLR;

    Exfmt F14;
    %subarr(*IN:50:9) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF14();
    If *in50;
      Iter;
    EndIf;

    UPDTF14();

    Leave;
  EndDo;

End-Proc;


// Load Screen F14
Dcl-Proc MOVEF14;

  // get record
  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *ALL SQLLSTR;
  EndIf;

  F14User=User;
  F14Name=sqlName;
  F14Desc=SqlDesc;

End-Proc;


// Validate Screen F14
Dcl-Proc VALDF14;

  // in entry make sure a user is entered
  If F14USER=' ';
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
    A USER.':78);
    Return;
  EndIf;

  // in entry make sure a name is entered
  If F14NAME=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
      A NAME.':78);
    Return;
  EndIf;

  // in entry make sure a name does not start with #$lst
  If %subst(F14NAME:1:5)='#$LST';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE NAME CANNOT +
    Start With #$LST.':78);
    Return;
  EndIf;

  // in entry make sure the entered name does not already exists
  Chain(N) (F14USER:F14NAME) SQLLSTPF;
  If %found;
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THIS NAME ALREADY +
    EXISTS.':78);
    Return;
  EndIf;

  // entry make sure a description is entered
  If F14DESC=' ';
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
    DESCRIPTION.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F14
Dcl-Proc UPDTF14;

  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
    Return;
  EndIf;

  SQLNAME=F14Name;
  SQLDESC=F14Desc;
  SQLENUS=F14User;
  SQLENWS=WSID;
  SQLENDT=%dec(%char(%date():*ISO0):8:0);
  SQLENTM=%dec(%char(%time():*hms0):6:0);
  Write SQLLSTR;

  // add detail lines
  SetLL (SF1ENUS:SF1NAME) SQLDETPF;
  ReadE(N) (SF1ENUS:SF1NAME) SQLDETPF;
  DoW not %eof;
    SQDNAME=SQLNAME;
    SQDENUS=SQLENUS;
    Write SQLDETR;
    ReadE(N) (SF1ENUS:SF1NAME) SQLDETPF;
  EndDo;

  SF1ENUS=SQLENUS;
  SF1NAme=SQLNAME;

End-Proc;


// Preocess Screen F15
Dcl-Proc PROCF15;

  If F15SHOW<>'Y';
    UPDTF15L();
    Return;
  EndIf;

  MOVEF15();
  DoW not *INLR;

    *IN44 = *OFF;
    If RRNF15=0;
      *in45=*off;
    Else;
      *in45=*on;
    EndIf;
    If CRNF15<=0 or CRNF15>RRNF15;
      CRNF15=1;
    EndIf;
    Write F15F;
    Exfmt F15C;
    %subarr(*IN:50:9) = *OFF;
    ERM='';
    If CSRF15=0;
      If *in46;
        CRNF15=NumRcF15;
      Else;
        CRNF15=1;
      EndIf;
    Else;
      CRNF15=CSRF15;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
        BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF15();
    If *in50;
      Iter;
    EndIf;

    UPDTF15();
    If *IN25 or *IN26;
      MOVEF15();
      ITER;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screenf F15
Dcl-Proc MOVEF15;

  // the sfl gets loaded in updtf12, nothing is done here

End-Proc;


// Validate Screen F15
Dcl-Proc VALDF15;

  // check sfl options
  For xF15= 1 To NumRcF15;
    Chain xF15 F15S;
    If not %found;
      Iter;
    EndIf;

    If SF15DATE='Y' and
    SF12TYP<>'S' and SF12TYP<>'P';
      *IN50 = *ON;
      *IN51 = *ON;
      ERM=#$Cntr('ERROR - DATE FIELDS MUST BE +
      NUMERIC.':78);
      Update F15S;
      Return;
    EndIf;

    If SF15DATE='Y' and SF12LEN<>8;
      *IN50 = *ON;
      *IN51 = *ON;
      ERM=#$Cntr('ERROR - DATE FIELDS MUST HAVE +
      A LENGTH OF 8.':78);
      Update F15S;
      Return;
    EndIf;

    If SF15EDTZ='Y' and
    SF12TYP<>'S' and SF12TYP<>'P';
      *IN50 = *ON;
      *IN52 = *ON;
      ERM=#$Cntr('ERROR - EDTZ ONLY ALLOWED +
      on NUMERIC FIELDS.':78);
      Update F15S;
      Return;
    EndIf;

    If SF15EDTZ='Y' and SF12DEC<>0;
      *IN50 = *ON;
      *IN52 = *ON;
      ERM=#$Cntr('ERROR - EDTZ ONLY ALLOWED on +
      FIELDS With 0 DECIMALS.':78);
      Update F15S;
      Return;
    EndIf;

    *IN51 = *OFF;
    *IN52 = *OFF;
    Update F15S;

  EndFor;

End-Proc;


// Update Screen F15
Dcl-Proc UPDTF15;

  // if the cursor is in the middle of a line split it
  If %subst(LINES(CsrPos):(Col-1):(78-Col))<>' '
  and %subst(LINES(CsrPos):1:(Col-2))<>' ';
    // insert a line after the cursor
    For x=999 by 1 DOWNTO CsrPos;
      LINES(x+1)=LINES(x);
    EndFor;
    // split the line the cursor is on to the next line
    LINES(CsrPos+1)='       '+%subst(LINES(CsrPos):(Col-1):(78-Col));
    LINES(CsrPos)=%subst(LINES(CsrPos):1:(Col-2));
  EndIf;

  // check sfl for options entered
  For xF15 = 1 To NumRcF15;
    Chain xF15 F15S;
    If not %found;
      Iter;
    EndIf;

    // insert a line for the new variable
    // only if the rest of the line is not blank or near the end
    If %subst(LINES(CsrPos):(Col-1):(78-Col))<>' ' or COL>40;
      CsrPos+=1;
      For x=999 by 1 DOWNTO CsrPos;
        LINES(x+1)=LINES(x);
      EndFor;
      LINES(CsrPos)=' ';
    EndIf;

    If SF12SELECT='S';

      If SF15DATE<>' ';
        If LINES(CsrPos)<>' ';
          LINES(CsrPos)=%trimr(LINES(CsrPos)) +' FDATE(' +
              %trim(F12File2)+'.'+%trim(SF12FLD)+')';
        Else;
          LINES(CsrPos)='       FDATE(' +%trim(F12File2)+'.'+%trim(SF12FLD)+')';
        EndIf;
      ElseIf SF15EDTZ<>' ';
        If LINES(CsrPos)<>' ';
          LINES(CsrPos)=%trimr(LINES(CsrPos)) +' SUBSTR(EDTZ('+%trim(F12File2)+'.'+
                        %trim(SF12FLD)+','+ %trim(%char(SF12LEN))+'),1,'+ %trim(%char(SF12LEN))+')';
        Else;
          LINES(CsrPos)='       SUBSTR(EDTZ('+%trim(F12File2)+'.'+%trim(SF12FLD)+','+
                        %trim(%char(SF12LEN))+'),1,'+%trim(%char(SF12LEN))+')';
        EndIf;
      Else;
        If LINES(CsrPos)<>' ';
          LINES(CsrPos)=%trimr(LINES(CsrPos)) +' '+%trim(F12File2)+'.'+%trim(SF12FLD);
        Else;
          LINES(CsrPos)='       '+%trim(F12File2)+'.'+%trim(SF12FLD);
        EndIf;
      EndIf;
      If SF15TXT<>' ';
        LINES(CsrPos)=%trimr(LINES(CsrPos)) +' AS "' + %trim(SF15TXT) + '"';
      EndIf;
    ElseIf SF12SELECT='F';
      If LINES(CsrPos)<>' ';
        LINES(CsrPos)=%trimr(LINES(CsrPos)) +' '+%trim(F12File2)+'.'+%trim(SF12FLD);
      Else;
        LINES(CsrPos)='       '+%trim(F12File2)+'.'+%trim(SF12FLD);
      EndIf;
    Else;
      If LINES(CsrPos)<>' ';
        LINES(CsrPos)=%trimr(LINES(CsrPos)) +' '+%trim(SF12FLD);
      Else;
        LINES(CsrPos)='       '+%trim(SF12FLD);
      EndIf;
    EndIf;
    LINES(CsrPos)=%trimr(LINES(CsrPos)) + ',';

  EndFor;

End-Proc;


// *********************************************************************
Dcl-Proc UPDTF15L;

  // figure out what word the cursor is after,
  prvWrd=#$Upify(#$PreviousWord(LINES(CsrPos):Col-2));

  // if the cursor is after the word select it will create a selection list
  // if the cursor is after the word on it will setup a dummy comparison
  // if the cursor is after the word where, it will setup a dummy where clause
  // otherwise it use the default logic of prefixing each field with a , and just add them
  If prvWrd='ON';
    UPDTF15LON();
  ElseIf prvWrd='WHERE';
    UPDTF15LWHR();
  Else;
    UPDTF15LREG();
  EndIf;

End-Proc;


// *********************************************************************
// after select logic
Dcl-Proc UPDTF15LREG;

  // if the cursor is in the middle of a line split it
  If %subst(LINES(CsrPos):(Col-1):(78-Col))<>' '
    and
    %subst(LINES(CsrPos):1:(Col-2))<>' ';
    // insert a line after the cursor
    For x=999 by 1 DOWNTO CsrPos;
      LINES(x+1)=LINES(x);
    EndFor;
    // split the line the cursor is on to the next line
    LINES(CsrPos+1)='       '+
    %subst(LINES(CsrPos):
    (Col-1):(78-Col));
    LINES(CsrPos)=%subst(LINES(CsrPos):
    1:(Col-2));
  EndIf;

  // if after the word select, do not add the First comma
  If prvWrd='SELECT';
    First=*ON;
  Else;
    First=*OFF;
  EndIf;

  // check sfl for options entered
  For xF15 = 1 To NumRcF15;
    Chain xF15 F15S;
    If not %found;
      Iter;
    EndIf;

    // see if the field will fit on this line, if not enter a new one and go
    // to the next line
    If %len(%trimr(LINES(CsrPos))+', '+
    %trim(SF12FLD))>78;
      CsrPos+=1;
      For x=999 by 1 DOWNTO CsrPos;
        LINES(x+1)=LINES(x);
      EndFor;
      Lines(CsrPos)='';
    EndIf;

    If First;
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ' '
      + %trim(SF12FLD);
      First=*OFF;
    Else;
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ', '
      + %trim(SF12FLD);
    EndIf;

  EndFor;

End-Proc;


// *********************************************************************
// after on logic
// this will add fields like this - fieldname=fieldname
// additional lines will add an and to the last line and skip to the
// next line, space over to the same starting location and add the column

// example with one field
// join plistd on pdinv=pdinv

// example with three fields
// join plistd on pdinv=pdinv and
//                pdisfx=pdisfx and
//                pdfab=pdfab

Dcl-Proc UPDTF15LON;

  // if the cursor is in the middle of a line split it
  If %subst(LINES(CsrPos):(Col-1):(78-Col))<>' '
  and
  %subst(LINES(CsrPos):1:(Col-2))<>' ';
    // insert a line after the cursor
    For x=999 by 1 DOWNTO CsrPos;
      LINES(x+1)=LINES(x);
    EndFor;
    // split the line the cursor is on to the next line
    LINES(CsrPos+1)='       '+
    %subst(LINES(CsrPos):
    (Col-1):(78-Col));
    LINES(CsrPos)=%subst(LINES(CsrPos):
    1:(Col-2));
  EndIf;

  // check sfl for options entered
  First=*ON;
  For xF15 = 1 To NumRcF15;
    Chain xF15 F15S;
    If not %found;
      Iter;
    EndIf;

    // see if the field will fit on this line, if not enter a new one and go
    // to the next line, after First always go to the next line
    If First and
    %len(%trimr(LINES(CsrPos))+', '+
      %trim(SF12FLD))>78
      or not First;
      CsrPos+=1;
      For x=999 by 1 DOWNTO CsrPos;
        LINES(x+1)=LINES(x);
      EndFor;
      Lines(CsrPos)='';
    EndIf;

    If First;
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ' '
      + %trim(SF12FLD) + '=' + %trim(SF12FLD);
      First=*OFF;
    Else;
      LINES(CsrPos-1)=%trimr(LINES(CsrPos-1)) +
      ' AND';
      %subst(LINES(CsrPos):Col-1:79-Col) =
        %trim(SF12FLD) + '=' + %trim(SF12FLD);
    EndIf;

  EndFor;

End-Proc;


// *********************************************************************
// after where logic
// this will add fields like this - fieldname=
// additional lines will add an and to the last line and skip to the
// next line, space over to the same starting location and add the column

// example with one field
// where pdinv=pdinv

// example with three fields
// where pdinv=0
//   and pdisfx=0
//   and pduom=' '

Dcl-Proc UPDTF15LWHR;

  // if the cursor is in the middle of a line split it
  If %subst(LINES(CsrPos):(Col-1):(78-Col))<>' '
  and
  %subst(LINES(CsrPos):1:(Col-2))<>' ';
    // insert a line after the cursor
    For x=999 by 1 DOWNTO CsrPos;
      LINES(x+1)=LINES(x);
    EndFor;
    // split the line the cursor is on to the next line
    LINES(CsrPos+1)='       '+
    %subst(LINES(CsrPos):
      (Col-1):(78-Col));
    LINES(CsrPos)=%subst(LINES(CsrPos):
    1:(Col-2));
  EndIf;

  // check sfl for options entered
  First=*ON;
  For xF15 = 1 To NumRcF15;
    Chain xF15 F15S;
    If not %found;
      Iter;
    EndIf;

    // see if the field will fit on this line, if not enter a new one and go
    // to the next line, after First always go to the next line
    If First and
    %len(%trimr(LINES(CsrPos))+', '+
      %trim(SF12FLD))>78
        or not First;
      CsrPos+=1;
      For x=999 by 1 DOWNTO CsrPos;
        LINES(x+1)=LINES(x);
      EndFor;
      Lines(CsrPos)='';
    EndIf;

    If First;
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ' '
      + %trim(SF12FLD) + ' =';
      First=*OFF;
    Else;
      %subst(LINES(CsrPos):Col-5:84-Col) =
      'AND ' +
        %trim(SF12FLD) + ' =';
    EndIf;

    // add '' for alpha else add 0
    If SF12TYP='A';
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ' ''''';
    Else;
      LINES(CsrPos)=%trimr(LINES(CsrPos)) + ' 0';
    EndIf;

  EndFor;

End-Proc;


// Process Screen F16
Dcl-Proc PROCF16;

  MOVEF16();
  DoW not *INLR;

    Exfmt F16;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF16();
    If *in50;
      Iter;
    EndIf;

    UPDTF16();

    Leave;
  EndDo;

End-Proc;


// Load Screen F16
Dcl-Proc MOVEF16;

  F16Name='';
  F16Desc='';

End-Proc;


// Validate Screen F16
Dcl-Proc VALDF16;

  // in entry make sure a name is entered
  If F16NAME=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
    A NAME.':78);
    Return;
  EndIf;

  // in make sure a name does not start with #$lst
  If %subst(F16NAME:1:5)='#$LST';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THE NAME CANNOT +
      Start With #$LST.':78);
    Return;
  EndIf;

  // in make sure the entered name does not already exists
  F14Name=F16Name;
  Chain(N) (USER:F14NAME) SQLLSTPF;
  If %found;
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THIS NAME ALREADY +
    EXISTS.':78);
    Return;
  EndIf;

  // entry make sure a description is entered
  If F16DESC=' ';
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER A +
    DESCRIPTION.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F16
Dcl-Proc UPDTF16;

  // add master record
  Clear *ALL SQLLSTR;
  SQLNAME = F16NAME;
  SQLDESC = F16DESC;
  SQLTYPE = 'SELECT';
  SQLOUTP = '1';
  SQLENUS = USER;
  SQLENWS = WSID;
  SQLENDT = %dec(%char(%date():*ISO0):8:0);
  SQLENTM = %dec(%char(%time():*hms0):6:0);
  Write SQLLSTR;

  // add detail lines
  For x=1 To 300;
    SQDEnus=SqlEnus;
    SQDName=SQLName;
    SQDSeq=x;
    SQDLINE=Lines(x);
    Write SQLDETR;
  EndFor;

  SF1Enus=SqlENus;
  SF1NAME=SqlName;

End-Proc;


// Process Screen F17
Dcl-Proc PROCF17;

  MOVEF17();
  DoW not *INLR;

    Exfmt F17;
    %subarr(*IN:50:9) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
        KEY.':78);
      ITER;
    EndIf;

    VALDF17();
    If *in50;
      Iter;
    EndIf;

    UPDTF17();

    Leave;
  EndDo;

End-Proc;


// Load Screen F17
Dcl-Proc MOVEF17;

  Clear F17;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  F17EM01 = SQLEM01;
  F17EM02 = SQLEM02;
  F17EM03 = SQLEM03;
  F17EM04 = SQLEM04;
  F17RPID = SQLRPID;
  F17RPID = SQLRPID;
  F17SUBJ = SQLSUBJ;
  F17INVR = SQLINVR;
  F17MSAS = SQLMSAS;
  F17MS01 = SQLMS01;
  F17MS02 = SQLMS02;
  F17MS03 = SQLMS03;
  F17MS04 = SQLMS04;
  F17MS05 = SQLMS05;
  F17MS06 = SQLMS06;
  F17MS07 = SQLMS07;
  F17MS08 = SQLMS08;
  F17MS09 = SQLMS09;
  F17MS10 = SQLMS10;

End-Proc;


// Validate Screen F16
Dcl-Proc VALDF17;

  // entry make sure the email address is valid
  If %trim(F17EM01)<>'*USER' and
    %trim(F17EM01)<>'*CURRENT' and
    F17EM01<>' ' and #$VEML(F17EM01);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    EMAIL.':78);
    Return;
  EndIf;

  If %trim(F17EM02)<>'*USER' and
  %trim(F17EM02)<>'*CURRENT' and
  F17EM02<>' ' and #$VEML(F17EM02);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
      EMAIL.':78);
    Return;
  EndIf;

  If %trim(F17EM03)<>'*USER' and
  %trim(F17EM03)<>'*CURRENT' and
    F17EM03<>' ' and #$VEML(F17EM03);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    EMAIL.':78);
    Return;
  EndIf;

  If %trim(F17EM04)<>'*USER' and
  %trim(F17EM04)<>'*CURRENT' and
  F17EM04<>' ' and #$VEML(F17EM04);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    EMAIL.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F17
Dcl-Proc UPDTF17;

  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  SQLLSTSV=SQLLSTDS;

  SQLEM01 = F17EM01;
  SQLEM02 = F17EM02;
  SQLEM03 = F17EM03;
  SQLEM04 = F17EM04;
  SQLRPID = F17RPID;
  SQLSUBJ = F17SUBJ;
  SQLINVR = F17INVR;
  SQLMSAS = F17MSAS;
  SQLMS01 = F17MS01;
  SQLMS02 = F17MS02;
  SQLMS03 = F17MS03;
  SQLMS04 = F17MS04;
  SQLMS05 = F17MS05;
  SQLMS06 = F17MS06;
  SQLMS07 = F17MS07;
  SQLMS08 = F17MS08;
  SQLMS09 = F17MS09;
  SQLMS10 = F17MS10;

  // update change flags
  If SQLLSTDS<>SQLLSTSV;
    SQLLRUS = User;
    SQLLRWS = WSID;
    SQLLRDT = %dec(%char(%date():*ISO0):8:0);
    SQLLRTM = %dec(%char(%time():*hms0):6:0);
  EndIf;

  If %found;
    Update SQLLSTR;
  EndIf;

End-Proc;


// Process Screen F18
Dcl-Proc PROCF18;

  MOVEF18();
  DoW not *INLR;

    Exfmt F18;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF18();
    If *in50;
      Iter;
    EndIf;

    UPDTF18();

    Leave;
  EndDo;

End-Proc;


// Load Screen F18
Dcl-Proc MOVEF18;

  Clear F18;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;

  F18OUTQ = SQLOUTQ;
  F18OQLB = SQLOQLB;
  F18COPY = SQLCOPY;
  F18HOLD = SQLHOLD;
  F18SAVE = SQLSAVE;
  F18USDT = SQLUSDT;
  F18FRLN = SQLFRLN;
  F18FRWD = SQLFRWD;
  F18PINVR= SQLPINVR;
  F18PINQY= SQLPINQY;

  If F18COPY=0;
    F18Copy=1;
  EndIf;
  If F18HOLD<>'*YES';
    F18HOLD= '*NO ';
  EndIf;
  If F18SAVE<>'*YES';
    F18SAVE= '*NO ';
  EndIf;
  If F18USDT=' ';
    F18USDT=SF1NAME;
  EndIf;
  If F18FRLN=0;
    F18FRLN=66;
  EndIf;
  If F18FRWD=0;
    F18FRWD=132;
  EndIf;

End-Proc;


// Validate Screen F18
Dcl-Proc VALDF18;

  // make sure the output queue is valid
  If F18OUTQ<>' ' and F18OUTQ<>'*JOB';
    If F18OQLB=' ';
      F18OQLB='*LIBL';
    EndIf;
    If not #$ISOUTQ(F18OUTQ:F18OQLB);
      *IN51 = *ON;
      *IN50 = *ON;
      ERM=#$Cntr('ERROR - INVALID OR MISSING +
      OUTPUT QUEUE.':78);
      Return;
    EndIf;
  EndIf;

End-Proc;


// Update Screen F18
Dcl-Proc UPDTF18;

  Chain (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  SQLLSTSV= SQLLSTDS;

  SQLOUTQ = F18OUTQ;
  SQLOQLB = F18OQLB;
  SQLCOPY = F18COPY;
  SQLHOLD = F18HOLD;
  SQLSAVE = F18SAVE;
  SQLUSDT = F18USDT;
  SQLFRLN = F18FRLN;
  SQLFRWD = F18FRWD;
  SQLPINVR= F18PINVR;
  SQLPINQY= F18PINQY;

  // update change flags
  If SQLLSTDS<>SQLLSTSV;
    SQLLRUS = USER;
    SQLLRWS = WSID;
    SQLLRDT = %dec(%char(%date():*ISO0):8:0);
    SQLLRTM = %dec(%char(%time():*hms0):6:0);
  EndIf;

  If %found;
    Update SQLLSTR;
  EndIf;

End-Proc;


// Process Screen F19
Dcl-Proc PROCF19;

  MOVEF19();
  DoW not *INLR;

    Exfmt F19;
    %subarr(*IN:50:13) = *OFF;
    ERM='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    // handle all searches
    SRCHF19();
    If againF19='Y';
      ITER;
    EndIf;

    VALDF19();
    If *in50;
      Iter;
    EndIf;

    UPDTF19();
    If *in50 or *in12;
      Iter;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen F19
Dcl-Proc MOVEF19;

  Clear F19;

End-Proc;


// Handle Searches for Scren F19
Dcl-Proc SRCHF19;

  againF19='';

  // search file
  If %scan('?':F19QRYDFN)>0;
    PROCF20();
    againF19='Y';
  EndIf;

End-Proc;


// Validate Screen F19
Dcl-Proc VALDF19;

  // make sure the qrydfn is valid
  If F19LIB=' ';
    F19LIB='*LIBL';
  EndIf;
  Monitor;
    #$Cmd('CHKOBJ OBJ('+%trim(F19LIB)+'/'+%trim(F19QRYDFN)+
    ') OBJTYPE(*QRYDFN)':2);
  On-Error;
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    QRYDFN.':78);
    Return;
  EndMon;

End-Proc;


// Update Screen F19
Dcl-Proc UPDTF19;

  // create source member is qtemp if it doesn't exists
  #$Cmd('CRTSRCPF QTEMP/QQMQRYSRC':1);

  // delete the member if it already exists
  #$Cmd('RMVM QTEMP/QQMQRYSRC ' + %trim(F19QRYDFN):1);

  // load qrydfn to temp source member
  Monitor;
    #$Cmd('RTVQMQRY QMQRY(' +  %trim(F19LIB) + '/' + %trim(F19QRYDFN) +
          ') SRCFILE(QTEMP/QQMQRYSRC) ALWQRYDFN(*YES)');
  On-Error;
    *IN50=*ON;
    ERM=#$Cntr(PSDSEXCDTA:78);
  EndMon;

  // read the source file into the psname variable
  *IN77=*OFF;
  psName=' ';
  Exec SQL Drop Alias QTEMP/temp;
  sqlStm='CREATE OR REPLACE ALIAS QTEMP/TEMP FOR QTEMP/QQMQRYSRC("' + %trim(F19QRYDFN) + '")';
  Exec SQL Execute Immediate :sqlStm;
  Exec SQL Declare qqmCursor Cursor For Select srcDta From qtemp/temp;
  Exec SQL Open qqmCursor;
  Exec SQL Fetch Next From qqmCursor Into :srcDta;
  DoW sqlState<'02';
    If (%subst(srcDta:1:1)<>'H' and %subst(srcDta:1:1)<>'V') or *IN77;
      EVAL psName=%trim(psName) + ' ' + %trim(srcDta);
      *IN77=*ON;
    EndIf;
    Exec SQL Fetch Next From qqmCursor Into :srcDta;
  EndDo;
  Exec SQL Close qqmCursor;
  Exec SQL Drop Alias QTEMP/temp;

  // convert psname to lines and go to ad hoc screen
  Lines=#$FormatSQL(psName);
  PROCF10();

End-Proc;


// Process Screen F20
Dcl-Proc PROCF20;

  MOVEF20();
  DoW not *INLR;

    *IN44 = *OFF;
    RRNF20=0;
    If CRNF20<=0 or CRNF20>RRNF20;
      CRNF20=1;
    EndIf;
    Write F20F;
    Exfmt F20C;
    %subarr(*IN:50:9) = *OFF;
    Erm='';

    If CSRF20=0;
      If *in46;
        CRNF20=NumRcF20;
      Else;
        CRNF20=1;
      EndIf;
    Else;
      CRNF20=CSRF20;
    EndIf;

    // if paged up past the end of sfl, just redisplay
    If *IN47;
      ERM=#$Cntr('YOU ARE ALREADY AT THE TOP.':78);
      ITER;
    EndIf;

    // if paged down past the end of sfl, just redisplay
    If *IN46;
      ERM=#$Cntr('YOU ARE ALREADY AT THE +
      BOTTOM.':78);
      ITER;
    EndIf;

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Leave;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
      KEY.':78);
      ITER;
    EndIf;

    VALDF20();
    If *in50;
      Iter;
    EndIf;

    UPDTF20();
    If *in25;
      MOVEF20();
      Iter;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen F20
Dcl-Proc MOVEF20;

  If F20LIB=' ';
    F20LIB='*LIBL';
  EndIf;

  // create a list of all queries in the library
  #$Cmd('DLTF QTEMP/WORKFILE':1);
  #$Cmd('DSPOBJD ' + %trim(F20LIB) + '/*ALL OBJTYPE(*QRYDFN) +
  OUTPUT(*OUTFILE) OUTFILE(QTEMP/WORKFILE)');

  // clear sfl
  *IN44 = *ON;
  Write F20C;
  *IN44 = *OFF;

  RRNF20=0;
  Clear Select;

  // loop through the temp file and fill the sfl
  Exec SQL Declare SQLCRS3 Cursor For
  Select ODLBNM, ODOBNM, ODOBTX
    From QTEMP/WORKFILE;
  Exec SQL Open SQLCRS3;
  Exec SQL Fetch Next From SQLCRS3 Into :SF20LIB,:SF20OBJ,:SF20TEXT;
  DoW not #$SQLSTT();
    RRNF20+=1;
    Write F20S;
    Exec SQL Fetch Next From SQLCRS3 Into :SF20LIB,:SF20OBJ,:SF20TEXT;
  EndDo;
  Exec SQL Close SQLCRS3;

  NumRcF20=RRNF20;

End-Proc;


// Validate Screen F20
Dcl-Proc VALDF20;

  If F20LIB<>'*LIBL' and not #$ISLIB(F20LIB);
    *IN50 = *ON;
    *IN51 = *ON;
    ERM=#$Cntr('ERROR - LIBRARY NOT FOUND':78);
    Return;
  EndIf;

End-Proc;


// Update Scren F20
Dcl-Proc UPDTF20;

  // check sfl for options entered
  For xF20 = 1 To NumRcF20;
    Chain xF20 F20S;
    If not %found;
      Iter;
    EndIf;

    If Select<>' ';
      F19QryDfn=Sf20Obj;
      F19Lib=SF20Lib;
      Leave;
    EndIf;

  EndFor;

End-Proc;


// Process Screen F21
Dcl-Proc PROCF21;

  MOVEF21();
  DoW not *INLR;

    Exfmt F21;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
        KEY.':78);
      ITER;
    EndIf;

    VALDF21();
    If *in50 or *in12 or *in03;
      Iter;
    EndIf;

    UPDTF21();

    Leave;
  EndDo;

End-Proc;


// Load Screen F21
Dcl-Proc MOVEF21;

  Clear F21;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

  F21FILE=SQLFILE;

  If F21FOLD=' ';
    F21FOLD=#$USRHOME;
  EndIf;

  If F21ATTY=' ';
    F21Atty=SQLAtty;
  EndIf;

  If F21ATTY=' ';
    F21ATTY='*XLS';
  EndIf;

  If F21EMPTY=' ';
    F21EMPTY='*YES';
  EndIf;

  If F21USETEXT=' ';
    F21USETEXT='*YES';
  EndIf;

  F21SHEET = 'SHEET 1';
  F21TITL1 = SQLDESC;
  F21TITL2 = *BLANKS;
  F21TITL3 = *BLANKS;
  F21TITL4 = *BLANKS;
  F21TITL5 = *BLANKS;

End-Proc;


// Validate Screen F21
Dcl-Proc VALDF21;

  // make sure the folder is valid and exists
  If F21FOLD=' ' or #$VPATH(F21FOLD);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    FOLDER.':78);
    Return;
  EndIf;

  // validate that a file name is entered
  If F21FILE=' ';
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
    A FILE NAME.':78);
    Return;
  EndIf;

  // validate the attachment type
  If F21ATTY<>'*XLS' and F21ATTY<>'*CSV' and
  F21ATTY<>'*XML' and F21ATTY<>'*PDF' and
  F21ATTY<>'*JSON';
    *IN53 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID FILE +
    TYPE.':78);
    Return;
  EndIf;

  // validate the create empty file option
  If F21EMPTY<>'*YES' and F21EMPTY<>'*NO';
    *IN54 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':78);
    Return;
  EndIf;

  // validate the use field text option
  If F21USETEXT<>'*YES' and F21USETEXT<>'*NO';
    *IN55 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':78);
    Return;
  EndIf;

  // get the file name without an extension if one is already entered
  F21FileNo=F21File;
  If F21ATTY='*XLS' and
  #$Upify(#$Last(F21FILE:5)) = '.XLSX';
    F21FileNo = %subst(F21FILE:1:
    %len(%trim(F21FILE))-5);
  EndIf;
  If F21ATTY='*CSV' and
    #$Upify(#$Last(F21FILE:4)) = '.CSV';
    F21FileNo = %subst(F21FILE:1:
    %len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*XML' and
  #$Upify(#$Last(F21FILE:4)) = '.XML';
    F21FileNo = %subst(F21FILE:1:
    %len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*PDF' and
  #$Upify(#$Last(F21FILE:4)) = '.PDF';
    F21FileNo = %subst(F21FILE:1:
    %len(%trim(F21FILE))-4);
  EndIf;
  If F21ATTY='*JSON' and
  #$Upify(#$Last(F21FILE:5)) = '.JSON';
    F21FileNo = %subst(F21FILE:1:
    %len(%trim(F21FILE))-5);
  EndIf;

  // default the extension
  F21Extn='';
  If F21ATTY = '*XLS';
    F21Extn = '.xlsx';
  ElseIf F21ATTY = '*CSV';
    F21Extn = '.csv';
  ElseIf F21ATTY = '*XML';
    F21Extn = '.xml';
  ElseIf F21ATTY = '*PDF';
    F21Extn = '.pdf';
  ElseIf F21ATTY = '*JSON';
    F21Extn = '.json';
  EndIf;

  // build the full path with extension and see if it already exists
  F21Path=%trim(F21fold) + '/' +
  %trim(F21FileNo) + %trim(F21Extn);
  If not #$VPATH(F21Path);
    PROCF22();
  EndIf;

End-Proc;


// Update Screen F21
Dcl-Proc UPDTF21;

  // build the sql statement with variable overrides
  BLDSQL();

  If F21ATTY='*PDF';
    UPDTF21PDF();
  ElseIf F21ATTY='*JSON';
    UPDTF21JSON();
  Else;
    UPDTF21OTHR();
  EndIf;

End-Proc;


// *********************************************************************
Dcl-Proc UPDTF21OTHR;

  // build a command to save the query
  cmd='SQL2XLS SQL(''' + %trim(#$DBLQ(SQLSTMP)) + ''') +
               FILE(''' + %trim(F21Path) + ''') +
               TYPE(' + %trim(F21ATTY) + ') +
               EMPTY(' + %trim(F21EMPTY) + ') +
               USETEXT(' + %trim(F21USETEXT) + ') +
               SHEET(''' + %trim(F21SHEET) + ''') +
               TITLE1(''' + %trim(F21TITL1) + ''') +
               TITLE2(''' + %trim(F21TITL2) + ''') +
               TITLE3(''' + %trim(F21TITL3) + ''') +
               TITLE4(''' + %trim(F21TITL4) + ''') +
               TITLE5(''' + %trim(F21TITL5) + ''')';

  #$Cmd(cmd:2);

End-Proc;


// *********************************************************************
Dcl-Proc UPDTF21JSON;

  // build a command to save the query
  cmd='SQL2JSON SQL(''' + %trim(#$DBLQ(SQLSTMP)) + ''') +
                FILE(''' + %trim(F21Path) + ''') +
                EMPTY(' + %trim(F21EMPTY) + ') +
                USETEXT(' + %trim(F21USETEXT) + ') +
                TITLE1(''' + %trim(F21TITL1) + ''') +
                TITLE2(''' + %trim(F21TITL2) + ''') +
                TITLE3(''' + %trim(F21TITL3) + ''') +
                TITLE4(''' + %trim(F21TITL4) + ''') +
                TITLE5(''' + %trim(F21TITL5) + ''')';

  #$Cmd(cmd:2);

End-Proc;


// *********************************************************************
Dcl-Proc UPDTF21PDF;

  // override and hard code some of the print variables
  psUsDt='SQL'+%trim(%char(%date():*ISO0));

  psPInVr=sqlPInVr;
  If PSPINVR<>'*YES';
    psPInVr='*NO ';
  EndIf;

  psPInQy=SQLPINQY;
  If PSPINQY<>'*YES';
    psPInQy='*NO ';
  EndIf;

  psHold =SQLHOLD;
  If PSHOLD<>'*NO';
    psHold ='*YES';
  EndIf;

  psSave =SQLSAVE;
  If PSSAVE<>'*YES';
    psSave ='*NO ';
  EndIf;

  psCopy =1;

  psFrWd=SqlFrWd;
  If psFrWd=0;
    psFrWd=132;
  EndIf;

  psFrLn=SqlFrLn;
  If psFrLn=0;
    psFrLn=66;
  EndIf;

  #$VARS=psVrIn;
  #$OUTQ  = 'TRASH';
  #$OQLB  = 'QGPL';
  #$COPY  = psCopy;
  #$HOLD  = psHold;
  #$SAVE  = psSave;
  #$USDT  = psUsDt;
  #$FRLN  = psFrLn;
  #$FRWD  = psFrWd;
  #$INVR  = psPInVr;
  #$INQY  = psPInQy;
  #$TITLE1 = F21TITL1;
  #$TITLE2 = F21TITL2;
  #$TITLE3 = F21TITL3;
  #$TITLE4 = F21TITL4;
  #$TITLE5 = F21TITL5;
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
  #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME);

  // if the file name is blank build one
  If F21FILE=' ';
    F21FILE='SQL'+%trim(WSID) +
    %trim(%char(%date():*ISO0))+%trim(%char(%time():*HMS0));
  EndIf;

  // convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMDO1) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
  %trim(F21Path) + ''') WSCST(*PDF)':2);

  // delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMDO1) SPLNBR(*LAST)':2);

End-Proc;


// Process Screen F22
Dcl-Proc PROCF22;

  MOVEF22();
  DoW not *INLR;

    Exfmt F22;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION KEY.':78);
      ITER;
    EndIf;

    VALDF22();
    If *in50;
      Iter;
    EndIf;

    UPDTF22();

    Leave;
  EndDo;

End-Proc;


// Lod Screen F22
Dcl-Proc MOVEF22;

  Clear F22;

  // build text string
  F22TEXT = 'File ' + %trim(F21Path) +
    ' already exists. Use F12 to go back +
    and change the file name, enter +
    a Y below To replace the file or +
    enter a B To keep both files.';

  // wrap the string to not break lines on words
  F22TEXT=#$WORDWRAP(F22TEXT:80);

End-Proc;


// Validate Screen F22
Dcl-Proc VALDF22;

  // validate the option
  If F22REPL<>'Y' and F22REPL<>'N' and
  F22REPL<>'B';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OPTION.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F22
Dcl-Proc UPDTF22;

  // if replace is issued delete the existing file
  If F22REPL='Y';
    #$Cmd('DEL '''+%trim(F21Path)+'''':2);
  EndIf;

  // if keep both is selected, rename the path to include (xxx)
  If F22REPL='B';
    version=0;
    DoW not *INLR;
      version+=1;
      F21Path=%trim(F21FOLD) + '/' +
        %trim(F21FileNo) +
        ' (' + %trim(%editc(version:'Z')) + ')' +
        %trim(F21Extn);
      If not #$VPATH(F21Path);
        ITER;
      Else;
        Leave;
      EndIf;
    EndDo;
  EndIf;

End-Proc;


// Process Screen F23
Dcl-Proc PROCF23;

  MOVEF23();
  DoW not *INLR;

    Exfmt F23;
    %subarr(*IN:50:13) = *OFF;
    Erm='';

    // f3=exit
    If *IN03;
      Leave;
    EndIf;

    // f12=cancel
    If *IN12;
      Return;
    EndIf;

    // fxx=any other function key so the screen doesnt lock up
    If *IN27;
      ERM=#$Cntr('ERROR - INVALID FUNCTION +
        KEY.':78);
      ITER;
    EndIf;

    VALDF23();
    If *in50 or *in12 or *in03;
      Iter;
    EndIf;

    UPDTF23();
    If *in50;
      Iter;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen F23
Dcl-Proc MOVEF23;

  Clear F23;

  // get record
  Chain(N) (SF1ENUS:SF1NAME) SQLLSTPF;
  If not %found;
    Clear *all SQLLSTR;
  EndIf;
  LOADLINES();
  VarDs=SQLVARS;

End-Proc;


// Validate Screen F23
Dcl-Proc VALDF23;

  // make sure the library is valid and exists
  If F23LIB=' ' or not #$ISLIB(F23LIB);
    *IN52 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - INVALID OR MISSING +
    LIBRARY.':78);
    Return;
  EndIf;

  // validate that a file name is entered
  If F23FILE=' ';
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - YOU MUST ENTER +
    A FILE NAME.':78);
    Return;
  EndIf;

  // see if the file already exists
  If #$ISFILE(F23FILE:F23LIB);
    *IN51 = *ON;
    *IN50 = *ON;
    ERM=#$Cntr('ERROR - THIS FILE ALREADY +
    EXISTS.':78);
    Return;
  EndIf;

End-Proc;


// Update Screen F23
Dcl-Proc UPDTF23;

  // build the sql statement with variable overrides
  BLDSQL();

  SQLSTMP2='CREATE TABLE ' + %trim(F23LIB) + '/' + %trim(F23FILE) +
    ' AS ('+%trim(SQLSTMP) + ') With DATA';
  Exec SQL Execute Immediate :SQLSTMP2;
  If #$SQLSTT();
    *IN50 = *ON;
    ERM=#$Cntr(PSDSEXCDTA:78);
    Return;
  EndIf;

End-Proc;


// process a direct email request
Dcl-Proc PROCEMAIL;

  // replace any &cr's with the correct line breaks
  If messageType='*TEXTHTML';
    psMess.message=#$SCANRPL('&CR':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&Cr':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&cR':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&cr':'<BR>':psMess.message);
  Else;
    psMess.message=#$SCANRPL('&CR':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&Cr':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&cR':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&cr':X'0D25':psMess.message);
  EndIf;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // override default variables
  If psFile=' ' or psFile='*DFT';
    psFile=sqlFile;
  EndIf;

  If psType=' ' or psType='*DFT';
    psType=sqlAtty;
  EndIf;
  If psType=' ';
    psType='*XLS';
  EndIf;

  If psSubject=' ' or psSubject='*DFT';
    psSubject=sqlSubj;
  EndIf;

  If messageType=' ' or messageType='*DFT';
    messageType=sqlMsas;
  EndIf;
  If messageType<>'*TEXTHTML';
    messageType= '*TEXTPLAIN';
  EndIf;

  If psMess.message=' ' or psMess.message='*DFT';
    If messageType='*TEXTHTML';
      psMess.message=%trim(SQLMS01) + '<BR>' +
        %trim(SQLMS02) + '<BR>' +
        %trim(SQLMS03) + '<BR>' +
        %trim(SQLMS04) + '<BR>' +
        %trim(SQLMS05) + '<BR>' +
        %trim(SQLMS06) + '<BR>' +
        %trim(SQLMS07) + '<BR>' +
        %trim(SQLMS08) + '<BR>' +
        %trim(SQLMS09) + '<BR>' +
        %trim(SQLMS10);
    Else;
      psMess.message=%trim(SQLMS01) + EOR +
        %trim(SQLMS02) + EOR +
        %trim(SQLMS03) + EOR +
        %trim(SQLMS04) + EOR +
        %trim(SQLMS05) + EOR +
        %trim(SQLMS06) + EOR +
        %trim(SQLMS07) + EOR +
        %trim(SQLMS08) + EOR +
        %trim(SQLMS09) + EOR +
        %trim(SQLMS10);
    EndIf;
  EndIf;

  // build a command to email the query
  cmd='EMLSQL SQL(''' + %trim(#$DBLQ(SQLSTMP)) + ''') EMAIL( ';

  For i=1 To psEMLCNT;
    If psEM(i)<>' ';
      cmd+= ' (' + %trim(psEM(i)) + ')';
    EndIf;
  EndFor;
  cmd+=' )';

  If psSubject<>' ';
    cmd+=' SUBJECT(''' + %trim(#$DBLQ(psSubject))+''')';
  EndIf;

  message=' ';
  If psMess.message<>' ' and psMess.message<>'*NONE';
    message=%trim(#$DBLQ(psMess.message));
  EndIf;
  If psInVr='*YES';
    If messageType='*TEXTHTML';
      Break='<BR>';
    Else;
      Break=X'0D25';
    EndIf;
    message+=%trim(Break) + 'Variable overrides:' + %trim(Break);
    For i=1 To 10;
      If VRNAME(i)<>' ';
        message+=VRNAME(i) +' = ' +VRDFT(i) + %trim(Break);
      EndIf;
    EndFor;
  EndIf;

  If message<>' ';
    cmd+=' MESSAGE(''' + message + ''' '+%trim(messageType)+')';
  EndIf;

  // add file name override if passed
  If PSFILE<>' ';
    cmd+= ' FILE(''' +%trim(psFile) + ''')';
  EndIf;

  // add file type if passed
  If PSTYPE<>' ';
    cmd+= ' TYPE(' + %trim(psType) + ')';
  EndIf;

  // add sheet name override if passed
  If PSSHEET<>' ';
    cmd+= ' SHEET(''' + %trim(psSheet) + ''')';
  EndIf;

  // add titles if passed
  If PSTITLE1<>' ';
    cmd+= ' TITLE1(''' + %trim(#$DBLQ(psTitle1)) + ''')';
  EndIf;
  If PSTITLE2<>' ';
    cmd+= ' TITLE2(''' + %trim(#$DBLQ(psTitle2)) + ''')';
  EndIf;
  If PSTITLE3<>' ';
    cmd+= ' TITLE3(''' + %trim(#$DBLQ(psTitle3)) + ''')';
  EndIf;
  If PSTITLE4<>' ';
    cmd+= ' TITLE4(''' + %trim(#$DBLQ(psTitle4)) + ''')';
  EndIf;
  If PSTITLE5<>' ';
    cmd+= ' TITLE5(''' + %trim(#$DBLQ(psTitle5)) + ''')';
  EndIf;

  // append objects if passed
  *IN77 = *OFF;
  For x=1 To psObjects.count;
    If %trim(objects(x).name)<>' ';
      If not *IN77;
        cmd+= ' OBJ(';
      EndIf;
      *IN77 = *ON;
      cmd+= ' (''' + %trim(#$DBLQ(objects(x).name)) + ''' ';
      If objects(x).type<>' ';
        cmd+=' ' + %trim(#$DBLQ(objects(x).type));
      EndIf;
      cmd+=' )';
    EndIf;
  EndFor;
  If *in77;
    cmd+=' )';
  EndIf;

  // append additional queries if passed
  *IN77 = *OFF;
  For x=1 To psQueries.count;
    If %trim(queries(x).sql)<>' ';
      If not *IN77;
        cmd+= ' ADDSQL(';
      EndIf;
      *IN77 = *ON;
      cmd+= ' (''' + %trim(#$DBLQ(queries(x).sql)) + ''' ';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).tab)) + '''';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).title1)) + '''';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).title2)) + '''';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).title3)) + '''';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).title4)) + '''';
      cmd+=' ''' + %trim(#$DBLQ(queries(x).title5)) + '''';
      cmd+=' )';
    EndIf;
  EndFor;
  If *in77;
    cmd+=' )';
  EndIf;

  #$Cmd(cmd:2);

  *INLR = *ON;
  Return;

End-Proc;


// process a direct email request with a pdf attachment
Dcl-Proc PROCEMAILPDF;

  // replace any &cr's with the correct line breaks
  If messageType='*TEXTHTML';
    psMess.message=#$SCANRPL('&CR':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&Cr':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&cR':'<BR>':psMess.message);
    psMess.message=#$SCANRPL('&cr':'<BR>':psMess.message);
  Else;
    psMess.message=#$SCANRPL('&CR':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&Cr':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&cR':X'0D25':psMess.message);
    psMess.message=#$SCANRPL('&cr':X'0D25':psMess.message);
  EndIf;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // override and hard code some of the print variables
  psUsDt='SQL'+%trim(%char(%date():*ISO0));

  If psTitle1=' ' or psTitle1='*DFT';
    psTitle1=SqlDesc;
  EndIf;

  If psPInVr=' ' or psPInVr='*DFT';
    psPInVr=sqlPInVr;
  EndIf;
  If PSPINVR<>'*YES';
    psPInVr='*NO ';
  EndIf;

  If psPInQy=' ' or psPInQy='*DFT';
    psPInQy=sqlPInQy;
  EndIf;
  If PSPINQY<>'*YES';
    psPInQy='*NO ';
  EndIf;

  psHold='*YES';
  psSave='*NO ';


  psCopy=1;

  If psFrWd=0;
    psFrWd = sqlFrWd;
  EndIf;
  If psFrWd=0;
    psFrWd=132;
  EndIf;

  If psFrLn=0;
    psFrLn = sqlFrLn;
  EndIf;
  If psFrLn=0;
    psFrLn=66;
  EndIf;

  #$VARS  = psVrIn;
  #$OUTQ  = 'TRASH';
  #$OQLB  = 'QGPL';
  #$COPY  = psCopy;
  #$HOLD  = psHold;
  #$SAVE  = psSave;
  #$USDT  = psUsDt;
  #$FRLN  = psFrLn;
  #$FRWD  = psFrWd;
  #$INVR  = psPInVr;
  #$INQY  = psPInQy;
  #$TITLE1 = psTitle1;
  #$TITLE2 = psTitle2;
  #$TITLE3 = psTitle3;
  #$TITLE4 = psTitle4;
  #$TITLE5 = psTitle5;
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
  #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME:queries);

  // convert the output file to a pdf
  If psFile=' ' or psFile='*DFT';
    psFile = sqlFile;
  EndIf;

  // if the file name is blank build one
  If psFile=' ';
    psFile='SQL'+%trim(WSID) +
    %trim(%char(%date():*ISO0))+%trim(%char(%time():*HMS0));
  EndIf;

  objPath='/ACOM/EMAIL/TMP/'+%trim(psFile);

  // add .pdf extension if not already on there
  If #$Upify(#$Last(objPath:4)) <>'.PDF';
    objPath=%trim(objPath)+'.PDF';
  EndIf;

  // convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMDO1) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
  %trim(objPath) + ''') WSCST(*PDF)':2);

  // delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMDO1) SPLNBR(*LAST)':2);

  // override default variables
  If psSubject=' ' or psSubject='*DFT';
    psSubject = sqlSubj;
  EndIf;

  If messageType=' ' or messageType='*DFT';
    messageType = sqlMsAs;
  EndIf;
  If messageType<>'*TEXTHTML';
    messageType= '*TEXTPLAIN';
  EndIf;

  If psMess.message=' ' or psMess.message='*DFT';
    If messageType='*TEXTHTML';
      psMess.message=%trim(SQLMS01) + '<BR>' +
        %trim(SQLMS02) + '<BR>' +
        %trim(SQLMS03) + '<BR>' +
        %trim(SQLMS04) + '<BR>' +
        %trim(SQLMS05) + '<BR>' +
        %trim(SQLMS06) + '<BR>' +
        %trim(SQLMS07) + '<BR>' +
        %trim(SQLMS08) + '<BR>' +
        %trim(SQLMS09) + '<BR>' +
        %trim(SQLMS10);
    Else;
      psMess.message=%trim(SQLMS01) + EOR +
        %trim(SQLMS02) + EOR +
        %trim(SQLMS03) + EOR +
        %trim(SQLMS04) + EOR +
        %trim(SQLMS05) + EOR +
        %trim(SQLMS06) + EOR +
        %trim(SQLMS07) + EOR +
        %trim(SQLMS08) + EOR +
        %trim(SQLMS09) + EOR +
        %trim(SQLMS10);
    EndIf;
  EndIf;

  // build a command to email the pdf file
  cmd='GUMBOMAIL/GSENDMAIL TOSMTPNAME(';

  For i=1 To psEMLCNT;
    If psEM(i)<>' ';
      cmd+=' (' + %trim(psEM(i)) + ')';
    EndIf;
  EndFor;
  cmd+=' )';

  If psSubject<>' ';
    cmd+=' SUBJECT(''' + %trim(#$DBLQ(psSubject))+''')';
  EndIf;

  message='';
  If psMess.message<>' ' and psMess.message<>'*NONE';
    message=%trim(#$DBLQ(psMess.message));
  EndIf;
  If psInVr='*YES';
    If messageType='*TEXTHTML';
      Break='<BR>';
    Else;
      Break=X'0D25';
    EndIf;
    message+=%trim(Break) +'Variable overrides:' + %trim(Break);
    For i=1 To 10;
      If VRNAME(i)<>' ';
        message+=VRNAME(i) +' = ' + VRDFT(i) + %trim(Break);
      EndIf;
    EndFor;
  EndIf;
  If message<>'';
    cmd+= ' MSG(''' + message +''' '+%trim(messageType)+')';
  EndIf;

  // append created pdf file
  cmd+=' OBJ( (''' + %trim(objPath) + ''' *ATTACHPDF )';

  // append objects if passed
  For x=1 To psObjects.count;
    If %trim(objects(x).name)<>' ';
      cmd+=' (''' + %trim(objects(x).name) + ''' ';
      If objects(x).type<>' ';
        cmd+=' ' + %trim(objects(x).type);
      EndIf;
      cmd+=' )';
    EndIf;
  EndFor;
  // end objects
  cmd+= ' )';

  // append from address if it is populate
  // If ACEMAIL<>' ';
  //   cmd+=' FROM(''' + %trim(ACEMAIL) + ''')';
  // EndIf;

  #$Cmd(cmd:2);

  *INLR = *ON;
  Return;

End-Proc;


// Process Direct Print
Dcl-Proc PROCPRINT;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  If (psUsDt=' ' or psUsDt='*DFT')
  and SQLNAME<>' ';
    psUsDt=SqlName;
  ElseIf (psUsDt=' ' or psUsDt='*DFT')
    and PSPNAME<>' ';
    psUsDt=psPName;
  ElseIf psUsDt=' ' or psUsDt='*DFT';
    psUsDt='SQLMNGR';
  EndIf;

  If psTitle1=' ' or psTitle1='*DFT';
    psTitle1=sqlDesc;
  EndIf;

  If psPInVr=' ' or psPInVr='*DFT';
    psPInVr=sqlPInVr;
  EndIf;
  If PSPINVR<>'*YES';
    psPInVr='*NO ';
  EndIf;

  If psPInQy=' ' or psPInQy='*DFT';
    psPInQy=sqlPInQy;
  EndIf;
  If PSPINQY<>'*YES';
    psPInQy='*NO ';
  EndIf;

  If psHold=' ' or psHold='*DFT';
    psHold=sqlHold;
  EndIf;
  If PSHOLD<>'*YES';
    psHold='*NO ';
  EndIf;

  If psSave=' ' or psSave='*DFT';
    psSave=sqlSave;
  EndIf;
  If PSSAVE<>'*YES';
    psSave='*NO ';
  EndIf;

  If psOutQ.OUTQ=' ' or psOutQ.OUTQ='*DFT';
    #$OUTQ=sqlOutQ;
    #$OQLB=sqlOQLb;
  Else;
    #$OUTQ=psOutQ.OutQ;
    #$OQLB=psOutQ.OQLb;
  EndIf;
  If #$OUTQ=' ';
    #$OUTQ='*JOB';
    #$OQLB=' ';
  EndIf;
  If #$OQLB=' ' and #$OUTQ<>'*JOB';
    #$OQLB='*LIBL';
  EndIf;

  If psCopy=0;
    psCopy=sqlCopy;
  EndIf;
  If psCopy=0;
    psCopy=1;
  EndIf;

  If psFrWd=0;
    psFrWd=sqlFrWd;
  EndIf;
  If psFrWd=0;
    psFrWd=132;
  EndIf;

  If psFrLn=0;
    psFrLn=SqlFrLn;
  EndIf;
  If psFrLn=0;
    psFrLn=66;
  EndIf;

  #$VARS=psVrIn;
  #$COPY  = psCopy;
  #$HOLD  = psHold;
  #$SAVE  = psSave;
  #$USDT  = psUsDt;
  #$FRLN  = psFrLn;
  #$FRWD  = psFrWd;
  #$INVR  = psPInVr;
  #$INQY  = psPInQy;
  #$TITLE1 = psTitle1;
  #$TITLE2 = psTitle2;
  #$TITLE3 = psTitle3;
  #$TITLE4 = psTitle4;
  #$TITLE5 = psTitle5;
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
  #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME:queries);


  *INLR = *ON;
  Return;

End-Proc;


// Process Direct Display
Dcl-Proc PROCDISPLAY;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  Monitor;
    Exec SQL prepare sqlstmp from :SQLSTMP2;
    #$SQLSTT();
  On-Error;
    *IN50=*ON;
    ERM=#$Cntr(PSDSEXCDTA:78);
    Return;
  EndMon;

  // call the display program
  SQLCMDD2(SQLSTMP);

End-Proc;


// Process Direct to PF
Dcl-Proc PROCOUTF;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // build an sql statement to create the file
  If psOutF.OUTL=' ';
    psOutF.OUTL='*CURLIB';
  EndIf;
  SQLSTMP2='CREATE TABLE ' + %trim(psOutF.OUTL) + '/' +
  %trim(psOutF.outf) + ' as ('+%trim(SQLSTMP)+
    ') With DATA';

  Monitor;
    Exec SQL Execute Immediate :SQLSTMP2;
    #$SQLSTT();
  On-Error;
    #$SndMsg(PSDSEXCDTA);
  EndMon;

  *INLR = *ON;
  Return;

End-Proc;


// Process Direct to IFS
Dcl-Proc PROCIFS;
  Dcl-S sqlCmd Char(5000);
  Dcl-S empty Char(4) inz('*YES');
  Dcl-S useText Char(4) inz('*YES');

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // build a command to save the query
  // replace any \ with /
  psIfsFl=%scanrpl('\':'/':psIfsFl);
  psIfsF =%scanrpl('\':'/':psIfsF );
  If #$Last(psIfsFl:1)<>'/' and
  %subst(psIfsF:1:1)<>'/';
    psIfsFl=%trim(psIfsFl)+'/';
  EndIf;
  If %subst(psIfsFl:1:1)<>'/';
    psIfsFl='/'+%trim(psIfsFl);
  EndIf;
  ifsFile=%trim(psIfsFl) + %trim(psIfsF);
  cmd='SQL2XLS SQL(''' + #$DblQ(SQLSTMP) + ''') +
               FILE(''' + %trim(ifsFile) +''') +
               TYPE(' + %trim(psIfsT) +')';

  sqlCmd = SQLSTMP;
  Monitor;
    #$Cmd(cmd:2);
    BuildPCFile(sqlCmd:ifsFile:psIfsT:empty:useText:psSheet:
        psTitle1:psTitle2:psTitle3:psTitle4:psTitle5:queries);
  On-Error;
    #$SndMsg(PSDSEXCDTA);
  EndMon;

  #$SndMsg('File ' + %trim(ifsFile) +' created.');

  *INLR = *ON;
  Return;

End-Proc;


// process a rquest to create a pdf file in the ifs
Dcl-Proc PROCIFSPDF;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // override and hard code some of the print variables
  psUsDt='SQL'+%trim(%char(%date():*ISO0));

  If psTitle1=' ' or psTitle1='*DFT';
    psTitle1=sqlDesc;
  EndIf;

  If psPInVr=' ' or psPInVr='*DFT';
    sqlPInVr=psPInVr;
  EndIf;
  If PSPINVR<>'*YES';
    psPInVr='*NO ';
  EndIf;

  If psPInQy=' ' or psPInQy='*DFT';
    psPInQy=sqlPInQy;
  EndIf;
  If PSPINQY<>'*YES';
    psPInQy='*NO ';
  EndIf;

  psHold='*YES';
  psSave='*NO ';

  psCopy=1;

  If psFrWd=0;
    psFrWd=sqlFrWd;
  EndIf;
  If psFrWd=0;
    psFrWd=132;
  EndIf;

  If psFrLn=0;
    psFrLn=sqlFrLn;
  EndIf;
  If psFrLn=0;
    psFrLn=66;
  EndIf;

  #$VARS  = SQLVARS;
  #$OUTQ  = 'TRASH';
  #$OQLB  = 'QGPL';
  #$COPY  = psCopy;
  #$HOLD  = psHold;
  #$SAVE  = psSave;
  #$USDT  = psUsDt;
  #$FRLN  = psFrLn;
  #$FRWD  = psFrWd;
  #$INVR  = psPInVr;
  #$INQY  = psPInQy;
  #$TITLE1 = psTitle1;
  #$TITLE2 = ' ';
  #$TITLE3 = ' ';
  #$TITLE4 = ' ';
  #$TITLE5 = ' ';
  #$PNAME  = psPName;

  SQLCMDB1(SQLSTMP:#$VARS:#$OUTQ:#$OQLB:#$COPY:#$HOLD:#$SAVE:#$USDT:#$FRLN:#$FRWD:#$INVR:#$INQY:
  #$TITLE1:#$TITLE2:#$TITLE3:#$TITLE4:#$TITLE5:#$PNAME:queries);


  // replace any \ with /
  psIfsFl=%scanrpl('\':'/':psIfsFl);
  psIfsF =%scanrpl('\':'/':psIfsF );
  If #$Last(psIfsFl:1)<>'/' and %subst(psIfsF:1:1)<>'/';
    psIfsFl=%trim(psIfsFl)+'/';
  EndIf;
  If %subst(psIfsFl:1:1)<>'/';
    psIfsFl='/'+%trim(psIfsFl);
  EndIf;
  // convert the output file to a pdf
  If psIfsF=' ' or psIfsF='*DFT';
    psIfsF=sqlFile;
  EndIf;

  // if the file name is blank build one
  If psIfsF=' ';
    psIfsF='SQL'+%trim(WSID) +
    %trim(%char(%date():*ISO0))+%trim(%char(%time():*HMS0));
  EndIf;

  ifsFile=%trim(psIfsFl) + %trim(psIfsF);

  // add .pdf extension if not already on there
  If #$Upify(#$Last(ifsFile:4)) <>'.PDF';
    ifsFile=%trim(ifsFile)+'.PDF';
  EndIf;

  // convert the spool file to a pdf
  #$Cmd('CPYSPLF FILE(SQLCMD03) TOFILE(*TOSTMF) SPLNBR(*LAST) TOSTMF(''' +
  %trim(ifsFile) + ''') WSCST(*PDF)':2);

  // delete the splf
  #$Cmd('DLTSPLF FILE(SQLCMD03) SPLNBR(*LAST)':2);

  #$SndMsg('File ' + %trim(ifsFile) + ' created.');

  *INLR = *ON;
  Return;

End-Proc;


// Process Direct to IFS as JSON
Dcl-Proc PROCIFSJSON;

  // build the sql statement with variable overrides
  If %len(%trim(psName))<=10;
    BLDSQL();
  Else;
    SQLSTMP=psName;
  EndIf;

  // build a command to save the query
  // replace any \ with /
  psIfsFl=%scanrpl('\':'/':psIfsFl);
  psIfsF =%scanrpl('\':'/':psIfsF );
  If #$Last(psIfsFl:1)<>'/' and
    %subst(psIfsF:1:1)<>'/';
    psIfsFl=%trim(psIfsFl)+'/';
  EndIf;
  If %subst(psIfsFl:1:1)<>'/';
    psIfsFl='/'+%trim(psIfsFl);
  EndIf;
  ifsFile=%trim(psIfsFl) + %trim(psIfsF);
  cmd='SQL2JSON SQL(''' + #$DblQ(SQLSTMP) + ''') +
               FILE(''' + %trim(ifsFile) + ''')';

  Monitor;
    #$Cmd(cmd:2);
  On-Error;
    #$SndMsg(PSDSEXCDTA);
  EndMon;

  #$SndMsg('File ' + %trim(ifsFile) +' created.');

  *INLR = *ON;
  Return;

End-Proc;


// Process Direct Query Definition
Dcl-Proc PROCQRYDFN;

  // make sure the query definition exists
  Monitor;
    #$Cmd('CHKOBJ OBJ('+%trim(psQryDfn.library)+'/'+%trim(psQryDfn.file)+') OBJTYPE(*QRYDFN)':2);
  On-Error;
    #$SndMsg('Error - Query definition not found.');
    *INLR = *ON;
    Return;
  EndMon;

  // create source member in qtemp if it doesn't exists
  #$Cmd('CRTSRCPF QTEMP/QQMQRYSRC':1);

  // delete the member if it already exists
  #$Cmd('RMVM QTEMP/QQMQRYSRC ' + %trim(psQryDfn.file):1);

  // load qrydfn to temp source member
  Monitor;
    #$Cmd('RTVQMQRY QMQRY(' +  %trim(psQryDfn.library) + '/' + %trim(psQryDfn.file) +
      ') SRCFILE(QTEMP/QQMQRYSRC) ALWQRYDFN(*YES)');
  On-Error;
    *IN50=*ON;
    ERM=#$Cntr(PSDSEXCDTA:78);
  EndMon;

  // read the source file into the psname variable
  *IN77=*OFF;
  psName=' ';
  Exec SQL Drop Alias QTEMP/temp;
  sqlStm='CREATE OR REPLACE ALIAS QTEMP/TEMP FOR QTEMP/QQMQRYSRC(' + %trim(F19QRYDFN) + '")';
  Exec SQL Execute Immediate :sqlStm;
  Exec SQL Declare qqmCursor2 Cursor For Select srcDta From qtemp/temp;
  Exec SQL Open qqmCursor2;
  Exec SQL Fetch Next From qqmCursor2 Into :srcDta;
  DoW sqlState<'02';
    If (%subst(srcDta:1:1)<>'H' and %subst(srcDta:1:1)<>'V') or *IN77;
      EVAL psName=%trim(psName) + ' ' + %trim(srcDta);
      *IN77=*ON;
    EndIf;
    Exec SQL Fetch Next From qqmCursor2 Into :srcDta;
  EndDo;
  Exec SQL Close qqmCursor2;
  Exec SQL Drop Alias QTEMP/temp;

End-Proc;
