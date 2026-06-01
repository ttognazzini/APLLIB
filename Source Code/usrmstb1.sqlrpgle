**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) bnddir('APLLIB');

// User Master Maintenance - Update/Add FastFax Profile

// ***** compile as qsecofr or change the owner
// chgobjown obj(usrmstb1) objtype(*pgm) newown(qsecofr)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

// globals
Dcl-S usrPrf Like(APLDCT.usrPrf);
Dcl-S cmpUid Packed(9) inz(1001); // Company Unique ID, defautls to correct one
Dcl-S dptUid Packed(9);  // Department Unique ID
Dcl-S usrUid Packed(9);  // User Unique ID

Dcl-Ds dta;
  acFNam  like(APLLIB.acFnam);
  acLNam  like(APLLIB.acLnam);
  acDept  like(APLLIB.acDept);
  acPExt  like(APLLIB.acPExt);
  acEmaiL like(APLLIB.acEmail);
  jdOutQ  like(APLLIB.jdOutQ);
  jdOQLb  like(APLLIB.jdOQLb);
End-Ds;


Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTB1');
    pmrUsrPrf Like(APLDCT.usrPrf);
  End-Pi;

  // Move Parms to globals
  usrPrf = pmrUsrPrf;

  // Get User names, dept, email, phone extension, output q, and outq library
  Clear dta;
  Exec SQL Select acFNam, acLNam, acDept, acPExt, AcEmail, Coalesce(jdOutQ,''), Coalesce(jdOQLb,'') into :dta
           from ACCESSPF
           left join GPPJOBD on jdUser = acUPrf
           where acUPrf = :usrPrf;

  // override phone extension with the main number if it is not populated
  If acPExt = 0;
    acPext = 7700;
  EndIf;

  // Get the user Department ID, create it if it is not already thier
  GetDepartment();

  // See if the user already exists in FastFax
  usrUid = 0;
  Exec SQL Select udAfid Into :usrUid From FASTFAX/FFXUSA Where udUser = :usrPrf;
  If usrUid = 0;
    AddUser();
  Else;
    UpdateUser();
  EndIf;

  // An output queue should have been setup in USRMSTC2, if it is try to add a FASTFAX monitor for it
  If #$ISOBJ(usrPrf:'*OUTQ':'QGPL');
    Exec SQL insert into FASTFAX/FFXOTQ
             ( FXOOTQ, FXOLIB, FXODSC, FXOINT, FXOCAC, FXOSDR,
               FXOPTT, FXOMIN, FXOCVR, FXOFMN, FXORSL, FXORCP,
               FXORCO,
               FXOPRT, FXOQLB, FXOBAT, FXODSD, FXOAIN,FXOEML)
       Values(:usrPrf, 'QGPL', 'FastFax email queue','USA','*NONE','QSYSOPR',
               'N',    2,      '*NONE','*NONE',1, #$C1st(:acFNam) || ' ' || #$C1st(:acLNam),
               'Comapny Name',
               'QPRINT','QGPL','N','E','USA',:acEmail);
  EndIf;

End-Proc;


// Add a new user to FastFax
Dcl-Proc AddUser;

  // get next uid
  Exec SQL Select DBCLID + 1 into :usrUid from FASTFAX/FFXDBC where DBCROT = 1;
  Exec SQL update FASTFAX/FFXDBC set DBCLID = :usrUid where DBCROT = 1;

  // Add all these files, *R is the main profile, *A reference the AS400 user, *C cross references to company and dept
  Exec SQL Insert into FASTFAX/FFXUSR
          ( UDUFID, UDUFIC, UDSLNM, UDSFNM,         UDLMNM, UDSVUS,
            UDSSIC, UDSVST, UDSVLG, UDETYP, UDSTYP,
            UDSVMV, UDSVRU, UDSRIC, UDSVRS, UDSVRE, UDSVRL, UDSVWJ,
            UDSNBK, UDSNIC, UDSABK, UDSAIC, UDSPBK, UDSPIC)
    values(:usrUid, 1, #$C1st(:acLnam), #$C1st(:acFnam), 1,     :usrUid,
            1,      'A',    10,     'A',    'N',
            'S',   :dptUid, 1,      'A',     10,    '*ALL', 'A',
           :usrUid, 1,     :usrUid, 1,     :usrUid, 1);

  Exec SQL Insert into FASTFAX/FFXUSA
          ( UDAFID, UDAFIC, UDAPFN, UDUSER, UDAMSQ, UDAMLB, UDAMGQ, UDAMGL, UDDPCA,
            UDARSL, UDAPRC, UDHPC,  UDSPC,  UDAPCV, UDAPRQ, UDAPLB, UDKLST, UDSVM,  UDSVX, UDMWRP,
            UDMFAX, UDAMEM, UDAAPI, UDAOFC, UDAQRY, UDASCR, UDASPL, UDARPR, UDWSPF, UDAECS)
    values(:usrUid, 1,      1,     :usrPrf, '*USRPRF', '', '*NONE', '', 'C:\FASTFAX',
            0,     'N',     'N',    'N',    'Y',   :jdOutQ,:jdOQLb, 'N',    4,      14,    'Y',
            'Y',   'Y',     'Y',    'N',    'N',    'N',    'N', '*USRPRF', 'Y', 'Y');

  Exec SQL Insert into FASTFAX/FFXUSC
      ( UDCFID, UDCFIC, UDCCID, UDCCIC, UDCDID, UDCDIC, UDCPFN,
        UDCLNM, UDCFNM, UDCMNM, UDCTEL,
        UDCTEX, UDCFXN, UDCATH,
        UDCEML, UDCAC,  UDOCAC, UDCCVR, UDOCVR, UDCCVM, UDOCVM)
    Values(:usrUid, 1,     :cmpUid, 1,     :dptUid, 1,      1,
        #$C1st(:acLNam), #$C1st(:acFNam), ' ', '918 392-' concat digits(:acPExt),
        ' ', '918 392-' concat digits(:acPExt), '',
        :acEmail, '*DEPT',  'Z', '*DEPT', 'Z', '*DEPT', 'Z');

  Exec SQL
    Insert into FASTFAX/FFXUSE
        (USEFID,USEFIC,USEEID,USETYP,USEPFN)
      values(:usrUid,1,1,'AS',1);

  Exec Sql
     Insert into FASTFAX/FFXUSP
         (UDPFID,UDPFIC,UDSVC,UDOSVC,UDUMSG,UDMTYP,UDSPTY,UDLPTY,
          UDHPTY,UDMXPG,UDASFU,UDANES,UDWFAS,UDRSVC,UDROSV,UDRMSG,
          UDRMTP,UDWFAR,UDAIT,UDASEF,UDAHRS,UDAPRG,UDRPO,UDAPBM,
          UDAABM,UDANBM,UDAUPM,UDACVM,UDAGRE)
    values(:usrUid,1,7,'Y','Y','E',50,50,30,999,'L'
           ,'Y','L',7,'N','N','A','L','N','N',
           'N','N','U','L','L','L','N','N','N');

  // Add some default authorizations
  Exec SQL
    Insert into FASTFAX.FFXFAL
    (FALROT,FALRID,FALRIC,FALFID,FALFIC,FALAU1,FALAU2,FALAU3,FALAU4,FALAU5,FALAU6)
    values(201,:usrUid,1,:usrUid,1,'Y','Y','Y','N','N','N'),
          (5,  :usrUid,1,:usrUid,1,'Y','Y','Y','Y','Y','N'),
          (6,  :usrUid,1,:usrUid,1,'Y','Y','Y','Y','Y','N'),
          (2,  :usrUid,1,:usrUid,1,'Y','Y','Y','Y','N','N'),
          (3,  :usrUid,1,:usrUid,1,'Y','Y','Y','Y','N','N'),
          (4,  :usrUid,1,:usrUid,1,'Y','Y','Y','Y','N','N');

End-Proc;


// Update and Existing user in FastFax
Dcl-Proc UpdateUser;

  // Update all these files, *R is the main profile, *A references the AS400 user, *C X-ref company and department
  // Only update the department, email and phone number, the rest must be done vie FFXMAIN manually
  Exec SQL Update FASTFAX/FFXUSR
    Set (udsLNm, udsFNm)
    =   (#$C1st(:acLnam),#$C1st(:acFnam))
    Where uduFID = :usrUid;

  // If not found in the FFXUSR then Add it
  If SQLSTATE >= '02';
    // Add all these files, *R is the main profile, *A reference the AS400 user, *C cross references to company and dept
    Exec SQL Insert into FASTFAX/FFXUSR
            ( UDUFID, UDUFIC, UDSLNM, UDSFNM,         UDLMNM, UDSVUS,
              UDSSIC, UDSVST, UDSVLG, UDETYP, UDSTYP,
              UDSVMV, UDSVRU, UDSRIC, UDSVRS, UDSVRE, UDSVRL, UDSVWJ,
              UDSNBK, UDSNIC, UDSABK, UDSAIC, UDSPBK, UDSPIC)
      values(:usrUid, 1, #$C1st(:acLnam), #$C1st(:acFnam), 1,     :usrUid,
              1,      'A',    10,     'A',    'N',
              'S',   :dptUid, 1,      'A',     10,    '*ALL', 'A',
             :usrUid, 1,     :usrUid, 1,     :usrUid, 1);
  EndIf;

  Exec SQL Update FASTFAX/FFXUSA
    set ( UDAPRQ, UDAPLB)
    =   (:jdOutQ,:jdOQLb)
    Where udaFID = :usrUid;

  Exec SQL Update FASTFAX/FFXUSC
    Set ( UDCLNM, UDCFNM, udcEml)
    =  (#$C1st(:acLNam),#$C1st(:acFNam),:acEmail)
    Where udcFID = :usrUid;

  // If not found in the FFXUSC then Add it
  If SQLSTATE >= '02';
    Exec SQL Insert into FASTFAX/FFXUSC
        ( UDCFID, UDCFIC, UDCCID, UDCCIC, UDCDID, UDCDIC, UDCPFN,
          UDCLNM, UDCFNM, UDCMNM, UDCTEL,
          UDCTEX, UDCFXN, UDCATH,
          UDCEML, UDCAC,  UDOCAC, UDCCVR, UDOCVR, UDCCVM, UDOCVM)
      Values(:usrUid, 1,     :cmpUid, 1,     :dptUid, 1,      1,
          #$C1st(:acLNam), #$C1st(:acFNam), ' ', '918 392-' concat digits(:acPExt),
          ' ', '918 392-' concat digits(:acPExt), '',
          :acEmail, '*DEPT',  'Z', '*DEPT', 'Z', '*DEPT', 'Z');
  EndIf;

End-Proc;

// Get the department for a user, also setups in FastFax if it does not exist
// populates the global variable depUid
Dcl-Proc GetDepartment;

  // get the department name from ACCESSPF
  If acDept = '';
    acDept = 'DEFAULT';
  ElseIf acDept = 'ACCOUNTING';
    acDept = 'INFOACCT';
  ElseIf acDept = 'CON SALES';
    acDept = 'MARKETING';
  ElseIf acDept = 'INSIDE SLS';
    acDept = 'TRENDSALES';
  ElseIf acDept = 'MIS';
    acDept = 'INFOACCT';
  ElseIf acDept = 'O/E FAB';
    acDept = 'ORDER ENTRY';
  ElseIf acDept = 'PERSONAL';
    acDept = 'INFOACCT';
  ElseIf acDept = 'PERSONNEL';
    acDept = 'INFOACCT';
  ElseIf acDept = 'SHOWROOM' and %subst(acFnam:1:1) = '*';
    acDept = 'AGENTSR';
  EndIf;

  // see if the department is setup in FASTFAX/FFXUSD, if not add it
  dptUid = 0;
  Exec SQL Select uddFid into :dptUid from FASTFAX/FFXUSD where uddNam = :acDept;
  If dptUid = 0;
    // get next uid
    Exec SQL Select DBCLID + 1 into :dptUid from FASTFAX/FFXDBC where DBCLID = 3;
    Exec SQL update FASTFAX/FFXDBC set DBCLID = :dptUid where DBCLID = 3;
    // Add department to FASTFAX
    Exec SQL Insert into FASTFAX/FFXUSD
            ( UDDFID, UDDFIC, UDDNAM, UDDCID, UDDCIC)
      Values(:dptUid, 1,     :acDept, 1001,   1);
    Exec SQL Insert into FASTFAX/FFXUSC
            ( UDCFID, UDCFIC, UDCCID, UDCCIC, UDCDID, UDCDIC, UDCPFN,
              UDCLNM, UDCFNM, UDCMNM, UDCTEL, UDCTEX, UDCFXN, UDCATH,
              UDCEML, UDCAC,  UDOCAC, UDCCVR, UDOCVR, UDCCVM, UDOCVM)
      Values(:dptUid, 1,     :cmpUid, 1,     :dptUid, 1,      1,
              ' ',    ' ',    ' ',    '918 622-7700', ' ', '833 708-0401', '',
              ucase(:acDept) || '@companyname.com', '*NONE',  'Y', 'FAB104', 'Y', 'MEMO01', 'Y');

    // Add generic user for the department
    // get next uid
    Exec SQL Select DBCLID + 1 into :usrUid from FASTFAX/FFXDBC where DBCLID = 3;
    Exec SQL update FASTFAX/FFXDBC set DBCLID = :usrUid where DBCLID = 3;
    Exec SQL Insert into FASTFAX/FFXUSR
            ( UDUFID, UDUFIC, UDSLNM, UDSFNM,         UDLMNM, UDSVUS,
              UDSSIC, UDSVST, UDSVLG, UDETYP, UDSTYP,
              UDSVMV, UDSVRU, UDSRIC, UDSVRS, UDSVRE, UDSVRL, UDSVWJ,
              UDSNBK, UDSNIC, UDSABK, UDSAIC, UDSPBK, UDSPIC)
      values(:usrUid, 1,     'Dept', #$C1st(:acFnam), 1,     :usrUid,
              1,      'A',    10,     'A',    'N',
              'S',   :dptUid, 1,      'A',     10,    '*ALL', 'A',
             :dptUid, 1,     :dptUid, 1,     :dptUid, 1);
    Exec SQL Insert into FASTFAX/FFXUSA
            ( UDAFID, UDAFIC, UDAPFN, UDUSER, UDAMSQ, UDAMLB, UDAMGQ, UDAMGL, UDDPCA,
              UDARSL, UDAPRC, UDHPC,  UDSPC,  UDAPCV, UDAPRQ, UDAPLB, UDKLST, UDSVM,  UDSVX, UDMWRP,
              UDMFAX, UDAMEM, UDAAPI, UDAOFC, UDAQRY, UDASCR, UDASPL, UDARPR, UDWSPF, UDAECS)
      values(:usrUid, 1,      1,     :acDept, '*USRPRF', '', '*NONE', '', 'C:\FASTFAX',
              ' ',   'N',     'N',    'N',    'Y',   :jdOutQ,:jdOQLb, 'N',    4,      14,    'Y',
              'Y',   'Y',     'Y',    'N',    'N',    'N',    'N', '*USRPRF', 'Y', 'Y');
    Exec SQL Insert into FASTFAX/FFXUSC
        ( UDCFID, UDCFIC, UDCCID, UDCCIC, UDCDID, UDCDIC, UDCPFN,
          UDCLNM, UDCFNM, UDCMNM, UDCTEL, UDCTEX, UDCFXN, UDCATH,
          UDCEML, UDCAC,  UDOCAC, UDCCVR, UDOCVR, UDCCVM, UDOCVM)
      Values(:usrUid, 1,     :cmpUid, 1,     :dptUid, 1,      1,
          'Dept', #$C1st(:acDept), ' ',    '918 622-7700', ' ', '833 708-0401', '',
          ucase(:acDept) || '@companyname.com', '*DEPT',  'Z', '*DEPT', 'Z', '*DEPT', 'Z');

  EndIf;

End-Proc;
