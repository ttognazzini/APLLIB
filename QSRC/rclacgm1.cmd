/*-------------------------------------------------------------------*/
/*                                                                   */
/*  Compile options:                                                 */
/*                                                                   */
/*    CRTCMD CMD(APLLIB/RE)                                          */
/*           PGM(APLLIB/RCLACGC1)                                    */
/*           SRCFILE(APLLIB/QSRC)                                    */
/*           SRCMBR(RCLACGM1)                                        */
/*           REPLACE(*YES)                                           */
/*                                                                   */
/*-------------------------------------------------------------------*/
             CMD        PROMPT('Recalim Eligible ActGrp') +
                          TEXT(*CMDPMT) VLDCKR(*NONE) HLPID(RE) +
                          HLPPNLGRP(RCLACGP1)

