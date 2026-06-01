      * Demonstration of Reading a CSV file and generating
      * a sample report.
      *                 Scott Klement, November 25, 2008
      *
      * To compile:
      *  - Ensure that you have already built CSVR4. See
      *      the CSVR4 member for details.
      *  - Run the following command:
      *>     CRTBNDRPG CSVDEMO SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      *
      *
      * NOTE: This program expects a CSV file named
      *       /home/sklement/addrtest.csv to be found
      *       in the IFS.  That file should be formatted
      *       with eight fields, an account id, name
      *       address1-4, postal code and credit limit.
      *       Here is a sample record (should be all one line)
      *
      *       "ABC123","Scott Klement","123 Sesame St","Milwaukee, WI",
      *          "USA","","53132-1234",1000.00
      *
      *  For demonstrtion purposes, only the account id, name
      *  and credit limit will be printed.
      *
     H DFTACTGRP(*NO) ACTGRP('KLEMENT') BNDDIR('APLLIB/APLLIB')
     H DECEDIT('0.')

     FQSYSPRT   O    F  132        PRINTER oflind(Overflow)

      /copy APLLIB/QSRC,PRSCSVV1PR // Prototypes for the PRSCSVV1 service program

     D acct            s             10a   varying
     D name            s             50a   varying
     D addr1           s             40a   varying
     D addr2           s             40a   varying
     D addr3           s             40a   varying
     D addr4           s             40a   varying
     D postal          s             10a   varying
     D creditLimit     s              9p 2
     D temp            s             11a   varying

     D csvfile         s                   like(CSV_HANDLE)
     D fc              s             10i 0
     D fld             s            132a   varying
     D prt             ds           132

      /free

          csvfile = csv_open('/home/sklement/addrtest.csv');
          except heading;

          dow csv_loadrec(csvfile);

             CSV_getfld(csvfile: acct:   %size(acct)  );
             CSV_getfld(csvfile: name:   %size(name)  );
             CSV_getfld(csvfile: addr1:  %size(addr1) );
             CSV_getfld(csvfile: addr2:  %size(addr2) );
             CSV_getfld(csvfile: addr3:  %size(addr3) );
             CSV_getfld(csvfile: addr4:  %size(addr4) );
             CSV_getfld(csvfile: postal: %size(postal));
             CSV_getfld(csvfile: temp:   %size(temp) );
             creditLimit = %dec( temp: 9: 2);

             if (OverFlow);
                except heading;
                Overflow = *OFF;
             endif;

             except rec;

          enddo;

          csv_close(csvfile);
          *inlr = *on;

      /end-free

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
     O                       creditLimit   P     +2
