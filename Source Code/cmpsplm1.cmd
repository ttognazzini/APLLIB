/********************************************************************/
/* COMPARE SPOOL FILE                                               */
/********************************************************************/
/* CRTCMD CMD(APLLIB/CMPSPLF)                                       */
/*        PGM(APLLIB/CMPSPLC1)                                      */
/*        SRCFILE(APLLIB/QSRC)                                      */
/*        SRCMBR(CMPSPLM1)                                          */
/*        REPLACE(*YES)                                             */
/********************************************************************/
             CMD        PROMPT('Compare Spool Files') HLPID(*CMD) +
                          HLPPNLGRP(CMPSPLP1)

             PARM       KWD(SPLFILE1) TYPE(*NAME) MIN(1) +
                          PROMPT('Spooled file 1')

             PARM       KWD(JOB1) TYPE(JOB) DFT(*) SNGVAL((*)) +
                          PROMPT('Job name 1')
 JOB:        QUAL       TYPE(*NAME) +
                          EXPR(*YES)
             QUAL       TYPE(*NAME) +
                          EXPR(*YES) PROMPT('User')
             QUAL       TYPE(*CHAR) LEN(8) EXPR(*YES) +
                          CHOICE('000000-999999') PROMPT('Number')

             PARM       KWD(SPLNBR1) TYPE(*CHAR) LEN(11) DFT(*ONLY) +
                          SPCVAL((*ONLY) (*LAST) (*ANY)) +
                          PROMPT('Spooled file number 1')

             PARM       KWD(SPLFILE2) TYPE(*NAME) MIN(1) +
                          PROMPT('Spooled file 2')

             PARM       KWD(JOB2) TYPE(JOB) PROMPT('Job name 2') +
                        DFT(*) SNGVAL((*))

             PARM       KWD(SPLNBR2) TYPE(*CHAR) LEN(11) DFT(*ONLY) +
                          SPCVAL((*ONLY) (*LAST) (*ANY)) +
                          PROMPT('Spooled file number 2')

             PARM       KWD(CMPTYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*LINE) VALUES(*LINE *FILE *WORD) +
                          SPCVAL((*LINE) (*FILE) (*WORD)) +
                          CHOICE('*LINE, *FILE, *WORD') +
                          PROMPT('Compare type')
             PARM       KWD(RPTTYPE) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*DIFF) VALUES(*DIFF *SUMMARY *CHANGE *DETAIL) +
      SPCVAL((*DIFF) (*SUMMARY) (*CHANGE) (*DETAIL)) PROMPT('Report type') +
                          CHOICE('*DIFF, *SUMMARY, *CHANGE...')
             PARM       KWD(OUTPUT) TYPE(*CHAR) LEN(8) RSTD(*YES) +
                          DFT(*) VALUES(* *OUTPUT *PRINT) +
                          SPCVAL((*) (*OUTPUT) (*PRINT)) PROMPT('Output') +
                          CHOICE('*, *PRINT, *OUTFILE')

             PARM       KWD(OUTFILE) TYPE(FILE) PROMPT('File to receive output')
 FILE:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB) (*LIBL)) PROMPT('Library')

          PARM   KWD(OUTMBR) TYPE(*CHAR) PROMPT('Member to receive output') +
                         LEN(10) DFT(*FIRST) SPCVAL((*FIRST))
          PARM KWD(ADDRPL) TYPE(*CHAR) LEN(8) DFT(*REPLACE) SPCVAL((*REPLACE) +
                          (*ADD)) PROMPT('Replace or add records') +
                          CHOICE('*REPLACE, *ADD')

