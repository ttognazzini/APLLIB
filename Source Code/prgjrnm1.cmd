/*  CRTCMD CMD(APLLIB/PRGJRNRCV)                     */
/*         PGM(APLLIB/PRGJRNB1)                      */
/*         SRCFILE(APLLIB/QSRC)                      */
/*         SRCMBR(PRGJRNM1)                          */
/*         REPLACE(*YES)                             */
/*                                                   */
             CMD        PROMPT('Purge Journal Receivers') +
                          HLPID(PRGJRNRCV) HLPPNLGRP(APLLIB/PRGJRNP1)

             PARM       KWD(JRNRCV) TYPE(QUAL) MIN(1) +
                          PROMPT('Journal Receiver')
 QUAL:       QUAL       TYPE(*GENERIC) LEN(10) SPCVAL((*ALL *ALL)) +
                          MIN(1) EXPR(*YES)
             QUAL       TYPE(*GENERIC) SPCVAL((*LIBL *LIBL) (*CURLIB +
                          *CURLIB) (*USRLIBL *USRLIBL) (*ALL *ALL) +
                          (*ALLUSR *ALLUSR)) MIN(1) EXPR(*YES) +
                          PROMPT('Library')

             PARM       KWD(PRGDAYS) TYPE(*DEC) LEN(4) DFT(180) +
                          REL(*GT 1) MIN(0) PROMPT('Days Old to Purge')

             PARM       KWD(PURGE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) SPCVAL((*YES *YES) (*NO *NO)) +
                          MIN(0) CHOICE('*YES, *NO for list only') +
                          PROMPT('Purge Receivers')

             PARM       KWD(PRGUNSAVED) TYPE(*CHAR) LEN(4) +
                          RSTD(*YES) DFT(*YES) SPCVAL((*YES *YES) +
                          (*NO *NO)) MIN(0) PROMPT('Purge Un-Saved +
                          Journals')

             PARM       KWD(EXCLIB) TYPE(*GENERIC) LEN(10) +
                          MIN(0) MAX(50) PROMPT('Exclude Libraries') +
                          SPCVAL((*LIBL *LIBL) (*CURLIB +
                          *CURLIB) (*USRLIBL *USRLIBL) (*ALL *ALL) +
                          (*ALLUSR *ALLUSR))

             PARM       KWD(PRTOPT) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*PURGED) SPCVAL((*PURGED *PURGED) +
                          (*SAVED *SAVED) (*ALL *ALL) (*NOLIST *NOLIST)) MIN(0) +
                          PROMPT('Print Option')

