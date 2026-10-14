**free
Ctl-Opt Option(*SrcStmt) Main(Main) srtseq(*langidshr) DftActGrp(*No) BndDir('APLLIB') actgrp(*new);

// Purge Journal Receivers

Dcl-F PRGJRNO1 Printer oflind(overFlow) usropn ;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

Dcl-S pmrLib char(10);
Dcl-S pmrNme char(10);
Dcl-S prtOpt char(7);

Dcl-S overFlow ind;
Dcl-S sqlStm varchar(5000);
Dcl-S x packed(3);
Dcl-S where varchar(6);
Dcl-S lstLib char(10);
Dcl-S prgDte char(10);
Dcl-Ds dta;
  rcvLib char(10);
  rcvNme char(10);
  jrnLib char(10);
  jrnNme char(10);
  atcDte char(10);
  dtcDte char(10);
  savDte char(10);
  jrnSiz packed(12:2);
End-Ds;
Dcl-Ds excLib Qualified;
  count int(5);
  lib char(10) Dim(50);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('PRGJRNB1');
    pmrJrnLib  char(20);
    prgDys     packed(4);
    purge      Char(4);
    prgUnsaved Char(4);
    pmrExcLib  likeds(excLib);
    pmrPrtopt     Char(7);
  End-Pi;

  pmrNme = %upper(%subst(pmrJrnLib:1:10));
  pmrLib = %upper(%subst(pmrJrnLib:11:10));
  purge = %upper(purge);
  excLib = pmrExcLib;
  prtOpt = pmrPrtOpt;

  prgDte = %char(%date() - %days(prgDys):*iso) ;
  #$CMD('OVRPRTF PRGJRNO1 HOLD(*YES)');

  If prtOpt <> '*NOLIST';
    Open PRGJRNO1;
  EndIf;

  // Build fields for the headar record and print it
  If purge = '*YES';
    hdr2 = '';
  Else;
    hdr2 = 'Listing Only, No Journals Purged.';
  EndIf;
  pgmNme = psdsPgmNam;
  usrNme = user;
  sysNme = #$SysName();
  fltTxt1 = 'Receivers to Purge ' + %trim(pmrLib) + '/' + %trim(pmrNme) +
            ' detached over ' + %trim(%char(prgDys)) + ' days ago, before ' + %trim(prgDte) +'.';
  Clear totSiz;
  Clear totPrg;
  Clear libSiz;
  Clear libPrg;
  Clear lstLib;

  PrintHeader();

  // Build sql statement to pull all the journals past the specified date
  sqlStm = '+
    Select +
      coalesce(journal_receiver_library,'''') rcvlib, +
      coalesce(journal_receiver_name,'''') rcvnme, +
      coalesce(journal_library,'''') jrnlib, +
      coalesce(journal_name,'''') jrnnme, +
      coalesce(char(date(attach_timestamp)),'''') atcdte, +
      coalesce(char(date(detach_timestamp)),'''') dtcdte, +
      coalesce(char(date(save_timestamp)),'''') savdte, +
      Dec(coalesce(size/1000.0,0),12,2) jrnsiz +
    From QSYS2.JOURNAL_RECEIVER_INFO';

  // Exclude options base on print option
  where = ' Where';
  If prtopt = '*PURGED';
    sqlStm += Where + ' detach_timestamp < current_date - ' + %char(prgDys) + ' days';
    where = ' and';
  ElseIf prtopt = '*SAVED';
    sqlStm += Where + ' save_timestamp is not null';
    where = ' and';
  EndIf;

  // Add Jounrnal Name Selection
  If not(pmrNme in %list('*ALL':'*':''));
    sqlStm += Where + ' journal_receiver_name like ''' + %scanrpl('*':'%':%trim(pmrNme):%len(%trim(pmrNme))) + '''';
    where = ' and';
  EndIf;

  // Add library selection
  If pmrLib = '*LIBL';
    sqlStm += Where + ' journal_receiver_library in ( +
      Select schema_name From QSYS2.LIBRARY_LIST_INFO)';
    where = ' and';
  ElseIf pmrLib = '*CURLIB';
    sqlStm += Where + ' journal_receiver_library in ( +
      Select schema_name From QSYS2.LIBRARY_LIST_INFO Where type = ''CURRENT'')';
    where = ' and';
  ElseIf pmrLib = '*USRLIBL';
    sqlStm += Where + ' journal_receiver_library in ( +
      Select schema_name From QSYS2.LIBRARY_LIST_INFO Where type in (''CURRENT'',''USER''))';
    where = ' and';
  ElseIf pmrLib = '*ALLUSR';
    sqlStm += Where + ' journal_receiver_library in ( +
      select objName from table(qsys2.object_statistics(''*ALLUSR'',''*LIB'')))';
    where = ' and';
  ElseIf not (pmrLib in %list('*ALL':''));
    sqlStm += Where + ' journal_receiver_library like ''' + %scanrpl('*':'%':%trim(pmrLib):%len(%trim(pmrLib))) + '''';
    where = ' and';
  EndIf;

  // Add libraries to exclude
  For x = 1 to excLib.count;
    If excLib.lib(x) = '*LIBL';
      sqlStm += Where + ' journal_receiver_library not in ( +
        Select schema_name From QSYS2.LIBRARY_LIST_INFO)';
      where = ' and';
    ElseIf excLib.lib(x) = '*CURLIB';
      sqlStm += Where + ' journal_receiver_library not in ( +
        Select schema_name From QSYS2.LIBRARY_LIST_INFO Where type = ''CURRENT'')';
      where = ' and';
    ElseIf excLib.lib(x) = '*USRLIBL';
      sqlStm += Where + ' journal_receiver_library not in ( +
        Select schema_name From QSYS2.LIBRARY_LIST_INFO Where type in (''CURRENT'',''USER''))';
      where = ' and';
    ElseIf excLib.lib(x) = '*ALLUSR';
      sqlStm += Where + ' journal_receiver_library not in ( +
        select objName from table(qsys2.object_statistics(''*ALLUSR'',''*LIB'')))';
      where = ' and';
    ElseIf not (excLib.lib(x) in %list('*ALL':''));
      sqlStm += Where + ' journal_receiver_library not like ''' +
                  %scanrpl('*':'%':%trim(excLib.lib(x)):%len(%trim(excLib.lib(x)))) + '''';
      where = ' and';
    EndIf;
  EndFor;

  // Add order by
  sqlStm += ' Order by journal_receiver_library, detach_timestamp';

  // Loop through Journal entries, print and delete each one.
  Exec SQL Prepare sqlStm from :sqlStm;
  Exec SQL Declare sqlCrs cursor for sqlStm;
  Exec SQL Open sqlCrs;
  Clear dta;
  Exec SQL Fetch Next from sqlCrs into :dta;
  DoW sqlState < '02';
    Clear message;
    // handle library change totals
    If rcvLib <> lstLib and lstLib <> '';
      If prtOpt <> '*NOLIST';
        Write #libTotal;
      EndIf;
      Clear libSiz;
      Clear libPrg;
    EndIf;
    lstLib = rcvLib;
    If dtcDte = '';
      message = 'Active, will not purge.';
    ElseIf savDte = '' and prgUnsaved <> '*YES';
      message = 'Not Saved, will not purge.';
    Else;
      If purge = '*YES' and dtcDte < prgDte;
        Monitor;
          #$Cmd('DLTJRNRCV JRNRCV('+%trim(rcvLib) + '/' + %trim(rcvNme) + ')  DLTOPT(*IGNINQMSG)');
          totPrg += jrnSiz;
          libPrg += jrnSiz;
          message = 'Purged.';
        On-Error;
          message = 'Not Purged, see job log.';
        EndMon;
      ElseIf purge <> '*YES' and dtcDte < prgDte;
        libPrg += jrnSiz;
        totPrg += jrnSiz;
        message = 'Not Purged, Edit Only.';
      ElseIf dtcDte >= prgDte;
        message = 'Before purge days.';
      Else;
        message = 'Not Purged.';
      EndIf;
    EndIf;
    If overFlow;
      PrintHeader();
    EndIf;
    If prtOpt <> '*NOLIST';
      Write #Detail;
    EndIf;
    libSiz += jrnSiz;
    totSiz += jrnSiz;
    Exec SQL Fetch Next from sqlCrs into :dta;
  EndDo;
  Exec SQL Close sqlCrs;

  // Add last library total
  If lstLib <> '';
    If prtOpt <> '*NOLIST';
      Write #libTotal;
    EndIf;
  EndIf;

  // Add report totals
  If prtOpt <> '*NOLIST';
    Write #Total;
  EndIf;

  If prtOpt <> '*NOLIST';
    Close PRGJRNO1;
  EndIf;

End-Proc;


Dcl-Proc PrintHeader;

  If prtOpt <> '*NOLIST';

    Write #header;
    overFlow = *off;

    // Add list of libraries to exclude to the header
    excLibs = '';
    For x = 1 to excLib.count;
      If excLib.lib(x) <> ' ';
        If excLibs = '';
          excLibs = 'Excluding libraries: ' + %trim(excLib.lib(x));
        ElseIf %len(%trim(excLibs) + ', ' + %trim(excLib.lib(x))) >= 132;
          excLibs = %trim(excLibs) + ',';
          Write #excLibs;
          excLibs = %trim(excLib.lib(x));
        Else;
          excLibs = %trim(excLibs)  + ', ' + %trim(excLib.lib(x));
        EndIf;
      EndIf;
    EndFor;
    If excLibs <> '';
      Write #excLibs;
    EndIf;

    Write #headers;

  EndIf;

End-Proc;
