/*********************************************************************/
/* COMMAND : ANLSRCF                                                 */
/* FUNCTION: ANALYSE SOURCE FILES                                    */
/*           CPP = ANLSRCC1                                          */
/*           VCP = ANLSRCC5                                          */
/* CREATE  : CRTCMD CMD(APLLIB/ANLSRCF)                              */
/*                  PGM(APLLIB/ANLSRCC1)                             */
/*                  SRCFILE(APLLIB/QSRC)                             */
/*                  SRCMBR(ANLSRCM1)                                 */
/*                  REPLACE(*YES)                                    */
/* Author  : Werner Noll                                             */
/* Remarks : This is free software.                                  */
/*           You can redistribute it and/or modify it.               */
/*           The only restriction is that you may not distribute     */
/*           it for the purposes of monetary gain.                   */
/*           We do not garantee for the expected functionalties.     */
/*           The use of this software is always at your own risk.    */
/*           All comments or reuqests for enhancements are           */
/*           welcome. My email: werner.noll@gefis.com.               */
/*********************************************************************/
             CMD        PROMPT('Analyse Source Files') +
                          ALLOW(*INTERACT *IPGM) +
                          VLDCKR(APLLIB/ANLSRCC5) HLPID(*CMD) +
                          HLPPNLGRP(APLLIB/ANLSRCP1)
             PARM       KWD(SRCFILE) TYPE(QUALI) PROMPT('Source file')
 QUALI:      QUAL       TYPE(*NAME) SPCVAL((*RPG) (*CL) (*CMD) +
                          (*ALL)) MIN(1)
             QUAL       TYPE(*GENERIC) SPCVAL((*ALLUSR)) MIN(1) +
                          PROMPT('Library')
             PARM       KWD(STRING_1) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 1')
             PARM       KWD(STRING_2) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 2')
             PARM       KWD(STRING_3) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 3')
             PARM       KWD(STRING_4) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 4')
             PARM       KWD(STRING_5) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 5')
             PARM       KWD(STRING_6) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 6')
             PARM       KWD(STRING_7) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 7')
             PARM       KWD(STRING_8) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 8')
             PARM       KWD(STRING_9) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 9')
             PARM       KWD(STRING_10) TYPE(*CHAR) LEN(10) +
                          CASE(*MIXED) PROMPT('Search string 10')
             PARM       KWD(CASE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(2) VALUES(1 2) MIN(0) PROMPT('1=Same +
                          case, 2=Ignore case')
             PARM       KWD(SBMJOB) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(Y) VALUES(Y N) MIN(0) PROMPT('Submit +
                          to batch')
