**free
Ctl-Opt OPTION(*SrcStmt) Dftactgrp(*No) Actgrp(*new) BNDDIR('APLLIB') Main(Main);

// This program tests the #$CSV procedures

Dcl-S file         Char(128);
Dcl-S test1        Packed(20:5) INZ(123.54);
Dcl-S test2        Packed(9:2) INZ(9.2);
Dcl-S test3        Zoned(9:2) INZ(-9.2);
Dcl-S Y            Zoned(5:0);
Dcl-S testIfsPath varchar(100) Inz('/ACOM/test/OUTFLEB3');

/Copy QSRC,OUTFLEV1PR

// ------------------------------------------------------------------ *
// Main line calcs
// ------------------------------------------------------------------ *
Dcl-Proc Main;

  // CREATE NEW CSV FILE IN THE IFS
  file=#$CSVCPath(testIfsPath);
  #$OpenCSV(file);

  // ADD HEADER RECORD 1
  #$CSVChar('Fabricut');
  #$CSVChar(' ');
  #$CSVChar(' ');
  #$CSVChar('#$CSVTS');
  #$CSVChar('1/12/10');
  #$CSVChar('12:15:02');

  // ADD HEADER RECORD 2
  #$CSVNext();
  #$CSVChar('Test CSV File Routines');

  // SKIP A LINE
  #$CSVNext();

  // ADD COLUMN HEADERS
  #$CSVNext();
  #$CSVChar('Row 1');
  #$CSVChar('Row 2');
  #$CSVChar('Row 3');
  #$CSVChar('Row 4');

  // ADD 10 LINES OF DETAIL
  For Y = 1 to 10;
    #$CSVNext();
    #$CSVChar('Value ' + %triml(%editc(Y:'Z')));
    #$CSVDate(20091210);
    #$CSVChar('Something Else');
    #$CSVNum(5-Y);
  EndFor;

  #$CSVNext();
  #$CSVChar('Value 11');
  #$CSVDate(20091210);
  #$CSVChar('Something Else');
  #$CSVNum(test1);

  #$CSVNext();
  #$CSVChar('Value 12');
  #$CSVDate(121009);
  #$CSVChar('Something Else');
  #$CSVNum(test2);

  #$CSVNext();
  #$CSVChar('Value 13');
  #$CSVDate(-20091210);
  #$CSVChar('Something Else');
  #$CSVNum(test3);

  #$CSVNext();
  #$CSVChar('Value 14');
  #$CSVDate(0);
  #$CSVChar('Something Else');
  #$CSVNum(55);

  // CLOSE THE OPEN CSV FILE
  // IF THIS IS NOT DONE THEN THE FILE WILL REMAIN LOCKED
  #$CloseCSV();

End-Proc;
