 /*  CRTCMD CMD(APLLIB/DBGBCH)                                       */
 /*         PGM(APLLIB/DBGBCHC1)                                     */
 /*         SRCFILE(APLLIB/QSRC)                                     */
 /*         SRCMBR(DBGBCHM1)                                         */
 /*         REPLACE(*YES)                                            */

             CMD        PROMPT('Start Debug for Batch Job') +
                          TEXT(*CMDPMT) HLPID(DBGBCH) +
                          HLPPNLGRP(APLLIB/DBGBCHP1)
             PARM       KWD(USRPRF) TYPE(*NAME) LEN(10) +
                          DFT(*CURRENT) SPCVAL((*CURRENT *CURRENT)) +
                          PROMPT('User Profile:')
