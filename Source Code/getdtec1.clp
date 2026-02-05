/* RETURN DATES IN DIFFERENT FORMATS, USED BY COMMAND GETDATE */
             PGM (&DEC8 &CHR8 &DEC6 &CHR6 &DECMDY8 &CHRMDY8 +
                  &DECMDY6 &CHRMDY6 &DECYYYY &CHRYYYY &DECYY +
                  &CHRYY &DECMM &CHRMM &DECDD &CHRDD &CHRF8 +
                  &CHRF6 &CHRFMDY8 &CHRFMDY6 &CHRS8 &CHRS6 +
                  &CHRSMDY8 &CHRSMDY6 &ADDDAY &SUBDAY +
                  &ADDWRKDAY &SUBWRKDAY +
                  &ADDMTH &SUBMTH +
                  &ADDYEAR &SUBYEAR &STRDATE &INDATE)

/* PARAMETER VARIABLES */
             DCL        &DEC8      *DEC   LEN(8 0)
             DCL        &CHR8      *CHAR  LEN(8)
             DCL        &DEC6      *DEC   LEN(6 0)
             DCL        &CHR6      *CHAR  LEN(6)
             DCL        &DECMDY8   *DEC   LEN(8 0)
             DCL        &CHRMDY8   *CHAR  LEN(8)
             DCL        &DECMDY6   *DEC   LEN(6 0)
             DCL        &CHRMDY6   *CHAR  LEN(6)
             DCL        &DECYYYY   *DEC   LEN(4 0)
             DCL        &CHRYYYY   *CHAR  LEN(4)
             DCL        &DECYY     *DEC   LEN(2 0)
             DCL        &CHRYY     *CHAR  LEN(2)
             DCL        &DECMM     *DEC   LEN(2 0)
             DCL        &CHRMM     *CHAR  LEN(2)
             DCL        &DECDD     *DEC   LEN(2 0)
             DCL        &CHRDD     *CHAR  LEN(2)
             DCL        &CHRF8     *CHAR  LEN(10)
             DCL        &CHRF6     *CHAR  LEN(8)
             DCL        &CHRFMDY8  *CHAR  LEN(10)
             DCL        &CHRFMDY6  *CHAR  LEN(8)
             DCL        &CHRS8     *CHAR  LEN(10)
             DCL        &CHRS6     *CHAR  LEN(8)
             DCL        &CHRSMDY8  *CHAR  LEN(10)
             DCL        &CHRSMDY6  *CHAR  LEN(8)
             DCL        &ADDDAY    *DEC   LEN(5 0)
             DCL        &SUBDAY    *DEC   LEN(5 0)
             DCL        &ADDWRKDAY *DEC   LEN(5 0)
             DCL        &SUBWRKDAY *DEC   LEN(5 0)
             DCL        &ADDMTH    *DEC   LEN(5 0)
             DCL        &SUBMTH    *DEC   LEN(5 0)
             DCL        &ADDYEAR   *DEC   LEN(5 0)
             DCL        &SUBYEAR   *DEC   LEN(5 0)
             DCL        &STRDATE   *CHAR  LEN(5)
             DCL        &INDATE    *CHAR  LEN(8)

/* WORK VARIABLES */
             DCL        &TODAY     *CHAR  LEN(6)
             DCL        &TDEC8     *DEC   LEN(8 0)
             DCL        &TCHR8     *CHAR  LEN(8)
             DCL        &TDEC6     *DEC   LEN(6 0)
             DCL        &TCHR6     *CHAR  LEN(6)
             DCL        &TDECMDY8  *DEC   LEN(8 0)
             DCL        &TCHRMDY8  *CHAR  LEN(8)
             DCL        &TDECMDY6  *DEC   LEN(6 0)
             DCL        &TCHRMDY6  *CHAR  LEN(6)
             DCL        &TDECYYYY  *DEC   LEN(4 0)
             DCL        &TCHRYYYY  *CHAR  LEN(4)
             DCL        &TDECYY    *DEC   LEN(2 0)
             DCL        &TCHRYY    *CHAR  LEN(2)
             DCL        &TDECMM    *DEC   LEN(2 0)
             DCL        &TCHRMM    *CHAR  LEN(2)
             DCL        &TDECDD    *DEC   LEN(2 0)
             DCL        &TCHRDD    *CHAR  LEN(2)

/* THIS PREVENTS THE 'POINTER NOT SET FOR REFERENCE' ERROR +
   WHICH ALLOWS THE COMMAND TO NOT HAVE ALL RETURN VALUES */
             MONMSG     MSGID(MCH3601)

/* GET CURRENT JOB, SYSTEM OR PASSED DATE */
/* AND CONVERT DATES TO DIFFERENT FORMATS */
   IF (&STRDATE *EQ '*JOB')  THEN(DO)
      RTVJOBA DATE(&TODAY)
      CVTDAT     &TODAY   &TCHR6    *JOB *YMD  *NONE
      CVTDAT     &TODAY   &TCHR8    *JOB *YYMD *NONE
      CVTDAT     &TODAY   &TCHRMDY8 *JOB *MDYY *NONE
      CVTDAT     &TODAY   &TCHRMDY6 *JOB *MDY  *NONE
   ENDDO
   IF (&STRDATE *EQ '*SYS')  THEN(DO)
      RTVSYSVAL QDATE &TODAY
      CVTDAT     &TODAY   &TCHR6    *SYSVAL *YMD  *NONE
      CVTDAT     &TODAY   &TCHR8    *SYSVAL *YYMD *NONE
      CVTDAT     &TODAY   &TCHRMDY8 *SYSVAL *MDYY *NONE
      CVTDAT     &TODAY   &TCHRMDY6 *SYSVAL *MDY  *NONE
   ENDDO
   IF (&STRDATE *EQ '*PASS') THEN(DO)
      CVTDAT     &INDATE  &TCHR6    *YYMD   *YMD  *NONE
          MONMSG CPF0000 EXEC(CHGVAR &TCHR6 '000000')
      CVTDAT     &INDATE  &TCHR8    *YYMD   *YYMD *NONE
      CVTDAT     &INDATE  &TCHRMDY8 *YYMD   *MDYY *NONE
      CVTDAT     &INDATE  &TCHRMDY6 *YYMD   *MDY  *NONE
          MONMSG CPF0000 EXEC(CHGVAR &TCHRMDY6 '000000')
   ENDDO

/* HANDLE ADDING OR SUBTRACTING DAYS */
   IF (&ADDDAY    *NE 0 *OR &SUBDAY    *NE 0 *OR +
       &ADDWRKDAY *NE 0 *OR &SUBWRKDAY *NE 0 *OR +
       &ADDMTH    *NE 0 *OR &SUBMTH    *NE 0 *OR +
       &ADDYEAR   *NE 0 *OR &SUBYEAR   *NE 0) (DO)
       CALL SYS275 (&TCHR8 &ADDDAY &SUBDAY &ADDWRKDAY &SUBWRKDAY +
                    &ADDMTH &SUBMTH &ADDYEAR &SUBYEAR)
       CVTDAT     &TCHR8   &TCHR6    *YYMD *YMD  *NONE
          MONMSG CPF0000 EXEC(CHGVAR &TCHR6 '000000')
       CVTDAT     &TCHR8   &TCHRMDY8 *YYMD *MDYY *NONE
       CVTDAT     &TCHR8   &TCHRMDY6 *YYMD *MDY  *NONE
          MONMSG CPF0000 EXEC(CHGVAR &TCHRMDY6 '000000')
   ENDDO

/* SETS UP THE OUT FIELD FOR ALL THE DIFFERENT DATE FORMATS */
             CHGVAR     &TCHRYYYY %SST(&TCHR8 1 4)
             CHGVAR     &TCHRYY   %SST(&TCHR6 1 2)
             CHGVAR     &TCHRMM   %SST(&TCHR6 3 2)
             CHGVAR     &TCHRDD   %SST(&TCHR6 5 2)
             CHGVAR     &TDEC8    &TCHR8
             CHGVAR     &TDEC6    &TCHR6
             CHGVAR     &TDECMDY8 &TCHRMDY8
             CHGVAR     &TDECMDY6 &TCHRMDY6
             CHGVAR     &TDECYYYY &TCHRYYYY
             CHGVAR     &TDECYY   &TCHRYY
             CHGVAR     &TDECMM   &TCHRMM
             CHGVAR     &TDECDD   &TCHRDD

             CHGVAR     &DEC8      &TDEC8
             CHGVAR     &CHR8      &TCHR8
             CHGVAR     &DEC6      &TDEC6
             CHGVAR     &CHR6      &TCHR6
             CHGVAR     &DECMDY8   &TDECMDY8
             CHGVAR     &CHRMDY8   &TCHRMDY8
             CHGVAR     &DECMDY6   &TDECMDY6
             CHGVAR     &CHRMDY6   &TCHRMDY6
             CHGVAR     &DECYYYY   &TDECYYYY
             CHGVAR     &CHRYYYY   &TCHRYYYY
             CHGVAR     &DECYY     &TDECYY
             CHGVAR     &CHRYY     &TCHRYY
             CHGVAR     &DECMM     &TDECMM
             CHGVAR     &CHRMM     &TCHRMM
             CHGVAR     &DECDD     &TDECDD
             CHGVAR     &CHRDD     &TCHRDD
             CHGVAR     &CHRF8    (&TCHRYYYY *CAT '-' *CAT &TCHRMM +
                                   *CAT '-' *CAT &TCHRDD)
             CHGVAR     &CHRF6    (&TCHRYY *CAT '-' *CAT &TCHRMM +
                                   *CAT '-' *CAT &TCHRDD)
             CHGVAR     &CHRFMDY8 (&TCHRMM *CAT '-' *CAT &TCHRDD +
                                   *CAT '-' *CAT &TCHRYYYY)
             CHGVAR     &CHRFMDY6 (&TCHRMM *CAT '-' *CAT &TCHRDD +
                                   *CAT '-' *CAT &TCHRYY)
             CHGVAR     &CHRS8    (&TCHRYYYY *CAT '/' *CAT &TCHRMM +
                                   *CAT '/' *CAT &TCHRDD)
             CHGVAR     &CHRS6    (&TCHRYY *CAT '/' *CAT &TCHRMM +
                                   *CAT '/' *CAT &TCHRDD)
             CHGVAR     &CHRSMDY8 (&TCHRMM *CAT '/' *CAT &TCHRDD +
                                   *CAT '/' *CAT &TCHRYYYY)
             CHGVAR     &CHRSMDY6 (&TCHRMM *CAT '/' *CAT &TCHRDD +
                                   *CAT '/' *CAT &TCHRYY)

/* REMOVES ALL THE ERROR MESSAGE ABOUT FIELDS THAT WERE NOT PASSED */
             RMVMSG     CLEAR(*ALL)

ENDPGM
