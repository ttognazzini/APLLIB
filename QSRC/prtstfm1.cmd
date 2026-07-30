/*    CRTCMD CMD(APLLIB/PRTSTMF)                             */
/*           PGM(APLLIB/PRTSTFB1)                            */
/*           SRCFILE(APLLIB/QSRC)                            */
/*           SRCMBR(PRTSTFM1)                                */
/*           REPLACE(*YES)                                   */

CMD PROMPT('Print Raw Stream File')

PARM KWD(STMF) TYPE(*CHAR) LEN(256) VARY(*YES +
     *INT2) CHOICE('IFS Path') PROMPT('Stream +
     file to print') MIN(1)

PARM KWD(OUTQ) TYPE(*CHAR) LEN(10) PROMPT('Output +
     Queue to print on') MIN(1)

