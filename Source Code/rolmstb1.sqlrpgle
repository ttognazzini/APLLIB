**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*Caller) BndDir('APLLIB') Main(Main);

// Role Master - Print List

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/copy QSRC,#$ENVNMEPR // returns the enviroments name
/COPY QSRC,OTOSRVV1PR // Output Options DS and prototypes
/Include #$INCOUTF    // creates output files in the IFS in Excel, csv, or xml format
/COPY QSRC,ROLMSTBRPR // Terms code listing - driver

Dcl-F ROLMSTO1 printer usropn OFLIND(overflow) ;
Dcl-S overflow ind;

Dcl-S pmSrtCde    like(APLDCT.srtCde);
Dcl-S pmRptTtl    like(APLDCT.rptTtl);
Dcl-S pmAcvRow    like(APLDCT.acvRow);

Dcl-S sqlStm varchar(2000);
Dcl-S Where varchar(5);

Dcl-S lngCmt like(APLDCT.lngCmt);
Dcl-S crtUsr like(APLDCT.crtUsr);
Dcl-S crtJob like(APLDCT.crtJob);
Dcl-S crtPgm like(APLDCT.crtPgm);
Dcl-S crtDtm like(APLDCT.crtDtm);
Dcl-S mntUsr like(APLDCT.mntUsr);
Dcl-S mntJob like(APLDCT.mntJob);
Dcl-S mntPgm like(APLDCT.mntPgm);
Dcl-S mntDtm like(APLDCT.mntDtm);

// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ROLMSTB1');
    pmrRolMstBrDs like(rolMstBrDs);
    pmrOtoDs char(4096);
  End-Pi;

  rolMstBrDs = pmrRolMstBrDs;
  otoDs = pmrOtoDs;

  // Move report parameters into variables so they can be used by SQL
  pmSrtCde = rolMstBrDs.srtCde;
  pmRptTtl = rolMstBrDs.rptTtl;
  pmAcvRow = rolMstBrDs.acvRow;

  // Override the print file
  OTOOVRC1(otoDs);

  Open ROLMSTO1;

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
  sqlStm = '+
    Select +
      ROLMST.rolNme, +
      lngCmt, +
      Coalesce(acv.enmDes,'''') acvDes, +
      ROLMST.crtDtm, ROLMST.crtUsr, ROLMST.crtJob, ROLMST.crtPgm, +
      ROLMST.mntDtm, ROLMST.mntUsr, ROLMST.mntJob, ROLMST.mntPgm +
    From ROLMST +
    left join DCTVAL as acv on (acv.dctNme,acv.fldNme,acv.enmVal) = (''APLDCT'',''ACVROW'',ROLMST.acvRow)';

  // Add selection criteria
  If pmAcvRow <> '';
    sqlStm += ' ' + Where + ' ROLMST.acvRow = ''' + %trim(pmAcvRow) + '''';
    Where = 'and';
  EndIf;

  // Add order by
  If pmSrtCde = 2;
    sqlStm += ' Order by rolNme';
  Else;
    sqlStm += ' Order by rolNme';
  EndIf;

  // loop through the entries and print/add each one
  Exec SQL Prepare sqlStm from :sqlStm;
  Exec SQL Declare sqlCrs Cursor For sqlStm;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs
    Into :rolNme,:lngCmt,:acvDes,:crtDtm,:crtUsr,:crtJob,:crtPgm,:mntDtm,:mntUsr,:mntJob,:mntPgm;
  DoW sqlState < '02';
    AddDetailRecord();
    Exec SQL Fetch Next From sqlCrs
      Into :rolNme,:lngCmt,:acvDes,:crtDtm,:crtUsr,:crtJob,:crtPgm,:mntDtm,:mntUsr,:mntJob,:mntPgm;
  EndDo;
  Exec SQL Close sqlCrs;

  Write #TOT;

  Close ROLMSTO1;
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
  rptLngCmt = lngCmt;
  Write #DETAIL;

  // Add detail record to output file
  #$NextRec();
  #$AddChar(rolNme);
  #$AddChar(lngCmt);
  #$AddChar(acvDes);
  If ataFmt = '1';
    #$AddChar(crtUsr);
    #$AddChar(crtJob);
    #$AddChar(crtPgm);
    #$AddChar(%char(crtDtm:*iso));
    #$AddChar(mntUsr);
    #$AddChar(mntJob);
    #$AddChar(mntPgm);
    #$AddChar(%char(mntDtm:*iso));
  EndIf;

End-Proc;



// Open output file and add headers, for Excel, CSV or XML output
Dcl-Proc AddOutfHeaders;

  // set column widths and open file.
  #$OutFWidths(01) = 30;  // Role Name
  #$OutFWidths(02) = 100;  // Description
  #$OutFWidths(03) = 12;  // Active row
  If ataFmt = '1';
    #$OutFWidths(04) = 18;  // Created User
    #$OutFWidths(05) = 28;  // Created Job
    #$OutFWidths(06) = 10;  // Created Program
    #$OutFWidths(07) = 25;  // Created Timestamp
    #$OutFWidths(08) = 18;  // Maintained User
    #$OutFWidths(09) = 28;  // Maintained Job
    #$OutFWidths(10) = 10;  // Maintained Program
    #$OutFWidths(11) = 25;  // Maintained Timestamp
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
  #$AddChar('Role':'H');
  #$AddChar('Description':'H');
  #$AddChar('Active':'H');
  If ataFmt = '1';
    #$AddChar('Created By':'H');
    #$AddChar('Created Job':'H');
    #$AddChar('Created Program':'H');
    #$AddChar('Created At':'H');
    #$AddChar('Last Updated By':'H');
    #$AddChar('Last Updated Job':'H');
    #$AddChar('Last Updated Program':'H');
    #$AddChar('Last Updated At':'H');
  EndIf;

End-Proc;
