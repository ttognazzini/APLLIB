/*  CRTCMD CMD(APLLIB/DSPWIN)                      */
/*         PGM(APLLIB/DSPWINB1)                    */
/*         SRCFILE(APLLIB/QSRC)                    */
/*         SRCMBR(DSPWINM1)                        */
/*         REPLACE(*YES)                           */

             CMD        PROMPT('Display Text in a Window') +
                          TEXT(*CMDPMT) HLPID(DSPWIN) +
                          HLPPNLGRP(APLLIB/DSPWINP1)

             PARM       KWD(WINTXT) TYPE(*CHAR) LEN(2000) MIN(1) +
                          PROMPT('Text to Display')
