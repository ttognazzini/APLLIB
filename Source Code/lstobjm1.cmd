/*  CRTCMD CMD(APLLIB/LSTOBJ)                                 */
/*         PGM(APLLIB/LSTOBJB1)                               */
/*         SRCFILE(APLLIB/QSRC)                               */
/*         SRCMBR(LSTOBJM1)                                   */
/*         REPLACE(*YES)                                      */
             CMD        PROMPT('List Library Objects with Size') +
                          TEXT(*CMDPMT) HLPID(LSTOBJ) +
                          HLPPNLGRP(APLLIB/LSTOBJP1)

             PARM       KWD(LIBRARY) TYPE(*NAME) LEN(10) +
                          SPCVAL((*ALLUSR *ALLUSR) (*LIBL *LIBL) +
                          (*ALL *ALL)) MIN(1) PROMPT('Library')

             PARM       KWD(EMAILTO) TYPE(*CHAR) LEN(50) +
                          MIN(1) CHOICE('Email Address') +
                          PROMPT('Email To')

