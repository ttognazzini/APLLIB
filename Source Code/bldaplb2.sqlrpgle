**FREE
Ctl-Opt ActGrp(*New);
/copy APLLIB/QSRC,$ctlopt  // Default Ctl-Opt's, does not include activation group

// Build APLLIB - Initial File Seeds

// This member creates all files for the dta system and seeds the with some required data
// the intent is to allow the dictionary and file system to be moved to a new library and
// started from scratch.

// For testing the system has been move the library APLLIB. This member hard references
// that library, change it to where you want this to run.

// create the dictionary, fields and segments files

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;

Dcl-Proc Main;

  // populate field types */
  Exec SQL Truncate APLLIB.FLDTYP;
  Exec SQL Alter Table APLLIB.FLDTYP Alter Column fldTypIdn Restart With 1;
  Exec SQL
  Insert into APLLIB.FLDTYP
        (ACVROW,FLDTYP,      DES,                               NMR,ALWDEC,ALWLEN,REQLEN,ALWALC,REQALC,MAXLEN,
        LRGVAL,SMLVAL,FRCLEN,FRCLEN1,FRCLEN2,FRCLEN3,FRCLEN4,FRCLEN5,DEFAULT_VALUE,SYSTEM_TYPE,SYSTEM_LENGTH)
  values(1,'CHAR      ','Character Field                      ','N','N','Y','Y','N','N',32766,
        0,0,                   'N',0,0,0,0,0,''' '''                      ,'CHAR    ',0),
        (1,'INTEGER   ','Integer                              ','Y','N','N','N','N','N',0    ,
        2147483648,-2147483648,'N',0,0,0,0,0,0                            ,'INTEGER' ,4),
        (1,'SMALLINT  ','Small Integer                        ','Y','N','N','N','N','N',0    ,
        32768,-32768,          'N',0,0,0,0,0,0                            ,'SMALLINT',2),
        (1,'BIGINT    ','Big Integer                          ','Y','N','N','N','N','N',0,
        9223372036854775808,-9223372036854775808,'N',0,0,0,0,0,0              ,'BIGINT  ',8),
        (1,'DECFLOAT  ','Decimal Floating Point               ','Y','N','Y','Y','N','N',34   ,
        0,0,                   'Y',16,34,0,0,0,'0E0'                      ,'DECFLOAT',0),
        (1,'NUMERIC   ','Zoned Numeric                        ','Y','Y','Y','Y','N','N',63   ,
        0,0,                   'N',0,0,0,0,0,0                            ,'NUMERIC ',0),
        (1,'DECIMAL   ','Packed Decimal                       ','Y','Y','Y','Y','N','N',63   ,
        0,0,                   'N',0,0,0,0,0,0                            ,'DECIMAL ',0),
        (1,'REAL      ','Real (Floating Point Number)         ','Y','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,0                            ,'FLOAT   ',4),
        (1,'DOUBLE    ','Double Precision (Big Floating Point)','Y','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,0                            ,'FLOAT   ',8),
        (1,'VARCHAR   ','Varying Length Character Data        ','N','N','Y','Y','Y','Y',32740,
        0,0,                   'N',0,0,0,0,0,''''''                       ,'VARCHAR ',0),
        (1,'CLOB      ','Character Large Object               ','N','N','Y','Y','N','N',2147483647,
        0,0,              'N',0,0,0,0,0,''''''                       ,'CLOB    ',0),
        (1,'DATE      ','Date                                 ','N','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,'CURRENT_DATE'               ,'DATE    ',4),
        (1,'TIME      ','Time                                 ','N','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,'CURRENT_TIME'               ,'TIME    ',3),
        (1,'TIMESTAMP ','Time Stamp                           ','N','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,'CURRENT_TIMESTAMP'          ,'TIMESTMP',10),
        (1,'BINARY    ','Binary Data                          ','N','N','Y','Y','N','N',255  ,
        0,0,                   'N',0,0,0,0,0,'BINARY(X''00'')'            ,'BINARY  ',0),
        (1,'VARBINARY ','Varying Length Binary Data           ','N','N','Y','Y','Y','Y',32740,
        0,0,                   'N',0,0,0,0,0,'VARBINARY(X'''''')'         ,'VARBIN  ',0),
        (1,'GRAPHIC   ','Graphic Data                         ','N','N','Y','Y','N','N',16383,
        0,0,                   'N',0,0,0,0,0,'N'''''                      ,'GRAPHIC ',0),
        (1,'VARGRAPHIC','Varying Length Graphic Data          ','N','N','Y','Y','Y','Y',16370,
        0,0,                   'N',0,0,0,0,0,'N'''''                      ,'VARG    ',0),
        (1,'BLOB      ','Binary Large Object                  ','N','N','Y','Y','N','N',2147483647,
        0,0,              'N',0,0,0,0,0,'BLOB('''')'                 ,'BLOB    ',0),
        (1,'DBCLOB    ','Large Graphic Object                 ','N','N','Y','Y','N','N',1073741823,
        0,0,              'N',0,0,0,0,0,'N'''''                      ,'DBCLOB  ',0),
        (1,'DATALINK  ','Data Link                            ','N','N','Y','Y','N','N',200  ,
        0,0,                   'N',0,0,0,0,0,'DLVALUE('''',''URL '','''')','DATALINK',0),
        (1,'XML       ','XML Document                         ','N','N','N','N','N','N',0    ,
        0,0,                   'N',0,0,0,0,0,''''''                       ,'XML     ',2147483647),
        (1,'IDENTITY  ','Auto Generated Identity Column       ','Y','N','N','N','N','N',0,
        9223372036854775808,-9223372036854775808,'N',0,0,0,0,0,''''''     ,'BIGINT  ',8);

  // populate DCTMST */
  Exec SQL
    insert into APLLIB.DCTMST
          ( dctNme,  des,                                 nte)
    values('APLDCT','Application Development Dictionary','Application Development Dictionary'),
          ('ERPDCT','ERP Dictionary','This is a dictionary for ERP stuff, outside of APLLIB');

  // populate required segments */
  // To repoduce from current values use:
  // Select
  //   '(''' || trim(replace(dtaSeg,'''','''''')) || ''',''' || trim(replace(des,'''','''''')) || ''','''
  //         || trim(replace(colTxt,'''','''''')) || ''',''' || trim(replace(colHdgSeg,'''',''''''))
  //         || ''',''' ||  replace(cnfExs,'''','''''') || ''',''' ||  replace(trim(nte),'''','''''') || '''),'
  // From DCTSEG
  // Order by dtaSeg;
  Exec SQL
Merge into APLLIB.DCTSEG as Target
Using(
  Values
('AAR','Auto Archive','Auto Archive','Auto Archive',' ',''),
('ABC','ABC - Inventory Classification Code','ABC - Inventory Classification Code','ABC - Inventory Clas',' ',''),
('ABR','Abbreviated','Abbreviated','Abbreviated',' ',''),
('ACC','Account','Account','Account',' ',''),
('ACG','Accounting','Accounting','Accounting',' ',''),
('ACL','Auto Close','Auto Close','Auto Close',' ',''),
('ACT','Action/Account','Action','Action',' ',''),
('ACV','Active','Active','Active',' ',''),
('ADD','Address','Address','Address',' ',''),
('AFT','After','After','After',' ',''),
('AGC','Accounting Group Code','Accounting Group Code','Accounting Group Cod',' ',''),
('ALC','Allocation','Allocation','Allocation',' ',''),
('ALW','Allow','Allow','Allow',' ',''),
('APL','Application','Application','Application',' ',''),
('ARA','Area','Area','Area',' ',''),
('ARC','Archive','Archive','Archive',' ',''),
('ASM','Assembly','Assembly','Assembly',' ',''),
('ATA','Attachment','Attachment','Attachment',' ',''),
('ATR','Attribute','Attribute','Attribute',' ',''),
('AUD','Audit','Audit','Audit',' ',''),
('AUT','Authorization/ Authority','Authorization/ Authority','Authorization/ Autho',' ',''),
('BAL','Balance','Balance','Balance',' ',''),
('BEG','Begin','Begin','Begin',' ',''),
('BFR','Before','Before','Before',' ',''),
('BIN','Bin','Bin','Bin',' ',''),
('BJB','Batch Job','Batch Job','Batch Job',' ',''),
('BSK','Balance Before Safety Stock','Balance Before Safety Stock','Balance Safety Stock',' ',''),
('BYR','Buyer','Buyer','Buyer',' ',''),
('CAC','Corrective Action','Corrective Action','Corrective Action',' ',''),
('CCD','Commodity Code','Commodity Code','Commodity Code',' ',''),
('CDE','Code','Code','Code',' ',''),
('CER','Certificate','Certificate','Certificate',' ',''),
('CHG','Change','Change','Change',' ',''),
('CHK','Check','Check','Check',' ',''),
('CLN','Clean','Clean','Clean',' ',''),
('CLS','Class','Class','Class',' ',''),
('CMD','Command','Command','Command',' ',''),
('CMP','Company','Company','Company',' ',''),
('CMT','Comment','Comment','Comment',' ',''),
('CNF','Conflict/Config','Conflict','Conflict','Y',''),
('CNT','Count','Count','Count',' ',''),
('CNY','Contact Type','Contact Type','Contact Type',' ',''),
('COL','Column/ Collection','Column/ Collection','Column/ Collection','Y',''),
('CON','Contact','Contact','Contact','Y',''),
('COU','Country','Country','Country','Y',''),
('CRD','Credit','Credit','Credit',' ',''),
('CRT','Create','Create','Create',' ',''),
('CST','Cost','Cost','Cost',' ',''),
('CTY','City','City','City',' ',''),
('CUS','Customer','Customer','Customer',' ',''),
('DBA','Database Administrator','Database Administrator','DB Admin',' ',''),
('DBT','Debit','Debit','Debit',' ',''),
('DCT','Dictionary','Dictionary','Dictionary',' ',''),
('DEC','Decimal','Decimal','Decimal',' ',''),
('DEL','Delete','Delete','Delete',' ',''),
('DES','Description','Description','Description',' ',''),
('DEV','Device','Device','Device',' ',''),
('DFT','Default','Default','Default',' ',''),
('DPT','Department','Department','Department',' ',''),
('DRV','Driver','Driver','Driver',' ',''),
('DSP','Display','Display','Display',' ',''),
('DST','Destination','Destination','Destination',' ',''),
('DTA','Data','Data','Data',' ',''),
('DTE','Date','Date','Date',' ',''),
('DTL','Detail','Detail','Detail',' ',''),
('DTM','Date/Time (Time stamp)','Date/Time (Time stamp)','Date/Time (Time stam',' ',''),
('DUE','Due','Due','Due',' ',''),
('DVW','Display View','Display View','Display View',' ','Used to save the view number on multi-view SFL''s'),
('DYS','Days','Days','Days',' ',''),
('EDT','Edit','Edit','Edit',' ',''),
('EML','Email','Email','Email',' ',''),
('EMP','Employee','Employee','Employee',' ',''),
('END','End/ Ending','End/ Ending','End/ Ending',' ',''),
('ENM','Enumerated','Enumerated','Enumerated',' ',''),
('ENT','Entry','Entry','Entry',' ',''),
('ERN','Earn','Earn','Earn',' ',''),
('ERR','Error','Error','Error',' ',''),
('EST','Estimate','Estimate','Estimate',' ',''),
('EXS','Exists','Exists','Exists',' ',''),
('EXT','Extension/ Extended/ Extend','Extension/ Extended/ Extend','Extension/ Extended/',' ',''),
('FAB','Fabricate','Fabricate','Fabricate',' ',''),
('FAX','Fax','Fax','Fax',' ',''),
('FBS','No Forecast Balance Before Safety Stk','No Forecast Balance Before Safety Stk','No-Forecast no Sfty',' ',''),
('FLD','Field','Field','Field',' ',''),
('FLE','File','File','File',' ',''),
('FLG','Flag','Flag','Flag',' ',''),
('FLR','Folder','Folder','Folder',' ',''),
('FLT','float','float','float',' ',''),
('FMG','Family Group','Family Group','Family Group',' ',''),
('FMT','Format','Format','Format',' ',''),
('FNC','Function','Function','Function',' ',''),
('FRC','Force','Force','Force',' ',''),
('FRM','From','From','From',' ',''),
('FST','First','First','First',' ',''),
('GLD','General Ledger','General Ledger','General Ledger',' ',''),
('GPR','Group','Group','Group',' ',''),
('GRP','Group','Group','Group',' ',''),
('HDG','Heading','Heading','Heading',' ',''),
('HGT','Height','Height','Height',' ',''),
('HLD','Hold','Hold','Hold',' ',''),
('HLP','Help','Help','Help',' ',''),
('ICM','increment','increment','increment',' ',''),
('IDN','Id','Id','Id',' ',''),
('IDX','Index','Index','Index',' ',''),
('IFM','IFS Monitor','IFS Monitor','IFS Monitor',' ',''),
('IFS','Integrated File Server','Integrated File Server','Integrated File Srv',' ',''),
('INA','In Address','In Address','In Address',' ',''),
('INC','Include','Include','Include',' ',''),
('IND','Indirect','Indirect','Indirect',' ',''),
('INQ','Inquiry','Inquiry','Inquiry',' ',''),
('INT','Integer/Initials','Integer/Initials','Integer/Initials','Y',''),
('INV','Invoice','Invoice','Invoice',' ',''),
('ISO','ISO','ISO','ISO',' ',''),
('ITR','IT Requester','IT Requester','IT Requester',' ',''),
('JEB','Journal Entry Batch','Journal Entry Batch','Journal Entry Batch',' ',''),
('JOB','Job','Job','Job',' ',''),
('KEY','Key','Key','Key',' ',''),
('LBE','Labor Error','Labor Error','Labor Error',' ',''),
('LBR','Labor','Labor','Labor',' ',''),
('LEC','Labor Error Code','Labor Error Code','Labor Error Code',' ',''),
('LED','Lead','Lead','Lead',' ',''),
('LEN','Length','Length','Length',' ',''),
('LIB','Library','Library','Library',' ',''),
('LKU','Lookup','Lookup','Lookup',' ',''),
('LNE','Line','Line','Line',' ',''),
('LNG','Long','Long','Long',' ',''),
('LOC','Location','Loc','Loc','N','Location'),
('LOG','Log','Log','Log',' ',''),
('LRG','Large','Large','Large',' ',''),
('LST','List/Last','List/Last','List/Last','Y',''),
('LVL','Level','Level','Level',' ',''),
('MAX','Maximum','Maximum','Maximum',' ',''),
('MBR','Member','Member','Member',' ',''),
('MDE','Mode','Mode','Mode',' ',''),
('MDL','Model','Model','Model',' ',''),
('MJR','Major','Major','Major',' ',''),
('MNT','Maintenance','Maintenance','Maintenance',' ',''),
('MNU','Menu','Menu','Menu',' ',''),
('MON','Monitor','Monitor','Monitor',' ',''),
('MRP','Material Resource Planning','MRP','MRP',' ',''),
('MSD','Message File Data','Msg Fle Dta','Message File Data',' ',''),
('MSF','Message File','Message File','Msg File',' ',''),
('MSG','Message','Message','Message',' ',''),
('MST','Master','Master','Master',' ',''),
('MTH','Month','Month','Month',' ',''),
('NAT','Native/National','Native','Native',' ',''),
('NBR','Number','Number','Number',' ',''),
('NFC','Non-Forecast','Non-Forecast','Non-Forecast',' ',''),
('NME','Name','Name','Name',' ',''),
('NMR','Numeric','Numeric','Numeric',' ',''),
('NTE','Note','Note','Note',' ',''),
('NUL','null','null','null',' ',''),
('NXT','Next','Next','Next',' ',''),
('OBJ','Object','Object','Object',' ',''),
('ONF','On File','On File','On File',' ',''),
('ONH','On Hand','On Hand','On Hand',' ',''),
('ONL','Only','Only','Only',' ',''),
('OPT','Option','Option','Option',' ',''),
('OQL','Output Queue Library','Output Queue Library','Output Queue Library',' ',''),
('OQN','Output Queue Name','Output Queue Name','Output Queue Name',' ',''),
('ORD','Order','Order','Order',' ',''),
('OTO','Output Options','Output Options','Output Options',' ',''),
('OUT','Output','Output','Output',' ',''),
('OWN','Owner','Owner','Owner',' ',''),
('PCD','Process/ Processed','Process/ Processed','Process/ Processed',' ',''),
('PCL','Product Class','Product Class','Product Class',' ',''),
('PGM','Program','Program','Program',' ',''),
('PHN','Phone','Phone','Phone',' ',''),
('PKL','Pick List','Pick List','Pick List',' ',''),
('PLT','Plant','Plant','Plant',' ',''),
('PMP','Prompt','Prompt','Prompt',' ',''),
('PRC','Price','Price','Price',' ',''),
('PRD','Product','Product','Product',' ',''),
('PRF','Profile','Profile','Profile',' ',''),
('PRI','Primary','Primary','Primary',' ',''),
('PRN','Parent','Parent','Parent',' ',''),
('PRT','Print/Part','Print/Part','Print/Part','Y',''),
('PSC','Postal Code','Postal Code','Postal Code',' ',''),
('PSL','Part Sales','Part Sales','Part Sales',' ',''),
('PTH','Path','Path','Path',' ',''),
('PUR','Purchase/Purchasing/Purchased','Purchase/Purchasing/Purchased','Purchase/Purchasing/',' ',''),
('QAD','Q/A Audit','Q/A Audit','Q/A Audit',' ',''),
('QTY','Quantity','Quantity','Quantity',' ',''),
('RCD','Record','Record','Record',' ',''),
('RCV','Receive','Receive','Receive',' ',''),
('REF','Reference','Reference','Reference',' ',''),
('REG','Registered/Regular','Registered/Regular','Registered/Regular','Y',''),
('REQ','Requires/Required','Required','Required',' ',''),
('ROW','Row','Row','Row',' ',''),
('RRN','Relative Record Number','Relative Record Number','Relative Record Nbr',' ',''),
('RSR','Response Rating','Response Rating','Response Rating',' ',''),
('SAV','Save','Save','Save',' ',''),
('SBS','Sub System','Sub System','Sub System',' ',''),
('SCD','Scheduled','Scheduled','Scheduled',' ',''),
('SCH','Search','Search','Search',' ',''),
('SCR','Screen','Screen','Screen',' ',''),
('SDS','Short Description','Short Description','Short Description',' ',''),
('SEC','Security','Security','Security',' ',''),
('SEG','Segment','Segment','Segment',' ',''),
('SEL','Select/Selection','Select/Selection','Select/Selection',' ',''),
('SEQ','Sequence','Sequence','Sequence',' ',''),
('SFT','Safety','Safety','Safety',' ',''),
('SHP','Ship','Ship','Ship',' ',''),
('SHR','Shortage','Shortage','Shortage',' ',''),
('SLS','Sales','Sales','Sales',' ',''),
('SML','Small','Small','Small',' ',''),
('SMP','Sample','Sample','Sample',' ',''),
('SPS','Special Process','Special Process','Special Process',' ',''),
('SQL','Structured Query Language','Structured Query Language','Structured Query Lan',' ',''),
('SRC','Source','Source','Source',' ',''),
('SRT','Sort','Sort','Sort',' ',''),
('SSC','Supplier Scorecard','Supplier Scorecard','Supplier Scorecard',' ',''),
('STA','State','State','State',' ',''),
('STK','Stock','Stock','Stock',' ',''),
('STR','Start','Start','Start',' ',''),
('STS','Status','Status','Status',' ',''),
('SUP','Supplier','Supplier','Supplier',' ',''),
('SYN','Synchornize','Synchornize','Synchornize',' ',''),
('SYS','System','System','System',' ',''),
('SZE','Size','Size','Size',' ',''),
('TBL','Table','Table','Table',' ',''),
('TBU','Tableau','Tableau','Tableau',' ',''),
('TCD','Time Card','Time Card','Time Card',' ',''),
('TER','Territory','Territory','Territory',' ',''),
('TGT','Target','Target','Target',' ',''),
('TME','Time','Time','Time',' ',''),
('TOT','Total','Total','Total',' ',''),
('TRG','Trigger','Trigger','Trigger',' ',''),
('TST','Test','Test','Test',' ',''),
('TTL','Title','Title','Title',' ',''),
('TXT','Text','Text','Text',' ',''),
('TYP','Type','Type','Type',' ',''),
('UDF','User Default','User Default','User Default',' ',''),
('UNI','Uni','Uni','Uni',' ','Common Business Number/Uni'),
('UNT','Unit','Unit','Unit',' ',''),
('UPD','Update','Update','Update',' ',''),
('USR','User','User','User',' ',''),
('VAL','Value','Value','Value',' ',''),
('VAR','Variable','Variable','Variable',' ',''),
('VND','Vendor','Vendor','Vendor',' ',''),
('VRY','Vary/ Varying','Vary/ Varying','Vary/ Varying',' ',''),
('WEB','Web','Web','Web',' ',''),
('WID','Width/ Wide','Width/ Wide','Width/ Wide',' ',''),
('WRD','Word','Word','Word',' ',''),
('YER','Year','Year','Year',' ',''),
('Zon','Zone','Zone','Zone',' ',''),
('1','1','1','1',' ',''),
('2','2','2','2',' ',''),
('3','3','3','3',' ',''),
('4','4','4','4',' ',''),
('5','5','5','5',' ',''),
('6','6','6','6',' ',''),
('7','7','7','7',' ',''),
('8','8','8','8',' ',''),
('9','9','9','9',' ','')
) as source (dtaSeg, des, colTxt, colHdgSeg, cnfExs, nte)
on target.dtaSeg = source.dtaSeg

When Matched Then Update Set
    target.dtaSeg    = source.dtaSeg,
    target.des       = source.des,
    target.colTxt    = source.colTxt,
    target.colHdgSeg = source.colHdgSeg,
    target.cnfExs    = source.cnfExs,
    target.nte       = source.nte

When not Matched Then
    Insert (dtaSeg, des, colTxt, colHdgSeg, cnfExs, nte)
    Values (source.dtaSeg, source.des, source.colTxt, source.colHdgSeg, source.cnfExs, source.nte);



  // populate required dictionary fields */
  // To generate values from production table use:
  // With
  //   Line1 as (
  //     Select
  //       dctNme,
  //       fldNme,
  //       2 as lneSeq,
  //       '(''' || trim(dctNme) || ''','''
  //             || trim(fldNme) || ''','''
  //             || trim(fldNmeSql) || ''','''
  //             || trim(fldTyp) || ''','
  //             || fldLen || ','
  //             || fldScl || ','
  //             || fldAlc || ','''
  //             || trim(replace(colTxt,'''','''''')) || '''' as dta
  //     From DCTFLD
  //     Where dctNme = 'APLDCT'
  //   ),
  //   line2 as (
  //     Select
  //       dctNme,
  //       fldNme,
  //       2 as lneSeq,
  //       '         ,''' || trim(replace(colHdg,'''','''''')) || ''','''
  //             || trim(pcdFlg) || ''','''
  //             || trim(fldpmp) || ''','''
  //             || trim(alwNul) || ''','''
  //             || trim(replace(dftVal,'''','''''')) || ''','''
  //             || trim(fldEnm) || '''),' as dta
  //     From DCTFLD
  //     Where dctNme = 'APLDCT'
  //   )
  // Select dta
  // from (
  //   Select * From Line1
  //   Union All
  //   Select * From Line2
  // )
  // Order by dctNme,FldNme, lneSeq;
  Exec SQL
Merge into APLLIB.DCTFLD as Target
Using(
  Values
('APLDCT','AARFLR','auto_archive_folder','CHAR',128,0,0,'Auto Archive Folder'
         ,'Auto Archive Folder','','','','',''),
('APLDCT','ABCFLEIDN','test_file_id','BIGINT',0,0,0,'Test file Id'
         ,'test                file                Id','','','','',''),
('APLDCT','ACGCDE','accounting_code','CHAR',15,0,0,'Accounting Code'
         ,'Accounting Code','','','','',''),
('APLDCT','ACTCDE','action_code','CHAR',2,0,0,'Action Code'
         ,'Action              Code','','','','',''),
('APLDCT','ACVDES','active_description','CHAR',8,0,0,'Active Description'
         ,'Active              Desc','','','','',''),
('APLDCT','ACVROW','active_row','CHAR',1,0,0,'Active Row'
         ,'Active              Row','0','','','''1''','Y'),
('APLDCT','AFTVAL','after_value','VARCHAR',100,0,50,'After Value'
         ,'After               Value','','','','',''),
('APLDCT','ALWALC','allow_allocation','CHAR',1,0,0,'Allow Allocation'
         ,'Allow               Allocation','','Allow Allocation','N','','Y'),
('APLDCT','ALWARC','allow_archive','CHAR',1,0,0,'Allow Archive'
         ,'Allow Archive','','','','','Y'),
('APLDCT','ALWDEC','allow_decimal_positions','CHAR',1,0,0,'Allow Decimal Positions'
         ,'Allow1              Decimal             Positions','','Allow Dec Positions','N','','Y'),
('APLDCT','ALWEML','allow_email','CHAR',1,0,0,'Allow Email'
         ,'Allow Email','','','','','Y'),
('APLDCT','ALWFAX','allow_fax','CHAR',1,0,0,'AllowFax'
         ,'AllowFax','','','','','Y'),
('APLDCT','ALWINQ','allow_inquiry','CHAR',1,0,0,'Allow Inquiry'
         ,'Allow                Inquiry','0','','','',''),
('APLDCT','ALWLEN','allow_length','CHAR',1,0,0,'Allow Length'
         ,'Allow               Length','','Allow Length','N','','Y'),
('APLDCT','ALWMNT','allow_maintenance','CHAR',1,0,0,'Allow Maintenance'
         ,'Allow               Maintenance','0','','','',''),
('APLDCT','ALWNUL','allow_null','CHAR',1,0,0,'Allow Null'
         ,'Allow               Null','0','','','',''),
('APLDCT','ALWSEL','allow_select','CHAR',1,0,0,'Allow Select'
         ,'Allow               Select','0','','','',''),
('APLDCT','APL','application','CHAR',3,0,0,'Application'
         ,'Application','','','','','Y'),
('APLDCT','APLLIBIDN','fabric_library_id','BIGINT',0,0,0,'Fabric Library ID'
         ,'Fabric              Library             Id','','','','',''),
('APLDCT','ARCFLR','archive_folder','CHAR',128,0,0,'Archive Folder'
         ,'Archive Folder','','','','',''),
('APLDCT','ARCOUT','archive_output','CHAR',1,0,0,'Archive Output'
         ,'Archive Output','','','','','Y'),
('APLDCT','ATAFMT','attachment_format','CHAR',1,0,0,'Attachment Format'
         ,'Attachment Format','','','','','Y'),
('APLDCT','ATANME','attachment_name','CHAR',128,0,0,'Attachment Name'
         ,'Attachment Name','','','','',''),
('APLDCT','ATATYP','attachment_type','CHAR',5,0,0,'Attachment Type'
         ,'Attachment Type','','','','','Y'),
('APLDCT','AUDFLD','auit_field','CHAR',1,0,0,'Audit Field'
         ,'Audit Field','','','','','Y'),
('APLDCT','AUDLOGIDN','file_audit_log_id','BIGINT',0,0,0,'File Audit Log Id'
         ,'File                Audit               Log Id','','','','',''),
('APLDCT','AUTOPT','auto_display_output_options','CHAR',1,0,0,'Auto Display Output Options'
         ,'Auto Display Output Options','','','','',''),
('APLDCT','BCCEML','bcc_email_address','CHAR',60,0,0,'BCC Email Address'
         ,'BCC Email Address','','','','',''),
('APLDCT','BCCNME','bcc_email_name','CHAR',30,0,0,'BCC Email Name'
         ,'BCC Email Name','','','','',''),
('APLDCT','BEGDTE','beginning_date','DATE',0,0,0,'Beginning Date'
         ,'Begin               Date','','','','',''),
('APLDCT','BEGDTE8','beginning_date_yyyymmdd','DECIMAL',8,0,0,'Beginning Date YYYYMMDD'
         ,'Beginning           Date                YYYYMMDD','','','','',''),
('APLDCT','BFRVAL','before_value','VARCHAR',100,0,50,'Before Value'
         ,'Before              Value','','','','',''),
('APLDCT','CC1EML','cc_email_address_1','CHAR',60,0,0,'CC Email Address 1'
         ,'CC Email Address 1','','','','',''),
('APLDCT','CC1NME','cc_email_name_1','CHAR',30,0,0,'CC Email Name 1'
         ,'CC Email Name 1','','','','',''),
('APLDCT','CC2EML','cc_email_address_2','CHAR',60,0,0,'CC Email Address 2'
         ,'CC Email Address 2','','','','',''),
('APLDCT','CC2NME','cc_email_name_2','CHAR',30,0,0,'CC Email Name 2'
         ,'CC Email Name 2','','','','',''),
('APLDCT','CC3EML','cc_email_address_3','CHAR',60,0,0,'CC Email Address 3'
         ,'CC Email Address 3','','','','',''),
('APLDCT','CC3NME','cc_email_name_','CHAR',30,0,0,'CC Email Name 3'
         ,'CC Email Name 3','','','','',''),
('APLDCT','CHGSCD','change_scheduled','CHAR',1,0,0,'Change Scheduled'
         ,'Change              Scheduled','','','','','Y'),
('APLDCT','CHKBJBIDN','check_batch_job_id','BIGINT',0,0,0,'Check Batch Job Id'
         ,'Check Batch         Job                 Id','','','','',''),
('APLDCT','CLNKEYWRD','clean_key_word','CHAR',20,0,0,'Clean Key Word'
         ,'Clean               Key                 Word','','','','',''),
('APLDCT','CLNSRCIDN','clean_source_id','BIGINT',0,0,0,'Clean Source ID'
         ,'Clean               Source              ID','','','','',''),
('APLDCT','CMPDES','comparison_description','CHAR',30,0,0,'Comparison Description'
         ,'Comparison Description','','','','',''),
('APLDCT','CMTEXS','comment_exists','CHAR',1,0,0,'Comment Exists'
         ,'Comment             Exists','','','','',''),
('APLDCT','CNFEXS','conflicts_exist','CHAR',1,0,0,'Conflicts Exist'
         ,'Conflicts            Exist','','','','','Y'),
('APLDCT','COLHDG','column_heading','CHAR',60,0,0,'Column Heading'
         ,'Column              Heading','0','','','',''),
('APLDCT','COLHDGSEG','column_heading_for_a_segment','CHAR',20,0,0,'Column Heading for a Segment'
         ,'Column              Heading             For Segment','','','','',''),
('APLDCT','COLTXT','column_text','CHAR',50,0,0,'Column Text'
         ,'Column              Text','0','','','',''),
('APLDCT','CRTDTM','create_time_stamp','TIMESTAMP',0,0,0,'Create Date/Time (Time stamp)'
         ,'Create              Date','0','','','CURRENT_TIMESTAMP',''),
('APLDCT','CRTJOB','create_job','CHAR',28,0,0,'Create Job'
         ,'Create              Job','0','','','',''),
('APLDCT','CRTNBR','create_job_number','CHAR',6,0,0,'Create Job Number'
         ,'Create              Job                 Number','','','','',''),
('APLDCT','CRTPGM','create_program','CHAR',10,0,0,'Create Program'
         ,'Create              Program','0','','','',''),
('APLDCT','CRTSTR','create_string','CHAR',70,0,0,'Create String'
         ,'Create String','','','','',''),
('APLDCT','CRTUSR','create_user','CHAR',18,0,0,'Create User'
         ,'Create              User','0','','','USER',''),
('APLDCT','CRTXMA','create_xml_attribute_file','CHAR',1,0,0,'Create XML Attribute File'
         ,'Create XML Attribute File','','','','','Y'),
('APLDCT','CSTNME','contraint_name','CHAR',30,0,0,'Contraint Name'
         ,'Contraint           Name','','','','',''),
('APLDCT','CSTTYP','constraint_type','CHAR',11,0,0,'Constraint Type'
         ,'Constraint          Type','','','','',''),
('APLDCT','DCTFLDIDN','dictionary_field_id','BIGINT',0,0,0,'Dictionary Field ID'
         ,'Dictionary          Field               Id','','','','',''),
('APLDCT','DCTMSTIDN','dictionary_master_id','BIGINT',0,0,0,'Dictionary Master ID'
         ,'Dictionary          Master              Id','','','','',''),
('APLDCT','DCTNME','dictionary_name','CHAR',10,0,0,'Dictionary Name'
         ,'Dictionary          Name','0','','N','',''),
('APLDCT','DCTSEGIDN','dictionary_segment_id','BIGINT',0,0,0,'Dictionary Segment ID'
         ,'Dictionary          Segment             Id','','','','',''),
('APLDCT','DCTVALIDN','dictionary_value_id','BIGINT',0,0,0,'Dictionary Value Id'
         ,'Dictionary          Value               Id','','','','',''),
('APLDCT','DES','description','CHAR',40,0,0,'Description'
         ,'Description','','Desc','N','',''),
('APLDCT','DEVUSR','development_user','CHAR',10,0,0,'Development User'
         ,'Development         User','','','','',''),
('APLDCT','DFTAUT','default_authorization','CHAR',1,0,0,'Default Authorization'
         ,'Default             Authorization','','','','','Y'),
('APLDCT','DFTVAL','default_value','CHAR',60,0,0,'Default Value'
         ,'Default             Value','0','','','',''),
('APLDCT','DSPFLE','display_file','CHAR',10,0,0,'Display File'
         ,'Display             File','','','','',''),
('APLDCT','DSTPTH','destination_path','VARCHAR',132,0,30,'Destination Path'
         ,'Destination         Path','','','','',''),
('APLDCT','DTASEG','data_segment','CHAR',3,0,0,'Data Segment'
         ,'Data                Segment','','','N','',''),
('APLDCT','DVW','display_view','CHAR',1,0,0,'Display View'
         ,'Display             View','','','','1',''),
('APLDCT','EDTCDE','edit_code','CHAR',1,0,0,'Edit Code'
         ,'Edit                Code','0','','','',''),
('APLDCT','EDTWRD','edit_word','CHAR',28,0,0,'Edit Word'
         ,'Edit                Word','0','','','',''),
('APLDCT','EML','email_','CHAR',50,0,0,'Email'
         ,'Email','','Email','','',''),
('APLDCT','EMLADD','email_address','CHAR',60,0,0,'Email Address'
         ,'Email Address','','','','',''),
('APLDCT','EMLMSG01','email_message_1','CHAR',75,0,0,'Email Message 1'
         ,'Email Message 1','','','','',''),
('APLDCT','EMLMSG02','email_message_2','CHAR',75,0,0,'Email Message 2'
         ,'Email Message 2','','','','',''),
('APLDCT','EMLMSG03','email_message_3','CHAR',75,0,0,'Email Message 3'
         ,'Email Message 3','','','','',''),
('APLDCT','EMLMSG04','email_message_4','CHAR',75,0,0,'Email Message 4'
         ,'Email Message 4','','','','',''),
('APLDCT','EMLMSG05','email_message_5','CHAR',75,0,0,'Email Message 5'
         ,'Email Message 5','','','','',''),
('APLDCT','EMLMSG06','email_message_6','CHAR',75,0,0,'Email Message 6'
         ,'Email Message 6','','','','',''),
('APLDCT','EMLMSG07','email_message_7','CHAR',75,0,0,'Email Message 7'
         ,'Email Message 7','','','','',''),
('APLDCT','EMLMSG08','email_message_8','CHAR',75,0,0,'Email Message 8'
         ,'Email Message 8','','','','',''),
('APLDCT','EMLMSG09','email_message_9','CHAR',75,0,0,'Email Message 9'
         ,'Email Message 9','','','','',''),
('APLDCT','EMLMSG10','email_message_10','CHAR',75,0,0,'Email Message 10'
         ,'Email Message 10','','','','',''),
('APLDCT','EMLMSG11','email_message_11','CHAR',75,0,0,'Email Message 11'
         ,'Email Message 11','','','','',''),
('APLDCT','EMLMSG12','email_message_12','CHAR',75,0,0,'Email Message 12'
         ,'Email Message 12','','','','',''),
('APLDCT','EMLNME','email_name','CHAR',30,0,0,'Email Name'
         ,'Email Name','','','','',''),
('APLDCT','EMLOUT','email_output','CHAR',1,0,0,'Email Output'
         ,'Email Output','','','','','Y'),
('APLDCT','EMLSBJ','email_subject','CHAR',60,0,0,'Email Subject'
         ,'Email Subject','','','','',''),
('APLDCT','EMPNBR','employee_number','CHAR',10,0,0,'Employee Number'
         ,'Employee Number','','','','',''),
('APLDCT','ENCFLD','encrypt_field','CHAR',1,0,0,'Encrypt Field'
         ,'Encrypt Field','','','','','Y'),
('APLDCT','ENDCHR','end_character','CHAR',1,0,0,'End Character'
         ,'End Character','','','','',''),
('APLDCT','ENDDTE','ending_date','DATE',0,0,0,'Ending Date'
         ,'Ending              Date','','','','',''),
('APLDCT','ENDDTE8','ending_date_yyyymmdd','DECIMAL',8,0,0,'Ending Date YYYYMMDD'
         ,'Ending              Date                YYYYMMDD','','','','',''),
('APLDCT','ENMDES','enumerated_description','CHAR',40,0,0,'Enumerated Description'
         ,'Enumerated          Description','0','','N','',''),
('APLDCT','ENMVAL','enumerated_value','CHAR',10,0,0,'Enumerated Value'
         ,'Enumerated          Value','0','','N','',''),
('APLDCT','ERRMSG','error_message','VARCHAR',1000,0,100,'Error Message'
         ,'Error               Message','','','','',''),
('APLDCT','ERRTYP','error_type','CHAR',1,0,0,'Error Type'
         ,'Error               Type','','','','',''),
('APLDCT','EXTTYP','extended_type','CHAR',10,0,0,'Extended Type'
         ,'Extended            Type','','','','',''),
('APLDCT','FAXNBR','fax_number','CHAR',20,0,0,'Fax Number'
         ,'Fax Number','','','','',''),
('APLDCT','FAXOUT','fax_output','CHAR',1,0,0,'Fax Output'
         ,'Fax Output','','','','','Y'),
('APLDCT','FLDALC','field_allocation','DECIMAL',5,0,0,'Field Allocation'
         ,'Field               Allocation','0','','','',''),
('APLDCT','FLDCNT','field_count','DECIMAL',5,0,0,'Field Count'
         ,'Field               Count','','','','',''),
('APLDCT','FLDCOL','field_column','DECIMAL',3,0,0,'Field Column'
         ,'Field               Column','','','','',''),
('APLDCT','FLDENM','field_enumerated','CHAR',1,0,0,'Field Enumerated'
         ,'Field               Enumerated','0','','N','','Y'),
('APLDCT','FLDIDN','field_id_numbercode','BIGINT',0,0,0,'Field ID Number/Code'
         ,'Field               ID                  Number/Code','','','','',''),
('APLDCT','FLDLEN','field_length','DECIMAL',5,0,0,'Field Length'
         ,'Field               Length','0','','','',''),
('APLDCT','FLDLVL','field_level','CHAR',1,0,0,'Field Level'
         ,'Field               Level','','','','','Y'),
('APLDCT','FLDNME','field_name','CHAR',10,0,0,'Field Name'
         ,'Field               Name','0','','','',''),
('APLDCT','FLDNMESQL','field_name_sql','CHAR',30,0,0,'Field Name SQL Version (long name)'
         ,'Field               Name                SQL','','','','',''),
('APLDCT','FLDNTEIDN','field_note_id','BIGINT',0,0,0,'Field Note Id'
         ,'Field               Note                Id','','','','',''),
('APLDCT','FLDPMP','field_prompt_text','CHAR',20,0,0,'Field Prompt Text'
         ,'Field               Prompt              TEXT','0','','','',''),
('APLDCT','FLDROW','field_row','DECIMAL',3,0,0,'Field Row'
         ,'Field               Row','','','','',''),
('APLDCT','FLDSCL','field_scale','DECIMAL',2,0,0,'Field Scale'
         ,'Field               Scale','0','','','',''),
('APLDCT','FLDSEQ','field_sequence','DECIMAL',7,0,0,'Field Sequence'
         ,'Field               Sequence','','','','',''),
('APLDCT','FLDSTS','field_status','CHAR',1,0,0,'Field Status'
         ,'Field               Status','','','','','Y'),
('APLDCT','FLDTYP','field_','CHAR',14,0,0,'Field'
         ,'Field               Type','0','','','','Y'),
('APLDCT','FLDTYPIDN','field_type_id','BIGINT',0,0,0,'Field Type ID'
         ,'Field               Type                Id','','','','',''),
('APLDCT','FLE','file_','CHAR',10,0,0,'File'
         ,'File','','','','',''),
('APLDCT','FLEDES','file_description','CHAR',50,0,0,'File Description'
         ,'File                Description','','','','',''),
('APLDCT','FLEERR','file_error','CHAR',1,0,0,'File Error'
         ,'File                Error','','','','','Y'),
('APLDCT','FLEERRIDN','file_errors_id','BIGINT',0,0,0,'File Errors Id'
         ,'File                Errors              Id','','','','',''),
('APLDCT','FLEFLDIDN','file_field_id','BIGINT',0,0,0,'File Field ID'
         ,'File                Field               Id','','','','',''),
('APLDCT','FLEIDN','file_idn','BIGINT',0,0,0,'File IDN'
         ,'File                IDN','','','','',''),
('APLDCT','FLEIDXIDN','file_index_id','BIGINT',0,0,0,'File Index ID'
         ,'File                Index               Id','','','','',''),
('APLDCT','FLELIB','file_library','CHAR',10,0,0,'File Library'
         ,'File                Library','','','','',''),
('APLDCT','FLELOGIDN','file_log_id','BIGINT',0,0,0,'File Log ID'
         ,'File                Log                 Id','','','','',''),
('APLDCT','FLEMSTIDN','file_id','BIGINT',0,0,0,'File Master ID'
         ,'File                Master              Id','','','','',''),
('APLDCT','FLENME','file_name','CHAR',10,0,0,'File Name'
         ,'File                Name','','','','',''),
('APLDCT','FLENTEIDN','file_note_id','BIGINT',0,0,0,'File Note ID Number'
         ,'File Note           Note                Id','','','','',''),
('APLDCT','FLESTS','file_status','CHAR',1,0,0,'File Status'
         ,'File                Status','','','','','Y'),
('APLDCT','FLETYP','file_type','CHAR',6,0,0,'File Type'
         ,'File                Type','','','','',''),
('APLDCT','FLT','filter_','VARCHAR',2048,0,256,'Filter'
         ,'Filter','0','','N','',''),
('APLDCT','FNCDES','function_description','CHAR',50,0,0,'Function Description'
         ,'Function            Description','','','','',''),
('APLDCT','FNCKEY','function_key','CHAR',10,0,0,'Function Key'
         ,'Function            Key','0','','N','',''),
('APLDCT','FNCNME','function_name','CHAR',20,0,0,'Function Name'
         ,'Function            Name','','','','',''),
('APLDCT','FNCTYP','function_type','CHAR',8,0,0,'Function Type'
         ,'Function            Type','','','','',''),
('APLDCT','FRCLEN','force_length','CHAR',1,0,0,'Force Length'
         ,'Force               Length','','','','','Y'),
('APLDCT','FRCLEN1','force_length_1','INTEGER',0,0,0,'Force Length 1'
         ,'Force               Length 1','','','','',''),
('APLDCT','FRCLEN2','force_length_2','INTEGER',0,0,0,'Force Length 2'
         ,'Force               Length 2','','','','',''),
('APLDCT','FRCLEN3','force_length_3','INTEGER',0,0,0,'Force Length 3'
         ,'Force               Length 3','','','','',''),
('APLDCT','FRCLEN4','force_length_4','INTEGER',0,0,0,'Force Length 4'
         ,'Force               Length 4','','','','',''),
('APLDCT','FRCLEN5','force_length_5','INTEGER',0,0,0,'Force Length 5'
         ,'Force               Length 5','','','','',''),
('APLDCT','FRMEML','from_email_address','CHAR',60,0,0,'From Email Address'
         ,'From Email Address','','','','',''),
('APLDCT','FRMLIB','from_library','CHAR',10,0,0,'From Library'
         ,'From                Library','','','','',''),
('APLDCT','FRMNME','from_email_name','CHAR',30,0,0,'From Email Name'
         ,'From Email Name','','','','',''),
('APLDCT','FRMPTH','from_path','VARCHAR',132,0,30,'From Path'
         ,'From                Path','','','','',''),
('APLDCT','FRMTYP','form_type','CHAR',10,0,0,'Form Type'
         ,'Form Type','','','','',''),
('APLDCT','FSTNME','first_name','VARCHAR',20,0,0,'First Name'
         ,'First Name','','','','',''),
('APLDCT','GRPPRF','group_profile','CHAR',10,0,0,'Group Profile'
         ,'Group Profile','','','','',''),
('APLDCT','HGT','height_','DECIMAL',5,2,0,'Height'
         ,'Height','','','','',''),
('APLDCT','HLDOUT','hold_output','CHAR',5,0,0,'Hold Output'
         ,'Hold Output','','','','','Y'),
('APLDCT','HLPCNT','help_count','DECIMAL',6,0,0,'Help Count'
         ,'Help                Count','','','','',''),
('APLDCT','HLPDTLIDN','help_detail_id','BIGINT',0,0,0,'Help Detail Id'
         ,'Help                Detail              Id','','','','',''),
('APLDCT','HLPMSTIDN','help_master_id','BIGINT',0,0,0,'Help Master Id'
         ,'Help                Master              Id','','','','',''),
('APLDCT','HLPREF','help_reference','CHAR',10,0,0,'Help Reference'
         ,'Help                Reference','','','','',''),
('APLDCT','HLPTXT','help_text','CHAR',79,0,0,'Help Text'
         ,'Help                Text','','','N','',''),
('APLDCT','HLPTYP','help_type','CHAR',1,0,0,'Help Type'
         ,'Help                Type','','','','','Y'),
('APLDCT','IDN','unique_row_identifier','IDENTITY',0,0,0,'Unique Row Identifier'
         ,'Unique              Row                 Identifier','','','','',''),
('APLDCT','IDNICM','id_increment','BIGINT',0,0,0,'ID increment'
         ,'ID                  increment','','','','',''),
('APLDCT','IDXCNT','index_count','DECIMAL',5,0,0,'Index Count'
         ,'Index               Count','','','','',''),
('APLDCT','IDXFLD','file_index_field','CHAR',10,0,0,'File Index Field'
         ,'File                Index               Field','','','','',''),
('APLDCT','IDXFLDIDN','index_field_id','BIGINT',0,0,0,'Index Field ID'
         ,'Index               Field               Id','','','','',''),
('APLDCT','IDXLIB','index_library','CHAR',10,0,0,'Index Library'
         ,'Index               Library','','','','',''),
('APLDCT','IDXNME','index_name','CHAR',10,0,0,'Index Name'
         ,'Index               Name','','','','',''),
('APLDCT','IDXSEQ','index_field_sequence','DECIMAL',7,0,0,'Index Field Sequence'
         ,'Index               Field               Sequence','','','','',''),
('APLDCT','IDXTXT','index_text','CHAR',50,0,0,'Index Text'
         ,'Index               Text','','','','',''),
('APLDCT','IDXUNI','index_unique','CHAR',1,0,0,'Index Unique'
         ,'Index               Unique','','','','','Y'),
('APLDCT','IFMDRVIDN','ifs_monitor_driver_id','BIGINT',0,0,0,'IFS Monitor Driver Id'
         ,'IFS Monitor         Driver              Id','','','','',''),
('APLDCT','IFMLOGIDN','ifs_monitor_log_id','BIGINT',0,0,0,'IFS Monitor Log Id'
         ,'IFS Monitor         Log                 Id','','','','',''),
('APLDCT','IFMSTS','ifs_monitor_status','CHAR',1,0,0,'IFS Monitor Status'
         ,'IFS                 Monitor             Status','','','','','Y'),
('APLDCT','INT','integer_','INTEGER',0,0,0,'Integer'
         ,'Integer','','','','',''),
('APLDCT','INVLOCIDN','invoice_loc_id','BIGINT',0,0,0,'Invoice Loc Id'
         ,'Invoice             Loc                 Id','','','','',''),
('APLDCT','JOBNME','job_name','CHAR',10,0,0,'Job Name'
         ,'Job                 Name','','','','',''),
('APLDCT','JOBTTL','job_title','VARCHAR',50,0,50,'Job Title'
         ,'Job                 Title','','','','',''),
('APLDCT','KEYWRD','key_word','CHAR',20,0,0,'Key Word'
         ,'Key                 Word','','','','',''),
('APLDCT','LEN','length_','DECIMAL',5,2,0,'Length'
         ,'Length','','','','',''),
('APLDCT','LIB','library_','CHAR',10,0,0,'Library'
         ,'Library','','','','',''),
('APLDCT','LIBDES','library_description','CHAR',50,0,0,'Library Description'
         ,'Library             Description','','','','',''),
('APLDCT','LIBNME','library_name','CHAR',10,0,0,'Library Name'
         ,'Library             Name','','','','',''),
('APLDCT','LIBSZE','library_size','DECIMAL',9,0,0,'Library Size'
         ,'Library             Size','','','','',''),
('APLDCT','LIBTYP','library_type','CHAR',1,0,0,'Library Type'
         ,'Library             Type','','','','','Y'),
('APLDCT','LNECNT','line_count','DECIMAL',5,0,0,'Line Count'
         ,'Line                Count','','','','',''),
('APLDCT','LNGCMT','long_comment','VARCHAR',250,0,0,'Long Comment'
         ,'Long Comment','','','','',''),
('APLDCT','LOGDES','log_description','CHAR',50,0,0,'Log Description'
         ,'Log                 Description','','','','',''),
('APLDCT','LOGMSG','log_message','VARCHAR',5000,0,100,'Log Message'
         ,'Log                 Message','','','','',''),
('APLDCT','LOGTYP','log_type','CHAR',20,0,0,'Log Type'
         ,'Log                 Type','','','','',''),
('APLDCT','LRGVAL','largest_value','DECIMAL',63,0,0,'Largest Value'
         ,'Largest             Value','','','','',''),
('APLDCT','LSTNME','last_name','VARCHAR',20,0,0,'Last Name'
         ,'Last Name','','','','',''),
('APLDCT','MAXLEN','maximum_lenght','BIGINT',0,0,0,'Maximum Length'
         ,'Maximum             Length','','','','',''),
('APLDCT','MBR','member_','CHAR',10,0,0,'Member'
         ,'Member','','','','',''),
('APLDCT','MDE','mode_','CHAR',10,0,0,'Mode'
         ,'Mode','','','','',''),
('APLDCT','MNTDTM','maintenance_time_stamp','TIMESTAMP',0,0,0,'Maintenance Date'
         ,'Maintenance         Date','0','','','CURRENT_TIMESTAMP',''),
('APLDCT','MNTJOB','maintenance_job','CHAR',28,0,0,'Maintenance Job'
         ,'Maintenance         Job','0','','','',''),
('APLDCT','MNTPGM','maintenance_program','CHAR',10,0,0,'Maintenance Program'
         ,'Maintenance         Program','0','','','',''),
('APLDCT','MNTSTR','maintenance_string','CHAR',70,0,0,'Maintenance String'
         ,'Maintenance String','','','','',''),
('APLDCT','MNTUSR','maintenance_user','CHAR',18,0,0,'Maintenance User'
         ,'Maintenance         User','0','','','USER',''),
('APLDCT','MNUNME','menu_name','CHAR',50,0,0,'Menu Name'
         ,'Menu                Name','','','','',''),
('APLDCT','MNUOBJ','menu_object','CHAR',1,0,0,'Menu Object'
         ,'Menu                Object','','','','','Y'),
('APLDCT','MSDLEN','message_data_length','CHAR',5,0,0,'Message Data Length'
         ,'Message             Data                Length','','','','',''),
('APLDCT','MSDLNE','message_file_data_line_number','CHAR',5,0,0,'Message File Data Line Number'
         ,'Msg                 Data                Line','','','','',''),
('APLDCT','MSDTYP','message_data_type_substitution','CHAR',8,0,0,'Message Data Type (substitutions)'
         ,'Message             Data                Type','','','','','Y'),
('APLDCT','MSDVRY','message_data_varying_length','DECIMAL',5,0,0,'Message Data Varying Length'
         ,'Message             Data                Vary Len','','','','',''),
('APLDCT','MSFDES','message_file_description','CHAR',40,0,0,'Message File Description'
         ,'Message             File                Description','','','','',''),
('APLDCT','MSFLIB','message_file_library','CHAR',10,0,0,'Message File Library'
         ,'Message             File                Library','','','','',''),
('APLDCT','MSFNME','message_file_name','CHAR',10,0,0,'Message File Name'
         ,'Message             File                Name','','','','','Y'),
('APLDCT','MSGDES','message_description','CHAR',79,0,0,'Message Description'
         ,'Message             Description','','','','',''),
('APLDCT','MSGIDN','message_identification_number','CHAR',7,0,0,'Message Identification Number'
         ,'Message             Number','','','','',''),
('APLDCT','MSGTXT','message_text','VARCHAR',1040,0,20,'Message Text'
         ,'Message             TExt','','','','',''),
('APLDCT','NATTYP','native_type','CHAR',10,0,0,'Native Type'
         ,'Native              Type','','','','',''),
('APLDCT','NBRCPY','number_of_copies','CHAR',3,0,0,'Number of Copies'
         ,'Number of Copies','','','','',''),
('APLDCT','NMR','is_numeric','CHAR',2,0,0,'is Numeric'
         ,'Numeric','','Numeric','','','Y'),
('APLDCT','NTE','note_','CHAR',60,0,0,'Note'
         ,'Note','','Note','','',''),
('APLDCT','NTEEXS','note_exists','CHAR',1,0,0,'Note Exists'
         ,'Note                Exists','','','','',''),
('APLDCT','NTEKEY','note_key','CHAR',10,0,0,'Note Key'
         ,'Note                Key','','','','',''),
('APLDCT','NTESEQ','note_sequence','DECIMAL',7,0,0,'Note Sequence'
         ,'Note                Sequence','','','','',''),
('APLDCT','OBJATR','object_attribute','CHAR',10,0,0,'Object Attribute'
         ,'Object              Attribute','','','','','Y'),
('APLDCT','OBJAUTLST','object_authorization_list','CHAR',10,0,0,'Object Authorization List'
         ,'Object              Authorization       List','','','','','Y'),
('APLDCT','OBJLIB','object_library','CHAR',10,0,0,'Object library'
         ,'Object              Library','','','','',''),
('APLDCT','OBJNME','object_name','CHAR',10,0,0,'Object Name'
         ,'Object              Name','','','','',''),
('APLDCT','OBJOWN','object_owner','CHAR',10,0,0,'Object Owner'
         ,'Object              Owner','','','','''QPGMR''',''),
('APLDCT','OBJTYP','object_type','CHAR',10,0,0,'Object Type'
         ,'Object              Type','','','','',''),
('APLDCT','OPT','sfl_option','NUMERIC',2,0,0,'SFL Option'
         ,'SFL                 Option','','','','',''),
('APLDCT','OPTION','option_','CHAR',2,0,0,'Option'
         ,'Option','','','','','Y'),
('APLDCT','OTOEML','output_options_email','CHAR',50,0,0,'Output Options Email'
         ,'Output Options Email','','','','',''),
('APLDCT','OTONME','output_options_name','CHAR',50,0,0,'Output Options Name'
         ,'Output Options Name','','','','',''),
('APLDCT','OTQLIB','ouput_queue_library','CHAR',10,0,0,'Ouput Queue Library'
         ,'Ouput Queue Library','','','','',''),
('APLDCT','OTQMSTIDN','output_queue_id','BIGINT',0,0,0,'Output Qqueue Id'
         ,'Output Qqueue Id','','','','',''),
('APLDCT','OTQNME','output_queue_name','CHAR',10,0,0,'Output Queue Name'
         ,'Output Queue Name','','','','',''),
('APLDCT','OUTMDL','output_model','CHAR',2,0,0,'Output Model'
         ,'Output Model','','','','',''),
('APLDCT','PCDFLG','processed_flag','CHAR',1,0,0,'Processed Flag'
         ,'Processed           Flag','0','','','',''),
('APLDCT','PCYNBR','policy_number','CHAR',10,0,0,'Policy Number'
         ,'Policy Number','','','','',''),
('APLDCT','PGELEN','page_length','CHAR',3,0,0,'Page Length'
         ,'Page Length','','','','',''),
('APLDCT','PGEWID','page_width','CHAR',3,0,0,'Page Width'
         ,'Page Width','','','','',''),
('APLDCT','PGMACTIDN','program_action_id','BIGINT',0,0,0,'Program Action Id'
         ,'Program             Action              Id','','','','',''),
('APLDCT','PGMDES','program_description','CHAR',50,0,0,'Program Description'
         ,'Program             Description','','','','',''),
('APLDCT','PGMFNCIDN','program_function_id','BIGINT',0,0,0,'Program Function Id'
         ,'Program             Function            Id','','','','',''),
('APLDCT','PGMMSTIDN','program_master_id','BIGINT',0,0,0,'Program Master Id'
         ,'Program             Master              Id','','','','',''),
('APLDCT','PGMNME','program_name','CHAR',10,0,0,'Program Name'
         ,'Program             Name','','','','',''),
('APLDCT','PGMOPTIDN','program_options_id','BIGINT',0,0,0,'Program Option Id'
         ,'Program             Option              Id','','','','',''),
('APLDCT','PGMTYP','program_type','CHAR',1,0,0,'Program Type'
         ,'Program             Type','','','','','Y'),
('APLDCT','PGMUDFIDN','program_user_default_id','BIGINT',0,0,0,'Program User Default Id'
         ,'Program User        Default             Id','','','','',''),
('APLDCT','PHNEXT','phone_extension','CHAR',6,0,0,'Phone Extension'
         ,'Phone Extension','','','','',''),
('APLDCT','PHNNBR','phone_number','CHAR',12,0,0,'Phone Number'
         ,'Phone Number','','','','',''),
('APLDCT','PRCDES','procedure_description','CHAR',50,0,0,'Procedure Description'
         ,'Procedure           Description','','','','',''),
('APLDCT','PRCNME','procedure_name','CHAR',10,0,0,'Procedure Name'
         ,'Procedure           Name','','','','',''),
('APLDCT','PRCTYP','procedure_type','CHAR',7,0,0,'Procedure Type'
         ,'Procedure           Type','','','','',''),
('APLDCT','PRDFLE','production_file','CHAR',1,0,0,'Production File'
         ,'Production          File','','','','','Y'),
('APLDCT','PRIKEY','primary_key','CHAR',1,0,0,'Primary Key'
         ,'Primary             Key','','','','','Y'),
('APLDCT','PRJNBR','project_number','CHAR',10,0,0,'Project Number'
         ,'Project             Number','0','','','',''),
('APLDCT','PRTDEV','print_device','CHAR',10,0,0,'Print Device'
         ,'Print Device','','','','',''),
('APLDCT','PRTFLE','printer_file','CHAR',10,0,0,'Printer File'
         ,'Printer File','','','','',''),
('APLDCT','PRTFRM','printer_form','CHAR',10,0,0,'Printer Form'
         ,'Printer Form','','','','',''),
('APLDCT','PRTOTQ','print_output_queue','CHAR',10,0,0,'Print Output Queue'
         ,'Print Output Queue','','','','',''),
('APLDCT','PRTOUT','print_output','CHAR',1,0,0,'Print Output'
         ,'Print Output','','','','','Y'),
('APLDCT','PRTOVL','printer_overlay','CHAR',10,0,0,'Printer Overlay'
         ,'Printer Overlay','','','','',''),
('APLDCT','PRTQUL','print_quality','CHAR',10,0,0,'Print Quality'
         ,'Print Quality','','','','','Y'),
('APLDCT','PRTTYP','printer_type','CHAR',10,0,0,'Printer Ttype'
         ,'Printer Ttype','','','','',''),
('APLDCT','PSTBCH','post_batch','BIGINT',0,0,0,'Post Batch'
         ,'Post Batch','','','','',''),
('APLDCT','PSTFLG','post_flag','CHAR',1,0,0,'Post Flag'
         ,'Post Flag','','','','','Y'),
('APLDCT','PSTFLR','post_folder','CHAR',128,0,0,'Post Folder'
         ,'Post Folder','','','','',''),
('APLDCT','PTH','path_','CHAR',100,0,0,'Path'
         ,'Path                Path','','','','',''),
('APLDCT','PURABCIDN','purchasing_abc_inventory_class','BIGINT',0,0,0,'Purchasing ABC - Inventory Class Id'
         ,'Purchasing          ABC Class           ID','','','','',''),
('APLDCT','RCDFMT','record_format','CHAR',10,0,0,'Record Format'
         ,'Record              Format','','','','',''),
('APLDCT','RCDFMTTYP','record_format_type','CHAR',10,0,0,'Record Format Type'
         ,'Record              Format              Type','','','','',''),
('APLDCT','RCDIDN','record_id','BIGINT',0,0,0,'Record Id'
         ,'Record              Id','','','','',''),
('APLDCT','REFFLD','reference_field','CHAR',10,0,0,'Reference Field'
         ,'Reference           Field','','','','',''),
('APLDCT','REFFLE','reference_file','CHAR',10,0,0,'Reference File'
         ,'Referrence          File','','','','',''),
('APLDCT','REFLIB','reference_library','CHAR',10,0,0,'Reference Library'
         ,'Reference           Library','','','','',''),
('APLDCT','REQALC','require_allocation','CHAR',1,0,0,'Require Allocation'
         ,'Require             Allocation','','','N','','Y'),
('APLDCT','REQDBA','required_database_administrato','CHAR',10,0,0,'Required Database Administrator'
         ,'Required            DB Admin','','','','',''),
('APLDCT','REQITR','required_it_requester','CHAR',10,0,0,'Required IT Requester'
         ,'Required            IT Requester','','','','',''),
('APLDCT','REQLEN','require_length','CHAR',1,0,0,'Require Length'
         ,'Require Length','','Require Length','N','','Y'),
('APLDCT','REQOWN','required_owner','CHAR',10,0,0,'Required Owner'
         ,'Required            Owner','','','','',''),
('APLDCT','ROLAPR','role_approved','CHAR',1,0,0,'Role Approved'
         ,'Role Approved','','','','','Y'),
('APLDCT','ROLAPRIDN','role_approval_id','BIGINT',0,0,0,'Role Approval Id'
         ,'Role Approval Id','','','','',''),
('APLDCT','ROLMSTIDN','role_master_id','BIGINT',0,0,0,'Role Master Id'
         ,'Role Master Id','','','','',''),
('APLDCT','ROLNME','role_name','CHAR',30,0,0,'Role Name'
         ,'Role Name','','','','',''),
('APLDCT','RPTTTL','report_title','CHAR',50,0,0,'Report Title'
         ,'Report Title','','','','',''),
('APLDCT','SAVOUT','save_output','CHAR',5,0,0,'Save Output'
         ,'Save Output','','','','','Y'),
('APLDCT','SBSLIB','sub_system_library','CHAR',10,0,0,'Sub System Library'
         ,'Sub                 System              Library','','','','',''),
('APLDCT','SBSNME','sub_system_name','CHAR',10,0,0,'Sub System Name'
         ,'Sub                 System              Name','','','','',''),
('APLDCT','SCHVAL','display_search_value','CHAR',40,0,0,'Display Search Value'
         ,'Display             Search              Value','','','','',''),
('APLDCT','SCRLOCIDN','screen_loc_id','BIGINT',0,0,0,'Screen Loc Id'
         ,'Screen              Loc                 Id','','','','',''),
('APLDCT','SCRSZE','screen_size','CHAR',1,0,0,'Screen Size'
         ,'Screen              Size','','','','','Y'),
('APLDCT','SECAUT','security_authorization','CHAR',10,0,0,'Security Authorization'
         ,'Security            Authorization','','','','',''),
('APLDCT','SECPGM','security_program','CHAR',10,0,0,'Security Program'
         ,'Security            Program','','','','',''),
('APLDCT','SEQNBR','sequence_number','SMALLINT',0,0,0,'Sequence Number'
         ,'Sequence            Number','','','','',''),
('APLDCT','SMLVAL','smallest_value','DECIMAL',63,0,0,'Smallest Value'
         ,'Smallest            Value','','','','',''),
('APLDCT','SQLTYP','sql_type','CHAR',10,0,0,'SQL Type'
         ,'SQL                 Type','','','','',''),
('APLDCT','SRCFLE','source_file','CHAR',10,0,0,'Source File'
         ,'Source              File','','','','',''),
('APLDCT','SRCLIB','source_library','CHAR',10,0,0,'Source Library'
         ,'Source              Library','','','','',''),
('APLDCT','SRCMBR','source_member','CHAR',10,0,0,'Source Member'
         ,'Source              Member','','','','',''),
('APLDCT','SRTCDE','sort_code','DECIMAL',2,0,0,'Sort Code'
         ,'Srt                 Cde','','','','',''),
('APLDCT','STRCMD','start_command','VARCHAR',256,0,50,'Start Command'
         ,'Start               Command','','','','',''),
('APLDCT','STRIDN','starting_id','BIGINT',0,0,0,'Starting ID'
         ,'Starting            ID','','','','',''),
('APLDCT','SYSLEN','system_length','DECIMAL',20,0,0,'System Length'
         ,'System              Length','','','','',''),
('APLDCT','SYSTYP','system_type','CHAR',10,0,0,'System Type'
         ,'System              Type','','','','',''),
('APLDCT','TBLNME','table_name','CHAR',50,0,0,'Table Name'
         ,'Table               Name','','','','',''),
('APLDCT','TBLTYP','table_type','CHAR',10,0,0,'Table Type'
         ,'Table               Type','','','','',''),
('APLDCT','TOTCNT','total_count','DECIMAL',6,0,0,'Total Count'
         ,'Total               Count','','','','',''),
('APLDCT','TRGADD','trigger_add','CHAR',1,0,0,'Trigger add'
         ,'Trigger             Add','','','','',''),
('APLDCT','TRGCNT','trigger_count','DECIMAL',5,0,0,'Trigger Count'
         ,'Trigger             Count','','','','',''),
('APLDCT','TRGDEL','trigger_delete','CHAR',1,0,0,'Trigger Delete'
         ,'Trigger             Delete','','','','',''),
('APLDCT','TRGFLE','trigger_file','CHAR',10,0,0,'Trigger File'
         ,'Trigger             File','','','','',''),
('APLDCT','TRGLIB','trigger_library','CHAR',10,0,0,'Trigger Library'
         ,'Trigger             Library','','','','',''),
('APLDCT','TRGNME','trigger_name','CHAR',10,0,0,'Trigger Name'
         ,'Trigger             Name','','','','',''),
('APLDCT','TRGPGM','trigger_program','CHAR',10,0,0,'Trigger Program'
         ,'Trigger             Program','','','','',''),
('APLDCT','TRGUPD','trigger_update','CHAR',1,0,0,'Trigger Update'
         ,'Trigger             Update','','','','',''),
('APLDCT','TSTFLEIDN','test_file_id','BIGINT',0,0,0,'Test File Id'
         ,'Test                File                Id','','','','',''),
('APLDCT','UDFDES','user_default_description','CHAR',60,0,0,'User Default Description'
         ,'User Default        Default             Description','','','','',''),
('APLDCT','UDFDFT','user_default_default_value','CHAR',20,0,0,'User Default Default Value'
         ,'User Default        Default             Value','','','','',''),
('APLDCT','UDFDPT','user_default_department','CHAR',10,0,0,'User Default Department'
         ,'User                Default             Department','','','','',''),
('APLDCT','UDFDTLIDN','user_default_detail_id','BIGINT',0,0,0,'User Default Detail Id'
         ,'User Default        Detail              Id','','','','',''),
('APLDCT','UDFKEY','user_default_key','CHAR',20,0,0,'User Default Key'
         ,'User                Default             Key','','','','',''),
('APLDCT','UDFMSTIDN','user_default_master_id','BIGINT',0,0,0,'User Default Master Id'
         ,'User Default        Master              Id','','','','',''),
('APLDCT','UDFOPT','user_default_option','CHAR',10,0,0,'User Default Option'
         ,'User Default        Default             Option','','','','',''),
('APLDCT','UDFUSR','user_default_user','CHAR',10,0,0,'User Default User'
         ,'User Default        Default             User','','','','',''),
('APLDCT','UDFVAL','user_default_value','CHAR',20,0,0,'User Default Value'
         ,'User Default        Default             Value','','','','',''),
('APLDCT','USR','user_','CHAR',10,0,0,'User'
         ,'User','','','','',''),
('APLDCT','USRAUT','program_user_authority','CHAR',6,0,0,'Program User Authority'
         ,'Program             User                Authority','','','','*OWNER','Y'),
('APLDCT','USRCLS','user_class','CHAR',10,0,0,'User Class'
         ,'User Class','','','','',''),
('APLDCT','USRCNF','user_configurable','CHAR',1,0,0,'User Configurable'
         ,'User                Configurable','','','','',''),
('APLDCT','USRDPT','user_department','VARCHAR',50,0,0,'User Department'
         ,'User Department','','','','',''),
('APLDCT','USRDTA','user_data','CHAR',10,0,0,'User Data'
         ,'User Data','','','','',''),
('APLDCT','USREML','user_email','CHAR',60,0,0,'User Email'
         ,'User                Email','','','','',''),
('APLDCT','USREMP','user_employee_number','CHAR',15,0,0,'User Employee Number'
         ,'User Employee Number','','','','',''),
('APLDCT','USRINT','user_initials','CHAR',3,0,0,'User Initials'
         ,'User Initials','','','','',''),
('APLDCT','USRMSTIDN','user_master_id','BIGINT',0,0,0,'User Master Id'
         ,'User Master Id','','','','',''),
('APLDCT','USRNME','user_name','CHAR',30,0,0,'User Name'
         ,'User Name','','','','',''),
('APLDCT','USROQL','user_output_queue_library','CHAR',10,0,0,'User Output Queue Library'
         ,'User Output         Queue               Library','','','','',''),
('APLDCT','USROQN','user_output_queu','CHAR',10,0,0,'User Output Queue'
         ,'User Output Queue','','','','',''),
('APLDCT','USRPRF','user_profile','CHAR',10,0,0,'User Profile'
         ,'User Profile','','','','',''),
('APLDCT','USRROLIDN','user_role_id','BIGINT',0,0,0,'User Role Id'
         ,'User Role Id','','','','',''),
('APLDCT','USRSTS','user_status','CHAR',10,0,0,'User Status'
         ,'User Status','','','','',''),
('APLDCT','USRTTL','user_title','VARCHAR',30,0,0,'User Title'
         ,'User Title','','','','',''),
('APLDCT','USRTXT','user_profile_text','VARCHAR',50,0,50,'User Profile Text'
         ,'User                Profile             Text','','','','',''),
('APLDCT','VAL','value_','CHAR',10,0,0,'Value'
         ,'Value','','','','',''),
('APLDCT','VARDES','variable_description','CHAR',50,0,0,'Variable Description'
         ,'Variable            Description','','','','',''),
('APLDCT','VARNME','variable_name','CHAR',20,0,0,'Variable Name'
         ,'Variable            Name','','','','',''),
('APLDCT','VARTYP','variable_type','CHAR',15,0,0,'Variable Type'
         ,'Variable            Type','','','','',''),
('APLDCT','VLDATA','valid_attachment_types','CHAR',1,0,0,'Valid Attachment Types'
         ,'Valid Attachment Types','','','','','Y'),
('APLDCT','WEBAPL','web_application','CHAR',1,0,0,'Web Application'
         ,'Web                 Application','','','','','Y'),
('APLDCT','WID','width_','DECIMAL',5,2,0,'Width'
         ,'Width','','','','',''),
('APLDCT','Zon','zoned_','NUMERIC',9,2,0,'Zoned'
         ,'Zoned','','','','','')

) as source (dctNme,fldNme,fldNmeSql,fldTyp,fldLen,fldScl,fldAlc,colTxt,
           colHdg,pcdFlg,fldpmp,alwNul,dftVal,fldEnm)

on (target.dctNme,target.fldNme) = (source.dctNme, source.fldNme)

When Matched Then Update Set
    target.dctNme    = source.dctNme,
    target.fldNme    = source.fldNme,
    target.fldNmeSql = source.fldNmeSql,
    target.fldTyp    = source.fldTyp,
    target.fldLen    = source.fldLen,
    target.fldScl    = source.fldScl,
    target.fldAlc    = source.fldAlc,
    target.colTxt    = source.colTxt,
    target.colHdg    = source.colHdg,
    target.pcdFlg    = source.pcdFlg,
    target.fldpmp    = source.fldpmp,
    target.alwNul    = source.alwNul,
    target.dftVal    = source.dftVal,
    target.fldEnm    = source.fldEnm

When not Matched Then
    Insert (dctNme,fldNme,fldNmeSql,fldTyp,fldLen,fldScl,fldAlc,colTxt,
           colHdg,pcdFlg,fldpmp,alwNul,dftVal,fldEnm)
    Values (source.dctNme,source.fldNme,source.fldNmeSql,source.fldTyp,
            source.fldLen,source.fldScl,source.fldAlc,source.colTxt,
            source.colHdg,source.pcdFlg,source.fldpmp,source.alwNul,
            source.dftVal,source.fldEnm);


  // Add some template program fields to ERPDCT
  Exec SQL
Merge into APLLIB.DCTFLD as Target
Using(
    Select
        'ERPDCT' dctNme,fldNme,fldNmeSql,fldTyp,fldLen,fldScl,fldAlc,colTxt,
                  colHdg,pcdFlg,fldpmp,alwNul,dftVal,fldEnm
    From DCTFLD
    Where dctNme = 'APLDCT'
      and fldNme in ('ACVDES','ACVROW','PGMNME','MDE',   'SRTCDE','RPTTTL',
                     'SCHVAL','SCRSZE','OPTION','CRTDTM','CRTJOB','CRTNBR',
                     'CRTPGM','CRTSTR','CRTUSR','CRTDTM','CRTJOB','CRTNBR',
                     'CRTPGM','CRTSTR','CRTUSR')
) as source (dctNme,fldNme,fldNmeSql,fldTyp,fldLen,fldScl,fldAlc,colTxt,
           colHdg,pcdFlg,fldpmp,alwNul,dftVal,fldEnm)

on (target.dctNme,target.fldNme) = (source.dctNme, source.fldNme)

When Matched Then Update Set
    target.dctNme    = source.dctNme,
    target.fldNme    = source.fldNme,
    target.fldNmeSql = source.fldNmeSql,
    target.fldTyp    = source.fldTyp,
    target.fldLen    = source.fldLen,
    target.fldScl    = source.fldScl,
    target.fldAlc    = source.fldAlc,
    target.colTxt    = source.colTxt,
    target.colHdg    = source.colHdg,
    target.pcdFlg    = source.pcdFlg,
    target.fldpmp    = source.fldpmp,
    target.alwNul    = source.alwNul,
    target.dftVal    = source.dftVal,
    target.fldEnm    = source.fldEnm

When not Matched Then
    Insert (dctNme,fldNme,fldNmeSql,fldTyp,fldLen,fldScl,fldAlc,colTxt,
           colHdg,pcdFlg,fldpmp,alwNul,dftVal,fldEnm)
    Values (source.dctNme,source.fldNme,source.fldNmeSql,source.fldTyp,
            source.fldLen,source.fldScl,source.fldAlc,source.colTxt,
            source.colHdg,source.pcdFlg,source.fldpmp,source.alwNul,
            source.dftVal,source.fldEnm);


  // populate DCTVAL
  // To reporduce use this:
  // Select '(''' || trim(dctNme) || ''','''
  //              || trim(fldNme) || ''','''
  //              || trim(enmVal) || ''','''
  //              || trim(replace(enmDes,'''','''''')) || '''),'
  // From DCTVAL
  // Where dctNme = 'APLDCT';
  Exec SQL
Merge into APLLIB.DCTVAL as Target
Using(
  Values
('APLDCT','ACVROW','0','Inactive'),
('APLDCT','ACVROW','1','Active'),
('APLDCT','ALWALC','N','No'),
('APLDCT','ALWALC','Y','Yes'),
('APLDCT','ALWDEC','N','No'),
('APLDCT','ALWDEC','Y','Yes'),
('APLDCT','ALWLEN','N','No'),
('APLDCT','ALWLEN','Y','Yes'),
('APLDCT','APL','APP','Accounts Payable'),
('APLDCT','APL','ARR','Acounts Receivable'),
('APLDCT','APL','NVT','Inventory'),
('APLDCT','APL','OEI','Order Entry'),
('APLDCT','APL','PAY','Payroll'),
('APLDCT','APL','SYS','System (APLLIB)'),
('APLDCT','CHGSCD','N','No'),
('APLDCT','CHGSCD','Y','Yes'),
('APLDCT','CNFEXS','N','No'),
('APLDCT','CNFEXS','Y','Yes'),
('APLDCT','DFTAUT','0','Not Authorized'),
('APLDCT','DFTAUT','1','All Authority'),
('APLDCT','DFTAUT','5','Inquiry Only'),
('APLDCT','FLDENM','N','No'),
('APLDCT','FLDENM','Y','Yes'),
('APLDCT','FLDLVL','1','Active Row'),
('APLDCT','FLDLVL','2','Indentity'),
('APLDCT','FLDLVL','3','Primary Key'),
('APLDCT','FLDLVL','4','File Attributes'),
('APLDCT','FLDLVL','5','Create/Maintenance Fields'),
('APLDCT','FLDSTS','1','Entry'),
('APLDCT','FLDSTS','2','Production'),
('APLDCT','FLDSTS','3','Pending Changes'),
('APLDCT','FLDSTS','4','Changes Scheduled'),
('APLDCT','FLDSTS','5','Pending Delete'),
('APLDCT','FLDSTS','6','Delete Scheduled'),
('APLDCT','FLDSTS','9','Inactive'),
('APLDCT','FLEERR','N','No'),
('APLDCT','FLEERR','Y','Yes'),
('APLDCT','FLESTS','1','Entry'),
('APLDCT','FLESTS','2','Development'),
('APLDCT','FLESTS','3','Production'),
('APLDCT','FLESTS','4','Pending Changes'),
('APLDCT','FLESTS','5','Changes Scheduled'),
('APLDCT','FLESTS','9','Inactive'),
('APLDCT','FRCLEN','N','No'),
('APLDCT','FRCLEN','Y','Yes'),
('APLDCT','HLPTYP','1','Dictionary Field'),
('APLDCT','HLPTYP','2','Screen Field'),
('APLDCT','HLPTYP','3','Screen Function Key'),
('APLDCT','HLPTYP','4','Screen SFL Option'),
('APLDCT','HLPTYP','5','Screen Header'),
('APLDCT','HLPTYP','6','System Default'),
('APLDCT','IDXUNI','E','Encoded Vector Index'),
('APLDCT','IDXUNI','N','Not Unique'),
('APLDCT','IDXUNI','Y','Unique Index'),
('APLDCT','LIBTYP','1','Production'),
('APLDCT','LIBTYP','2','Auxillery'),
('APLDCT','LIBTYP','3','Development'),
('APLDCT','LIBTYP','4','Tool/External'),
('APLDCT','LIBTYP','5','System+'),
('APLDCT','MNUOBJ','N','No'),
('APLDCT','MNUOBJ','Y','Yes'),
('APLDCT','MSDTYP','*CHAR','Character'),
('APLDCT','MSDTYP','*DEC','Decimal'),
('APLDCT','MSDTYP','*DTS','Date Time Stamp'),
('APLDCT','MSDTYP','*HEX','Hexadecimal ie: (x''C0F4'')'),
('APLDCT','MSDTYP','*QTDCHAR','Quoted Character ie: (''Monday, the 1st'')'),
('APLDCT','MSDTYP','*UTC','Universal Time ie:(x''2022123117300000'')'),
('APLDCT','MSFNME','ENVIRONMNT','Environment Definition'),
('APLDCT','NMR','N','No'),
('APLDCT','NMR','Y','Yes'),
('APLDCT','OBJATR','DATA','Data (PF/LF)'),
('APLDCT','OBJATR','DSPF','Display File (DSPF)'),
('APLDCT','OBJAUTLST','DEVELOPER','Developer accessto data'),
('APLDCT','OBJAUTLST','USER','Normal non payroll authority'),
('APLDCT','OBJAUTLST','QUESTIV','Restricted Payroll Data'),
('APLDCT','OPTION','VP','Validate, prompt if not valid'),
('APLDCT','OPTION','1','Select or Create'),
('APLDCT','OPTION','13','Reactivate'),
('APLDCT','OPTION','2','Update'),
('APLDCT','OPTION','3','Copy'),
('APLDCT','OPTION','4','Deactivate'),
('APLDCT','OPTION','5','Inquiry'),
('APLDCT','OPTION','7','Rename'),
('APLDCT','OPTION','8','Position To'),
('APLDCT','PGMTYP','B','Batch Program'),
('APLDCT','PGMTYP','C','Cl Program'),
('APLDCT','PGMTYP','D','Display Program'),
('APLDCT','PGMTYP','F','Display File'),
('APLDCT','PGMTYP','N','Binder Source'),
('APLDCT','PGMTYP','P','Panel Group'),
('APLDCT','PGMTYP','S','Stored Procedure'),
('APLDCT','PGMTYP','T','Table Function'),
('APLDCT','PGMTYP','U','User Defined Function'),
('APLDCT','PGMTYP','V','Service Program'),
('APLDCT','PRDFLE','N','No'),
('APLDCT','PRDFLE','Y','Yes'),
('APLDCT','PRIKEY','N','No'),
('APLDCT','PRIKEY','Y','Yes'),
('APLDCT','REQALC','N','No'),
('APLDCT','REQALC','Y','Yes'),
('APLDCT','REQLEN','N','No'),
('APLDCT','REQLEN','Y','Yes'),
('APLDCT','SCRSZE','1','80X24'),
('APLDCT','SCRSZE','2','132X27'),
('APLDCT','USRAUT','*OWNER','Object Owner Authority'),
('APLDCT','USRAUT','*USER','User Authority'),
('APLDCT','WEBAPL','N','No'),
('APLDCT','WEBAPL','Y','Yes'),
('APLDCT','PRTOUT','Y','Yes'),
('APLDCT','PRTOUT','N','No'),
('APLDCT','EMLOUT','Y','Yes'),
('APLDCT','EMLOUT','N','No'),
('APLDCT','ARCOUT','Y','Yes'),
('APLDCT','ARCOUT','N','No'),
('APLDCT','FAXOUT','Y','Yes'),
('APLDCT','FAXOUT','N','No'),
('APLDCT','PSTFLG','Y','Yes'),
('APLDCT','PSTFLG','N','No'),
('APLDCT','HLDOUT','*YES','Yes'),
('APLDCT','HLDOUT','*NO','No'),
('APLDCT','SAVOUT','*YES','Yes'),
('APLDCT','SAVOUT','*NO','No'),
('APLDCT','PRTQUL','*STD','Standard'),
('APLDCT','PRTQUL','*DEVD','Device Default'),
('APLDCT','PRTQUL','*DRAFT','Draft'),
('APLDCT','PRTQUL','*NLQ','Near Letter Qualitty'),
('APLDCT','PRTQUL','*FASTDRAFT','Fast Draft"'),
('APLDCT','ATATYP','*XML','XML'),
('APLDCT','ATATYP','*XSLX','Excel'),
('APLDCT','ATATYP','*CSV','Comma Seperated Variable (CSV)'),
('APLDCT','ATATYP','*TXT','Text File'),
('APLDCT','ATATYP','*PDF','PDF File'),
('APLDCT','VLDATA','','PDF,TIFF'),
('APLDCT','VLDATA','2','PDF,TIFF,CSV'),
('APLDCT','VLDATA','3','PDF,TIFF,CSV,XML'),
('APLDCT','VLDATA','4','PDF,TIFF,CSV,XML,Excel'),
('APLDCT','ATAFMT','1','Data'),
('APLDCT','ATAFMT','2','Report'),
('APLDCT','CRTXMA','Y','Yes'),
('APLDCT','CRTXMA','N','No'),
('APLDCT','AUDFLD','Y','Yes'),
('APLDCT','AUDFLD','N','No'),
('APLDCT','ENCFLD','Y','Yes'),
('APLDCT','ENCFLD','N','No'),
('APLDCT','ALWEML','Y','Yes'),
('APLDCT','ALWEML','N','No'),
('APLDCT','ALWARC','Y','Yes'),
('APLDCT','ALWARC','N','No'),
('APLDCT','ALWFAX','Y','Yes'),
('APLDCT','ALWFAX','N','No'),
('APLDCT','AUTOPT','Y','Yes'),
('APLDCT','AUTOPT','N','No'),
('APLDCT','ROLAPR','Y','Yes'),
('APLDCT','ROLAPR','N','No'),
('APLDCT','APL','PUR','Inventory Purchasing'),
('APLDCT','IFMSTS','C','Complete'),
('APLDCT','IFMSTS','E','Error'),
('APLDCT','MSFNME','APLMSGF','Messages for All APLLIB Programs')
) as source (dctNme,fldNme,enmVal,enmDes)
on (target.dctNme,target.fldNme,target.enmVal) = (source.dctNme,source.fldNme,source.enmVal)

When Matched Then Update Set
    target.dctNme    = source.dctNme,
    target.fldNme    = source.fldNme,
    target.enmVal    = source.enmVal,
    target.enmDes    = source.enmDes

When not Matched Then
    Insert (dctNme,fldNme,enmVal,enmDes)
    Values (source.dctNme,source.fldNme,source.enmVal,source.enmDes);

  Exec SQL
Merge into APLLIB.DCTVAL as Target
Using(
  Values
      ('ERPDCT','ACVROW','0'   ,'Inactive'),
      ('ERPDCT','ACVROW','1'   ,'Active'),
      ('ERPDCT','SCRSZE','1'   ,'80X24'),
      ('ERPDCT','SCRSZE','2'   ,'132X27')
) as source (dctNme,fldNme,enmVal,enmDes)
on (target.dctNme,target.fldNme,target.enmVal) = (source.dctNme,source.fldNme,source.enmVal)

When Matched Then Update Set
    target.dctNme    = source.dctNme,
    target.fldNme    = source.fldNme,
    target.enmVal    = source.enmVal,
    target.enmDes    = source.enmDes

When not Matched Then
    Insert (dctNme,fldNme,enmVal,enmDes)
    Values (source.dctNme,source.fldNme,source.enmVal,source.enmDes);

  // This creates the APLDCT file
  // this is done just to get started on the dictionary master system,
  // once that system is created, it will take over control of this file

  // APLDCT is a dictionary file controled by the DCTMST system, however
  // the DCTMST system cannot be built without the APLDCT file, so it
  // must first be manually created.

  // This program only adds enough columns to build DCTFLSB8 and DCTFLDB9,
  // those programs can be used to build the rest of the table, using the
  // data populated above.
  Exec SQL Drop Table APLLIB/APLDCT;
  Exec SQL
    Create or Replace Table APLLIB/APLDCT (
        active_row               for Column acvRow    Char(1) not null with default '1',
        dictionary_name          for column dctNme    char(10) not null with default,
        field_name               for column fldNme    char(10) not null with default,
        field_type               for column fldTyp    char(10) not null with default,
        flied_lenght             for column fldLen    decimal(5) not null with default,
        field_scale              for column fldScl    decimal(2) not null with default,
        field_allocation         for column fldAlc    decimal(5) not null with default,
        column_text              for column colTxt    char(50) not null with default,
        caolumn_heading          for column colHdg    char(60) not null with default,
        allow_null               for column alwNul    char(1) not null with default,
        default_value            for column dftVal    char(60) not null with default,
        field_name_sql           for column fldNmeSQL char(40) not null with default,
        require_length           for column reqLen    char(10) not null with default,
        allows_decimal_positions for column alwDec    char(1) not null with default,
        allow_allocation         for column alwAlc    char(1) not null with default,
        creation_timestamp       for Column crtDtm    timestamp not null with default current timestamp,
        creation_user            for Column crtUsr    char(18) not null with default user,
        creation_job             for Column crtJob    char(28) not null with default,
        creation_program         for Column crtPgm    char(10) not null with default,
        function_key             for Column fncKey    char(10) not null with default,
        description              for Column des       char(40) not null with default,
        option_                  for Column option    char(2) not null with default,
        enumerated_description   for Column enmDes    char(40) not null with default,
        enumerated_value         for Column enmVal    char(10) not null with default,
        user_                    for Column usr       char(10) not null with default,
        user_default_key         for Column udfKey    char(20) not null with default,
        user_default_value       for Column udfVal    char(20) not null with default,
        program_name             for Column pgmNme    char(10) not null with default
        )
      RcdFmt APLDCTR;
  Exec SQL Label on Table APLLIB/APLDCT is 'Application Dictionary';

End-Proc;
