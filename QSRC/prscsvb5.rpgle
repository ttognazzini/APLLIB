      * Demonstration of Reading a CSV file and generating
      * a sample report using DATA-INTO support with Unicode
      * and replacing "smart quotes" with straight ones.
      *                 Scott Klement, May 6, 2020
      *
      * To compile:
      *  - Ensure that you have already build CSVR4 and
      *      CSVINTO. These must be in your *LIBL. See
      *      the respective source members for details.
      *  - Run the following command:
      *>     CRTBNDRPG CSVDEMO5 SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *
      * NOTE: This program uses DATA-INTO which requires
      *       IBM i 7.2 or higher.  (In 7.2 and 7.3 PTFs are needed.)
      *
      *       This expects /home/sklement/addrtest.csv to
      *       be found in the IFS.  For more info, see the
      *       comments in the CSVDEMO member.
      *
       ctl-opt DECEDIT('0.') OPTION(*SRCSTMT:*NOSHOWCPY:*NODEBUGIO);

       dcl-f QSYSPRT PRINTER(132) OFLIND(OverFlow);

       dcl-ds pgmStat psds;
         numRows int(20) pos(372);
       end-ds;

       dcl-c LEFT_SINGLE_QUOTE      u'2018';
       dcl-c RIGHT_SINGLE_QUOTE     u'2019';
       dcl-c LEFT_DOUBLE_QUOTE      u'201C';
       dcl-c RIGHT_DOUBLE_QUOTE     u'201D';
       dcl-c STRAIGHT_SINGLE_QUOTE  u'0027';
       dcl-c STRAIGHT_DOUBLE_QUOTE  u'0022';
       dcl-s fancyQuotes    varucs2(4) ccsid(1200);
       dcl-s straightQuotes varucs2(4) ccsid(1200);

       dcl-s acct varchar(10);
       dcl-s name varchar(50);
       dcl-s addr1 varchar(40);
       dcl-s addr2 varchar(40);
       dcl-s addr3 varchar(40);
       dcl-s addr4 varchar(40);
       dcl-s postal varchar(10);
       dcl-s credLmt packed(9: 2);
       dcl-s x int(10);

       dcl-ds CSV qualified dim(5000);
          field1 like(acct);    // acct
          field2 varucs2(50) ccsid(1200);  // name is in Unicode
                                           // because curlyquotes dont
                                           // exist in EBCDIC.
          field3 like(addr1);   // addr1
          field4 like(addr2);   // addr2
          field5 like(addr3);   // addr3
          field6 like(addr4);   // addr4
          field7 like(postal);  // postal code
          field8 like(credLmt); // credit limit
       end-ds;

       //  'fancyQuotes' are the curly-type quotes that Microsoft
       //   sometimes uses in Office.
       //  'straightQuotes' are the normal ones that exist in EBCDIC

       fancyQuotes = LEFT_SINGLE_QUOTE + RIGHT_SINGLE_QUOTE
                   + LEFT_DOUBLE_QUOTE + RIGHT_DOUBLE_QUOTE;

       straightQuotes = STRAIGHT_SINGLE_QUOTE + STRAIGHT_SINGLE_QUOTE
                      + STRAIGHT_DOUBLE_QUOTE + STRAIGHT_DOUBLE_QUOTE;


       data-into CSV %DATA('/home/sklement/addrtest.csv': 'doc=file')
                     %PARSER('CSVINTO');
       except heading;

       for x = 1 to numRows;
          acct = CSV(x).field1;
          credLmt = CSV(x).field8;

          // replace fancy quotes w/straight ones
          // then convert the field to EBCDIC for printing
          CSV(x).field2 = %xlate( fancyQuotes: straightQuotes: CSV(x).field2 );
          name = %char(CSV(x).field2);

          if (OverFlow);
             except heading;
             Overflow = *OFF;
          endif;

          except rec;
       endfor;

       *inlr = *on;

     OQSYSPRT   E            heading        1  3
     O                                           +0 'Acct'
     O                                           +8 'Name'
     O                                          +48 'Credit Lmt '
     O          E            heading        1
     O                                           +0 '----------'
     O                                           +2 '--------------------'
     O                                           +0 '--------------------'
     O                                           +0 '----------'
     O                                           +2 '-----------'
     O          E            rec            1
     O                       acct                +0
     O                       name                +2
     O                       credLmt       P     +2
