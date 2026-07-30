      ** This program demonstrates parsing a spreadsheet with the
      **  XLPARSER4 service program.
      **                                Scott Klement, January 8, 2004
      **
      ** To compile:
      **    (first follow the instructions to compile XLPARSER4)
      **>   CRTBNDRPG XLPDEMO SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      **
     H DFTACTGRP(*NO) BNDDIR('APLLIB') ACTGRP(*NEW)

     FQSYSPRT   O    F   80        PRINTER OFLIND(*INOF)

      /copy QSRC,XLPARSV1PR

     D XLPDEMO         PR                  ExtPgm('XLPDEMO')
     D   peXSSF                       1n   const options(*nopass)
     D XLPDEMO         PI
     D   peXSSF                       1n   const options(*nopass)

     D IFSDIR          C                   '/tmp'

     D charcell        PR             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                    32767A   varying const

     D numbercell      PR             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value

     D msg             s             50A
     D wait            s              1A

     D year            s              4P 0
     D part            s              8A
     D descr           s             28A
     D sales           s              7P 2 dim(4)
     D myfile          s           1024a   varying

      /free

         // FIXME: Change the path below to the place where you put
         //       xlpdemo.xls in your IFS!

         if (%parms>=1 and peXSSF);
            myfile = IFSDIR + '/xlpdemo.xlsx';
         else;
            myfile = IFSDIR + '/xlpdemo.xls';
         endif;

         if xlparse_workbook( myfile
                            : %paddr(NumberCell)
                            : %paddr(CharCell)  ) < 0;
             msg = 'Error occcured while parsing spreadsheet.';
             dsply msg ' ' wait;
         endif;

         *inlr = *on;
         return;

       /end-free

     OQSYSPRT   E            Heading        1  3
     O                       *DATE         Y     10
     O                                           +1 'ACME Widget Sales for'
     O                       year                +1
     O                                           76 'Page'
     O                       page          Z     80

     O          E            item
     O                       part                10
     O                       descr               +1
     O                       sales(1)      L     +1
     O                       sales(2)      L     +1
     O                       sales(3)      L     +1
     O                       sales(4)      L     +1

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called once for each character cell in the spreadsheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P charcell        B
     D charcell        PI             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                    32767A   varying const
      /free

          // We're only interested in the "part no" and "description"
          // columns which are in rows 5 - 20, columns A & B.

          if (row>=4 and row<=19);

             select;
             when column = 0;
               part = value;
             when column = 1;
               descr = value;
             endsl;

          endif;

          return *OFF;

      /end-free
     P                 E

      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      *  This is called once for each numeric cell in the spreadsheet
      *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     P numbercell      B
     D numbercell      PI             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Column                       5I 0 value
     D   Value                        8F   value

     D firstpage       s              1N   static inz(*ON)
     D qtr             s             10I 0

      /free

          // we're interested in getting the year from the first row.

          if (row=0 and column=7);
              year = value;
          endif;

          // We're also interested in the sales figures which are
          // in columns C-F and rows 5-20

          if (row>=4 and row<=19);

             if (column>=2 and column<=5);

                // save sales figures into an array.

                qtr = column - 1;
                sales(qtr) = value;

                // if this is the last column, print this item, and
                //   clear out our variables.

                if (column = 5);

                    if (firstpage or *inof=*on);
                       except heading;
                       firstpage = *Off;
                    endif;

                    except item;

                    for qtr = 1 to %elem(sales);
                       sales(qtr) = 0;
                    endfor;

                    part = *blanks;
                    descr = *blanks;

                endif;

             endif;
          endif;

          return *off;
      /end-free
     P                 E
