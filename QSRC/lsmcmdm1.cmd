/*  CRTCMD CMD(APLLIB/LSM)                                      */
/*         PGM(*LIBL/LSMCMDC1)                                  */
/*         SRCFILE(APLLIB/QSRC)                                 */
/*         SRCMBR(LSMCMDM1)                                     */
/*         REPLACE(*YES)                                        */
             CMD        PROMPT('Write Levels on a Source Mbr') TEXT(*CMDPMT) +
                          HLPID(LSM) HLPPNLGRP(APLLIB/LSMCMDP1)
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Source Member')
             PARM       KWD(SRCFLE) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          CHOICE('*SEARCH, Source File Name') +
                          PROMPT('Source File')
             PARM       KWD(SRCLIB) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          PROMPT('*SEARCH, Source Library')
             PARM       KWD(OPTION) TYPE(*CHAR) LEN(6) RSTD(*YES) +
                          DFT(*NEST) SPCVAL((*NEST *NEST) (*CLEAR +
                          *CLEAR)) PROMPT('OPTION')
