       Ctl-Opt Option(*srcStmt) DftActGrp(*NO) BndDir('APLLIB/APLLIB');

       // Easy Excel File Parser - Test 1

       Dcl-F QSYSPRT PRINTER(132) OFLIND(*INOF);
      /COPY APLLIB/QSRC,XLPSRVV1PR // Easy Excel file parser

       Dcl-S year packed(4) inz(0);
       Dcl-S part char(10) inz(' ');
       Dcl-S desc char(30) inz(' ');
       Dcl-S salea packed(11:2) inz(0);
       Dcl-S saleb packed(11:2) inz(0);
       Dcl-S salec packed(11:2) inz(0);
       Dcl-S saled packed(11:2) inz(0);

       // Process the file and create qtemp/xlpwk
       XLPOPEN('/tmp/november_sales.xlsx');

       // The first row has the year in column 8
       XLPREAD();

       Monitor;
         year = %dech(XLPNEXT(8):8:0);
       On-Error;
         Clear year;
       EndMon;

       // Skip the second row, it just contains the headers
       XLPREAD();

       EXCEPT #HDR;

        // Loop through the file, all rows after 4 are detail rows
       DOW XLPREAD;
         part  = XLPNEXT();
         desc  = XLPNEXT();
         Monitor;
           salea = %dech(XLPNEXT():11:2);
         On-Error;
           Clear salea;
         EndMon;
         Monitor;
         saleb = %dech(XLPNEXT():11:2);
         On-Error;
           Clear salea;
         EndMon;
         Monitor;
         salec = %dech(XLPNEXT():11:2);
         On-Error;
           Clear salea;
         EndMon;
         Monitor;
         saled = %dech(XLPNEXT():11:2);
         On-Error;
           Clear salea;
         EndMon;
         If *InOF;
           EXCEPT #HDR;
         Endif;
         EXCEPT #DTL;
       ENDDO;

       XLPCLOSE();
       *INLR = *ON;
       RETURN;

     C***********************************************************************
     OQSYSPRT   E            #HDR              3
     O                       *DATE         Y     10
     O                                           55 'ACME Widget Sales for'
     O                       YEAR          Z     60
     O                                           80 'XLPSRVB1'
     O                                           92 'Page'
     O                       PAGE          Z     96
     O*
     O          E            #HDR        2
     O                                            4 'Item'
     O                                           22 'Description'
     O                                           54 'Qtr 1'
     O                                           68 'Qtr 2'
     O                                           82 'Qtr 3'
     O                                           96 'Qtr 4'
     O*
     O          E            #DTL        1
     O                       PART                10
     O                       DESC                +1
     O                       SALEA         L     +1
     O                       SALEB         L     +1
     O                       SALEC         L     +1
     O                       SALED         L     +1
