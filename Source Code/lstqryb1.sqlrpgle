**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB/APLLIB') Main(Main);

// Test scanning for a string in all files in a library.

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Future parameters
Dcl-S inFle char(10) Inz('*ALL');
Dcl-S inLib char(10) Inz('MRPS38S');
Dcl-S outLib char(10) Inz('TTOGNAZZIN');
Dcl-S outFle char(10) Inz('TMP012');

Dcl-S sqlStm varchar(1000);

// Data struceture to read one entry form the file/field list into
Dcl-Ds dta;
  objLib char(10);
  objNme char(10);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit=*none, UsrPrf=*owner, datfmt=*ISO, DynUsrPrf=*owner, CloSQLCsr=*endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('LSTQRYB1');
    pmrQry Char(20);
    pmrOutF Char(20);
  End-Pi;

  // convert input paramters to globals
  inFle = %subst(pmrQry:1:10);
  inLib = %subst(pmrQry:11:10);
  outFle = %subst(pmrOutF:1:10);
  outLib = %subst(pmrOutF:11:10);

  // get a list of all query deffinitions to a temp file
  #$CMD('DSPOBJD OBJ('+%trim(inLib)+'/'+%trim(inFle)+') OBJTYPE(*QRYDFN) OUTPUT(*OUTFILE) OUTFILE(QTEMP/TMP012A)');

  // Create a temp file to store the results in
  sqlStm = 'Drop table '+%trim(outLib)+'.'+%trim(outFle);
  Exec SQL Execute immediate :sqlStm;
  sqlStm = '+
    Create or Replace table '+%trim(outLib)+'.'+%trim(outFle)+' ( +
      objLib     char(10), +
      objNme     char(10), +
      qryTxt     char(50), +
      prtCvrPag  char(4), +
      cvrPagTtl1 char(60), +
      cvrPagTtl2 char(60), +
      cvrPagTtl3 char(60), +
      cvrPagTtl4 char(60) +
    )';
  Exec SQL Execute immediate :sqlStm;

  // hold the splf make sure it does not print anywhere
  #$CMD('OVRPRTF QPQUPRFIL HOLD(*YES) OVRSCOPE(*JOB)');

  Exec SQL Declare sqlCrs Cursor for
    Select ODLBNM, ODOBNM
    From QTEMP.TMP012A;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs into :dta;
  DoW sqlstate < '02';
    ProcessQRYDFN();
    Exec SQL Fetch Next From sqlCrs into :dta;
  EndDo;
  Exec SQL Open sqlCrs;

  // Delte the veride on the splf
  #$CMD('DLTOVR FILE(QPQUPRFIL) LVL(*JOB)');

End-Proc;


// Search for the search string in one field in one file
Dcl-Proc ProcessQRYDFN;
  Dcl-S line   char(350);
  Dcl-Ds qryDfnA;
    qryTxt      char(50);
    inCvrPagTtl Ind;
    prtCvrPag   char(4);
    cvrPagTtl1  char(60);
    cvrPagTtl2  char(60);
    cvrPagTtl3  char(60);
    cvrPagTtl4  char(60);
  End-Ds;

  // Print Query details to a SPLF
  Exec SQL call QSYS2.Print_Query_Definition (:objLib, :objNme, 0);

  // Copy the splft o PF
  #$CMD('DLTF QTEMP/TMP012B':1);
  #$CMD('CRTPF FILE(QTEMP/TMP012B) RCDLEN(350)');
  #$CMD('CPYSPLF FILE(QPQUPRFIL) TOFILE(QTEMP/TMP012B) SPLNBR(*LAST)');

  // loop through the file an parse otu required data
  Clear qryDfnA;
  Exec SQL Declare sqlCrs2 Cursor for
    Select tmp012B
    From QTEMP.TMP012B
    Order by RRN(TMP012B);
  Exec SQL Open sqlCrs2;
  Exec SQL Fetch Next From sqlCrs2 Into :line;
  DoW sqlState < '02';
    If %subst(line:1:42) = '   Query text  . . . . . . . . . . . . . .';
      qryTxt = %subst(line:44:50);
    EndIf;
    If %subst(line:1:42) = '   Print cover page  . . . . . . . . . . .';
      prtCvrPag = %subst(line:44:4);
    EndIf;
    If line = '     Cover page title';
      inCvrPagTtl = *on;
    ElseIf inCvrPagTtl and %subst(line:1:7) <> '';
      inCvrPagTtl = *off;
    ElseIf inCvrPagTtl;
      If cvrPagTtl1 = '';
        cvrpagTtl1 = %subst(line:8:60);
      ElseIf cvrPagTtl2 = '';
        cvrpagTtl2 = %subst(line:8:60);
      ElseIf cvrPagTtl3 = '';
        cvrpagTtl3 = %subst(line:8:60);
      ElseIf cvrPagTtl4 = '';
        cvrpagTtl4 = %subst(line:8:60);
      EndIf;
    EndIf;
    Exec SQL Fetch Next From sqlCrs2 Into :line;
  EndDo;
  Exec SQL Close sqlCrs2;

  // add the record to the output file
  sqlStm = '+
    Insert Into '+%trim(outLib)+'.'+%trim(outFle)+' +
      ( objLib , objNme, +
        qryTxt, prtCvrPag, +
        cvrPagTtl1, cvrPagTtl2, +
        cvrPagTtl3, cvrPagTtl4) +
      Values('''+%trim(objLib)+''','''+%trim(objNme)+''',+
             '''+%trim(qryTxt)+''','''+%trim(prtCvrPag)+''', +
             '''+%trim(cvrPagTtl1)+''','''+%trim(cvrPagTtl2)+''', +
             '''+%trim(cvrPagTtl3)+''','''+%trim(cvrPagTtl4)+''')';
  Exec SQL Execute immediate :sqlStm;

  #$CMD('DLTSPLF FILE(QPQUPRFIL) SPLNBR(*LAST)');

End-Proc;
