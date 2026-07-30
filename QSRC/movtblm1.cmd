/*  CRTCMD CMD(APLLIB/MOVTBL)                     */
/*         PGM(APLLIB/MOVTBLC1)                   */
/*         SRCFILE(APLLIB/QSRC)                   */
/*         SRCMBR(MOVTBLM1)                       */
/*         REPLACE(*YES)                          */
/*                                                */
             CMD        PROMPT('Move File to Tableau Database') +
                          TEXT(*CMDPMT) MAXPOS(2) HLPID(*CMD) +
                          HLPPNLGRP(APLLIB/MOVTBLP1)

             PARM       KWD(FLENME) TYPE(NAME1) +
                          MIN(1) MAX(1) PROMPT('File to Move')
 NAME1:      QUAL   TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(MRPS38S) +
                          SPCVAL((*LIBL *LIBL) (*CURLIB *CURLIB)) +
                          PROMPT('Library,*LIBL,*CURLIB')

             PARM       KWD(NEWTBLNME) TYPE(*CHAR) LEN(128) +
                          CHOICE('Name, *TABLE') PROMPT('New Table Name') +
                          DFT(*TABLE)

