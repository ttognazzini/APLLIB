/*   CRTCMD   CMD(APLLIB/CHGOTQ) PGM(*LIBL/CHGOTQC1) */

             CMD        PROMPT('Change Output Queue') +
                        HLPID(CHGOTQ) HLPPNLGRP(CHGOTQP1)

             PARM       KWD(OUTQ) TYPE(QUAL) MIN(1) PROMPT('Out Queue')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')
