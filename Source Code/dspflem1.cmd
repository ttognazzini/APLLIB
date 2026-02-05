/*  CRTCMD CMD(APLLIB/DSPFLE)                        */
/*         PGM(APLLIB/DSPFLED1)                      */
/*         SRCFILE(APLLIB/QSRC)                      */
/*         SRCMBR(DSPFLEM1)                          */
/*         REPLACE(*YES)                             */
/*                                                   */
/* Also create as FSM to work with the xSM commands  */
/*  CRTCMD CMD(APLLIB/FSM)                           */
/*         PGM(APLLIB/DSPFLED1)                      */
/*         SRCFILE(APLLIB/QSRC)                      */
/*         SRCMBR(DSPFLEM1)                          */
/*         REPLACE(*YES)                             */
             CMD        PROMPT('Display File Fields')
             PARM       KWD(FILE) TYPE(QUAL) MIN(1) PROMPT('File')
 QUAL:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')
