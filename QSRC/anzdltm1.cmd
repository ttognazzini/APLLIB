/*-------------------------------------------------------------------*/
/*  Compile options:                                                 */
/*    CRTCMD CMD(APLLIB/ANZDLT)                                      */
/*           PGM(APLLIB/ANZDLTB1)                                    */
/*           SRCFILE(APLLIB/QSRC)                                    */
/*           SRCMBR(ANZDLTM1)                                        */
/*           REPLACE(*YES)                                           */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Analyze Deleted Records') +
                          TEXT(*CMDPMT) HLPID(ANZDLT) +
                          HLPPNLGRP(APLLIB/ANZDLTP1)

             PARM       KWD(LIB) TYPE(*NAME) MIN(1) PROMPT('Library')

             PARM       KWD(EMAILTO) TYPE(*CHAR) LEN(50) +
                          PROMPT('Email to address')

             PARM       KWD(REORG) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) +
                          PROMPT('Reorganize Files')

