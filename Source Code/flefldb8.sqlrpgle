**FREE
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*caller) BndDir('APLLIB') Main(Main);

// Re-Build File from FLEFLD

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDB8PR // Always include the prototype for the current program
/Copy QSRC,FLEFLDB9PR
/Copy QSRC,FLEMSTB7PR

Dcl-Ds idxDta;
  idxLib    like(APLDCT.idxLib);
  idxNme    like(APLDCT.idxNme);
  idxUni    like(APLDCT.idxUni);
  idxTxt    like(APLDCT.idxtxt);
  idxflds   varchar(500);
  acvRow    like(APLDCT.acvRow);
  fleIdxIdn like(APLDCT.fleIdxIdn);
End-Ds;

Dcl-S fleMstIdn Like(APLDCT.fleMstIdn);
Dcl-S fleLib Like(APLDCT.fleLib);
Dcl-S fleNme Like(APLDCT.fleNme);


Exec SQL Set Option Commit = *none, UsrPrf = *owner, DynUsrPrf = *owner, DatFmt = *iso, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDB8');
    pmrFleLib Like(APLDCT.fleLib);
    pmrFleNme Like(APLDCT.fleNme);
  End-Pi;
  Dcl-S fldNme Like(APLDCT.fldNme);
  Dcl-S fleDes Like(APLDCT.fleDes);
  Dcl-S sqlStm varchar(2000);
  Dcl-S keys varchar(1000);

  fleLib = pmrFleLib;
  fleNme = pmrFleNme;

  If %parms() < 2 or fleLib = '' or fleNme = '';
    Return;
  EndIf;

  // Get the file master id number for the log entries
  Exec SQL Select fleMstIdn into :fleMstIdn from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);

  // drop the trigger program, it gets rebuilt at the end
  sqlStm = 'Drop Trigger ' + %trim(fleLib) + '.' + %trim(fleNme) + 'TRG';
  Exec SQL Execute Immediate :sqlStm;

  // loop through all fields and process each one
  // Sinces fields are inserted before an existing field, we have to do them in reverse order
  Exec SQL Declare FLEFLD Cursor For
    Select FldNme
    From FLEFLD
    Where (fleLib,fleNme) = (:fleLib,:fleNme)
    Order by fldSeq desc,fldNme;
  Exec SQL Open FLEFLD;
  Exec SQL Fetch Next From FLEFLD Into :fldNme;
  DoW sqlState < '02';
    FLEFLDB9(fleLib:fleNme:fldNme);
    Exec SQL Fetch Next From FLEFLD Into :fldNme;
  EndDo;
  Exec SQL Close FLEFLD;

  // get list of key fields
  Exec SQL Select listAgg(trim(fldnme),', ') within group(order by FLDSEQ) into :keys
           from fleFld where (fleLib,fleNme,priKey) = (:fleLib,:fleNme,'Y');

  // drop and re-add the primary key
  sqlStm = 'Alter Table ' + %trim(fleLib) + '.' + %trim(fleNme) +
            ' Drop Constraint ' + %trim(fleNme);
  Exec SQL Execute Immediate :sqlStm;
  If keys <> '';
    sqlStm = 'Alter Table ' + %trim(fleLib) + '.' + %trim(fleNme) +
              ' Add Constraint ' + %trim(fleNme) +
                ' Primary Key(' + %trim(keys) + ')';
    Exec SQL Execute Immediate :sqlStm;
  EndIf;

  // add table label
  Exec SQL Select fleDes into :fleDes from FLEMST where (fleLib,fleNme) = (:fleLib,:fleNme);
  sqlStm = 'Label on Table ' + %trim(fleLib) + '.' + %trim(fleNme) +
            ' is ''' + %trim(fleDes) + '''';
  Exec Sql Execute immediate :sqlStm;

  // create index logic here, delete and rebuild them incase any keys change
  Exec SQL Declare idxCrs cursor for
    With fields as (
      Select idxLib, idxNme,listagg(trim(idxFld),',') within group (order by idxSeq) idxFlds
      from IDXFLD
      where (fleLib,fleNme) = (:fleLib,:fleNme)
      group by idxLib, idxNme
      )
    Select
      FLEIDX.idxLib, FLEIDX.idxNme, idxUni, idxTxt, idxFlds, FLEIDX.acvRow, fleIdxIdn
    from FLEIDX
    join fields on (fields.idxLib,fields.idxNme) = (FLEIDX.idxLib,FLEIDX.idxNme)
    where (fleLib,fleNme) = (:fleLib,:fleNme);
  Exec SQL Open idxCrs;
  Exec SQL Fetch Next From idxCrs into :idxDta;
  DoW SQLState < '02';
    CreateIndex();
    Exec SQL Fetch Next From idxCrs into :idxDta;
  EndDo;
  Exec SQL Close idxCrs;

  // build trigger program' to handle creation and maintenance date... and audit logging.
  FLEMSTB7(fleLib:fleNme);

End-Proc;


// try to create index, ignores errors, so changes will not work
Dcl-Proc CreateIndex;
  Dcl-Pi *n;
  End-Pi;
  Dcl-S sqlStm varchar(300);
  Dcl-S currentFlds like(idxFlds);
  Dcl-S idxExs ind;

  // Delete index type errors, they will be re-added if this update fails
  Exec SQL Delete from FLEERR where (fleLib,fleNme,idxLib,idxNme) = (:fleLib,:fleNme,:idxLib,:idxNme)
                                and des = 'Index not created';

  // Check the index fields, if they are the same as the current fields, just skip this
  Exec SQL Select '1',listagg(trim(fldNme),',') into :idxExs,:currentFlds From Table(KEYFLDT1(:idxLib,:idxNme));

  // if the index exists and it is not active, drop it and leave
  If idxExs and acvRow <> '1';
    sqlStm = 'Drop Index ' + %trim(idxLib) + '.' + %trim(idxNme);
    Exec Sql Execute immediate :sqlStm;
    If sqlState>='02';
      AddLog('Inactive Index Drop Error'
           : 'Index ' + %trim(idxLib) + '/' + %trim(idxNme) +' drop failed.'
           : 'SQLState  . . . :   ' + sqlState +
             '&N SQLStm  . . . . :   ' + sqlStm +
             '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
             #$SQLMessageHelp(sqlCode:sqlErrMc) +
             '&N Previous key fields = ' + %trim(currentFlds) +
             '&N New key fields = ' + %trim(idxFlds));
    Else;
      AddLog('Inactive Index Drop'
           : 'Index ' + %trim(idxLib) + '/' + %trim(idxNme) +' dropped.'
           : 'Previous key fields : ' + %trim(currentFlds) +
             '&N New key fields  . . : ' + %trim(idxFlds) +
             '&N SQLStm  . . . . . . : ' + sqlStm );
    EndIf;

  EndIf;

  If currentFlds = idxFlds;
    Return;
  EndIf;

  // try to drop the index if is already exists
  sqlStm = 'Drop Index ' + %trim(idxLib) + '.' + %trim(idxNme);
  Exec Sql Execute immediate :sqlStm;

  // create index, can be regular, unique or evi
  If idxUni = 'E';
    sqlStm = 'Create Encoded Vector Index ' + %trim(idxLib) + '.' + %trim(idxNme) +
             ' on ' + %trim(fleLib) + '.' + %trim(fleNme) +
                ' (' + %trim(idxFlds) + ')' +
                ' With 255 Distinct Values';
  ElseIf idxUni = 'Y';
    sqlStm = 'Create Unique Index ' + %trim(idxLib) + '.' + %trim(idxNme) +
              ' on ' + %trim(fleLib) + '.' + %trim(fleNme) +
                 ' (' + %trim(idxFlds) + ')';
  Else;
    sqlStm = 'Create Index ' + %trim(idxLib) + '.' + %trim(idxNme) +
              ' on ' + %trim(fleLib) + '.' + %trim(fleNme) +
                 ' (' + %trim(idxFlds) + ')';
  EndIf;
  Exec Sql Execute immediate :sqlStm;
  If sqlState>='02';
    AddLog('Index Create Error'
         : 'Index ' + %trim(idxLib) + '/' + %trim(idxNme) +' creation failed.'
         : 'SQLState  . . . :   ' + sqlState +
           '&N SQLStm  . . . . :   ' + sqlStm +
           '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
           #$SQLMessageHelp(sqlCode:sqlErrMc) +
           '&N Previous key fields = ' + %trim(currentFlds) +
           '&N New key fields = ' + %trim(idxFlds));
    Exec SQL insert into FLEERR
           ( fleLib, fleNme, Des, idxLib, idxNme, fleIdxIdn,
             errMsg,
             crtDtm, crtUsr, crtJob, crtPgm,
             mntDtm, mntUsr, mntJob, mntPgm)
     values(:fleLib,:fleNme, 'Index not created', :idxLib, :idxNme, :fleIdxIdn,
             'The last creation of this index failed, view the file log for more information.',
             Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
             Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);
  Else;
    AddLog('Index Created'
         : 'Index ' + %trim(idxLib) + '/' + %trim(idxNme) +' created.'
         : 'Previous key fields : ' + %trim(currentFlds) +
           '&N New key fields  . . : ' + %trim(idxFlds) +
           '&N SQLStm  . . . . . . : ' + sqlStm );
  EndIf;

  sqlStm = 'Label on Index ' + %trim(idxLib) + '.' + %trim(idxNme) +
            ' is ''' + %trim(idxTxt) + '''';
  Exec Sql Execute immediate :sqlStm;
  If sqlState>='02';
    AddLog('Label on Index Error'
         : 'Index ' + %trim(idxLib) + '/' + %trim(idxNme) +' label failed.'
         : 'SQLState  . . . :   ' + sqlState +
           '&N SQLStm  . . . . :   ' + sqlStm +
           '&N SQLMessage  . . :   ' + #$SQLMessage(sqlCode:sqlErrMc) +
           #$SQLMessageHelp(sqlCode:sqlErrMc) +
           '&N Previous key fields = ' + %trim(currentFlds) +
           '&N New key fields = ' + %trim(idxFlds));
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
        ( FLELIB, FLENME, FLEMSTIDN, LOGTYP, LOGDES, LOGMSG,
          CRTDTM, CRTUSR, CRTJOB,CRTPGM,
          MNTDTM, MNTUSR, MNTJOB,MNTPGM)
  values( :fleLib,:fleNme,:fleMstIdn,:logTyp,:logDes,:logMsg,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam,
          Current TimeStamp, :User, :psdsJobNam, :psdsPgmNam);

End-Proc;
