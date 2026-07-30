/*  CRTCMD CMD(APLLIB/DSPURL)                        */
/*         PGM(APLLIB/DSPURLD1)                      */
/*         SRCFILE(APLLIB/QSRC)                      */
/*         SRCMBR(DSPURLM1)                          */
/*         REPLACE(*YES)                             */
/*                                                   */
             CMD        PROMPT('Display URL in Users Browser')
             PARM       KWD(URL) TYPE(*CHAR) LEN(499) MIN(1) +
                          EXPR(*YES) PROMPT('URL to Display')
