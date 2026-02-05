**free
//  These function are used to create CSV files in the IFS
//    the functions are stored in file #$CSV see program
//    #$CSVTS for an example how to use them
//
//    #$CVSPath  = Create a default path
//    #$OpenCSV  = Open an existing file or create a new one
//    #$NewSheet = Start a new sheet, ignored for CSV
//    #$CSVChar  = add a character field to a csv file
//    #$CSVNum   = add a value field to csv file
//    #$CSVNum0  = add a value field to csv file - 0 Dec
//    #$CSVNum2  = add a value field to csv file - 2 Dec
//    #$CSVDate  = add a date file to csv file
//    #$CSVNext  = start a new record
//    #$CloseCSV = Close the open CSV File
Dcl-S #$CSVFile int(10);
Dcl-S #$CSVFF char(1);
Dcl-S #$CSVPath char(1024);
Dcl-S #$CSVLine char(2048);
Dcl-Pr #$CSVCPath char(1024) ExtProc;
  *n char(1024) const; // #$CSVName
End-Pr;
Dcl-Pr #$OpenCSV ExtProc;
  *n char(1024) const; // #$CSVName
End-Pr;
Dcl-Pr #$CSVChar ExtProc;
  *n char(512) const; // #$CSVChar
End-Pr;
Dcl-Pr #$CSVNum ExtProc;
  *n zoned(20: 5) const; // #$CSVNum
End-Pr;
Dcl-Pr #$CSVNum0 ExtProc;
  *n zoned(20: 5) const; // #$CSVNum
End-Pr;
Dcl-Pr #$CSVNum2 ExtProc;
  *n zoned(20: 5) const; // #$CSVNum
End-Pr;
Dcl-Pr #$CSVDate ExtProc;
  *n zoned(8) const; // #$CSVDate
End-Pr;
Dcl-Pr #$CSVNext ExtProc end-pr;
Dcl-Pr #$CloseCSV ExtProc end-pr;


//  These function are used to create XML files in the IFS
//    the functions are stored in file #$XML see program
//    #$XMLTS for an example how to use them
//
//    #$XMLCPath = Create a default path
//    #$XMLNew   = Create a new XML file
//    #$XMLStyle = Create a style group
//    #$XMLWkSh  = Add a worksheet ot the XML file
//    #$XMLNwRw  = start a new row
//    #$XMLChar  = add a character field to a csv file
//    #$XMLNum   = add a value field to csv file
//    #$XMLDate  = add a date file to csv file
//    #$XMLClose = Close the open XML File
//
// š   Global Variables
Dcl-S #$XMLFile int(10);
Dcl-S #$XMLPath char(1024);
Dcl-S #$XMLStylO char(1);
Dcl-S #$XMLTablO char(1);
Dcl-S #$XMLRowO char(1);
Dcl-S #$XMLWkShO char(1);
Dcl-Ds #$XMLWsDs qualified;
  #$XMLWidth zoned(4) dim(100);
  #$XMLFrzTop zoned(2) inz(0);
  #$XMLFrzLft zoned(2) inz(0);
  #$XMLPrCol zoned(2) inz(0);
  #$XMLPrRows zoned(2) inz(0);
  #$XMLPrBM zoned(4: 2) inz(.75);
  #$XMLPrTM zoned(4: 2) inz(.75);
  #$XMLPrLM zoned(4: 2) inz(.70);
  #$XMLPrRM zoned(4: 2) inz(.70);
  #$XMLPrHM zoned(4: 2) inz(.30);
  #$XMLPrFM zoned(4: 2) inz(.30);
  #$XMLPrSc zoned(3) inz(100);
  #$XMLPrCH char(1) inz('0');
  #$XMLPrCV char(1) inz('0');
  #$XMLPrHR zoned(4) inz(600);
  #$XMLPrVR zoned(4) inz(600);
End-Ds;
//   Function Prototypes
Dcl-Pr #$XMLCPath char(1024) ExtProc;
  *n char(1024) const; // #$XMLName
End-Pr;
Dcl-Pr #$XMLOpen ExtProc;
  *n char(1024) const; // #$XMLName
End-Pr;
Dcl-Pr #$XMLStyle ExtProc;
  *n char(10) const; // Style
  *n char(1) const options( *nopass : *omit ); // BordTop
  *n char(1) const options( *nopass : *omit ); // BordBottom
  *n char(1) const options( *nopass : *omit ); // BordLeft
  *n char(1) const options( *nopass : *omit ); // BordRight
  *n char(10) const options( *nopass : *omit ); // FontName
  *n char(3) const options( *nopass : *omit ); // FontSize
  *n char(7) const options( *nopass : *omit ); // FontColor
  *n char(1) const options( *nopass : *omit ); // FontBold
  *n char(1) const options( *nopass : *omit ); // FontUL
  *n char(1) const options( *nopass : *omit ); // FontItalic
  *n char(1) const options( *nopass : *omit ); // NumFormat
  *n char(1) const options( *nopass : *omit ); // Center
End-Pr;
Dcl-Pr #$XMLWkSh ExtProc;
  *n char(20) const; // WorkSheet
  *n like(#$XMLWsDs); // PSXMLWsDs
End-Pr;
Dcl-Pr #$XMLNwRw ExtProc end-pr;
Dcl-Pr #$XMLChar ExtProc;
  *n char(512) const; // #$XMLChar
  *n char(10) const options( *nopass : *omit ); // Style
End-Pr;
Dcl-Pr #$XMLNum ExtProc;
  *n zoned(20: 5) const; // #$XMLNum
  *n char(10) const options( *nopass : *omit ); // Style
End-Pr;
Dcl-Pr #$XMLDate ExtProc;
  *n zoned(8) const; // #$XMLDate
  *n char(10) const options( *nopass : *omit ); // pStyle
End-Pr;
Dcl-Pr #$XMLClose ExtProc end-pr;


//  These function are used to create Excel files in the IFS
//    the functions are stored in file #$XLS see program
//    #$XLSTS for an example how to use them
//
//    #$XLSPath  = Create a default path
//    #$OpenXLS  = Open an existing file or create a new one
//    #$XLSWkSh  = Create a New Worksheet
//    #$XLSCWid  = Set Column Width
//    #$XLSChar  = add a character field to a Excel File
//    #$XLSNum   = add a value field to Excel file
//    #$XLSDate  = add a date field to Excel file
//    #$XLSForm  = add a formula field to a Excel File
//    #$XLSNext  = start a new row
//    #$CloseXLS = Close the open Excel File
Dcl-S #$XLSRowCnt zoned(9);
Dcl-S #$XLSCol zoned(5);
Dcl-S #$XLSPath char(1024);
Dcl-Pr #$XLSPathC char(1024) ExtProc;
  *n char(1024) const; // #$XLSName
End-Pr;
Dcl-Pr #$OpenXLS ExtProc;
  *n char(1024) const; // #$XLSName
End-Pr;
Dcl-Pr #$XLSWkSh ExtProc;
  *n char(124) const; // Sheet
  *n zoned(2) const options(*nopass); // FrRows
  *n zoned(2) const options(*nopass); // FrColumns
End-Pr;
Dcl-Pr #$XLSCWid ExtProc;
  *n zoned(5) const; // Column
  *n zoned(5) const; // Width
End-Pr;
Dcl-Pr #$XLSChar ExtProc;
  *n char(512) const; // #$XLSChar
  *n char(1) const options(*nopass); // PsBold
  *n char(1) const options(*nopass); // PsUnder
  *n char(1) const options(*nopass); // PsSize
  *n char(1) const options(*nopass); // PsJustify
  *n char(1) const options(*nopass); // PsItalic
  *n char(1) const options(*nopass); // PsWrap
End-Pr;
Dcl-Pr #$XLSNum ExtProc;
  *n zoned(30: 10) const; // Number
  *n zoned(1) const options(*nopass : *omit); // PsDecimals
  *n char(1) const options(*nopass); // PsCommas
  *n char(1) const options(*nopass); // PsBold
  *n char(1) const options(*nopass); // PsUnder
  *n char(1) const options(*nopass); // PsSize
  *n char(1) const options(*nopass); // PsJustify
  *n char(1) const options(*nopass); // PsItalic
End-Pr;
Dcl-Pr #$XLSDate ExtProc;
  *n zoned(8) const; // Date
  *n char(1) const options(*nopass); // PsBold
  *n char(1) const options(*nopass); // PsUnder
  *n char(1) const options(*nopass); // PsSize
  *n char(1) const options(*nopass); // PsJustify
  *n char(1) const options(*nopass); // PsItalic
End-Pr;
Dcl-Pr #$XLSform ExtProc;
  *n char(512) const; // #$Form
  *n char(1) const options(*nopass); // PsBold
  *n char(1) const options(*nopass); // PsUnder
  *n char(1) const options(*nopass); // PsSize
  *n char(1) const options(*nopass); // PsJustify
  *n char(1) const options(*nopass); // PsItalic
End-Pr;
Dcl-Pr #$XLSNext ExtProc end-pr;
Dcl-Pr #$CloseXLS ExtProc end-pr;


//  These function are used to create output Files in the IFS
//  The programmer designates the file type
//
//    #$OpenOut  = Open an existing file or create a new one
//    #$NewSheet = start a new sheet, ignored for csv file
//    #$AddChar  = add a character field to a file
//    #$AddNum   = add a value field to a file
//    #$AddNum0  = add a value field to a file - 0 DEC
//    #$AddNum2  = add a value field to a file - 2 DEC
//    #$AddDate  = add a date file to a file
//    #$AddForm  = add a formula field to a file
//    #$NextRec  = start a new record
//    #$CloseOut = Close the open File
Dcl-S #$OutFWidths packed(4) dim(100);
Dcl-S #$OutFPath char(1024);
Dcl-Pr #$OpenOut ExtProc;
  *n char(1024) const; // File
  *n char(3) const options(*nopass: *omit); // PType
  *n packed(4) dim(100) options(*nopass: *omit); // PWidths
  *n char(124) const options(*nopass: *omit); // PSheetName
  *n zoned(2) const options(*nopass: *omit); // PFrRows
  *n zoned(2) const options(*nopass: *omit); // PFrColumns
End-Pr;
Dcl-Pr #$NewSheet ExtProc;
  PSheetName Char(124) const options(*nopass: *omit);
  *n packed(4) dim(100) options(*nopass: *omit); // PWidths
  *n zoned(2) const options(*nopass: *omit); // PFrRows
  *n zoned(2) const options(*nopass: *omit); // PFrColumns
End-Pr;
Dcl-Pr #$AddChar ExtProc;
  *n char(512) const; // #$Char
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$AddNum ExtProc;
  *n zoned(20: 5) const; // #$Num
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$AddNum0 ExtProc;
  *n zoned(20: 5) const; // #$Num
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$AddNum2 ExtProc;
  *n zoned(20: 5) const; // #$Num
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$AddDate ExtProc;
  *n zoned(8) const; // #$Date
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$AddForm ExtProc;
  *n char(512) const; // #$Form
  *n char(2) const options(*nopass); // PsStyle
End-Pr;
Dcl-Pr #$NextRec ExtProc end-pr;
Dcl-Pr #$CloseOut ExtProc;
  *n char(1) const options(*nopass); // PsDupAut
End-Pr;
Dcl-Pr #$CrtPath char(1024) ExtProc;
  #$file Char(1024) CONST options(*nopass:*omit);
  #$type Char(4) CONST options(*nopass:*omit);
End-Pr;

