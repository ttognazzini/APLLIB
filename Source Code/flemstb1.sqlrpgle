**Free
Ctl-Opt debug Option(*SrcStmt:*NoDebugIO) DftActGrp(*No) ActGrp(*Caller) Main(Main);

// File Master - Hard Delete

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR   // prototypes for $ procedures used for template programs
/Copy QSRC,FLEMSTB1PR
/Copy QSRC,PMPWDWD1PR

// globals for parameters
Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEMSTB1');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
    pmrKeyPressed  Like(keyPressed);
  End-Pi;
  Dcl-S answer Char(1);

  fleLib = pmrFleLib;
  fleNme = pmrFleNme;

  // Provide warning prompt, they must enter a Y to continue
  PMPWDWD1('Warning you are about to delete file ' + %trim(fleLib) + '/' + %trim(fleNme) +
          ' from the system and file master system. The object and all of it''s indexes will be deleted, +
            and all information will be removed from the file master system. This cannot be +
            undone, any data in the file will be lost. Are you sure you want to continue?'
           : answer : 'YN' : 'Y=Yes, N=No' : pmrKeyPressed);
  If answer = 'Y' and pmrKeyPressed = 'ENTER';
    DeleteFile();
  Else;
    pmrKeyPressed = 'F12';
  EndIf;

End-Proc;


// Delete file and remove from the file master system
Dcl-Proc DeleteFile;
  Dcl-Ds dta;
    idxLib like(APLDCT.idxLib);
    idxNme like(APLDCT.idxNme);
  End-Ds;
  Dcl-S sqlStm Varchar(200);

  // Loop through all indexes and delete them
  Exec SQL Declare idxCrs Cursor For
    Select idxLib, idxNme
    From FLEIDX
    Where (fleLib,fleNme) = (:fleLib,:fleNme);
  Exec SQL Open idxCrs;
  Exec SQL Fetch Next From idxCrs Into :dta;
  DoW sqlState < '02';
    sqlStm = 'Drop Index ' + %trim(idxLib) + '.' + %trim(idxNme);
    Exec SQL Execute Immediate :sqlStm;
    Exec SQL Fetch Next From idxCrs Into :dta;
  EndDo;
  Exec SQL Close idxCrs;

  // Delete the physical file
  sqlStm = 'Drop Table ' + %trim(fleLib) + '.' + %trim(fleNme);
  Exec SQL Execute Immediate :sqlStm;

  // Remove from the file master system
  Exec SQL Delete From FLEMST Where (fleLib,flenme) = (:fleLib,:fleNme);
  Exec SQL Delete From FLEFLD Where (fleLib,flenme) = (:fleLib,:fleNme);
  Exec SQL Delete From FLEIDX Where (fleLib,flenme) = (:fleLib,:fleNme);
  Exec SQL Delete From IDXFLD Where (fleLib,flenme) = (:fleLib,:fleNme);
  Exec SQL Delete From FLELOG Where (fleLib,flenme) = (:fleLib,:fleNme);
  Exec SQL Delete From FLENTE Where (fleLib,flenme) = (:fleLib,:fleNme);

End-Proc;
