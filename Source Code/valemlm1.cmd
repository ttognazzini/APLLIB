   /*   CRTCMD CMD(APLLIB/VALEML)                          +
               PGM(*LIBL/VALEMLB1)                         +
               SRCFILE(APLLIB/QSRC)                        +
               SRCMBR(VALEMLM1)                            +
               REPLACE(*YES)                               */
             CMD        PROMPT('Validate Email Address') ALLOW(*IPGM +
                          *BPGM) HLPID(VALEML) HLPPNLGRP(VALEMLP1)
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(50) PROMPT('Email +
                          Address to Validate')
             PARM       KWD(PASS) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('Variable to Return Status')
