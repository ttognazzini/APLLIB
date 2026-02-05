**Free
Ctl-Opt indent('| ') debug Option(*SrcStmt:*NoDebugIO:*NoShowCpy) nomain;

// Create a PC file

// To Create this serice program:
//
// CRTRPGMOD MODULE(QTEMP/OUTFLEV1) SRCFILE(APLLIB/QSRC)
//           DBGVIEW(*ALL)
// CRTSRVPGM SRVPGM(APLLIB/OUTFLEV1) MODULE(QTEMP/OUTFLEV1)
//       TEXT('Create Report File in the IFS')
//       BNDSRVPGM((#$XLSX1.0/#$XLSX))
//       EXPORT(*SRCFILE) SRCFILE(APLLIB/QSRC) SRCMBR(OUTFLEN1)
// DLTMOD     MODULE(QTEMP/OUTFLEV1)

// This program merged 3 service programs into one program. The sections
// below list each one seperately. Each section has its own test program.


// ********************************************************************
//  These function are used to create output Files in the IFS
//
//  This system allows the outpuot type to be passed and provides a
//  common interface to create each file type.
//
//  See the test program OUTFLEB1 for examples.
//
//    #$OpenOut  = Open an existing file or create a new one
//    #$NewSheet = start a new sheet, ignored for csv file
//    #$AddChar  = add a character field to a csv file
//    #$AddNum   = add a value field to csv file
//    #$AddNum0  = add a value field to csv file - 0 DEC
//    #$AddNum2  = add a value field to csv file - 2 DEC
//    #$AddDate  = add a date file to csv file
//    #$AddForm  = add a Formula field to an Excel File
//    #$NextRec  = start a new record
//    #$CloseOut = Close the open CSV File
//    #$CrtPath  = Create a path to a file, optionlaly with a file name
//  See Example program #$OUTFTS for specifics
// ********************************************************************


// ********************************************************************
//  These function are used to create XML files in the IFS
//    the prototypes are stored in file #$proto
//
//  See program OUTFLEB2 for an example how to use them
//
//    #$XMLCPath = Create a default path
//    #$XMLNew   = Create a new XML file
//    #$XMLStyle = Create a style group
//    #$XMLWkSh  = Add a worksheet ot the XML file
//    #$XMLNwRw  = start a new row
//    #$XMLChar  = add a character field to a XML file
//    #$XMLNum   = add a value field to XML file
//    #$XMLDate  = add a date file to XML file
//    #$XMLClose = Close the open XML File
//
// ********************************************************************

// ********************************************************************
// These function are used to create CSV files in the IFS
//
//   #$CSVCPath = Create a default path
//   #$OpenCSV  = Open an existing file or create a new one
//   #$CSVChar  = add a character field to a csv file
//   #$CSVNum   = add a value field to csv file
//   #$CSVNum0  = add a value field to csv file - 0 DEC
//   #$CSVNum2  = add a value field to csv file - 2 DEC
//   #$CSVDate  = add a date field to csv file
//   #$CSVtRec  = start a new record
//   #$CloseCSV = Close the open CSV File
//
// See Example program #$csvts for specifics
//
// ********************************************************************


/Include QSRC,OUTFLEV1PR
/Include #$XLSX1.0/QRPGLESRC,#$XLSX_H

// Programm status DS
Dcl-Ds psds psds;
  psdsdata       Char(429); //The data
  // Retrieved exception data
  psdsExcDta     Char(80)   OVERLAY(PSDSDATA:091);
  User           Char(10)   OVERLAY(PSDSDATA:254);
End-Ds;

Dcl-S type Char(3);
Dcl-S Sheet packed(3);

// Open an IFS file
Dcl-Pr Open Int(10) EXTPROC( 'open' );
  filename       Pointer    VALUE;
  openflags      Int(10)    VALUE;
  mode           Uns(10)    VALUE OPTIONS( *NOPASS );
  codepage       Uns(10)    VALUE OPTIONS( *NOPASS );
End-Pr;

// Close an IFS file
Dcl-Pr Close Int(10) EXTPROC( 'close' );
  filehandle     Int(10)    VALUE;
End-Pr;

// Write to an IFS file
Dcl-Pr Write Int(10) EXTPROC( 'write' );
  filehhndle     Int(10)    VALUE;
  datatowrite    Pointer    VALUE;
  nbytes         Uns(10)    VALUE;
End-Pr;

// Constants for file access
// File Access Modes for open()
Dcl-S o_wronly     Int(10)    INZ( 2 );
Dcl-S o_rdwr       Int(10)    INZ( 4 );
// Oflag values for open()
Dcl-S o_creat      Int(10)    INZ( 8 );
Dcl-S o_trunc      Int(10)    INZ( 64 );
// File permissions
Dcl-S s_irwxu      Int(10)    INZ( 448 );
Dcl-S s_iroth      Int(10)    INZ( 4 );
// Misc
Dcl-S o_textdata   Int(10)    INZ( 16777216 );
Dcl-S o_codepage   Int(10)    INZ( 8388608 );

// Miscellaneous data declarations
Dcl-S asciicodepage Uns(10)    INZ(367);
Dcl-S null         Char(1)    INZ( X'00' );
Dcl-S fullname     Char(512);
Dcl-S i            Int(10);
Dcl-S x            Packed(5:0);
Dcl-S eor          Char(2)    INZ( X'0D25' );
Dcl-S cr           Char(1)    INZ( X'0D' );
Dcl-S l            Char(1024);
Dcl-S returnint    Int(10);


// buffer used for CSV file creation
Dcl-C BUFFERSIZE 1000000;
Dcl-S buffer varchar(BUFFERSIZE);


// #$OpenOut - Open an existing file or create a new one.
//     input = File Name
//           = Optional, Type (XLS,CSV,XML) Default XLS
//           = Optional, Widths, column Widths in characters
//           = Optional, Sheet Name, Default 'Sheet 1'
//           = Optional, Freeze Rows, default 0, freezes number of rows at top
//           = Optional, Freeze Columns, default 0, freezes number of columns on left
Dcl-Proc #$OpenOut export;
  Dcl-Pi #$OpenOut;
    pFile Char(1024) const;
    pType Char(3) const options(*nopass: *omit);
    pWidths packed(4) dim(100) options(*nopass: *omit);
    pSheetName Char(124) const options(*nopass: *omit);
    pFrRows zoned(2) const options(*nopass: *omit);
    pFrColumns zoned(2) const options(*nopass: *omit);
  End-Pi;
  Dcl-S File Char(1024);
  Dcl-S SheetName Char(124) Inz('Sheet 1');
  Dcl-S Widths packed(4) dim(100);
  Dcl-S FrRows zoned(2) Inz(0);
  Dcl-S FrColumns zoned(2) Inz(0);
  Dcl-S x packed(4);

  File = pFile;

  If %parms>=2 and %addr(pType) <> *null;
    type = pType;
  Else;
    type = 'XLS';
  EndIf;

  If %parms>=3 and %addr(pWidths) <> *null;
    Widths = pWidths;
  EndIf;

  If %parms>=4 and %addr(pSheetName) <> *null;
    SheetName = pSheetName;
  EndIf;

  If %parms>=5 and %addr(pFrRows) <> *null;
    FrRows = pFrRows;
  EndIf;

  If %parms>=6 and %addr(pFrColumns) <> *null;
    FrColumns = pFrColumns;
  EndIf;

  type = %upper(type);

  // The CSS outO system passes the type as *XLSX, *XML, or *CSV, we are only receiving the first,
  // 3 chars, map those to the new type
  If type = '*XL';
    type = 'XLS';
  ElseIf type = '*XM';
    type = 'XML';
  ElseIf type = '*CS';
    type = 'CSV';
  EndIf;

  // If the file name does have the correct extension, add it
  If type='XML' and %upper(#$Last(File:4)) <> '.XML';
    File=%trim(File)+'.xml';
  EndIf;
  If type='CSV' and %upper(#$Last(File:4)) <> '.CSV';
    File=%trim(File)+'.csv';
  EndIf;
  If type='XLS' and %upper(#$Last(File:5)) <> '.XLSX';
    File=%trim(File)+'.xlsx';
  EndIf;


  // Prepare the correct file format
  If (type = 'CSV');
    #$OpenCSV(File);

    // Create XML file, open it, Setup Default Styles, set Column Widths, add a sheet
  ElseIf (type='XML');
    #$XMLOpen(File);
    // C = CompanyLine, Calibri, Size 16, Color-Black, Bold
    #$XMLStyle('C':'0':'0':'0':'0':'Calibri':'16':'#000000':'1');
    // T = Title, Calibri, Size 14, Color-Black, Bold
    #$XMLStyle('T':'0':'0':'0':'0':'Calibri':'14':'#000000':'1');
    // H = Header, Bottom-Border, Calibri, Size 12, Color-Black, Bold
    #$XMLStyle('H':'0':'1':'0':'0':'Calibri':'12':'#000000':'1');
    // HR = Header, Bottom-Border, Calibri, Size 12, Color-Black, Bold
    #$XMLStyle('HR':'0':'1':'0':'0':'Calibri':'12':'#000000':'1'
                                                      :' ':' ':'R');
    // B = Bold, Calibri, Size 11, Color-Black, Bold
    #$XMLStyle('B':'0':'0':'0':'0':'Calibri':'11':'#000000':'1');
    // BU = Bold Underline, Calibri, Size 11, Color-Black, Bold
    #$XMLStyle('BU':'0':'1':'0':'0':'Calibri':'11':'#000000':'1');
    // BR = Bold Right: Calibri, Size 11, Color-Black, Bold, Right Justified
    #$XMLStyle('BR':'0':'0':'0':'0':'Calibri':'11':'#000000':'1'
                                                      :' ':' ':'R');
    // U = Underline, Calibri, Size 12, Color-Black,
    #$XMLStyle('U':'0':'1':'0':'0':'Calibri':'11':'#000000');

    // Set Column widths
    #$XMLWsDs.#$XMLWIDTH  = Widths * 6;
    // add a New Worksheet
    #$XMLWkSh('Sheet 1':#$XMLWsDs);
    // Start First Row
    #$XMLNwRw();

  ElseIf (type='XLS');
    #$XLSXOpen('OutputName:' + %trim(File));
    #$XLSXWkSh('SheetName:' + %trim(SheetName)
             : 'FreezeRows:' + %char(FrRows)
             : 'FreezeColumns:' + %char(FrColumns) );
    // Set Column widths
    For x=1 by 1 To 100;
      If (Widths(x))<>0;
        #$XLSXWkSh('COLUMNWIDTH:'+%char(x)+':'+%char(Widths(x)));
      EndIf;
    EndFor;
    // setup styles
    // Char     2Decimals  Date     Description
    // S_D      S2_D       SD_D     Default
    // S_C      S2_C       SD_C     Company
    // S_T      S2_T       SD_T     Title
    // S_H      S2_H       SD_H     Header
    // S_HR     S2_HR      SD_HR    Header Right
    // S_B      S2_B       SD_B     Bold Regular
    // S_BR     S2_BR      SD_BR    Bold Right
    // S_BU     S2_BU      SD_BU    Bold Underline
    // S_U      S2_U       SD_U     Underline
    // S_UR     S2_UR      SD_UR    Underline Right
    #$XLSXStyle('Name:S_D':'PointSize:11' : 'VerticalAlignment:TOP');
    #$XLSXStyle('Name:S_C':'PointSize:16'
              : 'VerticalAlignment:TOP':'BoldWeight:BOLD');
    #$XLSXStyle('Name:S_T':'PointSize:14'
              : 'VerticalAlignment:TOP':'BoldWeight:BOLD');
    #$XLSXStyle('Name:S_H':'PointSize:12'
             : 'WrapText:YES':'VerticalAlignment:BOTTOM'
             : 'BoldWeight:BOLD':'BorderBottom:THIN');
    #$XLSXStyle('Name:S_HR':'PointSize:12'
              : 'WrapText:YES':'Alignment:RIGHT'
              :'VerticalAlignment:BOTTOM':'BoldWeight:BOLD'
              : 'Alignment:RIGHT':'BorderBottom:THIN');
    #$XLSXStyle('Name:S_B':'PointSize:11'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD');
    #$XLSXStyle('Name:S_BR':'PointSize:11'
              : 'VerticalAlignment:TOP'
              : 'BoldWeight:BOLD':'Alignment:RIGHT');
    #$XLSXStyle('Name:S_BU':'PointSize:11'
              : 'VerticalAlignment:TOP'
              : 'BoldWeight:BOLD':'BorderBottom:THIN');
    #$XLSXStyle('Name:S_U':'PointSize:11'
              : 'WrapText:YES':'VerticalAlignment:TOP'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:S_UR':'PointSize:11'
              : 'VerticalAlignment:TOP'
              : 'WrapText:YES':'Alignment:RIGHT'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:S2_D':'PointSize:11'
              : 'DataFormat:#,##0.00':'VerticalAlignment:TOP');
    #$XLSXStyle('Name:S2_C':'PointSize:16'
              : 'DataFormat:#,##0.00':'VerticalAlignment:TOP'
              : 'BoldWeight:BOLD');
    #$XLSXStyle('Name:S2_T':'PointSize:14'
              : 'DataFormat:#,##0.00':'VerticalAlignment:TOP'
              : 'BoldWeight:BOLD');
    #$XLSXStyle('Name:S2_H': 'PointSize:12'
              : 'DataFormat:#,##0.00': 'WrapText:YES'
              : 'VerticalAlignment:BOTTOM'
              : 'BoldWeight:BOLD':'BorderBottom:THIN');
    #$XLSXStyle('Name:S2_HR': 'PointSize:12'
              : 'DataFormat:#,##0.00': 'WrapText:YES'
              : 'Alignment:RIGHT': 'VerticalAlignment:BOTTOM'
              : 'BoldWeight:BOLD': 'Alignment:RIGHT'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:S2_B': 'PointSize:11'
              : 'DataFormat:#,##0.00'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD');
    #$XLSXStyle('Name:S2_BR': 'PointSize:11'
              : 'DataFormat:#,##0.00'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD'
              : 'Alignment:RIGHT');
    #$XLSXStyle('Name:S2_BU': 'PointSize:11'
              : 'DataFormat:#,##0.00'
              : 'VerticalAlignment:TOP'
              : 'BoldWeight:BOLD': 'BorderBottom:THIN');
    #$XLSXStyle('Name:S2_U': 'PointSize:11'
              : 'DataFormat:#,##0.00': 'WrapText:YES'
              : 'VerticalAlignment:TOP': 'BorderBottom:THIN');
    #$XLSXStyle('Name:S2_UR': 'PointSize:11'
              : 'DataFormat:#,##0.00': 'WrapText:YES'
              : 'VerticalAlignment:TOP'
              : 'Alignment:RIGHT':'BorderBottom:THIN');
    #$XLSXStyle('Name:SD_D': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP');
    #$XLSXStyle('Name:SD_C': 'PointSize:16'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD');
    #$XLSXStyle('Name:SD_T': 'PointSize:14'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD');
    #$XLSXStyle('Name:SD_H': 'PointSize:12'
              : 'DataFormat:yyyy/mm/dd'
              : 'WrapText:YES': 'VerticalAlignment:BOTTOM'
              : 'BoldWeight:BOLD': 'BorderBottom:THIN');
    #$XLSXStyle('Name:SD_HR': 'PointSize:12'
              : 'DataFormat:yyyy/mm/dd': 'WrapText:YES'
              : 'Alignment:RIGHT': 'VerticalAlignment:BOTTOM'
              : 'BoldWeight:BOLD': 'Alignment:RIGHT'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:SD_B': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD');
    #$XLSXStyle('Name:SD_BR': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD'
              : 'Alignment:RIGHT');
    #$XLSXStyle('Name:SD_BU': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd'
              : 'VerticalAlignment:TOP': 'BoldWeight:BOLD'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:SD_U': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd': 'WrapText:YES'
              : 'VerticalAlignment:TOP'
              : 'BorderBottom:THIN');
    #$XLSXStyle('Name:SD_UR': 'PointSize:11'
              : 'DataFormat:yyyy/mm/dd': 'WrapText:YES'
              : 'VerticalAlignment:TOP'
              : 'Alignment:RIGHT': 'BorderBottom:THIN');
  EndIf;

  // Save the file path to use in closeout
  #$OutFPath=File;

  // set number of sheets to 1, if another is added this will be incremented
  Sheet = 1;

End-Proc;


// #$NewSheet - Start a new sheet in the file, ignored for CSV
//     input = Optional, Sheet Name, Default 'Sheet XXX'
Dcl-Proc #$NewSheet export;
  Dcl-Pi #$NewSheet;
    pSheetName Char(124) const options(*nopass: *omit);
    pWidths packed(4) dim(100) options(*nopass: *omit);
    pFrRows zoned(2) const options(*nopass: *omit);
    pFrColumns zoned(2) const options(*nopass: *omit);
  End-Pi;
  Dcl-S SheetName Char(124) Inz('Sheet 1');
  Dcl-S Widths packed(4) dim(100);
  Dcl-S FrRows zoned(2) Inz(0);
  Dcl-S FrColumns zoned(2) Inz(0);
  Dcl-S x packed(4);

  // Increment number of sheets
  Sheet += 1;

  If %parms>=1 and %addr(pSheetName) <> *null;
    SheetName = pSheetName;
  Else;
    SheetName = 'Sheet' + %char(Sheet);
  EndIf;

  If %parms>=2 and %addr(pWidths) <> *null;
    Widths = pWidths;
  EndIf;

  If %parms>=3 and %addr(pFrRows) <> *null;
    FrRows = pFrRows;
  EndIf;

  If %parms>=4 and %addr(pFrColumns) <> *null;
    FrColumns = pFrColumns;
  EndIf;

  // Start a new sheet for the specified file type
  If (type='CSV');
    #$CSVNext();
    #$CSVNext();
  ElseIf (type='XML');
    #$XMLWkSh(%trim(SheetName):#$XMLWsDs);
    // Start First Row
    #$XMLNwRw();
  ElseIf (type='XLS');
    #$XLSXWkSh('SheetName:' + %trim(SheetName)
             : 'FreezeRows:' + %char(FrRows)
             : 'FreezeColumns:' + %char(FrColumns) );
    // Set Column widths
    For x=1 by 1 To 100;
      If (Widths(x))<>0;
        #$XLSXWkSh('COLUMNWIDTH:'+%char(x)+':'+%char(Widths(x)));
      EndIf;
    EndFor;
  EndIf;

End-Proc;


// #$AddChar - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//             style = Optional
//     style Codes  Description
//                  Default          Size 11
//        C         Company          Size 16, bold
//        T         Title            Size 14, bold
//        H         Header           Size 12, Bold, Bottom Border
//        HR        Header Right     Size 12, Bold, Bottom Border, Right Justified
//        B         Bold Regular     Size 11, Bold
//        BR        Bold Right       Size 11, Bold, Right Justified
//        BU        Bold Underline   Size 11, Bold, Bottom Border
//        U         Underline        Size 11, Bottom Border
//        UR        Underline Right  Size 11, Bottom Border
Dcl-Proc #$AddChar export;
  Dcl-Pi #$AddChar;
    Char Char(512) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);

  If %parms()>=2;
    Style = PsStyle;
  EndIf;

  If (type='CSV');
    #$CSVChar(Char);
  EndIf;

  If (type='XML');
    If (Style<>' ');
      #$XMLChar(Char:Style);
    Else;
      #$XMLChar(Char);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When %trim(Char)='' and Style=' ';
        #$XLSXNull();
      When Style='C';
        #$XLSXChar(Char:'S_C');
      When Style='T';
        #$XLSXChar(Char:'S_T');
      When Style='H';
        #$XLSXChar(Char:'S_H');
      When Style='HR';
        #$XLSXChar(Char:'S_HR');
      When Style='B';
        #$XLSXChar(Char:'S_B');
      When Style='BR';
        #$XLSXChar(Char:'S_BR');
      When Style='BU';
        #$XLSXChar(Char:'S_BU');
      When Style='U ';
        #$XLSXChar(Char:'S_U');
      When Style='UR';
        #$XLSXChar(Char:'S_UR');
      Other;
        #$XLSXChar(Char:'S_D');
    endsl;
  EndIf;

End-Proc;


// #$AddNum - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$AddNum(123.45)
Dcl-Proc #$AddNum export;
  Dcl-Pi #$AddNum;
    #$Num zoned(20: 5) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);
  If %parms>=2;
    Style = PsStyle;
  EndIf;

  If (type='CSV');
    #$CSVNUM(#$Num);
  EndIf;

  // Create path for XML files if needed
  If (type='XML');
    If (Style<>' ');
      #$XMLNum(#$Num:Style);
    Else;
      #$XMLNum(#$Num);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When Style='C';
        #$XLSXNumr(#$Num:'S_C');
      When Style='T';
        #$XLSXNumr(#$Num:'S_T');
      When Style='H';
        #$XLSXNumr(#$Num:'S_H');
      When Style='HR';
        #$XLSXNumr(#$Num:'S_HR');
      When Style='B';
        #$XLSXNumr(#$Num:'S_B');
      When Style='BR';
        #$XLSXNumr(#$Num:'S_BR');
      Other;
        #$XLSXNumr(#$Num:'S_D');
    endsl;
  EndIf;

End-Proc;


// #$AddNum0 - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$AddNum0(123)
Dcl-Proc #$AddNum0 export;
  Dcl-Pi #$AddNum0;
    #$Num zoned(20: 5) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);

  If %parms>=2;
    Style = PsStyle;
  EndIf;

  If (type='CSV');
    #$CSVNUM0(#$Num);
  EndIf;

  If (type='XML');
    If (Style<>' ');
      #$XMLNum(#$Num:Style);
    Else;
      #$XMLNum(#$Num);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When Style='C';
        #$XLSXNumr(#$Num:'S_C');
      When Style='T';
        #$XLSXNumr(#$Num:'S_T');
      When Style='H';
        #$XLSXNumr(#$Num:'S_H');
      When Style='HR';
        #$XLSXNumr(#$Num:'S_HR');
      When Style='B';
        #$XLSXNumr(#$Num:'S_B');
      When Style='BR';
        #$XLSXNumr(#$Num:'S_BR');
      Other;
        #$XLSXNumr(#$Num:'S_D');
    endsl;
  EndIf;


End-Proc;

// #$AddNum2 - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$AddNum2(123.45)
Dcl-Proc #$AddNum2 export;
  Dcl-Pi #$AddNum2;
    #$Num zoned(20: 5) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);

  If %parms>=2;
    Style = PsStyle;
  EndIf;

  If (type='CSV');
    #$CSVNUM2(#$Num);
  EndIf;

  If (type='XML');
    If (Style<>' ');
      #$XMLNum(#$Num:Style);
    Else;
      #$XMLNum(#$Num);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When Style='C';
        #$XLSXNumr(#$Num:'S2_C');
      When Style='T';
        #$XLSXNumr(#$Num:'S2_T');
      When Style='H';
        #$XLSXNumr(#$Num:'S2_H');
      When Style='HR';
        #$XLSXNumr(#$Num:'S2_HR');
      When Style='B';
        #$XLSXNumr(#$Num:'S2_B');
      When Style='BR';
        #$XLSXNumr(#$Num:'S2_BR');
      Other;
        #$XLSXNumr(#$Num:'S2_D');
    endsl;
  EndIf;

End-Proc;


// #$AddDate - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$AddNum(123.45)
Dcl-Proc #$AddDate export;
  Dcl-Pi #$AddDate;
    #$Date zoned(8) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);
  Dcl-S date zoned(8);

  date = #$Date;
  If %parms >= 2;
    Style = PsStyle;
  EndIf;

  // if a 6 digit date is passed, convert it to an 8 digit date
  If date < 1000000;
    If %rem(date:100) < 50;
      date = 20000000 + %rem(date:100) * 10000 + %int(date/100);
    Else;
      date = 19000000 + %rem(date:100) * 10000 + %int(date/100);
    EndIf;
  EndIf;

  If (type='CSV');
    #$CSVDate(date);
  EndIf;

  If (type='XML');
    If (Style<>' ');
      #$XMLDate(date:Style);
    Else;
      #$XMLDate(date);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When Style='C';
        #$XLSXYYMD(date:'SD_C');
      When Style='T';
        #$XLSXYYMD(date:'SD_T');
      When Style='H';
        #$XLSXYYMD(date:'SD_H');
      When Style='HR';
        #$XLSXYYMD(date:'SD_HR');
      When Style='B';
        #$XLSXYYMD(date:'SD_B');
      When Style='BR';
        #$XLSXYYMD(date:'SD_BR');
      Other;
        #$XLSXYYMD(date:'SD_D');
    endsl;
  EndIf;

End-Proc;


// #$AddForm - Add a formula string to the open file
//     input = #$CSVForm = Field containing the formula
//             style = Optional
//     style Codes  Description
//                  Default          Size 11
//        C         Company          Size 16, bold
//        T         Title            Size 14, bold
//        H         Header           Size 12, Bold, Bottom Border
//        HR        Header Right     Size 12, Bold, Bottom Border, Right Justified
//        B         Bold Regular     Size 11, Bold
//        BR        Bold Right       Size 11, Bold, Right Justified
//        BU        Bold Underline   Size 11, Bold, Bottom Border
//        U         Underline        Size 11, Bottom Border
//        UR        Underline Right  Size 11, Bottom Border
Dcl-Proc #$AddForm export;
  Dcl-Pi *n;
    Form Char(512) const;
    PsStyle Char(2) const options(*nopass);
  End-Pi;
  Dcl-S Style Char(2);

  If %parms()>=2;
    Style = PsStyle;
  EndIf;

  If (type='CSV');
    #$CSVChar(Form);
  EndIf;

  If (type='XML');
    If (Style<>' ');
      #$XMLChar(Form:Style);
    Else;
      #$XMLChar(Form);
    EndIf;
  EndIf;

  If (type='XLS');
    Select;
      When Style='C';
        #$XLSXform(Form:'S_C');
      When Style='T';
        #$XLSXform(Form:'S_T');
      When Style='H';
        #$XLSXform(Form:'S_H');
      When Style='HR';
        #$XLSXform(Form:'S_HR');
      When Style='B';
        #$XLSXform(Form:'S_B');
      When Style='BR';
        #$XLSXform(Form:'S_BR');
      When Style='BU';
        #$XLSXform(Form:'S_BU');
      When Style='U ';
        #$XLSXform(Form:'S_U');
      When Style='UR';
        #$XLSXform(Form:'S_UR');
      Other;
        #$XLSXform(Form:'S_D');
    endsl;
  EndIf;

End-Proc;


// #$NextRec - Write a line to the open CSV file and start the next
//             record
Dcl-Proc #$NextRec export;
  Dcl-Pi #$NextRec End-Pi;


  If (type='CSV');
    #$CSVNext();
  EndIf;

  If (type='XML');
    #$XMLNwRw();
  EndIf;

  If (type='XLS');
    #$XLSXNext();
  EndIf;

End-Proc;


// #$CloseCSV - Close an Existing open file
//     input = #$CSVFile = file name in the IFS
//                Example: \CSS\Output.csv
Dcl-Proc #$CloseOut export;
  Dcl-Pi #$CloseOut;
    PsDupAut Char(1) const options(*nopass);
  End-Pi;
  Dcl-S DupAut Char(1) Inz('Y');
  Dcl-S Cmd Char(512);

  If %parms>=1;
    DupAut = PsDupAut;
  EndIf;

  If DupAut<>'N';
    DupAut = 'Y';
  EndIf;

  If (type='CSV');
    #$CloseCSV();
  EndIf;

  If (type='XML');
    #$XMLClose();
  EndIf;

  If (type='XLS');
    #$XLSXClose();
  EndIf;

  // if the option to duplciate the parent folders permissions
  // is selected, do that here
  If DupAut='Y';
    Cmd='DUPAUT ''' + %trim(#$OutFPath) + '''';
    Monitor;
      #$Cmd(Cmd:2);
    On-Error;
      #$SndMsg('AUTHORITIES NOT DUPLICATED');
    EndMon;
  EndIf;

End-Proc;


// #$cmd - run a command
// This proceudre runs a command. Errors are displayed in a
// window or ignored.

//   Input: #$CMD = Command to run.
//          #$NOE = Optional, Ignore Errors (Pass a 1)
//   Output: nothing
Dcl-Proc #$Cmd;
  Dcl-Pi *n;
    #$Cmd Varchar(32768) Value;
    PSNOE zoned(1) const options(*nopass : *omit);
  End-Pi;
  Dcl-S #$LEN packed(15: 5);
  Dcl-S #$NOE packed(15: 5);
  // prototype for qcmdexc
  Dcl-Pr CMD extpgm('QCMDEXC');
    *n Char(32768) const; // command
    *n packed(15: 5) const; // length
  End-Pr;

  // use noe if passed otherwise default it to 0
  If %parms() > 1 and %addr(PSNOE)<>*NULL;
    #$NOE=PSNOE;
  Else;
    #$NOE=0;
  EndIf;

  #$LEN=%len(%trim(#$Cmd));

  If #$NOE=2;
    CMD(%trim(#$Cmd):#$LEN);
  Else;
    Monitor;
      CMD(%trim(#$Cmd):#$LEN);
    On-Error;
      If #$NOE<>1;
        #$DSPWIN(psdsExcDta);
      EndIf;
    EndMon;
  EndIf;

End-Proc;


// #$SNDMSG - Send Message
// Procedure to send a message.
//  INPUT: MESSAGE = The message text to send.
//         TYPE    = The type of message, options are:
//                   *COMP    - Completion
//                   *DIAG    - Diagnostic
//                   *ESCAPE  - Escape
//                   *INFO    - Informational, Default
//                   *INQ     - Inquiry. (Only used when
//                              ToPgmQ(*EXT) is specified).
//                   *NOTIFY  - Notify
//                   *RQS     - Request
//                   *STATUS  - Status
//         TOPGMQ  = Message Queue/Level, This option allows
//                   the message to be sent to the calling
//                   programs message queue. This is optional,
//                   the default is *PRV. Options:
//                   *       = The message goes to the queue
//                             for program running the
//                             #$SNDMSG procedure.
//                   *PRV    = The message goes to the queue
//                             for one procedure level up in
//                             the call stack.
//                   *PRVPGM = The message goes to the queue
//                             for one program level up in
//                             the call stack.
//                   *EXT    = The external message queue,
//                             generally displayed on the users
//                             screen if in an interactive pgm.
//                   *CTLBDY = Control Boundary
Dcl-Proc #$SndMsg;
  Dcl-Pi *n;
    MSG Varchar(1024) const;
    PSMSGTYPE Char(10) const options(*nopass);
    PSTOPGMQ Char(10) const options(*nopass);
  End-Pi;

  Dcl-Ds QUSEC; // qusec
    QUSBPRV int(10) pos(1); // Bytes Provided
    QUSBAVL int(10) pos(5); // Bytes Available
    QUSEI Char(7) pos(9); // Exception Id
    QUSERVED Char(1) pos(16); // Reserved
  End-Ds;

  Dcl-Ds QUSC0200; // Qus ERRC0200
    QUSK01 int(10) pos(1); // Key
    QUSBPRV00 int(10) pos(5); // Bytes Provided
    QUSBAVL14 int(10) pos(9); // Bytes Available
    QUSEI00 Char(7) pos(13); // Exception Id
    QUSERVED39 Char(1) pos(20); // Reserved
    QUSCCSID11 int(10) pos(21); // ccsid
    QUSOED01 int(10) pos(25); // Offset Exc Data
    QUSLED01 int(10) pos(29); // Length Exc Data
  End-Ds;

  // Local variables.
  Dcl-S msgType like(PSMSGTYPE);
  Dcl-S toPgmQ like(PSTOPGMQ);
  Dcl-S msgid Char(7) Inz('CPF9897');

  Dcl-Ds msgf len(21);
    MsgFile Char(10) Inz('QCPFMSG');
    MsgLib Char(10) Inz('*LIBL');
  End-Ds;

  Dcl-S nRelInv int(10) Inz(2);
  Dcl-S RtnMsgKey Char(4);

  Dcl-Ds myAPIErrorDS likeds(QUSEC);

  // prototype for ibm send message api
  Dcl-Pr QMHSNDPM extpgm('QMHSNDPM');
    *n Char(7) const; // szMsgID
    *n Char(20) const; // szMsgFile
    *n Char(6000) const options(*varsize); // szMsgData
    //   Message Type may be one of the following:
    //   *COMP    - Completion
    //   *DIAG    - Diagnostic
    //   *ESCAPE  - Escape
    //   *INFO    - Informational
    //   *INQ     - Inquiry.
    //              (Only used when ToPgmQ(*EXT) is specified).
    //   *NOTIFY  - Notify
    //   *RQS     - Request
    //   *STATUS  - Status
    *n int(10) const; // nMsgDataLen
    //   Call Stack Entry may be one of the following:
    //   *        - *same
    //   *EXT     - The external message queue
    //   *CTLBDY  - Control Boundary
    *n Char(10) const; // psmsgtype
    *n Char(10) const; // szCallStkEntry
    *n int(10) const; // nRelativeCallStkEntr
    *n Char(4); // szRtnMsgKey
    *n likeds(QUSEC) options(*varsize); // apiErrorDS
  End-Pr;

  myAPIErrorDS = *ALLX'00';

  // set message type
  msgType='*INFO';
  If %parms()>=2;
    msgType = PSMSGTYPE;
    If %subst(msgType:1:1)<>'*';
      msgType = '*' + %triml(msgType);
    EndIf;
  EndIf;

  If msgType = '*';
    msgType = '*INFO';
  EndIf;

  // set to program queue
  toPgmQ='*PRV';
  If %parms()>= 3;
    If PSTOPGMQ <> *BLANKS;
      toPgmQ=  PSTOPGMQ;
    EndIf;
  EndIf;

  If toPgmQ = '*SAME';
    toPgmQ = '*';
  EndIf;

  // status messages always go topgmq(*ext)
  If msgType = '*STATUS';
    toPgmQ = '*EXT';
  EndIf;

  // nrelinv tells the message to go up that many
  // entries in the call stack and go to that entries
  // message queue. it is defaulted to 1 to go to the
  // program calling #$sndmsg. the following moves it
  // up in the call stacked based on the passed parameters.
  Select;
      // *same
    When toPgmQ  = ' '
        or toPgmQ = '*SAME'
        or toPgmQ = '*';
      toPgmQ = '*';
      nRelInv = 2;
      // *prvpgm
    When toPgmQ = '*PRVPGM';
      toPgmQ = '*CTLBDY';
      nRelInv = 2;
      // *ctlbdy
    When toPgmQ = '*CTLBDY';
      nRelInv = 3;
      // *ext
    When toPgmQ = '*EXT';
      nRelInv = 2;
      // *prv or anything else
    OTHER;
      toPgmQ = '*';
      nRelInv = 3;
  ENDSL;

  CALLP(E) QMHSNDPM(msgid   : msgf :
      %trim(MSG): %len(%trim(MSG)) :
      msgType   :
      toPgmQ    :
      nRelInv   :
      RtnMsgKey :
      myAPIErrorDS);

  Return;

End-Proc;


// #$DspWin - Display Text in a Window
// This procedure displays some text in a window.
// It has options for all numberic or allow loeading and
// trailing spaces.

//   Input: #$TEXT    = Character value to display
//          #$MSGID   = Optional, Used as the title if you
//                      have a message id.
//          #$MSGFILE = Optional, message file name.
//   Output Displays a window with the text in it.

//   #$dspwin('some text')
Dcl-Proc #$DSPWIN;
  Dcl-Pi *n;
    #$TEXT Char(8192) const;
    #$MSGID Char(7) const options(*nopass : *omit);
    #$MSGFILE Char(21) const options(*nopass : *omit);
  End-Pi;

  Dcl-Ds MYAPIERROR;
    dsECBytesP int(10) Inz(256) pos(1);  //  Bytes Provided (size of struct)
    dsECBytesA int(10) Inz(0) pos(5);  // Bytes Available (returned by API)
    dsECMsgID Char(7) pos(9);  // Msg ID of Error Msg Returned
    dsECReserv Char(1) pos(16); // Reserved
    dsECMsgDta Char(240) pos(17);  // Msg Data of Error Msg Returned
  End-Ds;
  Dcl-Pr QUILNGTX extpgm('QUILNGTX');
    *n Char(8192) const; // text
    *n int(10) const; // len
    *n Char(7) const; // msgid
    *n Char(21) const; // msgfile
    *n like(MYAPIERROR); // apierror
  End-Pr;
  Dcl-S MSGID like(#$MSGID);
  Dcl-S MSGFILE like(#$MSGFILE);

  If %parms = 1;
    MSGID = ' ';
    MSGFILE = ' ';
  ElseIf %parms = 2;
    MSGID = #$MSGID;
    MSGFILE = 'QCPFMSG';
  ElseIf %parms = 3;
    MSGID = #$MSGID;
    MSGFILE = #$MSGFILE;
  EndIf ;

  QUILNGTX ( #$TEXT
           : %len(#$TEXT)
           : MSGID
           : MSGFILE
           : MYAPIERROR
           );

End-Proc;


// #$last - returns the last characters from a string
// This procedure returns the last characters from a string.
// You must specify the number of characters to return.
//
//   Input: #$STRING = The character string.
//          #$CHARS  = The number of characters to return
//   Output: the characters from the string
//
//   Examples
//    #$LAST('/tog/test.pdf':4) = '.pdf'
Dcl-Proc #$Last;
  Dcl-Pi *n Varchar(99);
    #$String Varchar(2048) const;
    #$Chars packed(2) const;
  End-Pi;

  // if the number of character is 0 or less return blanks
  If #$CHARS<=0;
    Return ' ';
  EndIf;

  // if the length is greater than the string length return the full field
  If %len(%trim(#$String))<=#$Chars;
    Return %trim(#$String);
  EndIf;

  // return the last number of characters
  Return %subst(%trim(#$String):(%len(%trim(#$String))-#$Chars+1):#$Chars);

End-Proc;


// #$CrtPath - Creates a CSS default path, uses temp folder
//             \email\tmp + #$File + '.csv'
//             if #$file is blanks, returns unique control number
//
//     input = #$File = Optional, file name in the IFS
//
//  Examples    Input               Output
//              OutputFile:CVS      /email/tmp/OutputFile.csv
//              OutputFile:XLS      /email/tmp/OutputFile.xlsx
//              OutputFile:XLSX     /email/tmp/OutputFile.xlsx
//              OutputFile:xml      //email/tmp/OutputFile.xml
//              OutputFile.csv      /email/tmp/OutputFile.csv
//                                  /email/tmp/00012342.csv
//              *omit:pdf           /email/tmp/00012342.pdf
//              \                   /00012342.csv
//              \css\               /css/00012342.csv
//              test.csv            /email/tmp/test.csv
//              \test.csv           /test.csv
//              \css\test.csv       /css/test.csv
Dcl-Proc #$CrtPath export;
  Dcl-Pi #$CrtPath char(1024);
    #$file Char(1024) CONST options(*nopass:*omit);
    #$type Char(4) CONST options(*nopass:*omit);
  End-Pi;
  Dcl-S file Char(1024);
  Dcl-S path Char(1024);

  // If a file is passed use it, otherwise careate a unique file name
  If %parms() >= 1 and %addr(#$file) <> *null;
    file = #$file;
  Else;
    file = %trim(user) + '-' + %char(%timestamp());
  EndIf;

  path = '/email/tmp/' + %trim(file);

  // If a type is passed, add the file extension
  If %parms >= 2 and %addr(#$type) <> *null;
    If %upper(#$type) = 'CSV';
      path = %trim(path) + '.csv';
    ElseIf %upper(#$type) = 'XML';
      path = %trim(path) + '.xml';
    ElseIf %upper(#$type) = 'XLS' or %upper(#$type) = 'XLSX';
      path = %trim(path) + '.xlsx';
    EndIf;
  EndIf;

  Return path;

End-Proc;


// *****************************************************************************
// Start of old #$XML service program

// #$XMLCPath - Creates a CSS default path, uses temp folder
//             \sndmimeml\temp + #$File + '.xml'
//             if #$fileis blanks, returns unique control number
//     input = #$File = file name in the IFS
//  Examples    Input               Output
//              OutputFile          /sndmimeml/temp/OutputFile.xml
//              OutputFile.xml      /sndmimeml/temp/OutputFile.xml
//                                  /sndmimeml/temp/00012342.xml
//              \                   /00012342.xml
//              \css\               /css/00012342.xml
//              test.xml            /sndmimeml/temp/test.xml
//              \test.xml           /test.xml
//              \css\test.xml       /css/test.xml
Dcl-Proc #$XMLCPath EXPORT;
  Dcl-Pi #$XMLCPath Char(1024);
    #$File         Char(1024) CONST;
  End-Pi;
  Dcl-S File         Char(1024);
  Dcl-S Path         Char(1024);
  Dcl-S Name         Char(1024);
  Dcl-S FileExt      Char(1024);
  Dcl-S Last         Zoned(5:0);
  Dcl-S #$NXTNBR     Packed(8:0);

  Dcl-Pr Program_1  EXTPGM('#$CSVNX');
    #$NXTNBR       Packed(8:0);
  End-Pr;


  // Convert any \ to /
  File = %xlate('\':'/':#$File);

  // Find last occurance of /
  Last = 0;
  x = 1;
  DoW %scan('/':File:x) <> 0;
    Last = %scan('/':File:x);
    x = Last + 1;
  EndDo;

  // Get path
  If Last = 0;
    Path = '/sndmimeml/temp/';
  Else;
    Path = %subst(File :1  : Last);
  EndIf;

  // Get File
  If Last = 0;
    Name = File;
  Else;
    Name = %subst(File : Last+1 : 1024-Last);
  EndIf;

  // if name = blanks generate unique number
  If Name = ' ';
    callp Program_1(#$NXTNBR);
    Name = %char(#$NXTNBR);
  EndIf;

  // Find last occurance of .
  Last = 0;
  x = 1;
  DoW %scan('.':Name:x) <> 0;
    Last = %scan('.':Name:x);
    x = Last + 1;
  EndDo;

  // check if ends in .xml, else add .xml
  If Last > 0;
    FileExt = %subst(Name:Last:1024-Last);
    If FileExt <> '.xml' and FileExt <> '.XML';
      Name = %trimr(Name) + '.xml';
    EndIf;
  Else;
    Name = %trimr(Name) + '.xml';
  EndIf;

  // combine path and file and return vaule
  File = %trimr(Path) + %trimr(Name);
  Return    File;


End-Proc;


// #$XMLOpen - Open an existing file or create a new one.
//     input = #$XMLFile = file name in the IFS
//                Example: /CSS/Output.xml
Dcl-Proc #$XMLOpen EXPORT;
  Dcl-Pi #$XMLOpen;
    #$File         Char(1024) CONST;
  End-Pi;

  // fix file name, remove trailing spaces, add / if needed
  //    remove leading \
  fullname  = %trimr(#$File) + null;
  If %subst(fullname:1:1) = '\';
    fullname = %subst(fullname:2:%len(fullname)-1);
  EndIf;
  If %subst(fullname:1:1) <> '/';
    fullname = '/' + fullname;
  EndIf;

  // Open XML File
  #$XMLFile = Open( %addr( fullname ) : o_creat + o_wronly + o_trunc +
                      o_codepage: s_irwxu + s_iroth : asciicodepage );
  #$XMLFile = Close( #$XMLFile );
  #$XMLFile = Open( %addr( fullname ) : o_textdata + o_rdwr );

  // Add hard coded header values
  l = '<?xml version="1.0"?>' + cr +
              '<?mso-application progid="Excel.Sheet"?>' +  cr +
              '<Workbook xmlns="urn:schemas-microsoft-com:+
                office:spreadsheet"' + cr +
              ' xmlns:o="urn:schemas-microsoft-com:office:office"' + cr +
              ' xmlns:x="urn:schemas-microsoft-com:office:excel"' + cr +
              ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + cr +
              ' xmlns:html="http://www.w3.org/TR/REC-html40">'+cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  l = ' <DocumentProperties  xmlns="urn:schemas-microsoft-com:+
                 office:office">' + cr +
              '  <Version>12.00</Version>' + cr +
              ' </DocumentProperties>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  l = ' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:+
                 office:excel">' + cr +
              '  <WindowHeight>10005</WindowHeight>' + cr +
              '  <WindowWidth>10005</WindowWidth>' + cr +
              '  <WindowTopX>120</WindowTopX>' + cr +
              '  <WindowTopY>135</WindowTopY>' + cr +
              '  <ProtectStructure>False</ProtectStructure>' + cr +
              '  <ProtectWindows>False</ProtectWindows>' +  cr +
              ' </ExcelWorkbook>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  l = ' <Styles>' + cr +
              '  <Style ss:ID="Default" ss:Name="Normal">' + cr +
              '   <Alignment ss:Vertical="Bottom"/>' + cr +
              '   <Borders/>' + cr +
              '   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" +
                 ss:Color="#000000"/>' + cr +
              '   <Interior/>' + cr +
              '   <NumberFormat/>' + cr +
              '   <Protection/>' + cr +
              '  </Style>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // Initialize Global Fields
  #$XMLStylO = 'Y';
  #$XMLTablO = ' ';
  #$XMLRowO  = ' ';
  #$XMLWkShO = ' ';


End-Proc;


// #$XMLStyle - Create a style group
//     input =
//     in Center Use an R for Right
Dcl-Proc #$XMLStyle EXPORT;
  Dcl-Pi #$XMLStyle;
    Style          Char(10)   CONST; //1
    pBordTop       Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //2
    pBordBottom    Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //3
    pBordLeft      Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //4
    pBordRight     Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //5
    pFontName      Char(10)   CONST OPTIONS( *NOPASS : *OMIT ); //6
    pFontSize      Char(3)    CONST OPTIONS( *NOPASS : *OMIT ); //7
    pFontColor     Char(7)    CONST OPTIONS( *NOPASS : *OMIT ); //8
    pFontBold      Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //9
    pFontUL        Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //10
    pFontItalic    Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //11
    pNumFormat     Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //12
    pCenter        Char(1)    CONST OPTIONS( *NOPASS : *OMIT ); //13
  End-Pi;

  Dcl-S BordTop      Char(1)    INZ('N');
  Dcl-S BordBottom   Char(1)    INZ('N');
  Dcl-S BordLeft     Char(1)    INZ('N');
  Dcl-S BordRight    Char(1)    INZ('N');
  Dcl-S FontName     Char(10)   INZ('CALIBRI');
  Dcl-S FontSize     Char(3)    INZ('11' );
  Dcl-S FontColor    Char(7)    INZ('#000000');
  Dcl-S FontBold     Char(1)    INZ('N');
  Dcl-S FontUl       Char(1)    INZ('N');
  Dcl-S FontItalic   Char(1)    INZ('N');
  Dcl-S NumFormat    Char(1)    INZ('1');
  Dcl-S Center       Char(1)    INZ(' ');

  // override passed parameteres
  If %parms >= 2 and %addr( pBordTop ) <> *NULL;
    BordTop = pBordTop;
  EndIf;
  If %parms >= 3 and  %addr( pBordBottom ) <> *NULL;
    BordBottom = pBordBottom;
  EndIf;
  If %parms >= 4 and  %addr( pBordLeft ) <> *NULL;
    BordLeft = pBordLeft;
  EndIf;
  If %parms >= 5 and  %addr( pBordRight ) <> *NULL;
    BordRight = pBordRight;
  EndIf;
  If %parms >= 6 and  %addr( pFontName ) <> *NULL and pFontName<>' ';
    FontName = pFontName;
  EndIf;
  If %parms >= 7 and  %addr( pFontSize ) <> *NULL and pFontSize<>' ';
    FontSize = pFontSize;
  EndIf;
  If %parms >= 8 and  %addr( pFontColor ) <> *NULL and pFontColor<>' ';
    FontColor = pFontColor;
  EndIf;
  If %parms >= 9 and  %addr( pFontBold ) <> *NULL;
    FontBold = pFontBold;
  EndIf;
  If %parms >= 10 and  %addr( pFontUL ) <> *NULL;
    FontUl = pFontUL;
  EndIf;
  If %parms >= 11 and  %addr( pFontItalic ) <> *NULL;
    FontItalic = pFontItalic;
  EndIf;
  If %parms >= 12 and  %addr( pNumFormat ) <> *NULL;
    NumFormat = pNumFormat;
  EndIf;
  If %parms >= 13 and  %addr( pCenter ) <> *NULL;
    Center = pCenter;
  EndIf;

  // add Style Group
  l = '  <Style ss:ID="' + %trim(Style) + '">' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // add Border Group
  If BordRight>='1' or BordLeft>='1' or
             BordTop>='1' or BordBottom>='1';

    l = '   <Borders>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

    If BordRight>='1' and BordRight<='4';
      l = '    <Border ss:Position="Right" ss:LineStyle="Continuous" +
                     ss:Weight="' + BordRight   + '"/>' + cr;
      i = Write(#$XMLFile:%addr(l):%len(%trimr(l))) ;
    EndIf;

    If BordLeft>='1' and BordLeft<='4';
      l = '    <Border ss:Position="Left" ss:LineStyle="Continuous" +
                     ss:Weight="' + BordLeft   + '"/>' + cr;
      i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    EndIf;

    If BordTop>='1' and BordTop<='4';
      l = '    <Border ss:Position="Top"  ss:LineStyle="Continuous" +
                     ss:Weight="' + BordTop   + '"/>' + cr;
      i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    EndIf;

    If Bordbottom>='1' and BordBottom<='4';
      l='    <Border ss:Position="Bottom" ss:LineStyle="Continuous" +
                     ss:Weight="' + BordBottom   + '"/>' + cr;
      i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    EndIf;

    l = '   </Borders>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // add Font Group
  l = '   <Font ss:FontName="'+ %trim(FontName) +
            '" ss:Size="' + %trim(FontSize) +
            '" ss:Color="' + %trim(FontColor) + '"';
  If FontBold='1';
    l = %trimr(l) + ' ss:Bold="1"';
  EndIf;
  If FontUl = '1';
    l = %trimr(l) + ' ss:Underline="Single"';
  EndIf;
  If FontUl = '2';
    l = %trimr(l) + ' ss:Underline="Double"';
  EndIf;
  If FontItalic='1';
    l = %trimr(l) + ' ss:Italic="1"';
  EndIf;
  l = %trimr(l) + '/>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // Add Number Format
  If NumFormat='1';
    l = '   <NumberFormat ss:Format="_(* #,##0.00_);+
             _(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;
  If NumFormat='2';
    l = '   <NumberFormat ss:Format="Percent"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;
  If NumFormat='3';
    l = '   <NumberFormat ss:Format="+
                  _(&quot;$&quot;* #,##0.00_);+
                  _(&quot;$&quot;* \(#,##0.00\);+
                  _(&quot;$&quot;* +
                  &quot;-&quot;??_);_(@_)"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;
  If NumFormat='4';
    l = '   <NumberFormat ss:Format="_(* #,##0_);_(* \(#,##0\);+
             _(* &quot;-&quot;??_);_(@_)"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // add center option
  If Center='1';
    l = '   <Alignment ss:Horizontal="Center"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // add Right option
  If Center='R';
    l = '   <Alignment ss:Horizontal="Right"/>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // End Style Group
  l = '  </Style>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));


End-Proc;


// #$XMLWkSh  - Add a worksheet to the XML file
//     input =
Dcl-Proc #$XMLWkSh EXPORT;
  Dcl-Pi #$XMLWkSh;
    WorkSheet      Char(20)   CONST;
    psXMLWsDs                 LIKE(#$XMLWsDs);
  End-Pi;

  Dcl-Ds #$XMLWsDs  QUALIFIED;
    #$XMLWidth     Zoned(4:0) DIM(100);
    #$XMLFrzTop    Zoned(2:0) INZ(0);
    #$XMLFrzLft    Zoned(2:0) INZ(0);
    #$XMLPrCol     Zoned(2:0) INZ(0);
    #$XMLPrRows    Zoned(2:0) INZ(0);
    #$XMLPrBM      Zoned(4:2) INZ(.75);
    #$XMLPrTM      Zoned(4:2) INZ(.75);
    #$XMLPrLM      Zoned(4:2) INZ(.70);
    #$XMLPrRM      Zoned(4:2) INZ(.70);
    #$XMLPrHM      Zoned(4:2) INZ(.30);
    #$XMLPrFM      Zoned(4:2) INZ(.30);
    #$XMLPrSc      Zoned(3:0) INZ(100);
    #$XMLPrCH      Char(1)    INZ('0');
    #$XMLPrCV      Char(1)    INZ('0');
    #$XMLPrHR      Zoned(4:0) INZ(600);
    #$XMLPrVR      Zoned(4:0) INZ(600);
  End-Ds;

  // Miscellaneous data declarations
  Dcl-S LastWidth    Packed(5:0);

  #$XMLWsDs=psXMLWsDs;

  // find last width value sent
  LastWidth=0;
  x=0;
  For x= 1 to 100;
    If #$XMLWsDs.#$XMLWidth(x)<>0;
      LastWidth=x;
    EndIf;
  EndFor;

  // if the style block is still open close it
  If #$XMLStylO='Y';
    l = ' </Styles>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // if the Row block is still open close it
  If #$XMLRowO='Y';
    l = '   </Row>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLRowO=' ';
  EndIf;

  // if the Table block is still open close it
  If #$XMLTablO='Y';
    l = '  </Table>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLTablO=' ';
  EndIf;

  // if the worksheet block is still open close it
  If #$XMLWkShO='Y';
    l = ' </Worksheet>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLWkShO=' ';
  EndIf;

  // Start New Worksheet
  l = ' <Worksheet ss:Name="' + %trim(WorkSheet) + '">' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // Add logic to print first columns/rows on each page
  If #$XMLWsDs.#$XMLPrCol>0 or #$XMLWsDs.#$XMLPrRows>0;

    // start names block
    l = '  <Names>' + cr +
                 '   <NamedRange ss:Name="Print_Titles" +
                    ss:RefersTo="';
    // add columns
    If #$XMLWsDs.#$XMLPrCol=1;
      l = %trimr(l) + '''' + %trim(WorkSheet) + '''' + '!C1';
    EndIf;
    If #$XMLWsDs.#$XMLPrCol>1;
      l = %trimr(l) + '''' + %trim(WorkSheet) + '''' + '!C1:C' +
                    %trim(%editc(#$XMLWsDs.#$XMLPrCol:'Z'));
    EndIf;
    // add comma if both columns and rows sent
    If #$XMLWsDs.#$XMLPrCol>0 and
                #$XMLWsDs.#$XMLPrRows>0;
      l = %trimr(l) + ',';
    EndIf;
    // add rows
    If #$XMLWsDs.#$XMLPrRows=1;
      l = %trimr(l) + '''' + %trim(WorkSheet) + '''' + '!R1';
    EndIf;
    If #$XMLWsDs.#$XMLPrRows>1;
      l = %trimr(l) + '''' + %trim(WorkSheet) + '''' + '!R1:R' +
                %trim(%editc(#$XMLWsDs.#$XMLPrRows:'Z'));
    EndIf;

    // end Names Blocks
    l = %trimr(l) + '"/>' + cr + '  </Names>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // add worksheet options
  l = '  <WorksheetOptions xmlns="urn:schemas-+
                 microsoft-com:office:excel">' + cr +
          '   <PageSetup>' + cr +
          '    <Header x:Margin="' + %trim(%editc(#$XMLWsDs.#$XMLPrHM:'3')) +
                '"/>' + cr +
          '    <Footer x:Margin="' + %trim(%editc(#$XMLWsDs.#$XMLPrFM:'3')) +
                '"/>' + cr +
          '    <PageMargins' +
          ' x:Bottom="' + %trim(%editc(#$XMLWsDs.#$XMLPrBM:'3')) + '"' +
          ' x:Left ="'  + %trim(%editc(#$XMLWsDs.#$XMLPrLM:'3')) + '"' +
          ' x:Right="'  + %trim(%editc(#$XMLWsDs.#$XMLPrRM:'3')) + '"' +
          ' x:Top="'    + %trim(%editc(#$XMLWsDs.#$XMLPrTM:'3')) +
                '"/>' + cr +
          '   </PageSetup>' + cr +
          '   <Print>' + cr +
          '    <ValidPrinterInfo/>' + cr +
          '    <Scale>' +  %trim(%editc(#$XMLWsDs.#$XMLPrSc:'3')) +
               '</Scale>' + cr +
          '    <HorizontalResolution>' +
              %trim(%editc(#$XMLWsDs.#$XMLPrHR:'3')) +
              '</HorizontalResolution>' + cr +
          '    <VerticalResolution>' + %trim(%editc(#$XMLWsDs.#$XMLPrVR:'3')) +
              '</VerticalResolution>' + cr +
          '   </Print>' + cr +
          '   <Unsynced/>' + cr +
          '   <Selected/>' + cr;

  // add freeze pane options if selected
  If #$XMLWsDs.#$XMLFrzTop<>0 or #$XMLWsDs.#$XMLFrzLft<>0;
    l =  %trimr(l) + '   <FreezePanes/>' + cr +
                  '   <FrozenNoSplit/>' + cr;
    If #$XMLWsDs.#$XMLFrzTop<>0;
      l =  %trimr(l) + '   <SplitHorizontal>' +
                     %trim(%editc(#$XMLWsDs.#$XMLFrzTop:'Z'))+
                     '</SplitHorizontal>' +
                     cr +
                     '   <TopRowBottomPane>' +
                     %trim(%editc(#$XMLWsDs.#$XMLFrzTop:'Z'))+
                     '</TopRowBottomPane>' + cr;
    EndIf;
    If #$XMLWsDs.#$XMLFrzLft<>0;
      l = %trimr(l) + '   <SplitVertical>' +
                    %trim(%editc(#$XMLWsDs.#$XMLFrzLft:'Z'))+
                    '</SplitVertical>' + cr +
                    '   <LeftColumnRightPane>' +
                    %trim(%editc(#$XMLWsDs.#$XMLFrzLft:'Z'))+
                    '</LeftColumnRightPane>' + cr;
    EndIf;
  EndIf;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  l =  '   <ActivePane>0</ActivePane>' + cr +
               '   <Panes>'  + cr +
               '    <Pane>'  + cr +
               '     <Number>3</Number>'  + cr +
               '    </Pane>'  + cr +
               '    <Pane>'  + cr +
               '     <Number>1</Number>'  + cr +
               '    </Pane>'  + cr +
               '    <Pane>'  + cr +
               '     <Number>2</Number>'  + cr +
               '    </Pane>'  + cr +
               '    <Pane>'  + cr +
               '     <Number>0</Number>'  + cr +
               '     <ActiveRow>0</ActiveRow>'  + cr +
               '     <RangeSelection>C2</RangeSelection>' +  cr +
               '    </Pane>'  + cr +
               '   </Panes>'  + cr +
               '   <ProtectObjects>False</ProtectObjects>' + cr +
               '   <ProtectScenarios>False</ProtectScenarios>' + cr +
               '  </WorksheetOptions>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // Start Table
  l ='  <Table x:FullColumns="1"' +
             ' x:FullRows="1" ss:DefaultRowHeight="15">' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // add collumn widths
  If LastWidth>0;
    x=0;
    For x = 1 to LastWidth;
      l ='   <Column';
      If #$XMLWsDs.#$XMLWidth(x)<>0;
        l = %trimr(l) + ' ss:Width="' +
                        %trim(%editc(#$XMLWsDs.#$XMLWidth(x):'3')) +  '"';
      EndIf;
      l = %trimr(l) + '/>' + cr;
      i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    EndFor;
  EndIf;

  #$XMLStylO=' ';
  #$XMLTablO='Y';
  #$XMLRowO =' ';
  #$XMLWkShO='Y';


End-Proc;


// #$XMLNwRw  - Add a new row to the XML file
//     input =
Dcl-Proc #$XMLNwRw EXPORT;

  // if the Row block is still open close it
  If #$XMLRowO='Y';
    l = '   </Row>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLRowO =' ';
  EndIf;

  // Start a New Row
  l = '   <Row ss:AutoFitHeight="0">' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  #$XMLRowO ='Y';


End-Proc;


// #$XMLChar - Add a character string to the open XML file
//     input = #$XMLChar = Field containing the value to add
//                Example: callp      #$AddChar('my name is')
Dcl-Proc #$XMLChar EXPORT;
  Dcl-Pi #$XMLChar;
    #$Char         Char(512)  CONST;
    pStyle         Char(10)   CONST OPTIONS( *NOPASS : *OMIT );
  End-Pi;

  Dcl-S Style        Char(10)   INZ(' ');


  If %parms>=2 and %addr(pStyle) <> *NULL;
    Style = pStyle;
  EndIf;

  // add Character cell to file
  If Style<>' ';
    l = '    <Cell ss:StyleID="' +  %trim(Style) + '">';
  Else;
    l = '    <Cell>';
  EndIf;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // add Character cell to file
  If #$Char<>' ';
    l = '<Data ss:Type="String">' + %trim(#$XMLESC(#$Char)) + '</Data>';
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // add Character cell to file
  l = '</Cell>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));


End-Proc;


// #$XMLNum - Add a character string to the open XML file
//     input = #$XMLNum = Field containing the value to add
//                Example: callp      #$AddNum(123.45)
Dcl-Proc #$XMLNum EXPORT;
  Dcl-Pi #$XMLNum;
    #$XMLNo        Zoned(20:5) CONST;
    pStyle         Char(10)   CONST OPTIONS( *NOPASS : *OMIT );
  End-Pi;

  Dcl-S Style        Char(10)   INZ(' ');

  Dcl-S #$EDTnum     Char(23);

  If %parms>=2;
    Style = pStyle;
  EndIf;

  // if negative, add sign and make positive
  If #$XMLNo < 0;
    #$EDTnum='-' + %triml(%editc(#$XMLNo:'3'));
  Else;
    #$EDTnum=%triml(%editc(#$XMLNo:'3'));
  EndIf;

  // add cell to file
  If Style<>' ';
    l = '    <Cell ss:StyleID="' + %trim(Style) + '">';
  Else;
    l = '    <Cell>';
  EndIf;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // add Character cell to file
  l = '<Data ss:Type="Number">' + %trim(#$EDTnum) +
              '</Data></Cell>' + cr;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

End-Proc;


// #$XMLDate - Add a character string to the open XML file
//     input = #$XMLDate = Field containing the value to add
//                Example: callp      #$AddDate(120114)
//                Example: callp      #$AddDate(20141201)
Dcl-Proc #$XMLDate EXPORT;
  Dcl-Pi #$XMLDate;
    #$XMLDate      Zoned(8:0) CONST;
    pStyle         Char(10)   CONST OPTIONS( *NOPASS : *OMIT );
  End-Pi;

  Dcl-S Style        Char(10)   INZ(' ');

  Dcl-S cc           Char(2);
  Dcl-S yy           Char(2);
  Dcl-S mm           Char(2);
  Dcl-S dd           Char(2);
  Dcl-S #$EDTDate    Char(23);
  Dcl-S date         Char(6);

  If %parms>=2 and %addr(pStyle) <> *NULL;
    Style = pStyle;
  EndIf;

  // just leave if the date is 0, this should leave an empty cell
  If #$XMLDate = 0 or #$XMLDate = 20000000;
    Return;
  EndIf;

  // Get edited date value
  If (#$XMLDate<1000000);
    date = %char(#$XMLDate);
    yy = %subst(date:1:2);
    mm = %subst(date:3:2);
    dd = %subst(date:5:2);
    If yy<'50';
      cc='20';
    Else;
      cc='19';
    EndIf;
    #$EDTDate = cc + yy + '-' + mm + '-' + dd + 'T00:00:00.000';
  Else;
    #$EDTDate = %editw(#$XMLDate:'    -  -  ') + 'T00:00:00.000';
  EndIf;

  // add Character cell to file
  If Style<>' ';
    l = '    <Cell ss:StyleID="' +  %trim(Style) + '">' +
                            '<Data ss:Type="DateTime">' +
                   %trim(#$EDTDate) + '</Data></Cell>' + cr;
  Else;
    l = '    <Cell> <Data ss:Type="DateTime">' +
                      %trim(#$EDTDate) + '</Data></Cell>' + cr;
  EndIf;
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

End-Proc;


// #$XMLClose - Close an Existing open file
//     input = #$XMLFile = file name in the IFS
//                Example: \CSS\Output.xml
Dcl-Proc #$XMLClose EXPORT;
  Dcl-Pi #$XMLClose;
  End-Pi;

  // if the style block is still open close it
  If #$XMLStylO='Y';
    l = ' </Styles>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
  EndIf;

  // if the Row block is still open close it
  If #$XMLRowO='Y';
    l = '   </Row>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLRowO=' ';
  EndIf;

  // if the Table block is still open close it
  If #$XMLTablO='Y';
    l = '  </Table>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLTablO=' ';
  EndIf;

  // if the worksheet block is still open close it
  If #$XMLWkShO='Y';
    l = ' </Worksheet>' + cr;
    i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));
    #$XMLWkShO=' ';
  EndIf;

  // End Workbook
  l = '</Workbook>';
  i = Write(#$XMLFile:%addr(l):%len(%trimr(l)));

  // Close open file
  i = Close(#$XMLFile);

End-Proc;


// #$XMLESC - Escapes special characters in a string for XML
// This procedure replaces special characters for an XML
// output field
//     & to &#38;       < to &#60;    > to &#62;
//     ' to &#39,       " to &#34;
//
//        INPUT:  #$IN = String in
//      RETURNS:  Fixed String
//
// Example #$XMLESC('<DATA>')='&#60;DATA&#62;'
Dcl-Proc #$XMLESC;
  Dcl-Pi *N Varchar(1024);
    #$TXT Varchar(1024) VALUE;
  End-Pi;
  #$TXT = %trim(#$TXT);
  #$TXT=%scanrpl('&':'&#38;':#$TXT);
  #$TXT=%scanrpl('<':'&#60;':#$TXT);
  #$TXT=%scanrpl('>':'&#62;':#$TXT);
  #$TXT=%scanrpl('''':'&#39;':#$TXT);
  #$TXT=%scanrpl('"':'&#34;':#$TXT);
  Return #$TXT;
End-Proc;

// *****************************************************************************
// Start of old #$CSV service program


// #$CSVCPath - Creates a CSS default path, uses temp folder
//             \sndmimeml\temp + #$File + '.csv'
//             if #$fileis blanks, returns unique control number
//     input = #$File = file name in the IFS
//  Examples    Input               Output
//              OutputFile          /sndmimeml/temp/OutputFile.csv
//              OutputFile.csv      /sndmimeml/temp/OutputFile.csv
//                                  /sndmimeml/temp/00012342.csv
//              \                   /00012342.csv
//              \css\               /css/00012342.csv
//              test.csv            /sndmimeml/temp/test.csv
//              \test.csv           /test.csv
//              \css\test.csv       /css/test.csv
Dcl-Proc #$CSVCPath EXPORT;
  Dcl-Pi #$CSVCPath Char(1024);
    #$File         Char(1024) CONST;
  End-Pi;
  Dcl-S File         Char(1024);
  Dcl-S Path         Char(1024);
  Dcl-S Name         Char(1024);
  Dcl-S FileExt      Char(1024);
  Dcl-S Last         Zoned(5:0);
  Dcl-S x            Zoned(5:0);

  // Convert any \ to /
  File = %xlate('\':'/':#$File);

  // Find last occurance of /
  Last = 0;
  x = 1;
  DoW %scan('/':File:x) <> 0;
    Last = %scan('/':File:x);
    x = Last + 1;
  EndDo;

  // Get path
  If Last = 0;
    Path = '/sndmimeml/temp/';
  Else;
    Path = %subst(File :1  : Last);
  EndIf;

  // Get File
  If Last = 0;
    Name = File;
  Else;
    Name = %subst(File : Last+1 : 1024-Last);
  EndIf;

  // if name = default it to something
  If Name = ' ';
    Name = 'Temp' + %char(%timestamp():*iso);
  EndIf;

  // Find last occurance of .
  Last = 0;
  x = 1;
  DoW %scan('.':Name:x) <> 0;
    Last = %scan('.':Name:x);
    x = Last + 1;
  EndDo;

  // check if ends in .csv, else add .csv
  If Last > 0;
    FileExt = %subst(Name:Last:1024-Last);
    If FileExt <> '.csv' and FileExt <> '.CSV';
      Name = %trimr(Name) + '.csv';
    EndIf;
  Else;
    Name = %trimr(Name) + '.csv';
  EndIf;

  // combine path and file and return vaule
  File = %trimr(Path) + %trimr(Name);
  Return File;

End-Proc;


// #$OpenCSV - Open an existing file or create a new one.
//     input = #$CSVFile = file name in the IFS
//                Example: /tog/Output.csv
Dcl-Proc #$OpenCSV EXPORT;
  Dcl-Pi #$OpenCSV;
    #$File         Char(1024) CONST;
  End-Pi;

  // fix file name, remove trailing spaces, add / if needed remove leading \
  fullname  = %trimr(#$File) + null;
  If %subst(fullname:1:1) = '\';
    fullname = %subst(fullname:2:%len(fullname)-1);
  EndIf;
  If %subst(fullname:1:1) <> '/';
    fullname = '/' + fullname;
  EndIf;

  // Open CSV File
  #$CSVFile = Open( %addr( fullname )
                         : o_creat + o_wronly + o_trunc + o_codepage
                         : s_irwxu + s_iroth
                         : asciicodepage );
  returnint = Close( #$CSVFile );
  #$CSVFile = Open( %addr( fullname ) : o_textdata + o_rdwr );
  // Initialize Line Field
  Clear buffer;
  #$CSVFF   = 'Y';

End-Proc;


// #$CSVChar - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$CSVChar('my name is')
Dcl-Proc #$CSVChar EXPORT;
  Dcl-Pi #$CSVChar;
    #$CSVChar char(512) const;
  End-Pi;
  Dcl-S x     Int(5);
  Dcl-S Field Char(520);

  // add comma if not the first field on the line
  If #$CSVFF = 'Y';
    #$CSVFF  = ' ';
  Else;
    AddToBuffer(',');
  EndIf;

  // if just a blank is passed, leave
  If #$CSVChar = ' ' or #$CSVChar = '';
    Return;
  EndIf;

  // double quotes
  x = 1;
  Field = #$CSVChar;
  DoW %scan('"':Field:x) <> 0;
    Field = %replace('""' : Field : %scan('"':Field:x):1);
    x = %scan('"':Field:x) + 2;
    If x >= %len(Field);
      Leave;
    EndIf;
  EndDo;

  // add or set field value in double quotes
  AddToBuffer('"' + %trim(Field) + '"');

End-Proc;


// #$CSVNum - Add a character string to the open CSV file
//     input = #$CSVNum = Field containing the value to add
//                Example: callp      #$CSVNUM(123.45)
Dcl-Proc #$CSVNUM EXPORT;
  Dcl-Pi #$CSVNum;
    #$CSVNum       Zoned(20:5) CONST;
  End-Pi;
  Dcl-S Number       Zoned(20:5);
  Dcl-S Number2      Zoned(15:0);

  Number=#$CSVNum;

  // add comma if not the first field on the line
  If #$CSVFF = 'Y';
    #$CSVFF   = ' ';
  Else;
    AddToBuffer(',');
  EndIf;

  // if negative, add sign and make positive
  If Number < 0;
    AddToBuffer('-');
    Number *= -1;
  EndIf;

  // add value editied with an 3(no sign, no commas)
  Number2 = Number * 100;
  If %rem(Number2:100) = 0;
    Number2 = Number;
    AddToBuffer(%trim(%editc(Number2:'3')));
  Else;
    AddToBuffer(%trim(%editc(Number:'3')));
  EndIf;

End-Proc;


// #$CSVNUM0 - Add a character string to the open CSV file
//     input = #$CSVNum = Field containing the value to add
//                Example: callp      #$CSVNUM0(123)
Dcl-Proc #$CSVNUM0 EXPORT;
  Dcl-Pi #$CSVNUM0;
    #$CSVNum       Zoned(20:5) CONST;
  End-Pi;
  Dcl-S Number       Zoned(15:0);

  Number=#$CSVNum;

  // add comma if not the first field on the line
  If #$CSVFF = 'Y';
    #$CSVFF   = ' ';
  Else;
    AddToBuffer(',');
  EndIf;

  // if negative, add sign and make positive
  If Number < 0;
    AddToBuffer('-');
    Number *= -1;
  EndIf;

  // add value editied with an 3(no sign, no commas)
  AddToBuffer(%trim(%editc(Number:'3')));

End-Proc;


// #$CSVNUM2 - Add a character string to the open CSV file
//     input = #$CSVNum = Field containing the value to add
//                Example: callp      #$CSVNUM2(123.45)
Dcl-Proc #$CSVNUM2 EXPORT;
  Dcl-Pi #$CSVNUM2;
    #$CSVNum       Zoned(20:5) CONST;
  End-Pi;
  Dcl-S Number       Zoned(17:2);
  Dcl-S Number2      Zoned(15:0);

  Number=#$CSVNum;

  // add comma if not the first field on the line
  If #$CSVFF = 'Y';
    #$CSVFF   = ' ';
  Else;
    AddToBuffer(',');
  EndIf;

  // if negative, add sign and make positive
  If Number < 0;
    AddToBuffer('-');
    Number *= -1;
  EndIf;

  // add value editied with an 3(no sign, no commas)
  Number2 = Number * 100;
  If %rem(Number2:100) = 0;
    Number2 = Number;
    AddToBuffer(%trim(%editc(Number2:'3')));
  Else;
    AddToBuffer(%trim(%editc(Number:'3')));
  EndIf;

End-Proc;


// #$CSVDate - Add a character string to the open CSV file
//     input = #$CSVChar = Field containing the value to add
//                Example: callp      #$CSVDATE(123.45)
Dcl-Proc #$CSVDate EXPORT;
  Dcl-Pi #$CSVDate;
    #$CSVDate      Zoned(8:0) CONST;
  End-Pi;

  // add comma if not the first field on the line
  If #$CSVFF = 'Y';
    #$CSVFF   = ' ';
  Else;
    AddToBuffer(',');
  EndIf;

  // add value edited
  AddToBuffer(%trim(%editw(#$CSVDate:'    /  / 0')));

End-Proc;


// #$CSVNext - Write a line to the open CSV file and start the next record
Dcl-Proc #$CSVNext EXPORT;

  // end the last line in the buffer
  AddToBuffer(eor);

  // Initialize Line Field and set first field indicator
  #$CSVFF   = 'Y';

End-Proc;


// #$CloseCSV - Close an Existing open file
Dcl-Proc #$CloseCSV EXPORT;

  // write rest of buffer to disk and close the file
  If BUFFERSIZE > 65535;
    returnint = Write(#$CSVFile : %addr(buffer) + 4 : %len(buffer) );
  Else;
    returnint = Write(#$CSVFile : %addr(buffer) + 2 : %len(buffer) );
  EndIf;
  returnint = Close(#$CSVFile);

End-Proc;


// Add data to the buffer
// write it to disk if needed
Dcl-Proc AddToBuffer;
  Dcl-Pi *n;
    data varchar(1000) value;
  End-Pi;

  // If the buffer is over the max size, write it to disc and clear it
  // The +2/4 logic is because IBM stores the size of varchar in the initial
  // bytes of a field and the pointer starts at that data.
  If %len(buffer) + %len(data) >= BUFFERSIZE;
    If BUFFERSIZE > 65535;
      returnint = Write(#$CSVFile : %addr(buffer) + 4 : %len(buffer) );
    Else;
      returnint = Write(#$CSVFile : %addr(buffer) + 2 : %len(buffer) );
    EndIf;
    Clear buffer;
  EndIf;

  buffer += data;

End-Proc;
