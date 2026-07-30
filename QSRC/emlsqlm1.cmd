 /* CRTCMD CMD(APLLIB/EMLSQL)                                      +
           PGM(*LIBL/EMLSQLB1)                                     +
           SRCFILE(APLLIB/QSRC)                                    +
           SRCMBR(EMLSQLM1)                                        +
           REPLACE(*YES)                                           */
             CMD        PROMPT('Email SQL as a File') TEXT(*CMDPMT) +
                          HLPID(EMLSQL) HLPPNLGRP(EMLSQL)

             PARM       KWD(SQL) TYPE(*CHAR) LEN(5000) MIN(1) +
                          PROMPT('SQL Statement')
             PARM       KWD(FILE) TYPE(*CHAR) LEN(123) MIN(0) +
                          PROMPT('FILE NAME')
             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*XLS) VALUES(*XLS *XML *CSV *JSON) MIN(0) +
                          PROMPT('FILE TYPE')
             PARM       KWD(READABLE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) MIN(0) +
                          PROMPT('READABLE JSON FILE') PMTCTL(P3)
             PARM       KWD(ZIP) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('ZIP FILE')
             PARM       KWD(USETEXT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) MIN(0) +
                          PROMPT('USE FIELD TEXT')
             PARM       KWD(SHEET) TYPE(*CHAR) LEN(32) +
                          MIN(0)  +
                          PROMPT('SHEET NAME')
             PARM       KWD(TITLE1) TYPE(*CHAR) LEN(80) DFT(*NONE) +
                          MIN(0) PROMPT('TITLE LINE 1')
             PARM       KWD(TITLE2) TYPE(*CHAR) LEN(80) +
                          MIN(0)  DFT(*NONE) +
                          PROMPT('TITLE LINE 2')
             PARM       KWD(TITLE3) TYPE(*CHAR) LEN(80) +
                          MIN(0)  DFT(*NONE) +
                          PROMPT('TITLE LINE 3')
             PARM       KWD(TITLE4) TYPE(*CHAR) LEN(80) +
                          MIN(0)  DFT(*NONE) +
                          PROMPT('TITLE LINE 4')
             PARM       KWD(TITLE5) TYPE(*CHAR) LEN(80) +
                          MIN(0)  DFT(*NONE) +
                          PROMPT('TITLE LINE 5')
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(50) DFT(*CURRENT) +
                          SPCVAL((*CURRENT ' ') (*RPTDSTID +
                          '*RPTDSTID')) MIN(0) MAX(50) PROMPT('To +
                          Email Address(es)')
             PARM       KWD(RPTDSTID) TYPE(*CHAR) LEN(10) PMTCTL(P2) +
                          PROMPT('REPORT DISTRIBUTION ID')
             PARM       KWD(SUBJECT) TYPE(*CHAR) LEN(128) DFT(*NONE) +
                          MIN(0) PROMPT('Subject')
             PARM       KWD(MESSAGE) TYPE(MESSAGE) DFT(*NONE) +
                          MIN(0) PROMPT('Message') SNGVAL(*NONE)
             PARM       KWD(EMPTY) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES('*YES' '*NO') MIN(0) +
                          PROMPT('Send Empty File')

             PARM       KWD(OBJ) TYPE(OBJ) +
                          MIN(0) MAX(100) PROMPT('Objects')

 MESSAGE:    ELEM       TYPE(*CHAR) LEN(5000)
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*TEXTPLAIN) VALUES(*TEXTPLAIN +
                          *TEXTHTML) PROMPT('SEND AS')

 OBJ:        ELEM       TYPE(*CHAR) LEN(128)
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*ATTACH) +
                          VALUES(*ATTACH *NO *TEXTPLAIN *TEXTHTML +
                          *ATTACHPDF *ATTACHPS *NOTE) +
                          CHOICE('*ATTACH, *TEXTPLAIN,...') +
                          PROMPT('Send as')

 P2:        PMTCTL     CTL(EMAIL) COND((*EQ '*RPTDSTID'))
 P3:        PMTCTL     CTL(TYPE) COND((*EQ '*JSON'))

             PARM       KWD(ADDSQL) TYPE(ADDSQL) +
                          MIN(0) MAX(300) PROMPT('Additional Queries')

 ADDSQL:     ELEM       TYPE(*CHAR) LEN(5000)
             ELEM       TYPE(*CHAR) LEN(32) PROMPT('SHEET NAME')
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 1')
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 2')
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 3')
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 4')
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 5')
