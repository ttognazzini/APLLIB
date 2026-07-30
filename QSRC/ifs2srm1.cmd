/*                                                   */
/*    CRTCMD CMD(APLLIB/IFS2SRC)                     */
/*           PGM(APLLIB/IFS2SRC1)                    */
/*           SRCFILE(APLLIB/QSRC)                    */
/*           SRCMBR(IFS2SRM1)                        */
/*           REPLACE(*YES)                           */
/*                                                   */
CMD PROMPT('Copy Source Member from IFS') TEXT(*CMDPMT) HLPID(IFS2SRC) HLPPNLGRP(IFS2SRP1)

PARM IFSFILE TYPE(*CHAR) LEN(150) MIN(1) CHOICE('Full path to source file') +
             PROMPT('IFS file path') EXPR(*YES)
PARM SRCFILE TYPE(QUAL) MIN(1) PROMPT('Source File')
PARM MBR     TYPE(*CHAR) LEN(10) MIN(1) PROMPT('Member')
PARM TEXT    TYPE(*CHAR) LEN(50) PROMPT('Member Text') EXPR(*YES)
PARM MBROPT  TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*REPLACE) VALUES(*NONE *ADD *REPLACE) +
             MIN(0) CHOICE('*NONE,*ADD,*REPLACE') PROMPT('Member Option')

QUAL: QUAL  *NAME MIN(1) EXPR(*YES)
      QUAL  *NAME DFT(*LIBL) SPCVAL((*LIBL) (*CURLIB)) EXPR(*YES) PROMPT('Library')
