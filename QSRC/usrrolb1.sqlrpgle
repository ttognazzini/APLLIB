**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*Caller) BndDir('APLLIB') Main(Main);

// Role Master - Print List

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/copy QSRC,#$ENVNMEPR // returns the enviroments name
/COPY QSRC,OTOSRVV1PR // Output Options DS and prototypes
/Include #$INCOUTF    // creates output files in the IFS in Excel, csv, or xml format
/COPY QSRC,USRROLBRPR // Terms code listing - driver

Dcl-F USRROLO1 printer usropn OFLIND(overflow) ;
Dcl-S overflow ind;

Dcl-S pmSrtCde    like(APLDCT.srtCde);
Dcl-S pmRptTtl    like(APLDCT.rptTtl);
Dcl-S pmUsrNme    like(APLDCT.usrNme);
Dcl-S pmRolNme    like(APLDCT.rolNme);
Dcl-S pmAcvRow    like(APLDCT.acvRow);

Dcl-S sqlStm varchar(3000);
Dcl-S Where varchar(5);

Dcl-Ds dta;
  acvRow like(APLDCT.acvRow);
  usrRolIdn like(APLDCT.usrRolIdn);
  rolMstIdn like(APLDCT.rolMstIdn);
  rolNme like(APLDCT.rolNme);
  usrMstIdn like(APLDCT.usrMstIdn);
  usrPrf like(APLDCT.usrPrf);
  usrNme like(APLDCT.usrNme);
  lngCmt like(APLDCT.lngCmt);
  emlAdr like(APLDCT.emlAdd);
  usrDpt like(APLDCT.acDept);
  usrJob like(APLDCT.acJobD);
  aprDes char(3);
  acvDes like(APLDCT.acvDes);
  rolAprIdn like(APLDCT.rolAprIdn);
  aprDtm like(APLDCT.crtDtm);
  aprUsr like(APLDCT.crtUsr);
  aprJob like(APLDCT.crtJob);
  aprPgm like(APLDCT.crtPgm);
  crtDtm like(APLDCT.crtDtm);
  crtUsr like(APLDCT.crtUsr);
  crtJob like(APLDCT.crtJob);
  crtPgm like(APLDCT.crtPgm);
  mntDtm like(APLDCT.mntDtm);
  mntUsr like(APLDCT.mntUsr);
  mntJob like(APLDCT.mntJob);
  mntPgm like(APLDCT.mntPgm);
End-Ds;

// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRROLB1');
    pmrUsrRolBrDs like(usrRolBrDs);
    pmrOtoDs char(4096);
  End-Pi;

  usrRolBrDs = pmrUsrRolBrDs;
  otoDs = pmrOtoDs;

  // Move report parameters into variables so they can be used by SQL
  pmSrtCde = usrRolBrDs.srtCde;
  pmRptTtl = usrRolBrDs.rptTtl;
  pmUsrNme = usrRolBrDs.usrNme;
  pmRolNme = usrRolBrDs.rolNme;
  pmAcvRow = usrRolBrDs.acvRow;

  // Override the print file
  OTOOVRC1(otoDs);

  Open USRROLO1;

  // Get some report header values
  #date = %dec(%date():*ISO);
  #time = %dec(%time():*HMS);
  prtUser = user;
  prtTitle = #$CNTR(pmRptTtl:50);
  environmnt = #$CNTR(#$envNme():50);

  Write #PAGEHDR;
  AddOutfHeaders();

  // build sql statement based on selection and sort criteria
  Where = 'Where';
  sqlStm = 'Select * from USRROLB1VW';

  // Add selection criteria
  If pmAcvRow <> '';
    sqlStm += ' ' + Where + ' acvRow = ''' + %trim(pmAcvRow) + '''';
    Where = 'and';
  EndIf;
  If pmUsrNme <> '';
    sqlStm += ' ' + Where + ' usrNme = ''' + %trim(pmUsrNme) + '''';
    Where = 'and';
  EndIf;
  If pmRolNme <> '';
    sqlStm += ' ' + Where + ' rolNme = ''' + %trim(pmRolNme) + '''';
    Where = 'and';
  EndIf;

  // Add order by
  If pmSrtCde = 2;
    sqlStm += ' Order by rolNme, usrNme';
  Else;
    sqlStm += ' Order by usrNme, rolNme';
  EndIf;

  // loop through the entries and print/add each one
  Clear dta;
  Exec SQL Prepare sqlStm from :sqlStm;
  Exec SQL Declare sqlCrs Cursor For sqlStm;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs Into :dta;
  DoW sqlState < '02';
    AddDetailRecord();
    Exec SQL Fetch Next From sqlCrs Into :dta;
  EndDo;
  Exec SQL Close sqlCrs;

  Write #TOT;

  Close USRROLO1;
  #$CloseOut();

  // Apply the output options to the spool file
  OTOPRCC1(otoDs);

End-Proc;



// Add a detail line to the report and output file
Dcl-Proc AddDetailRecord;

  // Handle printed overflow
  If overflow;
    Write #PAGEHDR;
    overflow = *off;
  EndIf;

  // Write detail record to printed report
  rptUsrNme = usrNme;
  rptRolNme = rolNme;
  rptAprDes = aprDes;
  rptAcvDes = acvDes;
  rptLngCmt = lngCmt;
  Write #DETAIL;

  // Add detail record to output file
  #$NextRec();
  If ataFmt = '2';
    #$AddChar(rolNme);
    #$AddChar(usrPrf);
    #$AddChar(usrNme);
    #$AddChar(lngCmt);
    #$AddChar(emlAdr);
    #$AddChar(usrDpt);
    #$AddChar(usrJob);
    #$AddChar(aprDes);
    #$AddChar(acvDes);
    #$AddChar(%char(aprDtm:*iso));
    #$AddChar(aprUsr);
  Else;
    #$AddNum0(usrRolIdn);
    #$AddNum0(rolMstIdn);
    #$AddChar(rolNme);
    #$AddNum0(usrMstIdn);
    #$AddChar(usrPrf);
    #$AddChar(usrNme);
    #$AddChar(lngCmt);
    #$AddChar(emlAdr);
    #$AddChar(usrDpt);
    #$AddChar(usrJob);
    #$AddChar(aprDes);
    #$AddChar(acvDes);
    #$AddNum0(rolAprIdn);
    #$AddChar(%char(aprDtm:*iso));
    #$AddChar(aprUsr);
    #$AddChar(aprJob);
    #$AddChar(aprPgm);
    #$AddChar(%char(crtDtm:*iso));
    #$AddChar(crtUsr);
    #$AddChar(crtJob);
    #$AddChar(crtPgm);
    #$AddChar(%char(mntDtm:*iso));
    #$AddChar(mntUsr);
    #$AddChar(mntJob);
    #$AddChar(mntPgm);
  EndIf;

End-Proc;



// Open output file and add headers, for Excel, CSV or XML output
Dcl-Proc AddOutfHeaders;

  // set column widths and open file.
  If ataFmt = '2';
    #$OutFWidths(01) = 30; // Role Name
    #$OutFWidths(02) = 12; // User Profile
    #$OutFWidths(03) = 30; // User Name
    #$OutFWidths(04) = 50; // Role Description
    #$OutFWidths(05) = 50; // User Email
    #$OutFWidths(06) = 14; // User Department
    #$OutFWidths(07) = 10; // User Job
    #$OutFWidths(08) = 12; // Role Approved
    #$OutFWidths(09) = 10; // Active
    #$OutFWidths(10) = 25; // Approval Time Stamp
    #$OutFWidths(11) = 12; // Approval User
  Else;
    #$OutFWidths(01) = 10; // User Roles Id
    #$OutFWidths(02) = 10; // Role master file Id
    #$OutFWidths(03) = 30; // Role Name
    #$OutFWidths(04) = 10; // User Master Id
    #$OutFWidths(05) = 12; // User Profile
    #$OutFWidths(06) = 30; // User Name
    #$OutFWidths(07) = 50; // Role Description
    #$OutFWidths(08) = 50; // User Email
    #$OutFWidths(09) = 14; // User Department
    #$OutFWidths(10) = 10; // User Job
    #$OutFWidths(11) = 12; // Role Approved
    #$OutFWidths(12) = 10; // Active
    #$OutFWidths(13) = 10; // Aprroval ID
    #$OutFWidths(14) = 25; // Approval Time Stamp
    #$OutFWidths(15) = 12; // Approval User
    #$OutFWidths(16) = 28; // Approval Job
    #$OutFWidths(17) = 10; // Approval Program
    #$OutFWidths(18) = 25; // Creation Time Stamp
    #$OutFWidths(19) = 12; // Creation User
    #$OutFWidths(20) = 28; // Creation Job
    #$OutFWidths(21) = 10; // Creation Program
    #$OutFWidths(22) = 25; // Maintenance Time Stamp
    #$OutFWidths(23) = 12; // Maintenance User
    #$OutFWidths(24) = 28; // Maintenance Job
    #$OutFWidths(25) = 10; // Maintenance Program
  EndIf;
  #$OpenOut(#$CrtPath(ataNme):ataTyp:#$OutFWidths);

  // add header record 1
  #$AddChar(environmnt:'C');
  #$AddChar('');
  #$AddChar('');
  #$AddChar(psDsPgmNam);
  #$AddDate(#date);
  #$AddChar(%editw(#TIME:' 0:  :  '));
  // add header record 2
  #$NextRec();
  #$AddChar(pmRptTtl:'T');

  // skip a line
  #$NextRec();
  // add column header
  #$NextRec();
  If ataFmt = '2';
    #$AddChar('Role Name':'H');
    #$AddChar('User Profile':'H');
    #$AddChar('User Name':'H');
    #$AddChar('Role Description':'H');
    #$AddChar('User Email':'H');
    #$AddChar('User Department':'H');
    #$AddChar('User Job':'H');
    #$AddChar('Role Approved':'H');
    #$AddChar('Active':'H');
    #$AddChar('Approval Time Stamp':'H');
    #$AddChar('Approval User':'H');
  Else;
    #$AddChar('User Roles Id':'HR');
    #$AddChar('Role master file Id':'HR');
    #$AddChar('Role Name':'H');
    #$AddChar('User Master Id':'HR');
    #$AddChar('User Profile':'H');
    #$AddChar('User Name':'H');
    #$AddChar('Role Description':'H');
    #$AddChar('User Email':'H');
    #$AddChar('User Department':'H');
    #$AddChar('User Job':'H');
    #$AddChar('Role Approved':'H');
    #$AddChar('Active':'H');
    #$AddChar('Aprroval ID':'H');
    #$AddChar('Approval Time Stamp':'H');
    #$AddChar('Approval User':'H');
    #$AddChar('Approval Job':'H');
    #$AddChar('Approval Program':'H');
    #$AddChar('Creation Time Stamp':'H');
    #$AddChar('Creation User':'H');
    #$AddChar('Creation Job':'H');
    #$AddChar('Creation Program':'H');
    #$AddChar('Maintenance Time Stamp':'H');
    #$AddChar('Maintenance User':'H');
    #$AddChar('Maintenance Job':'H');
    #$AddChar('Maintenance Program':'H');

  EndIf;

End-Proc;
