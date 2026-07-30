**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// User Master Maintenance - Force Delete a User

// ***** compile as qsecofr or change the owner
// chgobjown obj(usrmstb5) objtype(*pgm) newown(qsecofr)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTC7PR // Get User Profile Values
/Copy QSRC,PRCSCRD1PR // Display processing screen
/Copy CLP474PR        // Delete library and remove RSF entries

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Globals for Parameters
Dcl-S usrPrf like(APLDCT.usrPrf);
Dcl-S bjqLib like(APLDCT.lib);
Dcl-S otq    like(APLDCT.otq);


// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTB5');
    pmrACno Like(APLLIB.acNo);
  End-Pi;
  Dcl-S bdgUsrPrf like(APLDCT.usrPrf);
  Dcl-S bdgUsrNbr packed(9);
  Dcl-S usrUid Packed(9);  // User Unique ID
  Dcl-S pmMessage Char(100);
  Dcl-S acEmpNo like(APLLIB.acEmpNo);
  Dcl-S acDept like(APLLIB.acDept);
  Dcl-S usrCls CHAR(10);
  Dcl-S usrMstIdn like(APLDCT.usrMstIdn);

  // get user profile and department for account number
  Exec SQL Select acUPrf, acDept into :usrPrf, :acDept from ACCESSPF
  where acNo = :pmrACno;
  If usrPrf = '';
    Return;
  EndIf;

  // make sure the user is a *USER class user
  Exec SQL Select usrCls into :usrCls from USRMST where usrPrf = :usrPrf;
  If usrCls <> '*USER' and usrCls <> '*PGMR' and usrCls <> '';
    Return;
  EndIf;

  // Remove from Supervisor override
  Exec SQL Select acEmpNo into :acEmpNo from ACCESSPF where acUPrf = :usrPrf;
  bdgUsrNbr = 123400000 + #$RVL(acEmpNo);
  Exec SQL Delete From SPRVOVPF Where SPRVNUM = :bdgUsrNbr;

  // Remove the badge user if it exists
  bdgUsrPrf = 'Q1234' + acEmpNo;
  USRMSTC7(bdgUsrPrf:pmMessage);

  // get Output Queue and BJQnnLIB for the user
  Exec SQL Select JDOUTQ, JDJQLB into :otq, :bjqLib from GPPJOBD where JDUSER = :usrPrf;
  If sqlState > '02';
    otq = '';
    bjqLib = '';
  Else;
    // Don't mess with the BJQnnLIB library if the library is found in
    // another user's GPPJOBD record. This can happend if the user being
    // deleted was copied but option 14 never used.  It could still have
    // the same BJQnnLIB library as the original user.
    found = *off;
    Exec SQL Select '1' into :found from GPPJOBD where JDJQLB = :bjqLib
              and JDUSER <> :usrPrf;
    If found;
      bjqLib = '';
      otq = '';
    EndIf;
  EndIf;

  // copy output queue entries to trash2, remove the output queue from FastFax monitor and delete the output queue
  MoveOutput();
  Exec SQL Delete FASTFAX/FFXOTQ where (fxoOtq, fxoLib) = (:usrPrf,'QGPL');
  #$CMD('DLTOUTQ OUTQ(QGPL/'+%trim(usrPrf)+')');

  // Clear and remove output queues on P2 and P3
  If acDept = 'MIS';
    #$CMD('DLTOUTQ OUTQ(QGPL/'+%trim(otq)+')':1);
    #$CMD('RBTHALIB/RUNCMDRSF CMD(CLROUTQ QGPL/' + usrPrf + ') SERVER(PROD2)':1);
    #$CMD('RBTHALIB/RUNCMDRSF CMD(DLTOUTQ QGPL/' + usrPrf + ') SERVER(PROD2)':1);
    #$CMD('RBTHALIB/RUNCMDRSF CMD(CLROUTQ QGPL/' + usrPrf + ') SERVER(PROD3)':1);
    #$CMD('RBTHALIB/RUNCMDRSF CMD(DLTOUTQ QGPL/' + usrPrf + ') SERVER(PROD3)':1);
    If otq <> ' ';
      #$CMD('RBTHALIB/RUNCMDRSF CMD(CLROUTQ QGPL/' + otq + ') SERVER(PROD2)':1);
      #$CMD('RBTHALIB/RUNCMDRSF CMD(DLTOUTQ QGPL/' + otq + ') SERVER(PROD2)':1);
      #$CMD('RBTHALIB/RUNCMDRSF CMD(CLROUTQ QGPL/' + otq + ') SERVER(PROD3)':1);
      #$CMD('RBTHALIB/RUNCMDRSF CMD(DLTOUTQ QGPL/' + otq + ') SERVER(PROD3)':1);
    EndIf;

    // Remove their output queue from the output queue master file.
    Exec SQL Delete OTQMST where (otqNme, otqLib) = (:usrPrf,'QGPL');
    If otq <> ' ';
      Exec SQL Delete OTQMST where (otqNme, otqLib) = (:otq,'QGPL');
    EndIf;

    // Remove their output queue from the output queue master file on PROD2 only.
    // Replication will take care of removing the record on PROD3.
    Exec SQL Delete from FABRCUT2.APLLIB.OTQMST where (otqNme, otqLib) = (:usrPrf,'QGPL');
    Exec SQL Delete from FABRCUT2.APLLIB.OTQMST where (otqNme, otqLib) = (:otq,'QGPL');

    If %subst(bjqLib:1:3) = 'BJQ';
      // Remove job queue entry on P1
      #$CMD('RMVJOBQE SBSD(QBATCH) JOBQ(' +
        %trim(bjqLib) + '/QBATCH)':1);
      // Remove job queue entry on P2 and P3
      #$CMD('RBTHALIB/RUNCMDRSF CMD(RMVJOBQE SBSD(QBATCH) JOBQ(' +
        %trim(bjqLib) + '/QBATCH)) SERVER(PROD2)':1);
      #$CMD('RBTHALIB/RUNCMDRSF CMD(RMVJOBQE SBSD(QBATCH) JOBQ(' +
        %trim(bjqLib) + '/QBATCH)) SERVER(PROD3)':1);
      // Clear job queue on P2 and P3
      #$CMD('RBTHALIB/RUNCMDRSF CMD(CLRJOBQ JOBQ(' +
        %trim(bjqLib) + '/QBATCH)) SERVER(PROD2)':1);
      #$CMD('RBTHALIB/RUNCMDRSF CMD(CLRJOBQ JOBQ(' +
        %trim(bjqLib) + '/QBATCH)) SERVER(PROD3)':1);

      // Remove the BJQnnLIB library on current and other partitions
      // This program will also remove any RSF entries as well
      CLP474(bjqLib);
    EndIf;
  EndIf;

  // Remove the user from fast fax
  usrUid = 0;
  Exec SQL Select udAfid Into :usrUid From FASTFAX/FFXUSA Where udUser = :usrPrf;
  If SQLState < '02';
    Exec SQL Delete FASTFAX/FFXUSR where uduFid = :usrUid;
    Exec SQL Delete FASTFAX/FFXUSA where udaFid = :usrUid;
    Exec SQL Delete FASTFAX/FFXUSC where udcFid = :usrUid;
  EndIf;

  // Remove from Spy View
  Exec SQL Delete RSUBSCR Where subSid = :usrPrf;

  // Remove from RPT
  Exec SQL Delete QUSRIJS/QAIJSRCP Where RCPNM = :usrPrf;

  // Remove user roles
  Exec SQL Select usrMstIdn into :usrMstIdn from USRMST where accNbr = :pmrACno;
  Exec SQL Delete from USRROL where usrMstIdn = :usrMstIdn;

  // Remove from ISMAC entry
  Exec SQL Delete from SYS249IPF where UPUSER = :usrPrf;

  // Remove from USRMST
  Exec SQL Delete from USRMST where accNbr = :pmrACno;

  // Remove from ACCESSPF
  Exec SQL Delete from ACCESSPF where acUPrf = :usrPrf;

  // Remove from GPPJOBD
  Exec SQL Delete from GPPJOBD where jdUser = :usrPrf;
  Exec SQL Delete from FABRCUT2.APLLIB2.GPPJOBD where jdUser = :usrPrf;
  Exec SQL Delete from FABRCUT3.APLLIB3.GPPJOBD where jdUser = :usrPrf;

  // Delete User Profile
  USRMSTC7(usrPrf:pmMessage);

End-Proc;


// copy output queue entries to trash2
Dcl-Proc MoveOutput;
  Dcl-Ds Dta;
    splfnam Char(10);
    job Char(28);
    splfnbr packed(6);
  End-Ds;

  // Open a cursor to a list of spool files in the from outq
  Exec SQL Declare SQlCrs Cursor For
    Select
      SPOOLED_FILE_NAME,
      JOB_NAME,
      FILE_NUMBER
    From OUTPUT_QUEUE_ENTRIES
    Where OUTPUT_QUEUE_NAME = :usrPrf;
  Exec SQL Open SQLCrs;
  Exec SQL Fetch Next From SQLCrs Into :Dta;
  DoW sqlState<'02';
    // Move the SPLF to trash2
    #$CMD ('CHGSPLFA FILE('+%trim(SPLFNAM)+') +
              JOB('+JOB+') +
              SPLNBR('+%char(SPLFNBR)+') +
              OUTQ(QGPL/TRASH2)');
    Exec SQL Fetch Next From SQLCrs Into :Dta;
  EndDo;
  Exec SQL Close SQLCrs;

End-Proc;
