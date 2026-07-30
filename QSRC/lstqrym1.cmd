/*   CRTCMD CMD(APLLIB/LSTQRY)                     */
/*          PGM(APLLIB/LSTQRYB1)                   */
/*          SRCFILE(APLLIB/QSRC)                   */
/*          SRCMBR(LSTQRYM1)                       */
/*          REPLACE(*YES)                          */

             CMD        PROMPT('List Query Details') TEXT(*CMDPMT) +
                          HLPID(LSTQRY) HLPPNLGRP(LSTQRYP1)

             PARM       KWD(QRY) TYPE(QUAL) MIN(1) PROMPT('Query')
 QUAL:       QUAL       TYPE(*GENERIC) SPCVAL((*ALL) (*ALL)) MIN(1) +
                          EXPR(*YES) CHOICE('Name, generic*, *ALL')
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')

             PARM       KWD(OUTF) TYPE(QUAL2) PROMPT('Output File')
 QUAL2:      QUAL       TYPE(*NAME) DFT(LSTQRYF) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(QTEMP) EXPR(*YES) PROMPT('Library')
