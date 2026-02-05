**free

// Data Area to store output options system defautls
Dcl-Ds OTODFT dtaara len(300);
  sysPstFlr char(128); // System post folder
  sysFrmNme char(30); // System post folder
  sysFrmEml char(60); // System post folder
  sysAlwEml char(1);   // allow email Y/N
  sysAlwArc char(1);   // allow archive Y/N
  sysAlwFax char(1);   // allow faxing Y/N
  sysAutOpt char(1);   // allow automaitcally display output options screen when running a report
  sysUniNbr packed(8); // next unieuq number for use if a file name is not selected
End-Ds;

// Data structure for output options
// If this is changed OTOSRVC1PR must be changed to match it.
Dcl-Ds otoDs;

  // Passed in, just passed along to all programs that use this
  outMdl like(APLDCT.outMdl);  // Module
  pgmNme like(APLDCT.pgmNme);  // Program Name

  // option types selected
  prtOut like(APLDCT.prtOut);  // Print output (Y/N)
  emlOut like(APLDCT.emlOut);  // Email output (Y/N)
  arcOut like(APLDCT.arcOut);  // Archie ouput (Y/N)
  faxOut like(APLDCT.faxOut);  // Fax Output

  // Use to determine if a posting archive option is requried
  pstFlg like(APLDCT.pstFlg);  // post (Y/N)

  // print options, most of these are used via a CHGPRTF command
  prtDev like(APLDCT.prtDev);  // Printer ID
  prtOtq like(APLDCT.prtOtq);  // ouptut queue
  hldOut like(APLDCT.hldOut);  // hold (*YES/*NO)
  savOut like(APLDCT.savOut);  // save output (*YES/*NO)
  prtFrm like(APLDCT.prtFrm);  // form
  usrDta like(APLDCT.usrDta);  // user data
  nbrCpy like(APLDCT.nbrCpy);  // copies
  prtQul like(APLDCT.prtQul);  // print quality
  prtOvl like(APLDCT.prtOvl);  // overlay, used on chgprtf

  // Archive Options
  arcFlr like(APLDCT.arcFlr);  // Archive File name
  aarFlr like(APLDCT.aarFlr);  // Auto Archive folder

  // Fax Options
  faxNbr like(APLDCT.faxNbr);  // fax number

  // Email options
  emlAdd like(APLDCT.emlAdd);  // Email address
  emlNme like(APLDCT.emlNme);  // 30
  frmEml like(APLDCT.frmEml);  // from address
  frmNme like(APLDCT.frmNme);  // from name
  cc1Eml like(APLDCT.cc1Eml);  // cc address 1
  cc1Nme like(APLDCT.cc1Nme);  // cc name 1
  cc2Eml like(APLDCT.cc2Eml);  // cc address 2
  cc2Nme like(APLDCT.cc2Nme);  // cc name 2
  cc3Eml like(APLDCT.cc3Eml);  // cc address 3
  cc3Nme like(APLDCT.cc3Nme);  // cc name 3
  bccEml like(APLDCT.bccEml);  // bcc address
  bccNme like(APLDCT.bccNme);  // bcc name
  emlSbj like(APLDCT.emlSbj);  // subject

  // Attachment options, used for email attachments and archives
  ataTyp like(APLDCT.ataTyp);  // Attachment type
  vldAta like(APLDCT.vldAta);  // Valid Attachement Types,=PDF,TIFF;2=+CSV,3=+XML,4=+XLS
  ataNme like(APLDCT.ataNme);  // File Name
  ataFmt like(APLDCT.ataFmt);  // CSV File format (1=Data,2=Report)
  crtXma like(APLDCT.crtXma);  // Create XML attribute file (Y/N)

  // Message used on fax cover sheet and the email body
  emlMsg01 like(APLDCT.emlMsg01);  // Message 1
  emlMsg02 like(APLDCT.emlMsg02);  // Message 2
  emlMsg03 like(APLDCT.emlMsg03);  // Message 3
  emlMsg04 like(APLDCT.emlMsg04);  // Message 4
  emlMsg05 like(APLDCT.emlMsg05);  // Message 5
  emlMsg06 like(APLDCT.emlMsg06);  // Message 6
  emlMsg07 like(APLDCT.emlMsg07);  // Message 7
  emlMsg08 like(APLDCT.emlMsg08);  // Message 8
  emlMsg09 like(APLDCT.emlMsg09);  // Message 9
  emlMsg10 like(APLDCT.emlMsg10);  // Message 10
  emlMsg11 like(APLDCT.emlMsg11);  // Message 11
  emlMsg12 like(APLDCT.emlMsg12);  // Message 12

  // system post folder, only used if this is a posting
  pstFlr like(APLDCT.pstFlr);  // System Post Folder

  prtFle like(APLDCT.prtFle); // Print file name
  pgeWid like(aplDct.pgeWid); // Print File page width
  pgeLen like(aplDct.pgeLen); // Print File page length

  // ending char, contains * to ensure the full parm is passed when using CL programs
  endChr like(APLDCT.endChr) Pos(4096) inz('*');

End-Ds;

// Used in OTODFtB1, nothing else should call this
Dcl-Pr OTODFTC1 ExtPgm;
  prtOtq like(APLDCT.prtOtq);
  prtDev like(APLDCT.prtDev);
End-Pr;

// Used in OTODFtB1, nothing else should call this
Dcl-Pr OTODFTC2 ExtPgm;
  prtOtq like(APLDCT.prtOtq);
  prtDev like(APLDCT.prtDev);
End-Pr;


// Prototype for OTODFTRB1, populate otoDs with defaults
Dcl-Pr OTODFTB1 ExtPgm;
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
End-Pr;

// Prototype for OTODFTRB1 idsplay output opitons prompt screen
Dcl-Pr OTOPMTD1 ExtPgm;
  pmrOto Like(otoDs);
  pmrKeyPressed Like(keyPressed) options(*nopass);
End-Pr;

// Override a print file with ouput options
Dcl-Pr OTOOVRC1 ExtPgm;
  pmrOto Like(otoDs);
End-Pr;

// Process output options
Dcl-Pr OTOPRCC1 ExtPgm;
  pmrOto Like(otoDs);
End-Pr;

// Fix File name
Dcl-Pr OTOPRCB2 ExtPgm;
  pmrOto Like(otoDs);
End-Pr;
