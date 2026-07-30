/*******************************************************************/
/* RETRIEVE SPOOLED FILE ATTRIBUTES - RTVSPLFA                     */
/*                                                                 */
/* THE RTVSPLFA COMMAND RETRIEVES THE SPOOLED FILE INFORMATION     */
/* ONE OR MORE PARAMETERS MAY BE RETURNED                          */
/*                                                                 */
/*******************************************************************/
 PGM        PARM(&SPLF &FULLJOB &SPLNBR &FORMTYPE &OUTPTY +
                          &CPYLEFT &COPIES &MAXRCDS &FILESEP +
                          &SCHEDULE &HOLD &SAVE &DEVTYPE &PRTTYPE +
                          &DEVFILE &DEVFILEL &USRDTA &ACGCDE &OPNPGM +
                          &OPNPGML &OPNDAT &OPNTIM &PAGWTN &TOTPAG +
                          &RCDLEN &PAGLEN &PAGWDT &LPI &CPI &OVRFLW +
                          &FOLD &CTLCHAR &RPLUNPRT &ALIGN &PRTQLTY +
                          &FORMFEED &DRAWER &FONT &PAGRTT &JUSTIFY +
                          &RTVSPLNBR)
             DCL        &SPLF *CHAR LEN(10)
             DCL        &FULLJOB *CHAR LEN(26)
             DCL        &JOB *CHAR LEN(10)
             DCL        &USER *CHAR LEN(10)
             DCL        &JOBNBR *CHAR LEN(6)
             DCL        &SPLNBR *CHAR LEN(6)
             DCL        &SPLNBRD *DEC LEN(9 0)
             DCL        &SPLNBRB *CHAR LEN(4)
             DCL        &RTVSPLNBR *CHAR LEN(6)
             DCL        &DATSEP *CHAR LEN(1)
             DCL        &FORMTYPE *CHAR LEN(10)
             DCL        &OUTPTY *CHAR LEN(1)
             DCL        &CPYLEFT *CHAR LEN(3)
             DCL        &COPIES *CHAR LEN(3)
             DCL        &MAXRCDS *CHAR LEN(10)
             DCL        &FILESEP *CHAR LEN(1)
             DCL        &SCHEDULE *CHAR LEN(8)
             DCL        &HOLD *CHAR LEN(4)
             DCL        &SAVE *CHAR LEN(4)
             DCL        &DEVTYPE *CHAR LEN(10)
             DCL        &PRTTYPE *CHAR LEN(5)
             DCL        &DEVFILE *CHAR LEN(10)
             DCL        &DEVFILEL *CHAR LEN(10)
             DCL        &USRDTA *CHAR LEN(10)
             DCL        &ACGCDE *CHAR LEN(15)
             DCL        &OPNPGM *CHAR LEN(10)
             DCL        &OPNPGML *CHAR LEN(10)
             DCL        &OPNDAT *CHAR LEN(8)
             DCL        &OPNTIM *CHAR LEN(8)
             DCL        &PAGWTN *CHAR LEN(10)
             DCL        &TOTPAG *CHAR LEN(10)
             DCL        &RCDLEN *CHAR LEN(5)
             DCL        &PAGLEN *CHAR LEN(3)
             DCL        &PAGWDT *CHAR LEN(3)
             DCL        &LPI *CHAR LEN(1)
             DCL        &CPI *CHAR LEN(2)
             DCL        &OVRFLW *CHAR LEN(3)
             DCL        &FOLD *CHAR LEN(4)
             DCL        &CTLCHAR *CHAR LEN(5)
             DCL        &RPLUNPRT *CHAR LEN(4)
             DCL        &ALIGN *CHAR LEN(4)
             DCL        &PRTQLTY *CHAR LEN(6)
             DCL        &FORMFEED *CHAR LEN(8)
             DCL        &DRAWER *CHAR LEN(1)
             DCL        &FONT *CHAR LEN(5)
             DCL        &PAGRTT *CHAR LEN(5)
             DCL        &JUSTIFY *CHAR LEN(3)
             DCL        &DS *CHAR LEN(1000)
             DCL        &DSLEND *DEC LEN(9 0)
             DCL        &DSLENB *CHAR LEN(4)
             DCL        &QLFJOB *CHAR LEN(26)
             DCL        &INTJOB *CHAR LEN(16)
             DCL        &INTSPLF *CHAR LEN(16)
             DCL        &WORK4 *CHAR LEN(4)
             DCL        &WORK6 *CHAR LEN(6)
             DCL        &DEC9 *DEC LEN(9 0)
             DCL        &WORK9 *CHAR LEN(9)
             DCL        &ERRORSW *LGL           /* STANDARD ERROR */
             DCL        &MSGID *CHAR LEN(7)     /* STANDARD ERROR */
             DCL        &MSG *CHAR LEN(512)     /* STANDARD ERROR */
             DCL        &MSGDTA *CHAR LEN(512)  /* STANDARD ERROR */
             DCL        &MSGF *CHAR LEN(10)     /* STANDARD ERROR */
             DCL        &MSGFLIB *CHAR LEN(10)  /* STANDARD ERROR */
             DCL        &KEYVAR *CHAR LEN(4)    /* STANDARD ERROR */
             DCL        &KEYVAR2 *CHAR LEN(4)   /* STANDARD ERROR */
             DCL        &RTNTYPE *CHAR LEN(2)   /* STANDARD ERROR */
             MONMSG     MSGID(MCH3601)
             MONMSG     MSGID(CPF0000) EXEC(GOTO STDERR1) /* STD ERR */
             RTVSYSVAL  SYSVAL(QDATSEP) RTNVAR(&DATSEP)
             CHGVAR     &JOB %SST(&FULLJOB 1 10)
             CHGVAR     &USER %SST(&FULLJOB 11 10)
             CHGVAR     &JOBNBR %SST(&FULLJOB 21 6)
             IF         (&JOB *EQ '*') DO /* USE CURRENT JOB */
             RTVJOBA    JOB(&JOB) USER(&USER) NBR(&JOBNBR)
             ENDDO      /* USE CURRENT JOB */
                        /* BUILD QLFD JOB NAME FOR THE CALL */
             CHGVAR     &QLFJOB (&JOB *CAT &USER *CAT &JOBNBR)
                        /* DETERMINE SPLF NUMBER */
             IF         (&SPLNBR *EQ '*ONLY') DO /* ONLY */
             CHGVAR     &SPLNBRD 0
             GOTO       CVTSPLN
             ENDDO      /* ONLY */
             IF         (&SPLNBR *EQ '*LAST') DO /* LAST */
             CHGVAR     &SPLNBRD -1
             GOTO       CVTSPLN
             ENDDO      /* LAST */
                        /* IF NOT *ONLY OR *LAST, CONVERT THE NBR */
             CHGVAR     &SPLNBRD &SPLNBR
 CVTSPLN:    CHGVAR     %BIN(&SPLNBRB 1 4) &SPLNBRD
                        /* USE 1000 BYTE LEN FOR DS - CVT TO BIN */
             CHGVAR     &DSLEND 1000
             CHGVAR     %BIN(&DSLENB 1 4) &DSLEND
                        /* CALL API TO RTV SPLFA */
             CALL       QUSRSPLA PARM(&DS &DSLENB 'SPLA0100' +
                          &QLFJOB &INTJOB &INTSPLF &SPLF &SPLNBRB)
 SPLNBR:     CHGVAR     &SPLNBRD %BIN(&DS 77 4)
             CHGVAR     &RTVSPLNBR &SPLNBRD
 FORMTYPE:   CHGVAR     &FORMTYPE %SST(&DS 81 10)
 OUTPTY:     CHGVAR     &OUTPTY %SST(&DS 182 1)
 CPYLEFT:    CHGVAR     &WORK4 %SST(&DS 169 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &CPYLEFT &DEC9
 COPIES:     CHGVAR     &WORK4 %SST(&DS 165 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &COPIES &DEC9
 MAXRCDS:    CHGVAR     &WORK4 %SST(&DS 305 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &MAXRCDS &DEC9
             IF         (&DEC9 *EQ 0) CHGVAR &MAXRCDS '*NOMAX'
 FILESEP:    CHGVAR     &WORK4 %SST(&DS 433 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &FILESEP %SST(&WORK9 9 1)
 SCHEDULE:   CHGVAR     &SCHEDULE %SST(&DS 111 10)
 HOLD:       CHGVAR     &HOLD %SST(&DS 121 4)
 SAVE:       CHGVAR     &SAVE %SST(&DS 131 4)
 DEVTYPE:    CHGVAR     &DEVTYPE %SST(&DS 309 10)
 PRTTYPE:    CHGVAR     &PRTTYPE %SST(&DS 319 5)
 DEVFILE:    CHGVAR     &DEVFILE %SST(&DS 216 10)
 DEVFILEL:   CHGVAR     &DEVFILEL %SST(&DS 226 10)
 USRDTA:     CHGVAR     &USRDTA %SST(&DS 91 10)
 ACGCDE:     CHGVAR     &ACGCDE %SST(&DS 256 15)
 OPNPGM:     CHGVAR     &OPNPGM %SST(&DS 236 10)
 OPNPGML:    CHGVAR     &OPNPGML %SST(&DS 246 10)
 OPNDAT:     CHGVAR     &WORK6 %SST(&DS 204 6)
             CHGVAR     &OPNDAT (%SST(&WORK6 1 2) *CAT &DATSEP +
                          *CAT %SST(&WORK6 3 2) *CAT &DATSEP +
                          *CAT %SST(&WORK6 5 2))
 OPNTIM:     CHGVAR     &WORK6 %SST(&DS 210 6)
             CHGVAR     &OPNTIM (%SST(&WORK6 1 2) *CAT ':' +
                          *CAT %SST(&WORK6 3 2) *CAT ':' +
                          *CAT %SST(&WORK6 5 2))
 PAGWTN:     CHGVAR     &WORK4 %SST(&DS 145 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &PAGWTN &DEC9
 TOTPAG:     CHGVAR     &WORK4 %SST(&DS 141 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &TOTPAG &DEC9
 RCDLEN:     CHGVAR     &WORK4 %SST(&DS 301 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &RCDLEN %SST(&WORK9 5 5)
 PAGLEN:     CHGVAR     &WORK4 %SST(&DS 425 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &PAGLEN %SST(&WORK9 7 3)
 PAGWDT:     CHGVAR     &WORK4 %SST(&DS 429 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &PAGWDT %SST(&WORK9 7 3)
 LPI:        CHGVAR     &WORK4 %SST(&DS 173 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &LPI %SST(&WORK9 8 1)
 CPI:        CHGVAR     &WORK4 %SST(&DS 177 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &CPI %SST(&WORK9 7 2)
 OVRFLW:     CHGVAR     &WORK4 %SST(&DS 437 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &OVRFLW %SST(&WORK9 7 3)
                        /* FOLD CHANGED FROM REL 3 MANUAL */
 FOLD:       CHGVAR     &FOLD %SST(&DS 563 4)
                        /* CTLCHAR CHANGED FROM REL 3 MANUAL */
 CTLCHAR:    CHGVAR     &CTLCHAR %SST(&DS 573 5)
 RPLUNPRT:   CHGVAR     &RPLUNPRT '*YES'
             IF         (%SST(&DS 423 1) *EQ 'N') DO /* NO REPLACE */
             CHGVAR     &RPLUNPRT '*NO'
             ENDDO      /* NO REPLACE */
                        /* ALIGN CHANGED FROM REL 3 MANUAL */
 ALIGN:      CHGVAR     &ALIGN %SST(&DS 583 4)
                        /* PRTQLTY CHANGED FROM REL 3 MANUAL */
 PRTQLTY:    CHGVAR     &PRTQLTY %SST(&DS 593 6)
                        /* FORMFEED CHANGED FROM REL 3 MANUAL */
 FORMFEED:   CHGVAR     &FORMFEED %SST(&DS 603 8)
 DRAWER:     CHGVAR     &WORK4 %SST(&DS 525 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &DRAWER %SST(&WORK9 9 1)
 FONT:       CHGVAR     &FONT %SST(&DS 529 5)
 PAGRTT:     CHGVAR     &WORK4 %SST(&DS 545 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
                        /* CONVERT MINUS VALUES */
             IF         (&DEC9 *EQ -1) DO /* *AUTO */
             CHGVAR     &PAGRTT '*AUTO'
             GOTO       JUSTIFY
             ENDDO      /* AUTO */
             IF         (&DEC9 *EQ -2) DO /* *DEVD */
             CHGVAR     &PAGRTT '*DEVD'
             GOTO       JUSTIFY
             ENDDO      /* DEVD */
             IF         (&DEC9 *EQ -3) DO /* *COR */
             CHGVAR     &PAGRTT '*COR'
             GOTO       JUSTIFY
             ENDDO      /* COR */
                        /* ONLY POSITIVE VALUES REMAIN, CONVERT */
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &PAGRTT %SST(&WORK9 5 5)
 JUSTIFY:    CHGVAR     &WORK4 %SST(&DS 549 4)
             CHGVAR     &DEC9 %BIN(&WORK4 1 4)
             CHGVAR     &WORK9 &DEC9
             CHGVAR     &JUSTIFY %SST(&WORK9 7 3)
 ENDPGM:
             RMVMSG     CLEAR(*ALL)
             RETURN     /* NORMAL END OF PROGRAM */
 STDERR1:               /* STANDARD ERROR HANDLING ROUTINE */
             IF         &ERRORSW SNDPGMMSG MSGID(CPF9999) +
                          MSGF(QCPFMSG) MSGTYPE(*ESCAPE)
             CHGVAR     &ERRORSW '1' /* SET TO FAIL ON ERROR */
             RCVMSG     MSGTYPE(*EXCP) RMV(*NO) KEYVAR(&KEYVAR)
 STDERR2:    RCVMSG     MSGTYPE(*PRV) MSGKEY(&KEYVAR) RMV(*NO) +
                          KEYVAR(&KEYVAR2) MSG(&MSG) +
                          MSGDTA(&MSGDTA) MSGID(&MSGID) +
                          RTNTYPE(&RTNTYPE) MSGF(&MSGF) +
                          SNDMSGFLIB(&MSGFLIB)
             IF         (&RTNTYPE *NE '02') GOTO STDERR3
             IF         (&MSGID *NE ' ') SNDPGMMSG +
                          MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*DIAG)
             IF         (&MSGID *EQ ' ') SNDPGMMSG +
                          MSG(&MSG) MSGTYPE(*DIAG)
             RMVMSG     MSGKEY(&KEYVAR2)
 STDERR3:    RCVMSG     MSGKEY(&KEYVAR) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID) MSGF(&MSGF) +
                          SNDMSGFLIB(&MSGFLIB)
             SNDPGMMSG  MSGID(&MSGID) MSGF(&MSGFLIB/&MSGF) +
                          MSGDTA(&MSGDTA) MSGTYPE(*ESCAPE)
             ENDPGM
