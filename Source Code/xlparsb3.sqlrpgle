      ** This program demonstrates parsing a spreadsheet with the
      **  XLPARSER4 service program and uses the xlparse_notify()
      **  routine to determine where rows start/end.
      **                             Scott Klement, November 25, 2008
      **
      ** To compile:
      **    (first follow the instructions to compile XLPARSER4)
      **>   CRTBNDRPG XLPNOTDEMO SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      **
     H DFTACTGRP(*NO) BNDDIR('APLLIB') ACTGRP('KLEMENT')

     FQSYSPRT   O    F  132        PRINTER OFLIND(OverFlow)

      /copy QSRC,XLPARSV1PR

     D XLPNOTDEMO      PR                  ExtPgm('XLPNOTDEMO')
     D   peXSSF                       1n   const options(*nopass)
     D XLPNOTDEMO      PI
     D   peXSSF                       1n   const options(*nopass)

     D IFSDIR          C                   '/tmp'

     D clear_struct    PR
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value

     D print_struct    PR
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value

     D character       PR             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                    32767A   varying const

     D numeric         PR             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value

     D mon             ds                  qualified
     D   part                        10a
     D   desc                        30a
     D   saleA                       11p 2 inz
     D   saleB                       11p 2 inz
     D   saleC                       11p 2 inz
     D   saleD                       11p 2 inz

     D firstpage       s              1n   inz(*ON)
     D Month           s              9a
     D Year            s              4s 0

     D filename        s            200a   varying
     D msg             s             50A
     D wait            s              1A

      /free

         xlparse_notify( %paddr(clear_struct)
                       : %paddr(print_struct) );

         if (%parms>=1 and peXSSF);
            filename = IFSDIR + '/november_sales.xlsx';
         else;
            filename = IFSDIR + '/november_sales.xls';
         endif;

         if xlparse_workbook( filename
                            : %paddr(Numeric)
                            : %paddr(Character)
                            : *NULL ) <> 0;
             msg = 'Error occcured. See job log.';
             dsply msg ' ' wait;
         endif;

         // this disables notifications:

         xlparse_notify( *null: *null );

         *inlr = *on;
         return;

       /end-free

     OQSYSPRT   E            Heading        1  3
     O                       *DATE         Y     10
     O                                           +1 'ACME Widget Sales for'
     O                       Month               +1
     O                                           76 'Page'
     O                       page          Z     80

     O          E            item
     O                       mon.part            10
     O                       mon.desc            +1
     O                       mon.saleA     L     +1
     O                       mon.saleB     L     +1
     O                       mon.saleC     L     +1
     O                       mon.saleD     L     +1


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called once for each character cell in the spreadsheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Character       B
     D Character       PI             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                    32767A   varying const
      /free
          if (row = 1  and  column = 2);
             month = value;
          endif;

          if (row > 4);

             select;
             when column = 0;
               mon.part = value;
             when column = 1;
               mon.desc = value;
             endsl;

          endif;

          return *OFF;

      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called once for each numeric cell in the spreadsheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P Numeric         B
     D Numeric         PI             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value

      /free
          if (row = 1  and  column = 3);
             year = value;
          endif;


          // Sales figures are in columns C,D,E,F of each row
          // beyond row 4

          if (row > 4);

             select;
             when column=2;
                mon.saleA = value;
             when column=3;
                mon.saleB = value;
             when column=4;
                mon.saleC = value;
             when column=5;
                mon.saleD = value;
             endsl;

          endif;

          return *off;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called before each row that has data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P clear_struct    B
     D clear_Struct    PI
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
      /free
         if Row = 1;
            Month = *blanks;
            year  = 0;
         endif;

         if Row > 4;
            clear mon;
         endif;
      /end-free
     P                 E


      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called after each row that has data
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P print_struct    B
     D print_Struct    PI
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value

      /free
         if row > 4;
             if (firstpage or overflow);
                except Heading;
                firstpage = *off;
                overflow  = *off;
             endif;

             except item;
         endif;
      /end-free
     P                 E
