**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB') Main(Main) ActGrp(*caller);

// SQL Query Manager - Print Query

Dcl-F SQLCMDO1 printer oflind(ovrFlw) usropn;

Dcl-Ds columns LikeDs(#$SQLColumns);

Dcl-S #date packed(8);
Dcl-S #time packed(6);
Dcl-S x packed(5);
Dcl-S cpi packed(3:1);

Dcl-S LINES Char(78) dim(1000);
Dcl-S RPTLINE Char(1000) Inz(' ');
Dcl-S HDRLINE1 Char(1000) Inz(' ');
Dcl-S HDRLINE1O Char(1000) Inz(' ');
Dcl-S HDRLINE2 Char(1000) Inz(' ');
Dcl-S HDRLINE3 Char(1000) Inz(' ');
Dcl-S PAG packed(5) Inz(0);
Dcl-S Cmd char(500);
Dcl-S rpName char(10);
Dcl-S rpDft char(30);
Dcl-S i packed(5);
Dcl-S ovrFlw Ind;
Dcl-S EOF ind;
Dcl-S Row2 char(5000);

// Global variables for parameters
Dcl-S sqlStm varchar(32000);
Dcl-S outQ Char(10);
Dcl-S outQLib Char(10);
Dcl-S copies packed(3);
Dcl-S hold Char(5);
Dcl-S save Char(5);
Dcl-S userData Char(10);
Dcl-S formLength packed(3);
Dcl-S formWidth packed(3);
Dcl-S includeVariables Char(4);
Dcl-S includeQuery Char(4);
Dcl-S title1 Char(80);
Dcl-S title2 Char(80);
Dcl-S title3 Char(80);
Dcl-S title4 Char(80);
Dcl-S title5 Char(80);
Dcl-S programName Char(10);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command

// This option turns off commitment control
Exec SQL Set Option Commit = *none, CloSQLCsr = *endactgrp, UsrPrf = *owner, datfmt = *ISO,
                    DynUsrPrf = *owner;

// procedure interface and protype for *entry plist
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('SQLCMDB1');
    pmrSqlStm varchar(32000) const;
    pmrVars Char(500) const;
    pmrOutQ Char(10) const;
    pmrOutQLib Char(10) const;
    pmrCopies packed(3) const;
    pmrHold Char(5) const;
    pmrSave Char(5) const;
    pmrUserData Char(10) const;
    pmrFormLength packed(3) const;
    pmrFormWidth packed(3) const;
    pmrIncludeVariables Char(4) const;
    pmrIincludeQuery Char(4) const;
    pmrTitle1 Char(80) const;
    pmrTitle2 Char(80) const;
    pmrTitle3 Char(80) const;
    pmrTitle4 Char(80) const;
    pmrTitle5 Char(80) const;
    pmrProgramName Char(10) const;
    pmrQueries likeds(queries) dim(300) options(*nopass);
  End-Pi;

  // Set global variables for parameters passed
  sqlStm =pmrSqlStm;
  VarDs =pmrVars;
  outQ =pmrOutQ;
  outQLib =pmrOutQLib;
  copies =pmrCopies;
  hold =pmrHold;
  save =pmrSave;
  userData =pmrUserData;
  formLength =pmrFormLength;
  formWidth =pmrFormWidth;
  includeVariables =pmrIncludeVariables;
  includeQuery =pmrIincludeQuery;
  title1=pmrTitle1;
  title2=pmrTitle2;
  title3=pmrTitle3;
  title4=pmrTitle4;
  title5=pmrTitle5;
  programName =pmrProgramName;

  If %parms() >= 19;
    queries = pmrQueries;
  Else;
    Clear queries;
  EndIf;

  // Clear any titles if they are set to *None
  If title1='*NONE';
    title1=' ';
  EndIf;
  If title2='*NONE';
    title2=' ';
  EndIf;
  If title3='*NONE';
    title3=' ';
  EndIf;
  If title4='*NONE';
    title4=' ';
  EndIf;
  If title5='*NONE';
    title5=' ';
  EndIf;

  // Get date and time
  #date=%dec(%char(%date():*ISO0):8:0);
  #time=%dec(%char(%time():*HMS0):6:0);

  OpenPrintFile();

  // Start primary report
  PrintReport(sqlStm:title1:title2:title3:title4:title5);

  // Add any additional reports passed
  For i = 1 To 300;
    If queries(i).sql <> '';
      PrintReport(queries(i).sql:queries(i).title1:queries(i).title2:queries(i).title3
              :queries(i).title4:queries(i).title5);
    EndIf;
  EndFor;

  Close SQLCMDO1;
  #$Cmd('DLTOVR SQLCMDO1');

End-Proc;


// Print report
Dcl-Proc PrintReport;
  Dcl-Pi *n;
    pSqlStm varchar(32000) value;
    pTitle1 Char(80);
    pTitle2 Char(80);
    pTitle3 Char(80);
    pTitle4 Char(80);
    pTitle5 Char(80);
  End-Pi;

  PrepareSQL(pSqlStm);
  StartOutput(pTitle1:pTitle2:pTitle3:pTitle4:pTitle5);
  FetchSQL();
  DoW not #$SQLSTT;
    If ovrFlw;
      StartNewPage();
    EndIf;
    BuildRow();
    RPTLINE=Row2;
    Write #DTL;
    FetchSQL();
  EndDo;
  CloseAll();

End-Proc;


// Build Row
Dcl-Proc BuildRow;
  Dcl-S trmFld varchar(100);
  Dcl-S isNeg ind;

  Row2='';
  For x = 1 To columns.count;

    // if numeric, format and right justify
    If #$in(#$Upify(columns.col(x).type):'DECFLOAT':'NUMERIC':'DECIMAL':'INTEGER':'SMALLINT':
                         'FLOAT':'REAL':'DOUBLE':'BIGINT');

      // use the value passed by SQL, strip the - sign so it can be added to the end later.
      trmFld = %trim(val(x));
      Clear isNeg;
      If trmFld <> %scanrpl('-':'':trmFld);
        trmFld = %scanrpl('-':'':trmFld);
        isNeg = *on;
      EndIf;
      // the starting postion is the column offest + column length
      //                                           - 1 (for the negative sign)
      //                                           - field length
      // The length is just the length of the trimmed field
      %subst(Row2:columns.col(x).Offset + columns.col(x).COLWIDTH - 1 - %len(trmFld)
                 :%len(trmFld))=trmFld;
      If isNeg;
        %subst(Row2:columns.col(x).Offset+columns.col(x).COLWIDTH-1:1)='-';
      EndIf;

    Else;
      %subst(Row2:columns.col(x).OFFSET:columns.col(x).COLWIDTH)=val(x);
    EndIf;

  EndFor;

End-Proc;


// Prepare SQL
Dcl-Proc PrepareSQL;
  Dcl-Pi *n;
    pSqlStm varchar(32000);
  End-Pi;

  EOF=*OFF;

  // prepare the statement, setup the cursor and open it
  Exec SQL Prepare SQLF1 From :pSqlStm;
  #$SQLSTT();
  Exec SQL Declare SQLCRSF1 INSENSITIVE SCROLL Cursor For SQLF1;
  #$SQLSTT();
  Exec SQL Open SQLCRSF1;
  #$SQLSTT();

  // Get Columns for this statement
  columns=#$SQLGetColumns(sqlStm);

End-Proc;


// Fecth one record from the SQL statement
Dcl-Proc FetchSQL;

  // fetch one row into the data structure
  Monitor;
    Exec SQL Fetch Next From SQLCRSF1 Into :MYDS :nulls;
  On-Error;
  EndMon;
  If #$SQLSTT();
    EOF = *ON;
  EndIf;

End-Proc;


// Overide and open print file, add first page headers
Dcl-Proc OpenPrintFile;

  // override any passed variables to thier defaults if needed
  If outQ='*JOB';
    GetOutQ(outQ:outQLib);
  EndIf;
  If formWidth=0;
    formWidth=132;
  EndIf;
  If formLength=0;
    formLength=66;
  EndIf;
  If Hold<>'*YES';
    hold='*NO';
  EndIf;
  If save<>'*YES';
    save='*NO';
  EndIf;
  If userData=' ';
    userData='SQL';
  Else;
    userData=%scanrpl(' ':'_':%trim(userData));
  EndIf;

  // build the cpi based on the width
  If FormWidth<=80;
    cpi=10;
  ElseIf FormWidth<=96;
    cpi=12;
  ElseIf FormWidth<=139;
    cpi=13.3;
  ElseIf FormWidth<=157;
    cpi=15;
  ElseIf FormWidth<=175;
    cpi=16.7;
  ElseIf FormWidth<=189;
    cpi=18;
  Else;
    cpi=20;
  EndIf;

  // build the ovrprtf command based on passed parms
  Cmd='OVRPRTF SQLCMDO1 OUTQ(' + %trim(outQLib) +'/'+ %trim(outQ)+')'+
  ' HOLD('+%trim(hold)+')' +
  ' SAVE('+%trim(save)+')' +
  ' PAGESIZE('+%trim(%char(formLength))+' '+%trim(%char(formWidth))+')'+
  ' CPI(' + %trim(%char(cpi)) + ')' +
  ' LPI(6)' +
  ' COPIES(' + %trim(%char(copies)) + ')' +
  ' USRDTA(''' + %trim(userData) +''')';
  #$Cmd(Cmd);

  Open SQLCMDO1;

End-Proc;

// Overide and open print file, add first page headers
Dcl-Proc StartOutput;
  Dcl-Pi *n;
    pTitle1 Char(80) const;
    pTitle2 Char(80) const;
    pTitle3 Char(80) const;
    pTitle4 Char(80) const;
    pTitle5 Char(80) const;
  End-Pi;

  // build the header line 1, date/time/title/page
  PAG = 0;
  HDRLINE1=Center(pTitle1:formWidth);
  HDRLINE1O=HDRLINE1;
  %subst(HDRLINE1:1:19)=%editw(#date:'    /  / 0') +
    ' ' + %editw(#time:'  :  : 0');
  If programName<>' ';
    %subst(HDRLINE1:21:10)=programName;
  EndIf;
  %subst(HDRLINE1:formWidth-11:5)='PAGE:';
  %subst(HDRLINE1:formWidth-5:5)=%editc(PAG:'Z');

  // set the column headers as header line3
  HDRLINE3=columns.headers;

  // start new page
  PAG+=1;
  %subst(HDRLINE1:formWidth-5:5)=%editc(PAG:'Z');

  // start the first page
  Write #PAGE;
  RPTLINE=HDRLINE1;
  Write #DTL;
  RPTLINE=HDRLINE1O;
  Write #OVR;

  // add additional titles if passed
  If title2<>' ';
    RPTLINE=Center(pTitle2:formWidth);
    Write #DTL;
  EndIf;
  If title3<>' ';
    RPTLINE=Center(pTitle3:formWidth);
    Write #DTL;
  EndIf;
  If title4<>' ';
    RPTLINE=Center(pTitle4:formWidth);
    Write #DTL;
  EndIf;
  If title5<>' ';
    RPTLINE=Center(pTitle5:formWidth);
    Write #DTL;
  EndIf;

  // add variable overrides
  If includeVariables='*YES';
    AddVariables();
  EndIf;

  // add query
  If includeQuery='*YES';
    AddSqlStatement();
  EndIf;

  RPTLINE=HDRLINE2;
  Write #DTL;
  RPTLINE=HDRLINE3;
  Write #DTL;
  Write #OVR;

End-Proc;


// Add variable values to first page of report
Dcl-Proc AddVariables;

  *IN77 = *OFF;
  For i=1 To 10;
    If VRNAME(i)<>' ';
      rpName=Vrname(i);
      rpDft=vrDft(i);
      If not *in77;
        Write #varHdr;
        RPTLINE='________________________________________+
                 ________________________________________';
        Write    #OVR;
      EndIf;
      *IN77 = *ON;
      Write #VARDTL;
    EndIf;
  EndFor;
  If *in77;
    Write #spc;
  EndIf;

End-Proc;


// Add SQL
Dcl-Proc AddSqlStatement;

  // format the sql query into the lines array
  LINES=#$FormatSQL(sqlStm);

  // print query header line
  Write #SPC;
  RPTLINE='QUERY';
  Write #DTL;
  Write #OVR;
  RPTLINE='________________________________________+
           ________________________________________';
  Write #OVR;

  // print lines array
  For i=1 To 1000;
    If LINES(i)<>' ';
      If ovrFlw;
        PAG+=1;
        %subst(HDRLINE1:formWidth-5:5)=%editc(PAG:'Z');
        Write #PAGE;
        RPTLINE=HDRLINE1;
        Write #DTL;
        RPTLINE=HDRLINE1O;
        Write #OVR;
        RPTLINE=HDRLINE2;
        Write #DTL;
        RPTLINE='Query';
        Write #DTL;
        Write #OVR;
        RPTLINE='________________________________________+
          ________________________________________';
        Write #OVR;
      EndIf;
      RPTLINE=LINES(i);
      Write #DTL;
    EndIf;
  EndFor;

End-Proc;


// Start new page
Dcl-Proc StartNewPage;

  ovrFlw=*off;

  PAG+=1;
  %subst(HDRLINE1:formWidth-5:5)=%editc(PAG:'Z');

  // start the first page
  Write #PAGE;
  RPTLINE=HDRLINE1;
  Write #DTL;
  RPTLINE=HDRLINE1O;
  Write #OVR;
  RPTLINE=HDRLINE2;
  Write #DTL;
  RPTLINE=HDRLINE3;
  Write #DTL;
  Write #OVR;

End-Proc;


// Close cursor and print file
Dcl-Proc CloseAll;

  Exec SQL Close SQLCRSF1;

End-Proc;


// Centers text based on a field length
Dcl-Proc Center;
  Dcl-Pi Center varchar(1000);
    #$TXT varchar(1000) Value;
    #$LEN int(10) Value;
  End-Pi;
  Dcl-S #$OUT varchar(1000);
  Dcl-S #$POS int(10);

  // check if input string is bigger than desired output
  #$TXT = %trim(#$TXT);
  If %len(#$TXT) > #$LEN;
    %len(#$TXT) = #$LEN;
  EndIf;

  // find position of centered string in output
  EVAL(H) #$POS = (#$LEN - %len(#$TXT))/2 + 1;

  // build and return centered output string
  %len(#$OUT) = #$LEN;
  %subst(#$OUT:#$POS) = #$TXT;
  Return #$OUT;

End-Proc;
