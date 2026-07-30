/*                                               */
/*  CRTCMD CMD(APLLIB/SRC2IFS)                   */
/*         PGM(APLLIB/SRC2IFC1)                  */
/*         SRCFILE(APLLIB/QSRC)                  */
/*         SRCMBR(SRC2IFM1)                      */
/*         REPLACE(*YES)                         */
/*                                                 */
CMD PROMPT('Source Member to IFS File') TEXT(*CMDPMT) HLPID(SRC2IFS) HLPPNLGRP(SRC2IFP1)

 PARM SRCFILE TYPE(QUAL) MIN(1) PROMPT('Source File')
 PARM MBR     TYPE(*CHAR) LEN(10) MIN(1) PROMPT('Member') EXPR(*YES)
 PARM RTEPATH TYPE(*CHAR) LEN(150) DFT(*DFTLIB) MIN(0) CHOICE('NAME, *DFT, +
              *DFTLIB') PROMPT('Root Path')

 QUAL: QUAL *NAME MIN(1) EXPR(*YES)
       QUAL *NAME DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB)) EXPR(*YES) PROMPT('Library')
