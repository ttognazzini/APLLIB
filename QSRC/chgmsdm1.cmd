/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CRTCMD CMD(APLLIB/CHGMSD)                                     */
/*           PGM(APLLIB/CHGMSDB1)                                    */
/*           SRCFILE(APLLIB/QSRC)                                    */
/*           SRCMBR(CHGMSDM1)                                        */
/*           REPLACE(*YES)                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Change Message Description') TEXT(*CMDPMT) +
                          HLPID(*CMD) HLPPNLGRP(CHGMSDP1)


             PARM       KWD(MSGID) TYPE(*CHAR) LEN(7) MIN(1) +
                          PROMPT('Message ID.')

             PARM       KWD(MSGF) TYPE(MSGF) +
                          PROMPT('Message File')
 MSGF:       QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) +
                          CHOICE('Name') +
                          PROMPT('Library')

