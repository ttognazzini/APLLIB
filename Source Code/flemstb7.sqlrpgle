**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Create trigger program for each file
//
// The trigger program updates the Crtxx and mntXxx filed automatically. It also logs any fields
// with auditing turned on.

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

Dcl-S sqlStm varchar(32000);
Dcl-S or varchar(2);
Dcl-S fleLib like(APLDCT.fleLib);
Dcl-S fleNme like(APLDCT.fleNme);
Dcl-S fleMstIdn like(APLDCT.fleMstIdn);
Dcl-S idnFldNmeSql like(APLDCT.fldNmeSql);
Dcl-S fldTyp like(APLDCT.fldTyp);
Dcl-S fldNme like(APLDCT.fldNme);
Dcl-S fldNmeSql like(APLDCT.fldNmeSql);
Dcl-S fleFldIdn like(APLDCT.fleFldIdn);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;


Dcl-Proc Main;
  Dcl-Pi *n extPgm('FLEMSTB7');
    pmrFleLib like(APLDCT.fleLib);
    pmrFleNme like(APLDCT.fleNme);
  End-Pi;
  fleLib = pmrFleLib;
  fleNme = pmrFleNme;

  // get flemstidn
  Exec SQL select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // get the long field name of the files identity column
  Exec SQL select fldNmeSQL into :idnFldNmeSql
           from FLEMST
           join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
           join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
           where (FLEMST.fleLib,FLEFLD.fleNme,FLEFLD.fldLvl) = (:fleLib,:fleNme,2);

  sqlStm = 'Create or Replace Trigger ' + %trim(fleLib) + '.' + %trim(fleNme) + 'TRG +
            before Insert or Update on ' + %trim(fleLib) + '.' + %trim(fleNme) + ' +
            Referencing new row as n old row as o +
            for each row mode db2row +
            Begin +
              If Inserting Then +
                set n.creation_time_stamp = current timestamp, +
                    n.creation_user = user, +
                    n.creation_job = job_name, +
                    n.creation_program = APLLIB.current_program(); +
              End If ; +
              If inserting or +
                 (updating and (';

  // add each level 4 field that is flagged for user update
  Exec SQL Declare crs1 cursor for
    Select fldNmeSql, fldtyp
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme) = (:fleLib,:fleNme)
      and FLEFLD.fldLvl in (1,2,3,4)
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs1;
  Exec SQL fetch next from crs1 into :fldNmeSql,:fldTyp;
  or = '';
  DoW SQLState < '02';
    If fldTyp = 'XML';
      sqlStm += ' ' + or + ' hash(n.' + %trim(fldNmeSql) + ') <> hash(o.' + %trim(fldNmeSql) + ')';
    Else;
      sqlStm += ' ' + or + ' n.' + %trim(fldNmeSql) + ' <> o.' + %trim(fldNmeSql);
    EndIf;
    or = 'or';
    Exec SQL fetch next from crs1 into :fldNmeSql,:fldTyp;
  EndDo;
  Exec SQL Close crs1;

  sqlStm += ')) Then +
              set n.maintenance_time_stamp = current timestamp, +
                  n.maintenance_user = user, +
                  n.maintenance_job = job_name, +
                  n.maintenance_program = APLLIB.current_program(); +
            End If;';

  // add all audited fields
  Exec SQL Declare crs2 cursor for
    Select FLEFLD.fldNme,fldNmeSql, fleFldIdn
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme,audFld) = (:fleLib,:fleNme,'1')
      and fldtyp not in ('XML','DATALINK','GRAPHIC','VARGRAPHIC','DBCLOB')
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs2;
  Exec SQL fetch next from crs2 into :fldNme,:fldNmeSql,:fleFldIdn;
  DoW SQLState < '02';
    sqlStm += ' If o.' + %trim(fldNmeSql) +' <>  n.' +%trim(fldNmeSql) + ' Then +
                Insert into APLLIB.AUDLOG +
                  (fleLib, fleNme, fleMstIdn, +
                   rcdIdn, fldNme, fleFldIdn, +
                   bfrVal, aftVal) +
           Values('''+%trim(fleLib)+''','''+%trim(fleNme)+''', ' +%char(fleMstIdn) + ', +
                  n.'+%trim(idnFldNmeSql) + ','''+%trim(fldNme)+''','+%char(fleFldIdn) +', +
                  o.'+%trim(fldNmeSql) + ', n.'+%trim(fldNmeSql)+'); +
             End If;';
    Exec SQL fetch next from crs2 into :fldNme,:fldNmeSql,:fleFldIdn;
  EndDo;
  Exec SQL Close crs2;

  // Trim all varchar fields in case someone messes them up
  Exec SQL Declare crs3 cursor for
    Select fldNmeSql
    from fleMst
    join flefld on FLEFLD.fleMstIdn = FLEMST.fleMstIdn
    join DCTFLD on (DCTFLD.dctNme,DCTFLD.fldNme) = (FLEMST.dctNme,FLEFLD.fldNme)
    where (FLEMST.fleLib,FLEFLD.fleNme,fldTyp) = (:fleLib,:fleNme,'VARCHAR')
      and FLEFLD.acvRow = '1';
  Exec SQL Open crs3;
  Exec SQL fetch next from crs3 into :fldNmeSql;
  DoW SQLState < '02';
    sqlStm += ' set n.' + %trim(fldNmeSql) + ' = trim(n.' + %trim(fldNmeSql) + ');';
    Exec SQL fetch next from crs3 into :fldNmeSql;
  EndDo;
  Exec SQL Close crs3;

  // finish out statement
  sqlStm += ' End';

  Exec SQL execute immediate :sqlStm;
  If SQLState <> '00000';
    AddLog('Trigger Error':'Trigger ' +%trim(fleLib) + '.'+ %trim(fleNme) +'TRG creation failed.':
         'SQLState  . . . :   ' + sqlState +
         '&N SQLStm  . . . . :   ' + sqlStm +
         '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
         #$SQLMessageHelp(sqlCode:sqlErrMc));
  Else;
    AddLog('Trigger Created':'Trigger ' +%trim(fleLib) + '.'+ %trim(fleNme) +'TRG created/replaced.':
         'SQLStm  . . . . :   ' + sqlStm);
  EndIf;

End-Proc;


// Add log entry
Dcl-Proc AddLog;
  Dcl-Pi *n;
    logTyp Like(APLDCT.logTyp) const;
    logDes Like(APLDCT.logDes) const;
    logMsg Like(APLDCT.logMsg) const;
  End-Pi;

  Exec SQL Insert Into FLELOG
        ( FLELIB, FLENME, FLEMSTIDN, LOGTYP, LOGDES, LOGMSG)
  values(:fleLib,:fleNme,:fleMstIdn,:logTyp,:logDes,:logMsg);

End-Proc;
