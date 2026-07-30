   /*   CRTCMD CMD(APLLIB/CNTVAR)                          */
   /*          PGM(APLLIB/CNTVARB1)                        */
   /*          SRCFILE(APLLIB/QSRC)                        */
   /*          SRCMBR(CNTVARM1)                            */
   /*          REPLACE(*YES)                               */
             CMD        PROMPT('Center Variable (CHGVAR->ERM)') +
                          ALLOW(*BPGM *IPGM) HLPID(CNTVAR) +
                          HLPPNLGRP(CNTVARP1)
             PARM       KWD(VAR) TYPE(*CHAR) LEN(50) RTNVAL(*YES) +
                          PROMPT('CL variable name')
             PARM       KWD(VALUE) TYPE(*CHAR) LEN(50) EXPR(*YES) +
                          PROMPT('New value')
