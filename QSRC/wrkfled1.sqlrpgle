**free
Ctl-Opt OPTION(*srcstmt) SRTSEQ(*LANGIDSHR) DFTACTGRP(*NO) BNDDIR('APLLIB') Main(Main);
// Display Files and Their Prefixes

// This program loads SFL F1 and F2 in the same routines, *IN82 determines
// which one is displayed.

Dcl-F WRKFLEF1 WORKSTN UsrOpn
         SFILE(F1S:rrnf1) SFILE(F2S:rrnf1) SFILE(F11S:rrnf1) SFILE(F5S:rrnf5);
Dcl-F WRKFLE Usage(*Input) Keyed USROPN;
// ACCESSUP  IF   E           K DISK    USROPN
Dcl-S EMA          Char(50)   DIM(06) CTDATA PERRCD(1);
Dcl-S EOF          Ind;
Dcl-Ds FILDS  EXTNAME('WRKFLE');
End-Ds;
Dcl-S WORDS        Char(100)  DIM(10);
Dcl-S rrnf1 packed(4);
Dcl-S rrnf5 packed(4);
Dcl-S NUMRCF1 packed(5);
Dcl-S NUMRCF5 packed(5);
Dcl-S X   packed(5);
Dcl-S y   packed(5);
Dcl-S XF1 packed(5);
Dcl-S XF5 packed(5);
Dcl-S sqlStmF1 char(3000);
Dcl-S sqlStmF5 char(3000);
Dcl-S #date packed(8);
Dcl-S #time packed(6);
Dcl-S fileName char(60);
Dcl-S cmd char(2048);
Dcl-S filelib char(20);
Dcl-S isBigOk  char(1);
Dcl-S againF1  char(1);
Dcl-S againF5  char(1);

/INCLUDE QSRC,BASFNCV1PR // prototypes for all #$ procedures
/INCLUDE QSRC,OUTFLEV1PR
/INCLUDE QSRC,WRKFLEB1PR


Dcl-Proc Main;
  Dcl-Pi *n;
    pmrF1Desc char(30);
  End-Pi;

  If %parms() >= 1;
    f1Desc = pmrF1Desc;
  EndIf;

  Open WRKFLEF1;
  Open WRKFLE;


  // This needs to be replaced with something else.
  // GET THE CURRENT USERS EMAIL ADDRESS
  //                  OPEN      ACCESSUP
  //    USER          CHAIN     ACCESSUP
  //                  IF        %FOUND
  //                  MOVEL     ACEMAIL       F4EMAIL
  //                  ENDIF
  //                  CLOSE     ACCESSUP

  // RETURNS A Y IF THE WORKSTATION HANDLES 27 x 132
  isBigOk = #$132OK();
  PROCF1();

  Close WRKFLEF1;
  Close WRKFLE;

End-Proc;


// PROCESS SCREEN 1
Dcl-Proc PROCF1;

  MOVEF1();
  DoW NOT %shtdn();


    *In44 = *Off;
    If rrnf1 <> 0;
      *in45 = *on;
    Else;
      *in45 = *off;
    EndIf;
    If CRNF1<=0 OR CRNF1>RRNF1;
      CRNF1 = 1;
    EndIf;
    If isBigOk='Y';
      Write F11F;
      Exfmt F11C;
    Else;
      If *in82;
        Write F2F;
        Exfmt F2C;
      Else;
        Write F1F;
        Exfmt F1C;
      EndIf;
    EndIf;
    *In50 = *Off;
    *In51 = *Off;
    *In52 = *Off;
    Clear erm;
    If CSRF1=0;
      If *In46;
        CRNF1 = NUMRCF1;
      Else;
        CRNF1 = 1;
      EndIf;
    Else;
      CRNF1 = CSRF1;
    EndIf;

    // IF PAGED UP PAST THE END OF SFL, JUST REDISPLAY
    If *IN47;
      ERM = EMA(01);
      ITER;
    EndIf;

    // IF PAGED DOWN PAST THE END OF SFL, JUST REDISPLAY
    If *IN46;
      erm =EMA(02);
      ITER;
    EndIf;

    // F3=EXIT
    If *IN03;
      Leave;
    EndIf;

    // F12=Cancel
    If *IN12;
      Leave;
    EndIf;

    // F6=TOGGLE VIEW
    If *IN06 = *ON;
      If *IN82;
        *IN82=*OFF;
      Else;
        *IN82=*ON;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // F8=TOGGLE SORT
    If *IN08 = *ON;
      If *IN81;
        *IN81=*OFF;
      Else;
        *IN81=*ON;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // F10=EMAIL LIST
    If *IN10 = *ON;
      PROCF4();
      ITER;
    EndIf;

    // F11=TOGGLE WORKFILES
    If *IN11 = *ON;
      If *IN83;
        *IN83=*OFF;
      Else;
        *IN83=*ON;
      EndIf;
      MOVEF1();
      ITER;
    EndIf;

    // F18=REBUILD FILE
    If *IN18 = *ON;
      Write F3;
      WRKFLEB1();
      MOVEF1();
      ITER;
    EndIf;

    // FXX=ANY OTHER FUNCTION KEY SO THE SCREEN DOESN'T LOCK UP
    If *IN27;
      erm = EMA(03);
      ITER;
    EndIf;

    VALDF1();
    If *In50;
      ITER;
    EndIf;

    UPDTF1();
    If AGAINF1<>'Y' AND NOT *IN25;
      Leave;
    EndIf;

    MOVEF1();
  EndDo;

End-Proc;


Dcl-Proc MOVEF1;

  // SETUP COMMAND F8=SORT TOGGLE, USE *IN81 AS THE TOGGLE INDICATOR
  If *IN81;
    F1CMD8='F8=Sort by File  ';
  Else;
    F1CMD8='F8=Sort by Prefix';
  EndIf;

  // SETUP COMMAND F11=WK FILES TOGGLE, USE *IN83 AS THE TOGGLE INDICATOR
  If *IN83;
    F1CMD11='F11=Exclude WK Files';
  Else;
    F1CMD11='F11=Include WK Files';
  EndIf;

  // CLEAR SFL
  *In44 = *On;
  Write F1C;
  Write F2C;
  Write F11C;
  *In44 = *Off;

  Clear rrnf1;
  Clear SELECT;

  // FILL SFL
  BuildSqlF1();
  GETSQLF1();
  DoW NOT EOF;
    SF1Desc = fleDes;
    sf1Type = fleTyp;
    If srcMbr='*ERROR';
      SF2SRC='*ERROR';
      SF11SRC='*ERROR';
    Else;
      SF2SRC=%trim(srcFle) + '/' + %trim(srcMbr);
      SF11SRC=%trim(srcLib) + '/' + %trim(srcFle) + '.' + %trim(srcMbr);
    EndIf;
    rrnf1 = rrnf1 + 1;
    Write F1S;
    Write F2S;
    Write F11S;
    If RRNF1>4000;
      Leave;
    EndIf;
    GETSQLF1();
  EndDo;
  CLSSQLF1();

  NUMRCF1 = rrnf1;

End-Proc;


Dcl-Proc VALDF1;

  Clear againF1;

  // VALIDATE SFL OPTIONS
  For XF1 = 1 to NUMRCF1;

    If isBigOk='Y';
      Chain XF1 F11S ;
      *in76 = (%found() = *Off);
    Else;
      If NOT *In82;
        Chain XF1 F1S ;
        *in76 = (%found() = *Off);
      EndIf;
      If *In82;
        Chain XF1 F2S ;
        *in76 = (%found() = *Off);
      EndIf;
    EndIf;
    If *In76;
      ITER;
    EndIf;

    againF1 = 'Y';

    //                  IF        SELECT<>'X' AND SELECT<>'S' AND
    //                            SELECT<>'F' AND SELECT<>'L' AND
    //                            SELECT<>' '
    //                  EVAL      ERM=EMA(04)
    //                  SETON                                        5051
    //                  UPDATE    F1S
    //                  LEAVESR
    //                  ENDIF

    // IF VIEWING SORUCE AND THERE IS NO SOURCE, GIVE AN ERROR
    If isBigOk='Y' AND SELECT= 'S' AND SF11SRC = '*ERROR';
      ERM=EMA(06);
      *In50 = *On;
      *In51 = *On;
      Update F11S;
      Return;
    EndIf;

  EndFor;

End-Proc;


Dcl-Proc UPDTF1;

  // CHECK SFL FOR OPTIONS ENTERED
  For XF1 = 1 to NUMRCF1;
    If isBigOk='Y';
      Chain XF1 F11S ;
      *in76 = (%found() = *Off);
    Else;
      If NOT *In82;
        Chain XF1 F1S;
      Else;
        Chain XF1 F2S;
      EndIf;
    EndIf;
    If not %found;
      ITER;
    EndIf;

    // CHAIN WRKFLE SO ALL FIELDS ARE AVAILBLE
    Chain (fleLib:fleNme) WRKFLE;
    If NOT %found;
      Clear  *ALL WRKFLER;
    EndIf;

    // S=DISPLAY SOURCE
    If SELECT='S';
      If srcLib = 'MRPS38S' OR srcLib = '';
        srcLib = 'MRPS38SRC';
      Else;
        srcLib = srcLib;
      EndIf;
      If srcFle = '';
        srcFle = 'QDDSSRC';
      Else;
        srcFle = srcFle;
      EndIf;
      If srcMbr = '' or srcMbr = '*ERROR';
        srcMbr = fleNme;
      EndIf;
      CRNF1 = XF1;
      againF1 = 'Y';
      // See if the file exists, if not try library MRPS38S
      If not #$ISOBJ(srcFle:'*FILE':srcLib);
        srcLib = 'MRPS8SRC';
      EndIf;
      #$CMD('STRSEU SRCFILE(' + %trim(srcLib) + '/'+ %trim(srcFle) +
                ') SRCMBR(' + %trim(srcMbr) + ') OPTION(5)');
    EndIf;

    // X=VIEW FIELDS
    If SELECT<>'S' AND SELECT<>'F' AND SELECT<>'L' AND SELECT<>'D'
          AND SELECT<>'R' AND SELECT<>'Q' AND SELECT<>' ';
      CRNF1 = XF1;
      againF1 = 'Y';
      #$CMD('DSPFLE FILE(' + %trim(fleLib) + '/' + %trim(fleNme) + ')');
    EndIf;

    // F=VIEW FILE STATS
    If SELECT='F';
      CRNF1 = XF1;
      againF1 = 'Y';
      #$CMD('DSPFILD FILE(' + %trim(fleLib) + '/' + %trim(fleNme) + ')');
    EndIf;

    // D=WHERE USED
    If SELECT='D';
      CRNF1 = XF1;
      againF1 = 'Y';
      #$CMD('D ' + %trim(fleLib) + '/' + %trim(fleNme));
    EndIf;

    // R=QUERY
    If SELECT='R';
      CRNF1 = XF1;
      againF1 = 'Y';
      #$CMD('R ' + %trim(fleLib) + '/' + %trim(fleNme));
    EndIf;

    // Q=SQL
    If SELECT='Q';
      CRNF1 = XF1;
      againF1 = 'Y';
      #$CMD('SQL ''SELECT * FROM ' + %trim(fleLib) + '/' +
                %trim(fleNme) + '''');
    EndIf;

    // L=VIEW LOGICAL FILES
    If SELECT='L';
      CRNF1 = XF1;
      againF1 = 'Y';
      PROCF5();
    EndIf;

  EndFor;

End-Proc;


Dcl-Proc BuildSqlF1;
  // BUILDS AN SQL STATEMENT, AND OPENS A CURSOR TO IT

  EOF=*OFF;

  // SETUP SQL SELECT STATEMENT
  sqlStmF1='SELECT * FROM WRKFLE';

  // INDICATOR 77 IS ON TO SEE IF THE FIRST WHERE CLAUSE HAS BEEN ENTERED
  // IF IT HAS NOT IT NEEDS TO BE ADDED, IF IT HAS AN "AND" NEEDS TO BE ADDED
  *In77 = *Off;

  // ADD DESCRIPTION SELECTION IF ENTERED
  // IF A SEARCH IS ENTERED, PARSE IT INTO SEPERATE WORDS
  // THEN ADD A SELECTION FOR EACH ONE
  If F1DESC<>' ';
    WORDS=#$SPLIT(f1Desc);
    For X = 1 to 10;
      If WORDS(X)<>' ';
        If NOT *In77;
          sqlStmF1=%trim(sqlStmF1) + ' WHERE ';
        EndIf;
        If *In77;
          sqlStmF1=%trim(sqlStmF1) + ' AND ';
        EndIf;
        *In77 = *On;
        sqlStmF1=%trim(sqlStmF1) + '(UPPER(fleDes) LIKE ''%'+
           #$SQLESC(WORDS(X))+'%'' OR fleTyp LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR fleNme LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR flePfx LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR rcdFmt LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR srcLib LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR srcFle LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR srcMbr LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'' OR fleLib LIKE ''%' +
           #$SQLESC(WORDS(X))+'%'')';
      EndIf;
    EndFor;
  EndIf;

  // ADD PREFIX SELECTION IF ENTERED
  If F1PRFX<>' ';
    If NOT *In77;
      sqlStmF1=%trim(sqlStmF1) + ' WHERE ';
    EndIf;
    If *In77;
      sqlStmF1=%trim(sqlStmF1) + ' AND ';
    EndIf;
    *In77 = *On;
    sqlStmF1=%trim(sqlStmF1) + ' UPPER(flePfx) LIKE + ''' +
                    #$SQLESC(F1PRFX) + '%''';
  EndIf;

  // ADD EXCLUDE WORK FILES ON NOT *IN83
  If NOT *IN83;
    If NOT *In77;
      sqlStmF1=%trim(sqlStmF1) + ' WHERE ';
    EndIf;
    If *In77;
      sqlStmF1=%trim(sqlStmF1) + ' AND ';
    EndIf;
    *In77 = *On;
    sqlStmF1=%trim(sqlStmF1) + ' TRIM(fleNme) NOT LIKE(''%WK'')';
  EndIf;

  // ADD ORDER BY SELECTION
  If NOT *In81;
    sqlStmF1=%trim(sqlStmF1) +' ORDER BY fleNme';
  EndIf ;
  If *In81;
    sqlStmF1=%trim(sqlStmF1) +' ORDER BY flePfx, fleNme';
  EndIf ;

  // PREPARE THE STATEMENT, SETUP THE CURSOR AND OPEN IT
  Exec SQL PREPARE SQLF1 FROM :sqlStmF1;
  Exec SQL DECLARE SQLCRSF1 CURSOR FOR SQLF1;
  Exec SQL OPEN SQLCRSF1;

End-Proc;


Dcl-Proc GETSQLF1;

  Exec SQL FETCH NEXT FROM SQLCRSF1
         INTO :FILDS;

  If SQLSTT <> '00000';
    EOF = *ON;
  EndIf;

End-Proc;


Dcl-Proc CLSSQLF1;

  Exec SQL CLOSE SQLCRSF1;

End-Proc;


// PROCESS SCREEN 4 - EMAIL LIST
Dcl-Proc PROCF4;

  DoW NOT %shtdn();

    Exfmt F4;
    *In50 = *Off;
    *In51 = *Off;
    *In52 = *Off;
    Clear ERM;

    // F3=EXIT
    If *IN03 = *ON;
      Return;
    EndIf;

    // F12=Cancel
    If *IN12 = *ON;
      Leave;
    EndIf;

    // FXX=ANY OTHER FUNCTION KEY SO THE SCREEN DOESN'T LOCK UP
    If *IN27;
      erm = EMA(03);
      ITER;
    EndIf;

    VALDF4();
    If *In50;
      ITER;
    EndIf;

    UPDTF4();
    Leave;
  EndDo;

End-Proc;


Dcl-Proc VALDF4;

  If #$VEML(F4EMAIL);
    ERM=EMA(05);
    *In50 = *On;
    *In51 = *On;
    Return;
  EndIf;

End-Proc;


Dcl-Proc UPDTF4;

  // DISPLAY PROCESSING SCREEN
  Write F3;

  // SETUP TEMPORARY FILE NAME
  #date = %dec(%char(%date():*iso0):8:0);
  #time = %dec(%char(%time():*hms):6:0);
  Clear fileName;
  fileName='/ACOM/EMAIL/TMP/WRKPF-' + %editw(#date:'    -  - 0') +
                  '-' + %editw(#time:'  -  -  ') + '.xlsx';
  *In44 = *Off;

  // SET COLUMN WIDTHS AND OPEN FILE.
  #$OutFWidths( 1)=10;
  #$OutFWidths( 2)=10;
  #$OutFWidths( 3)=6;
  #$OutFWidths( 4)=50;
  #$OutFWidths( 5)=13;
  #$OutFWidths( 6)=10;
  #$OutFWidths( 7)=10;
  #$OutFWidths( 8)=10;
  #$OutFWidths( 9)=10;
  #$OpenOut(fileName:'XLS': #$OutFWidths:'WRKPF':1:0);

  // ADD COLUMN HEADERS
  #$AddChar('Library':'H');
  #$AddChar('File':'H');
  #$AddChar('Prefix':'H');
  #$AddChar('Description':'H');
  #$AddChar('Record Format':'H');
  #$AddChar('Type':'H');
  #$AddChar('Src Lib':'H');
  #$AddChar('Src File':'H');
  #$AddChar('Src Mbr':'H');

  // ADD DETAIL
  BuildSqlF1();
  GETSQLF1();
  DoW NOT EOF;
    // ADD DETAIL RECORD
    #$NextRec();
    #$AddChar(fleLib );
    #$AddChar(fleNme);
    #$AddChar(flePfx);
    #$AddChar(fleDes);
    #$AddChar(rcdFmt);
    #$AddChar(fleTyp);
    #$AddChar(srcLib);
    #$AddChar(srcFle);
    #$AddChar(srcMbr);
    GETSQLF1();
  EndDo;
  CLSSQLF1();

  // CLOSE THE OPEN FILE
  #$CloseOut();

  // EMAIL THE FILE
  cmd='GUMBOMAIL/GSENDMAIL TOSMTPNAME((' + %trim(F4EMAIL) + '))'
           + ' SUBJECT(''WRKPF Listing (SYS240)'')'
           + ' MSG(''Attached is the requested' + ' File Listing'+ EOR;
  // ADD SELECTION CRITERIA TO THE EMAIL BODY
  If F1DESC<>' ';
    cmd=%trim(cmd) + 'For Description '+ %trim(f1Desc) + EOR;
  EndIf;
  If F1PRFX<>' ';
    cmd=%trim(cmd) + 'For Prefix '+ %trim(F1PRFX) + EOR;
  EndIf;
  If NOT *IN83;
    cmd=%trim(cmd) + 'Files ending in WK excluded.'+EOR;
  EndIf;

  // ADD THE REST OF THE COMMAND
  cmd=%trim(cmd) + ''' *TEXTPLAIN) ' +
                      ' OBJ((''' + %trim(fileName) + '''))';

  // RUN THE EMAIL COMMAND
  #$CMD(cmd);

  // DELETE THE TEMP FILE
  #$CMD(('DEL ''' + %trim(fileName) +''''));


End-Proc;


// PROCESS SCREEN 5
Dcl-Proc PROCF5;

  MOVEF5();
  DoW NOT %shtdn();

    *In44 = *Off;
    If rrnf5 <> 0;
      *in45 = *on;
    Else;
      *in45 = *off;
    EndIf;
    If CRNF5<=0 OR CRNF5>RRNF5;
      CRNF5 = 1;
    EndIf;
    Write F5F;
    Exfmt F5C;
    *In50 = *Off;
    *In51 = *Off;
    *In52 = *Off;
    Clear ERM;
    If CSRF5=0;
      If *In46;
        CRNF5 = NUMRCF5;
      EndIf;
      If NOT *In46;
        CRNF5 = 1;
      EndIf;
    Else;
      CRNF5 = CSRF5;
    EndIf;

    // IF PAGED UP PAST THE END OF SFL, JUST REDISPLAY
    If *IN47;
      erm = EMA(01);
      ITER;
    EndIf;

    // IF PAGED DOWN PAST THE END OF SFL, JUST REDISPLAY
    If *IN46;
      erm = EMA(02);
      ITER;
    EndIf;

    // F1=EXIT
    If *IN03 = *ON;
      Return;
    EndIf;

    // F12=Cancel
    If *IN12 = *ON;
      Leave;
    EndIf;

    // F6=TOGGLE VIEW
    If *IN06 = *ON;
      If *IN85;
        *IN85=*OFF;
      Else;
        *IN85=*ON;
      EndIf;
      MOVEF5();
      ITER;
    EndIf;

    // FXX=ANY OTHER FUNCTION KEY SO THE SCREEN DOESN'T LOCK UP
    If *IN27;
      erm = EMA(03);
      ITER;
    EndIf;

    VALDF5();
    If *In50;
      ITER;
    EndIf;

    UPDTF5();
    If AGAINF5<>'Y' AND NOT *IN25;
      Leave;
    EndIf;

    MOVEF5();
  EndDo;

End-Proc;


Dcl-Proc MOVEF5;

  filelib = fleNme + fleLib;
  f5Desc = fleDes;
  f5Keys = #$GetKeys(fleLib:fleNme);

  // SETUP COMMAND KEY TO TOGGLE DESCRIPTION AND KEYS
  If *IN85;
    F5CMD6='F6=Show Keys';
    F5HDR1='Description';
  Else;
    F5CMD6='F6=Show Description';
    F5HDR1='Keys';
  EndIf;

  // CLEAR SFL
  *In44 = *On;
  Write F5C;
  *In44 = *Off;

  Clear rrnf5;
  Clear SELECT;

  // FILL SFL
  PRPSQLF5();
  GETSQLF5();
  DoW NOT EOF;
    filelib = sf5Nme + sf5Lib;
    If *IN85;
      sf5Keys = fleDes;
    Else;
      sf5Keys = #$GetKeys(sf5Lib:sf5Nme);
    EndIf;
    rrnf5 = rrnf5 + 1;
    Write F5S;
    If RRNF5>4000;
      Leave;
    EndIf;
    GETSQLF5();
  EndDo;
  CLSSQLF5();

  NUMRCF5 = rrnf5;

End-Proc;


Dcl-Proc VALDF5;

  Clear againF5;

  // VALIDATE SFL OPTIONS
  For X = 1 to NUMRCF5;
    Chain X F5S ;
    If not %found();
      ITER;
    EndIf;

    If *in26;
      againF5 = 'Y';
    EndIf;

  EndFor;

End-Proc;


Dcl-Proc UPDTF5;

  // CHECK SFL FOR OPTIONS ENTERED
  For XF5 = 1 to NUMRCF5;
    Chain XF5 F5S ;
    *in76 = (%found() = *Off);
    If *In76;
      ITER;
    EndIf;

    // S=DISPLAY SOURCE
    If SELECT='S';
      CRNF5 = XF5;
      againF5 = 'Y';
      #$CMD('STRSEU SRCFILE(' + %trim(SF5LIB) + '/QDDSSRC) +
                       SRCMBR(' + %trim(SF5Nme) + ') OPTION(5)');
    EndIf;

    // X=VIEW FIELDS
    If SELECT<>'S' AND SELECT<>'F' AND SELECT<>'D' AND SELECT<>' ';
      CRNF5 = XF5;
      againF5 = 'Y';
      #$CMD('DSPFLE FILE(' + %trim(SF5LIB) + '/' + %trim(sf5Nme) + ')');
    EndIf;

    // F=VIEW FILE STATS
    If SELECT='F';
      CRNF5 = XF5;
      againF5 = 'Y';
      #$CMD('DSPFILD FILE(' + %trim(SF5LIB) + '/' + %trim(sf5Nme) + ')');
    EndIf;

    // D=WHERE USED
    If SELECT='D';
      CRNF1 = XF1;
      againF5 = 'Y';
      #$CMD('D ' + %trim(SF5LIB) + '/' + %trim(sf5Nme));
    EndIf;

  EndFor;

End-Proc;


Dcl-Proc PRPSQLF5;
  // BUILDS AN SQL STATEMENT, AND OPENS A CURSOR TO IT

  // THIS PROGRAM FIRST HAS TO CREATE A LIST OF ALL DEPENDANT FILE
  // IT USES DSPDBR TO DO THIS, THEN QUERIES THAT FILE
  #$CMD('DLTF QTEMP/BLDLFTMP':1);
  #$CMD('DSPDBR ' + %trim(fleLib) + '/' + %trim(fleNme) +
              ' OUTPUT(*OUTFILE) OUTFILE(QTEMP/BLDLFTMP)');

  EOF=*OFF;

  // SETUP SQL SELECT STATEMENT
  sqlStmF5='SELECT WHREFI, WHRELI +
                  FROM QTEMP/BLDLFTMP +
                  WHERE WHREFI<>'' ''';

  // PREPARE THE STATEMENT, SETUP THE CURSOR AND OPEN IT
  Exec SQL PREPARE SQLF5 FROM :sqlStmF5;
  Exec SQL DECLARE SQLCRSF5 CURSOR FOR SQLF5;
  Exec SQL OPEN SQLCRSF5;

End-Proc;


Dcl-Proc GETSQLF5;

  Exec SQL FETCH NEXT FROM SQLCRSF5
         INTO :sf5Nme, :SF5LIB;

  If SQLSTT <> '00000';
    EOF = *ON;
  EndIf;

End-Proc;


Dcl-Proc CLSSQLF5;

  Exec SQL CLOSE SQLCRSF5;

End-Proc;


**  ERROR MESSAGES - EMA
           YOU ARE ALREADY AT THE TOP.             01
          YOU ARE ALREADY AT THE BOTTOM.           02
          ERROR - INVALID FUNCTION KEY.            03
         ERROR - INVALID OPTION ENTERED.           04
          ERROR - INVALID EMAIL ENTERED.           05
            ERROR - SROUCE NOT FOUND.              06
