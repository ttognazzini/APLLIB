       Ctl-Opt Option(*srcStmt) DftActGrp(*NO) BndDir('APLLIB/APLLIB');
        // This program demonstrates parsing a spreadsheet with the
        //  XLPARSER4 service program and uses the xlparse_notify()
        //  routine to determine where rows start/end.

       Dcl-F QSYSPRT PRINTER(132) OFLIND(*INOF);

      //COPY APLLIB/QSRC,XLPSRVV1PR // Easy Excel file parser
      /copy QSRC,XLPARSV1PR

       // DEFINE THE INPUT VARIABLES TO READ THE EXCEL FIELDS INTO
       // THIS HAS TO BE DONE IN THE MAINLINE PROGRAM, NOT ONE OF THE
       // PROCESSING PROCEDURES, SO THE VARIABLES ARE GLOBAL
       Dcl-S year packed(4) inz(0);
       Dcl-S part char(10) inz(' ');
       Dcl-S desc char(30) inz(' ');
       Dcl-S salea packed(11:2) inz(0);
       Dcl-S saleb packed(11:2) inz(0);
       Dcl-S salec packed(11:2) inz(0);
       Dcl-S saled packed(11:2) inz(0);

       Dcl-S fileName char(50);
       Dcl-S msg char(50);
       Dcl-S wait char(1);

     C     *ENTRY        PLIST
     C                   PARM                    PEXSSF            1

        // SETON OVERLFOW INDICATOR SO THE FIRST PAGE HEADING PRINT
       *INOF=*ON;

        // SETUP THE NOTIFICATION PROCEDURES
       XLPARSE_NOTIFY( %PADDR(#$XLPSTR) : %PADDR(#$XLPEND) );

        // SELECT THE FILE TO USE. THIS PROCEDURE DEMONSTRATES USING THE OLDER
        // BIF8 FROMAT FROM EXCEL BEFORE 2003 AND THE NEWE OOXML FORMAT USED
        // 2003 AND LATER, YOU DO NOT HAVE TO DO ANYTHING DIFFERENT, THE PROGRAM
        // WILL LOOK AT THE FILE TYPE AND FUNCTION THE SAME.
       IF (%PARMS>=1 AND PEXSSF<>'1');
         FILENAME = '/tmp/november_sales.xlsx';
       ELSE;
         FILENAME = '/tmp/november_sales.xls';
       ENDIF;

        // THIS PARSES THE ENTIRE FILE. IT WILL CALL THE FUNCTIONS PASSED
        // IN THIS CALL AND THE ONES SETUP IN THE NOTIFICATION PROCEDURE ABOVE
        // ALL WORK IS DONE IN THE PROCEDURES. tHE FOLLWING IS THE LIST OF
        // PROCEDURES USED:
        //       #$XLPSTR  = CALLED WHEN A NEW ROW IS STARTED
        //       #$XLPNUM  = CALLED IF A NUMERIC CELL IS READ
        //       #$XLPCHR  = CALLED IF A CHARACTER CELL IS READ
        //       #$XLPFRM  = CALLED WHEN A FORMUAL CELL IS READ, OPTIONAL
        //                   THIS IS CONSIDERED EXPERIMENTAL
        //       #$XLPEND  = CALLED WHEN ALL DATA HAS BEEN READ FROM THE ROW
        // THESE PROCEDURES ARE PROTOTYPED IN THE INCLUDE FILE TO MAKE WRITING CODE
        // EASIER. THIS MEANS YOU HAVE TO USE THE EXACT SAME PROCEDURE NAMES
        // IN ALL PROGRAMS.

        // THE CALL TO THE XLPARSE_WORKBOOK RETUNS A 0 IF THERE WERE NOT ERRORS
        // WE CALL IT INSIDE THE IF STATMENT TO PROCESS THE CALL AND TEST FOR
        // ERRORS AT THE SAME TIME. THE CODE BELOW JUST DISPLAYS A MESSAGE IF
        // AN ERROR OCCURED, IN PRACTICE IT SHOULD DO SOMETHING TO HANDLE THE ERROR
       IF XLPARSE_WORKBOOK(%TRIM(FILENAME):%PADDR(#$XLPNUM):%PADDR(#$XLPCHR)
                           :*NULL) <> 0;
          MSG = 'Error occcured. See job log.';
          DSPLY (MSG) ' ' WAIT;
        ENDIF;

        // THIS DISABLES NOTIFICATIONS
        XLPARSE_NOTIFY( *NULL: *NULL );

        *INLR = *ON;
        RETURN;

     O**********************************************************************
     OQSYSPRT   E            #HDR              3
     O                       *DATE         Y     10
     O                                           55 'ACME Widget Sales for'
     O                       YEAR          Z     60
     O                                           80 'XLPSRVB2'
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


        //****************************************************************
        // THIS IS CALLED ONCE FOR EACH CHARACTER CELL IN THE SPREADSHEET
        // THE PROCEDURE NAME AND INTERFACE MUST STAY THE SAME
        //****************************************************************
       Dcl-Proc #$XLPCHR;
         Dcl-PI #$XLPCHR Ind;
           SHEET          Varchar(1024)  CONST;
           ROW            Int(10)    VALUE;
           COLUMN         Int(5)     VALUE;
           VALUE          Varchar(32767)  CONST;

            // IF ROW 4 OR LATER READ IN DETAIL VALUES
          End-PI;
         IF (ROW >= 4);

           SELECT;
             WHEN COLUMN = 0;
               PART = VALUE;
             WHEN COLUMN = 1;
               DESC = VALUE;
           ENDSL;

         ENDIF;

         RETURN *OFF;

       End-Proc;

        //****************************************************************
        // THIS IS CALLED ONCE FOR EACH NUMERIC CELL IN THE SPREADSHEET
        // THE PROCEDURE NAME AND INTERFACE MUST STAY THE SAME
        //****************************************************************
       Dcl-Proc #$XLPNUM;
         Dcl-PI #$XLPNUM Ind;
           SHEET          Varchar(1024)  CONST;
           ROW            Int(10)    VALUE;
           COLUMN         Int(5)     VALUE;
           VALUE          Float(8)   VALUE;

            // SAVE YEAR
          End-PI;
         IF (ROW=0 AND COLUMN=7);
           YEAR=VALUE;
         ENDIF;

          // SALES FIGURES ARE IN COLUMNS C,D,E,F OF EACH ROW BEYOND ROW 4
         IF (ROW >= 4);

           SELECT;
             WHEN COLUMN=2;
               SALEA =VALUE;
             WHEN COLUMN=3;
               SALEB =VALUE;
             WHEN COLUMN=4;
               SALEC =VALUE;
             WHEN COLUMN=5;
               SALED =VALUE;
           ENDSL;

         ENDIF;

         RETURN *OFF;

       End-Proc;

        //****************************************************************
        // THIS IS CALLED BEFORE EACH ROW THAT HAS DATA
        // THE PROCEDURE NAME AND INTERFACE MUST STAY THE SAME
        //****************************************************************
       Dcl-Proc #$XLPSTR;
         Dcl-PI #$XLPSTR;
           SHEET          Varchar(1024)  CONST;
           ROW            Int(10)    VALUE;

            // CLEAR INPUT FIELDS FOR THE DETAIL RECORDS
          End-PI;
         PART  = ' ';
         DESC  = ' ';
         SALEA = 0;
         SALEB = 0;
         SALEC = 0;
         SALED = 0;

       End-Proc;

        //****************************************************************
        // THIS IS CALLED AFTER EACH ROW THAT HAS DATA
        // THE PROCEDURE NAME AND INTERFACE MUST STAY THE SAME
        //****************************************************************
       Dcl-Proc #$XLPEND;
         Dcl-PI #$XLPEND;
           SHEET          Varchar(1024)  CONST;
           ROW            Int(10)    VALUE;

            // PRINT DETAIL RECORD
          End-PI;
         IF ROW > 4;
           If *InOF;
             EXCEPT #HDR;
           Endif;
           EXCEPT #DTL;
           *InOF = *Off;
         ENDIF;

       End-Proc;
