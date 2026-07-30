/*   CRTCMD   CMD(APLLIB/DUPOTQ) PGM(*LIBL/DUPOTQC1) */

             CMD        PROMPT('Duplicate Output Queue') +
                        HLPID(DUPOTQ) HLPPNLGRP(DUPOTQP1)

             PARM       KWD(FRMOUTQ) TYPE(QUAL) MIN(1) PROMPT('From +
                          Out Queue')
             PARM       KWD(TOOUTQ) TYPE(QUAL) MIN(1) PROMPT('To +
                          Out Queue')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')
