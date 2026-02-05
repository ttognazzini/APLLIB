**free
Ctl-Opt OPTION(*srcStmt) Dftactgrp(*No) Actgrp(*new) BNDDIR('APLLIB');

// This program tests the #$XML procedure

/Copy QSRC,OUTFLEV1PR

Dcl-S Y            Zoned(5:0);
Dcl-S testIfsPath varchar(100) Inz('/ACOM/test/OUTFLEB2.XML');


// create new XML file in the IFS
// #$XMLPATH = #$XMLCPATH(FileName);
#$XMLOpen(testIfsPath);

// add a Styles
// Bottom-Border, Arial, size 14, Color-Red, Bold, Underline, Italics
#$XMLStyle('S01':'0':'1':'0':'0':'Arial':'14':'#990000':'1':'1':'1');

// Bottom Border, default on rest
#$XMLStyle('S02':'0':'1':'0':'0':*omit:*omit:*omit:'0':'0':'0');

// add a New Worksheet
#$XMLWsDs.#$XMLWIDTH     = 0   ;
#$XMLWsDs.#$XMLWIDTH(1)  = 150 ;
#$XMLWsDs.#$XMLWIDTH(2)  = 150 ;
#$XMLWsDs.#$XMLWIDTH(3)  = 150 ;
#$XMLWkSh('Summary':#$XMLWsDs)   ;

// add header record 1
#$XMLNwRw();
#$XMLChar('Computer Software Solutions':'S01');
#$XMLChar(' ':'S02');
#$XMLChar(' ':'S02');
#$XMLChar('#$XMLTS':'S02');
#$XMLChar('1/12/10':'S02');
#$XMLChar('12:15:02':'S02');
// add header record 2
#$XMLNwRw();
#$XMLChar('Test CSV File Routines':*omit);

// skip a line
#$XMLNwRw();

// add column headers
#$XMLNwRw();
#$XMLChar('Item');
#$XMLChar('Description');
#$XMLChar('Sales Qty');
#$XMLChar('Sales Dollars');

// add 10 lines of detail
Y=0;
For Y = 1 to 10;
  #$XMLNwRw();
  #$XMLChar('Item' + %triml(%editc(Y:'Z')));
  #$XMLChar('Description of item' + %triml(%editc(Y:'Z')));
  #$XMLNum(Y);
  #$XMLNum((Y*(5+Y)));
EndFor;

// add a New Worksheet
#$XMLWkSh('Detail':#$XMLWsDs)   ;

// add header record 1
#$XMLNwRw();
#$XMLChar('Computer Software Solutions' :'S01');
#$XMLChar(' ':'S02');
#$XMLChar(' ':'S02');
#$XMLChar('#$XMLTS':'S02');
#$XMLChar('1/12/10':'S02');
#$XMLChar('12:15:02':'S02');

// add header record 2
#$XMLNwRw();
#$XMLChar('Test CSV File Routines':*omit);

// skip a line
#$XMLNwRw();

// add column headers
#$XMLNwRw();
#$XMLChar('Item');
#$XMLChar('Description');
#$XMLChar('Order#');
#$XMLChar('Date');
#$XMLChar('Sales Qty');
#$XMLChar('Unit Price');
#$XMLChar('Total Price');

// add 10 lines of detail
Y=0;
For Y = 1 to 30;
  #$XMLNwRw();
  #$XMLChar('Item' + %triml(%editc(Y:'Z')));
  #$XMLChar('Description of item' +  %triml(%editc(Y:'Z')));
  #$XMLChar('100000-01');
  #$XMLChar('12/12/12');
  #$XMLNum(Y);
  #$XMLNum((5+Y));
  #$XMLNum((Y*(5+Y)));
EndFor;

// close the open CSV File
#$XMLClose();

Return;
