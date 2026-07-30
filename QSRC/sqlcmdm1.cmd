 /*===============================================================*/
 /* TO COMPILE:                                                   */
 /*                                                               */
 /*           CRTCMD     CMD(APLLIB/SQL) PGM(SQLCMDD1)            */
 /*                                                               */
 /*===============================================================*/
             CMD        PROMPT('SQL Query Manager') TEXT(*CMDPMT) +
                          HLPID(SQL) HLPPNLGRP(SQL)

             PARM       KWD(FILE) TYPE(*CHAR) LEN(5000) MIN(0) +
                          PROMPT('File, Query, SQL stm, *QRYDFN.')
             PARM       KWD(ACTION) TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*ADHOC) VALUES(*ADHOC *EDIT *PRINT +
                          *EMAIL *DISPLAY *OUTFILE *IFSFILE *VIEW) +
                          MIN(0) +
                          CHOICE('*ADHOC,*VIEW,*EDIT,*PRINT,...') +
                          PROMPT('Action to perform')
             PARM       KWD(USER) TYPE(*CHAR) LEN(10) DFT(*CURRENT) +
                          SPCVAL((*CURRENT ' ')) MIN(0) +
                          CHOICE('User Id, *CURRENT') PROMPT('User +
                          that created the query')

/* QRYDFN, ONLY DISPLAYED IF FILE=*QRYDFN */
             PARM       KWD(QRYDFN) TYPE(OUTQ) PMTCTL(P3) +
                          PROMPT('Query Definition, *QRYDFN')
 P3:        PMTCTL     CTL(FILE) COND((*EQ '*QRYDFN'))

/* EMAIL OPTIONS, ONLY DISPLAYED IF ACTION = *EMAIL */
             PARM       KWD(EMAIL) TYPE(*CHAR) LEN(50) DFT(*CURRENT) +
                          SPCVAL((*CURRENT '*CURRENT') (*RPTDSTID +
                          '*RPTDSTID') (*DFT '*DFT')) MIN(0) +
                          MAX(50) +
                          CHOICE('EMAIL,*CURRENT,*RPTDSTID,*DFT') +
                          CHOICEPGM(*NONE) PMTCTL(P2) PROMPT('To +
                          email address(es)')
             PARM       KWD(FILENAME) TYPE(*CHAR) LEN(123) MIN(0) +
                          EXPR(*YES) PMTCTL(P2) PROMPT('File name')
             PARM       KWD(TYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*DFT) VALUES(*DFT *XLS *XML *CSV *PDF +
                          *JSON) MIN(0) PMTCTL(P2) PROMPT('File type')
             PARM       KWD(SHEET) TYPE(*CHAR) LEN(32) MIN(0) +
                          PMTCTL(P22) PROMPT('SHEET NAME')
             PARM       KWD(TITLE1) TYPE(*CHAR) LEN(80) DFT(*NONE) +
               EXPR(*YES) MIN(0) PMTCTL(P22) PROMPT('TITLE LINE 1')
             PARM       KWD(TITLE2) TYPE(*CHAR) LEN(80) DFT(*NONE) +
               EXPR(*YES) MIN(0) PMTCTL(P22) PROMPT('TITLE LINE 2')
             PARM       KWD(TITLE3) TYPE(*CHAR) LEN(80) DFT(*NONE) +
               EXPR(*YES) MIN(0) PMTCTL(P22) PROMPT('TITLE LINE 3')
             PARM       KWD(TITLE4) TYPE(*CHAR) LEN(80) DFT(*NONE) +
               EXPR(*YES) MIN(0) PMTCTL(P22) PROMPT('TITLE LINE 4')
             PARM       KWD(TITLE5) TYPE(*CHAR) LEN(80) DFT(*NONE) +
               EXPR(*YES) MIN(0) PMTCTL(P22) PROMPT('TITLE LINE 5')
             PARM       KWD(SUBJECT) TYPE(*CHAR) LEN(128) DFT(*DFT) +
               EXPR(*YES) MIN(0) PROMPT('Subject') PMTCTL(P2)
             PARM       KWD(MESSAGE) TYPE(MESSAGE) DFT(*DFT) +
                          MIN(0) PROMPT('Message') SNGVAL(*DFT) +
                          PMTCTL(P2)
             PARM       KWD(OBJ) TYPE(OBJ) PMTCTL(P2) +
                          MIN(0) MAX(100) PROMPT('Objects')
             PARM       KWD(INCVARS) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) MIN(0) +
                          PMTCTL(P2) PROMPT('Include variable overides')
             PARM       KWD(RPTDSTID) TYPE(*CHAR) LEN(10) PMTCTL(P2) +
                          PROMPT('Report distribution ID')

 MESSAGE:    ELEM       TYPE(*CHAR) LEN(5000) EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) +
                          DFT(*TEXTPLAIN) VALUES(*TEXTPLAIN +
                          *TEXTHTML) PROMPT('Send as')

 OBJ:        ELEM       TYPE(*CHAR) LEN(128)
             ELEM       TYPE(*CHAR) LEN(10) RSTD(*YES) DFT(*ATTACH) +
                          VALUES(*ATTACH *NO *TEXTPLAIN *TEXTHTML +
                          *ATTACHPDF *ATTACHPS *NOTE) +
                          CHOICE('*ATTACH, *TEXTPLAIN,...') +
                          PROMPT('Send as')

 P2:        PMTCTL     CTL(ACTION) COND((*EQ '*EMAIL'))

 P22:        PMTCTL     CTL(ACTION) COND((*EQ '*EMAIL'))
             PMTCTL     CTL(ACTION) COND((*EQ '*PRINT')) +
                                    LGLREL(*OR)

/* IFSFILE OPTIONS, ONLY DISPLAYED IF ACTION = *IFSFILE */
             PARM       KWD(IFSFOLDER) TYPE(*CHAR) LEN(123) +
                          PMTCTL(P6) PROMPT('Output +
                          folder')
             PARM       KWD(IFSFILE) TYPE(*CHAR) LEN(123) +
                          PMTCTL(P6) PROMPT('Output +
                          file')
             PARM       KWD(IFSTYPE) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*XLS) VALUES(*XLS *XML *CSV *PDF *JSON) MIN(0) +
                          PMTCTL(P6) PROMPT('File type')

 P6:        PMTCTL     CTL(ACTION) COND((*EQ '*IFSFILE'))

/* PRINT OPTIONS, ONLY DISPLAYED IF ACTION = *PRINT */
             PARM       KWD(OUTQ) TYPE(OUTQ) DFT(*DFT) SNGVAL((*JOB) +
                          (*DFT)) PMTCTL(P4) PROMPT('Output queue')
             PARM       KWD(COPIES) TYPE(*DEC) LEN(3) DFT(0) RANGE(0 +
                          255) MIN(0) PMTCTL(P4) PROMPT('Copies, +
                          0=Default')
             PARM       KWD(HOLD) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*DFT) VALUES(*DFT *NO *YES) MIN(0) +
                          PMTCTL(P4) PROMPT('Hold output')
             PARM       KWD(SAVE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*DFT) VALUES(*DFT *NO *YES) MIN(0) +
                          PMTCTL(P4) PROMPT('Save output')
             PARM       KWD(USRDTA) TYPE(*CHAR) LEN(10) DFT(*DFT) +
                          MIN(0) PROMPT('USER DATA') PMTCTL(P42)
             PARM       KWD(WIDTH) TYPE(*DEC) LEN(3) DFT(0) MIN(0) +
                          PMTCTL(P42) PROMPT('Form width, 0=Default')
             PARM       KWD(LENGTH) TYPE(*DEC) LEN(3) DFT(0) MIN(0) +
                          PMTCTL(P42) PROMPT('Form length, 0=Default')
             PARM       KWD(PINVR) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*DFT) VALUES(*DFT *NO *YES) MIN(0) +
                          PMTCTL(P42) PROMPT('Include variables')
             PARM       KWD(PINQY) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*DFT) VALUES(*DFT *NO *YES) MIN(0) +
                          PMTCTL(P42) PROMPT('Include query')
             PARM       KWD(PNAME) TYPE(*CHAR) LEN(10) MIN(0) +
                          PMTCTL(P42) PROMPT('Program Name')

 OUTQ:       QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library')

 P4:         PMTCTL     CTL(ACTION) COND((*EQ '*PRINT'))

/* P42, ONLY DISPLAYED IF PRINTING OR CREATING A PDF */
 P42:        PMTCTL     CTL(ACTION) COND((*EQ '*PRINT'))
             PMTCTL     CTL(TYPE) COND((*EQ '*PDF')) LGLREL(*OR)
             PMTCTL     CTL(IFSTYPE) COND((*EQ '*PDF')) LGLREL(*OR)

/* OUTFILE OPTIONS, ONLY DISPLAYED IF ACTION = *OUTFILE */
             PARM       KWD(PFILE) TYPE(PFILE) +
                          PMTCTL(P5) PROMPT('Output +
                          file')

 PFILE:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) PROMPT('Library')

 P5:        PMTCTL     CTL(ACTION) COND((*EQ '*OUTFILE'))

/* VARIABLE OVERRIDE OPTIONS, ONLY DISPLAYED IF ACTION =            +
   *PRINT, *DISPLAY, *EMAIL, *OUTFILE, *IFSFILE                   */
             PARM       KWD(VAROVR) TYPE(VAROVR) PMTCTL(P7) +
                          MIN(0) MAX(10) PROMPT('Variable overrides')

 VAROVR:     ELEM       TYPE(*CHAR) LEN(10) PROMPT('Variable')
             ELEM       TYPE(*CHAR) LEN(30) PROMPT('Value')

 P7:         PMTCTL     CTL(ACTION) COND((*NE '*ADHOC') (*NE '*EDIT') +
                          (*NE '*VIEW'))

             PARM       KWD(ADDSQL) TYPE(ADDSQL) +
                          MIN(0) MAX(300) PROMPT('Additional Queries')

 ADDSQL:     ELEM       TYPE(*CHAR) LEN(5000) EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(32) PROMPT('SHEET NAME') EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 1') EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 2') EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 3') EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 4') EXPR(*YES)
             ELEM       TYPE(*CHAR) LEN(80) PROMPT('TITLE LINE 5') EXPR(*YES)
