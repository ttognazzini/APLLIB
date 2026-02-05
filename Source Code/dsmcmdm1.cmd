/* CRTCMD CMD(APLLIB/DSM) PGM(*LIBL/DSMCCMC1)                    */
/*        SRCFILE(APLLIB/QSRC) SRCMBR(DSMCCMM1) REPLACE(*YES)    */
             CMD        PROMPT('Display Source Member')

             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Source Member')

             PARM       KWD(SRCFLE) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          CHOICE('*SEARCH, Source File Name') +
                          PROMPT('Source File')

             PARM       KWD(SRCLIB) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          PROMPT('*SEARCH, Source Library')
