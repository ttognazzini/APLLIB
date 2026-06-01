   /*   CRTCMD CMD(APLLIB/VALDTE)                          +
               PGM(*LIBL/VALDTEC1)                         +
               SRCFILE(APLLIB/QSRC)                        +
               SRCMBR(VALDTEM1)                            +
               REPLACE(*YES)                               */
             CMD        PROMPT('Validate Date (YYYYMMDD)') +
                          ALLOW(*IPGM *BPGM) HLPPNLGRP(VALDTEP1) +
                          HLPSCHIDX(VALDTE)
             PARM       KWD(DATE) TYPE(*DEC) LEN(8) PROMPT('Date +
                          Field to Validate')
             PARM       KWD(PASS) TYPE(*CHAR) LEN(1) RTNVAL(*YES) +
                          PROMPT('Variable to Return Date Status')
