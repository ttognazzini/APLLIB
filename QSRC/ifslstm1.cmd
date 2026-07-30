             CMD        PROMPT('LIST IFS OBJECTS') +
                          TEXT(*CMDPMT) +
                          MAXPOS(2) HLPID(*CMD) +
                          HLPPNLGRP(IFSLST)

             PARM       KWD(FOLDER) TYPE(*CHAR) LEN(256) +
                          CHOICE('Name, *CURDIR') PROMPT('Folder') +
                          DFT(*CURDIR)

             PARM       KWD(OUTPUTTYPE) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) DFT(*PRINT) +
                          VALUES('*OUTFILE' '*PRINT') +
                          CHOICE('*PRINT, *OUTFILE') PROMPT('Output +
                          Type')

             PARM       KWD(OUTFILE) TYPE(NAME1) SNGVAL((*NONE)) +
                          MIN(0) MAX(1) PMTCTL(A) PROMPT('Output File')
 NAME1:      QUAL   TYPE(*NAME) LEN(10)
             QUAL   TYPE(*NAME) LEN(10) PROMPT('Library') DFT(QTEMP)
 A:          PMTCTL CTL(OUTPUTTYPE) COND((*EQ *OUTFILE))

             DEP        CTL(&OUTPUTTYPE *EQ *OUTFILE) PARM((OUTFILE))

             PARM       KWD(FILETYPE) TYPE(*CHAR) LEN(10) +
                          RSTD(*YES) DFT(*BASIC) +
                          VALUES('*BASIC' '*FULL') +
                          PROMPT('Output File Type') PMTCTL(A)

             PARM       KWD(INDIR) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES('*NO' '*YES') +
                          CHOICE('*NO, *YES') PMTCTL(*PMTRQS) +
                          PROMPT('Include Directories')

