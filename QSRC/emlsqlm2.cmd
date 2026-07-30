 /* CRTCMD CMD(APLLIB/SQL2XLS)                                     +
           PGM(*LIBL/EMLSQLB2)                                     +
           SRCFILE(APLLIB/QSRC)                                    +
           SRCMBR(EMLSQLM2)                                        +
           REPLACE(*YES)                                           */
             CMD        PROMPT('SQL to Excel') TEXT(*CMDPMT) +
                          HLPID(SQL2XLS) HLPPNLGRP(EMLSQLP2)

             PARM       KWD(SQL) TYPE(*CHAR) LEN(5000) MIN(1) +
                          PROMPT('SQL Statement')
             PARM       KWD(FILE) TYPE(*CHAR) LEN(128) MIN(1) +
                          PROMPT('PATH AND FILE NAME')
             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*XLS) VALUES(*XLS *XML *CSV) MIN(0) +
                          PROMPT('FILE TYPE')
             PARM       KWD(EMPTY) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES('*YES' '*NO') MIN(0) +
                          PROMPT('Create Empty File')
             PARM       KWD(USETEXT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) MIN(0) +
                          PROMPT('USE FIELD TEXT')
             PARM       KWD(SHEET) TYPE(*CHAR) LEN(32) +
                          MIN(0)  +
                          PROMPT('SHEET NAME')
             PARM       KWD(TITLE1) TYPE(*CHAR) LEN(80) +
                          MIN(0)  DFT(*NONE) +
                          PROMPT('TITLE LINE 1')
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

