**FREE
Ctl-Opt ActGrp(*New);
/copy APLLIB/QSRC,$ctlopt

// Analize Deleted Records in a Library - Command ANZDLT

// This was straight ripped off from
// https://www.ibm.com/support/pages/system/files/inline-files/i-db2-table-with-deleted-rows-pdf_2.pdf
// I do not claim any credit for the logic, I just put it in an easy to use program
// and made the results email as an ecel file.  -Tim Tognazzini
// Dictionary Master List

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('ANZDLTB1');
    lib char(10);
    emailTo char(50);
    reorg char(4);
  End-Pi;

  Dcl-S SQL1 varchar(5000);
  Dcl-S SQL2 varchar(5000);
  Dcl-S SQL3 varchar(5000);
  Dcl-S SQL4 varchar(5000);
  Dcl-S SQL5 varchar(5000);

  Dcl-Ds dta;
    fleLib char(10);
    fleNme char(10);
    fleMbr char(10);
  End-Ds;

  // Add APLLIB to LIBL to use the SQL command, ignore errors
  #$CMD('ADDLIBLE APLLIB *LAST':1);

  // * delete temp files in case they already exist
  Exec SQL Drop Index If Exists QTEMP.DSPFD_ATR_IX;
  Exec SQL Drop Index If Exists QTEMP.DSPFD_MBR_IX;
  #$CMD('DLTF QTEMP/ANZDLTT1':1);
  #$CMD('DLTF QTEMP/DSPFD_MBR':1);
  #$CMD('DLTF QTEMP/DSPFD_ATR':1);

  // create files of file objects
  #$cmd('DSPFD FILE('+ %trim(lib) + '/*ALL) TYPE(*MBR) OUTPUT(*OUTFILE) +
               FILEATR(*PF) OUTFILE(QTEMP/DSPFD_MBR) OUTMBR(*FIRST *ADD)');
  #$cmd('DSPFD FILE('+ %trim(lib) + '/*ALL) TYPE(*ATR) OUTPUT(*OUTFILE) +
               FILEATR(*PF) OUTFILE(QTEMP/DSPFD_ATR) OUTMBR(*FIRST *ADD)');

  // build some indexes on the new files
  Exec SQL CREATE INDEX QTEMP.DSPFD_ATR_IX ON QTEMP.DSPFD_ATR(PHFILE);
  Exec SQL CREATE INDEX QTEMP.DSPFD_MBR_IX ON QTEMP.DSPFD_MBR(MBFTYP, MBFILE, MBNDTR);

  // dump SQL plan cache to another temp file
  Exec SQL CALL QSYS2.DUMP_PLAN_CACHE('QTEMP', 'PCSS');

  // Create the table for the first tab, it is just a list of definitions
  Exec SQL Create Table QTEMP/ANZDLTT1 (seq decimal(5), txt varchar(100));
  Exec SQL Insert into QTEMP/ANZDLTT1 Values
    (001,'This file lists information about tables/files with Delete rows/records.'),
    (002,''),
    (003,'Each tab has different instructions. See below for information about'),
    (004,'what each tab is used for.'),
    (005,''),
    (006,'Tab 1 - Directions'),
    (007,'This tab provides information about how to use each other tab.'),
    (008,''),
    (009,'Tab 2 - Files'),
    (010,'This tab, provides information about each file including the number'),
    (011,'of deleted rows, the percentage of deleted rows and how room the deleted'),
    (012,'rows are taking up. This tab is used to clear up system space.'),
    (013,''),
    (014,'Tab 3 - Table Scans'),
    (015,'This tab shows the number of table scans done on files with deleted'),
    (016,'rows. Since table scans have to look through deleted rows, these are'),
    (017,'tables that are causing wasted system resources.'),
    (018,''),
    (019,'Tab 4 - Temp Index'),
    (020,'This tab shows files that have deleted records that the system is'),
    (021,'building temporary indexes over. This also waists system resources.'),
    (022,''),
    (023,'Tab 5 - High Access'),
    (024,'This tab shows information about tables with high usage that have'),
    (025,'deleted rows.'),
    (026,''),
    (027,'This was borrowed from:'),
    (029,'https://www.ibm.com/support/pages/system/files/inline-files/i-db2-table-with-deleted-rows-pdf_2.pdf'),
    (030,'Please review this site for more details. A copy of the PDF file has'),
    (031,'been saved in the APLLIB learning documents folder in case the link is'),
    (032,'not maintained in the future.');

  // build sql statements for each tab
  SQL1 = '+
    Select txt +
    From QTEMP/ANZDLTT1 +
    Order by seq';

  SQL2 = '+
    With  +
      FileStats as ( +
        Select Distinct +
          F.MBFILE fleNme, +
          F.MBNAME mbrNme, +
          MBLIB fleLib, +
          MBNRCD actRws, +
          MBNDTR dltRws, +
          PHRUSE rusDlt, +
          dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 +
                          else mbnrcd+mbndtr end) * 100,8,5) dltPct, +
          dec(Case when MBDSSZ > 0 then MBDSSZ ELSE MBDSZ2 END/1000000,10,3) fleSiz, +
          Dec(Case when MBDSSZ >0 then MBDSSZ ELSE MBDSZ2 END  +
              * dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 else mbnrcd+mbndtr end),10,3) / 1000000,10,3) +
              as dltSiz +
        FROM QTEMP.DSPFD_MBR AS F JOIN QTEMP.DSPFD_ATR AS A +
          ON F.MBFILE = A.PHFILE +
        WHERE MBFTYP = ''P'' and MBNDTR > 1 +
      ) +
    Select  +
      fleLib "Library", +
      fleNme "File", +
      mbrNme "Member", +
      actRws "Number Non-Deleted Rows", +
      dltRws "Number Deleted Rows", +
      rusDlt "Reusing Deleted Rows", +
      dltPct "Percent Deleted", +
      fleSiz "Size(MB)", +
      dltSiz "Deleted Space(MB)" +
    From FileStats +
    Where dltSiz > .01 +
    ORDER BY dltSiz DESC';

  SQL3 = '+
    With  +
      FileStats as ( +
        Select Distinct +
          F.MBFILE AS fleNme, +
          F.MBNAME as mbrNme, +
          MBLIB AS fleLib, +
          MBNRCD AS actRws, +
          MBNDTR AS dltRws, +
          PHRUSE AS rusDlt, +
          dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 +
                              else mbnrcd+mbndtr end) * 100,8,5) dltPct, +
          dec(Case when MBDSSZ > 0 then MBDSSZ ELSE MBDSZ2 END/1000000,10,3) fleSiz, +
          Dec(Case when MBDSSZ >0 then MBDSSZ ELSE MBDSZ2 END  +
              * dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 else mbnrcd+mbndtr end),10,3) / 1000000,10,3) +
              as dltSiz +
        FROM QTEMP.DSPFD_MBR AS F JOIN QTEMP.DSPFD_ATR AS A +
          ON F.MBFILE = A.PHFILE +
        WHERE MBFTYP = ''P''  +
          AND MBNDTR > 1  +
      ), +
      BigDel as ( +
        Select *  +
        From FileStats +
        Where dltSiz > .1 +
      ) +
    SELECT  +
      QQTLN "Library",  +
      QQTFN "File Name",  +
      d.rusDlt "Reusing Deleted Rows",  +
      Max(QQTOTR) "Number Non-Deleted Rows", +
      max(d.dltRws) "Number Deleted Rows" , +
      SUM(d.dltRws) "Total Deleted Rows Scanned", +
      count(*) "Total Scans" +
    From QTEMP.PCSS M  +
    Join bigdel d ON (d.fleLib,d.fleNme,d.mbrNme) = (m.qqtln,m.qqtfn,m.qqtmn) +
    Where qqrid = 3000 AND QQC11 <>''Y'' +
    Group By qqtln, qqtfn, d.rusDlt +
    ORDER BY SUM(d.dltRws) DESC +
    OPTIMIZE FOR ALL ROWS';

  sql4 = '+
    with  +
      FileStats as ( +
        Select Distinct +
          F.MBFILE AS fleNme, +
          F.MBNAME as mbrNme, +
          MBLIB AS fleLib, +
          MBNRCD AS actRws, +
          MBNDTR AS dltRws, +
          PHRUSE AS rusDlt, +
          dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 +
                              else mbnrcd+mbndtr end) * 100,8,5) dltPct, +
          dec(Case when MBDSSZ > 0 then MBDSSZ ELSE MBDSZ2 END/1000000,10,3) fleSiz, +
          Dec(Case when MBDSSZ >0 then MBDSSZ ELSE MBDSZ2 END  +
              * dec(mbndtr/(Case when mbnrcd+mbndtr=0 then 1 else mbnrcd+mbndtr end),10,3) / 1000000,10,3) +
              as dltSiz +
        FROM QTEMP.DSPFD_MBR AS F JOIN QTEMP.DSPFD_ATR AS A +
          ON F.MBFILE = A.PHFILE +
        WHERE MBFTYP = ''P''  +
          AND MBNDTR > 1 +
      ), +
      BigDel as ( +
        Select *  +
        From FileStats +
        Where dltSiz > .1 +
      ) +
    Select  +
      QQTLN "Library",  +
      QQTFN "File Name",  +
      D.rusDlt "Reusing Delweted Rows",  +
      Max(QQTOTR ) "Non-Deleted Rows", +
      max(d.dltRws) "Deleted Rows",  +
      SUM(d.dltRws) "Total Deleted Rows Scanned",  +
      SUM(M.QQRIDX) "Total index entries created", +
      QQIDXD as Index_Advised_Columns, +
      Sum(case when QQC16=''N'' then qqi6 else 0 end) as total_keys_built, +
      Sum(case when QQC16=''N'' then 1 else 0 end ) as indexCreated, +
      Sum(case when QQC16=''Y'' then 1 else 0 end ) as indexreused, +
      Count(*) as TotalIXsCreated +
    FROM QTEMP.PCSS M  +
    JOIN bigdel d ON (d.fleLib,d.fleNme,d.mbrNme) = (m.qqtln,m.qqtfn,m.qqtmn) +
    WHERE qqrid = 3002 +
    GROUP BY qqtln, qqtfn ,qqtmn, d.rusdlt, m.QQRCOD , QQIDXD +
    ORDER BY SUM(d.dltRws) DESC +
    OPTIMIZE FOR ALL ROWS';

  sql5 = '+
    SELECT  +
      system_table_schema "Library",  +
      system_table_name "File",  +
      dec(Data_size/1000000,10,3) "File Size(MB)",  +
      Number_Deleted_Rows "Deleted Rows", +
      Logical_Reads "Logical Reads",  +
      Physical_reads "Physical Reads",  +
      Sequential_reads "Sequential Reads",  +
      Random_reads "Random Reads" +
    FROM qsys2.systablestat +
    Where table_schema = ''' + %trim(lib) + ''' +
    ORDER BY Logical_reads DESC  +
    limit 500';

  // email the results as an excel file
  #$CMD('+
  SQL FILE(''' + #$DBLQ(SQL1) +''') +
      ACTION(*EMAIL) +
      EMAIL(''' + %trim(EMAILTO) + ''') +
      FILENAME(''Analyze Deleted Rows'') +
      TYPE(*XLS) +
      SHEET(''Directions'') +
      TITLE1(''Analyze Deleted Rows'') +
      TITLE2(''Library: '+ %trim(lib) + ''') +
      SUBJECT(''Analyze Deleted rows for Library ' + %trim(lib) + ' (ANZDLT)'') +
      MESSAGE(''Attached is the analysis of files with deleted rows for library ' +
              %trim(lib) + '.<br><br>View the first tab in the spreadsheet for +
              more information.'' *TEXTHTML) +
      ADDSQL( +
         (''' + #$DBLQ(SQL2) + ''' ''Files''        ''Analyze Deleted Rows'' +
           ''Library:' + %trim(lib) + ''' ''Files with delete rows.'') +
         (''' + #$DBLQ(SQL3) + ''' ''Table Scans''  ''Analyze Deleted Rows'' +
           ''Library:' + %trim(lib) + ''' ''Table Scans with Deleted Records'') +
         (''' + #$DBLQ(SQL4) + ''' ''Temp Indexes'' ''Analyze Deleted Rows'' +
           ''Library:' + %trim(lib) + ''' ''Temporary indexes with Deleted Records'') +
         (''' + #$DBLQ(SQL5) + ''' ''High Access''  ''Analyze Deleted Rows'' +
           ''Library:' + %trim(lib) + ''' ''High Access Tables w/Deleted Records'') +
      )');

  // Reorganize files with deleted records
  if reorg = '*YES';
    Exec SQL Declare crs cursor for
      Select Distinct
        MBLIB fleLib,
        MBFILE fleNme,
        MBNAME mbrNme
      FROM QTEMP.DSPFD_MBR AS F
      WHERE MBFTYP = 'P' and MBNDTR > 1;
    Exec SQL Open crs;
    Clear dta;
    Exec SQL fetch next from crs into :dta;
    Dow sqlState < '02';
      #$cmd('RGZPFM FILE(' + %trim(fleLib) + '/' + %trim(fleNme) + ') +
                   MBR(' + %trim(fleMbr) + ') +
                   RBDACCPTH(*NO) ALWCANCEL(*YES)  LOCK(*SHRUPD)':1);
      Exec SQL fetch next from crs into :dta;
    EndDo;
    Exec SQL Close crs;
  EndIf;

End-Proc;
