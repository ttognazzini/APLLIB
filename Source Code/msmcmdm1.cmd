   /*   CRTCMD   CMD(APLLIB/MSM)                       +
                 PGM(APLLIB/MSMCMDC1)                  +
                 REPLACE(*YES)                         */
             CMD        PROMPT('Move Source Member') TEXT(*CMDPMT) +
                          HLPID(MSM) HLPPNLGRP(APLLIB/MSMCMDP1)
             PARM       KWD(SRCMBR) TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Source Member')
             PARM       KWD(SRCFLE) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          CHOICE('*SEARCH, Source File Name') +
                          PROMPT('Source File')
             PARM       KWD(SRCLIB) TYPE(*NAME) LEN(10) DFT(*SEARCH) +
                          SPCVAL((*SEARCH *SEARCH)) +
                          PROMPT('*SEARCH, Source Library')
             PARM       KWD(SERVER) TYPE(*CHAR) LEN(50) +
                          DFT(WINCHTST) PROMPT('Server ID, IP or Host name')
