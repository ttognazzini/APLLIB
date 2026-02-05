**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// Ouptup Options - Setup default ouput options data structure

// In CL programs use command OTODFT to populate the data structure like this:
//  OTODFT &OTODS &MOD &PGMNME EMLMSG01('Attached is the requested report.')

// In an RPGL program use the following:
//   OTODFTB1(oto:mod:pgmNme);
// Then you can change any values you need to like this:
//   emlMsg01 = 'Attached is the requested report';

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,OTOSRVV1PR
/Copy QSRC,CHGUSRB1PR


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('OTODFTB1');
    oto likeds(otoDs);                                     // 1 oto Ds
    pmrOutMdl like(APLDCT.OutMdl) const;                   // 2 module
    pmrPgmNme like(APLDCT.pgmNme) const;                   // 3 program
    pmrPrtFle like(APLDCT.prtFle) const;                   // 4 Print file name
    // optional parameters
    pmrPgeWid like(APLDCT.pgeWid) const options(*nopass:*omit);  // 5 Print file page width
    pmrPgeLen like(APLDCT.pgeLen) const options(*nopass:*omit);  // 6 Print file page length
    pmrVldAta like(APLDCT.vldAta) const options(*nopass:*omit);  // 7 Valid Attach Types,=PDF,TIFF;2=+CSV,3=+XML,4=+XLS
    pmrRptTtl like(APLDCT.rptTtl) const options(*nopass:*omit);  // 8 report title, used for ataNme, emlSbj, and emlMsg
    pmrPstBch like(APLDCT.pstBch) const options(*nopass:*omit);  // 9 used in names and sets postflag if passed
  End-Pi;

  Clear oto;

  // set some gerenic defualts
  prtOut = 'N';
  emlOut = 'Y';
  arcOut = 'N';
  faxOut = 'N';
  pstFlg = 'N';
  hldOut = '*NO';
  savOut = '*NO';
  nbrCpy = '001';
  prtQul = '*STD';

  // get jobs default printer device and output queue
  OTODFTC1(prtOtq:prtDev);

  // set defaults based on parameters passed in
  outMdl = pmrOutMdl;
  pgmNme = pmrPgmNme;
  prtFle = pmrPrtFle;
  // Print file page width
  If %parms >= 5 and %addr(pmrPgeWid) <> *null;
    pgeWid = pmrPgeWid;
  Else;
    pgeWid = '132';
  EndIf;
  // Print file page length
  If %parms >= 6 and %addr(pmrPgeLen) <> *null;
    pgeLen = pmrPgeLen;
  Else;
    pgeLen = '066';
  EndIf;
  // Valid Attachement Types,1=PDF,TIFF;2=+CSV,3=+XML,4=+XLS
  If %parms >= 7 and %addr(pmrVldAta) <> *null;
    vldAta = pmrVldAta;
  Else;
    vldAta = '1';
  EndIf;

  // if a report title is passed, default the file name, email subject and message
  // add in post batch if that is passed
  If %parms >= 9 and %addr(pmrRptTtl) <> *null and %addr(pmrPstBch) <> *null and pmrPstBch <> 0;
    ataNme = %trim(pmrRptTtl);
    emlSbj = %trim(pmrRptTtl) + ' Post Batch ' + %trim(%editc(pmrPstBch:'Z')) + ' (' + %trim(pgmNme) + ')';
    emlMsg01 = 'Attached is the requested ' + %trim(pmrRptTtl) + '.';
    emlMsg02 = 'Post Batch ' + %trim(%editc(pmrPstBch:'Z'));
    pstFlg = 'Y';
  ElseIf %parms >= 8 and %addr(pmrRptTtl) <> *null;
    ataNme = %trim(pmrRptTtl); // Defaults a file name
    emlSbj = %trim(pmrRptTtl) + ' (' + %trim(pgmNme) + ')'; // default the email subject
    emlMsg01 = 'Attached is the requested ' + %trim(pmrRptTtl) + '.'; // default the email message
  EndIf;

  OTOPRCB2(otoDs); // this cleans up invalid characters in the file name

  // Get system values from data area
  in OTODFT;

  // get user defaults from USRMST
  Exec SQL
    Select
      case when arcFlr <> '' then arcFlr else :arcFlr end,
      case when prtDev <> '' then prtDev else :prtDev end,
      case when prtOtq <> '' then prtOtq else :prtOtq end,
      case when aarFlr <> '' then aarFlr else :aarFlr end,
      case when otoEml <> '' then otoEml else :emlAdd end,
      case when otoNme <> '' then otoNme else :emlNme end,
      case when hldOut <> '' then hldOut else :hldOut end,
      case when savOut <> '' then savOut else :savOut end,
      case when ataTyp <> '' then ataTyp else :ataTyp end,
      case when ataFmt <> '' then ataFmt else :ataFmt end,
      case when prtOut <> '' then prtOut else :prtOut end,
      case when emlOut <> '' then emlOut else :emlOut end,
      case when arcOut <> '' then arcOut else :arcOut end,
      case when faxOut <> '' then faxOut else :faxOut end
    into  :arcFlr, :prtDev, :prtOtq, :aarFlr, :emlAdd, :emlNme, :hldOut,
          :savOut, :ataTyp, :ataFmt, :prtOut, :emlOut, :arcOut, :faxOut
    From USRMST
    Where usrPrf = :user;

  // get user defaults from fabricut files
  Exec SQL
    Select
      case when acEmail <> '' and :emlAdd = '' then acEmail else :emlAdd end,
      case when acEmail <> '' then acEmail else :frmEml end,
      case when acFNam  <> '' then trim(acFNam) || ' ' || trim(acLNam) else :frmNme end
    into   :emlAdd, :frmEml, :frmNme
    From ACCESSPF
    Where acUPrf = :user;

  // If there is no from name override to the system default
  If frmNme = '';
    frmNme = sysFrmNme;
  EndIf;
  // If there is no from email override to the system default
  If frmEml = '';
    frmEml = sysFrmEml;
  EndIf;

  // add some defaults, in case nothing else populated them
  If not (ataTyp in %list('*PDF':'*TEXT':'*CSV':'*XML':'*XLSX'));
    ataTyp = '*PDF';
  EndIf;
  If not (ataFmt in %list('1':'2'));
    ataFmt = '2';
  EndIf;

  // Overrides *USRPRF and *DEV special values in the prtDev and prtOtq values
  OTODFTC2(prtOtq:prtDev);

  // If the file name is blank generate a unique number for the name
  If ataNme = '';
    // Try to create the data area in case it does not exist yet
    #$CMD('CRTDTAARA  QGPL/OTODFT TYPE(*CHAR) LEN(300) VALUE(''00000000'')':1);
    in *lock OTODFT;
    sysUniNbr += 1;
    out OTODFT;
    ataNme = %char(sysUniNbr);
  EndIf;

  // Append date and time to the file name
  ataNme = %trim(ataNme) + ' ' + %trim(%char(%timestamp():*ISO));

  // set the system post folder and clean it up
  pstFlr = %trim(sysPstFlr);

  // change \ to / if at begining
  If %subst(pstFlr:1:1) = '\';
    pstFlr = '/' + %subst(pstFlr:2:127);
  EndIf;

  // add beginning / if not there
  If %subst(pstFlr:1:1) <> '/' and pstFlr <> '';
    pstFlr = '/' + pstFlr;
  EndIf;

  // make folder if not found
  CHGUSRB1('ZZWINCHTAG');
  #$CMD('MD '''+%trim(pstFlr)+'''':1);

  // add module and year, make folder if not found
  pstFlr = %trim(pstFlr) + '/' + outMdl + %subst(%char(%date():*iso):1:4);
  #$CMD('MD '''+%trim(pstFlr)+'''':1);
  CHGUSRB1();

  // Gumbo only allows 128 character file names with the extension so cut it down here */
  ataNme = %trim(%subst(ataNme:1:123));

  oto = otoDs;

End-Proc;
