/*  CRTCMD CMD(APLLIB/QRYJOBLOG)   */
/*         PGM(*LIBL/QRYLOGM1)     */
/*         SRCFILE(APLLIB/QSRC)    */
/*         SRCMBR(QRYLOGM1)        */
/*         REPLACE(*YES)           */
 CLNSRC:     CMD        PROMPT('Querry Job Log') HLPID(*CMD) +
                          HLPPNLGRP(QRYLOGP1)

             PARM       KWD(WRKSTN) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Workstation')

