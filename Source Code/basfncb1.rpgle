     H DATEDIT(*YMD) OPTION(*SRCSTMT) Dftactgrp(*No) ACTGRP(*NEW)
     ‚*****************************************************************
     ‚* Test Fabricut Functions and Explain                           *
     ‚*****************************************************************
     ‚*€This program tests and explains how to use all functions     ‚*
     ‚*€in the #$FAB service program                                 ‚*
     ‚*š                                                             ‚*
     ‚*€for a list of the functions look in source member            ‚*
     ‚*€  FABLIBR/#$FAB                                              ‚*
     ‚*€                                                             ‚*
     ‚*****************************************************************

      **** this has to be included on an H spec, it can be on the same
      **** line as other hspecs.
     H BNDDIR('APLLIB/APLLIB')
     FQPRINT    O    F  132        PRINTER OFLIND(*INOF)

      **** this has to be included, it contains the prototypes required
      **** to use the functions
     D/COPY APLLIB/QSRC,BASFNCV1PR  // Includes all prototye for #$ functions
     D WORDS           S            100    DIM(10)
     D WRAPARRAY       S            250    DIM(250)
     D CSTEXT          S            480A
     D COLS            DS
     D  COL01                  1     10
     D  COL02                 11     20
     D  COL03                 21     30
     D  COL04                 31     40
     D  COL05                 41     50
     D  COL06                 51     60
     D  COL07                 61     70
     D  COL08                 71     80
     D  COL09                 81     90
     D  COL10                 91    100
     D  COL11                101    110
     D  COL12                111    120
     D   #$OBJ         S             10
     D   #$LIB         S             10
     D   #$TYPE2       S             10

     C*
     C* FIELD OUTPUT IS USED TO PRINT RESULTS
     C                   MOVE      *BLANKS       OUTPUT          132
     C                   MOVE      *BLANKS       TITLE            50
     C*
     C* #$CNTR - Centers text based on a field length.
     C* Pass field and the length you want it centered to
     C                   EVAL      TITLE=#$CNTR('MISCELLANEOUS FUNCTIONS':50)
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$CNTR - CENTER A FIELD'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT YOU WANT +
     C                                     CENTERED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = THE LENGTH OF +
     C                                     THE OUTPUT FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE FIELD CENTERED'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$CNTR(''CENTER ME'':50) = ''' +
     C                                    #$CNTR('CENTER ME':50) +''''
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CNTR(''CENTER ME'':30) = ''' +
     C                                    #$CNTR('CENTER ME':30) +''''
     C                   EXCEPT    #DTL
     C*
     C* #$upify - Covnerts text to all uppercase
     C* Pass field you want converted
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$UPIFY - CONVERT TO UPPERCASE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT YOU WANT +
     C                                     CONVERTED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE TEXT IN ALL +
     C                                     UPPERCASE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$UPIFY(''Upper Me'') = ' +
     C                                    #$UPIFY('Upper Me')
     C                   EXCEPT    #DTL
     C*
     C* #$lowfy - Covnerts text to all lowercase
     C* Pass field you want converted
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$LOWFY - CONVERT TO LOWERCASE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT YOU WANT +
     C                                     CONVERTED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE TEXT IN ALL +
     C                                     LOWERCASE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$LOWFY(''Lower Me'') = ' +
     C                                    #$LOWFY('Lower Me')
     C                   EXCEPT    #DTL
     C*
     C* #$EDTZP - EDITS A ZIP CODE
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$EDTZP - EDITING ZIP CODES'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = AN UNFORMATTED +
     C                                     ZIP CODE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE FORMATTED +
     C                                     ZIP CODE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$EDTZP(''11234'')      = ' +
     C                                     #$EDTZP('11234')
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$EDTZP(''112341234'')  = ' +
     C                                     #$EDTZP('112341234')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$EDTZP(''112340000'')  = ' +
     C                                     #$EDTZP('112340000')
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$EDTZP(''1123400000'') = ' +
     C                                     #$EDTZP('1123400000')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$EDTZP(''11234-1234'') = ' +
     C                                     #$EDTZP('11234-1234')
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$EDTZP(''A12 B6'')     = ' +
     C                                     #$EDTZP('A12 B6')
     C                   EXCEPT    #DTL
     C*
     C*
     C* #$FHTML - ESCAPES HTML SPECIAL CHARACTERS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FHTML - ESCAPE HTML SPECIAL +
     C                                     CHARACTERS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='REQUIRED FOR TEXT GOING TO A WEBSITE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A TEXT FIELD WITH +
     C                                     HTML SPECIAL CHARACTERS ESCAPED OUT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$FHTML(''IT''S A   GOOD DAY'') ='''+
     C                                     #$FHTML('IT''S A   GOOD DAY') + ''''
     C                   EXCEPT    #DTL
     C*
     C* #$RVL - GETS A NUMBER FROM A CHARACTER STRING
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$RVL - GET A NUMBER FROM A +
     C                                     CHARACTER STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     DERIVED FROM THE TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='CHARACTERS J-R AND } ARE +
     C                                     CONVERTED TO 1-9 AND 0, +
     C                                     AND MADE NEGATIVE TO HANDLE +
     C                                     SIGNED NUMERICS.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='IGNORES MOST OTHER CHARACTERS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$RVL(''1'')      = ' +
     C                                     %TRIM(%EDITC(#$RVL('1'):'M'))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$RVL(''1.123'')  = ' +
     C                                     %TRIM(%EDITC(#$RVL('1.123'):'M'))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$RVL(''1.123-'') = ' +
     C                                     %TRIM(%EDITC(#$RVL('1.123-'):'M'))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$RVL(''1.12L'')  = ' +
     C                                     %TRIM(%EDITC(#$RVL('1.12L'):'M'))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$RVL(''ABC'')    = ' +
     C                                     %TRIM(%EDITC(#$RVL('ABC'):'M'))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$RVL(''AJC'')    = ' +
     C                                     %TRIM(%EDITC(#$RVL('AJC'):'M'))
     C                   EXCEPT    #DTL
     C*
     C* #$RND05 - ROUNDS A NUMBER UP TO THE NEAREST NICKEL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$RND05 - ROUNDS A NUMBER UP +
     C                                     TO THE NEAREST NICKLE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NUMERIC VALUE +
     C                                     ROUNDED UP TO THE NEAREST NICKLE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$RND05(123.45) = ' +
     C                                     %TRIM(%EDITC(#$RND05(123.45):'M'))
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$RND05(123.47) = ' +
     C                                     %TRIM(%EDITC(#$RND05(123.47):'M'))
     C                   EVAL      %SUBST(OUTPUT:80:40) =
     C                                    '#$RND05(123.50) = ' +
     C                                     %TRIM(%EDITC(#$RND05(123.50):'M'))
     C                   EXCEPT    #DTL
     C*
     C* #$RNDUP - ROUNDS A NUMBER UP TO THE NEXT INTEGER
     C                   EVAL      OUTPUT='#$RNDUP - ROUNDS A NUMBER UP +
     C                                     TO THE NEXT INTEGER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NUMERIC VALUE +
     C                                     ROUNDED UP TO THE NEXT INTEGER'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$RNDUP(123.45) = ' +
     C                                     %TRIM(%EDITC(#$RNDUP(123.45):'M'))
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$RNDUP(123.0001) = ' +
     C                                     %TRIM(%EDITC(#$RNDUP(123.0001):'M'))
     C                   EVAL      %SUBST(OUTPUT:80:40) =
     C                                    '#$RNDUP(123.00) = ' +
     C                                     %TRIM(%EDITC(#$RNDUP(123.00):'M'))
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$RNDUP(123.45:50) = ' +
     C                                     %TRIM(%EDITC(#$RNDUP(123.45:50):'M'))
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$RNDUP(123.0001:.05) = ' +
     C                                 %TRIM(%EDITC(#$RNDUP(123.0001:.05):'M'))
     C                   EVAL      %SUBST(OUTPUT:80:40) =
     C                                    '#$RNDUP(123.23:.05) = ' +
     C                                 %TRIM(%EDITC(#$RNDUP(123.23:.05):'M'))
     C                   EXCEPT    #DTL
     C*
     C* #$UCC - RETURNS A STING IN UCC FORMAT
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$UCC - FORMAT A UCC STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE STRING EDITED +
     C                                     AS A UCC CODE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$UCC(''12345678901234'')   = ' +
     C                                     #$UCC('12345678901234')
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$UCC(''1234567890123'')    = ' +
     C                                     #$UCC('1234567890123')
     C                   EXCEPT    #DTL
     C*
     C* #$UPC - RETURNS A STING IN UPC FORMAT
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$UPC - FORMAT A UPC STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE STRING EDITED +
     C                                     AS A UPC CODE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$UPC(''123456789012'')   = ' +
     C                                     #$UPC('123456789012')
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$UPC(''12345678901'')    = ' +
     C                                     #$UPC('12345678901')
     C                   EXCEPT    #DTL
     C*
     C* #$XMLESC - ESCAPE XML SPECIAL CHARACTERS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$ESCXML - ESCAPE XML SPECIAL +
     C                                     CHARACTERS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE SAME STRING +
     C                                     WITH XML SPECIAL CHARACTERS +
     C                                     ESCAPED OUT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$XMLESC(''<DATE>'') = ' +
     C                                     #$XMLESC('<DATE>')
     C                   EXCEPT    #DTL
     C*
     C* #$SPLIT - Splits words into an array or delimited text
     C*
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$SPLIT - SPLITS WORD OR +
     C                                     DELIMITED TEXT INTO AN ARRAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT YOU WANT +
     C                                     SPLIT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, THE +
     C                                     DELIMITER'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='              IF NOT PASSED +
     C                                     IT WILL USE A BLANK'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = AN ARRAY OF THE +
     C                                                   SPLIT VALUES'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='WORDS=#$SPLIT(''I AM A SENTENCE'')'''
     C                   EXCEPT    #DTL
     C                   EVAL      WORDS=#$SPLIT('I AM A SENTENCE')
     C                   EVAL      OUTPUT='WORDS(1) = ' + WORDS(1)
     C                   EVAL      %SUBST(OUTPUT:30:30) =
     C                                    'WORDS(2) = ' + WORDS(2)
     C                   EVAL      %SUBST(OUTPUT:60:30) =
     C                                    'WORDS(3) = ' + WORDS(3)
     C                   EVAL      %SUBST(OUTPUT:90:30) =
     C                                    'WORDS(4) = ' + WORDS(4)
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='WORDS=#$SPLIT(''ONE,TWO,THREE''+
     C                                                   :'','')'''
     C                   EXCEPT    #DTL
     C                   EVAL      WORDS=#$SPLIT('ONE,TWO,THREE':',')
     C                   EVAL      OUTPUT='WORDS(1) = ' + WORDS(1)
     C                   EVAL      %SUBST(OUTPUT:30:30) =
     C                                    'WORDS(2) = ' + WORDS(2)
     C                   EVAL      %SUBST(OUTPUT:60:30) =
     C                                    'WORDS(3) = ' + WORDS(3)
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='WARNING DOES NOT HANDLE STRING +
     C                                     DELIMITERS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='WORDS=#$SPLIT(''"TIM","TIM,T""''+
     C                                                   :'','')'''
     C                   EXCEPT    #DTL
     C                   EVAL      WORDS=#$SPLIT('"TIM","TIM,T"':',')
     C                   EVAL      OUTPUT='WORDS(1) = ' + WORDS(1)
     C                   EVAL      %SUBST(OUTPUT:30:30) =
     C                                    'WORDS(2) = ' + WORDS(2)
     C                   EVAL      %SUBST(OUTPUT:60:30) =
     C                                    'WORDS(3) = ' + WORDS(3)
     C                   EXCEPT    #DTL
     C*
     C* #$EDTC - Edits a Numeric Variable
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$EDTC - EDITS A NUMERIC +
     C                                     VARIABLE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = ANY NUMERIC +
     C                                     VALUE UP TO 15,5'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = EDIT CODE, SEE +
     C                                     LIST'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL, DECIMAL +
     C                                     PRECISION, VALUE 1-5, DEFAULT=FLOAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 4 = OPTIONAL, RIGHT +
     C                                     JUSTIFY, VALUE 1-30'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 5 = OPTIONAL, ROUND +
     C                                     Y/N, DEFAULT Y, ONLY USED IF +
     C                                     DEC. PRECISION IS USED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A CHARACTER STRING OF +
     C                                                   THE EDITED VALUE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
        OUTPUT=' Edit Codes Allowed With Examples                             +
                Special Edit Codes                                            ';
        EXCEPT    #DTL;
        EXCEPT    #OVL;
        OUTPUT='           ZEROS     -        -            NO                 +
                Y = Date edit         101005="10/10/05"     91099=" 9/10/99"  ';
        EXCEPT    #DTL;
        OUTPUT='  COMMAS    BAL    (LEFT)  (RIGHT)   CR   SIGN    ()          +
                V = Date edit W/0     101005="10/10/05"     91099="09/10/99"  ';
        EXCEPT    #DTL;
        OUTPUT='    YES     YES      N        J      A     1       E          +
                W = Date edit 4 Digit 10102005="10/10/2005" 91099=" 9/10/1999"';
        EXCEPT    #DTL;
        OUTPUT='    YES     NO       O        K      B     2       F          +
                T = Time edit         123115="12:31:10"     10500=" 1:05:00"  ';
        EXCEPT    #DTL;
        OUTPUT='    NO      YES      P        L      C     3       G          +
                Z,X = Suppress Leading 0, no sign, no dec   000123.12- = 12312';
        EXCEPT    #DTL;
        OUTPUT='    NO      NO       Q        M      D     4       H          +
                S = Sales Order       123115="  1231-15"    10500="    105-00"';
        EXCEPT    #DTL;

        EXCEPT    #SPC;
        OUTPUT='#$EDTC(1:''M'')              = ''' +
                #$EDTC(1:'M') + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTC(-1.1:''A'')               = ''' +
                #$EDTC(-1.1:'A') + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTC(-1:''E'':2)           = ''' +
                #$EDTC(-1:'E':2) + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTC(1:''M'':2:9)              = ''' +
                #$EDTC(1:'M':2:9) + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTC(1.1234:''M'':2:9)     = '''+
                #$EDTC(1.1234:'M':2:9)+'''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTC(1.1234:''M'':2:9:''N'')     = ''' +
                #$EDTC(1.1234:'M':2:9:'N') + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTC(1.1234:''M'':2:0:''N'') = ''' +
                #$EDTC(1.1234:'M':2:0:'N') + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTC(1.1234:''M'':2:*OMIT:''N'') = ''' +
                #$EDTC(1.1234:'M':2:*OMIT:'N') + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTC(20181009:''Y'')       = ''' +
                #$EDTC(20181009:'Y') + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTC(123105:''T'')             = ''' +
                #$EDTC(123105:'T') + '''';
        EXCEPT    #DTL;
     C*
     C* #$EDTP - Edits a Numeric PHONE NUMBER
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$EDTP - EDITS A NUMERIC +
     C                                     PHONE NUMBER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = NUMERIC +
     C                                     PHONE NUMBER UP TO 11,0'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A CHARACTER STRING OF +
     C                                               THE EDITED PHONE NUMBER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC

        OUTPUT='#$EDTP(11235551234) = ''' +
                #$EDTP(11235551234) + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTP(01235551234) = ''' +
                #$EDTP(01235551234) + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTP(01235551234) = ''' +
                #$EDTP(01235551234) + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTP(5551234)     = ''' +
                #$EDTP(5551234) + '''';
        EXCEPT    #DTL;
        OUTPUT='#$EDTP(41235551234) = ''' +
                #$EDTP(41235551234) + '''';
        %SUBST(OUTPUT:50:50) =
               '#$EDTP(551234)      = ''' +
                #$EDTP(551234) + '''';
        EXCEPT    #DTL;
     C*
     C* #$VEML - VALIDATES AN EMAIL ADDRESS
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$VEML - VALIDATES AN EMAIL ADDRESS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = EMAIL ADDRESS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON FOR INVALID +
     C                                     ADDRESS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC

        OUTPUT='#$VEML(''TIM@TEST.COM'') = ' + #$VEML( 'TIM@TEST.COM' );
        %SUBST(OUTPUT:40:40) =
               '#$VEML(''TIM#TEST.COM'') = ' + #$VEML( 'TIM#TEST.COM' );
        %SUBST(OUTPUT:80:40) =
               '#$VEML(''TIM@TEST,COM'') = ' + #$VEML( 'TIM@TEST,COM' );
        EXCEPT    #DTL;

        OUTPUT='#$VEML(''TIM@.COM    '') = ' + #$VEML( 'TIM@.COM    ' );
        %SUBST(OUTPUT:40:40) =
               '#$VEML(''@TEST.COM   '') = ' + #$VEML( '@TEST.COM   ' );
        %SUBST(OUTPUT:80:40) =
               '#$VEML(''TIM@TE@T.COM'') = ' + #$VEML( 'TIM@TE@T.COM' );
        EXCEPT    #DTL;
     C*
     C* #$TESTN - TEST A FIELD FOR NUMERIC VALUE
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TESTN - TEST A FIELD FOR NUMERICS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT YOU WANT +
     C                                     TESTED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, PASS +
     C                                     A 1 TO ALLOW LEADING BLANKS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL, PASS +
     C                                     A 1 TO ALLOW TRAILING BLANKS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 4 = OPTIONAL, PASS +
     C                                     A 1 TO ALLOW NAGTIVE SIGNS "-"'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = BOOLEAN TRUE IF +
     C                                                   NUMERIC'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TESTN(''12345'') = ' +
     C                                     #$TESTN( '12345' )
     C                   EVAL      %SUBST(OUTPUT:32:30) =
     C                                    '#$TESTN('' 12345'') = ' +
     C                                     #$TESTN( ' 12345' )
     C                   EVAL      %SUBST(OUTPUT:64:30) =
     C                                    '#$TESTN(''12345 '') = ' +
     C                                     #$TESTN( '12345 ' )
     C                   EVAL      %SUBST(OUTPUT:96:30) =
     C                                    '#$TESTN(''12345-'') = ' +
     C                                     #$TESTN( '12345-' )
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$TESTN('' 12345- '') = ' +
     C                                     #$TESTN( ' 12345- ' )
     C                   EVAL      %SUBST(OUTPUT:32:30) =
     C                                    '#$TESTN('' 12345'':1) = ' +
     C                                     #$TESTN( ' 12345' :1)
     C                   EVAL      %SUBST(OUTPUT:64:30) =
     C                                    '#$TESTN(''12345 '':0:1) = ' +
     C                                     #$TESTN( '12345 ' :0:1)
     C                   EVAL      %SUBST(OUTPUT:96:30) =
     C                                    '#$TESTN(''12345-'':0:0:1) = ' +
     C                                     #$TESTN( '12345-' :0:0:1)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$TESTN('' 12345- '':1:1:1) = ' +
     C                                     #$TESTN( ' 12345- ' :1:1:1)
     C                   EVAL      %SUBST(OUTPUT:32:30) =
     C                                    '#$TESTN(''1234J'') = ' +
     C                                     #$TESTN( '1234J' )
     C                   EVAL      %SUBST(OUTPUT:64:30) =
     C                                    '#$TESTN('' '':1:1) = ' +
     C                                     #$TESTN( ' ':1:1 )
     C                   EVAL      %SUBST(OUTPUT:96:30) =
     C                                    '#$TESTN(''ZERO'':1:1:1) = ' +
     C                                     #$TESTN( 'ZERO' :1:1:1)
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #HDR
     C* #$LAST - RETURNS THE LAST CHARACTERS OF A STRING
     C                   EVAL      OUTPUT='#$LAST - RETURNS THE LAST +
     C                                     CHARACTERS OF A STRING.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF CHARACTERS +
     C                                     TO RETURN'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE REQUESTED NUMBER +
     C                                     OF CHARACTERS FROM THE END OF A +
     C                                     STRING'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$LAST(''SOMEFILE.PDF'':4) = ' +
     C                                     #$LAST('SOMEFILE.PDF':4)
     C                   EVAL      %SUBST(OUTPUT:51:50) =
     C                                    '#$LAST(''TEMPFILWK'':2) = ' +
     C                                     #$LAST('TEMPFILWK':2)
     C                   EXCEPT    #DTL
     C*
     C* #$CMD - RUNS A COMAND
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$CMD - RUNS A COMMAND.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A COMMAND'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = ERROR HANDLING, +
     C                                                   OPTIONAL'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='              0, DEFAULT, ANY +
     C                                     ERRORS ARE DISPLAYED IN A WINDOW'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='              1, ERRORS ARE +
     C                                     IGNORED'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='              2, CRASH, THEY +
     C                                     MUST BE MONITORED FOR IN THE +
     C                                     PROGRAM.'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$CMD(''OVRPRTF QPRINT +
     C                                     OUTQ(QPRINT3B)'')'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CMD(''ADDLIBLE ACOM'':1) +
     C                                     THIS WILL JUST IGNORE ANY +
     C                                     ERRORS THAT HAPPEN.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CMD(''DLTF QTEMP/WORKFILE'':2) +
     C                                     ERRORS ARE RETURNED TO THE PROGRAM, +
     C                                     PUT IN A MONITOR GROUP TO CHECK +
     C                                     FOR THEM.'
     C                   EXCEPT    #DTL
     C*
     C* #$DSPWIN - DISPLAYS SOME TEXT IN A WINDOW
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DSPWIN - DISPLAYS SOME TEXT +
     C                                     IN A WINDOW.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = TEXT TO DISPLAY'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = MESSAGE ID, +
     C                                     OPTIONAL, WILL PULL THE +
     C                                     WINDOW TITLE FROM THE MESSAGE FILE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = MESSAGE FILE, +
     C                                     OPTIONAL, USED WITH THE MESSAGE ID'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DSPWIN(''SOME MESSAGE TO +
     C                                     DSIPLAY'')'
     C                   EXCEPT    #DTL
     C*
     C* #$URIESC - ESCAPE URI SPECIAL CHARACTERS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$URIESC - ESCAPE URI SPECIAL +
     C                                     CHARACTERS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, 1=''+'' +
     C                                     FOR SPACES, 2=''%20'' FOR +
     C                                     SPACES, DEFAUTLS TO 1'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL, 1=USE +
     C                                     UPPER CASE FOR HEX VALUES, 0=+
     C                                     LOWER CASE, DEFAUTLS TO 0'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE SAME STRING +
     C                                     WITH URI SPECIAL CHARACTERS +
     C                                     ESCAPED OUT'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$URIESC(''<begin> ! </begin>''+
     C                                     ) = ' +
     C                                     #$URIESC('<begin> ! </begin>')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$URIESC(''<begin> ! </begin>''+
     C                                     :2) = ' +
     C                                     #$URIESC('<begin> ! </begin>':2)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$URIESC(''<begin> ! </begin>''+
     C                                     :1:1) = ' +
     C                                     #$URIESC('<begin> ! </begin>')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$URIESC(''<begin> ! </begin>''+
     C                                     :2:1) = ' +
     C                                     #$URIESC('<begin> ! </begin>':2:1)
     C                   EXCEPT    #DTL
     C*
     C* #$URIDESC - UN-ESCAPE URI SPECIAL CHARACTERS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$URIDESC - UN-ESCAPE URI SPECIAL +
     C                                     CHARACTERS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE SAME STRING +
     C                                     WITH URI SPECIAL CHARACTERS +
     C                                     UN-ESCAPED'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$URIDESC(''%3cbegin%3e+
     C                                     3e+%21+%3c%2fbegin%3e'') + ' +
     C                                     #$URIDESC('%3cbegin+
     C                                     3e+%21+%3c%2fbegin%3e')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$URIDESC(''%3Cbegin%3E+
     C                                     %20%21%20%3C%2fbegin%3E'') + ' +
     C                                     #$URIDESC('%3Cbegin%3E+
     C                                     %20%21%20%3C%2fbegin%3E')
     C                   EXCEPT    #DTL
     C*
     C* #$SQLESC - ESCAPE A STRING THAT WILL BE USED IN AN SQL STATEMENT
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SQLESC - ESCAPE A STRING THAT +
     C                                     WILL BE USED IN AN SQL STATEMENT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TEXT STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, CONVERT * +
     C                                     DEFAULTS TO 1, 1=YES, 0=NO'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE SAME STRING +
     C                                     WITH SINGLE QUOTES DOUBLED +
     C                                     AND * CONVERTED TO %'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SQLESC(''*DON''T*'') = ' +
     C                                     #$SQLESC('*DON''T*')
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$SQLESC(''*DON''T*'':0) = ' +
     C                                     #$SQLESC('*DON''T*':0)
     C                   EXCEPT    #DTL
     C*
     C* #$FLDTXT - RETURNS THE TEXT FOR A FIELD NAME
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FLDTXT - RETURNS THE TEXT +
     C                                     FOR A FIELD NAME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = FILE NAME'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = FIELD NAME'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = LIBRARY, +
     C                                     OPTIONAL, DEFAULTS TO *LIBL'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE TEXT FOR THE +
     C                                     FIELDS, IF THE TEXT IS NOT FOUND +
     C                                     IT RETURNS THE COLHDG, IF AN +
     C                                     ERROR OCCURS IT RETURNS ''ERROR'''
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FLDTXT(''CUST'':''CNUM'') = ' +
     C                                     #$FLDTXT('CUST':'CNUM')
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$FLDTXT(''CUST'':''CNUM''' +
     C                                    ':''ARRLIB'') = ' +
     C                                     #$FLDTXT('CUST':'CNUM':'ARRLIB')
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$FLDTXT(''CUST'':''CNAM'') = ' +
     C                                     #$FLDTXT('CUST':'CNAM')
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$FLDTXT(''CUST'':''NO'') = ' +
     C                                     #$FLDTXT('CUST':'NO')
     C                   EXCEPT    #DTL
     C*
     C* #$RTVOBJD - RETRIEVES AN OBJECTS DESCRIPTION
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$RTVOBJD - RETRIEVES AN OBJECTS +
     C                                     DESCRIPTION'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = OBJECT NAME'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = LIBRARY'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = TYPE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE #$OBJD +
     C                                     DATA STRUCTURE DEFINED IN +
     C                                     #$INCLUDE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      #$OBJ='OEI001'
     C                   EVAL      #$LIB='OEILIB'
     C                   EVAL      #$TYPE2='*PGM'
     C                   EXSR      TEST
     C*
     C                   EVAL      #$OBJ='OEC001'
     C                   EVAL      #$LIB='OEILIB'
     C                   EVAL      #$TYPE2='*PGM'
     C                   EXSR      TEST
     C*
     C* #$FILE - RETURNS THE FILE PART OF A PATH
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FILE - RETURNS THE FILE PART +
     C                                     OF A PATH'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = PATH'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE FILE +
     C                                     PART OF A PATH'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FILE(''/TOG/FILE.XLS'') = ' +
     C                                     #$FILE('/TOG/FILE.XLS')
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$FILE(''\TOG\TEMP\FILE.XLS'') = ' +
     C                                     #$FILE('/TOG/TEMP/FILE.XLS')
     C                   EXCEPT    #DTL
     C*
     C* #$FOLDER - RETURNS THE FOLDER PART OF A PATH
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FOLDER - RETURNS THE FOLDER PART +
     C                                     OF A PATH'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = PATH'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE FOLDER +
     C                                     PART OF A PATH'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$FOLDER(''/TOG/FILE.XLS'') = ' +
     C                                     #$FOLDER('/TOG/FILE.XLS')
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                   '#$FOLDER(''\TOG\TEMP\FILE.XLS'') = ' +
     C                                    #$FOLDER('/TOG/TEMP/FILE.XLS')
     C                   EXCEPT    #DTL
     C*
     C* #$VPHN - VALIDATES AN PHONE NUMBER
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$VPHN - VALIDATES A PHONE NUMBER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = PHONE NUMBER, 30 CHAR'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON FOR INVALID +
     C                                     PHONE NUMBER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC

        OUTPUT='#$VPHN(''9185551234'') = ' + #$VPHN( '9185551234' );
        %SUBST(OUTPUT:40:40) =
               '#$VPHN(''918-555-1234'') = ' + #$VPHN( '918-555-1234' );
        %SUBST(OUTPUT:80:40) =
               '#$VPHN(''19185551234'') = ' + #$VPHN( '19185551234' );
        EXCEPT    #DTL;

        OUTPUT='#$VPHN(''123456      '') = ' + #$VPHN( '123456      ' );
        %SUBST(OUTPUT:40:40) =
               '#$VPHN(''918@5551234 ''_ = ' + #$VPHN( '918@5551234 ' );
        %SUBST(OUTPUT:80:40) =
               '#$VPHN(''12345678912345'') = ' + #$VPHN( '123456789012345' );
        EXCEPT    #DTL;

        OUTPUT='#$VPHN(''011 44 11 22 33 44 55'') = ' +
                #$VPHN( '011 44 11 22 33 44 55' );
        %SUBST(OUTPUT:40:40) =
               '#$VPHN(''011-44-11-22-33-44-55'') = ' +
                #$VPHN( '011-44-11-22-33-44-55' );
        %SUBST(OUTPUT:80:40) =
               '#$VPHN(''1 (918) 555-1234'') = ' +
                #$VPHN( '1 (918) 555-1234' );
        EXCEPT    #DTL;
     C*
     C* #$JSONESC - ESCAPES SPECIAL CHARACTERS IN A JSON STRING
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$JSONESC - ESCAPES SPECIAL +
     C                                     CHARACTERS IN A JSON STRING.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A CHARACTER STRING +
     C                                     UP TO 4096 IN LENGTH.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE SAME STRING +
     C                                     WITH JSON SPECIAL CHARACTERS +
     C                                     ESCAPED.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC

        OUTPUT='#$JSONESC(''"THIS IS IN DOUBLE QUOTES" ' +
                           ' BACKSLASH->\' +
                           ' BACKSPACE->' + X'16' + ' ' +
                           ' FORMFEED->' + X'0C' + ' ' +
                           ' NEWLINE->' + X'25' + ' ' +
                           ' CARRIAGE RETURN->' + X'0D' + ' ' +
                           ' TAB->' + X'05' + ''')';
        EXCEPT    #DTL;
        OUTPUT= #$JSONESC( '"THIS IS IN DOUBLE QUOTES" ' +
                           ' BACKSLASH->\' +
                           ' BACKSPACE->' + X'16' + ' ' +
                           ' FORMFEED->' + X'0C' + ' ' +
                           ' NEWLINE->' + X'25' + ' ' +
                           ' CARRIAGE RETURN->' + X'0D' + ' ' +
                           ' TAB->' + X'05');
        EXCEPT    #DTL;
     C*
     C* #$ISFILE - TEST IF A FILE EXISTS
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$ISFILE - TEST IF IS A FILE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = FILE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, LIBRARY, +
     C                                     DEFAULTS TO *LIBL'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON IF THE FILE EXISTS'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$ISFILE(''INVEN'') = ' +
     C                                     #$ISFILE( 'INVEN' )
     C                   EVAL      %SUBST(OUTPUT:33:30) =
     C                                    '#$ISFILE(''INVEN'':''NVTLIB'') = ' +
     C                                     #$ISFILE( 'INVEN' : 'NVTLIB' )
     C                   EVAL      %SUBST(OUTPUT:66:30) =
     C                                    '#$ISFILE(''INVEN'':''OEILIB'') = ' +
     C                                     #$ISFILE( 'INVEN' : 'OEILIB' )
     C                   EVAL      %SUBST(OUTPUT:99:30) =
     C                                    '#$ISFILE(''INVEN'':''TESTER'') = ' +
     C                                     #$ISFILE( 'INVEN' : 'TESTER' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$ISLIB - TEST IF A LIBRARY EXISTS
     C                   EVAL      OUTPUT='#$ISLIB - TEST IF A LIBRARY EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = LIBRARY, CHAR(10)'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON IF THE FILE EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ISLIB(''NVTLIB'') = ' +
     C                                     #$ISLIB( 'NVTLIB' )
     C                   EVAL      %SUBST(OUTPUT:33:30) =
     C                                    '#$ISLIB(''ASBDF'') = ' +
     C                                     #$ISLIB( 'ASBDF' )
     C                   EVAL      %SUBST(OUTPUT:66:30) =
     C                                    '#$ISLIB(''QTEMP'') = ' +
     C                                     #$ISLIB( 'QTEMP' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$ISOUTQ - TEST IF AN OUTPUT QUEUE EXISTS
     C                   EVAL      OUTPUT='#$ISOUTQ - TEST IF AN OUTPUT QUEUE +
     C                                     EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = OUTPUT QUEUE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, LIBRARY, +
     C                                     DEFAULTS TO *LIBL'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON IF THE OUTQ EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ISOUTQ(''TOGOUTQ'') = ' +
     C                                     #$ISOUTQ( 'TOGOUTQ' )
     C                   EVAL      %SUBST(OUTPUT:33:30) =
     C                                    '#$ISOUTQ(''ASBDF'') = ' +
     C                                     #$ISOUTQ( 'ASBDF' )
     C                   EVAL      %SUBST(OUTPUT:66:30) =
     C                                    '#$ISOUTQ(''TOGOUTQ'':''QGPL'') = ' +
     C                                     #$ISOUTQ( 'TOGOUTQ' : 'QGPL' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$ISOBJ - TEST IF AN OBJECT EXISTS
     C                   EVAL      OUTPUT='#$ISOBJ - TEST IF AN OBJECT +
     C                                     EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = OBJECT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = TYPE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL, LIBRARY, +
     C                                     DEFAULTS TO *LIBL'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON IF THE OBJECT +
     C                                     EXISTS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ISOBJ(''TOGOUTQ'':''*OUTQ'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*OUTQ' )
     C                   EVAL      %SUBST(OUTPUT:43:43) =
     C                                    '#$ISOBJ(''TOGOUTQ'':''*OUTQ'':+
     C                                             ''QGPL'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*OUTQ' :
     C                                              'QGPL' )
     C                   EVAL      %SUBST(OUTPUT:86:43) =
     C                                    '#$ISOBJ(''TOGOUTQ'':''*FILE'':+
     C                                             ''QGPL'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*FILE' :
     C                                              'QGPL' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ISOBJ(''TOGOUTQ'':''*LIB'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*LIB' )
     C                   EVAL      %SUBST(OUTPUT:43:43) =
     C                                    '#$ISOBJ(''TOGOUTQ'':''*LIB'':+
     C                                             ''QGPL'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*LIB' :
     C                                              'QGPL' )
     C                   EVAL      %SUBST(OUTPUT:86:43) =
     C                                    '#$ISOBJ(''TOGOUTQ'':''*OUTQ'':+
     C                                             ''TOGLIB'') = ' +
     C                                     #$ISOBJ( 'TOGOUTQ' : '*OUTQ' :
     C                                              'TOGLIB' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$ISMBR - TEST IF A MEMBER EXISTS
     C                   EVAL      OUTPUT='#$ISMBR - TEST IF A MEMBER +
     C                                     EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = LIBRARY'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = FILE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = MEMEBER'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = *ON IF THE MEMBER +
     C                                     EXISTS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ISMBR(''FABLIBR'':''QRPGLESRC'':+    +
     C                                             ''SYS002'') = ' +
     C                                     #$ISMBR( 'FABLIBR' : 'QRPGLESRC' :
     C                                              'SYS002' )
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ISMBR(''FABLIBR'':''QRPGLESRC'':+    +
     C                                             ''SYS001'') = ' +
     C                                     #$ISMBR( 'FABLIBR' : 'QRPGLESRC' :
     C                                              'SYS001' )
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ISMBR(''FABLIBR'':''QDDSSRC'':+    +
     C                                             ''SYS002'') = ' +
     C                                     #$ISMBR( 'FABLIBR' : 'QDDSSRC' :
     C                                              'SYS002' )
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ISMBR(''FABLIB'':''QRPGLESRC'':+    +
     C                                             ''SYS002'') = ' +
     C                                     #$ISMBR( 'FABLIB' : 'QRPGLESRC' :
     C                                              'SYS002' )
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ISMBR(''FABLIBR'':''QRPGSRC'':+    +
     C                                             ''SYS002'') = ' +
     C                                     #$ISMBR( 'FABLIBE' : 'QRPGSRC' :
     C                                              'SYS002' )
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ISMBR(''FABLIBE'':''QRPGSRC'':+    +
     C                                             ''SYS001'') = ' +
     C                                     #$ISMBR( 'FABLIBE' : 'QRPGSRC' :
     C                                              'SYS001' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C*
     C* #$SCANR - FIND THE LAST OCCURANCE OF A STRING
     C                   EVAL      OUTPUT='#$SCANR - FIND THE LAST OCCURANCE +
     C                                     LAST A STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = SEARCH STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = STRING TO SEARCH IN'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL, STARTING +
     C                                     POSITITON OF SEARCH'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE LAST LOCATION OF +
     C                                     THE SEARCH ARGUMENT IN THE PASSED +
     C                                     STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$SCANR(''IS'':''+
     C                                            ''THIS IS A SEARCH STRING'') +
     C                                            = ' + %CHAR(
     C                                     #$SCANR( 'IS':
     C                                            'THIS IS A SEARCH STRING'))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SCANR(''IS'':''+
     C                                            ''THIS IS A SEARCH STRING'':+
     C                                            5)= ' + %CHAR(
     C                                     #$SCANR( 'IS':
     C                                            'THIS IS A SEARCH STRING':5))
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$C1ST - FORMAT A STRING SO THE FIRST CHARACTER OF EVERY WORD IF CAPITOL
     C                   EVAL      OUTPUT='#$C1ST - FORMAT A STRING SO THE +
     C                                     FIRST LETTER OF EACH WORD IS +
     C                                     UPPERCASE AND THE REST IS LOWER CASE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = STRING'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE FORMATTED STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$C1ST(''THIS IS A STRING'') = ' +
     C                                     #$C1ST( 'THIS IS A STRING' )
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$C1ST(''another string'') = ' +
     C                                     #$C1ST( 'another string' )
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EXCEPT    #HDR
     C* #$VEML2 - VALIDATE AN EMAIL ADDRESS, RETURNS ERROR MESSAGE
     C                   EVAL      OUTPUT='#$VEML2- VALIDATE AN EMAIL ADDRESS, +
     C                                     RETRUNS ERROR MESSAGE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = EMAIL ADDRESS TO +
     C                                     VALIDATE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = ERROR MESSAGE +
     C                                     CENTERED, 50 CHARACTERS LONG +
     C                                     FORMATTED FOR ERM.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
        OUTPUT='#$VEML2(''TIM@TEST.COM'') = '''+#$VEML2( 'TIM@TEST.COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''@TEST.COM   '') = '''+#$VEML2( '@TEST.COM   ' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM#TEST.COM'') = '''+#$VEML2( 'TIM#TEST.COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TE@T.COM'') = '''+#$VEML2( 'TIM@TE@T.COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TEST,COM'') = '''+#$VEML2( 'TIM@TEST,COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@.COM    '') = '''+#$VEML2( 'TIM@.COM    ' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TEST.   '') = '''+#$VEML2( 'TIM@TEST.   ' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TEST    '') = '''+#$VEML2( 'TIM@TEST    ' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TST..COM'') = '''+#$VEML2( 'TIM@TST..COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TEST567890123456789012345678901234567890+
                          1234567890123456789012345@TST.COM'') +
          = '''+#$VEML2( 'TEST567890123456789012345678901234567890+
                          1234567890123456789012345@TST.COM' )+'''';
        EXCEPT    #DTL;
        OUTPUT='#$VEML2(''TIM@TST.COM]'') = '''+#$VEML2( 'TIM@TST.COM]' )+'''';
        EXCEPT    #DTL;

     C                   EXCEPT    #SPC

     C*
     C* #$FIXPRMLST - Fix paramete list
     C                   EVAL      OUTPUT='#$FIXPRMLST - FIX PARAMETER +
     C                                     LIST'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = PARAMETER LIST'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS FIXED LIST'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$FIXPRMLST(''FAB,tre'') = ' +
     C                                     #$FIXPRMLST( 'FAB,tre' )
     C                   EXCEPT    #DTL
               OUTPUT='#$FIXPRMLST(''FAB, tre ,TEST,"CHEESE"  RALPH'') = ' +
                       #$FIXPRMLST( 'FAB, tre ,TEST,"CHEESE"  RALPH' );
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$INTACT - See if the job is interactive
     C                   EVAL      OUTPUT='#$INTACT - SEE IF THIS JOB IS +
     C                                     INTEREACTIVE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='RETURNS I IF INTERACTIVE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$INTACT() = ' +
     C                                     #$INTACT()
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C* #$ACTJOB - CHECK IF AN ACTIVE JOB EXISTS
        OUTPUT='#$ACTJOB - CHECK IF AN ACTIVE JOB EXISTS';
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
        OUTPUT='This program assumes that an active job named ACOMMERGE is +
                running for user QSYSOPR in the sub system QSYS/SLEEPER.';
     C                   EXCEPT    #DTL
        OUTPUT='If this job is not running all these tests should return +
                false.';
     C                   EXCEPT    #DTL
        OUTPUT='The entry with the job number will also return false +
                because the number will be different than it was.';
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
       OUTPUT='PARAMETER 1 = JOBNAME - Name of Job';
     C                   EXCEPT    #DTL
       OUTPUT='PARAMETER 2 = JOBUSER - Optional, Omittable, default *ALL';
     C                   EXCEPT    #DTL
       OUTPUT='PARAMETER 3 = JOBNUMBER - Optional, Omittable, default *ALL';
     C                   EXCEPT    #DTL
       OUTPUT='PARAMETER 4 = SUBSYSTEMNAME - Optional, Omittable, default *ALL';
     C                   EXCEPT    #DTL
       OUTPUT='PARAMETER 5 = SUBSYSTEMLIB - Optional, Omittable, default *ALL';
     C                   EXCEPT    #DTL
       OUTPUT='RETURNS     = Boolean = *ON at least one active job exists';
     C                   EXCEPT    #DTL
       OUTPUT='                        *OFF no active jobs exist';
     C                   EXCEPT    #DTL
     C*
        OUTPUT='#$ACTJOB(''ACOMMERGE'') = ' +
                #$ACTJOB( 'ACOMMERGE' );
     C                   EXCEPT    #DTL
        OUTPUT='#$ACTJOB(''ACOMMERGE'':''QSYSOPR'') = ' +
                #$ACTJOB( 'ACOMMERGE' : 'QSYSOPR' );
     C                   EXCEPT    #DTL
        OUTPUT='#$ACTJOB(''ACOMMERGE'':''QSYSOPR'':''052561'') = ' +
                #$ACTJOB( 'ACOMMERGE' : 'QSYSOPR' : '052561' );
     C                   EXCEPT    #DTL
        OUTPUT='#$ACTJOB(''ACOMMERGE'':*OMIT:*OMIT:''SLEEPER'') = ' +
                #$ACTJOB( 'ACOMMERGE' :*OMIT:*OMIT: 'SLEEPER' );
     C                   EXCEPT    #DTL
        OUTPUT='#$ACTJOB(''ACOMMERGE'':*OMIT:*OMIT:''SLEEPER'':''QGPL'') = ' +
                #$ACTJOB( 'ACOMMERGE' :*OMIT:*OMIT: 'SLEEPER' : 'QGPL' );
     C                   EXCEPT    #DTL
        OUTPUT='#$ACTJOB(''ACOMMERGE'':''QSYSOPR'':*OMIT:''SLEEPER'': +
        ''QGPL'') = ' +
                #$ACTJOB( 'ACOMMERGE' : 'QSYSOPR' :*OMIT: 'SLEEPER' :
         'QGPL' );
     C                   EXCEPT    #DTL
     C*
     C* #$Partition - Returns the current partition.
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$PARTITION - RETURNS THE +
     C                                     CURRENT PARTITION'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='RETURNS = THE CURRENT PARTITION +
     C                                     AS A NUMBER'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$PARTITION() = ' +
     C                                     %CHAR(#$PARTITION())
     C                   EXCEPT    #DTL
     C*
     C* #$SysName - Returns the system's name
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SYSNAME - RETURNS THE +
     C                                     SYSTEM NAME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='RETURNS = THE SYSTEM NAME CHAR(8)'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SYSNAME() = ' +
     C                                     #$SYSNAME()
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #HDR
     C* #$WORDWRAP - Wraps a string of text by the length you specify back into a string
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$WORDWRAP - WRAPS A STRING OF +
     C                                     TEXT BY THE LENGTH YOU SPECIFY +
     C                                     BACK INTO A STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMTER 1 = STRINGIN, THE +
     C                                     STRING TO WRAP.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMTER 2 = TRIMLENGTH, THE +
     C                                     LINE LENGTH IN WHICH TO WRAP.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS    = THE INPUT STRING WITH +
     C                                     SPACING INSERTED SO WORDS DO NOT +
     C                                     BREAK ON THE TRIMLENGTH ENTERED.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
       OUTPUT='            ....+....1....+....2....+....3....+....4+
              ....+....5....+....6';
       EXCEPT #DTL;
       OUTPUT='#$WORDWRAP(''This line will be split into 3 lines of +
              20 characters.'':20)';
       EXCEPT #DTL;
       OUTPUT='         = ''' + %TRIM(#$WORDWRAP('This line will be split +
            into 3 lines of 20 characters.':20)) + '''';
       EXCEPT #DTL;
     C*
     C* #$WORDWRP2 - Wraps a string of text by the length you specify into an array
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$WORDWRP2 - WRAPS A STRING OF +
     C                                     TEXT BY THE LENGTH YOU SPECIFY +
     C                                     INTO AN ARRAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMTER 1 = STRINGIN, THE +
     C                                     STRING TO WRAP.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMTER 2 = TRIMLENGTH, THE +
     C                                     LINE LENGTH IN WHICH TO WRAP.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS    = THE INPUT STRING +
     C                                     BROKEN DOWN INTO LINES IN AN ARRAY.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
       OUTPUT='WRAPARRAY=#$WORDWRP2(''This line will be split into 3 lines of +
              20 characters.'':20)';
       EXCEPT #DTL;
       WRAPARRAY = #$WORDWRP2('This line will be split into 3 lines of +
        20 characters.':20);
       OUTPUT='WRAPARRAY(1) = ' + %trim(WRAPARRAY(1));
       EXCEPT #DTL;
       OUTPUT='WRAPARRAY(2) = ' + %trim(WRAPARRAY(2));
       EXCEPT #DTL;
       OUTPUT='WRAPARRAY(3) = ' + %trim(WRAPARRAY(3));
       EXCEPT #DTL;
     C*
     C* #$VPATH - Validates an IFS path
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$VPATH - VALIDATES AN +
     C                                     IFS PATH'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
       OUTPUT='PARAMETER 1 = PATH - THE PATH TO THE IFS OBJECT';
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = *ON IF THE PATH DOES +
     C                                     NOT EXISTS. *OFF IF IT DOES.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$VPATH(''/TOG'') = ' +
     C                                     #$VPATH( '/TOG' )
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$VPATH(''/TOG/FAKE'') = ' +
     C                                     #$VPATH( '/TOG/FAKE' )
     C                   EVAL      %SUBST(OUTPUT:80:40) =
     C                                    '#$VPATH(''/FAKE/'') = ' +
     C                                     #$VPATH( '/FAKE/' )
     C                   EXCEPT    #DTL
     C*
     C* #$USRHOME - Retrives a users home directory
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$USRHOME RETRIEVES A USERS +
     C                                     HOME DIRECTORY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
       OUTPUT='PARAMETER 1 = USER - OPTIONAL, DEFAULTS TO THE CURRENT USER.';
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = BLANK IF AN ERROR +
     C                                     OCCURES OR THE USERS HOME +
     C                                     DIRECTORY.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='THE USER RUNNING THE PROGRAM MUST +
     C                                     HAVE AUTHORITY TO THE REQUESTED +
     C                                     USER OR THE PATH WILL NOT BE +
     C                                     RETURNED.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$USRHOME() = ' +
     C                                     #$USRHOME()
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$USRHOME('''+%TRIM(USER)+''') = ' +
     C                                     #$USRHOME( USER )
     C                   EXCEPT    #DTL
     C                   IF        USER='GWEST'
     C                   EVAL      OUTPUT='#$USRHOME(''VLOWE'') = ' +
     C                                     #$USRHOME( 'VLOWE' )
     C                   ELSE
     C                   EVAL      OUTPUT='#$USRHOME(''GWEST'') = ' +
     C                                     #$USRHOME( 'GWEST' )
     C                   ENDIF
     C                   EXCEPT    #DTL
     C*
     C* #$SCANRPL - SAME AS %SCANRPL WITHOUT PDM ERRORS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SCANRPL - SAME AS %SCANRPL +
     C                                     WITHOUT PDM ERRORS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EXCEPT    #SPC
     C*
           OUTPUT='#$SCANRPL(''TIM'':''GARY'':''TIMS TEST'') = ' +
                   #$SCANRPL( 'TIM' : 'GARY' : 'TIMS TEST' );
     C                   EXCEPT    #DTL
     C*
     C* #$DBLQ - DOUBLES QUOTES IN A STRING
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DBLQ - DOUBLES QUOTES IN +
     C                                     A STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = ORIGINAL STRING.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = THE ORIGINAL STRING +
     C                                     WITH ANY QUOTES DOUBLED UP.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$DBLQ(''TIM''S TEST'') = ''' +
     C                                     #$DBLQ( 'TIM''S TEST' ) +''''
     C                   EXCEPT    #DTL
     C*
     C* #$C2H - CONVERT A CHARACTER STRING TO A HEX STRING
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$C2H - CONVERT A CHARACTER +
     C                                     TO A HEX STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = ORIGINAL STRING.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = THE ORIGINAL STRING +
     C                                     IN HEX, WILL BE TWICE AS LONG'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$C2H(''SOME TEXT'') = ''' +
     C                                     #$C2H( 'SOME TEXT' ) +''''
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$C2H(''SOME TEXT''+EOR) = ''' +
     C                                     #$C2H( 'SOME TEXT' +EOR) +''''
     C                   EXCEPT    #DTL
     C*
     C* #$H2C - CONVERT A HEX STRING TO A CHARACTER STRING
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$H2C - CONVERT A HEX STRING +
     C                                     TO A CHARACTER STRING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = HEX STRING.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = THE CHARACTER STRING, +
     C                                     WILL BE HALF AS LONG'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$H2C(''40F1400D2540'') = ''' +
     C                                     #$H2C( '40F1400D2540' ) +''''
     C                   EVAL      %SUBST(OUTPUT:60:60) =
     C                                    '#$H2C(''e2D6d4C540E3C5E7E3'') = ''' +
     C                                     #$H2C( 'e2D6d4C540E3C5E7E3' ) +''''
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='THIS ONE CONTAINS INVALID +
     C                                     HEX THE ZERO IN 0D IS A LETTER O'
     C                   EVAL      %SUBST(OUTPUT:60:60) =
     C                                    '#$H2C(''40F140oD2540'') = ''' +
     C                                     #$H2C( '40F140oD2540' ) +''''
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='AN ERROR IS LOGGED AND +
     C                                     NOTHING IS RETURNED'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #HDR
     C*
     C* #$CCHAR- CLEAN CHARACTER, REMOVES UN-PRINTABLE CHARS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$CCHAR- CLEAN CHARACTER, +
     C                                     REMOVES UN-PRINTABLE CHARS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = ORIGINAL STRING.'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = THE ORIGINAL STRING +
     C                                     WITH ANY UNPRINTABLE CHARACTERS +
     C                                     REMOVED'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='STRING=''TWO''+EOR+''LINES''' +
     C                                ' #$CCHAR(''TWO''+EOR+''LINES'') = ''' +
     C                                  #$CCHAR( 'TWO' +EOR+ 'LINES' ) +''''
     C                   EXCEPT    #DTL
     C*
        OUTPUT='IN THIS ONE EVERY OTHER CHARACTER IS INVALID: ' +
               '#$CCHAR(x''F100F226F302F423F534F612F701F826F931F0'') = ''' +
                #$CCHAR( x'F100F226F302F423F534F612F701F826F931F0' ) +'''';
        EXCEPT #DTL;

        EXCEPT #SPC;
        OUTPUT='THIS SECTION TESTS EVERY CHARACTER ONE LINE AT A TIME';
        EXCEPT #DTL;
        EXCEPT #OVL;
        OUTPUT='THE HEX PASSED';
        %SUBST(OUTPUT:55:15) ='PRINTED CHARS';
        %SUBST(OUTPUT:75:15) ='CLEANED CHARS';
        EXCEPT #DTL;
        OUTPUT               =      'x''000102030405060708090A0B0C0D0F''';
        %SUBST(OUTPUT:55:15) =        x'000102030405060708090A0B0C0D0F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'000102030405060708090A0B0C0D0F');
        EXCEPT #DTL;
        OUTPUT               =      'x''101112131415161718191A1B1C1D1F''';
        %SUBST(OUTPUT:55:15) =        x'101112131415161718191A1B1C1D1F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'101112131415161718191A1B1C1D1F');
        EXCEPT #DTL;
        OUTPUT               =      'x''202122232425262728292A2B2C2D2F''';
        %SUBST(OUTPUT:55:15) =        x'202122232425262728292A2B2C2D2F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'202122232425262728292A2B2C2D2F');
        EXCEPT #DTL;
        OUTPUT               =      'x''303132333435363738393A3B3C3D3F''';
        %SUBST(OUTPUT:55:15) =        x'303132333435363738393A3B3C3D3F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'303132333435363738393A3B3C3D3F');
        EXCEPT #DTL;
        OUTPUT               =      'x''404142434445464748494A4B4C4D4F''';
        %SUBST(OUTPUT:55:15) =        x'404142434445464748494A4B4C4D4F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'404142434445464748494A4B4C4D4F');
        EXCEPT #DTL;
        OUTPUT               =      'x''505152535455565758595A5B5C5D5F''';
        %SUBST(OUTPUT:55:15) =        x'505152535455565758595A5B5C5D5F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'505152535455565758595A5B5C5D5F');
        EXCEPT #DTL;
        OUTPUT               =      'x''606162636465666768696A6B6C6D6F''';
        %SUBST(OUTPUT:55:15) =        x'606162636465666768696A6B6C6D6F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'606162636465666768696A6B6C6D6F');
        EXCEPT #DTL;
        OUTPUT               =      'x''707172737475767778797A7B7C7D7F''';
        %SUBST(OUTPUT:55:15) =        x'707172737475767778797A7B7C7D7F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'707172737475767778797A7B7C7D7F');
        EXCEPT #DTL;
        OUTPUT               =      'x''808182838485868788898A8B8C8D8F''';
        %SUBST(OUTPUT:55:15) =        x'808182838485868788898A8B8C8D8F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'808182838485868788898A8B8C8D8F');
        EXCEPT #DTL;
        OUTPUT               =      'x''909192939495969798999A9B9C9D9F''';
        %SUBST(OUTPUT:55:15) =        x'909192939495969798999A9B9C9D9F';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'909192939495969798999A9B9C9D9F');
        EXCEPT #DTL;
        OUTPUT               =      'x''A0A1A2A3A4A5A6A7A8A9AAABACADAF''';
        %SUBST(OUTPUT:55:15) =        x'A0A1A2A3A4A5A6A7A8A9AAABACADAF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'A0A1A2A3A4A5A6A7A8A9AAABACADAF');
        EXCEPT #DTL;
        OUTPUT               =      'x''B0B1B2B3B4B5B6B7B8B9BABBBCBDBF''';
        %SUBST(OUTPUT:55:15) =        x'B0B1B2B3B4B5B6B7B8B9BABBBCBDBF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'B0B1B2B3B4B5B6B7B8B9BABBBCBDBF');
        EXCEPT #DTL;
        OUTPUT               =      'x''C0C1C2C3C4C5C6C7C8C9CACBCCCDCF''';
        %SUBST(OUTPUT:55:15) =        x'C0C1C2C3C4C5C6C7C8C9CACBCCCDCF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'C0C1C2C3C4C5C6C7C8C9CACBCCCDCF');
        EXCEPT #DTL;
        OUTPUT               =      'x''D0D1D2D3D4D5D6D7D8D9DADBDCDDDF''';
        %SUBST(OUTPUT:55:15) =        x'D0D1D2D3D4D5D6D7D8D9DADBDCDDDF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'D0D1D2D3D4D5D6D7D8D9DADBDCDDDF');
        EXCEPT #DTL;
        OUTPUT               =      'x''E0E1E2E3E4E5E6E7E8E9EAEBECEDEF''';
        %SUBST(OUTPUT:55:15) =        x'E0E1E2E3E4E5E6E7E8E9EAEBECEDEF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'E0E1E2E3E4E5E6E7E8E9EAEBECEDEF');
        EXCEPT #DTL;
        OUTPUT               =      'x''F0F1F2F3F4F5F6F7F8F9FAFBFCFDFF''';
        %SUBST(OUTPUT:55:15) =        x'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFF';
        %SUBST(OUTPUT:75:15) =#$CCHAR(x'F0F1F2F3F4F5F6F7F8F9FAFBFCFDFF');
        EXCEPT #DTL;

        EXCEPT #SPC;
        OUTPUT='IF COMMING FROM A PC FILE SOME CHARACTERS GET MANUALLY +
                CONVERTED.';
        EXCEPT #DTL;
        EXCEPT #OVL;
        OUTPUT              ='#$CCHAR(x''1542206A422038422039422004422014''+
                                      :''PC'')';
        %SUBST(OUTPUT:55:15)=          x'1542206A422038422039422004422014';
        %SUBST(OUTPUT:75:15)= #$CCHAR( x'1542206A422038422039422004422014'
                                      :'PC');
        EXCEPT #DTL;
     C*
     C* #$GETCNTRY - Get the country based on the state
     C*                  EXCEPT    #SPC
     C*                  EVAL      OUTPUT='#$GETCNTRY - GET THE COUNTRY +
     C*                                    BASED ON THE STATE'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #OVL
     C*                  EVAL      OUTPUT='PARAMETER 1 = STATE CHAR(2)'
     C*                  EXCEPT    #DTL
     C*                  EVAL      OUTPUT='RETURNS = THE COUNTRY CODE +
     C*                                    CHAR(2)'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #SPC
     C*
     C*                  EVAL      OUTPUT='#$GETCNTRY(''OK'') = ''' +
     C*                                    #$GETCNTRY( 'OK' ) +''''
     C*                  EVAL      %SUBST(OUTPUT:40:40) =
     C*                                   '#$GETCNTRY(''NF'') = ''' +
     C*                                    #$GETCNTRY( 'NF' ) +''''
     C*                  EVAL      %SUBST(OUTPUT:80:40) =
     C*                                   '#$GETCNTRY(''XX'') = ''' +
     C*                                    #$GETCNTRY( 'XX' ) +''''
     C*                  EXCEPT    #DTL
     C*
     C* #$ISUSER - VALIDATE A USER ID
     C*                  EXCEPT    #SPC
     C*                  EVAL      OUTPUT='#$ISUSER - VALIDATE A USER ID'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #OVL
     C*                  EVAL      OUTPUT='PARAMETER 1 = THE USER ID CHAR(10)'
     C*                  EXCEPT    #DTL
     C*                  EVAL      OUTPUT='RETURNS = *ON IF FOUND, OTHERWISE +
     C*                                    *OFF'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #SPC
     C*
     C*                  EVAL      OUTPUT='#$ISUSER(''TTOGNAZZIN'') = ''' +
     C*                                    #$ISUSER( 'TTOGNAZZIN' )+''''
     C*                  EVAL      %SUBST(OUTPUT:40:40) =
     C*                                   '#$ISUSER(''NOTAUSER'') = ''' +
     C*                                    #$ISUSER( 'NOTAUSER' )+''''
     C*                  EXCEPT    #DTL
     C*
     C* #$IN - Test if a value is in a list
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$IN - TEST IF A CHARACTER VALUE IS +
     C                                     IN A LIST'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = THE VALUE TO TEST'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2-21 = THE LIST OF VALUES'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = *ON IF IN THE LIST, +
     C                                     OTHERWISE *OFF'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
        OUTPUT='#$IN(''ONE'':''ONE'':''TWO'':''Three'') = ' +
                #$IN( 'ONE' : 'ONE' : 'TWO' : 'Three');
        %SUBST(OUTPUT:50:50) =
               '#$IN(''THREE'':''ONE'':''TWO'':''Three'') = ' +
                #$IN( 'THREE' : 'ONE' : 'TWO' : 'Three');
     C                   EXCEPT    #DTL
        OUTPUT='#$IN(''FOUR'':''ONE'':''TWO'':''Three'') = ' +
                #$IN( 'FOUR' : 'ONE' : 'TWO' : 'Three');
        %SUBST(OUTPUT:50:50) =
               '#$IN(''Three'':''ONE'':''TWO'':''Three'') = ' +
                #$IN( 'Three' : 'ONE' : 'TWO' : 'Three');
     C                   EXCEPT    #DTL
     C*
     C* #$INN - Test if a value is in a list
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$INN - TEST IF A NUMERIC VALUE IS +
     C                                     IN A LIST'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = THE VALUE TO TEST'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2-21 = THE LIST OF VALUES'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = *ON IF IN THE LIST, +
     C                                     OTHERWISE *OFF'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
        OUTPUT='#$INN(1:1:2:123.45) = ' + #$INN(1:1:2:123.45);
        %SUBST(OUTPUT:30:30) =
               '#$INN(3:1:2:123.45) = ' + #$INN(3:1:2:123.45);
        %SUBST(OUTPUT:60:30) =
               '#$INN(123:1:2:123.45) = ' + #$INN(123:1:2:123.45);
        %SUBST(OUTPUT:90:30) =
               '#$INN(123.45:1:2:123.45) = ' + #$INN(123.45:1:2:123.45);
     C                   EXCEPT    #DTL
     C*
     C* #$132OK - Tests if the display handle 132 characters
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$132OK - TESTS IF THE DISPLAY +
     C                                     HANDELS 132 CHARACTERS.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='NO PARAMETERS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS = *ON IF IN THE DISPLAY +
     C                                     HANDLES 132 CHARACTERS.'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL       OUTPUT='#$132OK() = ' + #$132OK()
     C                   EXCEPT    #DTL
     C*
     C* #$FMTPHN - Format Phone number based on country code
     C*                  EXCEPT    #HDR
     C*
     C*                  EXCEPT    #SPC
     C*                  EVAL      OUTPUT='#$FMTPHN - FORMAT PHONE NUMBER +
     C*                                    BASED ON COUNTRY CODE.'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #OVL
     C*                  EVAL      OUTPUT='PARAMETER 1 = PHONE NUMBER'
     C*                  EXCEPT    #DTL
     C*                  EVAL      OUTPUT='PARAMETER 2 = COUNTRY CODE OPTIONAL'
     C*                  EXCEPT    #DTL
     C*                  EVAL      OUTPUT='PARAMETER 3 = INCLUDE PREFIX +
     C*                                    OPTIONAL'
     C*                  EXCEPT    #DTL
     C*                  EVAL      OUTPUT='RETURNS = THE EDITED PHONE NUMBER'
     C*                  EXCEPT    #DTL
     C*                  EXCEPT    #SPC
     C*
      * OUTPUT='#$FMTPHN(''9181235555'') = ' + #$FMTPHN('9181235555');
      * %SUBST(OUTPUT:60:60) =
      * '#$FMTPHN(''9181235555'':''US'') = ' + #$FMTPHN('9181235555':'US');
     C*                  EXCEPT    #DTL
      * OUTPUT='#$FMTPHN(''123412341234'':''MX'') = ' +
      *         #$FMTPHN( '123412341234' : 'MX');
      * %SUBST(OUTPUT:60:60) =
      *        '#$FMTPHN(''123412341234'':''MX'':''Y'') = ' +
      *         #$FMTPHN( '123412341234' : 'MX' : 'Y');
     C*                  EXCEPT    #DTL
      * OUTPUT='#$FMTPHN(''8005551234'':''US'':''Y'') = ' +
      *         #$FMTPHN( '8005551234' : 'US' : 'Y' );
      * %SUBST(OUTPUT:60:60) =
      *        '#$FMTPHN(''1234567890'':''FR'':''Y'') = ' +
      *         #$FMTPHN( '1234567890' : 'FR' : 'Y');
     C*                  EXCEPT    #DTL
     C*
     C* #$ADDDAY - add days to a date
     C* The inputs are a date and the days to add to it, it returns the
     C* the new date
     C                   EVAL      TITLE=#$CNTR('DATE FUNCTIONS':50)
     C                   EXCEPT    #HDR
     C*
     C                   EVAL      OUTPUT='#$ADDDAY - ADD DAYS TO A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF DAYS +
     C                                     TO ADD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ADDDAY(20180810:5)  = ' +
     C                               %CHAR(#$ADDDAY(20180810:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDDAY(081018:5)    = ' +
     C                               %CHAR(#$ADDDAY(081018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ADDDAY(20180725:10) = ' +
     C                               %CHAR(#$ADDDAY(20180725:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDDAY(072518:10)   = ' +
     C                               %CHAR(#$ADDDAY(072518:10))
     C                   EXCEPT    #DTL
     C*
     C* #$SUBDAY - Subtracts Days from a date
     C* The inputs are a date and the days to subtract from it, it returns the
     C* the new date
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SUBDAY - SUBTRACT DAYS FROM A +
     C                                     DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF DAYS +
     C                                     TO SUBTRACT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SUBDAY(20180810:5)  = ' +
     C                                     %CHAR(#$SUBDAY(20180810:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBDAY(081018:5)    = ' +
     C                                     %CHAR(#$SUBDAY(081018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBDAY(20180804:10) = ' +
     C                                     %CHAR(#$SUBDAY(20180804:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBDAY(080418:10)   = ' +
     C                                     %CHAR(#$SUBDAY(080418:10))
     C                   EXCEPT    #DTL
     C*
     C* #$DDIFF - Difference between two dates in days
     C* The inputs are a date1 and date2, it retruns the days from date1 to date2
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DDIFF - DIFFERENCE BETWEEN TWO +
     C                                     DATES IN DAYS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE1 IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = DATE2 IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NUMBER OF DAYS +
     C                                     FROM DATE1 TO DATE2'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$DDIFF(20180810:20180815)  = ' +
     C                                     %CHAR(#$DDIFF(20180810:20180815))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$DDIFF(081018:081518)  = ' +
     C                                     %CHAR(#$DDIFF(081018:081518))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$DDIFF(20180801:20190315)  = ' +
     C                                     %CHAR(#$DDIFF(20180801:20190315))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$DDIFF(080119:031519)  = ' +
     C                                     %CHAR(#$DDIFF(080118:031519))
     C                   EXCEPT    #DTL
     C*
     C* #$DAYOW - Returns the numeric value of the day of the week
     C*    0 = Monday   1 = Tuesday    2 = Wednesday  3 = Thursday
     C*    4 = Friday   5 = Saturday   6 = Sunday
     C* The only input is a date
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DAYOW - RETURN DAY OF WEEK AS A +
     C                                     NUMBER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DAY OF WEEK, +
     C                                                   0=Monday 1=Tuesday +
     C                                     2=Wednesday 3=Thursday 4=Friday +
     C                                     5=Saturday 6=Sunday'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$DAYOW(20180910) = ' +
     C                                     %CHAR(#$DAYOW(20180910))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$DAYOW(091018)   = ' +
     C                                     %CHAR(#$DAYOW(091018))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$DAYOW(20180928) = ' +
     C                                     %CHAR(#$DAYOW(20180928))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$DAYOW(092818)   = ' +
     C                                     %CHAR(#$DAYOW(092818))
     C                   EXCEPT    #DTL
     C*
     C* #$DOW - Returns the name of the day of the week
     C* Input can be a day number 0=Mon ro a date in MMDDYY or YYYYMMDD
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DOW - RETURN DAY OF WEEK AS A NAME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL - 3 FOR A +
     C                                     3 CHARACTER ABBREVIATION'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL - 1 FOR +
     C                                     MIXED CASE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DAY OF WEEK'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$DOW(091918)   = ' +
     C                                     #$DOW(091918)
     C                   EVAL      %SUBST(OUTPUT:32:32) =
     C                                    '#$DOW(091918:3)   = ' +
     C                                     #$DOW(091918:3)
     C                   EVAL      %SUBST(OUTPUT:64:34) =
     C                                    '#$DOW(091918:3:1)   = ' +
     C                                     #$DOW(091918:3:1)
     C                   EVAL      %SUBST(OUTPUT:96:36) =
     C                                    '#$DOW(091918:0:1)   = ' +
     C                                     #$DOW(091918:0:1)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$DOW(20180928) = ' +
     C                                     #$DOW(20180928)
     C                   EVAL      %SUBST(OUTPUT:32:32) =
     C                                    '#$DOW(20180928:3) = ' +
     C                                     #$DOW(20180928:3)
     C                   EVAL      %SUBST(OUTPUT:64:34) =
     C                                    '#$DOW(20180928:3:1) = ' +
     C                                     #$DOW(20180928:3:1)
     C                   EVAL      %SUBST(OUTPUT:96:36) =
     C                                    '#$DOW(20180928:0:1) = ' +
     C                                     #$DOW(20180928:0:1)
     C                   EXCEPT    #DTL
     C*
     C* #$MNTH - GETS A MONTHS NAME
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$MNTH - GET THE NAME OF THE MONTH'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A MONTH NUMBER OR A +
     C                                     DATE IN MMDDYY OR YYYYMMDD FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL - 3 FOR A +
     C                                     3 CHARACTER ABBREVIATION'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL - 1 FOR +
     C                                     MIXED CASE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE MONTH NAME'
     C                   EXCEPT    #DTL
     C
     C                   EVAL      OUTPUT='#$MNTH(1)        = ' +
     C                                     #$MNTH(1)
     C                   EVAL      %SUBST(OUTPUT:40:40)=
     C                                    '#$MNTH(1:3)      = ' +
     C                                     #$MNTH(1:3)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$MNTH(010518)   = ' +
     C                                     #$MNTH(010518)
     C                   EVAL      %SUBST(OUTPUT:40:40)=
     C                                    '#$MNTH(1:3:1)    = ' +
     C                                     #$MNTH(1:3:1)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$MNTH(20180105) = ' +
     C                                     #$MNTH(20180105)
     C                   EVAL      %SUBST(OUTPUT:40:40)=
     C                                    '#$MNTH(1:0:1)    = ' +
     C                                     #$MNTH(1:0:1)
     C                   EXCEPT    #DTL
     C*
     C* #$DAT - Returns the date in a text format
     C* Input can be a date in MMDDYY or YYYYMMDD
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$DAT - RETURN ALPHA DATE NAME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL - IF A 2 +
     C                                     IS PASSED THE DATE WILL NOT +
     C                                     INCLUDE THE DAY NAME'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 3 = OPTIONAL - 1 FOR +
     C                                     MIXED CASE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DAY OF WEEK'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$DAT(20180910)     = ' +
     C                                     #$DAT(20180910)
     C                   EVAL      %SUBST(OUTPUT:60:50) =
     C                                    '#$DAT(092818:1:1) = ' +
     C                                     #$DAT(092818:1:1)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$DAT(20180928:2)   = ' +
     C                                     #$DAT(20180928:2)
     C                   EVAL      %SUBST(OUTPUT:60:50) =
     C                                    '#$DAT(092818:2:1) = ' +
     C                                     #$DAT(092818:2:1)
     C                   EXCEPT    #DTL
     C*
     C* #$WOY - GET WEEK OF YEAR
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$WOY - GET WEEK OF YEAR'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE WEEK OF THE +
     C                                     YEAR AS A NUMERIC VALUE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='USES ISO 8601 STANDARD, THE +
     C                                     YEAR STARTS ON THE MONDAY OF +
     C                                     THE WEEK CONTAINING JANUARY 4TH'
     C                   EXCEPT    #DTL
     C
     C                   EVAL      OUTPUT='#$WOY(20180104) = ' +
     C                                     %CHAR(#$WOY(20180104))
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$WOY(010418)   = ' +
     C                                     %CHAR(#$WOY(010418))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$WOY(20180215) = ' +
     C                                     %CHAR(#$WOY(20180215))
     C                   EVAL      %SUBST(OUTPUT:40:40) =
     C                                    '#$WOY(021518)   = ' +
     C                                     %CHAR(#$WOY(021518))
     C                   EXCEPT    #DTL
     C*
     C* #$NXTDOW - Returns the next date for a specified day of the week.
     C* Pass a Date and the day you want. If the passed date is the day
     C* of the week requested it will return the same date as passed.
     C*    0 = Monday   1 = Tuesday    2 = Wednesday  3 = Thursday
     C*    4 = Friday   5 = Saturday   6 = Sunday
     C                   EXCEPT    #HDR
     C*
     C* GETS THE NEXT FRIDAY DATE
     C                   EVAL      OUTPUT='#$NXTDOW - GET DATE OF THE NEXT +
     C                                     SPECIFIC DAY OF THE WEEK'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = THE DAY NUMBER'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='              0=Monday 1=Tuesday +
     C                                     2=Wednesday 3=Thursday 4=Friday +
     C                                     5=Saturday 6=Sunday'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='GET NEXT FRIDAYS DATE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$NXTDOW(20180918:4) = ' +
     C                               %CHAR(#$NXTDOW(20180918:4))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$NXTDOW(091818:4)   = ' +
     C                               %CHAR(#$NXTDOW(091818:4))
     C                   EXCEPT    #DTL
     C*
     C* IF YOU WANT THE PREVIOUS FRIDAY DATE, JUST SUBTRACT 7 DAYS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='TO GET THE PREVIOUS FRIDAYS DATE +
     C                                     USE WITH #$SUBDAY TO GO BACK ONE +
     C                                     WEEK'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBDAY(#$NXTDOW(20180918:4):7) = '+
     C                              %CHAR(#$SUBDAY(#$NXTDOW(20180918:4):7))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBDAY(#$NXTDOW(091818:4):7)   = '+
     C                              %CHAR(#$SUBDAY(#$NXTDOW(091818:4):7))
     C                   EXCEPT    #DTL
     C*
     C* #$YMD8    = Converts MMDDYY to YYYYMMDD date
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$YMD8 - CONVERT A MMDDYY DATE +
     C                                     TO A YYYYMMDD DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN MMDDYY +
     C                                     FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DATE IN YYYYMMDD +
     C                                     FORMAT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$YMD8(091518) = ' +
     C                               %CHAR(#$YMD8(091518))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$YMD8(094218) = ' +
     C                               %CHAR(#$YMD8(094218))
     C                   EXCEPT    #DTL
     C*
     C* #$MDY6    = Converts YYYYMMDD to MMDDYY date
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$MDY6 - CONVERTS YYYYMMDD TO +
     C                                      TO A MMDDYY DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DATE IN MMDDYY +
     C                                     FORMAT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$MDY6(20180915) = ' +
     C                               %CHAR(#$MDY6(20180915))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$MDY6(20180942) = ' +
     C                               %CHAR(#$MDY6(20180942))
     C                   EXCEPT    #DTL
     C*
     C* #$ADDWD   = Adds a number of work days to a date
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ADDWD - ADDS A NUMBER OF WORK +
     C                                      DAYS TO A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF WORK DAYS +
     C                                     TO ADD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DATE IN SAME +
     C                                     FORMAT WITH THE NUMBER OF DAYS ADDED'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$ADDWD(20180912:10) = ' +
     C                               %CHAR(#$ADDWD(20180912:10))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ADDWD(20180831:1)  = ' +
     C                               %CHAR(#$ADDWD(20180831:1))
     C                   EXCEPT    #DTL
     C*
     C* #$SUBWD   = Subtracts a number of work days from a date
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$SUBWD - SUBTRACTS A NUMBER OF +
     C                                      WORK DAYS FROM A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF WORK DAYS +
     C                                     TO SUBTRACT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DATE IN SAME +
     C                                     FORMAT WITH THE NUMBER OF +
     C                                     WORK DAYS REMOVED'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SUBWD(20180926:10) = ' +
     C                               %CHAR(#$SUBWD(20180926:10))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBWD(20180904:1)  = ' +
     C                               %CHAR(#$SUBWD(20180904:1))
     C                   EXCEPT    #DTL
     C*
     C* #$WDDIFF  = Difference between dates in work days
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$WDDIFF - RETURNS THE DIFFERENCE +
     C                                      BETWEEN DATES IN WORK DAYS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE DATE NUMBER +
     C                                     OF WORK DAYS BETWEEN THE +
     C                                     TWO DATES'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$WDDIFF(20180926:20180912) = ' +
     C                               %CHAR(#$WDDIFF(20180926:20180912))
     C                   EVAL      %SUBST(OUTPUT:50:50)=
     C                                    '#$WDDIFF(091218:092618) = ' +
     C                               %CHAR(#$WDDIFF(091218:092618))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$WDDIFF(20180831:20180904) = ' +
     C                               %CHAR(#$WDDIFF(20180831:20180904))
     C                   EXCEPT    #DTL
     C*
     C* #$VDAT - VALIDATE A DATE
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$VDAT - VALIDATE A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, A 2 FOR +
     C                                     LEVEL 2 VALIDATION'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A BOOLEAN TRUE OR +
     C                                     FALSE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$VDAT(20180101) = ' +
     C                                     #$VDAT(20180101)
     C                   EVAL      %SUBST(OUTPUT:30:30)=
     C                                    '#$VDAT(20181301) = ' +
     C                                     #$VDAT(20181301)
     C                   EVAL      %SUBST(OUTPUT:60:30)=
     C                                    '#$VDAT(010118)   = ' +
     C                                     #$VDAT(010118)
     C                   EVAL      %SUBST(OUTPUT:90:30)=
     C                                    '#$VDAT(130118)   = ' +
     C                                     #$VDAT(130118)
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='OPTIONAL LEVEL 2 VALIDATION - +
     C                                     MAKES SURE A DATE IS NO MORE THAN +
     C                                     360 DAYS IN THE PAST OR 90 DAYS +
     C                                     IN THE FUTURE'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='THIS CAN BE USED TO PREVENT ENTRY +
     C                                     OF THE WRONG YEAR AND TO PREVENT +
     C                                     MISS-KEYED DATES'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$VDAT(20180101:2) = ' +
     C                                     #$VDAT(20180101:2)
     C                   EVAL      %SUBST(OUTPUT:30:30)=
     C                                    '#$VDAT(20150101:2) = ' +
     C                                     #$VDAT(20150101:2)
     C                   EVAL      %SUBST(OUTPUT:60:30)=
     C                                    '#$VDAT(010118:2)   = ' +
     C                                     #$VDAT(010118:2)
     C                   EVAL      %SUBST(OUTPUT:90:30)=
     C                                    '#$VDAT(010115:2)   = ' +
     C                                     #$VDAT(010115:2)
     C                   EXCEPT    #DTL
     C*
     C* #$ISWKD - Determines if a date is a work day
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$ISWKD - DETERMINES IF A DATE IS +
     C                                     A WORK DAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, PASS A +
     C                                     1 TO INCLUIDE SATURDAYS AS WORK DAYS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = BOOLEAN TRUE OR FALSE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ISWKD(20180919)  = ' +
     C                                     #$ISWKD(20180919) +
     C                                     '  JUST A WEDNESDAY'
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$ISWKD(091518)  = ' +
     C                                     #$ISWKD(091518) +
     C                                     '  JUST A SATURDAY'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ISWKD(20181225)  = ' +
     C                                     #$ISWKD(20181225) +
     C                                     '  CHRISTMAS'
     C                   EVAL      %SUBST(OUTPUT:60:60)=
     C                                    '#$ISWKD(010118)  = ' +
     C                                     #$ISWKD(010118) +
     C                                     '  NEW YEARS'
     C                   EXCEPT    #DTL
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='NEW YEARS ON A SATURDAY'
     C                   EVAL      %SUBST(OUTPUT:78:50)=
     C                                    'NEW YEARS ON A WEEKDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/30/10'
     C                   EVAL      COL02 = '12/31/10'
     C                   EVAL      COL03 = '01/01/11'
     C                   EVAL      COL04 = '01/02/11'
     C                   EVAL      COL05 = '01/03/11'
     C                   EVAL      COL08 = '12/30/18'
     C                   EVAL      COL09 = '12/31/18'
     C                   EVAL      COL10 = '01/01/19'
     C                   EVAL      COL11 = '01/02/19'
     C                   EVAL      COL12 = '01/03/19'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20101230)
     C                   EVAL      COL02 = #$DOW(20101231)
     C                   EVAL      COL03 = #$DOW(20110101)
     C                   EVAL      COL04 = #$DOW(20110102)
     C                   EVAL      COL05 = #$DOW(20110103)
     C                   EVAL      COL08 = #$DOW(20181230)
     C                   EVAL      COL09 = #$DOW(20181231)
     C                   EVAL      COL10 = #$DOW(20190101)
     C                   EVAL      COL11 = #$DOW(20190102)
     C                   EVAL      COL12 = #$DOW(20190103)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20101230)
     C                   EVAL      COL02 = #$ISWKD(20101231)
     C                   EVAL      COL03 = #$ISWKD(20110101)
     C                   EVAL      COL04 = #$ISWKD(20110102)
     C                   EVAL      COL05 = #$ISWKD(20110103)
     C                   EVAL      COL08 = #$ISWKD(20181230)
     C                   EVAL      COL09 = #$ISWKD(20181231)
     C                   EVAL      COL10 = #$ISWKD(20190101)
     C                   EVAL      COL11 = #$ISWKD(20190102)
     C                   EVAL      COL12 = #$ISWKD(20190103)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='NEW YEARS ON A SUNDAY'
     C                   EVAL      %SUBST(OUTPUT:78:50)=
     C                                    'NEW YEARS ON A WEEKDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/30/16'
     C                   EVAL      COL02 = '12/31/16'
     C                   EVAL      COL03 = '01/01/17'
     C                   EVAL      COL04 = '01/02/17'
     C                   EVAL      COL05 = '01/03/17'
     C                   EVAL      COL08 = '12/30/17'
     C                   EVAL      COL09 = '12/31/17'
     C                   EVAL      COL10 = '01/01/18'
     C                   EVAL      COL11 = '01/02/18'
     C                   EVAL      COL12 = '01/03/18'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20161230)
     C                   EVAL      COL02 = #$DOW(20161231)
     C                   EVAL      COL03 = #$DOW(20170101)
     C                   EVAL      COL04 = #$DOW(20170102)
     C                   EVAL      COL05 = #$DOW(20170103)
     C                   EVAL      COL08 = #$DOW(20171230)
     C                   EVAL      COL09 = #$DOW(20171231)
     C                   EVAL      COL10 = #$DOW(20180101)
     C                   EVAL      COL11 = #$DOW(20180102)
     C                   EVAL      COL12 = #$DOW(20180103)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20101230)
     C                   EVAL      COL02 = #$ISWKD(20101231)
     C                   EVAL      COL03 = #$ISWKD(20110101)
     C                   EVAL      COL04 = #$ISWKD(20110102)
     C                   EVAL      COL05 = #$ISWKD(20110103)
     C                   EVAL      COL08 = #$ISWKD(20171230)
     C                   EVAL      COL09 = #$ISWKD(20171231)
     C                   EVAL      COL10 = #$ISWKD(20180101)
     C                   EVAL      COL11 = #$ISWKD(20180102)
     C                   EVAL      COL12 = #$ISWKD(20180103)
     C                   EXCEPT    #ISWKD
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='TEST MEMORIAL DAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '05/24/18'
     C                   EVAL      COL02 = '05/25/18'
     C                   EVAL      COL03 = '05/26/18'
     C                   EVAL      COL04 = '05/27/18'
     C                   EVAL      COL05 = '05/28/18'
     C                   EVAL      COL06 = '05/29/18'
     C                   EVAL      COL07 = '05/30/18'
     C                   EVAL      COL08 = '05/31/18'
     C                   EVAL      COL09 = '06/01/18'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20180524)
     C                   EVAL      COL02 = #$DOW(20180525)
     C                   EVAL      COL03 = #$DOW(20180526)
     C                   EVAL      COL04 = #$DOW(20180527)
     C                   EVAL      COL05 = #$DOW(20180528)
     C                   EVAL      COL06 = #$DOW(20180529)
     C                   EVAL      COL07 = #$DOW(20180530)
     C                   EVAL      COL08 = #$DOW(20180531)
     C                   EVAL      COL09 = #$DOW(20180601)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20180524)
     C                   EVAL      COL02 = #$ISWKD(20180525)
     C                   EVAL      COL03 = #$ISWKD(20180526)
     C                   EVAL      COL04 = #$ISWKD(20180527)
     C                   EVAL      COL05 = #$ISWKD(20180528)
     C                   EVAL      COL06 = #$ISWKD(20180529)
     C                   EVAL      COL07 = #$ISWKD(20180530)
     C                   EVAL      COL08 = #$ISWKD(20180531)
     C                   EVAL      COL09 = #$ISWKD(20180601)
     C                   EXCEPT    #ISWKD
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='4TH OF JULY ON A SATURDAY'
     C                   EVAL      %SUBST(OUTPUT:78:50)=
     C                                    '4TH OF JULY ON A WEEKDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '07/02/15'
     C                   EVAL      COL02 = '07/03/15'
     C                   EVAL      COL03 = '07/04/15'
     C                   EVAL      COL04 = '07/05/15'
     C                   EVAL      COL05 = '07/06/15'
     C                   EVAL      COL08 = '07/02/14'
     C                   EVAL      COL09 = '07/03/14'
     C                   EVAL      COL10 = '07/04/14'
     C                   EVAL      COL11 = '07/05/14'
     C                   EVAL      COL12 = '07/06/14'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20150702)
     C                   EVAL      COL02 = #$DOW(20150703)
     C                   EVAL      COL03 = #$DOW(20150704)
     C                   EVAL      COL04 = #$DOW(20150705)
     C                   EVAL      COL05 = #$DOW(20150706)
     C                   EVAL      COL08 = #$DOW(20140702)
     C                   EVAL      COL09 = #$DOW(20140703)
     C                   EVAL      COL10 = #$DOW(20140704)
     C                   EVAL      COL11 = #$DOW(20140705)
     C                   EVAL      COL12 = #$DOW(20140706)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20150702)
     C                   EVAL      COL02 = #$ISWKD(20150703)
     C                   EVAL      COL03 = #$ISWKD(20150704)
     C                   EVAL      COL04 = #$ISWKD(20150705)
     C                   EVAL      COL05 = #$ISWKD(20150706)
     C                   EVAL      COL08 = #$ISWKD(20140702)
     C                   EVAL      COL09 = #$ISWKD(20140703)
     C                   EVAL      COL10 = #$ISWKD(20140704)
     C                   EVAL      COL11 = #$ISWKD(20140705)
     C                   EVAL      COL12 = #$ISWKD(20140706)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='4TH OF JULY ON A SUNDAY'
     C                   EVAL      %SUBST(OUTPUT:78:50)=
     C                                    '4TH OF JULY ON A WEEKDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '07/02/10'
     C                   EVAL      COL02 = '07/03/10'
     C                   EVAL      COL03 = '07/04/10'
     C                   EVAL      COL04 = '07/05/10'
     C                   EVAL      COL05 = '07/06/10'
     C                   EVAL      COL08 = '07/02/16'
     C                   EVAL      COL09 = '07/03/16'
     C                   EVAL      COL10 = '07/04/16'
     C                   EVAL      COL11 = '07/05/16'
     C                   EVAL      COL12 = '07/06/16'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20100702)
     C                   EVAL      COL02 = #$DOW(20100703)
     C                   EVAL      COL03 = #$DOW(20100704)
     C                   EVAL      COL04 = #$DOW(20100705)
     C                   EVAL      COL05 = #$DOW(20100706)
     C                   EVAL      COL08 = #$DOW(20160702)
     C                   EVAL      COL09 = #$DOW(20160703)
     C                   EVAL      COL10 = #$DOW(20160704)
     C                   EVAL      COL11 = #$DOW(20160705)
     C                   EVAL      COL12 = #$DOW(20160706)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20100702)
     C                   EVAL      COL02 = #$ISWKD(20100703)
     C                   EVAL      COL03 = #$ISWKD(20100704)
     C                   EVAL      COL04 = #$ISWKD(20100705)
     C                   EVAL      COL05 = #$ISWKD(20100706)
     C                   EVAL      COL08 = #$ISWKD(20160702)
     C                   EVAL      COL09 = #$ISWKD(20160703)
     C                   EVAL      COL10 = #$ISWKD(20160704)
     C                   EVAL      COL11 = #$ISWKD(20160705)
     C                   EVAL      COL12 = #$ISWKD(20160706)
     C                   EXCEPT    #ISWKD
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='TEST LABOR DAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '08/31/18'
     C                   EVAL      COL02 = '09/01/18'
     C                   EVAL      COL03 = '09/02/18'
     C                   EVAL      COL04 = '09/03/18'
     C                   EVAL      COL05 = '09/04/18'
     C                   EVAL      COL06 = '09/05/18'
     C                   EVAL      COL07 = '09/06/18'
     C                   EVAL      COL08 = '09/07/18'
     C                   EVAL      COL09 = '09/08/18'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20180831)
     C                   EVAL      COL02 = #$DOW(20180901)
     C                   EVAL      COL03 = #$DOW(20180902)
     C                   EVAL      COL04 = #$DOW(20180903)
     C                   EVAL      COL05 = #$DOW(20180904)
     C                   EVAL      COL06 = #$DOW(20180905)
     C                   EVAL      COL07 = #$DOW(20180906)
     C                   EVAL      COL08 = #$DOW(20180907)
     C                   EVAL      COL09 = #$DOW(20180908)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20180831)
     C                   EVAL      COL02 = #$ISWKD(20180901)
     C                   EVAL      COL03 = #$ISWKD(20180902)
     C                   EVAL      COL04 = #$ISWKD(20180903)
     C                   EVAL      COL05 = #$ISWKD(20180904)
     C                   EVAL      COL06 = #$ISWKD(20180905)
     C                   EVAL      COL07 = #$ISWKD(20180906)
     C                   EVAL      COL08 = #$ISWKD(20180907)
     C                   EVAL      COL09 = #$ISWKD(20180908)
     C                   EXCEPT    #ISWKD
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='THANKS GIVING'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '11/21/18'
     C                   EVAL      COL02 = '11/22/18'
     C                   EVAL      COL03 = '11/23/18'
     C                   EVAL      COL04 = '11/24/18'
     C                   EVAL      COL05 = '11/25/18'
     C                   EVAL      COL06 = '11/26/18'
     C                   EVAL      COL07 = '11/27/18'
     C                   EVAL      COL08 = '11/28/18'
     C                   EVAL      COL09 = '11/29/18'
     C                   EVAL      COL10 = '11/30/18'
     C                   EVAL      COL11 = '11/31/18'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20181121)
     C                   EVAL      COL02 = #$DOW(20181122)
     C                   EVAL      COL03 = #$DOW(20181123)
     C                   EVAL      COL04 = #$DOW(20181124)
     C                   EVAL      COL05 = #$DOW(20181125)
     C                   EVAL      COL06 = #$DOW(20181126)
     C                   EVAL      COL07 = #$DOW(20181127)
     C                   EVAL      COL08 = #$DOW(20181128)
     C                   EVAL      COL09 = #$DOW(20181129)
     C                   EVAL      COL10 = #$DOW(20181130)
     C                   EVAL      COL11 = #$DOW(20181131)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20181121)
     C                   EVAL      COL02 = #$ISWKD(20181122)
     C                   EVAL      COL03 = #$ISWKD(20181123)
     C                   EVAL      COL04 = #$ISWKD(20181124)
     C                   EVAL      COL05 = #$ISWKD(20181125)
     C                   EVAL      COL06 = #$ISWKD(20181126)
     C                   EVAL      COL07 = #$ISWKD(20181127)
     C                   EVAL      COL08 = #$ISWKD(20181128)
     C                   EVAL      COL09 = #$ISWKD(20181129)
     C                   EVAL      COL10 = #$ISWKD(20181130)
     C                   EVAL      COL11 = #$ISWKD(20181131)
     C                   EXCEPT    #ISWKD
     C*
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='WINTER HOLIDAY, WEEKDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/21/18'
     C                   EVAL      COL02 = '12/22/18'
     C                   EVAL      COL03 = '12/23/18'
     C                   EVAL      COL04 = '12/24/18'
     C                   EVAL      COL05 = '12/25/18'
     C                   EVAL      COL06 = '12/26/18'
     C                   EVAL      COL07 = '12/27/18'
     C                   EVAL      COL08 = '12/28/18'
     C                   EVAL      COL09 = '12/29/18'
     C                   EVAL      COL10 = '12/30/18'
     C                   EVAL      COL11 = '12/31/18'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20181221)
     C                   EVAL      COL02 = #$DOW(20181222)
     C                   EVAL      COL03 = #$DOW(20181223)
     C                   EVAL      COL04 = #$DOW(20181224)
     C                   EVAL      COL05 = #$DOW(20181225)
     C                   EVAL      COL06 = #$DOW(20181226)
     C                   EVAL      COL07 = #$DOW(20181227)
     C                   EVAL      COL08 = #$DOW(20181228)
     C                   EVAL      COL09 = #$DOW(20181229)
     C                   EVAL      COL10 = #$DOW(20181230)
     C                   EVAL      COL11 = #$DOW(20181231)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20181221)
     C                   EVAL      COL02 = #$ISWKD(20181222)
     C                   EVAL      COL03 = #$ISWKD(20181223)
     C                   EVAL      COL04 = #$ISWKD(20181224)
     C                   EVAL      COL05 = #$ISWKD(20181225)
     C                   EVAL      COL06 = #$ISWKD(20181226)
     C                   EVAL      COL07 = #$ISWKD(20181227)
     C                   EVAL      COL08 = #$ISWKD(20181228)
     C                   EVAL      COL09 = #$ISWKD(20181229)
     C                   EVAL      COL10 = #$ISWKD(20181230)
     C                   EVAL      COL11 = #$ISWKD(20181231)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='WINTER HOLIDAY, THURSDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/21/14'
     C                   EVAL      COL02 = '12/22/14'
     C                   EVAL      COL03 = '12/23/14'
     C                   EVAL      COL04 = '12/24/14'
     C                   EVAL      COL05 = '12/25/14'
     C                   EVAL      COL06 = '12/26/14'
     C                   EVAL      COL07 = '12/27/14'
     C                   EVAL      COL08 = '12/28/14'
     C                   EVAL      COL09 = '12/29/14'
     C                   EVAL      COL10 = '12/30/14'
     C                   EVAL      COL11 = '12/31/14'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20141221)
     C                   EVAL      COL02 = #$DOW(20141222)
     C                   EVAL      COL03 = #$DOW(20141223)
     C                   EVAL      COL04 = #$DOW(20141224)
     C                   EVAL      COL05 = #$DOW(20141225)
     C                   EVAL      COL06 = #$DOW(20141226)
     C                   EVAL      COL07 = #$DOW(20141227)
     C                   EVAL      COL08 = #$DOW(20141228)
     C                   EVAL      COL09 = #$DOW(20141229)
     C                   EVAL      COL10 = #$DOW(20141230)
     C                   EVAL      COL11 = #$DOW(20141231)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20141221)
     C                   EVAL      COL02 = #$ISWKD(20141222)
     C                   EVAL      COL03 = #$ISWKD(20141223)
     C                   EVAL      COL04 = #$ISWKD(20141224)
     C                   EVAL      COL05 = #$ISWKD(20141225)
     C                   EVAL      COL06 = #$ISWKD(20141226)
     C                   EVAL      COL07 = #$ISWKD(20141227)
     C                   EVAL      COL08 = #$ISWKD(20141228)
     C                   EVAL      COL09 = #$ISWKD(20141229)
     C                   EVAL      COL10 = #$ISWKD(20141230)
     C                   EVAL      COL11 = #$ISWKD(20141231)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='WINTER HOLIDAY, FRIDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/21/15'
     C                   EVAL      COL02 = '12/22/15'
     C                   EVAL      COL03 = '12/23/15'
     C                   EVAL      COL04 = '12/24/15'
     C                   EVAL      COL05 = '12/25/15'
     C                   EVAL      COL06 = '12/26/15'
     C                   EVAL      COL07 = '12/27/15'
     C                   EVAL      COL08 = '12/28/15'
     C                   EVAL      COL09 = '12/29/15'
     C                   EVAL      COL10 = '12/30/15'
     C                   EVAL      COL11 = '12/31/15'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20151221)
     C                   EVAL      COL02 = #$DOW(20151222)
     C                   EVAL      COL03 = #$DOW(20151223)
     C                   EVAL      COL04 = #$DOW(20151224)
     C                   EVAL      COL05 = #$DOW(20151225)
     C                   EVAL      COL06 = #$DOW(20151226)
     C                   EVAL      COL07 = #$DOW(20151227)
     C                   EVAL      COL08 = #$DOW(20151228)
     C                   EVAL      COL09 = #$DOW(20151229)
     C                   EVAL      COL10 = #$DOW(20151230)
     C                   EVAL      COL11 = #$DOW(20151231)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20151221)
     C                   EVAL      COL02 = #$ISWKD(20151222)
     C                   EVAL      COL03 = #$ISWKD(20151223)
     C                   EVAL      COL04 = #$ISWKD(20151224)
     C                   EVAL      COL05 = #$ISWKD(20151225)
     C                   EVAL      COL06 = #$ISWKD(20151226)
     C                   EVAL      COL07 = #$ISWKD(20151227)
     C                   EVAL      COL08 = #$ISWKD(20151228)
     C                   EVAL      COL09 = #$ISWKD(20151229)
     C                   EVAL      COL10 = #$ISWKD(20151230)
     C                   EVAL      COL11 = #$ISWKD(20151231)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='WINTER HOLIDAY, SATURDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/21/10'
     C                   EVAL      COL02 = '12/22/10'
     C                   EVAL      COL03 = '12/23/10'
     C                   EVAL      COL04 = '12/24/10'
     C                   EVAL      COL05 = '12/25/10'
     C                   EVAL      COL06 = '12/26/10'
     C                   EVAL      COL07 = '12/27/10'
     C                   EVAL      COL08 = '12/28/10'
     C                   EVAL      COL09 = '12/29/10'
     C                   EVAL      COL10 = '12/30/10'
     C                   EVAL      COL11 = '12/31/10'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20101221)
     C                   EVAL      COL02 = #$DOW(20101222)
     C                   EVAL      COL03 = #$DOW(20101223)
     C                   EVAL      COL04 = #$DOW(20101224)
     C                   EVAL      COL05 = #$DOW(20101225)
     C                   EVAL      COL06 = #$DOW(20101226)
     C                   EVAL      COL07 = #$DOW(20101227)
     C                   EVAL      COL08 = #$DOW(20101228)
     C                   EVAL      COL09 = #$DOW(20101229)
     C                   EVAL      COL10 = #$DOW(20101230)
     C                   EVAL      COL11 = #$DOW(20101231)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20101221)
     C                   EVAL      COL02 = #$ISWKD(20101222)
     C                   EVAL      COL03 = #$ISWKD(20101223)
     C                   EVAL      COL04 = #$ISWKD(20101224)
     C                   EVAL      COL05 = #$ISWKD(20101225)
     C                   EVAL      COL06 = #$ISWKD(20101226)
     C                   EVAL      COL07 = #$ISWKD(20101227)
     C                   EVAL      COL08 = #$ISWKD(20101228)
     C                   EVAL      COL09 = #$ISWKD(20101229)
     C                   EVAL      COL10 = #$ISWKD(20101230)
     C                   EVAL      COL11 = #$ISWKD(20101231)
     C                   EXCEPT    #ISWKD
     C*
     C                   EVAL      OUTPUT='WINTER HOLIDAY, SUNDAY'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   MOVE      *BLANKS       COLS
     C                   EVAL      COL01 = '12/21/16'
     C                   EVAL      COL02 = '12/22/16'
     C                   EVAL      COL03 = '12/23/16'
     C                   EVAL      COL04 = '12/24/16'
     C                   EVAL      COL05 = '12/25/16'
     C                   EVAL      COL06 = '12/26/16'
     C                   EVAL      COL07 = '12/27/16'
     C                   EVAL      COL08 = '12/28/16'
     C                   EVAL      COL09 = '12/29/16'
     C                   EVAL      COL10 = '12/30/16'
     C                   EVAL      COL11 = '12/31/16'
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$DOW(20161221)
     C                   EVAL      COL02 = #$DOW(20161222)
     C                   EVAL      COL03 = #$DOW(20161223)
     C                   EVAL      COL04 = #$DOW(20161224)
     C                   EVAL      COL05 = #$DOW(20161225)
     C                   EVAL      COL06 = #$DOW(20161226)
     C                   EVAL      COL07 = #$DOW(20161227)
     C                   EVAL      COL08 = #$DOW(20161228)
     C                   EVAL      COL09 = #$DOW(20161229)
     C                   EVAL      COL10 = #$DOW(20161230)
     C                   EVAL      COL11 = #$DOW(20161231)
     C                   EXCEPT    #ISWKD
     C                   EVAL      COL01 = #$ISWKD(20161221)
     C                   EVAL      COL02 = #$ISWKD(20161222)
     C                   EVAL      COL03 = #$ISWKD(20161223)
     C                   EVAL      COL04 = #$ISWKD(20161224)
     C                   EVAL      COL05 = #$ISWKD(20161225)
     C                   EVAL      COL06 = #$ISWKD(20161226)
     C                   EVAL      COL07 = #$ISWKD(20161227)
     C                   EVAL      COL08 = #$ISWKD(20161228)
     C                   EVAL      COL09 = #$ISWKD(20161229)
     C                   EVAL      COL10 = #$ISWKD(20161230)
     C                   EVAL      COL11 = #$ISWKD(20161231)
     C                   EXCEPT    #ISWKD
     C*
     C* #$ADDM - add months to a date
     C* The inputs are a date and the months to add to it, it returns the
     C* the new date
     C                   EXCEPT    #HDR
     C*
     C                   EVAL      OUTPUT='#$ADDM - ADD MONTHS TO A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF MONTHS +
     C                                     TO ADD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ADDM(20180510:5)  = ' +
     C                               %CHAR(#$ADDM(20180510:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDM(051018:5)    = ' +
     C                               %CHAR(#$ADDM(051018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ADDM(20180725:10) = ' +
     C                               %CHAR(#$ADDM(20180725:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDM(072518:10)   = ' +
     C                               %CHAR(#$ADDM(072518:10))
     C                   EXCEPT    #DTL
     C*
     C* #$SUBM - Subtracts months from a date
     C* The inputs are a date and the months to subtract from it, it returns the
     C* the new date
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SUBM - SUBTRACT MONTHS FROM A +
     C                                     DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF MONTHS +
     C                                     TO SUBTRACT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SUBM(20180810:5)  = ' +
     C                                     %CHAR(#$SUBM(20180810:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBM(081018:5)    = ' +
     C                                     %CHAR(#$SUBM(081018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBM(20180804:10) = ' +
     C                                     %CHAR(#$SUBM(20180804:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBM(080418:10)   = ' +
     C                                     %CHAR(#$SUBM(080418:10))
     C                   EXCEPT    #DTL
     C*
     C* #$ADDY - add years to a date
     C* The inputs are a date and the years to add to it, it returns the
     C* the new date
     C                   EXCEPT    #SPC
     C*
     C                   EVAL      OUTPUT='#$ADDY - ADD YEARS TO A DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF YEARS +
     C                                     TO ADD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$ADDY(20180510:5)  = ' +
     C                               %CHAR(#$ADDY(20180510:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDY(051018:5)    = ' +
     C                               %CHAR(#$ADDY(051018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ADDY(20180725:10) = ' +
     C                               %CHAR(#$ADDY(20180725:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$ADDY(072518:10)   = ' +
     C                               %CHAR(#$ADDY(072518:10))
     C                   EXCEPT    #DTL
     C*
     C* #$SUBY - Subtracts years from a date
     C* The inputs are a date and the years to subtract from it, it returns the
     C* the new date
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SUBY - SUBTRACT YEARS FROM A +
     C                                     DATE'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = NUMBER OF YEARS +
     C                                     TO SUBTRACT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     THE ENTRY DATES FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SUBY(20180810:5)  = ' +
     C                                     %CHAR(#$SUBY(20180810:5))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBY(081018:5)    = ' +
     C                                     %CHAR(#$SUBY(081018:5))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBY(20180804:10) = ' +
     C                                     %CHAR(#$SUBY(20180804:10))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$SUBY(080418:10)   = ' +
     C                                     %CHAR(#$SUBY(080418:10))
     C                   EXCEPT    #DTL
     C*
     C* #$CVTDAT - CONVERT ALHA DAT TO NUMERIC
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$CVTDAT - CONVERT ALPHA DATE +
     C                                     TO NUMERIC (8,0)'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = ALPHA DATE CHAR(10)'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = OPTIONAL, FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = THE NEW DATE IN +
     C                                     YYYYMMDD FORMAT, DEC(8,0)'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$CVTDAT(''1/1/2019'') = ' +
     C                               %CHAR(#$CVTDAT( '1/1/2019' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$CVTDAT(''01-01-2019'') = ' +
     C                               %CHAR(#$CVTDAT( '01-01-2019' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''1/1/2019'':''*USA'') = ' +
     C                               %CHAR(#$CVTDAT( '1/1/2019' : '*USA' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''01.01.2019'':''*USA'') = ' +
     C                             %CHAR(#$CVTDAT( '01.01.2019' : '*USA' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''1/1/2019'':''*MDYY'') = '+
     C                               %CHAR(#$CVTDAT( '1/1/2019' : '*MDYY' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''01&01&2019'':''*MDYY'') = '+
     C                             %CHAR(#$CVTDAT( '01&01&2019' : '*MDYY' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''2019/1/1'':''*YYMD'') = '+
     C                               %CHAR(#$CVTDAT( '2019/1/1' : '*YYMD' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''2019,01,01'':''*YYMD'') = '+
     C                             %CHAR(#$CVTDAT( '2019,01,01' : '*YYMD' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''2019/1/1'':''*ISO'') = '+
     C                               %CHAR(#$CVTDAT( '2019/1/1' : '*ISO' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''2019/01/01'':''*ISO'') = '+
     C                             %CHAR(#$CVTDAT( '2019/01/01' : '*ISO' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''19/01/01'':''*YMD'') = '+
     C                               %CHAR(#$CVTDAT( '19/01/01' : '*YMD' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''19/01.01'':''*YMD'') = '+
     C                             %CHAR(#$CVTDAT( '19/01.01' : '*YMD' ))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$CVTDAT(''01/01/19'':''*MDY'') = '+
     C                               %CHAR(#$CVTDAT( '01/01/19' : '*MDY' ))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                  '#$CVTDAT(''01&01,19'':''*MDY'') = '+
     C                             %CHAR(#$CVTDAT( '01&01,19' : '*MDY' ))
     C                   EXCEPT    #DTL
     C*
     C* #$VTIM - VALIDATE A TIME
     C                   EVAL      TITLE=#$CNTR('TIME FUNCTIONS':50)
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$VTIM - VALIDATE A TIME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC FIELD +
     C                                     CONTAINTING A TIME IN HHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A BOOLEAN TRUE OR +
     C                                     FALSE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$VTIM(120000) = ' +
     C                                     #$VTIM(120000)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$VTIM(126400) = ' +
     C                                     #$VTIM(126400)
     C                   EXCEPT    #DTL
     C*
     C* #$SEC2HMS- CONVERT A NUMBER OF SECONDS TO HMS FORMAT
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SEC2HMS - CONVERT A NUMBER OF +
     C                                     SECONDS TO HMS FORMAT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE +
     C                                     CONTAINING A NUMBER OF SECONDS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     CONTAINING A HMS TIME FIELD, +
     C                                     HMS FORMAT = HHHHHHMMSS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SEC2HMS(1000)   = ' +
     C                                     %CHAR(#$SEC2HMS(1000)) + '    = ' +
     C                                    %EDITW(#$SEC2HMS(1000):'      :  : 0')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SEC2HMS(834235) = ' +
     C                                     %CHAR(#$SEC2HMS(834235)) + ' = ' +
     C                                  %EDITW(#$SEC2HMS(834235):'      :  : 0')
     C                   EXCEPT    #DTL
     C*
     C* #$HMS2SEC- CONVERT A HMS FORMAT TO NUMBER OF SECONDS
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$HMS2SEC - CONVERT A HMS FIELD TO +
     C                                     NUMBER OF SECONDS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE +
     C                                     CONTAINING A HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     CONTAINING THE NUMBER OF SECONDS +
     C                                     IN THE HMS FIELD'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$HMS2SEC(1000)    = ' +
     C                                     %CHAR(#$HMS2SEC(1000))
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$HMS2SEC(2314355) = ' +
     C                                     %CHAR(#$HMS2SEC(2314355))
     C                   EXCEPT    #DTL
     C*
     C* #$TDIFF- RETURNS THE DIFFERENCE IN TWO TIMES IN HMS FORMAT
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TDIFF - RETURNS THE DIFFERENCE IN +
     C                                     TWO TIMES IN HMS FORMAT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE +
     C                                     CONTAINING A HHMMSS TIME FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMERIC VALUE +
     C                                     CONTAINING A HHMMSS TIME FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     CONTAINING THE TIME BETWEEN THE +
     C                                     INPUT TIMES IN HMS FORMAT'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TDIFF(104000:123000) = ' +
     C                              %CHAR(#$TDIFF(104000:123000)) + '  = ' +
     C                             %EDITW(#$TDIFF(104000:123000):'      :  : 0')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$TDIFF(010000:233000) = ' +
     C                              %CHAR(#$TDIFF(010000:233000)) + ' = ' +
     C                             %EDITW(#$TDIFF(010000:233000):'      :  : 0')
     C                   EXCEPT    #DTL
     C*
     C* #$ADDHMS - ADDS TWO HMS FIELDS TOGETHER
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$ADDHMS - ADDS TWO HMS FIELDS +
     C                                     TOGETHER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE +
     C                                     CONTAINING A HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMERIC VALUE +
     C                                     CONTAINING A HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     CONTAINING THE SUM OF THE INPUT +
     C                                     HMS FIELDS'
     C                   EXCEPT    #DTL
     C*
     C                   MOVE      *ZEROS        TMP100           10 0
     C                   EVAL      TMP100=#$ADDHMS(14000:2525)
     C                   EVAL      OUTPUT='#$ADDHMS(14000:2525)   = ' +
     C                              %CHAR(TMP100) + '   = ' +
     C                             %EDITW(TMP100:'      :  : 0')
     C                   EXCEPT    #DTL
     C                   EVAL      TMP100=#$ADDHMS(1104729:1532)
     C                   EVAL      OUTPUT='#$ADDHMS(1104729:1532) = ' +
     C                              %CHAR(TMP100) + ' = ' +
     C                             %EDITW(TMP100:'      :  : 0')
     C                   EXCEPT    #DTL
     C*
     C* #$SUBHMS - SUBTRACTS ONE HMS FIELD FROM ANOTHER
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$SUBHMS - SUBTRACTS ONE HMS FIELD +
     C                                     FROM ANOTHER'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A NUMERIC VALUE +
     C                                     CONTAINING A HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMERIC VALUE +
     C                                     CONTAINING A HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A NUMERIC VALUE +
     C                                     CONTAINING THE DIFFERENCE OF THE +
     C                                     INPUT HMS FIELDS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$SUBHMS(14000:5525)   = ' +
     C                              %CHAR(#$SUBHMS(14000:5525))+ '    = ' +
     C                             %EDITW(#$SUBHMS(14000:5525):'      :  : 0')
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$SUBHMS(1101532:3459) = ' +
     C                              %CHAR(#$SUBHMS(1101532:3459))+ ' = ' +
     C                             %EDITW(#$SUBHMS(1101532:3459):'      :  : 0')
     C                   EXCEPT    #DTL
     C*
     C* #$VTS - Validates a Timestamp
     C                   EVAL      TITLE=#$CNTR('TIMESTAMP FUNCTIONS':50)
     C                   EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$VTS - VALIDATES A DEC(14,0) +
     C                                     TIMESTAMP IN YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDSSHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A BOOLEAN TRUE +
     C                                     OR FALSE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$VTS(20180918122516)   = ' +
     C                                     #$VTS(20180918122516)
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$VTS(20181918122516)   = ' +
     C                                     #$VTS(20181918122516)
     C                   EXCEPT    #DTL
     C*
     C* #$TSSET - Creates a Timestamp from a date and a time
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TSSET - CREATES A TIMESTAMP +
     C                                     FROM A DATE AND A TIME'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A DATE IN YYYYMMDD +
     C                                     OR MMDDYY FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A TIME IN HHMMSS +
     C                                     FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A YYYYMMDDHHMMSS +
     C                                     TIMESTAMP'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSSET(20180918:122516) = ' +
     C                               %CHAR(#$TSSET(20180918:122516))
     C                   EVAL      %SUBST(OUTPUT:50:50) =
     C                                    '#$TSSET(20181918:122516)   = ' +
     C                               %CHAR(#$TSSET(20181918:122516))
     C                   EXCEPT    #DTL
     C*
     C* #$TSDATE - Returns a date from a timestamp
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TSDATE - RETURNS A DATE FROM +
     C                                     A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A YYYYMMDD DATE'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSDATE(20180918122516) = ' +
     C                               %CHAR(#$TSDATE(20180918122516))
     C                   EXCEPT    #DTL
     C*
     C* #$TSTIME - Returns a time from a timestamp
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TSTIME - RETURNS A TIME FROM +
     C                                     A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A HHMMSS TIME'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSTIME(20180918122516) = ' +
     C                               %CHAR(#$TSTIME(20180918122516))
     C                   EXCEPT    #DTL
     C*
     C* #$TSADDD - Adds a number of days to a timestamp
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSADDD - ADDS A NUMBER OF DAYS +
     C                                     TO A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMBER OF DAYS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A TIMESTAMP'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSADDD(20180918122516:2) = ' +
     C                               %CHAR(#$TSADDD(20180918122516:2))
     C                   EXCEPT    #DTL
     C*
     C* #$TSSUBD - Subtracts a number of days from a timestamp
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSSUBD - SUBTRACTS A NUMBER OF +
     C                                     DAYS FROM A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMBER OF DAYS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A TIMESTAMP'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSSUBD(20180918122516:2) = ' +
     C                               %CHAR(#$TSSUBD(20180918122516:2))
     C                   EXCEPT    #DTL
     C*
     C* #$TSADDS - Adds a number of seconds to a timestamp
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSADDS - ADDS A NUMBER OF +
     C                                     SECONDS TO A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMBER OF SECONDS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A TIMESTAMP'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSADDS(20180918122516:2) = ' +
     C                               %CHAR(#$TSADDS(20180918122516:2))
     C                   EXCEPT    #DTL
     C*
     C* #$TSSUBS - Subtracts a number of seconds from a Timestamp
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSSUBS - SUBTRACTS A NUMBER OF +
     C                                     SECONDS FROM A TIMESTAMP'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A NUMBER OF SECONDS'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = A TIMESTAMP'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSSUBS(20180918122516:2) = ' +
     C                               %CHAR(#$TSSUBS(20180918122516:2))
     C                   EXCEPT    #DTL
     C*
     C* #$TSDDAY - Returns the difference between Timestamps in days
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSDDAY - RETURNS THE DIFFERENCE +
     C                                     BETWEEN TIMESTAMPS IN DAYS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = DIFFERENCE IN DAYS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSDDAY(20180918122516:+
     C                                              20180923122516) = ' +
     C                               %CHAR(#$TSDDAY(20180918122516:+
     C                                              20180923122516))
     C                   EXCEPT    #DTL
     C*
     C* #$TSDSEC - Returns the difference between Timestamps in seconds
     C                   EXCEPT    #SPC
     C   OF              EXCEPT    #HDR
     C                   EVAL      OUTPUT='#$TSDSEC - RETURNS THE DIFFERENCE +
     C                                     BETWEEN TIMESTAMPS IN SECONDS'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = DIFFERENCE IN SECONDS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSDSEC(20180918122516:+
     C                                             :20180918122526) = ' +
     C                               %CHAR(#$TSDSEC(20180918122516:+
     C                                              20180918122526))
     C                   EXCEPT    #DTL
     C*
     C* #$TSDHMS - Returns the difference between Timestamps in an HMS field
     C                   EXCEPT    #SPC
     C                   EVAL      OUTPUT='#$TSDHMS - RETURNS THE DIFFERENCE +
     C                                     BETWEEN TIMESTAMPS IN AN HMS FIELD'
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C                   EVAL      OUTPUT='PARAMETER 1 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='PARAMETER 2 = A TIMESTAMP IN +
     C                                     YYYYMMDDHHMMSS FORMAT'
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='RETURNS     = DIFFERENCE IN HMS'
     C                   EXCEPT    #DTL
     C*
     C                   EVAL      OUTPUT='#$TSDHMS(20180918122516:+
     C                                             :20180919122526) = ' +
     C                               %CHAR(#$TSDHMS(20180918122516:+
     C                                              20180919122526)) + ' = ' +
     C                              %EDITW(#$TSDHMS(20180918122516:+
     C                                              20180919122526)
     C                                    :'      :  : 0')
     C                   EXCEPT    #DTL
     C*
     C                   SETON                                        LR
     C                   RETURN
     C*
     C******************************************************************
     C     TEST          BEGSR
     C*
     C                   EVAL      OUTPUT='TESTING #$RTVOBJD('''+
     C                                    %TRIM(#$OBJ) + ''':''' +
     C                                    %TRIM(#$LIB) + ''':''' +
     C                                    %TRIM(#$TYPE2) + ''')'
     C                   EXCEPT    #SPC
     C                   EXCEPT    #DTL
     C                   EXCEPT    #OVL
     C*
     C                   EVAL      #$OBJD=#$RTVOBJD(#$OBJ:#$LIB:#$TYPE2)
     C*
     C* IF THE DATA STRUCTURE DOES NOT CONTAIN THE NAME AN ERROR OCCURED
     C                   IF        #$ODNAM<>#$OBJ
     C                   EVAL      OUTPUT='AN ERROR OCCURED'
     C                   EXCEPT    #DTL
     C                   LEAVESR
     C                   ENDIF
     C*
     C* PRINT SOME OF THE REVTREIVED VALUES
     C                   EVAL      OUTPUT='#$ODOwnr = Objects owner = ' +
     C                               %trim(#$ODOwnr)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODCrtDat = ' +
     C                                    'Creation date and time = ' +
     C                               %TRIM(#$ODCrtDat)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODChgDat = ' +
     C                                    'Changed date and time = ' +
     C                               %TRIM(#$ODChgDat)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODTxt = ' +
     C                                    'Test = ' +
     C                              %TRIM(#$ODTxt)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODSrcFil = ' +
     C                                    'Source File = ' +
     C                              %TRIM(#$ODSrcFil)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODSrcLib = ' +
     C                                    'Source File Library = ' +
     C                              %TRIM(#$ODSrcLib)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODSrcMbr = ' +
     C                                    'Source File Mbr = ' +
     C                              %TRIM(#$ODSrcMbr)
     C                   EXCEPT    #DTL
     C                   EVAL      OUTPUT='#$ODSrcChgDat = ' +
     C                                    'Source Changed date and Time = ' +
     C                               %TRIM(#$ODSrcChgDat)
     C                   EXCEPT    #DTL
     C*
     C                   ENDSR
     C******************************************************************
     OQPRINT    E            #HDR             01
     O                                            5 'Date:'
     O                       *DATE               17 '    /  / 0'
     O                                           75 'Fabricut Functions'
     O                                          116 'PAGE:'
     O                       PAGE          Z    120
     O                                          132 '#$BASETS'
     O          E            #HDR        0  0
     O                                           75 'Fabricut Functions'
     O          E            #HDR        1  1
     O                       TITLE               91
     O          E            #SPC        1
     O          E            #DTL        1
     O                       OUTPUT             132
     O          E            #ISWKD      1
     O                       COL01               10
     O                       COL02               21
     O                       COL03               32
     O                       COL04               43
     O                       COL05               54
     O                       COL06               65
     O                       COL07               76
     O                       COL08               87
     O                       COL09               98
     O                       COL10              109
     O                       COL11              120
     O                       COL12              131
     O          E            #OVL        0  0
     O                       OUTPUT             132
