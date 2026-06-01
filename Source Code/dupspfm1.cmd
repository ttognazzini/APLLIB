 /*===============================================================*/
  /* TO COMPILE:                                                   */
  /*                                                               */
  /*           CRTCMD CMD(APLLIB/DUPSPLF)                          */
  /*                  PGM(APLLIB/DUPSPFB1)                         */
  /*                  SRCFILE(APLLIB/QSRC)                         */
  /*                  SRCMBR(DUPSPFM1)                             */
  /*                  REPLACE(*YES)                                */
  /*                                                               */
  /*===============================================================*/
             CMD        PROMPT('Duplicate Spool File') +
                          HLPID(DUPSPLF) HLPPNLGRP(APLLIB/DUPSPFP1)

             PARM       KWD(FILE) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Spooled File')

             PARM       KWD(JOB) TYPE(Q1) DFT(*) SNGVAL((*)) +
                          PROMPT('Job Name')

             PARM       KWD(SPLNBR) TYPE(*DEC) LEN(6) DFT(*ONLY) +
                          RANGE(1 9999) SPCVAL((*ONLY 0) (*LAST +
                          -1)) PROMPT('Spooled File Number')

             PARM       KWD(USRDTA) TYPE(*CHAR) LEN(10) DFT(*SAME) +
                          PROMPT('User Data')

             PARM       KWD(OUTQ) TYPE(Q2) PROMPT('Output Queue')

             PARM       KWD(OVRUSR) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PROMPT('Override +
                          to Current User')

   Q1:         QUAL       TYPE(*NAME) LEN(10)
               QUAL       TYPE(*NAME) LEN(10) PROMPT('User')
               QUAL       TYPE(*CHAR) LEN(6) RANGE('000000' '999999') +
                            PROMPT('Number')

   Q2:         QUAL       TYPE(*NAME) LEN(10) DFT(*SAME)
               QUAL       TYPE(*NAME) LEN(10) +
                            PROMPT('Library')
