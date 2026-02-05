 /*  CRTCMD CMD(APLLIB/DAJ)                            */
 /*         PGM(APLLIB/DAJCMDC1)                       */
 /*         SRCFILE(APLLIB/QSRC)                       */
 /*         SRCMBR(DAJCMDM1)                           */
 /*         REPLACE(*YES)                              */
 /*                                                    */
             CMD        PROMPT('Display Active Jobs')
             PARM       KWD(SBS) TYPE(*CHAR) LEN(10) DFT(*ALL) MIN(0) +
                          PROMPT('Subsystem name:')
