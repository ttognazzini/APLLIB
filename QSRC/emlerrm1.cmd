   /*   CRTCMD CMD(APLLIB/EMLERR)                    +
               PGM(APLLIB/EMLERRC1)                  +
               SRCFILE(APLLIB/QSRC)                  +
               SRCMBR(EMLERRM1)                      +
               REPLACE(*YES)                         */
             CMD        PROMPT('Email Error W/JobLog') TEXT(*CMDPMT) +
                          HLPID(EMLERR) HLPPNLGRP(APLLIB/EMLERRP1)
             PARM       KWD(EMLTO) TYPE(*CHAR) LEN(50) MIN(1) +
                          PROMPT('Email To')
             PARM       KWD(subject) TYPE(*char) LEN(100) MIN(1) +
                          EXPR(*YES) PROMPT('Subject')
             PARM       KWD(MESSAGE) TYPE(*CHAR) LEN(1000) MIN(1) +
                          EXPR(*YES) PROMPT('Email Message')
             PARM       KWD(INCDMP) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(' ') VALUES(' ' 'Y') PROMPT('Include +
                          Dump')
             PARM       KWD(EMLFRM) TYPE(*CHAR) LEN(50) PROMPT('Email From')
             PARM       KWD(EMLTO2) TYPE(*CHAR) LEN(50) PROMPT('Email To 2')
             PARM       KWD(EMLTO3) TYPE(*CHAR) LEN(50) PROMPT('Email To 3')
