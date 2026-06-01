/*   CRTCMD CMD(APLLIB/PRTQRYD)                    */
/*          PGM(APLLIB/PRTQRYC1)                   */
/*          SRCFILE(APLLIB/QSRC)                   */
/*          SRCMBR(PRTQRYM1)                       */
/*          REPLACE(*YES)                          */

             CMD        PROMPT('Print Query Definition') +
                          TEXT(*CMDPMT) HLPID(PRTQRYD) +
                          HLPPNLGRP(PRTQRYP1)

             PARM       KWD(QRY) TYPE(QUAL) MIN(1) PROMPT('Query')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')
