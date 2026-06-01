      ** This program demonstrates parsing a spreadsheet that has
      ** formulas with the XLPARSER4 program.
      **                                Scott Klement, July 12, 2007
      **
      ** WARNING: Formula support should be considered "experimental"
      **          at this point.
      **
      ** To compile:
      **    (first follow the instructions to compile XLPARSER4)
      **>   CRTBNDRPG XLPDEMOF SRCFILE(QRPGLESRC) DBGVIEW(*LIST)
      **
     H DFTACTGRP(*NO) BNDDIR('APLLIB') ACTGRP(*NEW)

     FQSYSPRT   O    F   80        PRINTER OFLIND(*INOF)

      /copy QSRC,XLPARSV1PR

     D XLPDEMOF        PR                  ExtPgm('XLPDEMOF')
     D   peXSSF                       1n   const options(*nopass)
     D XLPDEMOF        PI
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

     D formulacell     PR             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Col                          5I 0 value
     D   Value                        8F   value
     D   Nan                          5I 0 value
     D   Formula                  32767A   varying const

     D prt             ds            80

     D filename        s            200a   varying
     D msg             s             50A
     D wait            s              1A

      /free

         // FIXME: Change the path below to the place where you put
         //       TestFormula.xls in your IFS!

         if (%parms>=1 and peXSSF);
            filename = IFSDIR + '/TestFormula.xlsx';
         else;
            filename = IFSDIR + '/TestFormula.xls';
         endif;

         if xlparse_workbook( filename
                            : %paddr(NumberCell)
                            : %paddr(CharCell)
                            : %paddr(FormulaCell)
                            : *OFF ) < 0;
             msg = 'Error occcured while parsing spreadsheet.';
             dsply msg ' ' wait;
         endif;

         *inlr = *on;
         return;

       /end-free

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

          prt = 'Row=' + %char(row) + ', Col=' + %char(Column)
              + ', value = ' + Value + ' (charcell)';
          write QSYSPRT prt;

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

          prt = 'Row=' + %char(row) + ', Col=' + %char(Column)
              + ', value = ' + %char(%dec(Value:3:0))
              + ' (numbercell)';
          write QSYSPRT prt;

          return *off;
      /end-free
     P                 E

     P formulacell     B
     D formulacell     PI             1N
     D   Sheet                     1024A   varying const
     D   Row                         10I 0 value
     D   Col                          5I 0 value
     D   Value                        8F   value
     D   Nan                          5I 0 value
     D   Formula                  32767A   varying const
      /free

          if (Nan = 0);
             prt = 'Row=' + %char(row) + ', Col=' + %char(Col)
                 + ', value = ' + %char(%dec(Value:3:0))
                 + ' (formulacell)';
             write QSYSPRT prt;
          else;
             prt = 'Row=' + %char(row) + ', Col=' + %char(Col)
                 + ', value = NaN (Not a Number)'
                 + ' (formulacell)';
             write QSYSPRT prt;
          endif;

         return *Off;
      /end-free
     P                 E
