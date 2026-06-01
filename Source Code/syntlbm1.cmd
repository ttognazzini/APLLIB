 /*===============================================================*/
 /* TO COMPILE:                                                   */
 /*                                                               */
 /*           CRTCMD CMD(APLLIB/SYNCTEXT)                         */
 /*                  PGM(APLLIB/SYNTLBB1)                         */
 /*                  SRCFILE(APLLIB/QSRC)                         */
 /*                  SRCMBR(SYNTLBM1)                             */
 /*                  REPLACE(*YES)                                */
 /*                                                               */
 /*===============================================================*/
             CMD        PROMPT('Sync Test Library') TEXT(*CMDPMT) +
                          HLPID(SYNCTEST) HLPPNLGRP(APLLIB/SYNTLBP1)

             PARM       KWD(PRDLIB) TYPE(*NAME) PROMPT('From Library +
                          (Production)')  MIN(1)

             PARM       KWD(TSTLIB) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('To Library (Test)')

             PARM       KWD(REFRESH) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) SPCVAL((*NO +
                          *NO) (*YES *YES)) MIN(0) PROMPT('Refresh +
                          Data Objects')

             PARM       KWD(EMAILTO) TYPE(*CHAR) LEN(50) +
                          MIN(1) CHOICE('Email Address') +
                          PROMPT('Email To')

