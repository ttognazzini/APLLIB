**Free
Ctl-Opt DftActGrp(*NO) BndDir('APLLIB/APLLIB':'#$XLSX1.0/#$XLSX') option(*SrcStmt) Main(Main)
        ActGrp(*New);

// Sync Test Library - SYNCTEST Command

// Warning, the program has to use both SYSTABLES and SYSFILES because LF38
// and PF38 objects only show up in SYSFILES, while SQL tables only show up in
// SYSTABLES. However standard LF's and PF's show up in both tables. The CTE's
// pull both data sets, then group them together so there are no duplicates.

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy APLLIB/QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Include #$XLSX1.0/QRPGLESRC,#$XLSX_H

// globals for input parameters
Dcl-S prdLib char(10);
Dcl-S tstLib char(10);
Dcl-S refresh char(4);
Dcl-S emailTo char(50);

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO,
                 DynUsrPrf = *owner,CloSQLCsr = *endmod,SrtSeq = *langidshr;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('SYNTLBB1');
    pmrPrdLib  like(prdLib);
    pmrTstLib  like(tstLib);
    pmrRefresh like(refresh);
    pmrEmailTo like(emailTo);
  End-Pi;

  // move input parameters to globals
  prdLib  = pmrPrdLib;
  tstLib  = pmrTstLib;
  refresh = pmrRefresh;
  emailTo = pmrEmailTo;

  // Opens/creates the Excel work book
  #$XLSXOpen('OutputName:/tmp/Synchronize Test Library Results.xlsx');

  // Setup some styles
  #$XLSXStyle('name:S_DATE' : 'Font:Arial' : 'PointSize:10' : 'Alignment:CENTER': 'DataFormat:yyyy/mm/dd');
  #$XLSXStyle('name:S_DOLLAR' : 'Font:Arial' : 'PointSize:10': 'DataFormat:#,##0.00');
  #$XLSXStyle('name:S_TITLE' : 'Font:Arial' : 'PointSize:18' : 'WrapText:Yes': 'Alignment:CENTER' : 'BoldWeight:BOLD');
  #$XLSXStyle('name:S_HDR' : 'Font:Arial' : 'PointSize:10' : 'WrapText:YES': 'Alignment:CENTER' : 'BoldWeight:BOLD');

  If refresh = '*YES';
    RefreshData();
  EndIf;

  ValidateObjects();

  ValidateReferences();

  // Close the open XLS File
  #$XLSXClose();

  // Email the file that was generated
  #$CMD('RJSSMTP/SMTPSEND +
            TOADDR(''' + %trim(emailTo) + ''') +
            SUBJECT(''Sychronize Test Library Results (SYNCTEST)'') +
            MESSAGE(''Attached is ...'') +
            ATTACHMENT(''/tmp/Synchronize Test Library Results.xlsx'') +
            CONTYPE(''text/html'')');
End-Proc;


// Refresh all data objects in test library, from production library
Dcl-Proc RefreshData;

  Dcl-Ds dta;
    fleLib like(APLDCT.fleLib);
    fleNme like(APLDCT.fleNme);
    fleTyp char(30);
    fleTxt like(APLDCT.des);
  End-Ds;
  Dcl-S action char(30);
  Dcl-S errTxt char(30);
  Dcl-S i packed(3);
  Dcl-S isFound Ind;

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:Refresh Results'
          : 'FreezeRows:6'
          : 'ColumnWidth: 1:12'  // Library
          : 'ColumnWidth: 2:12'  // File
          : 'ColumnWidth: 3:15'  // Type
          : 'ColumnWidth: 4:40'  // Text
          : 'ColumnWidth: 5:30'  // Action
          : 'ColumnWidth: 6:30'  // Error
  );

  // add headers
  #$XLSXChar('Synchronize Test Data Library':'S_TITLE':3);
  #$XLSXChar('SYNCTEST');
  #$XLSXChar(%editw(%dec(%char(%date():*iso0):8:0):'    /  / 0'));
  #$XLSXChar(%editw(%dec(%char(%time():*hms0):6:0):'  :  : 0'));

  // add prod library
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Production Library: ' +%trim(prdLib));

  // add test library
  #$XLSXNext();
  #$XLSXChar('Test Library: ' +%trim(tstLib));

  // skip 2 lines and add a header row
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Library':'S_HDR');
  #$XLSXChar('File':'S_HDR');
  #$XLSXChar('Type':'S_HDR');
  #$XLSXChar('File Text':'S_HDR');
  #$XLSXChar('Action':'S_HDR');
  #$XLSXChar('Error':'S_HDR');

  // Delete all views, LF's and indexes in test library
  // This must be looped through until they are all done,
  // This is becasue some may refercne other and allow them to not be deleted.
  // Do not give an error on the first 9 attemps at deleted the file, on the
  // 10 attempt give the error. It only loops ten times to prevent a never
  // ending loop. If there are more than 10 levle of file references, then the
  // structure needs to be reconsidered.
  Action = 'Deleting LFs/Views/Index';
  For i = 1 to 10;
    isFound = *off;
    Exec SQL Declare crs1 Cursor for
      With
        views as (
          Select
            system_table_schema,
            system_table_name,
            Case table_type
              When 'A'  Then 'Alias'
              When 'G'  Then 'Temp Table'
              When 'L'  Then 'Logical File'
              When 'P'  Then 'Physical File'
              When 'T'  Then 'Table'
              When 'V'  Then 'View'
              When 'S'  Then 'System Temporal'
              When 'H'  Then 'History Table'
            End file_type,
            cast(table_text as char(40) ccsid 37) table_text
          From systables
          Where system_table_schema = :tstLib
            and file_type = 'D' // only include data files
            and table_type not in ('T','P','A') // exclude tables,PF or aliases
        ),
        logicals as (
          Select
            system_table_schema,
            system_table_name,
            'Logical File'file_type,
            cast(coalesce(text_description,'') as char(40) ccsid 37) table_text
          From sysfiles
          Where system_table_schema = :tstLib
            and native_type = 'LOGICAL'
        ),
        Indexes as (
          Select
            system_index_schema,
            system_index_name,
            'Index' table_type,
            cast(index_text as char(40) ccsid 37) table_text
          From sysIndexes
          Where system_index_schema = :tstLib
        )
      Select
        system_table_schema,
        system_table_name,
        listagg(distinct trim(file_type),', ') file_type,
        max(table_text) table_text
      From (
        Select * From Views
        Union All
        Select * From Logicals
        Union All
        Select * From Indexes)
      Group by system_table_schema, system_table_name
      Order by system_table_name;

    Clear dta;
    Exec SQL Open crs1;
    Exec SQL Fetch Next From crs1 into :dta;
    DoW sqlState < '02';
      isFound = *on;
      Monitor;
        #$CMD('DLTF ' + %trim(fleLib) + '/' + %trim(fleNme));
        // Write To the Excel file, file deleted
        #$XLSXNext();
        #$XLSXChar(fleLib);
        #$XLSXChar(fleNme);
        #$XLSXChar(fleTyp);
        #$XLSXChar(fleTxt);
        #$XLSXChar(action);
        #$XLSXChar('');
      On-Error;
        If i = 10;
          // Write to the Excel file, not deleted, only on the tenth try
          #$XLSXNext();
          #$XLSXChar(fleLib);
          #$XLSXChar(fleNme);
          #$XLSXChar(fleTyp);
          #$XLSXChar(fleTxt);
          #$XLSXChar(action);
          #$XLSXChar('Not Deleted');
        EndIf;
      EndMon;
      Exec SQL Fetch Next From crs1 into :dta;
    EndDo;
    Exec SQL Close crs1;
    // If not entryies where foudnon this try, exit the fir loop
    If not isFound;
      Leave;
    EndIf;
  EndFor;

  // Duplicate all tables and PF's in test library, with data
  Action = 'Duplicating data files';
  Exec SQL Declare crs2 cursor for
    With
      tables as (
        Select
          system_table_schema,
          system_table_name,
          Case table_type
            When 'A'  Then 'Alias'
            When 'G'  Then 'Temp Table'
            When 'L'  Then 'Logical File'
            When 'P'  Then 'Physical File'
            When 'T'  Then 'Table'
            When 'V'  Then 'View'
            When 'S'  Then 'System Temporal'
            When 'H'  Then 'History Table'
          End file_type,
          cast(table_text as char(40) ccsid 37) table_text
        From systables
        Where system_table_schema = :prdLib
          and file_type = 'D' // only include data files
          and table_type in ('T','P','A') // only include tables,PF or aliases
          and system_table_name not like 'FQCSTHLD' // Exclude this huge table
          and system_table_name not like 'POPRT%' // exclude these backups
      ),
      Files as (
        Select
          system_table_schema,
          system_table_name,
          'Physical File' file_type,
          cast(coalesce(text_description,'') as char(40) ccsid 37) table_text
        From sysfiles
        Where system_table_schema = :prdLib
          and native_type = 'PHYSICAL'
          and system_table_name not like 'FQCSTHLD' // Exclude this huge table
          and system_table_name not like 'POPRT%' // exclude these backups
      )
      Select
        system_table_schema,
        system_table_name,
        listagg(distinct trim(file_type),', ') file_type,
        max(table_text) table_text
      From (
        Select * From Tables
        Union All
        Select * From Files)
      Group by system_table_schema, system_table_name
      Order by file_type Desc, system_table_name; -- make sure to do aliases last

  Clear dta;
  Exec SQL Open crs2;
  Exec SQL Fetch Next From crs2 into :dta;
  DoW sqlState < '02';
    #$CMD('DLTF ' + %trim(tstLib) + '/' + %trim(fleNme):1);
    Clear errTxt;
    Monitor;
      #$CMD('CRTDUPOBJ ' + %trim(fleNme) + ' ' + %trim(prdLib) + ' *FILE ' + %trim(tstLib) + ' DATA(*YES)':2);
    On-Error;
      errTxt = 'Not Duplicated';
    EndMon;
    // Write To the Excel file
    #$XLSXNext();
    #$XLSXChar(fleLib);
    #$XLSXChar(fleNme);
    #$XLSXChar(fleTyp);
    #$XLSXChar(fleTxt);
    #$XLSXChar(action);
    #$XLSXChar(errTxt);
    Exec SQL Fetch Next From crs2 into :dta;
  EndDo;
  Exec SQL Close crs2;

  // Duplicate all views, LF's and indexes from production lib to test lib
  Action = 'Re-creating LFs/Views/Indexes';
  Exec SQL Declare crs3 Cursor for
      With
        views as (
          Select
            system_table_schema,
            system_table_name,
            Case table_type
              When 'A'  Then 'Alias'
              When 'G'  Then 'Temp Table'
              When 'L'  Then 'Logical File'
              When 'P'  Then 'Physical File'
              When 'T'  Then 'Table'
              When 'V'  Then 'View'
              When 'S'  Then 'System Temporal'
              When 'H'  Then 'History Table'
            End file_type,
            cast(table_text as char(40) ccsid 37) table_text
          From systables
          Where system_table_schema = :prdLib
            and file_type = 'D' // only include data files
            and table_type not in ('T','P','A') // exclude tables,PF or aliases
        ),
        logicals as (
          Select
            system_table_schema,
            system_table_name,
            'Logical File'file_type,
            cast(coalesce(text_description,'') as char(40) ccsid 37) table_text
          From sysfiles
          Where system_table_schema = :prdLib
            and native_type = 'LOGICAL'
        ),
        Indexes as (
          Select
            system_index_schema,
            system_index_name,
            'Index' table_type,
            cast(index_text as char(40) ccsid 37) table_text
          From sysIndexes
          Where system_index_schema = :prdLib
        )
      Select
        system_table_schema,
        system_table_name,
        listagg(distinct trim(file_type),', ') file_type,
        max(table_text) table_text
      From (
        Select * From Views
        Union All
        Select * From Logicals
        Union All
        Select * From Indexes)
      Group by system_table_schema, system_table_name
      Order by system_table_name;
  Clear dta;
  Exec SQL Open crs3;
  Exec SQL Fetch Next From crs3 into :dta;
  DoW sqlState < '02';
    Clear errTxt;
    Monitor;
      #$CMD('CRTDUPOBJ ' + %trim(fleNme) + ' ' + %trim(fleLib) + ' *FILE ' +%trim(tstLib):2);
    On-Error;
      errTxt = 'Not Duplicated';
    EndMon;
    // Write To the Excel file
    #$XLSXNext();
    #$XLSXChar(fleLib);
    #$XLSXChar(fleNme);
    #$XLSXChar(fleTyp);
    #$XLSXChar(fleTxt);
    #$XLSXChar(action);
    #$XLSXChar(errTxt);
    Exec SQL Fetch Next From crs3 into :dta;
  EndDo;
  Exec SQL Close crs3;

End-Proc;


// Validate that all file objects exist in the test library that are in the production library
Dcl-Proc ValidateObjects;
  Dcl-Ds dta;
    prdfle like(APLDCT.fleNme);
    fleTxt like(APLDCT.des);
    fleTyp char(15);
  End-Ds;

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:Missing Files'
          : 'FreezeRows:6'
          : 'ColumnWidth: 1:12'  // File
          : 'ColumnWidth: 2:40'  // File Text
          : 'ColumnWidth: 3:15'  // File Type
  );

  // add headers
  #$XLSXChar('Synchronize Test Data Library':'S_TITLE':3);
  #$XLSXChar('SYNCTEST');
  #$XLSXChar(%editw(%dec(%char(%date():*iso0):8:0):'    /  / 0'));
  #$XLSXChar(%editw(%dec(%char(%time():*hms0):6:0):'  :  : 0'));

  // add prod library
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Production Library: ' +%trim(prdLib));

  // add test library
  #$XLSXNext();
  #$XLSXChar('Test Libraray: ' +%trim(tstLib));

  // skip 2 lines and add a header row
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('File':'S_HDR');
  #$XLSXChar('File Text':'S_HDR');
  #$XLSXChar('File Type':'S_HDR');

  // Print all dependancies to the production library from outside the production library
  Exec SQL Declare crs5 Cursor for
    With
      TestViews as (
        Select
          system_table_schema,
          system_table_name,
          Case table_type
            When 'A'  Then 'Alias'
            When 'G'  Then 'Temp Table'
            When 'L'  Then 'Logical File'
            When 'P'  Then 'Physical File'
            When 'T'  Then 'Table'
            When 'V'  Then 'View'
            When 'S'  Then 'System Temporal'
            When 'H'  Then 'History Table'
          End file_type,
          cast(table_text as char(40) ccsid 37) table_text
        From systables
        Where system_table_schema = :tstLib
          and file_type = 'D' -- only include data files
          and table_type not in ('T','P','A') -- exclude tables,PF or aliases
      ),
      TestLogicals as (
        Select
          system_table_schema,
          system_table_name,
          case native_type when 'LOGICALS' then 'Logical File'
                           when 'PHYSICAL' then 'Phyical File'
                           Else 'Error'
          End file_type,
          cast(coalesce(text_description,'') as char(40) ccsid 37) table_text
        From sysfiles
        Where system_table_schema = :tstLib
      ),
      TestIndexes as (
        Select
          system_index_schema,
          system_index_name,
          'Index' table_type,
           cast(index_text as char(40) ccsid 37) table_text
        From sysIndexes
        Where system_index_schema = :tstLib
      ),
      ProductionViews as (
        Select
          system_table_schema,
          system_table_name,
          Case table_type
            When 'A'  Then 'Alias'
            When 'G'  Then 'Temp Table'
            When 'L'  Then 'Logical File'
            When 'P'  Then 'Physical File'
            When 'T'  Then 'Table'
            When 'V'  Then 'View'
            When 'S'  Then 'System Temporal'
            When 'H'  Then 'History Table'
          End file_type,
          cast(table_text as char(40) ccsid 37) table_text
        From systables
        Where system_table_schema = :prdLib
          and file_type = 'D' -- only include data files
          and table_type not in ('T','P','A') -- exclude tables,PF or aliases
      ),
      ProductionLogicals as (
        Select
          system_table_schema,
          system_table_name,
          case native_type when 'LOGICALS' then 'Logical File'
                           when 'PHYSICAL' then 'Phyical File'
                           Else 'Error'
          End file_type,
          cast(coalesce(text_description,'') as char(40) ccsid 37) table_text
        From sysfiles
        Where system_table_schema = :prdLib
      ),
      ProductionIndexes as (
        Select
          system_index_schema,
          system_index_name,
          'Index' table_type,
           cast(index_text as char(40) ccsid 37) table_text
        From sysIndexes
        Where system_index_schema = :prdLib
      ),
      Test as (
        Select
          system_table_schema,
          system_table_name,
          listagg(distinct trim(file_type),', ') file_type,
          max(table_text) table_text
        From (
          Select * From TestViews
          Union All
          Select * From TestLogicals
          Union All
          Select * From TestIndexes)
        Group by system_table_schema, system_table_name
      ),
      Production as (
        Select
          system_table_schema,
          system_table_name,
          listagg(distinct trim(file_type),', ') file_type,
          max(table_text) table_text
        From (
          Select * From ProductionViews
          Union All
          Select * From ProductionLogicals
          Union All
          Select * From ProductionIndexes)
        Group by system_table_schema, system_table_name
      )
    Select
      l.system_table_schema,
      l.system_table_name,
      l.file_type,
      l.table_text
    From Production as l
    Left Join Test as t on (l.system_table_name = t.system_table_name)
    Where t.system_table_name is null  -- is not in test library
    Order by l.system_table_name;
  Clear dta;
  Exec SQL Open crs5;
  Exec SQL Fetch Next From crs5 into :dta;
  DoW sqlState < '02';
    // Write To the Excel file
    #$XLSXNext();
    #$XLSXChar(prdfle);
    #$XLSXChar(fleTxt);
    #$XLSXChar(fleTyp);
    Exec SQL Fetch Next From crs5 into :dta;
  EndDo;
  Exec SQL Close crs5;



End-Proc;


// Validate that no object in the test library references an object in the production library
Dcl-Proc ValidateReferences;
  Dcl-Ds dta;
    prdfle like(APLDCT.fleNme);
    refLib like(APLDCT.fleLib);
    refFle like(APLDCT.fleNme);
    fleTyp char(15);
    prdTxt like(APLDCT.des);
    refTxt like(APLDCT.des);
  End-Ds;

  // create a new sheet(tab)
  #$XLSXWkSh('SheetName:Reference Errors'
          : 'FreezeRows:6'
          : 'ColumnWidth: 1:12'  // Production File
          : 'ColumnWidth: 2:12'  // Reference Library
          : 'ColumnWidth: 3:12'  // Reference File
          : 'ColumnWidth: 4:12'  // Reference File Type
          : 'ColumnWidth: 5:40'  // Production Text
          : 'ColumnWidth: 6:40'  // Reference Text
  );

  // add headers
  #$XLSXChar('Synchronize Test Data Library':'S_TITLE':3);
  #$XLSXChar('SYNCTEST');
  #$XLSXChar(%editw(%dec(%char(%date():*iso0):8:0):'    /  / 0'));
  #$XLSXChar(%editw(%dec(%char(%time():*hms0):6:0):'  :  : 0'));

  // add prod library
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Production Library: ' +%trim(prdLib));

  // add test library
  #$XLSXNext();
  #$XLSXChar('Test Library: ' +%trim(tstLib));

  // skip 2 lines and add a header row
  #$XLSXNext();
  #$XLSXNext();
  #$XLSXChar('Production File':'S_HDR');
  #$XLSXChar('Reference Library ':'S_HDR');
  #$XLSXChar('Reference File':'S_HDR');
  #$XLSXChar('Reference File Type':'S_HDR');
  #$XLSXChar('Production Text':'S_HDR');
  #$XLSXChar('Reference Text':'S_HDR');
  #$XLSXChar('Error':'S_HDR');


  // Build tempfile of relations
  #$CMD('DSPDBR FILE(' + %trim(prdLib) + '/*ALL) +
           OUTPUT(*OUTFILE) OUTFILE(QTEMP/DSPDBRPF) OUTMBR(*FIRST *REPLACE)');

  // Print all dependancies to the production library from outside the production library
  Exec SQL Declare crs4 Cursor for
    SELECT
      whRfi produttion_file,
      whReLi reference_library,
      whReFi reference_file,
      Case re.table_type
        When 'A'  Then 'Alias'
        When 'G'  Then 'Temp table'
        When 'L'  Then 'Logical file'
        When 'P'  Then 'Physical file'
        When 'T'  Then 'Table'
        When 'V'  Then 'View'
        When 'S'  Then 'System temporal'
        When 'H'  Then 'History table'
      End reference_file_type,
      cast(r.table_text as char(40) ccsid 37) prodcution_file_text,
      cast(re.table_text as char(40) ccsid 37) reference_file_text
    FROM QTEMP.DSPDBRPF
    Left Join systables as r on (r.system_table_name,r.system_table_schema) = (whRFi, whRLi)
    Left Join systables as re on (re.system_table_name,re.system_table_schema) = (whReFi, whReLi)
    Where WHRELI = :tstLib;
  Clear dta;
  Exec SQL Open crs4;
  Exec SQL Fetch Next From crs4 into :dta;
  DoW sqlState < '02';
    // Write To the Excel file
    #$XLSXNext();
    #$XLSXChar(prdfle);
    #$XLSXChar(refLib);
    #$XLSXChar(refFle);
    #$XLSXChar(fleTyp);
    #$XLSXChar(prdTxt);
    #$XLSXChar(refTxt);
    Exec SQL Fetch Next From crs4 into :dta;
  EndDo;
  Exec SQL Close crs4;



End-Proc;
