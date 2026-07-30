/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CRTCMD CMD(APLLIB/CHGUSR)                                      */
/*           PGM(APLLIB/CHGUSRB1)                                    */
/*           SRCFILE(APLLIB/QSRC)                                    */
/*           SRCMBR(CHGUSRM1)                                        */
/*           REPLACE(*YES)                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Change Jobs User') TEXT(*CMDPMT) +
                          HLPID(*CMD) HLPPNLGRP(APLLIB/CHGUSRP1)

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(' ') +
                          PROMPT(USER)

