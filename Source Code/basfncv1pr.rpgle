**free
// Constant for low time value
Dcl-S LOWTME       Time       INZ(T'00.00.01');
// Constant for low date value
Dcl-S LOWDTE       Date       INZ(D'0001-01-01');
// Constant for low timestamp value
Dcl-S LOWDTM       Timestamp  INZ(Z'0001-01-01-00.00.00.000000');

// Add days to a dec(8) YYYYMMDD date
Dcl-Pr #$ADDDAY Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$DAYS         Zoned(6:0) CONST;
End-Pr;

// Subtract days from a dec(8) YYYYMMDD date
Dcl-Pr #$SUBDAY Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$DAYS         Zoned(6:0) CONST;
End-Pr;

// Add months to a dec(8) YYYYMMDD date
Dcl-Pr #$ADDM Zoned(8:0) ExtProc;
  DATE           Zoned(8:0) CONST;
  MONTHS         Zoned(6:0) CONST;
End-Pr;

// Add years to a dec(8) YYYYMMDD date
Dcl-Pr #$ADDY Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$YEARS        Zoned(6:0) CONST;
End-Pr;

// Add months to a dec(8) YYYYMMDD date
Dcl-Pr #$SUBM Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$MONTHS       Zoned(6:0) CONST;
End-Pr;

// Add months to a dec(8) YYYYMMDD date
Dcl-Pr #$SUBY Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$YEARS        Zoned(6:0) CONST;
End-Pr;

// Difference between dec(8) YYYYMMDD dates in days
Dcl-Pr #$DDIFF Zoned(8:0) ExtProc;
  #$DATE1        Zoned(8:0) CONST;
  #$DATE2        Zoned(8:0) CONST;
End-Pr;

// Determines if a dec(8) YYYYMMDD date is a work day
Dcl-Pr #$ISWKD Ind ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$ALSAT        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Adds a number of work days to a dec(8) YYYYMMDD date
Dcl-Pr #$ADDWD Packed(8:0) ExtProc;
  #$DATE         Packed(8:0) CONST;
  #$DAYS         Packed(8:0) CONST;
End-Pr;

// Subtracts a number of work days from a dec(8) YYYYMMDD date
Dcl-Pr #$SUBWD Packed(8:0) ExtProc;
  #$DATE         Packed(8:0) CONST;
  #$DAYS         Packed(8:0) CONST;
End-Pr;

// Difference between dec(8) YYYYMMDD dates in work days
Dcl-Pr #$WDDIFF Packed(8:0) ExtProc;
  #$DATE1        Packed(8:0) CONST;
  #$DATE2        Packed(8:0) CONST;
End-Pr;

// Converts MMDDYY to YYYYMMDD date
Dcl-Pr #$YMD8 Packed(8:0) ExtProc;
  #$DATE         Packed(6:0) CONST;
End-Pr;

// Converts YYYYMMDD to MMDDYY date
Dcl-Pr #$MDY6 Packed(6:0) ExtProc;
  #$DATE         Packed(8:0) CONST;
End-Pr;

// Returns the Day of Week for a Date number, 0 = Monday
Dcl-Pr #$DAYOW Zoned(1:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
End-Pr;

// Returns the Day of Week Name
Dcl-Pr #$DOW Char(10) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$LEN          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$CAS          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Returns character date in several formats
Dcl-Pr #$DAT Varchar(30) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$PSFMT        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$PSCAS        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Finds the next day of a week from a date
Dcl-Pr #$NXTDOW Zoned(8:0) ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$DAY          Zoned(1:0) CONST;
End-Pr;

// Converts Character Date to Numeric(8,0)
Dcl-Pr #$CVTDAT Zoned(8:0) ExtProc;
  #$CHAR         Char(10)   CONST;
  #$FMT          Char(5)    CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

// Centers Text
Dcl-Pr #$CNTR Varchar(100) ExtProc;
  #$TXT          Varchar(100) VALUE;
  #$LEN          Int(10)    VALUE;
End-Pr;

// Edits a zip code to a standard format
Dcl-Pr #$EDTZP Char(10) ExtProc;
  #$ZIPC         Char(10)   VALUE;
End-Pr;

// Fix HTML Text, escapes special characters
Dcl-Pr #$FHTML Varchar(2048) ExtProc;
  #$IN           Varchar(2048) VALUE;
End-Pr;

// Returns month name
Dcl-Pr #$MNTH Varchar(10) ExtProc;
  #$MTH          Zoned(8:0) CONST;
  #$LEN          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$CAS          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Returns a number from a character string
Dcl-Pr #$RVL Packed(30:10) ExtProc;
  #$TEXT         Char(30)   CONST;
End-Pr;

// Returns a string in UCC format
Dcl-Pr #$UCC Char(18) ExtProc;
  #$TXT          Varchar(100)  CONST;
End-Pr;

// Returns a string in UCP format
Dcl-Pr #$UPC Char(15) ExtProc;
  #$TXT          Varchar(100)  CONST;
End-Pr;

// Validates a date
Dcl-Pr #$VDAT Ind ExtProc;
  #$DATE         Zoned(8:0) CONST;
  #$PSLVL        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Validates a time
Dcl-Pr #$VTIM Ind ExtProc;
  #$TIME         Zoned(6:0) CONST;
End-Pr;

// Returns the week of the year, using ISO 8601 standard
Dcl-Pr #$WOY Zoned(2:0) ExtProc;
  DateIn         Packed(8:0) VALUE;
End-Pr;

// Escapes special characters in a string for XML
Dcl-Pr #$XMLESC Varchar(1024) ExtProc;
  #$TXT          Varchar(1024) VALUE;
End-Pr;

// Converts a number of seconds to HHMMSS format
Dcl-Pr #$SEC2HMS Packed(10:0) ExtProc;
  #$SECS         Packed(10:0) VALUE;
End-Pr;

// Converts a HMS to Number of Seconds
Dcl-Pr #$HMS2SEC Packed(10:0) ExtProc;
  #$HMS          Packed(10:0) VALUE;
End-Pr;

// Returns the difference in times in HMS format
Dcl-Pr #$TDIFF Packed(10:0) ExtProc;
  #$TIME1        Packed(6:0) VALUE;
  #$TIME2        Packed(6:0) VALUE;
End-Pr;

// Adds 2 HMS fields together
Dcl-Pr #$ADDHMS Packed(10:0) ExtProc;
  #$HMS1         Packed(10:0) VALUE;
  #$HMS2         Packed(10:0) VALUE;
End-Pr;

// Subtracts 2 HMS
Dcl-Pr #$SUBHMS Packed(10:0) ExtProc;
  #$HMS1         Packed(10:0) VALUE;
  #$HMS2         Packed(10:0) VALUE;
End-Pr;

// Validates a Timestamp in YYYYMMDDHHMMSS format
Dcl-Pr #$VTS Ind ExtProc;
  #$TS           Packed(14:0) CONST;
End-Pr;

// Creates a timestamp from a date and time
Dcl-Pr #$TSSET Packed(14:0) ExtProc;
  #$DATE         Packed(8:0) CONST;
  #$TIME         Packed(6:0) CONST;
End-Pr;

// Returns a date from a timestamp field
Dcl-Pr #$TSDATE Packed(8:0) ExtProc;
  #$TS           Packed(14:0) CONST;
End-Pr;

// Returns a time from a timestamp field
Dcl-Pr #$TSTIME Packed(8:0) ExtProc;
  #$TS           Packed(14:0) CONST;
End-Pr;

// Adds a number of days to a Timestamp
Dcl-Pr #$TSADDD Packed(14:0) ExtProc;
  #$TS           Packed(14:0) CONST;
  #$DAYS         Packed(8:0) CONST;
End-Pr;

// Subtracts a number of days from a Timestamp
Dcl-Pr #$TSSUBD Packed(14:0) ExtProc;
  #$TS           Packed(14:0) CONST;
  #$DAYS         Packed(8:0) CONST;
End-Pr;

// Adds a number of seconds to a Timestamp
Dcl-Pr #$TSADDS Packed(14:0) ExtProc;
  #$TS           Packed(14:0) CONST;
  #$SECS         Packed(8:0) CONST;
End-Pr;

// Subtracts a number of seconds from a Timestamp
Dcl-Pr #$TSSUBS Packed(14:0) ExtProc;
  #$TS           Packed(14:0) CONST;
  #$SECS         Packed(8:0) CONST;
End-Pr;

// Returns the difference between Timestamps in days
Dcl-Pr #$TSDDAY Packed(8:0) ExtProc;
  #$TS1          Packed(14:0) CONST;
  #$TS2          Packed(14:0) CONST;
End-Pr;

// Returns the difference between Timestamps in seconds
Dcl-Pr #$TSDSEC Packed(14:0) ExtProc;
  #$TS1          Packed(14:0) CONST;
  #$TS2          Packed(14:0) CONST;
End-Pr;

// Returns the difference between Timestamps in an HMS field
Dcl-Pr #$TSDHMS Packed(10:0) ExtProc;
  #$TS1          Packed(14:0) CONST;
  #$TS2          Packed(14:0) CONST;
End-Pr;

// Converts to all lowercase, decapricated use %lower
Dcl-Pr #$LOWFY Varchar(32767) ExtProc;
  #$DATA         Varchar(32767) CONST  OPTIONS(*VARSIZE);
End-Pr;

// Converts to all uppercase, decapricated use %upper
Dcl-Pr #$UPIFY Varchar(32767) ExtProc;
  #$DATA         Varchar(32767) CONST  OPTIONS(*VARSIZE);
End-Pr;

// Splits a string into words, decapricated use %split
Dcl-Pr #$SPLIT Char(1000) DIM(50) ExtProc;
  #$DATA         Char(8000) CONST;
  DELIMITER1     Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Edits a number variable, normally use %editc, but this has more options
Dcl-Pr #$EDTC Char(30) ExtProc;
  #$VALU         Packed(15:5) CONST;
  #$EDTC         Char(1)    CONST;
  #$EDTP         Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$EDTR         Packed(2:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$RND          Char(1)    CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Edit Phone Number
Dcl-Pr #$EDTP Char(12) ExtProc;
  #$PHNO         Packed(11:0) CONST;
End-Pr;

// Edit Phone Number
Dcl-Pr #$EDTP2 Char(20) ExtProc;
  #$PHNO         Char(20)   CONST;
End-Pr;

// Escapes out URI special characters
Dcl-Pr #$URIESC Varchar(256000) ExtProc;
  #$TXT          Varchar(256000) VALUE;
  #$SPC          Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$UPR          Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Un-Escapes URI special characters
Dcl-Pr #$URIDESC Varchar(256000) ExtProc;
  #$TXT          Varchar(256000) VALUE;
  #$SPC          Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Validates an email address, returns true or false
Dcl-Pr #$VEML Ind ExtProc;
  #$EMAIL        Varchar(100) VALUE;
End-Pr;

// Validate an Email Address, returns error message
Dcl-Pr #$VEML2 Char(50) ExtProc;
  #$EMAIL        Varchar(100) VALUE;
End-Pr;

// Test if a field contains all numeric data
Dcl-Pr #$TESTN Ind ExtProc;
  #$TEXT         Varchar(100) VALUE;
  #$ALLD         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$ALTR         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$ALNG         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Rounds up to the next 0.05
Dcl-Pr #$RND05 Packed(20:5) ExtProc;
  #$VALU         Packed(20:5) VALUE;
End-Pr;

// Rounds a number up, to the next whole number by default but has more opt
Dcl-Pr #$RNDUP Packed(30:10) ExtProc;
  #$VALUE        Packed(30:10) VALUE;
  #$PRECISION    Packed(30:10) CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

// Retrieve object description
Dcl-Pr #$RTVOBJD  LIKE(#$ObjD) ExtProc;
  #$OBJ          Char(10)   VALUE;
  #$LIB          Char(10)   VALUE;
  #$TYPE         Char(10)   VALUE;
End-Pr;

// Displays text in a window
Dcl-Pr #$DSPWIN ExtProc;
  #$TEXT         Char(8192) CONST;
  #$MSGID        Char(7)    CONST OPTIONS(*NOPASS : *OMIT);
  #$MSGFILE      Char(21)   CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Runs a command
Dcl-Pr #$CMD ExtProc;
  #$CMD          Varchar(32768) VALUE;
  #$NOE          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Get the text for a field
Dcl-Pr #$FLDTXT Varchar(50) ExtProc;
  #$FILE         Varchar(10) CONST;
  #$FIELD        Varchar(10) CONST;
  #$LIB          Char(10)   CONST OPTIONS(*NOPASS);
End-Pr;

// Returns the last part of a string
Dcl-Pr #$LAST Varchar(99) ExtProc;
  #$STRING       Varchar(2048) CONST;
  #$CHARS        Zoned(2:0) CONST;
End-Pr;

// Send Message
Dcl-Pr #$SNDMSG ExtProc;
  #$MSG          Varchar(1024) CONST;
  #$MSGTYPE      Char(10)   CONST OPTIONS(*NOPASS);
  #$TOPGMQ       Char(10)   CONST OPTIONS(*NOPASS);
End-Pr;

// Split File Name From Path
Dcl-Pr #$FILE Char(2048) ExtProc;
  PATH           Varchar(4096) CONST;
End-Pr;

// Split Folder From Path
Dcl-Pr #$FOLDER Char(2048) ExtProc;
  PATH           Varchar(4096) CONST;
End-Pr;

// Check the last SQL statements status
Dcl-Pr #$SQLSTT Ind ExtProc;
  PSSQLSTT       Char(5)    CONST OPTIONS(*NOPASS : *OMIT);
  PSTYPE         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Converts * to % and doubles any single quotes
Dcl-Pr #$SQLESC Varchar(512) ExtProc;
  #$TEXT         Varchar(512) VALUE;
  #$CNVAST       Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Validates a phone number
Dcl-Pr #$VPHN Ind ExtProc;
  #$PHON         Varchar(30) VALUE;
End-Pr;

// Escapes special characters in a JSON string
Dcl-Pr #$JSONESC Varchar(4096) ExtProc;
  #$TEXT         Varchar(4096) VALUE;
End-Pr;

// Get JSON string from SQL output
Dcl-Pr #$SQL2JSON Varchar(1024000) ExtProc;
  sqlStm         Varchar(8192)  CONST;
  #$CLMOVR       Char(128)  DIM(200) OPTIONS(*NOPASS: *OMIT) CONST;
  #$ARYONLY      Zoned(1:0) OPTIONS(*NOPASS: *OMIT) CONST;
End-Pr;
Dcl-S #$CLMOVR     Char(128)  DIM(200);

// Returns a JSON string from the results of an SQL statement
Dcl-Pr #$SQL2JCGI Varchar(1024000) ExtProc;
  sqlStm         Varchar(8192)  CONST;
  #$CLMOVR       Char(128)  DIM(200) OPTIONS(*NOPASS: *OMIT) CONST;
  #$ARYONLY      Zoned(1:0) OPTIONS(*NOPASS: *OMIT) CONST;
  PSSTREAM       Zoned(1:0) OPTIONS(*NOPASS: *OMIT) CONST;
End-Pr;

// Check to see if a resource at a URL exists
Dcl-Pr #$URLTST Ind ExtProc;
  URL            Varchar(32767)  CONST;
End-Pr;

// Get image/web link to a fabric
Dcl-Pr #$SKULNK Char(512) ExtProc;
  FNO            Packed(7:0) VALUE;
  TYPE           Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  PSCNUM         Packed(7:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Create an HTTP link to an image, tear sheet or webpage for a furniture m
Dcl-Pr #$FURLNK Varchar(512) ExtProc;
  PSMODEL        Varchar(30) CONST;
  TYPE           Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Test if a file exists
Dcl-Pr #$ISFILE Ind ExtProc;
  #$FILE         Char(10)   CONST;
  #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Test if a library exists
Dcl-Pr #$ISLIB Ind ExtProc;
  #$LIB          Char(10)   CONST;
End-Pr;

// Test if an object exists
Dcl-Pr #$ISOBJ Ind ExtProc;
  #$FILE         Char(10)   CONST;
  #$TYPE         Char(10)   CONST;
  #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Test if a member exists
Dcl-Pr #$ISMBR Ind ExtProc;
  #$LIB          Char(10)   CONST;
  #$FILE         Char(10)   CONST;
  #$MBR          Char(10)   CONST;
End-Pr;

// Test if an outq exists
Dcl-Pr #$ISOUTQ Ind ExtProc;
  #$OUTQ         Char(10)   CONST;
  #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Scans a string from the right
Dcl-Pr #$SCANR Packed(5:0) ExtProc;
  #$FIND         Varchar(1024) CONST;
  #$IN           Varchar(32767) CONST;
  #$STR          Packed(5:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Start each word with an uppercase letter
Dcl-Pr #$C1ST Varchar(10000) ExtProc;
  #$TEXT         Varchar(10000) CONST;
End-Pr;

// Converts an Excel time value to HHMMSS
Dcl-Pr #$XLDTTM Zoned(14:0) ExtProc;
  #$DATE         Float(8)   VALUE;
End-Pr;

// Converts an Excel date value to YYYYMMDD
Dcl-Pr #$XLDATE Zoned(8:0) ExtProc;
  #$DATE         Float(8)   VALUE;
End-Pr;

// Converts an Excel date/time value to YMDHMS
Dcl-Pr #$XLTIME Zoned(6:0) ExtProc;
  #$DATE         Float(8)   VALUE;
End-Pr;

// Returns Order Type Details
Dcl-Pr #$ORDTYP  LIKEDS(#$ORDTYPDS) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
  #$PSLNNO       Packed(2:0) CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

// Data structre returned from #$ordtyp
Dcl-Ds #$ORDTYPDS;
  #$TYP3         Char(3);
  #$BRANCH       Packed(2:0);
  #$TYPE         Char(20);
  #$OPNCLS       Char(1);
  #$HDRFILE      Char(10);
  #$DTLFILE      Char(10);
  #$SHMFILE      Char(10);
  #$SHDFILE      Char(10);
End-Ds;

// See if an active job exists
Dcl-Pr #$ACTJOB Ind ExtProc;
  #$JOBNAME      Char(10)   CONST;
  #$JOBUSER      Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
  #$JOBNBR       Char(6)    CONST OPTIONS(*NOPASS:*OMIT);
  #$SBSNAME      Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
  #$SBSLIB       Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

Dcl-S #$BLDSCHF    Char(1000) DIM( 500 );

// Build Multi Word Search String for SQL
Dcl-Pr #$BLDSCH Varchar(10000) ExtProc;
  #$SRCHSTR      Varchar(1000)  CONST;
  #$SRCHFLDS     Char(1000) DIM( 500 );
End-Pr;

// See if a Job is Interactive
Dcl-Pr #$INTACT Char(1) ExtProc;
End-Pr;

// Word Wrap a string and return a string
Dcl-Pr #$WORDWRAP Char(32000) ExtProc;
  stringIn       Varchar(32000)  CONST OPTIONS(*VARSIZE);
  trimLength     Packed(5:0) CONST;
End-Pr;

// Word Wrap a string and return an array
Dcl-Pr #$WORDWRP2 Char(250) DIM(250) ExtProc;
  stringIn       Varchar(32000)  CONST OPTIONS(*VARSIZE);
  trimLength     Packed(5:0) CONST;
End-Pr;

// Returns the Partition Number
Dcl-Pr #$PARTITION Bindec(4) ExtProc;
End-Pr;

// Returns the System Name
Dcl-Pr #$SYSNAME Char(8) ExtProc;
End-Pr;

// Validates an IFS Path
Dcl-Pr #$VPATH Ind ExtProc;
  #$PATH         Varchar(5000) VALUE;
End-Pr;

// Get a Users Home Directory
Dcl-Pr #$USRHOME Varchar(256) ExtProc;
  #$USER         Char(10)   CONST OPTIONS(*NOPASS);
End-Pr;

// Same as %SCANRPL without PDM Errors
Dcl-Pr #$SCANRPL Varchar(32000) ExtProc;
  #$FIND         Varchar(32000) CONST;
  #$REPLACE      Varchar(32000) CONST;
  #$IN           Varchar(32000) CONST;
End-Pr;

// Doubles Quotes in a String
Dcl-Pr #$DBLQ Varchar(32000) ExtProc;
  #$IN           Varchar(32000) CONST;
End-Pr;

// Get UOM descriptive text for the Web and other places
Dcl-Pr #$UOMTEXT Char(100) ExtProc;
  #$FNO          Packed(7:0) CONST;
End-Pr;

// Prodcedure to fix parameter lists in a CGI program.
// This takes a string like this - FAB,tre
// and converts it to this - "FAB","TRE"
Dcl-Pr #$FIXPRMLST Varchar(4096) ExtProc;
  DATAIN         Varchar(4096) CONST;
End-Pr;

// Get the vendor for the first line in an order
Dcl-Pr #$GETVENDOR Zoned(5:0) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
End-Pr;

// Get material type for first line in an order
Dcl-Pr #$GETMTYP Zoned(2:0) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
End-Pr;

// Get freight for a leather order
Dcl-Pr #$LTHFRT Zoned(7:2) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
End-Pr;

// Get users initials
Dcl-Pr #$INITS Char(3) ExtProc;
  PSINITS        Char(5)    CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

// Get order category for an order (dft 1st line)
Dcl-Pr #$GETORDCAT Char(3) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
  #$PSLNNO       Packed(2:0) CONST OPTIONS(*NOPASS:*OMIT);
End-Pr;

// Get freight for a rug order
Dcl-Pr #$RUGFRT Zoned(7:2) ExtProc;
  #$CNO          Packed(7:0) VALUE;
  #$INV          Packed(6:0) VALUE;
End-Pr;

// Returns the status of an order
Dcl-Pr #$ORDSTS Char(15) ExtProc;
  #$INV          Zoned(6:0) CONST OPTIONS(*NOPASS : *OMIT);
  #$CUSTIN       Zoned(7:0) CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// Delay job for a number of seconds
Dcl-Pr #$WAIT ExtProc;
  NBRSECS        Packed(15:5) VALUE;
End-Pr;

// Returns the EOL date of the master
Dcl-Pr #$MSTEOL Packed(6:0) ExtProc;
  FNO            Packed(7:0) VALUE;
End-Pr;

// Returns the greates EOL date of all equivalents
Dcl-Pr #$LSTEOL Packed(6:0) ExtProc;
  FNO            Packed(7:0) VALUE;
End-Pr;

// Returns the count of all equivalent items
Dcl-Pr #$EQVCNT Packed(3:0) ExtProc;
  FNO            Packed(7:0) VALUE;
End-Pr;

// Clean Character, removes un-printable chars
Dcl-Pr #$CCHAR Varchar(32000) ExtProc;
  #$STR          Varchar(32000)  CONST;
  CCSID          Char(4)    CONST OPTIONS(*NOPASS);
End-Pr;

// Convert a character string to a hex string
Dcl-Pr #$C2H Varchar(32000) ExtProc;
  #$STR          Varchar(32000)  CONST;
End-Pr;

// Convert a hex string to a character string
Dcl-Pr #$H2C Varchar(32000) ExtProc;
  #$HEX          Varchar(32000)  CONST;
End-Pr;

// Get the country based on the state
Dcl-Pr #$GETCNTRY Char(2) ExtProc;
  #$STATE        Char(2)    CONST;
End-Pr;

// Get Cut lenght for Quick Ship item
Dcl-Pr #$GETCUTLEN Zoned(3:0) ExtProc;
  PSSKU          Varchar(30) CONST;
  PSGRP16        Char(1)    CONST;
End-Pr;

// Validate a user id
Dcl-Pr #$isUser Ind ExtProc;
  userID         Varchar(10)  CONST;
End-Pr;

// Test Playing a WAV on the local computer
Dcl-Pr #$play ExtProc;
  #$FILE         varchar(100)  CONST OPTIONS(*NOPASS : *OMIT);
End-Pr;

// get status for a line on an order
Dcl-Pr #$ORDLNESTS char(3) ExtProc;
  inv packed(6) value;
  lne packed(2) value;
End-Pr;



// #$IN - Test if a character value is in a list

// INPUT:  Value    - A variable holding the value to test
//         parm2-21 - A list of up to 20 values to test
// RETURN: *on or *off

// Example:
//  if #$IN(value:'ONE':'TWO':'THREE')
//     erm='Value in list.';
//  else;
//     erm='Value not in list.';
//  endif;
Dcl-Pr #$IN Ind ExtProc;
  Value          Char(100)  CONST;
  list01         Char(100)  CONST OPTIONS(*NOPASS);
  list02         Char(100)  CONST OPTIONS(*NOPASS);
  list03         Char(100)  CONST OPTIONS(*NOPASS);
  list04         Char(100)  CONST OPTIONS(*NOPASS);
  list05         Char(100)  CONST OPTIONS(*NOPASS);
  list06         Char(100)  CONST OPTIONS(*NOPASS);
  list07         Char(100)  CONST OPTIONS(*NOPASS);
  list08         Char(100)  CONST OPTIONS(*NOPASS);
  list09         Char(100)  CONST OPTIONS(*NOPASS);
  list10         Char(100)  CONST OPTIONS(*NOPASS);
  list11         Char(100)  CONST OPTIONS(*NOPASS);
  list12         Char(100)  CONST OPTIONS(*NOPASS);
  list13         Char(100)  CONST OPTIONS(*NOPASS);
  list14         Char(100)  CONST OPTIONS(*NOPASS);
  list15         Char(100)  CONST OPTIONS(*NOPASS);
  list16         Char(100)  CONST OPTIONS(*NOPASS);
  list17         Char(100)  CONST OPTIONS(*NOPASS);
  list18         Char(100)  CONST OPTIONS(*NOPASS);
  list19         Char(100)  CONST OPTIONS(*NOPASS);
  list20         Char(100)  CONST OPTIONS(*NOPASS);
End-Pr;

// #$INN - Test if a numeric value is in a list

// INPUT:   Value    - A variable holding the value to test
//          Parm2-21 - A list of up to 20 values to test

// RETURNS: *on or *off

// Example:
//  if #$INN(value:1:2:123.35)
//     erm='Value in list.';
//  else;
//     erm='Value not in list.';
//  endif;
Dcl-Pr #$INN Ind ExtProc;
  Value          Packed(20:5) VALUE;
  list01         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list02         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list03         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list04         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list05         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list06         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list07         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list08         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list09         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list10         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list11         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list12         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list13         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list14         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list15         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list16         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list17         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list18         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list19         Packed(20:5) VALUE OPTIONS(*NOPASS);
  list20         Packed(20:5) VALUE OPTIONS(*NOPASS);
End-Pr;

// #$132OK - Tests it display handles 132 characters
// INPUT: None
// RETURN: *on or *off, *on = handels 132 cha

// Example:

//  if #$132OK;
//     ScrSze='2';
//  else;
//     ScrSze='1';
//  endif;
Dcl-Pr #$132OK Ind ExtProc;
End-Pr;

// #$NextBatch - Gets the next unqiue 6 character batch number
// €                                                             ‚
// €INPUT:   Nothing
// €RETURNS: Char(6), the next 6 character alpha batch number     ‚
// €                                                             ‚
// €Example:                                                     ‚
// € BchNbr=#$NextBatch();
Dcl-Pr #$NextBatch Char(6) ExtProc;
End-Pr;

// #$FMTPHN - Format Phone number based on country code

// INPUT: Phone number
//        Country Code - Defualts to US
//        Include Prefix (Y/N) - Defaults to N
// RETURN: Edited Phone Number

// Example:
//   Phone = #$FmtPhn(Phone:Country:'Y');
//   PhoneEdited = #$FmtPhn(Phone:'US':'Y');
Dcl-Pr #$FmtPhn Char(30) ExtProc;
  Phone#         Char(30)   CONST;
  CountryCd      Char(2)    CONST OPTIONS(*NOPASS);
  PrefixYN       Char(1)    CONST OPTIONS(*NOPASS);
End-Pr;

// Data structure returned from #$RTVOBJF
Dcl-Ds #$ObjD;
  #$ODDscLen     Int(10); //Bytes returned
  #$ODDscSiz     Int(10); //Bytes available
  #$ODNam        Char(10); //Object name
  #$ODLib        Char(10); //Object library name
  #$ODTyp        Char(10); //Object type
  #$ODRtnLib     Char(10); //Return library
  #$ODAsp        Int(10); //Object ASP number
  #$ODOwnr       Char(10); //Object owner
  #$ODDmn        Char(2); //Object domains
  #$ODCrtDat     Char(13); //Creation date and ta
  #$ODChgDat     Char(13); //Object change date/t
  #$ODAtr        Char(10); //Extended object att
  #$ODTxt        Char(50); //Text description
  #$ODSrcFil     Char(10); //Source file name
  #$ODSrcLib     Char(10); //Source file library
  #$ODSrcMbr     Char(10); //Source file member
  #$ODSrcChgDat  Char(13); //Source file updated
  #$ODSrcSavDat  Char(13); //Object saved date/tm
  #$ODSrcRstDat  Char(13); //Object restored dat
  #$ODCrtUsr     Char(10); //Creator's user prof
  #$ODCrtSys     Char(8); //System where object
  #$ODResDat     Char(7); //Reset date
  #$ODSavSiz     Int(10); //Save size
  #$ODSavSeq     Int(10); //Save sequence numbe
  #$ODStg        Char(10); //Storage
  #$ODSavCmd     Char(10); //Save command
  #$ODSavVolId   Char(71); //Save volume ID
  #$ODSavDvc     Char(10); //Save device
  #$ODSavFil     Char(10); //Save file name
  #$ODSavLib     Char(10); //Save file library n
  #$ODSavLbl     Char(17); //Save label
  #$ODSavLvl     Char(9); //System level
  #$ODCompiler   Char(16); //Compiler
  #$ODLvl        Char(8); //Object level
  #$ODUsrChg     Char(1); //User changed
  #$ODLicPgm     Char(16); //Licensed program
  #$ODPtf        Char(10); //Program temporary f
  #$ODApar       Char(10); //Authorized program
  #$ODUseDat     Char(7); //Last-used date
  #$ODUsgInf     Char(1); //Usage information u
  #$ODUseDay     Int(10); //Days-used count
  #$ODSiz        Int(10); //Object size
  #$ODSizMlt     Int(10); //Object size multipl
  #$ODCprSts     Char(1); //Object compression
  #$ODAlwChg     Char(1); //Allow change by pro
  #$ODChgByPgm   Char(1); //Changed by program
  #$ODUsrAtr     Char(10); //User-defined attrib
  #$ODOvrflwAsp  Char(1); //Object overflowed A
  #$ODSavActDat  Char(7); //Save active date
  #$ODSavActTim  Char(6); //Save active time
  #$ODAudVal     Char(10); //Object auditing val
  #$ODPrmGrp     Char(10); //Primary group
  #$ODJrnSts     Char(1); //Journal status
  #$ODJrnNm      Char(10); //Journal name
  #$ODJrnLib     Char(10); //Journal library nam
  #$ODJrnImg     Char(1); //Journal images
  #$ODJrnOmit    Char(1); //Journal entries to
  #$ODJrnStrDte  Char(13); //Journal start date
  #$ODDgtSig     Char(1); //Digitally signed
  #$ODSavUntSiz  Int(10); //Saved size in units
  #$ODSavUntMul  Int(10); //Saved size multipli
  #$ODAspLibNbr  Int(10); //Library ASP number
  #$ODAspDevNm   Char(10); //Object ASP device n
  #$ODAspLibNm   Char(10); //Library ASP device
  #$ODDgtTrust   Char(1); //Digitally signed by
  #$ODDgtMost    Char(1); //Digitally signed mo
End-Ds;


Dcl-Pr #$SQLMessage varchar(500) ExtProc;
  sqlCodeIn packed(4) const;
  sqlErrMc char(500) const options(*nopass);
End-Pr;


Dcl-Pr #$SQLMessageHelp varchar(4000) ExtProc;
  sqlCodeIn packed(4) const;
  sqlErrMc char(500) const options(*nopass);
End-Pr;

Dcl-Pr #$SQLLstStm varchar(10000) ExtProc;
End-Pr;


Dcl-Pr #$SQLMSGID char(7) ExtProc;
  sqlCode int(10);
End-Pr;

Dcl-Pr #$ShowsInGeneralSearch char(1) ExtProc;
  pmrFno packed(7) const;
  pmrRsn char(50) options(*nopass);
End-Pr;

Dcl-Pr #$ALPH ExtProc;
  #$Value packed(13:2) value;
  txt1 char(73);
  txt2 char(73);
  cents1 char(1) const options(*nopass:*omit);
End-Pr;

Dcl-Pr #$DftAcpCmp ExtProc;
  pmrUser char(10);
  acpCmpIdn int(20);
  cmpNme varchar(100);
End-Pr;

Dcl-Pr #$HasRole Ind ExtProc;
  rolNme01 varchar(30) const options(*nopass:*omit);
  rolNme02 varchar(30) const options(*nopass:*omit);
  rolNme03 varchar(30) const options(*nopass:*omit);
  rolNme04 varchar(30) const options(*nopass:*omit);
  rolNme05 varchar(30) const options(*nopass:*omit);
  rolNme06 varchar(30) const options(*nopass:*omit);
  rolNme07 varchar(30) const options(*nopass:*omit);
  rolNme08 varchar(30) const options(*nopass:*omit);
  rolNme09 varchar(30) const options(*nopass:*omit);
  rolNme10 varchar(30) const options(*nopass:*omit);
  rolNme11 varchar(30) const options(*nopass:*omit);
  rolNme12 varchar(30) const options(*nopass:*omit);
  rolNme13 varchar(30) const options(*nopass:*omit);
  rolNme14 varchar(30) const options(*nopass:*omit);
  rolNme15 varchar(30) const options(*nopass:*omit);
  rolNme16 varchar(30) const options(*nopass:*omit);
  rolNme17 varchar(30) const options(*nopass:*omit);
  rolNme18 varchar(30) const options(*nopass:*omit);
  rolNme19 varchar(30) const options(*nopass:*omit);
  rolNme20 varchar(30) const options(*nopass:*omit);
  rolNme21 varchar(30) const options(*nopass:*omit);
  rolNme22 varchar(30) const options(*nopass:*omit);
  rolNme23 varchar(30) const options(*nopass:*omit);
  rolNme24 varchar(30) const options(*nopass:*omit);
  rolNme25 varchar(30) const options(*nopass:*omit);
  rolNme26 varchar(30) const options(*nopass:*omit);
  rolNme27 varchar(30) const options(*nopass:*omit);
  rolNme28 varchar(30) const options(*nopass:*omit);
  rolNme29 varchar(30) const options(*nopass:*omit);
  rolNme30 varchar(30) const options(*nopass:*omit);
  rolNme31 varchar(30) const options(*nopass:*omit);
  rolNme32 varchar(30) const options(*nopass:*omit);
  rolNme33 varchar(30) const options(*nopass:*omit);
  rolNme34 varchar(30) const options(*nopass:*omit);
  rolNme35 varchar(30) const options(*nopass:*omit);
  rolNme36 varchar(30) const options(*nopass:*omit);
  rolNme37 varchar(30) const options(*nopass:*omit);
  rolNme38 varchar(30) const options(*nopass:*omit);
  rolNme39 varchar(30) const options(*nopass:*omit);
  rolNme40 varchar(30) const options(*nopass:*omit);
  rolNme41 varchar(30) const options(*nopass:*omit);
  rolNme42 varchar(30) const options(*nopass:*omit);
  rolNme43 varchar(30) const options(*nopass:*omit);
  rolNme44 varchar(30) const options(*nopass:*omit);
  rolNme45 varchar(30) const options(*nopass:*omit);
  rolNme46 varchar(30) const options(*nopass:*omit);
  rolNme47 varchar(30) const options(*nopass:*omit);
  rolNme48 varchar(30) const options(*nopass:*omit);
  rolNme49 varchar(30) const options(*nopass:*omit);
  rolNme50 varchar(30) const options(*nopass:*omit);
End-Pr;

// #$ENVME - Returns the current environments name
Dcl-Pr #$envNme char(50) ExtProc;
End-Pr;

Dcl-Pr #$GetKeys varchar(100) ExtProc;
  fleLib char(10);
  fleNme char(10);
End-Pr;

// Debug a batch job
Dcl-Pr #$DbgBch ExtProc;
  user char(10) const;
End-Pr;

// Get Calling program
Dcl-Pr #$CallingPgm ExtProc;
  pgmNme char(10);
  libNme char(10);
End-Pr;

Dcl-Pr #$RtvMbrD char(50) ExtProc;
  lib char(10) const;
  fle char(10) const;
  mbr char(10) const;
End-Pr;


// *************************************************************************
// š                           IFS Prototypes
// *************************************************************************
// € These prototypes are for IBM's IFS file reading and writing API's
// € You can see an example of them working program #$IFSIOTS in APLLIB.
// € These also include a handeful of predefined constants for use with thes
// € API's and others
// *************************************************************************
Dcl-S EOR          Char(2)    INZ( X'0D25' );
Dcl-S CR           Char(1)    INZ( X'0D' );
Dcl-S LF           Char(1)    INZ( X'25' );
Dcl-S TAB          Char(1)    INZ( X'05' );
Dcl-S NULL         Char(1)    INZ( X'00' );
Dcl-S asciicodepage Uns(10)    INZ(367);
Dcl-S filedesc     Int(10);
Dcl-S byteswrt     Int(10);
Dcl-S bytesred     Int(10);
Dcl-S fullname     Char(512);
Dcl-S returnint    Int(10);

// IF CGIDEV is included it already has the IFS prototype defined,
// so do not include these if they are already defined
/if not defined(IFS_DEFINED)

// Get IFS object status via UNIX API stat()
Dcl-Pr stat Int(10) EXTPROC('stat');
  filename       Pointer    VALUE OPTIONS(*STRING); //null terminated str
  statStruct     Pointer    VALUE;
End-Pr;

// Get IFS object status via UNIX API stat64()
Dcl-Pr stat64 Int(10) EXTPROC('stat64');
  filename       Pointer    VALUE OPTIONS(*STRING); //null terminated str
  statStruct     Pointer    VALUE;
End-Pr;

// Open
Dcl-Pr Open Int(10) EXTPROC('open');
  filename       Pointer    VALUE OPTIONS(*STRING); //null terminated str
  openflags      Int(10)    VALUE;
  mode           Uns(10)    VALUE OPTIONS(*NOPASS);
  codepage       Uns(10)    VALUE OPTIONS(*NOPASS);
End-Pr;

// Read
Dcl-Pr Read Int(10) EXTPROC('read');
  filehandle     Int(10)    VALUE;
  datareceived   Pointer    VALUE;
  nbytes         Uns(10)    VALUE;
End-Pr;

// Write
Dcl-Pr Write Int(10) EXTPROC('write');
  filehandle     Int(10)    VALUE;
  datatowrite    Pointer    VALUE;
  nbytes         Uns(10)    VALUE;
End-Pr;

// Close
Dcl-Pr Close Int(10) EXTPROC('close');
  filehandle     Int(10)    VALUE;
End-Pr;

// Link (creates a hard link)
Dcl-Pr link Int(10) EXTPROC('link');
  filepath       Pointer    VALUE OPTIONS(*STRING);
  newlink        Pointer    VALUE OPTIONS(*STRING);
End-Pr;

// Unlink (unlinks an IFS file)
Dcl-Pr unlink Int(10) EXTPROC('unlink');
  filepath       Pointer    VALUE OPTIONS(*STRING);
End-Pr;

// ****************************************************************
// IFS constants
// ****************************************************************
// File Access Modes for open()
Dcl-S O_RDONLY     Int(10)    INZ(1);
Dcl-S O_WRONLY     Int(10)    INZ(2);
Dcl-S O_RDWR       Int(10)    INZ(4);

// oflag values for open()
Dcl-S O_CREAT      Int(10)    INZ(8);
Dcl-S O_EXCL       Int(10)    INZ(16);
Dcl-S O_TRUNC      Int(10)    INZ(64);
Dcl-S O_LARGEFILE  Int(10)    INZ(536870912);

// File Status Flags for open() and fcntl()
Dcl-S O_NONBLOCK   Int(10)    INZ(128);
Dcl-S O_APPEND     Int(10)    INZ(256);

// oflag Share Mode values for open()
Dcl-S O_SHARE_RDONLY Int(10)    INZ(65536);
Dcl-S O_SHARE_WRONLY Int(10)    INZ(131072);
Dcl-S O_SHARE_RDWR Int(10)    INZ(262144);
Dcl-S O_SHARE_NONE Int(10)    INZ(524288);

// File permissions
Dcl-S S_IRUSR      Int(10)    INZ(256); //Read for owner
Dcl-S S_IWUSR      Int(10)    INZ(128); //Write for owner
Dcl-S S_IXUSR      Int(10)    INZ(64); //Execute and Search f
Dcl-S S_IRWXU      Int(10)    INZ(448); //Read, Write, Execute
Dcl-S S_IRGRP      Int(10)    INZ(32); //Read for group
Dcl-S S_IWGRP      Int(10)    INZ(16); //Write for group
Dcl-S S_IXGRP      Int(10)    INZ(8); //Execute and Search f
Dcl-S S_IRWXG      Int(10)    INZ(56); //Read, Write, Execute
Dcl-S S_IROTH      Int(10)    INZ(4); //Read for other
Dcl-S S_IWOTH      Int(10)    INZ(2); //Write for other
Dcl-S S_IXOTH      Int(10)    INZ(1); //Execute and Search f
Dcl-S S_IRWXO      Int(10)    INZ(7); //Read, Write, Execute

// Misc
Dcl-S O_TEXTDATA   Int(10)    INZ(16777216); //text data flag
Dcl-S O_CODEPAGE   Int(10)    INZ(8388608); //code page flag
Dcl-S O_CCSID      Int(10)    INZ(32); //ccsid page flag
Dcl-S O_INHERITMODE Int(10)    INZ(134217728); //inherit mode flag

/ENDIF
/DEFINE IFS_DEFINED

// *************************************************************************
// š                       Program Status Data Structure
// *************************************************************************
// € The following is the full program status data structure. Most fields st
// € with psds, except for the common ones that Fabricut uses.
// *************************************************************************
/if not defined(PSD_DEFINED)
Dcl-Ds psds  psds; //Pgm status DS
  psdsData       Char(429); //The data
  // PROGRAM STATUS DATA STRUCTURE LAYOUT
  // For documentation of Program Status Data Structure fields, see
  // http://publib.boulder.ibm.com/cgi-bin/bookmgr/BOOKS/QB3AGZ03/1.5.2.1?
  // SHELF=QB3AYC08&DT=19990323173815#TBLPROSTA8
  // ======
  // Program name
  psdsPgmNam     Char(10)   OVERLAY(psdsData:001);
  // Status code
  psdsStsCde     Zoned(5:0) OVERLAY(psdsData:011);
  // Previous status code
  psdsStsPrv     Zoned(5:0) OVERLAY(psdsData:016);
  // RPG IV source listing line number or statement number
  psdsStmNbr     Char(8)    OVERLAY(psdsData:021);
  // Name of the RPG IV routine in which the exception or error occurred
  psdsErrRtn     Char(8)    OVERLAY(psdsData:029);
  // Number of parameters passed to this program from the calling pgm
  // (-1 if no parameters)
  psdsParms      Zoned(3:0) OVERLAY(psdsData:037);
  // Exception type (CPF or MCH)
  psdsExcTyp     Char(3)    OVERLAY(psdsData:040);
  // Exception number (message number)
  psdsExcNbr     Char(4)    OVERLAY(psdsData:043);
  // Work area for messages (internal use only)
  psdsMsgWrk     Char(30)   OVERLAY(psdsData:051);
  // Name of library in which the program is located
  psdsPgmLib     Char(10)   OVERLAY(psdsData:081);
  // Retrieved exception data
  psdsExcDta     Char(80)   OVERLAY(psdsData:091);
  ERRMSG1        Char(80)   OVERLAY(psdsData:091);
  // Identification of the exception that caused
  // RNX9001 exception to be signaled
  psdsExcID      Char(4)    OVERLAY(psdsData:171);
  // Name of file on which the last file operation occurred
  // (updated only when an error occurs)
  psdsExcFl      Char(10)   OVERLAY(psdsData:175);
  // Date (*DATE format) the job entered the system
  psdsDATE       Char(8)    OVERLAY(psdsData:191);
  // First 2 digits of a 4-digit year
  psdsYEAR1      Zoned(2:0) OVERLAY(psdsData:199);
  // Name of file on which the last file operation occurred
  // (updated only when an error occurs)
  // For longer file name, see field "psdsExcFl"
  psdsExcFlS     Char(8)    OVERLAY(psdsData:201);
  // Status information on the last file used
  psdsLstFSts    Char(35)   OVERLAY(psdsData:209);
  // Qualififed Job name
  psdsJob        Char(26)   OVERLAY(psdsData:244);
  // Job name
  psdsJobNam     Char(10)   OVERLAY(psdsData:244);
  PSJOB          Char(10)   OVERLAY(psdsData:244);
  WSID           Char(10)   OVERLAY(psdsData:244);
  // User profile name
  psdsUsrNam     Char(10)   OVERLAY(psdsData:254);
  user           Char(10)   OVERLAY(psdsData:254);
  // Job number
  psdsJobNbr     Char(6)    OVERLAY(psdsData:264);
  // Date (in UDATE format) the program started running in the system
  psdsRunDtS     Char(6)    OVERLAY(psdsData:270);
  // Time (in the format hhmmss) the program started running in the system
  psdsRunTmS     Char(6)    OVERLAY(psdsData:276);
  // Time (in the format hhmmss) of the program running
  psdsRunTmR     Char(6)    OVERLAY(psdsData:282);
  // Date (in UDATE format) the program was compiled
  psdsCmpDat     Char(6)    OVERLAY(psdsData:288);
  // Time (in the format hhmmss) the program was compiled
  psdsCmpTme     Char(6)    OVERLAY(psdsData:294);
  // Level of the compiler
  psdsCmpLvl     Char(4)    OVERLAY(psdsData:300);
  // Source file name
  psdsSrcF       Char(10)   OVERLAY(psdsData:304);
  // Source library name
  psdsSrcFLb     Char(10)   OVERLAY(psdsData:314);
  // Source member name
  psdsSrcMbr     Char(10)   OVERLAY(psdsData:324);
  // Program containing procedure
  psdsPrcPgm     Char(10)   OVERLAY(psdsData:334);
  // Module containing procedure
  psdsPrcMod     Char(10)   OVERLAY(psdsData:344);
  // Source Id matching the statement number from positions 21-28
  psdsSrcId1     Zoned(2:0) OVERLAY(psdsData:354);
  // Source Id matching the statement number from positions 228-235
  psdsSrcId2     Zoned(2:0) OVERLAY(psdsData:356);
  // Current user profile name
  psdsUsrPrf     Char(10)   OVERLAY(psdsData:358);
  PARMS *PARMS;
End-Ds;
/ENDIF
/DEFINE PSD_DEFINED

