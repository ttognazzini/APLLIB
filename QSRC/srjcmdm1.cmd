 /*===============================================================*/
 /* TO COMPILE:                                                   */
 /*                                                               */
 /*           CRTCMD CMD(APLLIB/SRJ)                              */
 /*                  PGM(APLLIB/SRJCMDB1)                         */
 /*                  SRCFILE(APLLIB/QSRC)                         */
 /*                  SRCMBR(SRJCMDM1)                             */
 /*                  REPLACE(*YES)                                */
 /*                                                               */
 /*===============================================================*/
             CMD        PROMPT('Submit Restore Journal') +
                          TEXT(*CMDPMT) HLPID(SRJ) HLPPNLGRP(SRJCMDP1) +
                          PMTOVRPGM(SRJCMDC1)

             PARM       KWD(OBJ) TYPE(OBJ) PROMPT('Object') KEYPARM(*YES)
 OBJ:        QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library') +
                        SPCVAL((*LIBL)) EXPR(*YES) DFT(*LIBL)

             PARM       KWD(OBJTYPE) TYPE(*CHAR) LEN(10) MIN(0) +
                          Dft(*FILE) PROMPT('Object Type.')

             PARM       KWD(FROMDATE) TYPE(*CHAR) LEN(10) MIN(0) +
                          PROMPT('Start Date.') DFT(5)

             PARM       KWD(OUTFILE) TYPE(OUTFILE) PROMPT('Output File')
 OUTFILE:    QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library')

             PARM       KWD(JOBNAME) TYPE(*CHAR) LEN(10) MIN(0) +
                          PROMPT('Job Name')

