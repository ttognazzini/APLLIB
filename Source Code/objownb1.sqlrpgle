**Free
Ctl-Opt Option(*SrcStmt) Main(Main) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB');

// Email list of objects not owned by QPGMR or QSECOFR

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-S sqlStm varchar(2000);
Dcl-S temp varchar(2000);
Dcl-S found ind;

Dcl-Proc Main;

  // build and add objects to a temporary table
  #$CMD('DLTF QTEMP/OBJOWN':1);
  #$CMD('DSPOBJD OBJ(OEILIB/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(ARRLIB/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(APPLIB/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(NVTLIB/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(APLLIB/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(FABLIBR/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');
  #$CMD('DSPOBJD OBJ(FABDWH/*ALL) OBJTYPE(*ALL) OUTPUT(*OUTFILE) OUTFILE(QTEMP/OBJOWN) OUTMBR(*FIRST *ADD)');

  sqlStm = 'SELECT +
              ODLBNM AS "Library", +
              ODOBNM AS "Object", +
              ODOBTP AS "Object_type", +
              ODOBAT AS "Object_attribute", +
              ODOBTX AS "Text_description", +
              ODOBOW AS "Object_owner" +
            FROM OBJOWN +
            where ODOBOW not in (''QPGMR'',''QSECOFR'',''QSYSOPR'', +
                                ''SMAC1'',''EDIUSER'') +
              and ODOBTP not in ( ''*DTAARA'',''*DTAQ'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF1'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF2'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF3'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF4'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF5'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF6'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF7'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF8'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF9'') +
              and (odLbNm <> ''FABLIBR'' or left(odObNm,3) <> ''FF0'')';

  // see if any errors exist, only email if there are some
  Clear found;
  Exec SQL Prepare sqlStm from :sqlStm;
  Exec SQL Declare sqlCrs cursor for sqlStm;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch next from sqlCrs into :temp;
  If sqlState <> '02000';
    found = *on;
  EndIf;

  // Email any objects that are not owned by QPGM or QSECOFR
  If found;
    #$CMD('+
        SQL '''+ #$DBLQ(sqlStm) + ''' +
        ACTION(*EMAIL) +
        EMAIL(*RPTDSTID) +
        RPTDSTID(OBJOWNB1) +
        FILENAME(''Object Owners'') +
        SHEET(OBJOWNB1) +
        TITLE1(''Object Owner Errors'') +
        SUBJECT(''Object Owner Errors (OBJOWNB1)'') +
        MESSAGE(''Attached is a list of objects that are owned by the wrong users.<br><br>+
                  The list excludes users QPGMR, QSYSOPR, QSECOFR, SMAC1, and EDIUSER.<br><br>+
                  The second tab includes all objects for all owners in case that information needs +
                  to be reviewed.<br><br>+
                  <small>You are receiving this list becasue your user id is in RPT entry OBJOWNB1. +
                  If you no longer want to receive this list please submit a help ticket asking to have +
                  your user id removed from RPT entry OBJOWNB1. If someone else needs to receive this +
                  email, please submit a help ticket requesting to have thier user id added to RPT entry +
                  OBJOWNB1.</small>'' *TEXTHTML) +
        ADDSQL((''SELECT +
                    ODLBNM AS "Library", +
                    ODOBNM AS "Object", +
                    ODOBTP AS "Object_type", +
                    ODOBAT AS "Object_attribute", +
                    ODOBTX AS "Text_description", +
                    ODOBOW AS "Object_owner" +
                  FROM OBJOWN'' +
              ALL_OBJECTS +
              ''All Objects''))');
  EndIf;

End-Proc;
