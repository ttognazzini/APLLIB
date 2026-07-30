 /* CRTCMD CMD(APLLIB/SQL2JSON)                                    +
           PGM(*LIBL/EMLSQLB3)                                     +
           SRCFILE(APLLIB/QSRC)                                    +
           SRCMBR(EMLSQLM3)                                        +
           REPLACE(*YES)                                           */
             CMD        PROMPT('SQL to JSON') TEXT(*CMDPMT) +
                          HLPID(SQL2JSON) HLPPNLGRP(EML2SQLP3)

             PARM       KWD(SQL) TYPE(*CHAR) LEN(5000) MIN(1) +
                          PROMPT('SQL Statement')
             PARM       KWD(FILE) TYPE(*CHAR) LEN(128) MIN(1) +
                          PROMPT('PATH AND FILE NAME')
             PARM       KWD(EMPTY) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES('*YES' '*NO') MIN(0) +
                          PROMPT('Create Empty File')
             PARM       KWD(READBLE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES('*YES' '*NO') MIN(0) +
                          PROMPT('Readable JSON File')
             PARM       KWD(USETEXT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) MIN(0) +
                          PROMPT('USE FIELD TEXT')
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
