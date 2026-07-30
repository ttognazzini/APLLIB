   /*   CRTCMD CMD(APLLIB/MONMSQ) PGM(APLLIB/MONMSQC1)              */
   /*          SRCFILE(APLLIB/QSRC) SRCMBR(MONMSQM1) REPLACE(*YES)  */
             CMD        PROMPT('Monitor Message Queue') MAXPOS(2) TEXT(*CMDPMT) +
                          ALLOW(*ALL) HLPID(MONMSQ) HLPPNLGRP(MONMSQP1)

             PARM       KWD(MSGQ) TYPE(QUAL1) MIN(1) PROMPT('Message Queue')
 QUAL1:      QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                         (*CURLIB)) EXPR(*YES) PROMPT('Library')

             PARM       KWD(EMLTO) TYPE(*CHAR) LEN(50) MIN(1) +
                          PROMPT('Email To')

             PARM       KWD(JOBNME) TYPE(*NAME) LEN(10) DFT(*MSGQ) +
                          SPCVAL((*MSGQ)) PROMPT('Job Name')

             PARM       KWD(JOBD) TYPE(QUAL2) MIN(1) PROMPT('Job Description')
 QUAL2:      QUAL       TYPE(*NAME) MIN(0) DFT(*USRPRF) SPCVAL((*USRPRF '*USRPRF'))
             QUAL       TYPE(*NAME) SPCVAL((*LIBL '*LIBL') +
                         (*CURLIB '*CURLIB')) EXPR(*YES) PROMPT('Library')

             PARM       KWD(USER) TYPE(*NAME) LEN(10) DFT(*CURRENT) +
                          PROMPT('User') SPCVAL((*CURRENT '*CURRENT'))

             PARM       KWD(DEBUG) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) SPCVAL((*NO +
                          '*NO') (*YES '*YES')) PROMPT('Debug')

