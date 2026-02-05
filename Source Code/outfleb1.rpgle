**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) Actgrp(*new) BndDir('APLLIB') Main(Main);

//  This program tests the procedures in OUTFLEV1 Service program

Dcl-S #date packed(8);
Dcl-S #time packed(6);
Dcl-S testIfsPath varchar(100) Inz('/ACOM/test/OUTFLEB1');

/Copy QSRC,OUTFLEV1PR


Dcl-Proc Main;

  #date = %dec(%char(%date():*ISO0):8:0);
  #time = %dec(%char(%time():*HMS0):6:0);

  // section one, create a csv output file.
  CreateReport('CSV');


  // section two, create an xml output file.
  CreateReport('XML');

  // section three, create a excel output file.
  CreateReport('XLS');

End-Proc;


Dcl-Proc CreateReport;
  Dcl-Pi *n;
    type Char(4) const;
  End-Pi;

  // set column widths and open file.
  #$OutFWidths(1)=16;
  #$OutFWidths(2)=40;
  #$OutFWidths(3)=12;
  #$OutFWidths(4)=12;
  #$OutFWidths(5)=12;
  #$OutFWidths(6)=12;
  #$OutFWidths(7)=12;
  #$OutFWidths(8)=12;
  #$OpenOut(testIfsPath:type:#$OutFWidths);

  // add header record 1
  #$AddChar('Aplication Library Test':'C');
  #$AddChar('');
  #$AddChar('');
  #$AddChar('OUTFLEB1');
  #$AddDate(#date);
  #$AddChar(%editw(#time:' 0:  :  '));
  // add header record 2
  #$NextRec();
  #$AddChar('Inventory Requirements':'T');
  // skip a line
  #$NextRec();
  // add column header
  #$NextRec();
  #$AddChar('ITEM NO':'H');
  #$AddChar('ITEM DESCRIPTION':'H');
  #$AddChar('ON HAND':'HR');
  #$AddChar('ORDERED':'HR');
  #$AddChar('B/O':'HR');
  #$AddChar('GROSS ORDERED':'HR');
  #$AddChar('DISCOUNTS':'HR');
  #$AddChar('NET--ORDERED':'HR');
  // add detail record
  #$NextRec();
  #$AddChar('101');
  #$AddChar('BLUE WIDGET');
  #$AddNum( 10);
  #$AddNum(  5);
  #$AddNum(  0);
  #$AddNum2( 1150.25);
  #$AddNum2( 25.34);
  #$AddNum2( 1124.98);

  // add detail record
  #$NextRec();
  #$AddChar('1234567890123456');
  #$AddChar('12345678901234567890134567890');
  #$AddNum( 123456789);
  #$AddNum(  5);
  #$AddNum(  0);
  #$AddNum2( 1150.235);
  #$AddNum2( 25.34);
  #$AddNum2( 1124.98);

  // add report total
  #$NextRec();
  #$NextRec();
  #$AddChar(' ');
  #$AddChar('** REPORT TOTAL':'B');
  #$AddChar(' ');
  #$AddChar(' ');
  #$AddChar(' ');
  #$AddNum2( 2001.35:'B');
  #$AddNum2( 57.42:'B');
  #$AddNum2( 2943.25:'B');

  // The rest of this starts a new sheet with same stuff
  #$OutFWidths(1)=16;
  #$OutFWidths(2)=20;
  #$OutFWidths(3)=12;
  #$OutFWidths(4)=12;
  #$OutFWidths(5)=12;
  #$OutFWidths(6)=12;
  #$OutFWidths(7)=12;
  #$OutFWidths(8)=12;
  #$NewSheet();

  // add header record 1
  #$AddChar('Aplication Library Test':'C');
  #$AddChar('');
  #$AddChar('');
  #$AddChar('OUTFLEB1');
  #$AddDate(#date);
  #$AddChar(%editw(#time:' 0:  :  '));
  // add header record 2
  #$NextRec();
  #$AddChar('INVENTORY REQUIREMENTS':'T');
  // skip a line
  #$NextRec();
  // add column header
  #$NextRec();
  #$AddChar('ITEM NO':'H');
  #$AddChar('ITEM DESCRIPTION':'H');
  #$AddChar('ON HAND':'HR');
  #$AddChar('ORDERED':'HR');
  #$AddChar('B/O':'HR');
  #$AddChar('GROSS ORDERED':'HR');
  #$AddChar('DISCOUNTS':'HR');
  #$AddChar('NET--ORDERED':'HR');
  // add detail record
  #$NextRec();
  #$AddChar('101');
  #$AddChar('BLUE WIDGET');
  #$AddNum( 10);
  #$AddNum(  5);
  #$AddNum(  0);
  #$AddNum2( 1150.25);
  #$AddNum2( 25.34);
  #$AddNum2( 1124.98);

  // add detail record
  #$NextRec();
  #$AddChar('1234567890123456');
  #$AddChar('12345678901234567890134567890');
  #$AddNum( 123456789);
  #$AddNum(  5);
  #$AddNum(  0);
  #$AddNum2( 1150.235);
  #$AddNum2( 25.34);
  #$AddNum2( 1124.98);

  // add report total
  #$NextRec();
  #$NextRec();
  #$AddChar(' ');
  #$AddChar('** REPORT TOTAL':'B');
  #$AddChar(' ');
  #$AddChar(' ');
  #$AddChar(' ');
  #$AddNum2( 2001.35:'B');
  #$AddNum2( 57.42:'B');
  #$AddNum2( 2943.25:'B');

  // Close the open File
  #$CloseOut();

End-Proc;
