**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Build APLLIB - Program Master Seeds


/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;

Dcl-Proc Main;

  AddPgmMst('$OPTIONS':'Static Procedures for Template Programs':'':'');
  AddPgmMst('APLLIBBP':'Application Libraries - Auto Prompt':'':'');
  AddPgmMst('APLLIBB0':'Application Libraries - Navigator':'':'');
  AddPgmMst('APLLIBDZ':'Application Libraries - Filters':'F4=Prompt':'');
  AddPgmMst('APLLIBD1':'Application Libraries - List':'F6=Add:F13=Filter':'*STD');
  AddPgmMst('APLLIBD2':'Application Libraries - Details':'F4=Prompt':'');
  AddPgmMst('APLSRVV1':'Applicaiton Serivce Program':'':'');
  AddPgmMst('AUDLOGB0':'File Audit Log Navigator':'':'');
  AddPgmMst('AUDLOGDZ':'File Audit Log Filters':'':'');
  AddPgmMst('AUDLOGD1':'File Audit Log List':'F13=Filter':'5=View');
  AddPgmMst('AUDLOGD2':'File Audit Log Detail':'':'');
  AddPgmMst('BASFNCB1':'APLLIB Base Functions Service Program - Test':'':'');
  AddPgmMst('BASFNCV1':'APLLIB Base Functions Service Program':'':'');
  AddPgmMst('BLDAPLB2':'Build APLLIB - Dictionary Master seeds':'':'');
  AddPgmMst('BLDAPLB3':'Build APLLIB - File Master Seeds':'':'');
  AddPgmMst('BLDAPLB4':'Build APLLIB - Program Master Seeds':'':'');
  AddPgmMst('CHGDTQB1':'Change Data Queue - CPP(CGHDTAQ)':'':'');
  AddPgmMst('CHGDTQB2':'Change Data Queue - POP':'':'');
  AddPgmMst('CHGDTQB3':'Change Data Queue - VCP':'':'');
  AddPgmMst('CHGDTQM1':'Change Data Queue - CMD(CGHDTAQ)':'':'');
  AddPgmMst('CHGDTQP1':'Change Data Queue - Help Panel':'':'');
  AddPgmMst('CHGMSDB1':'Change Message Description - CPP(CHGMSD)':'':'');
  AddPgmMst('CHGMSDM1':'Change Message Description - CMD(CHGMSD)':'':'');
  AddPgmMst('CHGMSDP1':'Change Message Description - Help Panel':'':'');
  AddPgmMst('CHGUSRB1':'Change User on Current Job':'':'');
  AddPgmMst('CMPSPLC1':'Compare Spool Files':'':'');
  AddPgmMst('CMPSPLM1':'Compare Spool Files':'':'');
  AddPgmMst('CMPSPLP1':'Compare Spool Files':'':'');
  AddPgmMst('CNTVARB1':'Center Variable Command for CLLE':'':'');
  AddPgmMst('CNTVARM1':'Center Variable Command for CLLE':'':'');
  AddPgmMst('CNTVARP1':'Center Variable Command for CLLE':'':'');
  AddPgmMst('CPYMSDB1':'Copy Message Description - CPP(CPYMSD)':'':'');
  AddPgmMst('CPYMSDM1':'Copy Message Description - CMD(CPYMSD)':'':'');
  AddPgmMst('CPYMSDP1':'Copy Message Description - Help Panel':'':'');
  AddPgmMst('DCTFLDBP':'Dictionary Fields - Auto Prompt':'':'');
  AddPgmMst('DCTFLDB0':'Dictionary Fields - Navigator':'':'');
  AddPgmMst('DCTFLDB8':'Re-Build Dictionary From DCTFLD':'':'');
  AddPgmMst('DCTFLDB9':'Build Dictionary Field From DCTFLD':'':'');
  AddPgmMst('DCTFLDDL':'Dictionary Fields - Load From File':'':'');
  AddPgmMst('DCTFLDDZ':'Dictionary Fields - Filter':'F4=Prompt':'');
  AddPgmMst('DCTFLDD1':'Dictionary Fields - List':'F6=Add:F13=Filter:F18=Load From File'
                      :'*STD:6=Help:9=Enum Values:11=Log');
  AddPgmMst('DCTFLDD2':'Dictionary Fields - Detail':'F4=Prompt:F6=Field Builder:F8=Segments':'');
  AddPgmMst('DCTFLDD3':'Dictionary Fields - Field Builder':'F4=Prompt':'');
  AddPgmMst('DCTFLDS1':'Build DCTFLD From existing Database':'':'');
  AddPgmMst('DCTMSTBP':'Dictionary Master - Auto Prompt':'':'');
  AddPgmMst('DCTMSTBR':'Dictionary Master - Report Driver':'':'');
  AddPgmMst('DCTMSTB0':'Dictionary Master - Navigator':'':'');
  AddPgmMst('DCTMSTB1':'Dictionary Master - Report':'':'');
  AddPgmMst('DCTMSTDR':'Dictionary Master - Report Prompt':'F4=Prompt':'');
  AddPgmMst('DCTMSTDZ':'Dictionary Master - Filters':'F4=Prompt':'');
  AddPgmMst('DCTMSTD1':'Dictionary Master - List Screen':'F6=Add:F13=Filter'
                      :'*STD:6=Fields:9=Rebuild Dictionary:11=Log');
  AddPgmMst('DCTMSTD2':'Dictionary Master - Detail':'F4=Prompt':'');
  AddPgmMst('DCTMSTM1':'Dictionary Master - List Screen':'':'');
  AddPgmMst('DCTMSTO1':'Dictionary Master - Report':'':'');
  AddPgmMst('DCTSEGBP':'Dictionary Segments - Auto Pormpt':'':'');
  AddPgmMst('DCTSEGB0':'Dictionary Segments - Navigator':'':'');
  AddPgmMst('DCTSEGDZ':'Dictionary Segments - Filters':'F4=Prompt':'');
  AddPgmMst('DCTSEGD1':'Dictionary Segments - List':'F6=Add:F13=Filter':'*STD');
  AddPgmMst('DCTSEGD2':'Dictionary Segments - Detail':'':'');
  AddPgmMst('DCTSEGM1':'Dictionary Segments - List':'':'');
  AddPgmMst('DCTVALBP':'Dictionary Values - Auto Prompt':'':'');
  AddPgmMst('DCTVALB0':'Dictionary Values - Navigator':'':'');
  AddPgmMst('DCTVALDP':'Dictionary Values - Prompt':'':'1=Select:8=Position To');
  AddPgmMst('DCTVALDZ':'Dictionary Values - Filters':'F4=Prompt':'');
  AddPgmMst('DCTVALD1':'Dictionary Values - List':'':'*STD');
  AddPgmMst('DCTVALD2':'Dictionary Values - Details':'':'');
  AddPgmMst('DSPDTQB1':'Display Data Queue - Test Data Queue Stuff':'':'');
  AddPgmMst('DSPDTQD1':'Display Data Queue - CPP(DSPDTAQ)':'':'');
  AddPgmMst('DSPDTQM1':'Display Data Queue - Command(DSPDTAQ)':'':'');
  AddPgmMst('DSPFLEC1':'Display Files - List':'':'');
  AddPgmMst('DSPFLED1':'Display Files - List':'':'8=Position To');
  AddPgmMst('DSPFLEM1':'Display Files - List':'':'');
  AddPgmMst('DSPPNLB1':'Display Panel Group CPP (DSPPNLGRP)':'':'');
  AddPgmMst('EDTNBR  ':'SQL Function EDTNBR, Edit a Numeric Field':'':'');
  AddPgmMst('EDTNBRN1':'SQL Function EDTNBR, Edit a Numeric Field':'':'');
  AddPgmMst('EDTNBRTS':'SQL Function EDTNBR, Edit a Numeric Field - Test':'':'');
  AddPgmMst('EDTNBRV1':'SQL Function EDTNBR, Edit a Numeric Field':'':'');
  AddPgmMst('EMLEXTC1':'Exit program to email from WRKSPLF... RJS':'':'');
  AddPgmMst('EMLEXTC2':'Exit program to email from WRKSPLF... GumboMail':'':'');
  AddPgmMst('EMLEXTC3':'Exit program to email from WRKSPLF... KeyesMail':'':'');
  AddPgmMst('EMLEXTF1':'Exit program to email from WRKSPLF... RJS':'':'');
  AddPgmMst('EMLEXTF2':'Exit program to email from WRKSPLF... GumboMail':'':'');
  AddPgmMst('EMLEXTF3':'Exit program to email from WRKSPLF... KeyesMail':'':'');
  AddPgmMst('EMLEXTP1':'Exit program to email from WRKSPLF... RJS':'':'');
  AddPgmMst('EMLSQLB1':'Email the results of an sql - RJS Version':'':'');
  AddPgmMst('EMLSQLB2':'Create a PC (Excel,CSV,XML) file from an SQL':'':'');
  AddPgmMst('EMLSQLB2GM':'Email the results of an sql - Gumbo Mail version':'':'');
  AddPgmMst('EMLSQLB3':'Create a JSON file from an SQL Statement':'':'');
  AddPgmMst('EMLSQLM1':'Email results of an SQL Statement, Command EMLSQL':'':'');
  AddPgmMst('EMLSQLM2':'Create a PC (Excel,CSV,XML) from SQL, Cmd SQL2XLS':'':'');
  AddPgmMst('EMLSQLM3':'Create a JSON file from SQL, CMD SQL2JSON':'':'');
  AddPgmMst('EMLSQLP1':'Email results of an SQL Statement, Cmd Help':'':'');
  AddPgmMst('EMLSQLP2':'Create a PC (Excel,CSV,XML) from SQL, Cmd Help':'':'');
  AddPgmMst('EMLSQLP3':'Create a JSON file from SQL, CMD Help':'':'');
  AddPgmMst('FLDNTED1':'Field Notes':'F6=Insert Line:F10=Copy Line:F14=Delete Line:F15=Split Line:F16=Combine Line':'');
  AddPgmMst('FLDTYPBP':'Field Types - Auto Prompt':'':'');
  AddPgmMst('FLDTYPB0':'Field Types - Navigator':'':'');
  AddPgmMst('FLDTYPDZ':'Field Types - Filters':'F4=Prompt':'');
  AddPgmMst('FLDTYPD1':'Field Types - List':'F6=Add:F11=More Detail:F13=Filter':'*STD');
  AddPgmMst('FLDTYPD2':'Field Types - Details':'F4=Prompt':'');
  AddPgmMst('FLEERRB0':'File Errors - Navigator':'':'');
  AddPgmMst('FLEERRD1':'File Errors - List':'F4=Prompt':'5=View');
  AddPgmMst('FLEERRD2':'File Errors - Details':'':'');
  AddPgmMst('FLEFLDB0':'File Fields - Navigator':'':'');
  AddPgmMst('FLEFLDB1':'Sync file and FLEFLD':'':'');
  AddPgmMst('FLEFLDB7':'Safely rebuild a file, like fmtopt(*map)':'':'');
  AddPgmMst('FLEFLDB8':'Re-Build File from FLEFLD':'':'');
  AddPgmMst('FLEFLDB9':'Rebuild field in a file':'':'');
  AddPgmMst('FLEFLDDZ':'File Fields - Filter':'F4=Prompt':'');
  AddPgmMst('FLEFLDD1':'File Fields - List':'F6=Add:F10=Change View:F13=Filter:F16=Update File'
                                           :'*STD:6=Notes:9=Enum Values:11=Log:16=Hard Delete');
  AddPgmMst('FLEFLDD2':'File Fields - Detail':'F4=Prompt:F10=Enum Values':'');
  AddPgmMst('FLEIDXB0':'File Indexes - Navigator':'':'');
  AddPgmMst('FLEIDXDZ':'File Indexes - Filter':'F4=Prompt':'');
  AddPgmMst('FLEIDXD1':'File Indexes - List':'F6=Add:F13=Filter':'*STD');
  AddPgmMst('FLELOGB0':'File Log - Navigator':'':'');
  AddPgmMst('FLELOGD1':'File Log - List':'F4=Prompt':'*STD');
  AddPgmMst('FLELOGD2':'File Log - Details':'':'');
  AddPgmMst('FLEMSTB0':'File Master - Navigator':'':'');
  AddPgmMst('FLEMSTB1':'File Master - Hard Delete':'':'');
  AddPgmMst('FLEMSTB2':'File Master - Email File Error List':'':'');
  AddPgmMst('FLEMSTB3':'File Master - Build Errors':'':'');
  AddPgmMst('FLEMSTB4':'File Master - Build RLA Errors':'':'');
  AddPgmMst('FLEMSTB5':'File Master - Add all SQL tables in production lib':'':'');
  AddPgmMst('FLEMSTB6':'File Master - Nightly Scheduled Change Processor':'':'');
  AddPgmMst('FLEMSTB7':'Create trigger program for each file':'':'');
  AddPgmMst('FLEMSTB8':'File Master - Build file errors for all files':'':'');
  AddPgmMst('FLEMSTB9':'File Master - Create Source Members':'':'');
  AddPgmMst('FLEMSTDZ':'File Master - Filter':'F4=Prompt':'');
  AddPgmMst('FLEMSTD1':'File Master - List':'F6=Add:F11=More Detail:F13=Filter'
                                           :'*STD:6=Indexes:9=Notes:10=Log:11=Errors:16=Hard Delete');
  AddPgmMst('FLEMSTD2':'File Master - Detail':'F4=Prompt':'');
  AddPgmMst('FLEMSTD3':'File Master - Copy Options':'F4=Prompt':'');
  AddPgmMst('FLEMSTD4':'File Master - Create Source Code':'F4=Prompt':'');
  AddPgmMst('FLENTED1':'File Notes - List'
           :'F6=Insert Line:F10=Copy Line:F14=Delete Line:F15=Split Line:F16=Combine Line':'');
  AddPgmMst('HLPDTLD1':'Help Details'
           :'F6=Insert Line:F9=View:F10=Copy Line:F14=Delete Line:F15=Split Line:F16=Combine Line':'');
  AddPgmMst('HLPMSTB0':'Help Master - Navigator':'':'');
  AddPgmMst('HLPMSTB1':'Help Master - Create Panel Group':'':'');
  AddPgmMst('HLPMSTB2':'Help Master - CRTDSPF Pre-Processor':'':'');
  AddPgmMst('HLPMSTB3':'Help Master - CRTDSPF Override CMD':'':'');
  AddPgmMst('HLPMSTB4':'Help Master - Display Help Text UIM':'':'');
  AddPgmMst('HLPMSTDZ':'Help Master - Filters':'F4=Prompt':'');
  AddPgmMst('HLPMSTD1':'Help Master - List':'F13=Filter':'*STD:5=View Help');
  AddPgmMst('IDXFLDD1':'File Index Fields Detail':'F4=Prompt':'');
  AddPgmMst('IFSPMTD1':'IFS File/Folder Prompt':'F7=Previous Folder':'1=Select:7=Browse Directory:8=Position To');
  AddPgmMst('LSTQRYB1':'List Query Details - CPP(LSTQRY)':'':'');
  AddPgmMst('LSTQRYM1':'List Query Details - LSTQRY':'':'');
  AddPgmMst('LSTQRYP1':'List Query Details - Help(LSTQRY)':'':'');
  AddPgmMst('MONMSQB1':'Monitor Message Queue, Email Messages - Fix SECLVL':'':'');
  AddPgmMst('MONMSQC1':'Monitor Message Queue, Email Messages - Submit Job':'':'');
  AddPgmMst('MONMSQM1':'Monitor Message Queue, Email Messages':'':'');
  AddPgmMst('MONMSQP1':'Monitor Message Queue, Email Messages - Help Text':'':'');
  AddPgmMst('MSGDTAT1':'Parse the Message Data from the Message File':'':'');
  AddPgmMst('MSGDTAT1FN':'Parse the Message Data from the Message File':'':'');
  AddPgmMst('MSGDTAT2':'Get Field Data for a Message ID':'':'');
  AddPgmMst('MSGDTAT2FN':'Get Field Data for a Message ID':'':'');
  AddPgmMst('MSGDTLB0':'Message File Detail - Navigator':'':'');
  AddPgmMst('MSGDTLDZ':'Message File Detail - Filter':'':'');
  AddPgmMst('MSGDTLD1':'Message File Detail - List':'F11=More Detail:F13=Filter'
                      :'1=Add:2=Update:3=Copy:4=Delete:5=View');
  AddPgmMst('MSGMSTB0':'Message Files - Navigator':'':'');
  AddPgmMst('MSGMSTD1':'Message Files - List':'F13=Filters':'1=Select:1=Add:2=Update:5=View:6=Messages');
  AddPgmMst('MSGMSTDZ':'Message Files - Filter':'F4=Prompt':'');
  AddPgmMst('OBJOWNB1':'Email list of objects not owner errors':'':'');
  AddPgmMst('OTOAUTB1':'Output Options - Preform auto prompt if setup':'':'');
  AddPgmMst('OTODFTB1':'Output Options - Setup default ouput options DS':'':'');
  AddPgmMst('OTODFTC1':'Output Options - Get Jobs Default Printer':'':'');
  AddPgmMst('OTODFTC2':'Output Options - Get Jobs Default Printer':'':'');
  AddPgmMst('OTODFTM1':'Output Options - Get Default Output Options':'':'');
  AddPgmMst('OTOOVRC1':'Output Options - Override Print File':'':'');
  AddPgmMst('OTOPMTD1':'Output Options - Selection/Print Screen':'F4=Prompt:F16=User Defaults':'');
  AddPgmMst('OTOSRVC1PR':'Output Queues - Just the OTO DS Definition':'':'');
  AddPgmMst('OTOSRVV1PR':'Output Queues - Prototypes and DS''s':'':'');
  AddPgmMst('OTOPMTD2':'Output Options - Email Options':'F4=Prompt':'');
  AddPgmMst('OTOPMTD3':'Output Options - Fax Options':'F4=Prompt':'');
  AddPgmMst('OTOPMTD4':'Output Options - Archive Options':'F4=Prompt':'');
  AddPgmMst('OTOPRCB1':'Output Options - Create XML Attrbiute File':'':'');
  AddPgmMst('OTOPRCB2':'Output Options - Fix File Name':'':'');
  AddPgmMst('OTOPRCC1':'Output Options - Aply Options to SPLF':'':'');
  AddPgmMst('OTOPRMD1':'Output Options - Parameter Maintenance':'F4=Prompt':'');
  AddPgmMst('OTOPRTC8':'Output Options - Not Used':'':'');
  AddPgmMst('OTQMSTBP':'Output Queues - Auto Prompt':'':'');
  AddPgmMst('OTQMSTB0':'Output Queues - Navigator':'':'');
  AddPgmMst('OTQMSTDZ':'Output Queues - Filters':'F4=Prompt':'');
  AddPgmMst('OTQMSTD1':'Output Queues - List':'F6=Add:F11=More Detail:F13=Filter'
                      :'6=Work With Outq:9=Start Writer:11=Log:12=End Writer');
  AddPgmMst('OTQMSTD2':'Output Queues - Details':'F4=Prompt':'');
  AddPgmMst('OUTFLEB1':'Test OUTFLEV1 Service Program':'':'');
  AddPgmMst('OUTFLEB2':'Test OUTFLEV1 #$XML options':'':'');
  AddPgmMst('OUTFLEB3':'Test OUTFLEV1 #$CSV options':'':'');
  AddPgmMst('PGMACTBP':'Program Actions - Auto Prompt':'':'');
  AddPgmMst('PGMACTB0':'Program Actions - Navigator':'':'');
  AddPgmMst('PGMACTDP':'Program Actions - Prompt':'':'');
  AddPgmMst('PGMACTDZ':'Program Actions - Filters':'F4=Prompt':'');
  AddPgmMst('PGMACTD1':'Program Actions - List':'F13=Filter':'*STD');
  AddPgmMst('PGMACTD2':'Program Actions - Details':'F4=Prompt':'');
  AddPgmMst('PGMFNCB0':'Program Function Keys - Navigator':'':'');
  AddPgmMst('PGMFNCDZ':'Program Function Keys - Filters':'F4=Prompt':'');
  AddPgmMst('PGMFNCD1':'Program Function Keys - List':'F11=More Detail:F13=Filter':'*STD:16=Hard Delete');
  AddPgmMst('PGMFNCD2':'Program Function Keys - Details':'F4=Prompt':'');
  AddPgmMst('PGMHLPB0':'Program Help - Navigator':'':'');
  AddPgmMst('PGMHLPD1':'Program Help - List':'F9=Rebuild Panel Group':'*STD:6=Dictionary:7=System Default');
  AddPgmMst('PGMHLPT1':'Program Help - Table Function':'':'');
  AddPgmMst('PGMMSTB0':'Program Master - Navigator':'':'');
  AddPgmMst('PGMMSTB1':'Program Master - Copy Program':'':'');
  AddPgmMst('PGMMSTDZ':'Program Master - Filters':'F4=Prompt':'');
  AddPgmMst('PGMMSTD1':'Program Master - List':'F6=Add:F11=More Detail:F13=Filter'
           :'*STD:6=Help:7=Notes:9=Function Keys:10=SFL Options:11=Actions');
  AddPgmMst('PGMMSTD2':'Program Master - Details':'F4=Prompt':'');
  AddPgmMst('PGMMSTD3':'Program Master - Copy Options':'':'');
  AddPgmMst('PGMOPTB0':'Program Options - Navigator':'':'');
  AddPgmMst('PGMOPTDZ':'Program Options - Filter':'F4=Prompt':'');
  AddPgmMst('PGMOPTD1':'Program Options - List':'F11=More Detail:F13=Filter':'*STD:16=Hard Delete');
  AddPgmMst('PGMOPTD2':'Program Options - Details':'F4=Prompt':'');
  AddPgmMst('PMPWDWD1':'Display Prompt Window':'':'');
  AddPgmMst('PRCSCRD1':'Generic Processing Screen':'':'');
  AddPgmMst('PRTQRYC1':'Print Query Definition - CPP(PRTQRYD)':'':'');
  AddPgmMst('PRTQRYM1':'Print Query Definition - PRTQRYD':'':'');
  AddPgmMst('PRTQRYP1':'Print Query Definition - Help(PRTQRYD)':'':'');
  AddPgmMst('PRTSTFM1':'Print Stream File - PRTSTMF':'':'');
  AddPgmMst('PRTSTFB1':'Print Stream File - CPP(PRTSTMF)':'':'');
  AddPgmMst('PRTSTFPR':'Print Stream File - Copy book':'':'');
  AddPgmMst('QRYLOGB1':'Querry Job Logs - CPP(QRYJOBLOG)':'':'');
  AddPgmMst('ROLAPRDZ':'Role Approvals - Filter':'F4=Prompt':'');
  AddPgmMst('ROLAPRD1':'Role Approvals - List':'F11=Show Inactive:F13=Filter':'');
  AddPgmMst('ROLMSTBP':'Role Master - Auto Prompt':'':'');
  AddPgmMst('ROLMSTBR':'Role Master - Report Driver':'':'');
  AddPgmMst('ROLMSTB0':'Role Master - Navigator':'':'');
  AddPgmMst('ROLMSTB1':'Role Master - Report':'':'');
  AddPgmMst('ROLMSTDR':'Role Master - Report Prompt':'F4=Prompt':'');
  AddPgmMst('ROLMSTDZ':'Role Master - Filter':'F4=Prompt':'');
  AddPgmMst('ROLMSTD1':'Role Master - List':'F6=Add:F11=Show Inactive:F13=Filter':'*STD:6=Add:11=View Log');
  AddPgmMst('ROLMSTD2':'Role Master - Details':'F4=Prompt':'');
  AddPgmMst('RTVSPLB1':'Retreive SPLF attributes - CPP(RTVSPLFA)':'':'');
  AddPgmMst('RTVSPLM1':'Retreive SPLF attributes - CMD(RTVSPLFA)':'':'');
  AddPgmMst('RTVSPLP1':'Retreive SPLF attributes - Help Text':'':'');
  AddPgmMst('RTVWTRB1':'Retreive Writer Status - CPP(RTVWTRSTS)':'':'');
  AddPgmMst('RTVWTRC1':'Retreive Writer Status - Test Program':'':'');
  AddPgmMst('RTVWTRM1':'Retreive Writer Status - CMD(RTVWTRSTS)':'':'');
  AddPgmMst('SCRLOCB1':'Update SCRLOC for a Display File':'':'');
  AddPgmMst('SRJCMDB1':'Submit Restore Journal - SRJ CPP':'':'');
  AddPgmMst('SRJCMDM1':'Submit Restore Journal - SRJ Command':'':'');
  AddPgmMst('SRJCMDP1':'Submit Restore Journal - Help Text':'':'');
  AddPgmMst('SYSCSTDZ':'System Constraints - ':'F4=Prompt':'');
  AddPgmMst('SYSCSTD1':'System Constraints - ':'F13=Filter':'');
  AddPgmMst('SYSFLEDZ':'System Files - Filter':'F4=Prompt':'');
  AddPgmMst('SYSFLED1':'System Files - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSFNCDZ':'System Functions - Filter':'F4=Prompt':'');
  AddPgmMst('SYSFNCD1':'System Functions - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSIDXDZ':'System Indexes - Filter':'F4=Prompt':'');
  AddPgmMst('SYSIDXD1':'System Indexes - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSLIBDZ':'System Libraries - Filter':'F4=Prompt':'');
  AddPgmMst('SYSLIBD1':'System Libraries - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSPRCDZ':'System Procedures - Filter':'F4=Prompt':'');
  AddPgmMst('SYSPRCD1':'System Procedures - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSTRGDZ':'System Triggers - Filter':'F4=Prompt':'');
  AddPgmMst('SYSTRGD1':'System Triggers - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSVARDZ':'System Variables - Filter':'F4=Prompt':'');
  AddPgmMst('SYSVARD1':'System Variables - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('SYSVEWDZ':'System Views - Filter':'F4=Prompt':'');
  AddPgmMst('SYSVEWD1':'System Views - List':'F11=More Detail:F13=Filter':'');
  AddPgmMst('UDFDTLB0':'User Default Detail - Navigator':'':'');
  AddPgmMst('UDFDTLDZ':'User Default Detail - Filters':'':'');
  AddPgmMst('UDFDTLD1':'User Default Detail - List':'':'*STD');
  AddPgmMst('UDFDTLD2':'User Default Detail - User/Dept Selection':'':'');
  AddPgmMst('UDFDTLD3':'User Default Detail - Program Selection':'':'');
  AddPgmMst('UDFMSTB0':'User Default Master - Navigator':'':'');
  AddPgmMst('UDFMSTDZ':'User Default Master - Filters':'':'');
  AddPgmMst('UDFMSTD1':'User Default Master - List':'F6=Add:F13=Filter':'*STD');
  AddPgmMst('UDFMSTD2':'User Default Master - Details':'':'');

  AddPgmMst('USRMSTBP':'User Master Maintenance - Auto Prompt':'':'');
  AddPgmMst('USRMSTB0':'User Master Maintenance - Navigator':'':'');
  AddPgmMst('USRMSTB1':'User Master Maintenance - Update/Add FastFax':'':'');
  AddPgmMst('USRMSTB2':'User Master Maintenance - Update/Add RPT Profile':'':'');
  AddPgmMst('USRMSTB3':'User Master Maintenance - Update/Add SPYView':'':'');
  AddPgmMst('USRMSTB4':'User Master Maintenance - Rebuild file USRMST':'':'');
  AddPgmMst('USRMSTB5':'User Master Maintenance - Force Delete a User':'':'');
  AddPgmMst('USRMSTC1':'User Master Maintenance - Get User Profile details':'':'');
  AddPgmMst('USRMSTC2':'User Master Maintenance - Update User Profile':'':'');
  AddPgmMst('USRMSTC3':'User Master Maintenance - Copy User Profile':'':'');
  AddPgmMst('USRMSTC4':'User Master Maintenance - Reset Password':'':'');
  AddPgmMst('USRMSTC5':'User Master Maintenance - Disable User Profile':'':'');
  AddPgmMst('USRMSTC6':'User Master Maintenance - Enable User Profile':'':'');
  AddPgmMst('USRMSTC7':'User Master Maintenance - Delete User Profile':'':'');
  AddPgmMst('USRMSTDZ':'User Master Maintenance - Filter':'':'');
  AddPgmMst('USRMSTD1':'User Master Maintenance - List'
                      :'F8=Roles:F9=Show Disabled:F10=Refresh List:F11=Show More:F13=Filters':'*STD');
  AddPgmMst('USRMSTD2':'User Master Maintenance - Detail Screen':'':'');
  AddPgmMst('USRMSTD3':'User Master Maintenance - Detail Screen 2':'':'');
  AddPgmMst('USRMSTD4':'User Master Maintenance - Authorized Programs':'':'');
  AddPgmMst('USRMSTD6':'User Master Maintenance - Prompt for User':'':'');
  AddPgmMst('USRMSTD6':'User Master Maintenance - Module Defaults':'':'');
  AddPgmMst('USRMSTD7':'User Master Maintenance - Output Options Defaults':'':'');
  AddPgmMst('USRMSTD8':'User Master Maintenance - Create Developer Env':'':'');
  AddPgmMst('USRMSTM1':'User Master Maintenance - List Screen':'':'');
  AddPgmMst('USRMSTP1':'User Master Maintenance - List Screen':'':'');
  AddPgmMst('USRROLBR':'User Roles - Report Driver':'':'');
  AddPgmMst('USRROLB0':'User Roles - Navigator':'':'');
  AddPgmMst('USRROLB1':'User Roles - Report':'':'');
  AddPgmMst('USRROLDR':'User Roles - Report Prompt':'F4=Prompt':'');
  AddPgmMst('USRROLDZ':'User Roles - Filters':'F4=Prompt':'');
  AddPgmMst('USRROLD1':'User Roles - List':'F6=Add:F7=Import From User:F9=Compare to User:F11=Show Inactive:F13=Filter'
           :'*STD:11=Log');
  AddPgmMst('USRROLD2':'User Roles - Details':'F4=Prompt':'');
  AddPgmMst('XLPARSB1':'Excel File Parser - Demo':'':'');
  AddPgmMst('XLPARSB2':'Excel File Parser - Demo with Formulas':'':'');
  AddPgmMst('XLPARSB3':'Excel File Parser - Demo with Notify':'':'');
  AddPgmMst('XLPARSN1':'Excel File Parser - Binder Source':'':'');
  AddPgmMst('XLPARSV1':'Excel File Parser - Service Program':'':'');
  AddPgmMst('XLPARSV1PR':'Excel File Parser - Prototypes':'':'');

  // Add programs for ERPLIB stuff, seperate so this can be optional later
  AddPgmMst('COUMSTBP':'Country Code - Validation\Prompt':'':'');
  AddPgmMst('COUMSTBR':'Country Code - Report':'F4=Prompt':'');
  AddPgmMst('COUMSTB0':'Country Code - Navigator':'':'');
  AddPgmMst('COUMSTB1':'Country Code - Report':'':'');
  AddPgmMst('COUMSTB2':'Country Code - Data Seed':'F4=Prompt':'');
  AddPgmMst('COUMSTDR':'Country Code - Report Prompt':'F4=Prompt':'');
  AddPgmMst('COUMSTDZ':'Country Code - Filters':'':'');
  AddPgmMst('COUMSTD1':'Country Code - List':'F6=Add:F11=Show Inactive:F13=Filter:F21=Print':'*STD');
  AddPgmMst('COUMSTD2':'Country Code - Detail':'F4=Prompt':'');
  AddPgmMst('VNDCNYBP':'Vendor Contact Type - Validation\Prompt':'':'');
  AddPgmMst('VNDCNYB0':'Vendor Contact Type - Navigator':'':'');
  AddPgmMst('VNDCNYB1':'Vendor Contact Type - Report':'':'');
  AddPgmMst('VNDCNYDZ':'Vendor Contact Type - Filter':'F4=Prompt':'');
  AddPgmMst('VNDCNYD1':'Vendor Contact Type - List':'F6=Add:F11=Show Inactive:F13=Filter':'*STD');
  AddPgmMst('VNDCNYD2':'Vendor Contact Type - Detail':'F4=Prompt':'');
  AddPgmMst('VNDCONBP':'Vendor Contacts - Validation\Prompt':'':'');
  AddPgmMst('VNDCONBR':'Vendor Contacts - Report Driver':'':'');
  AddPgmMst('VNDCONB0':'Vendor Contacts - Navigator':'':'');
  AddPgmMst('VNDCONB1':'Vendor Contacts - Report':'':'');
  AddPgmMst('VNDCONDR':'Vendor Contacts - Report Prompt':'F4=Prompt':'');
  AddPgmMst('VNDCONDZ':'Vendor Contacts - Filter':'F4=Prompt':'');
  AddPgmMst('VNDCOND1':'Vendor Contacts - List':'F6=Add:F11=Show Inactive:F13=Filter':'*STD');
  AddPgmMst('VNDCOND2':'Vendor Contacts - Detail':'F4=Prompt':'');
  AddPgmMst('VNDNTEBP':'Vendor Notes - Validation\Prompt':'':'');
  AddPgmMst('VNDNTEBR':'Vendor Notes - Report Driver':'':'');
  AddPgmMst('VNDNTEB0':'Vendor Notes - Navigator':'':'');
  AddPgmMst('VNDNTEB1':'Vendor Notes - Report':'':'');
  AddPgmMst('VNDNTEDR':'Vendor Notes - Report Prompt':'F4=Prompt':'');
  AddPgmMst('VNDNTEDZ':'Vendor Notes - Filter':'F4=Prompt':'');
  AddPgmMst('VNDNTED1':'Vendor Notes - List':'F6=Add:F11=Show Inactive:F13=Filter':'*STD');
  AddPgmMst('VNDNTED2':'Vendor Notes - Detail':'F4=Prompt':'');


End-Proc;


Dcl-Proc AddPgmMst;
  Dcl-Pi *n;
    pgmNme char(10) const;
    des varchar(100) const;
    cmdKeys varchar(100) const;
    sflOpts varchar(100) const;
  End-Pi;
  Dcl-S pgmTyp char(1);
  Dcl-S dspFle char(10);
  Dcl-S objTyp char(10);
  Dcl-S fncKeys varchar(50) dim(24);
  Dcl-S sflOpt varchar(50) dim(99);
  Dcl-S x packed(3);

  pgmTyp = %subst(pgmNme:7:1);
  If pgmTyp = 'D';
    dspFle = %subst(pgmNme:1:6) + 'F' + %subst(pgmNme:8:3);
  Else;
    Clear dspFle;
  EndIf;

  If pgmTyp = 'C';
    objTyp = 'CLLE';
  Else;
    objTyp = 'SQLRPGLE';
  EndIf;

  // add PGMMST, skip commands and panel groups
  If not (pgmTyp in %list('M':'P'));
    Exec SQL Delete From APLLIB.PGMMST where pgmNme = :pgmNme;
    Exec SQL
      Insert into APLLIB.PGMMST
            ( pgmNme, des, apl,  objTyp, pgmTyp, dspFle)
      Values(:pgmNme,:des,'SYS',:objTyp,:pgmTyp,:dspFle);
  EndIf;

  // Add comand keys and SLF options if a display program
  If pgmTyp = 'D';
    // Default command keys
    AddPgmFnc(pgmNme:'F1=Help');
    AddPgmFnc(pgmNme:'F3=Exit');
    AddPgmFnc(pgmNme:'F5=Refresh');
    AddPgmFnc(pgmNme:'F12=Cancel');

    // passed command keys
    If cmdKeys <> '';
      fncKeys = %split(cmdKeys:':');
      For x = 1 to 24;
        If fncKeys(x) <> '';
          AddPgmFnc(pgmNme:fncKeys(x));
        EndIf;
      EndFor;
    EndIf;

    // passed SFL options
    If sflOpts <> '';
      sflOpt = %split(sflOpts:':');
      For x = 1 to 99;
        If %upper(sflOpt(x)) = '*STD';
          AddPgmOpt(pgmNme:'1=Select');
          AddPgmOpt(pgmNme:'1=Add');
          AddPgmOpt(pgmNme:'2=Update');
          AddPgmOpt(pgmNme:'3=Copy');
          AddPgmOpt(pgmNme:'4=Deactivate');
          AddPgmOpt(pgmNme:'5=View');
          AddPgmOpt(pgmNme:'13=Reactivate');
        ElseIf sflOpt(x) <> '';
          AddPgmOpt(pgmNme:sflOpt(x));
        EndIf;
      EndFor;
    EndIf;

  EndIf;

  // add text to source members and copy books
  #$CMD('CHGPFM FILE(APLLIB/QSRC) MBR('+%trim(pgmNme) + ') TEXT(''' + #$DBLQ(des) +''')');
  #$CMD('CHGPFM FILE(APLLIB/QSRC) MBR('+%trim(pgmNme) + 'PR) TEXT(''' + #$DBLQ(des) +''')':1);

  // If a display program, try to update dspfile and copy books
  If pgmTyp = 'D';
    #$CMD('CHGPFM FILE(APLLIB/QSRC) MBR('+%trim(pgmNme) + '_@) TEXT(''' + #$DBLQ(des) +''')':1);
    #$CMD('CHGPFM FILE(APLLIB/QSRC) MBR('+%trim(pgmNme) + '_2) TEXT(''' + #$DBLQ(des) +''')':1);
    #$CMD('CHGPFM FILE(APLLIB/QSRC) MBR('+%trim(dspFle) + ') TEXT(''' + #$DBLQ(des) +''')':1);
  EndIf;

End-Proc;


Dcl-Proc AddPgmFnc;
  Dcl-Pi *n;
    pgmNme char(10) const;
    des varchar(100) const;
  End-Pi;
  Dcl-S fncKey char(3);
  Dcl-S option char(2);
  Dcl-S seqNbr packed(3);

  // get function key from description, everything from before the =
  fncKey = %subst(des:1:%scan('=':des)-1);

  // Set option based on description
  If des = 'F6=Add';
    option = '2';
  Else;
    option = '';
  EndIf;

  seqNbr = %dec(%subst(fncKey:2:2):2:0);

  Exec SQL Delete From APLLIB.PGMFNC where (pgmNme,fncKey,option) = (:pgmNme,:fncKey,:option);
  Exec SQL
    Insert into APLLIB.PGMFNC
          ( pgmNme, fncKey, option, seqNbr, des)
    Values(:pgmNme,:fncKey,:option,:seqNbr,:des);

End-Proc;


Dcl-Proc AddPgmOpt;
  Dcl-Pi *n;
    pgmNme char(10) const;
    des varchar(100) const;
  End-Pi;
  Dcl-S opt char(2);
  Dcl-S option char(2);

  // get funciton key froM descriioption, everythig from befoer the =
  opt = %subst(des:1:%scan('=':des)-1);

  // Set option based on description
  If des = '1=Select' and pgmNme <> 'DCTVALDP';
    option = '1';
  ElseIf des = '1=Add'
      or des = '2=Update'
      or des = '3=Copy'
      or des = '4=Deactivate'
      or des = '13=Reactivate';
    option = '2';
  Else;
    option = '';
  EndIf;

  Exec SQL Delete From APLLIB.PGMOPT where (pgmNme,opt,option) = (:pgmNme,:opt,:option);
  Exec SQL
    Insert into APLLIB.PGMOPT
          ( pgmNme, opt, option, des)
    Values(:pgmNme,:opt,:option,:des);

End-Proc;
