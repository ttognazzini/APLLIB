   /*   CRTCMD   CMD(APLLIB/GETEML)                          +
                 PGM(*LIBL/GETEMLB1)                         +
                 SRCFILE(APLLIB/QSRC)                        +
                 SRCMBR(GETEMLM1)                            +
                 REPLACE(*YES)                               */
             CMD        PROMPT('Get Email Address') ALLOW(*IPGM +
                          *BPGM) HLPPNLGRP(GETEMLP1) HLPSCHIDX(GETEML)
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(50) RTNVAL(*YES) +
                          MIN(1) CHOICE('Variable *CHAR LEN(50)') +
                          PROMPT('CL Variable to Receive Address')
             PARM       KWD(USER) TYPE(*CHAR) LEN(10) DFT(' ') +
                          PROMPT('User to Find the Address Of')
