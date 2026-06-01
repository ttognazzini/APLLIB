      * Demonstration of Reading a CSV file and generating
      * a sample report using DATA-INTO support.
      *                 Scott Klement, October 11, 2018
      *
      * To compile:
      *  - Ensure that you have already build CSVR4 and
      *      CSVINTO. These must be in your *LIBL. See
      *      the respective source members for details.
      *  - Run the following command:
      *>     CRTBNDRPG CSVDEMO3 SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
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
          field2 like(name);    // name
          field8 like(credLmt); // credit limit
       end-ds;

       data-into CSV %DATA( '/home/sklement/addrtest.csv'
                          : 'doc=file allowextra=yes')
                     %PARSER('CSVINTO');
       except heading;

       for x = 1 to numRows;
          acct = CSV(x).field1;
          name = CSV(x).field2;
          credLmt = CSV(x).field8;

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
