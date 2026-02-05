**free
// ***************************************************************
// Base Functions
// *************************************************************
//
// Function List
//
// Date Functions
//   #$VDAT    = Validates a date
//   #$ADDDAY  = Add days to a date
//   #$SUBDAY  = Add days to a date
//   #$DDIFF   = Difference between dates in days
//   #$ISWKD   = Determines if a date is a work day
//   #$ADDWD   = Adds a number of work days to a date
//   #$SUBWD   = Subtracts a number of work days from a date
//   #$WDDIFF  = Difference between dates in work days
//   #$YMD8    = Converts MMDDYY to YYYYMMDD date
//   #$MDY6    = Converts YYYYMMDD to MMDDYY date
//   #$DAYOW   = Returns the Day of Week for a Date
//   #$NXTDOW  = Finds the next day of a week from a date
//   #$DOW     = Returns the Day of Week Name
//   #$WOY     = Returns the week of the year
//   #$MNTH    = Returns month name
//   #$DAT     = Returns character date in several formats
//   #$ADDM    = Add months to a date
//   #$SUBM    = Add months to a date
//   #$ADDY    = Add years to a date
//   #$SUBY    = Add years to a date
//   #$CVTDAT  = Converts Character Date to Numeric(8,0)
//   #$PARTITION = Returns the Current Partition
//   #$SYSNAME = Returns the Current System Name
//   #$VPATH = Validates an IFS path.
//   #$USRHOME = Returns a Users Home Directory.
//   #$CCHAR   = Clean Character, removes un-printable chars
//   #$C2H     = Convert a character string to a hex string
//   #$H2C     = Convert a hex string to a character string
//   #$IN      = Checks if a value is in a list, character
//   #$INN     = Checks if a value is in a list, numeric
//
// Time Functions
// An HMS field is defined as 10,0 and contains a length of
// time in HHHHHHMMSS format. It can be stored in a smaller
// field if you do not need that many hours.
//   #$VTIM    = Validates a time
//   #$SEC2HMS = Converts a number of seconds to HHMMSS format
//   #$HMS2SEC = Converts a HMS to Number of Seconds
//   #$TDIFF   = Returns the difference in times in HMS format
//   #$ADDHMS  = Adds 2 HMS fields together
//   #$SUBHMS  = Subtracts 2 HMS
//
// Time Stamp Functions
// A time stamp field is defined as 14,0 and contains data
// in the following format YYYYMMDDHHMMSS
//   #$VTS     = Validates a Timestamp
//   #$TSSET   = Creates a timestamp from a date and time
//   #$TSDATE  = Returns a date from a timestamp field
//   #$TSTIME  = Returns a time from a timestamp field
//   #$TSADDD  = Adds a number of days to a Timestamp
//   #$TSSUBD  = Subtracts a number of days from a Timestamp
//   #$TSADDS  = Adds a number of seconds to a Timestamp
//   #$TSSUBS  = Subtracts a number of seconds from a Timestamp
//   #$TSDDAY  = Returns the difference between Timestamps
//               in days
//   #$TSDSEC  = Returns the difference between Timestamps
//               in seconds
//   #$TSDHMS  = Returns the difference between Timestamps
//               in an HMS field
//
// Other Functions
//   #$CNTR    = Centers Text
//   #$EDTZP   = Edits a zip code to a standard format
//   #$FHTML   = Fix HTML Text
//   #$RVL     = Returns a number from a character string
//   #$UCC     = Returns a string in UCC format
//   #$UCP     = Returns a string in UCP format
//   #$XMLESC  = Escapes special characters in a string for XML
//   #$UPIFY   = Converts to all uppercase
//   #$LOWFY   = Converts to all lowercase
//   #$EDTC    = Edits a number variable
//   #$EDTP    = Edits a phone number (Numeric)
//   #$EDTP2   = Edits a phone number (Alpha)
//   #$CMD     = Runs a command
//   #$DSPWIN  = Displays text in a window
//   #$LAST    = Returns the last part of a string
//   #$RNDUP   = Rounds a number up
//   #$RND05   = Rounds to the next 0.05
//   #$SPLIT   = Splits a sting into words
//   #$TESTN   = Tests a field for numeric data
//   #$URIESC  = Escapes out URI special characters
//   #$URIDESC = Un-Escapes URI special characters
//   #$VEML    = Validates an email address
//   #$ISFILE  = Test if a file exists
//   #$ISLIB   = Test if a library exists
//   #$ISOUTQ  = Test if an outq exists
//   #$JSONESC = Escapes special characters in a JSON string
//   #$SCANR   = Scans a string from the right
//   #$SQLSTT  = Check the last SQL statements status
//   #$URLTST  = Check to see if a resource at a URL exists
//   #$VPHN    = Validates a phone number
//   #$XLDATE  = Converts an Excel date value to YYYYMMDD
//   #$XLDTTM  = Converts an Excel time value to HHMMSS
//   #$XLTIME  = Converts an Excel date/time value to YMDHMS
//   #$C1ST    = Start each word with an uppercase letter
//   #$SQL2JSON= get JSON string from SQL output
//   #$ACTJOB  = See if an active job exists
//   #$BLDSCH  = Build Multi Word Search String for SQL
//   #$INTACT - See if a Job is Interactive
//   #$WORDWRP2= Word Wrap a string and return an array
//   #$WORDWRAP= Word Wrap a string and return a string
//   #$PARITION= Returns the Partition Number
//   #$SYSNAME = Returns the System Name
//   #$VPATH   = Validates an IFS Path
//   #$USRHOME = Get a Users Home Directory
//   #$DBLQ    = Doubles Quotes in a String
//   #$SCANRPL = Same as %SCANRPL without PDM Errors
//   #$FIXPRMLST= Fix Parameter List
//   #$WAIT     = Delay job for a number of seconds
//   #$ISOBJ   = Test if an object exists
//   #$ISMBR   = Test if a member exists
//   #$GETCNTRY= Get the country based on the state
//   #$ALPH      = converts a number to readable text
//   #$GetKeys   = returns key fields for a file
//   #$RtvMbrD   = Retrieve Member Description
//
// *************************************************************
// If you add modules to this source you need to update the
// binder language in QSRC/BASFNCN1. Do not change the order
// of these procedures, only add to the bottom. If you need to
// change parameters, all programs will have to be recompiled.
//
// If this needs to be built live it can be done. Just make
// sure the function list does not change and that no
// parameters change and then run the following commands:
//
// CRTSQLRPGI OBJ(QTEMP/BASFNCV1) SRCFILE(APLLIB/QSRC)
//            OBJTYPE(*MODULE) DBGVIEW(*SOURCE)
// CRTSRVPGM  SRVPGM(APLLIB/BASFNCV1) MODULE(QTEMP/BASFNCV1)
//            TEXT('APLLIB Base Functions') EXPORT(*SRCFILE)
//            STGMDL(*INHERIT) SRCFILE(APLLIB/QSRC)
//            SRCMBR(BASFNCN1)
// DLTMOD     MODULE(QTEMP/BASFNCV1)
//
// *************************************************************

Ctl-Opt NoMain Option(*NoDebugIO:*SrcStmt) StgMdl(*Inherit);
/Copy QSRC,BASFNCV1PR
// INCLUDE LIBHTTP3/QRPGLESRC,HTTPAPI_H

// Prototype for QMHRTVM API
Dcl-Pr retrieve_MessageFromMsgF extPgm('QMHRTVM');
  msgInfo           char(3000) options(*varSize);
  msgInfoLen        int(10) const;
  formatName        char(8) const;
  msgId             char(7) const;
  msgF              char(20) const;
  replacement       char(500) const;
  replacementLength int(10) const;
  replaceSubValues  char(10) const;
  returnFCC         char(10) const;
  usec              char(256);
End-Pr;

// Format RTVM0300 for data returned from QMHRTVM
Dcl-Ds RTVM0300 qualified;
  bytesreturned int(10);
  bytesAvail    int(10);
  severity      int(10);
  alertIndex    int(10);
  alertOption   char(9);
  logIndicator  char(1);
  messageId     char(7);
  *n            char(3);
  noSubVarFmts  int(10);
  CCSIDIndText  int(10);
  CCSIDIndRep   int(10);
  CCSIDTextRet  int(10);
  dftRpyOffset  int(10);
  dftRpyLenRet  int(10);
  dftRpyLenAvl  int(10);
  messageOffset int(10);
  messageLenRet int(10);
  messageLenAvl int(10);
  helpOffset    int(10);
  helpLenRet    int(10);
  helpLenAvl    int(10);
  SVFOffset     int(10);
  SVFLenRet     int(10);
  SVFLenAvl     int(10);
  data          char(5000);
End-Ds;

Dcl-Ds apiError qualified len(256) inz;
  bytesProvides int(10) inz(256) pos(1);
  bytesAvailable int(10) pos(5);
  messageID char(7) pos(9);
  errNbr char(1) pos(16);
  messageDta char(100) pos(17);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO,
                DynUsrPrf = *owner, CloSQLCsr = *endmod,SrtSeq = *langidshr;

// ****************************************************************
// #$ADDDAY - Add Days
// Procedure to add a number of days to a date
//        INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//                #$DAYS = NUMBER OF DAYS TO ADD TO DATE
//        RETURN:        = NEW DATE IN THE ENTRY DATES FORMAT
Dcl-Proc #$ADDDAY EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$DAYS         Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)+%days(#$DAYS) ):
                         *MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)+%days(#$DAYS) ):*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$SUBDAY - Subtract Days
// Procedure to subtract a number of days from a date
//            INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//                    #$DAYS = NUMBER OF DAYS TO SUBTRACT
//           RETURN:         = NEW DATE IN THE ENTRY DATES
//                             FORMAT
Dcl-Proc #$SUBDAY EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$DAYS         Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)-%days(#$DAYS) )
                          :*MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)-%days(#$DAYS) ):*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$ADDM Adds a number of months to a date.
//
//  INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$MTHS = NUMBER OF MONTHS TO ADD TO DATE
// RETURN:         = NEW DATE IN THE ENTRY DATES
//                   FORMAT
Dcl-Proc #$ADDM EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$MONTHS       Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)+%months(#$MONTHS) )
                           :*MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)+%months(#$MONTHS) )
                           :*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$SUBM Subtracts a number of months from a date.
//
//  INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$DAYS = NUMBER OF DAYS TO ADD TO DATE
// RETURN:         = NEW DATE IN THE ENTRY DATES
//                   FORMAT
Dcl-Proc #$SUBM EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$MONTHS       Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)-%months(#$MONTHS) ):
                           *MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)-%months(#$MONTHS) )
                          :*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$ADDY Adds a number of years to a date.
//
//  INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$YEARS= NUMBER OF YEARS TO ADD TO A DATE
// RETURN:         = NEW DATE IN THE ENTRY DATES FORMAT
Dcl-Proc #$ADDY EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$YEARS        Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)+%years(#$YEARS) ):
                           *MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)+%years(#$YEARS) )
                         :*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$SUBY Subtracts a number of years from a date.
//
//  INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$YEARS= NUMBER OF YEARS TO SUBTRACT FROM DATE
// RETURN:         = NEW DATE IN THE ENTRY DATES FORMAT
Dcl-Proc #$SUBY EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$YEARS        Zoned(6:0) CONST;
  End-Pi;
  Dcl-S NEWDATE      Zoned(8:0);

  If #$DATE<1000000;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE:*MDY)-%years(#$YEARS) )
                          :*MDY0):6:0);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      NEWDATE=%dec(%char(( %date(#$DATE)-%years(#$YEARS) ):*ISO0):8:0);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return NEWDATE;

End-Proc;

// ***************************************************************
// #$DDIFF  - Difference between two dates in days
//        INPUT:  #$DATE1 = DATE IN YYYYMMDD OR MMDDYY FORMAT
//                #$DATE2 = DATE IN YYYYMMDD OR MMDDYY FORMAT
//       RETURN:          = NUMBER OF DAYS BETWEEN THE DATES
Dcl-Proc #$DDIFF EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE1        Zoned(8:0) CONST;
    #$DATE2        Zoned(8:0) CONST;
  End-Pi;
  Dcl-S DATE1        Date;
  Dcl-S DATE2        Date;
  Dcl-S #$DAYS       Zoned(8:0);

  // GET DATE 1 IN A DATE FIELD
  If #$DATE1<1000000;
    Monitor;
      DATE1=%date(#$DATE1:*MDY);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      DATE1=%date(#$DATE1);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  // GET DATE 2 IN A DATE FIELD
  If #$DATE2<1000000;
    Monitor;
      DATE2=%date(#$DATE2:*MDY);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      DATE2=%date(#$DATE2);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return %diff(DATE2:DATE1:*DAYS);

End-Proc;

// ****************************************************************
// #$ISWKD  - Determines if a date is a work day
//  INPUT:  #$DATE  = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$ALSAT = Optional, Pass a 1 to accept Saturdays
//                    as work days
// RETURN:          = BOOLEAN TRUE OR FALSE
Dcl-Proc #$ISWKD EXPORT;
  Dcl-Pi *N Ind;
    #$DATE         Zoned(8:0) CONST;
    #$ALSAT        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);

  End-Pi;
  Dcl-S ALSAT        Zoned(1:0) INZ(0);
  Dcl-S DATE         Zoned(8:0);
  Dcl-S YEAR         Zoned(4:0);
  Dcl-S MMDD         Zoned(4:0);
  Dcl-S DAY          Zoned(2:0);
  Dcl-S MON          Zoned(2:0);
  Dcl-S DOFW         Zoned(1:0);
  Dcl-S yymmdd       Zoned(6:0);
  Dcl-S yy           Zoned(2:0);

  If %parms() > 1 AND %addr(#$ALSAT) <> *NULL;
    If #$ALSAT = 1;
      ALSAT=1;
    EndIf;
  EndIf;

  // IF A SUNDAY RETURN NO
  If #$DAYOW(#$DATE)=6;
    Return *OFF;
  EndIf;

  // IF A SATURDAY AND SATURDAYS ARE ALLOWED RETURN NO
  If #$DAYOW(#$DATE)=5;
    If ALSAT=1;
      Return *ON;
    Else;
      Return *OFF;
    EndIf;
  EndIf;

  // GET DAY,MONTH AND YEAR FROM THE DATE IN EITHER DATE FORMAT
  If #$DATE>=1000000;
    YEAR = %int(#$DATE/10000);
    MMDD = %rem(#$DATE:10000);
    MON = %int(MMDD/100);
    DAY = %rem(MMDD:100);
  Else;
    yymmdd = #$DATE;
    yy = %int(yymmdd/10000);
    If YY<50;
      YEAR=2000+yy;
    Else;
      YEAR=1900+yy;
    EndIf;
    MMDD = %rem(#$DATE:10000);
    MON = %int(MMDD/100);
    DAY = %rem(MMDD:100);
  EndIf;

  // BUILD THE 8 DIGIT DATE INCASE A MMDDYY WAS PASSED
  DATE=YEAR*10000+MON*100+DAY;

  // IF THE MONTH DOES NOT HAVE ANY HOLIDAYS IN IT , SKIP
  If MON=2 OR MON=3 OR MON=4 OR MON=6 OR MON=8 OR MON=10;
    Return *ON;
  EndIf;

  // GET THE DAY OF THE WEEK
  DOFW = #$DAYOW(#$DATE);

  // SKIP NEW YEARS, 12-31 IF A FRIDAY OR 1-1 OR 1-2 IF A MONDAY
  If (MMDD=1231 AND DOFW=4) OR (MMDD=0101) OR (MMDD=0102 AND DOFW=0);
    Return *OFF;
  EndIf;

  // SKIP MEMORIAL, LAST MONDAY IN MAY, 5/25-5/31 IF A MONDAY
  If MMDD>=0525 AND MMDD<=0531 AND DOFW=0;
    Return *OFF;
  EndIf;

  // SKIP JULY 4TH, 7/3 IF FRIDAY, 7/4, 7/5 IF A MONDAY
  If (MMDD=0703 AND DOFW=4) OR (MMDD=0704) OR (MMDD=0705 AND DOFW=0);
    Return *OFF;
  EndIf;

  // SKIP LABOR DAY, FIRST MONDAY IN SEPTEMBER, 9/1-9/6 IF A MONDAY
  If MMDD>=0901 AND MMDD<=0906 AND DOFW=0;
    Return *OFF;
  EndIf;

  // THANKS GIVING DAY 1, 11/22-11/29 IF A THURSDAY
  If MMDD>=1122 AND MMDD<=1129 AND DOFW=3;
    Return *OFF;
  EndIf;

  // THANKS GIVING DAY 2, 11/23-11/30 IF A FRIDAY
  If MMDD>=1123 AND MMDD<=1130 AND DOFW=4;
    Return *OFF;
  EndIf;

  // WINTER HOLIDAY, 12/24 IF FRIDAY, 12/25, 12/26 IF A MONDAY
  If (MMDD=1224 AND DOFW=4) OR (MMDD=1225) OR (MMDD=1226 AND DOFW=0);
    Return *OFF;
  EndIf;

  // WINTER HOLIDAY 2, 12/26 IF FRIDAY
  If (MMDD=1226 AND DOFW=4);
    Return *OFF;
  EndIf;

  Return *ON;

End-Proc;

// ****************************************************************
// #$ADDWD  - Adds a number of work days to a date
//  INPUT:  #$DATE  = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$DAYS  = THE NUMBER OF WORK DAYS TO ADD
// RETURN:          = THE NEW DATE
Dcl-Proc #$ADDWD EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$DATE         Packed(8:0) CONST;
    #$DAYS         Packed(8:0) CONST;

  End-Pi;
  Dcl-S DATE         Packed(8:0);
  Dcl-S X            Zoned(8:0);

  If #$DAYS=0;
    Return #$DATE;
  EndIf;

  If #$DAYS < 0;
    Return #$SUBWD(#$DATE:1);
  EndIf;

  // ADD ONE DAY AT A TIME, ONLY COUNT THEM IF THEY ARE WORKDAYS
  DATE=#$DATE;
  Clear X;
  DoW X<#$DAYS;
    DATE=#$ADDDAY(DATE:1);
    If #$ISWKD(DATE);
      X = X + 1;
    EndIf;
  EndDo;

  Return DATE;

End-Proc;

// ****************************************************************
// #$SUBWD  - Subtracts a number of work days from a date
//  INPUT:  #$DATE  = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$DAYS  = THE NUMBER OF WORK DAYS TO SUBTRACT
// RETURN:          = THE NEW DATE
Dcl-Proc #$SUBWD EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$DATE         Packed(8:0) CONST;
    #$DAYS         Packed(8:0) CONST;

  End-Pi;
  Dcl-S DATE         Packed(8:0);
  Dcl-S X            Zoned(8:0);

  If #$DAYS=0;
    Return #$DATE;
  EndIf;

  If #$DAYS<0;
    Return #$ADDWD(#$DATE:#$DAYS*-1);
  EndIf;

  // ADD ONE DAY AT A TIME, ONLY COUNT THEM IF THEY ARE WORKDAYS
  DATE=#$DATE;
  Clear X;
  DoW X<#$DAYS;
    DATE=#$SUBDAY(DATE:1);
    If #$ISWKD(DATE);
      X = X + 1;
    EndIf;
  EndDo;

  Return DATE;

End-Proc;

// ****************************************************************
// #$WDDIFF - Finds the number of work days between two dates
//  INPUT:  #$DATE1 = DATE IN YYYYMMDD OR MMDDYY FORMAT
//          #$DATE2 = DATE IN YYYYMMDD OR MMDDYY FORMAT
// RETURN:          = THE NUMBER OF WORK DAYS BETWEEN THE DATES
Dcl-Proc #$WDDIFF EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$DATE1        Packed(8:0) CONST;
    #$DATE2        Packed(8:0) CONST;

  End-Pi;
  Dcl-S DATE1        Packed(8:0);
  Dcl-S DATE2        Packed(8:0);
  Dcl-S DATE         Packed(8:0);
  Dcl-S X            Zoned(8:0);

  // CONVERT THE DATES TO YYYYMMDD IF PASSED AS MMDDYY FOR COMPARISON
  If #$DATE1<1000000;
    DATE1=#$YMD8(#$DATE1);
  Else;
    DATE1=#$DATE1;
  EndIf;
  If #$DATE2<1000000;
    DATE2=#$YMD8(#$DATE2);
  Else;
    DATE2=#$DATE2;
  EndIf;

  If DATE1=DATE2;
    Return 0;
  EndIf;

  // LOOK AT EACH DAY BETWEEN THE TWO DATES, ADD EACH ONE THAT IS A WORKDAY
  DATE=DATE1;
  Clear X;
  DoU DATE=DATE2;
    If DATE1<DATE2;
      DATE=#$ADDDAY(DATE:1);
      If #$ISWKD(DATE);
        X = X + 1;
      EndIf;
    EndIf;
    If DATE1>DATE2;
      DATE=#$SUBDAY(DATE:1);
      If #$ISWKD(DATE);
        X = X - 1;
      EndIf;
    EndIf;
  EndDo;

  Return X;

End-Proc;

// ****************************************************************
// #$YMD8   - Converts a MMDDYY date to a YYYYMMDD date
//  INPUT:  #$DATE  = DATE IN MMDDYY FORMAT
// RETURN:          = DATE IN YYYYMMDD FORMAT
Dcl-Proc #$YMD8 EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$DATE         Packed(6:0) CONST;
  End-Pi;

  Dcl-S DATE         Packed(8:0);
  Dcl-S YEAR         Zoned(4:0);
  Dcl-S MMDD         Zoned(4:0);
  Dcl-S YY           Zoned(2:0);

  // IF A ZERO DATE IS PASSED IN, RETRUN A ZERO DATE
  If #$DATE = 0;
    Return 0;
  EndIf;

  // GET DAY,MONTH AND YEAR FROM THE DATE
  YY = %rem(#$DATE:100);
  If YY<50;
    YEAR=2000+YY;
  Else;
    YEAR=1900+YY;
  EndIf;
  MMDD = %int(#$DATE/100);

  // RETURN THE YYYYMMDD DATE
  Return YEAR*10000+MMDD;

End-Proc;

// ****************************************************************
// #$MDY6   - Converts a YYYYMMDD date to a MMDDYY date
//  INPUT:  #$DATE  = DATE IN YYYYMMDD FORMAT
// RETURN:          = DATE IN MMDDYY FORMAT
Dcl-Proc #$MDY6 EXPORT;
  Dcl-Pi *N Packed(6:0);
    #$DATE         Packed(8:0) CONST;
  End-Pi;

  Dcl-S DATE         Packed(8:0);
  Dcl-S YEAR         Zoned(4:0);
  Dcl-S MMDD         Zoned(4:0);
  Dcl-S YY           Zoned(2:0);

  // GET DAY,MONTH AND YEAR FROM THE DATE
  YEAR = %int(#$DATE/10000);
  YY = %rem(YEAR:100);
  MMDD = %rem(#$DATE:10000);

  // RETURN THE YYYYMMDD DATE
  Return MMDD*100+YY;

End-Proc;

// ****************************************************************
// #$DAYOW - Day of Week
// Procedure to return the day of the week
//           INPUT:  #$DATE = DATE IN YYYYMMDD FORMAT
//         RETURNS:  0      = Day of Week
//   0 = Monday   1 = Tuesday    2 = Wednesday  3 = Thursday
//   4 = Friday   5 = Saturday   6 = Sunday
Dcl-Proc #$DAYOW EXPORT;
  Dcl-Pi *N Zoned(1:0);
    #$DATE         Zoned(8:0) CONST;
  End-Pi;

  Dcl-S #$DAY        Zoned(1:0);

  If #$DATE<1000000;
    Monitor;
      #$DAY=%rem(%diff(%date(#$DATE:*MDY) :d'0001-01-01':*DAYS):7);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      #$DAY=%rem(%diff(%date(#$DATE) :d'0001-01-01':*DAYS):7);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  Return #$DAY;

End-Proc;

// ****************************************************************
// #$DOW - Day of Week Name
// Procedure to return the day of the week name
//            INPUT:  #$DATE = Day number 0=Monday -6  or
//                             Date in mmddyy format or
//                             Date in YYYYMMDD format
//           #$LEN = Optional, Pass a 3 for three character
//                   day code or leave blank
//           #$CAS = Optional, Pass a 1 to return mixed case
//                   Months
//          RETURNS:  Day of Week Text
//
//   EXAMPLES IN FREE FORMAT
//   #$DOW(3)                      RETURNS 'WEDNESDAY
//   #$DOW(180919)                 RETURNS 'WEDNESDAY
//   #$DOW(20180919)               RETURNS 'WEDNESDAY
//   #$DOW(3:3)                    RETURNS 'WED
//   #$DOW(091918:3)               RETURNS 'WED
//   #$DOW(20180919:3)             RETURNS 'WED
//   #$DOW(3:3:1)                  RETURNS 'Wed
//   #$DOW(091918:3:1)             RETURNS 'Wed
//   #$DOW(20180919:3:1)           RETURNS 'Wed
//   #$DOW(3:0:1)                  RETURNS 'Wednesday
//   #$DOW(091918:0:1)             RETURNS 'Wednesday
//   #$DOW(20180919:0:1)           RETURNS 'Wednesday
Dcl-Proc #$DOW EXPORT;
  Dcl-Pi *N Char(10);
    #$DATE         Zoned(8:0) CONST;
    #$LEN          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$CAS          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$DAY        Zoned(1:0);
  Dcl-S short Ind;
  Dcl-S mixed Ind;

  short = *OFF;
  If %parms() > 1 AND %addr(#$LEN) <> *NULL;
    If #$LEN = 3;
      short = *ON;
    EndIf;
  EndIf;

  mixed = *OFF;
  If %parms() > 2 AND %addr(#$CAS) <> *NULL;
    If #$CAS = 1;
      mixed = *ON;
    EndIf;
  EndIf;

  If #$DATE>6;
    Monitor;
      If #$DATE>1000000;
        #$DAY=%rem(%diff(%date(#$DATE) :d'0001-01-01':*DAYS):7);
      Else;
        #$DAY=%rem(%diff(%date(#$DATE:*MDY) :d'0001-01-01':*DAYS):7);
      EndIf;
    On-Error;
      Return 'ERROR';
    EndMon;
  EndIf;

  If #$DAY=0 AND short and mixed;
    Return 'Mon';
  ElseIf #$DAY=0 and short;
    Return 'MON';
  ElseIf #$DAY=0 and mixed;
    Return 'Monday';
  ElseIf #$DAY=0;
    Return 'MONDAY';
  ElseIf #$DAY=1 AND short and mixed;
    Return 'Tue';
  ElseIf #$DAY=1 AND short;
    Return 'TUE';
  ElseIf #$DAY=1 and mixed;
    Return 'Tuesday';
  ElseIf #$DAY=1 ;
    Return 'TUESDAY';
  ElseIf #$DAY=2 AND short and mixed;
    Return 'Wed';
  ElseIf #$DAY=2 AND short;
    Return 'WED';
  ElseIf #$DAY=2 and mixed;
    Return 'Wednesday';
  ElseIf #$DAY=2 ;
    Return 'WEDNESDAY';
  ElseIf #$DAY=3 AND short and mixed;
    Return 'Thu';
  ElseIf #$DAY=3 AND short;
    Return 'THU';
  ElseIf #$DAY=3 and mixed;
    Return 'Thursday';
  ElseIf #$DAY=3;
    Return 'THURSDAY';
  ElseIf #$DAY=4 AND short and mixed;
    Return 'Fri';
  ElseIf #$DAY=4 AND short;
    Return 'FRI';
  ElseIf #$DAY=4 and mixed;
    Return 'Friday';
  ElseIf #$DAY=4;
    Return 'FRIDAY';
  ElseIf #$DAY=5 AND short and mixed;
    Return 'Sat';
  ElseIf #$DAY=5 AND short;
    Return 'SAT';
  ElseIf #$DAY=5 and mixed;
    Return 'Saturday';
  ElseIf #$DAY=5;
    Return 'SATURDAY';
  ElseIf #$DAY=6 AND short and mixed;
    Return 'Sun';
  ElseIf #$DAY=6 AND short;
    Return 'SUN';
  ElseIf #$DAY=6 and mixed;
    Return 'Sunday';
  ElseIf #$DAY=6;
    Return 'SUNDAY';
  Else;
    Return %trim(%editc(#$DAY:'Z'));
  EndIf;

End-Proc;

// ****************************************************************
// #$DAT - Character dates in several formats
//  to return the day of the week name
//            INPUT:  #$DATE = Date in mmddyy format or
//                             Date in YYYYMMDD format
//           #$FMT = Optional, blanks is format 1, see examples
//                   below for format types
//           #$CAS = Optional, Pass a 1 to return mixed case
//          RETURNS:  Character representation of a date
//
//   EXAMPLES             Output
//   #$DATE(180919)       WEDNESDAY, SEPTEMBER 19, 2018
//   #$DATE(20180919)     WEDNESDAY, SEPTEMBER 19, 2018
//   #$DATE(180919:2)     SEPTEMBER 19, 2018
//   #$DATE(20180919:2)   SEPTEMBER 19, 2018
//   #$DATE(180919:1:1)   Wednesday, September 19, 2018
//   #$DATE(20180919:1:1) Wednesday, September 19, 2018
//   #$DATE(180919:2:1)   September 19, 2018
//   #$DATE(20180919:2:1) September 19, 2018
//
Dcl-Proc #$DAT EXPORT;
  Dcl-Pi *N Varchar(30);
    #$DATE         Zoned(8:0) CONST;
    #$PSFMT        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$PSCAS        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;

  Dcl-S #$FMT        Zoned(1:0);
  Dcl-S #$CAS        Zoned(1:0);
  Dcl-S DATE         Varchar(30);
  Dcl-S YEAR         Zoned(4:0);
  Dcl-S DAY          Zoned(2:0);
  Dcl-S MMDD         Zoned(4:0);
  Dcl-S YY           Zoned(2:0);
  Dcl-S yymmdd       Zoned(6:0);

  DATE=' ';

  // GET DAY AND YEAR FROM THE DATE IN EITHER DATE FORMAT
  If #$DATE>=1000000;
    YEAR = %int(#$DATE/10000);
    MMDD = %rem(#$DATE:10000);
    DAY = %rem(#$DATE:100);
  Else;
    yymmdd = #$DATE;
    YY = %int(yymmdd/10000);
    If YY<50;
      YEAR=2000+YY;
    Else;
      YEAR=1900+YY;
    EndIf;
    MMDD = %rem(#$DATE:10000);
    DAY = %rem(#$DATE:100);
  EndIf;

  If %parms() > 1 AND %addr(#$PSFMT) <> *NULL;
    #$FMT= #$PSFMT;
  Else;
    #$FMT = 1;
  EndIf;

  If %parms() > 2 AND %addr(#$CAS) <> *NULL;
    #$CAS= #$PSCAS;
  Else;
    #$CAS = 0;
  EndIf;

  // IF FORMAT 1 START WITH THE DAY NAME
  If #$FMT=1;
    DATE=%trim(#$DOW(#$DATE:0:#$CAS))+',';
  EndIf;

  // ADD MONTH NAME
  DATE=%trim(DATE) + ' ' + %trim(#$MNTH(#$DATE:0:#$CAS));

  // ADD DAY NUMBER
  DATE=%trim(DATE) + ' ' + %editc(DAY:'Z') + ',';

  // ADD YEAR NUMBER
  DATE=%trim(DATE) + ' ' + %trim(%editc(YEAR:'Z'));

  Return DATE;

End-Proc;

// ****************************************************************
// #$NXTDOW - Next Day Of Week
//
// Returns the next date for a specified day of the week.
//
// If the passed date is the same day as the requested day of
// the week it will return the passed date.
//
//            INPUT:  #$DATE = DATE IN YYYYMMDD OR MMDDYY FORMAT
//                    #$DOW  = DAY OF THE WEEK WE WANT
//    0 = Monday   1 = Tuesday    2 = Wednesday  3 = Thursday
//    4 = Friday   5 = Saturday   6 = Sunday
//          RETURNS:  THE DATE
//
// Example #$NXTDOW(20180918:4) = 20180921
//         20180918 is a Tuesday, we requested the next
//         Friday date which is 20180921
//
Dcl-Proc #$NXTDOW EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Zoned(8:0) CONST;
    #$DAY          Zoned(1:0) CONST;
  End-Pi;
  Dcl-S #$CURDAY     Zoned(1:0);
  Dcl-S #$DAYS       Zoned(1:0);

  // GET CURRENT DAY OF WEEK
  If #$DATE<1000000;
    Monitor;
      #$CURDAY=%rem(%diff(%date(#$DATE:*MDY) :d'0001-01-01':*DAYS):7);
    On-Error;
      Return -1;
    EndMon;
  Else;
    Monitor;
      #$CURDAY=%rem(%diff(%date(#$DATE) :d'0001-01-01':*DAYS):7);
    On-Error;
      Return -1;
    EndMon;
  EndIf;

  // CALCULATE THE NUMBER OF DAYS TO THE NEXT DOW
  If #$CURDAY>#$DAY;
    #$DAYS=#$DAY-#$CURDAY+7;
  Else;
    #$DAYS=#$DAY-#$CURDAY;
  EndIf;

  If #$DATE<1000000;
    Return %dec(%char(( %date(#$DATE:*MDY)+%days(#$DAYS) ):*MDY0):6:0);
  Else;
    Return %dec(%char(( %date(#$DATE)+%days(#$DAYS) ):*ISO0):8:0);
  EndIf;

End-Proc;

// ****************************************************************
// #$CNTR - Center Text
// Centers text based on a field length.
//
//        INPUT:  #$TEXT = Some text that needs to be centered
//                #$LEN  = Length of the output field
//      RETURNS:  The Text Centered to the Output Fields Length
//
// Example ERM=#$CNTR('SOME TEXT':50)
//     ERM='                 SOME TEXT                     '
//
Dcl-Proc #$CNTR EXPORT;
  Dcl-Pi *N Varchar(100);
    #$TXT          Varchar(100) VALUE;
    #$LEN          Int(10)    VALUE;
  End-Pi;

  Dcl-S #$OUT        Varchar(100);
  Dcl-S #$POS        Int(10);

  // CHECK IF INPUT STRING IS BIGGER THAN DESIRED OUTPUT
  #$TXT = %trim(#$TXT);
  If %len(#$TXT) > #$LEN;
    %len(#$TXT) = #$LEN;
  EndIf;

  // FIND POSITION OF CENTERED STRING IN OUTPUT
  EVAL(H) #$POS = (#$LEN - %len(#$TXT))/2 + 1;

  // BUILD AND RETURN CENTERED OUTPUT STRING
  %len(#$OUT) = #$LEN;
  %subst(#$OUT:#$POS) = #$TXT;
  Return #$OUT;

End-Proc;

// ****************************************************************
// #$EDTZP - Edit a zip code to a standard format
// Centers text based on a field length.
//
//        INPUT:  #$ZIPC = CHARACTER FIELD CONTAINING ZIP CODE
//      RETURNS:  EDITED ZIP CODE
//
// Example #$EDTZP('123546789')='12345-6789'
// EXAMPLES
//  INPUT        OUTPUT
//  123451234    12345-1234       ADDE - AT EXTENSION
//      12345    12345            LEFT JUSTIFY
//  123450000    12345            REMOVE 0000 EXTENSION
//  1234500000   12345            REMOVE 00000
//  XXXXXXXXX    XXXXXXXXXX       OTHERWISE DON'T CHANGE
//
Dcl-Proc #$EDTZP EXPORT;
  Dcl-Pi *N Char(10);
    #$ZIPC         Char(10)   VALUE;
  End-Pi;

  Dcl-S ZIP          Char(1)    DIM(10);
  Dcl-S ZI2          Char(1)    DIM(10);
  Dcl-S TST         Packed(10:0);

  // LEFT JUSTIFY
  #$ZIPC=%trim(#$ZIPC);

  // CHECK FOR NON NUMBERIC DATA, IF FOUND RETURN ORIGINAL VALUE
  Monitor;
    TST = %dec(%trim(#$ZIPC):10:0);
  On-Error;
    Return #$ZIPC;
  EndMon;

  // LEAVE IF EXTENSION = '    '
  If %subst(#$ZIPC:6:5)=' ';
    Return #$ZIPC;
  EndIf;

  // BLANK 0000 OR 00000 EXTENSION AND LEAVE
  If %subst(#$ZIPC:6:5)='0000 ' OR %subst(#$ZIPC:6:5)='00000';
    #$ZIPC=%subst(#$ZIPC:1:5);
    Return #$ZIPC;
  EndIf;

  // IF LAST DIGIT IS BLANKS, ADD A DASH
  If %subst(#$ZIPC:10:1)=' ';
    #$ZIPC=%subst(#$ZIPC:1:5)+'-'+ %subst(#$ZIPC:6:4);
  EndIf;

  Return #$ZIPC;

End-Proc;

// ****************************************************************
// #$FHTML - Fix HTML Text
// This procedure replaces double spaces with &nbsp
// and replaces the following characters
//     < to &lt;        > to &gt;     & to &amp;
//     ¢ to &cent;      £ to &pound;  ¥ to &yen;
//     " to &quot;      ' to &apos;   © to &copy;
//     ® to &reg;
//
//        INPUT:  #$IN = String in
//      RETURNS:  Fixed String
//
// Example #$FHTML('<DATA>')='&ltDATA&gt'
//
Dcl-Proc #$FHTML EXPORT;
  Dcl-Pi *N Varchar(2048);
    #$IN           Varchar(2048) VALUE;
  End-Pi;

  #$IN=%trimr(#$IN);

  // Replace & with &amp;, must be done first or will mess up all others
  #$IN=%scanrpl('&':'&amp':#$IN);

  // remove double spaces, replace with space plus &nbsp
  #$IN=%scanrpl('  ':' &nbsp':#$IN);

  // remove "&nbsp ", replace with 2 &nbsp
  #$IN=%scanrpl('&nbsp ':'&nbsp&nbsp':#$IN);

  // Replace all others
  #$IN=%scanrpl('<':'&lt':%trim(#$IN));
  #$IN=%scanrpl('>':'&gt':%trim(#$IN));
  #$IN=%scanrpl('"':'&quot':%trim(#$IN));
  #$IN=%scanrpl('''':'&apos':%trim(#$IN));
  #$IN=%scanrpl('¢':'&cent':%trim(#$IN));
  #$IN=%scanrpl('£':'&pound':%trim(#$IN));
  #$IN=%scanrpl('¥':'&yen':%trim(#$IN));
  #$IN=%scanrpl('©':'&copy':%trim(#$IN));
  #$IN=%scanrpl('®':'&reg':%trim(#$IN));

  Return #$IN;

End-Proc;

// ****************************************************************
// #$MNTH - RETURNS MONTH NAME
// #$MNTH(Month {: Length {: Case } }
// This procedure accepts a month number or MMDDY date or
// YYYYMMDD date and returns eith the full month name or the
// month abbreviation.
//
//   INPUT:  #$MTH = String in, month 1-12, MMDDYY or YYYYMMDD
//           #$LEN = Optional, Pass a 3 for three character
//                   Month code or leave blank
//           #$CAS = Optional, Pass a 1 to return mixed case
//                   Months
//      RETURNS:  Months Name or Abbreviation
//
//   EXAMPLES IN FREE FORMAT
//   #$MNTH(1)                      RETURNS 'JANUARY
//   #$MNTH(011210)                 RETURNS 'JANUARY
//   #$MNTH(20100112)               RETURNS 'JANUARY
//   #$MNTH(1:3)                    RETURNS 'JAN
//   #$MNTH(011210:3)               RETURNS 'JAN
//   #$MNTH(20100112:3)             RETURNS 'JAN
//   #$MNTH(1:3:1)                  RETURNS 'Jan
//   #$MNTH(011210:3:1)             RETURNS 'Jan
//   #$MNTH(20100112:3:1)           RETURNS 'Jan
//   #$MNTH(1:0:1)                  RETURNS 'January
//   #$MNTH(011210:0:1)             RETURNS 'January
//   #$MNTH(20100112:0:1)           RETURNS 'January
//
Dcl-Proc #$MNTH EXPORT;
  Dcl-Pi *N Varchar(10);
    #$MTH          Zoned(8:0) CONST;
    #$LEN          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$CAS          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S MTH          Zoned(6:0);
  Dcl-S mmdd         Zoned(4:0);
  Dcl-S mm           Zoned(2:0);
  Dcl-S short Ind;
  Dcl-S mixed Ind;


  Clear short;
  Clear mixed;

  If %parms() > 1 AND %addr(#$LEN) <> *NULL;
    If #$LEN = 3;
      short = *ON;
    EndIf;
  EndIf;

  If %parms() > 2 AND %addr(#$CAS) <> *NULL;
    If #$CAS = 1;
      mixed = *ON;
    EndIf;
  EndIf;

  If #$MTH > 13;
    If #$MTH > 1000000;
      mmdd = %int(#$MTH/10000);
      mm = %int(mmdd/100);
      MTH = mm;
    Else;
      mmdd = %rem(#$MTH:10000);
      mm = %int(mmdd/100);
      MTH = mm;
    EndIf;
  Else;
    MTH = #$MTH;
  EndIf;

  If MTH = 1 and short and mixed;
    Return 'Jan';
  ElseIf MTH = 1 and short;
    Return 'JAN';
  ElseIf MTH = 1 AND mixed;
    Return 'January';
  ElseIf MTH = 1;
    Return 'JANUARY';
  ElseIf MTH = 1 and short and mixed;
    Return 'JAN';
  ElseIf MTH = 1 and short;
    Return 'JAN';
  ElseIf MTH = 2 and short and mixed;
    Return 'Feb';
  ElseIf MTH = 2 and short;
    Return 'FEB';
  ElseIf MTH = 2 and mixed;
    Return 'Febuary';
  ElseIf MTH = 2;
    Return 'FEBUARY';
  ElseIf MTH = 3 and short and mixed;
    Return 'Mar';
  ElseIf MTH = 3 and short;
    Return 'MAR';
  ElseIf MTH = 3 and mixed;
    Return 'March';
  ElseIf MTH = 3;
    Return 'MARCH';
  ElseIf MTH = 4 and short and mixed;
    Return 'Apr';
  ElseIf MTH = 4 and short;
    Return 'APR';
  ElseIf MTH = 4 and mixed;
    Return 'April';
  ElseIf MTH = 4;
    Return 'APRIL';
  ElseIf MTH = 5 and short and mixed;
    Return 'May';
  ElseIf MTH = 5 and short;
    Return 'MAY';
  ElseIf MTH = 5 and mixed;
    Return 'May';
  ElseIf MTH = 5;
    Return 'MAY';
  ElseIf MTH = 6 and short and mixed;
    Return 'Jun';
  ElseIf MTH = 6 and short;
    Return 'JUN';
  ElseIf MTH = 6 and mixed;
    Return 'June';
  ElseIf MTH = 6;
    Return 'JUNE';
  ElseIf MTH = 7 and short and mixed;
    Return 'Jul';
  ElseIf MTH = 7 and short;
    Return 'JUL';
  ElseIf MTH = 7 and mixed;
    Return 'July';
  ElseIf MTH = 7;
    Return 'JULY';
  ElseIf MTH = 8 and short and mixed;
    Return 'Aug';
  ElseIf MTH = 8 and short;
    Return 'AUG';
  ElseIf MTH = 8 and mixed;
    Return 'August';
  ElseIf MTH = 8;
    Return 'AUGUST';
  ElseIf MTH = 9 and short and mixed;
    Return 'Sep';
  ElseIf MTH = 9 and short;
    Return 'SEP';
  ElseIf MTH = 9 and mixed;
    Return 'September';
  ElseIf MTH = 9;
    Return 'SEPTEMBER';
  ElseIf MTH = 10 and short and mixed;
    Return 'Oct';
  ElseIf MTH = 10 and short;
    Return 'OCT';
  ElseIf MTH = 10 and mixed;
    Return 'October';
  ElseIf MTH = 10;
    Return 'OCTOBER';
  ElseIf MTH = 11 and short and mixed;
    Return 'Nov';
  ElseIf MTH = 11 and short;
    Return 'NOV';
  ElseIf MTH = 11and mixed;
    Return 'November';
  ElseIf MTH = 11;
    Return 'NOVEMBER';
  ElseIf MTH = 12 and short and mixed;
    Return 'Dec';
  ElseIf MTH = 12 and short;
    Return 'DEC';
  ElseIf MTH = 12 and mixed;
    Return 'December';
  ElseIf MTH = 12;
    Return 'DECEMBER';
  Else;
    Return ' ';
  EndIf;

End-Proc;

// ****************************************************************
// #$RVL - RETURNS A NUMBER FROM A CHARACTER STRING
//
// This procedure accepts a character string and returns a
// number from the data
//
//  INPUT:  #$TXET = Input string
//  RETURNS:  Numeric value
//
//  Characters J-R and } are converted to 1-9 and 0
//  if included they reverse the sign, this handles
//  conerting signed numeric fields
//
//  EXAMPLES IN FREE FORMAT
//  #$RVL('1')                     RETURNS 1
//  #$RVL('-1')                    RETURNS -1
//  #$RVL('1-')                    RETURNS -1
//  #$RVL('1-123')                 RETURNS -1123
//  #$RVL('1-1.23')                RETURNS -11.23
//  #$RVL('1.1.23')                RETURNS 1.123
//  #$RVL('1A1.2C3-')              RETURNS -11.23
//  #$RVL('ABC')                   RETURNS 0
//  #$RVL('AJC')                   RETURNS -1
//
Dcl-Proc #$RVL EXPORT;
  Dcl-Pi *N Packed(30:10);
    input         Char(30)   CONST;
  End-Pi;
  Dcl-S isNegative Ind; // was *in77
  Dcl-S hasDecimal Ind; // was *in78
  Dcl-S clean varchar(40);
  Dcl-S x Packed(3);

  // This uses %DEC, but it removes any invalid charactrers first. It
  // also converts certain characters to decimal and negative to handle
  // signed numerics. It remove any decimal points after the first one.

  Clear clean;
  Clear isNegative;
  Clear hasDecimal;
  // move valid and converted characters to a new string
  For x = 1 to 30;
    If %subst(input:x:1) = 'J';
      clean += '1';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'K';
      clean += '2';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'L';
      clean += '3';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'M';
      clean += '4';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'N';
      clean += '5';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'O';
      clean += '6';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'P';
      clean += '7';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'Q';
      clean += '8';
      isNegative = *On;
    ElseIf %subst(input:x:1) = 'R';
      clean += '9';
      isNegative = *On;
    ElseIf %subst(input:x:1) = '}';
      clean += '0';
      isNegative = *On;
    ElseIf %subst(input:x:1) = '-';
      isNegative = *On;
    ElseIf %subst(input:x:1) >= '0' and %subst(input:x:1) <= '9';
      clean += %subst(input:x:1);
    ElseIf %subst(input:x:1) = '.' and not hasDecimal;
      clean += '.';
      hasDecimal = *On;
    EndIf;
  EndFor;

  // add negative sign if needed
  If isNegative;
    clean += '-';
  EndIf;

  Monitor;
    Return %dec(clean:30:10);
  On-Error;
    Return 0;
  EndMon;

End-Proc;

// ****************************************************************
// #$UCC - Returns a string in UCC format
// $UCC(#$TXT)
// his procedure accepts a character string and returns a
// tring fomratter in UCC readable format
//
//  INPUT:  #$TXT  = Input string
//  RETURNS:  formatteed string, see examples
//
//  Input should only include numeric characters,
//  no more than 14, leading zeros will be added,
//  anything past 14 will be ignored, see examples
//
//  EXAMPLES
//  #$UCC('12345678901234')   RETURNS '12-3-45678-90123-4
//  #$UCC('1234567890123')    RETURNS '01-2-34567-89012-3
//  #$UCC('1234567890123456') RETURNS '12-3-45678-90123-4
//
Dcl-Proc #$UCC EXPORT;
  Dcl-Pi *N Char(18);
    input Varchar(100)  CONST;
  End-Pi;
  Dcl-S tmp char(14);

  // zero pad input to 14 character
  Evalr tmp = '00000000000000' + %trim(input);

  Return %subst(tmp:1:2) + '-' +
                 %subst(tmp:3:1) + '-' +
                 %subst(tmp:4:5) + '-' +
                 %subst(tmp:9:5) + '-' +
                 %subst(tmp:14:1);

End-Proc;

// ****************************************************************
// #$UCP - Returns a string in UCP format
// #$UPC(#$TXT)
// This procedure accepts a character string and returns a
// string fomratter in UCP readable format
//
//   INPUT:  #$TXT  = Input string
//   RETURNS:  formatteed string, see examples
//
//   Input should only include numeric characters,
//   no more than 12, leading zeros will be added,
//   anything past 12 will be ignored, see examples
//
//   EXAMPLES
//   #$UPC('123456789012')     RETURNS '1-23456-78901-2
//   #$UPC('12345678901')      RETURNS '0-12345-67890-1
//   #$UPC('12345678901234')   RETURNS '1-23456-78901-2
//
Dcl-Proc #$UPC EXPORT;
  Dcl-Pi *N Char(15);
    input   Varchar(100)  CONST;
  End-Pi;
  Dcl-S tmp char(12);

  // zero pad input to 12 character
  If %len(%trim(input)) > 12;
    Evalr tmp = %subst(%trim(input):1:12);
  Else;
    Evalr tmp = '00000000000000' + %trim(input);
  EndIf;

  Return %subst(tmp:1:1) + '-' +
                 %subst(tmp:2:5) + '-' +
                 %subst(tmp:7:5) + '-' +
                 %subst(tmp:12:1);

End-Proc;

// ****************************************************************
// #$VDAT - Validates a Date
// This Procedure validates a YYYYMMDD or a MMDDYY date.
// It returns a boolean True or False. It also allows an option
// to make sure the date is recent, this prevents people from
// misskeying dates and should be used on transaction entry
// screens.
//
//   Input: #$DATE = dec(8 0) DATE TO TEST, YYYYMMDD or
//                            MMDDYY format.
//          #$LVL  = 1 or not passed= valid date
//                   2=allow 360 back and 90 days forward
//
//   #$VDAT(20180101)     RETURNS False
//   #$VDAT(20181301)     RETURNS True
//   #$VDAT(010118)       RETURNS False
//   #$VDAT(130118)       RETURNS True
//   #$VDAT(20180101:1)   RETURNS False
//   #$VDAT(20181301:1)   RETURNS True
//   #$VDAT(20120101:2)   RETURNS True
//   #$VDAT(20540101:2)   RETURNS True
Dcl-Proc #$VDAT EXPORT;
  Dcl-Pi *N Ind;
    #$date         Zoned(8:0) CONST;
    #$PSLVL        Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$INDT       Date INZ(*LOVAL);
  Dcl-S #$LVL        Zoned(1:0);
  Dcl-S DATE6        Zoned(6:0);

  If %parms() < 2 OR %addr(#$PSLVL) = *NULL;
    #$LVL=1;
  Else;
    #$LVL=#$PSLVL;
  EndIf;

  // VALIDATE DATE
  If #$DATE<1000000;
    DATE6 = #$date;
    Test(de) *mdy DATE6;
    If %error;
      Return *ON;
    EndIf;
  Else;
    Test(de) *iso #$date;
    If %error;
      Return *ON;
    EndIf;
  EndIf;

  // SKIP REST IF ONLY LEVEL 1 VALIDATION REQUESTED
  If #$LVL < 2;
    Return *OFF;
  EndIf;

  // VALIDATE DATE WITH ACCEPTABLE DATE RANGE -360 DAYS
  If #$DATE<100000;
    #$INDT = %date(#$date:*MDY);
  Else;
    #$INDT = %date(#$date);
  EndIf;
  If %diff(%date():#$INDT:*DAYS) > 360;
    Return *ON;
  EndIf;

  // VALIDATE DATE WITH ACCEPTABLE DATE RANGE + 90
  If %diff(%date():#$INDT:*DAYS) < -90;
    Return *ON;
  EndIf;

  Return *OFF;

End-Proc;

// ****************************************************************
// #$VTS - Validates a Timestamp
// This Procedure validates a YYYYMMDDHHMMSS timestamp.
// It returns a boolean True or False.
//
//   Input: #$TS   = dec(14 0) TIMESTAMP TO TEST,
//                    YYYYMMDDHHMMSS format.
//
//   #$VDAT(20180101125137)   RETURNS True
//   #$VDAT(20181301125137)   RETURNS False
//
Dcl-Proc #$VTS EXPORT;
  Dcl-Pi *N Ind;
    #$TS           Packed(14:0) CONST;
  End-Pi;
  Dcl-Ds *N;
    TS             Zoned(14:0) Pos(1);
    DATE           Zoned(8:0) Pos(1);
    TIME           Zoned(6:0) Pos(9);

    // MAKE SURE THE DATE AND TIME IS VALID
  End-Ds;
  TS=#$TS;
  If #$VDAT(DATE) OR #$VTIM(TIME);
    Return *OFF;
  Else;
    Return *ON;
  EndIf;

End-Proc;

// ****************************************************************
// #$TSSET - Creates a Timestamp from a date and a time
//
//   Input: #$DATE = A DATE IN YYYYMMDD OR
//                   MMDDYY FORMAT.
//          #$TIME = A TIME IN HHMMSS FORMAT
//   OUPUT:        = A YYYYMMDDHHMMSS TIMESTAMP
//
//   #$TSSET(20180101:125137) RETURNS 20180101125137
//   #$TSSET(010118:125137)   RETURNS 20180101125137
//
Dcl-Proc #$TSSET EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$DATE         Packed(8:0) CONST;
    #$TIME         Packed(6:0) CONST;

    // MAKE SURE THE DATE AND TIME IS VALID
  End-Pi;
  If #$DATE<1000000;
    Return #$YMD8(#$DATE);
  Else;
    Return #$DATE*1000000;
  EndIf;

End-Proc;

// ****************************************************************
// #$TSDATE - Returns a date from a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP TO TEST,
//                    YYYYMMDDHHMMSS FORMAT.
//  Output: A DATE IN YYYYMMDD FORMAT
//
//   #$TSDATE(20180101125137)= 20180101
//
Dcl-Proc #$TSDATE EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$TS           Packed(14:0) CONST;
  End-Pi;
  Dcl-Ds *N;
    TS             Zoned(14:0) Pos(1);
    DATE           Zoned(8:0) Pos(1);
    TIME           Zoned(6:0) Pos(9);
  End-Ds;

  // Make sure the date and time is valid
  TS=#$TS;
  Return DATE;

End-Proc;

// ****************************************************************
// #$TSTIME - Returns a time from a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP TO TEST,
//                    YYYYMMDDHHMMSS FORMAT.
//  Output: A TIME IN HHMMSS FORMAT
//
//   #$TSDATE(20180101125137)= 20180101
//
Dcl-Proc #$TSTIME EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$TS           Packed(14:0) CONST;
  End-Pi;
  Dcl-Ds *N;
    TS             Zoned(14:0) Pos(1);
    DATE           Zoned(8:0) Pos(1);
    TIME           Zoned(6:0) Pos(9);
  End-Ds;

  // Make sure the date and time is valid
  TS=#$TS;
  Return TIME;

End-Proc;

// ****************************************************************
// #$TSADDD - Adds a number of days to a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP TO TEST,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$DAYS = A NUMBER OF DAYS
//  Output: THE NEW TIMESTAMP
//
//   #$TSADDD(20180101125137:10)=20180111125137
//
Dcl-Proc #$TSADDD EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$TS           Packed(14:0) CONST;
    #$DAYS         Packed(8:0) CONST;
  End-Pi;
  Dcl-Ds *N;
    TS             Zoned(14:0) Pos(1);
    DATE           Zoned(8:0) Pos(1);
    TIME           Zoned(6:0) Pos(9);
  End-Ds;

  TS=#$TS;
  DATE=#$ADDDAY(DATE:#$DAYS);
  Return TS;

End-Proc;

// ****************************************************************
// #$TSSUBD - Subtracts a number of days from a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP TO TEST,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$DAYS = A NUMBER OF DAYS
//  Output: THE NEW TIMESTAMP
//
//   #$TSSUBD(20180111125137:10)=20180101125137
//
Dcl-Proc #$TSSUBD EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$TS           Packed(14:0) CONST;
    #$DAYS         Packed(8:0) CONST;
  End-Pi;
  Dcl-Ds *N;
    TS             Zoned(14:0) Pos(1);
    DATE           Zoned(8:0) Pos(1);
    TIME           Zoned(6:0) Pos(9);
  End-Ds;

  TS=#$TS;
  DATE=#$SUBDAY(DATE:#$DAYS);
  Return TS;

End-Proc;

// ****************************************************************
// #$TSADDS - Adds a number of seconds to a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$SECS = A NUMBER OF SECOND
//  Output: THE NEW TIMESTAMP
//
//   #$TSADDD(20180101125137:10)=20180101125147
//
Dcl-Proc #$TSADDS EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$TS           Packed(14:0) CONST;
    #$SECS         Packed(8:0) CONST;
  End-Pi;
  Dcl-S TS           Timestamp;

  TS=%timestamp((%editw(#$TS:'    -  -  -  .  .  ') + '.000000')) +
              %seconds(#$SECS);
  Return %dec(%char(TS : *iso0):20:0)/1000000;

End-Proc;

// ****************************************************************
// #$TSSUBS - Subtracts a number of seconds from a timestamp
//   Input:  #$TS   = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$SECS = A NUMBER OF SECOND
//  Output: THE NEW TIMESTAMP
//
//   #$TSADDD(20180101125137:10)=20180101125127
//
Dcl-Proc #$TSSUBS EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$TS           Packed(14:0) CONST;
    #$SECS         Packed(8:0) CONST;
  End-Pi;
  Dcl-S TS           Timestamp;

  TS=%timestamp((%editw(#$TS:'    -  -  -  .  .  ') + '.000000')) -
              %seconds(#$SECS);
  Return %dec(%char(TS : *iso0):20:0)/1000000;

End-Proc;

// ****************************************************************
// #$TSDDAY - Returns the differencs between Timestamps
//            in days
//   Input:  #$TS1  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$TS2  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//  Output: THE NUMBER OF DAYS BETWEEN THEM
//
//   #$TSDDAY(20180101125137:20180112125127)=11
//
Dcl-Proc #$TSDDAY EXPORT;
  Dcl-Pi *N Packed(8:0);
    #$TS1          Packed(14:0) CONST;
    #$TS2          Packed(14:0) CONST;
  End-Pi;
  Dcl-S DATE1        Packed(8:0);
  Dcl-S DATE2        Packed(8:0);

  DATE1 = #$TS1 / 1000000;
  DATE2 = #$TS2 / 1000000;
  Return #$DDIFF(DATE1:DATE2);

End-Proc;

// ****************************************************************
// #$TSDSEC - Returns the differencs between Timestamps
//            in seconds
//   Input:  #$TS1  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$TS2  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//  Output: THE NUMBER OF SECONDS BETWEEN THEM
//
//   #$TSDSEC(20180101125137:20180101125147)=10
//
Dcl-Proc #$TSDSEC EXPORT;
  Dcl-Pi *N Packed(14:0);
    #$TS1          Packed(14:0) CONST;
    #$TS2          Packed(14:0) CONST;
  End-Pi;

  Return %diff(
              %timestamp((%editw(#$TS1:'    -  -  -  .  .  ') + '.000000'))
             :%timestamp((%editw(#$TS2:'    -  -  -  .  .  ') + '.000000'))
             :*SECONDS);

End-Proc;

// ****************************************************************
// #$TSDHMS - Returns the differencs between Timestamps
//            in an HMS feild
//   Input:  #$TS1  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//           #$TS2  = DEC(14 0) TIMESTAMP,
//                    YYYYMMDDHHMMSS FORMAT.
//  Output: THE TIME BETWEEN THE TIME STAMPS IN HHHHHHMMSS
//
//   #$TSDHMS(20180101125137:20180112125127)=11
//
Dcl-Proc #$TSDHMS EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$TS1          Packed(14:0) CONST;
    #$TS2          Packed(14:0) CONST;
  End-Pi;
  Dcl-S SECONDS      Packed(14:0);

  SECONDS=%diff(
                %timestamp((%editw(#$TS1:'    -  -  -  .  .  ') + '.000000'))
              :%timestamp((%editw(#$TS2:'    -  -  -  .  .  ') + '.000000'))
              :*SECONDS);

  Return  %div(SECONDS : 3600 ) * 10000 +
                  %div( %rem( SECONDS : 3600 ) : 60 ) *100 +
                  %rem( %rem( SECONDS : 3600 ) : 60 );

End-Proc;

// ****************************************************************
// #$VTIM - Validates a Time
// This Procedure validates a HHMMSS time, it returns a
// Boolean True or False
//
//   Input: #$TIME = dec(6 0) TIME TO TEST, HHMMDD FORMAT
//
//   #$VDAT(010101)         RETURNS False
//   #$VDAT(270101)         RETURNS True
//
Dcl-Proc #$VTIM EXPORT;
  Dcl-Pi *N Ind;
    #$TIME         Zoned(6:0) CONST;
  End-Pi;

  // VALIDATE TIME
  Test(te) *HMS #$TIME;
  If %error;
    Return *ON;
  EndIf;

  Return *OFF;

End-Proc;

// ****************************************************************
// #$WOY - Returns the week of the year
// Retrieve week of year using ISO 8601 standard January 4)
// (Year starts on Monday of week containing January 4)
//
//   Input: #$DATE = dec(8 0) DATE, YYYYMMDD OR MMDDYY
//
//   #$WOY(20180104)       RETURNS 1
//
Dcl-Proc #$WOY EXPORT;
  Dcl-Pi #$WOY Zoned(2:0);
    #$DATE         Packed(8:0) VALUE;
  End-Pi;
  Dcl-Ds *N;
    Jan04Date      Zoned(8:0) INZ(00010104);
    Jan04Year      Zoned(4:0) OVERLAY(JAN04DATE);
  End-Ds;

  Dcl-S DateIn       Date;
  Dcl-S FirstMonday  Date;
  Dcl-S Jan04DOW     Int(5);

  If (#$date<1000000);
    DateIn=%date(#$DATE:*mdy);
  Else;
    DateIn=%date(#$DATE);
  EndIf;

  // Change Jan04Date to target year,
  // then calculate first Monday of target year
  Jan04Year   = %subdt(DateIn:*Y);
  Jan04DOW    = #$DAYOW(Jan04Date);
  FirstMonday = %date(Jan04Date) - %days(Jan04DOW);

  // If target date is before first Monday, switch to prior year
  If DateIn < FirstMonday;
    Jan04Year   = Jan04Year - 1;
    Jan04DOW    = #$DAYOW(Jan04Date);
    FirstMonday = %date(Jan04Date) - %days(Jan04DOW);
  EndIf;

  // Return week number (number of full weeks since first Monday + 1)
  Return %div(%diff(DateIn:FirstMonday:*DAYS):7) + 1;

End-Proc;

// ****************************************************************
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
//
Dcl-Proc #$XMLESC EXPORT;
  Dcl-Pi *N Varchar(1024);
    #$TXT          Varchar(1024) VALUE;
  End-Pi;
  #$TXT = %trim(#$TXT);
  #$TXT=%scanrpl('&':'&#38;':#$TXT);
  #$TXT=%scanrpl('<':'&#60;':#$TXT);
  #$TXT=%scanrpl('>':'&#62;':#$TXT);
  #$TXT=%scanrpl('''':'&#39;':#$TXT);
  #$TXT=%scanrpl('"':'&#34;':#$TXT);
  Return #$TXT;
End-Proc;

// ****************************************************************
// #$SEC2HMS - Converts a number of seconds to HHMMSS format
// This procedure converts a total number of seconds to
// HHMMSS format.
//
//        INPUT:  #$SECS = Number of seconds
//      RETURNS:  number of hours/minutes/seconds in HHMMSS
//                format.
//
// Example #$SEC2HMS(1000)=1640        Display as 16:40
// Example #$SEC2HMS(834235)=2314355   Display as 231:43:55
//
Dcl-Proc #$SEC2HMS EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$SECS         Packed(10:0) VALUE;
  End-Pi;

  Return %div(#$SECS : 3600 ) * 10000 +
                %div( %rem( #$SECS : 3600 ) : 60 ) *100 +
                %rem( %rem( #$SECS : 3600 ) : 60 );

End-Proc;

// ****************************************************************
// #$HMS2SEC - Converts a HMS to Number of Seconds
// This procedure converts a time field in HHMMSS format to
// a total number of seconds.
//
//        INPUT:  #$HMS  = hours/minutes/seconds field
//      RETURNS:  number of seconds
//
// Example #$HMS2SEC(1640)=1000
// Example #$HMS2SEC(2314355)=834235
//
Dcl-Proc #$HMS2SEC EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$HMS          Packed(10:0) VALUE;
  End-Pi;

  Return %int(#$HMS/10000) * 3600 +
                  %rem(%int(#$HMS/100):100) * 60 +
                  %rem(#$HMS:100);

End-Proc;

// ****************************************************************
// #$TDIFF - Returns the difference in times in HHMMSS format
// This procedure accepts two time fields in HHMMSS and returns
// the diffrerence in HHMMSS format.
//
//        INPUT:  #$time1 = First Time
//                #$time2 = Second Time
//      RETURNS:  HHMMSS difference between times
//
// Example #$TDIFF(104000:123000)=15000    1:50:00
// Example #$TDIFF(010000:233000)=223000  22:30:00
//
Dcl-Proc #$TDIFF EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$TIME1        Packed(6:0) VALUE;
    #$TIME2        Packed(6:0) VALUE;
  End-Pi;
  Dcl-S SECS         Packed(10:0);

  Monitor;
    EVAL SECS=%diff(%time(#$TIME2) : %time(#$TIME1) : *SECONDS);
    Return %div(SECS : 3600 ) * 10000 +
                   %div( %rem( SECS : 3600 ) : 60 ) *100 +
                   %rem( %rem( SECS : 3600 ) : 60 );
  On-Error;
    Return 0;
  EndMon;

End-Proc;

// ****************************************************************
// #$ADDHMS - Adds 2 HMS fields together                         *
// €This procedure accepts two HMS seconds fields and retruns    ‚*
// €the sum of them.                                             ‚*
// €                                                             ‚*
// €       INPUT:  #$HMS1 = First HMS field                      ‚*
// €               #$HMS2 = Second HMS Field                     ‚*
// €     RETURNS:  The sum of both fields                        ‚*
// €                                                             ‚*
// €Example #$ADDHMS(14000:2525)=20525      2:05:25              ‚*
// €Example #$ADDHMS(1104729:1532)=1110301  111:03:01            ‚*
// €                                                             ‚*
// ****************************************************************
Dcl-Proc #$ADDHMS EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$HMS1         Packed(10:0) VALUE;
    #$HMS2         Packed(10:0) VALUE;
  End-Pi;
  Dcl-S TOTSECS      Packed(10:0);

  // GET THE SECONDS FROM #$HMS1
  TOTSECS = %int(#$HMS1/10000) * 3600 +
                    %rem(%int(#$HMS1/100):100) * 60 +
                    %rem(#$HMS1:100);


  // ADD THE SECONDS FROM #$HMS2
  TOTSECS += %int(#$HMS2/10000) * 3600 +
                      %rem(%int(#$HMS2/100):100) * 60 +
                      %rem(#$HMS2:100);

  // RETURN THE TOTAL SECONDS IN HHMMSS FORMAT
  Return %div(TOTSECS : 3600 ) * 10000 +
                  %div( %rem( TOTSECS : 3600 ) : 60 ) *100 +
                  %rem( %rem( TOTSECS : 3600 ) : 60 );

End-Proc;

// ****************************************************************
// #$SUBHMS - Subtracts 2 HMS
// This procedure accepts two HMS seconds fields and retruns
// the HMS first value minus the second value
//
//        INPUT:  #$HMS1 = First HMS field
//                #$HMS2 = Second HMS Field
//      RETURNS:  The difference of the fields in HMS format
//
// Example #$SUBHMS(14000:5525)=4435       0:44:35
// Example #$SUBHMS(1101532:3459)=1094033  109:40:33
//
Dcl-Proc #$SUBHMS EXPORT;
  Dcl-Pi *N Packed(10:0);
    #$HMS1         Packed(10:0) VALUE;
    #$HMS2         Packed(10:0) VALUE;
  End-Pi;
  Dcl-S TOTSECS      Packed(10:0);
  Dcl-S HOURS        Packed(6:0);
  Dcl-S MMSS         Packed(4:0);
  Dcl-S MINS         Packed(2:0);
  Dcl-S SECS         Packed(2:0);

  // GET THE SECONDS FROM #$HMS1
  TOTSECS = %int(#$HMS1/10000) * 3600 +
                    %rem(%int(#$HMS1/100):100) * 60 +
                    %rem(#$HMS1:100);


  // ADD THE SECONDS FROM #$HMS2
  TOTSECS -= %int(#$HMS2/10000) * 3600 +
                      %rem(%int(#$HMS2/100):100) * 60 +
                      %rem(#$HMS2:100);

  // RETURN THE TOTAL SECONDS IN HHMMSS FORMAT
  Return %div(TOTSECS : 3600 ) * 10000 +
                  %div( %rem( TOTSECS : 3600 ) : 60 ) *100 +
                  %rem( %rem( TOTSECS : 3600 ) : 60 );

End-Proc;

// ****************************************************************
// #$upify - Convert to all upper case
// Converts lowercase characters to uppercase
// Only converts english characters.
//
//        INPUT:  data = Field to convert to all capitals
//      RETURNS:  The data field in all capitals
//
// Examples EVAL    TEXT=#$UPFIY(TEXT)
//
Dcl-Proc #$upify export;
  Dcl-Pi *N Varchar(32767);
    data           Varchar(32767) CONST  OPTIONS(*VARSIZE);
  End-Pi;

  Dcl-C ENGLOW     'abcdefghijklmnopqrstuvwxyz';
  Dcl-C ENGUP      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Dcl-S Output       Varchar(32767);

  Output = data;
  Output = %xlate(ENGLOW:ENGUP:Output);
  Return Output;

End-Proc;

// ****************************************************************
// #$lowfy - Convert to all loser case
// Converts lowercase characters to lowercase
// Only converts english characters.
//
//        INPUT:  data = Field to convert to all lower case
//      RETURNS:  The data field in all lower case
//
// Examples EVAL    TEXT=#$LOWFY(TEXT)
//
Dcl-Proc #$lowfy export;
  Dcl-Pi *N Varchar(32767);
    data           Varchar(32767) CONST  OPTIONS(*VARSIZE);
  End-Pi;

  Dcl-C ENGLOW     'abcdefghijklmnopqrstuvwxyz';
  Dcl-C ENGUP      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Dcl-S Output       Varchar(32767);

  Output = data;
  Output = %xlate(ENGUP:ENGLOW:Output);
  Return Output;

End-Proc;

// ****************************************************************
// #$edtc - Edits a Numeric Variable
// This is similar to BIFF %EDITC but includes a few custom
// edit codes and the ability to specify a number of decimal
// positions, right or left justify and round if needed.
//
// %EDITC(Numeric : Editcode {: Decimal Percision +
//        {: Right justify Length { :Round } } } )
//
//   INPUT: number = Any numeric value up to 15,5
//          EditCode = An Edit code, see list below
//          Decimal Precision = Value 1-5, optional,
//                              Default = Float, can be omitted
//          Right Justify Length = Value 1-30,
//                              Default = Float, can be omitted
//           Round -  Value Y,N, Defaults to Y, can be omitted
//                    used if dec. precision is used
// RETURNS:  The Value Edited as requried.
//
//  EXAMPLES IN FREE FORMAT
//  #$EDTC(1:'M')                      RETURNS '1
//  #$EDTC(1.1:'M')                    RETURNS '1.1
//  #$EDTC(1:'M':2)                    RETURNS '1.00
//  #$EDTC(1.1:'M':2)                  RETURNS '1.10
//  #$EDTC(1:'M':2:9)                  RETURNS '      1.00
//  #$EDTC(1-:'M':2:9)                 RETURNS '      1.00-
//  #$EDTC(1.1234-:'M':2:9)            RETURNS '      1.12-
//  #$EDTC(1.1254-:'M':2:9)            RETURNS '      1.13-
//  #$EDTC(1.1254-:'M':2:9:N)          RETURNS '      1.12-
//  #$EDTC(1.1254-:'M':2:*OMIT:N)      RETURNS '1.12-
//  #$EDTC(1.1254-:'M')                RETURNS '1.1254-
//  #$EDTC(1.1254-:'M')                RETURNS '1.1254-
//
//  Edit Codes Allowed With Examples
//            ZEROS     -        -            NO
//   COMMAS    BAL    (LEFT)  (RIGHT)   CR   SIGN    ()
//     YES     YES      N        J      A     1       E
//     YES     NO       O        K      B     2       F
//     NO      YES      P        L      C     3       G
//     NO      NO       Q        M      D     4       H
//
// Special Edit Codes
// Y = Date edit         101005='10/10/05'     91099=' 9/10/99'
// V = Date edit W/0     101005='10/10/05'     91099='09/10/99'
// W = Date edit 4 Digit 10102005='10/10/2005' 91099=' 9/10/1999'
// T = Time edit         123115='12:31:10'     10500=' 1:05:00'
// Z,X = Suppress Leading 0, no sign, no dec   000123.12- = 12312
// S = Sales Order       123115='  1231-15'    10500='    105-00'
//
Dcl-Proc #$EDTC EXPORT;
  Dcl-Pi *N Char(30);
    #$VALU         Packed(15:5) CONST;
    #$EDTC         Char(1)    CONST;
    #$EDTP         Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$EDTR         Packed(2:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$RND          Char(1)    CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S psValu packed(15:5);
  Dcl-Ds nbrs;
    num    Char(1) DIM(10) pos(1);
    dcm    Char(1) DIM(5)  pos(11);
    tmp5   Char(5)         pos(11);
  End-Ds;
  Dcl-S x packed(3);
  Dcl-S y packed(3);
  Dcl-S RJ         Char(1)    DIM(30);
  Dcl-S RND        Char(1);
  Dcl-S #$text     char(30);
  Dcl-S temp       char(30);

  If %parms() > 4 AND %addr(#$RND) <> *NULL;
    RND = #$RND;
  Else;
    RND = 'Y';
  EndIf;

  Clear #$text;
  psValu = #$VALU; //POSITIVE VAL
  If psValu < *ZEROS;
    psValu = psValu * -1;
  EndIf;
  nbrs = %editc(psValu:'X');

  // HANDLE EDIT CODE 'Y'
  If #$EDTC = 'Y' OR #$EDTC = 'V';
    ExSr EDTY;
    Return #$text;
  EndIf;

  // HANDLE EDIT CODE 'T'
  If #$EDTC = 'T';
    ExSr EDTT;
    Return #$text;
  EndIf;

  // HANDLE EDIT CODE 'O'
  If #$EDTC = 'S';
    ExSr EDTO;
    Return #$text;
  EndIf;

  // SHOW COMMAS
  If #$EDTC = '1' or #$EDTC = '2' or #$EDTC = 'A' or #$EDTC = 'B'
         or #$EDTC = 'J' or #$EDTC = 'K' or #$EDTC = 'N' or #$EDTC = 'O'
         or #$EDTC = 'E' or #$EDTC = 'F';
    *in96 = *on;
  Else;
    *in96 = *off;
  EndIf;

  // Show zeros
  If #$EDTC = '1' or #$EDTC = '3' or #$EDTC = 'A' or #$EDTC = 'C'
         or #$EDTC = 'J' or #$EDTC = 'L' or #$EDTC = 'N' or #$EDTC = 'P'
         or #$EDTC = 'E' or #$EDTC = 'G';
    *in97 = *on;
  Else;
    *in97 = *off;
  EndIf;
  If not *In97 and #$VALU = 0;
    Return #$text;
  EndIf;


  *In10 = *Off;

  If NUM(1) <> *ZEROS;
    #$text = %trimr(#$text) + NUM(1);
    *In10 = *On;
  EndIf;
  If *In10 and *in96;
    #$text = %trimr(#$text) + ',';
  EndIf;
  If NUM(2) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(2);
    *In10 = *On;
  EndIf;
  If NUM(3) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(3);
    *In10 = *On;
  EndIf;
  If NUM(4) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(4);
    *In10 = *On;
  EndIf;
  If *In10 and *in96;
    #$text = %trimr(#$text) + ',';
  EndIf;
  If NUM(5) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(4);
    *In10 = *On;
  EndIf;
  If NUM(6) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(6);
    *In10 = *On;
  EndIf;
  If NUM(7) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(7);
    *In10 = *On;
  EndIf;
  If *In10 and *in96;
    #$text = %trimr(#$text) + ',';
  EndIf;
  If NUM(8) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(8);
    *In10 = *On;
  EndIf;
  If NUM(9) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(9);
    *In10 = *On;
  EndIf;
  If NUM(10) <> *ZEROS OR *IN10 = *ON;
    #$text = %trimr(#$text) + NUM(10);
    *In10 = *On;
  EndIf;

  // Handle decimal percision
  If %parms() > 2 AND %addr(#$EDTP) <> *NULL;
    // Handle round and blank out anything greater than the percision
    If #$EDTP <> 5;
      If RND = 'Y' AND dcm(#$EDTP + 1)>'4';
        dcm(#$EDTP) = %char(%dec(dcm(#$EDTP):1:0) + 1);
      EndIf;
      // blank out anyhting after the percision
      For x = #$EDTP + 1 to 5;
        dcm(x) = ' ';
      EndFor;
    EndIf;
    // append decimal data to output string
    If #$EDTC <> 'Z' AND #$EDTC <> 'X' AND TMP5 <> '     ';
      #$text = %trimr(#$text) + '.';
    EndIf;
    #$text = %trimr(#$text) + TMP5;
  Else;
    // Add floating decimal positions
    If TMP5 <> '00000' AND TMP5 <> '     ';
      For x = 1 to 5;
        y = 6 - x;
        If NUM(y) = '0';
          num(y) = ' ';
        Else;
          Leave;
        EndIf;
      EndFor;
      If #$EDTC <> 'Z' AND #$EDTC <> 'X';
        #$text = %trimr(#$text) + '.';
      EndIf;
      #$text = %trimr(#$text) + TMP5;
    EndIf;
  EndIf;

  // HANDLE SHOW ZERO BALANCE
  If *In97 and #$text=' ';
    #$text='0';
  EndIf;

  // ADD NEGATIVE SIGN
  If #$VALU < *ZEROS;
    If #$EDTC = 'A' OR #$EDTC = 'B' OR #$EDTC = 'C' OR #$EDTC = 'D';
      #$text = %trimr(#$text) + 'CR';
    EndIf;
    If #$EDTC = 'J' OR #$EDTC = 'K' OR #$EDTC = 'L' OR #$EDTC = 'M';
      #$text = %trimr(#$text) + '-';
    EndIf;
    If #$EDTC = 'N' OR #$EDTC = 'O' OR #$EDTC = 'P' OR #$EDTC = 'Q';
      #$text = '- ' + #$text;
    EndIf;
    If #$EDTC = 'E' OR #$EDTC = 'F' OR #$EDTC = 'G' OR #$EDTC = 'H';
      #$text = '(' + %trimr(#$text) + ')';
    EndIf;
  EndIf;

  // Handle right justify value
  If %parms() > 3 AND %addr(#$EDTR) <> *NULL and #$EDTR <> 0;
    // Get desired length in y
    y = #$EDTR;
    // Add a space or two for the negative sign depending on the edit code
    If #$VALU >= *ZEROS;
      If #$EDTC = 'A' OR #$EDTC = 'B' OR #$EDTC = 'C' OR #$EDTC = 'D';
        y += 2;
      ElseIf #$EDTC = 'J' OR #$EDTC = 'K' OR #$EDTC = 'L' OR #$EDTC='M'
               or #$EDTC = 'E' OR #$EDTC = 'F' OR #$EDTC = 'G' OR #$EDTC = 'H';
        y += 1;
      EndIf;
    EndIf;

    temp = '';
    %subst(temp:y-%len(%trim(#$text)):%len(%trim(#$text)))
             = %trim(#$text);
    #$text = temp;

    // #$text = %REPEAT(' ': y - %LEN(%trim(#$text))) + %trim(#$text);

  EndIf;

  Return #$text;

  // *********************************************
  // EDITS FOR DATES (Y AND V)
  BegSr EDTY;

    If #$EDTC = 'V' AND psValu = *ZEROS;
      LeaveSr;
    EndIf;

    #$text = %trimr(#$text) + NUM(5);
    #$text = %trimr(#$text) + NUM(6);
    #$text = %trimr(#$text) + '/';
    #$text = %trimr(#$text) + NUM(7);
    #$text = %trimr(#$text) + NUM(8);
    #$text = %trimr(#$text) + '/';
    #$text = %trimr(#$text) + NUM(9);
    #$text = %trimr(#$text) + NUM(10);

    If NUM(5) = '0';
      %subst(#$text:1:1) = ' ';
    EndIf;

  EndSr;
  // *********************************************
  // EDITS FOR TIME  (T)
  BegSr EDTT;

    If psValu = *ZEROS;
      LeaveSr;
    EndIf;

    #$text = %trimr(#$text) + NUM(5);
    #$text = %trimr(#$text) + NUM(6);
    #$text = %trimr(#$text) + ':';
    #$text = %trimr(#$text) + NUM(7);
    #$text = %trimr(#$text) + NUM(8);
    #$text = %trimr(#$text) + ':';
    #$text = %trimr(#$text) + NUM(9);
    #$text = %trimr(#$text) + NUM(10);

    If NUM(5) = '0';
      %subst(#$text:1:1) = ' ';
    EndIf;

  EndSr;
  // *********************************************
  // EDITS FOR ORDER NUMBER (O)
  BegSr EDTO;

    If psValu = *ZEROS;
      LeaveSr;
    EndIf;

    *In10 = *Off;
    If NUM(1) <> '0';
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(2);
    EndIf;
    If NUM(2) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(3);
    EndIf;
    If NUM(3) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(4);
    EndIf;
    If NUM(4) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(5);
    EndIf;
    If NUM(5) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(6);
    EndIf;
    If NUM(6) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(7);
    EndIf;
    If NUM(7) <> '0' OR *IN10 = *ON;
      *In10 = *On;
      #$text = %trimr(#$text) + NUM(8);
    EndIf;
    If *In10;
      #$text = %trimr(#$text) + '-';
    EndIf;
    If *In10;
      #$text = %trimr(#$text) + NUM(9);
    EndIf;
    If *In10;
      #$text = %trimr(#$text) + NUM(10);
    EndIf;

  EndSr;
  // *********************************************
End-Proc;

// ****************************************************************
// #$EDTP - Edit Phone Number
// Procedure to edit a phone number
// INPUT:  #$PHNO = NUMERIC FIELD CONTAINING NUMBER
// OUTPUT: #$PHNO = EDITED PHONE NUMBER
//
// EXAMPLES
// INPUT        OUTPUT
// 11235551234  123-555-1234     STRIP LEADING 1, FORMAT
// 01235551234  123-555-1234     STRIP LEADING 0, FORMAT
// 1235551234   123-555-1234
// 5551234      555-1234
// 555234       555234           NO CHANGE SINCE NOT LONG ENOUGH
// 41235551234  41235551234      NO CHANGE, INVALID NUMBER
//
Dcl-Proc #$EDTP EXPORT;
  Dcl-Pi *N Char(12);
    #$PHNO         Packed(11:0) CONST;
  End-Pi;
  Dcl-S PHNO         Packed(11:0);
  Dcl-S PHN          Char(1)    DIM(12);
  Dcl-S PH2          Char(1)    DIM(12);

  PHNO = #$PHNO;

  // IF 11 CHARACTERS AND DOES NOT START WITH A 1 RETURN UN-EDITED
  If PHNO>=20000000000;
    Return %trim(%editc(PHNO:'Z'));
  EndIf;

  // IF LESS THAN 7 CHARACTERS RETURN UN-EDITED
  If PHNO<1000000;
    Return %trim(%editc(PHNO:'Z'));
  EndIf;

  // IF 11 CHARACTERS AND HAS A LEADING ONE, REMOVE THE ONE
  If PHNO>=10000000000 AND PHNO<20000000000;
    PHNO-=10000000000;
  EndIf;

  Return %trim(%editw(PHNO:'    -   -   0'));

End-Proc;

// ****************************************************************
// #$CMD - RUN A COMMAND
// This proceudre runs a command. Errors are displayed in a
// window or ignored.
//
//   Input: #$CMD = Command to run.
//          #$NOE = Optional, Ignore Errors (Pass a 1)
//   Output: nothing
//
Dcl-Proc #$CMD EXPORT;
  Dcl-Pi *N;
    #$CMD          Varchar(32768) VALUE;
    PSNOE          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$LEN        Packed(15:5);
  Dcl-S #$NOE        Packed(15:5);
  // PROTOTYPE FOR QCMDEXC
  Dcl-Pr CMD  EXTPGM('QCMDEXC');
    COMMAND        Char(32768) CONST;
    LENGTH         Packed(15:5) CONST;

    // USE NOE IF PASSED OTHERWISE DEFAULT IT TO 0
  End-Pr;
  If %parms() > 1 AND %addr(PSNOE)<>*NULL;
    #$NOE=PSNOE;
  Else;
    #$NOE=0;
  EndIf;

  // IF THE ERROR TYPE IS WINDOW BUT IT IS A BATCH JOB, CHANGE IT TO 2
  // WHICH JUST LETS THE ESCAPE ERROR HAPPEN UNCONTROLLED
  If #$NOE=0 AND #$INTACT()<>'I';
    #$NOE=2;
  EndIf;

  #$LEN=%len(%trim(#$CMD));

  If #$NOE=2;
    CMD(%trim(#$CMD):#$LEN);
  Else;
    Monitor;
      CMD(%trim(#$CMD):#$LEN);
    On-Error;
      If #$NOE<>1;
        #$DSPWIN(psdsExcDta);
      EndIf;
    EndMon;
  EndIf;

End-Proc;

// ****************************************************************
// #$DspWin - Display Text in a Window
// This procedure displays some text in a window.
// It has options for all numberic or allow loeading and
// trailing spaces.
//
//   Input: #$TEXT    = Character value to display
//          #$MSGID   = Optional, Used as the title if you
//                      have a message id.
//          #$MSGFILE = Optional, message file name.
//   Output Displays a window with the text in it.
//
//   #$DSPWIN('SOME TEXT')
//
Dcl-Proc #$DSPWIN EXPORT;
  Dcl-Pi *N;
    #$TEXT         Char(8192) CONST;
    #$MSGID        Char(7)    CONST OPTIONS(*NOPASS : *OMIT);
    #$MSGFILE      Char(21)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-Ds MYAPIERROR;
    dsECBytesP     Int(10)    Pos(1) INZ(256); // Bytes Provided (size of struct)
    dsECBytesA     Int(10)    Pos(5) INZ(0);   // Bytes Available (returned by API)
    dsECMsgID      Char(7)    Pos(9);          // Msg ID of Error Msg Returned
    dsECReserv     Char(1)    Pos(16);         //Reserved
    dsECMsgDta     Char(240)  Pos(17);         // Msg Data of Error Msg Returned
  End-Ds;
  Dcl-Pr QUILNGTX  EXTPGM('QUILNGTX');
    Text           Char(8192) CONST;
    LEN            Int(10)    CONST;
    MSGID          Char(7)    CONST;
    MSGFILE        Char(21)   CONST;
    apiError                  LIKE(MYAPIERROR);
  End-Pr;
  Dcl-S MSGID                   LIKE(#$MSGID);
  Dcl-S MSGFILE                 LIKE(#$MSGFILE);

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

  QUILNGTX ( #$TEXT : %len(#$TEXT) : MSGID : MSGFILE : MYAPIERROR);

End-Proc;

// ****************************************************************
// #$LAST - RETURNS THE LAST CHARACTERS FROM A STRING
// This procedure returns the last characters from a string.
// You must specify the number of characters to return.
//
//   Input: #$STRING = The character string.
//          #$CHARS  = The number of characters to return
//   Output: the characters from the string
//
//   Examples
//    #$LAST('/tog/test.pdf':4) = '.pdf'
//
Dcl-Proc #$LAST EXPORT;
  Dcl-Pi *N Varchar(99);
    #$STRING       Varchar(2048) CONST;
    #$CHARS        Zoned(2:0) CONST;
  End-Pi;

  // If the number of character is 0 or less return blanks
  If #$CHARS<=0;
    Return ' ';
  EndIf;

  // If the length is greate than the string length return the
  // full field
  If %len(%trim(#$STRING))<=#$CHARS;
    Return %trim(#$STRING);
  EndIf;

  // Return the last number of characters
  Return %subst(%trim(#$STRING):(%len(%trim(#$STRING))-#$CHARS+1)
                       :#$CHARS);

End-Proc;

// ****************************************************************
// #$RNDUP - Round Up To Next Integer
// This procedure rounds a value up to the next integer.
//
//   Input: #$VALU= Decimal value.
//   Output       = Decimal Value Rounded to the Next Integer
//
//   #$RNDUP(123.15)              Returns 124
//   #$RNDUP(123.65)              Returns 124
//   #$RNDUP(123.00)              Returns 123
//
Dcl-Proc #$RndUp EXPORT;
  Dcl-Pi *N Packed(30:10);
    #$value        Packed(30:10) value;
    #$precision    Packed(30:10) CONST OPTIONS(*NOPASS:*OMIT);
  End-Pi;
  Dcl-S value        Packed(30);
  Dcl-S temp         Packed(20:0);
  Dcl-S precision    Packed(30:10);
  Dcl-S rem          Packed(5:5);
  Dcl-S tmp          Packed(60:20);

  // Get percission if passed, otherwise set it to 1
  If %parms() > 1 AND %addr(#$precision) <> *NULL;
    precision = #$precision;
  Else;
    precision = 1;
  EndIf;

  tmp = (#$value / precision) + 0.4999999999;
  tmp = %dech(tmp : 10 : 0);
  tmp = %int(tmp);
  tmp *= precision;

  Return tmp;

End-Proc;

// ****************************************************************
// #$RND05 - Round Up To 0.05 (Nickle)
// This proceudre test rounds a value up to the next full
// Nickle.
//
//   Input: #$VALU= Decimal value.
//   Output       = Decimal Value Rounded to the Next Nickle
//
//   #$RND05(123.45)              Returns 123.45
//   #$RND05(123.47)              Returns 123.50
//   #$RND05(123.50)              Returns 123.50
//
Dcl-Proc #$RND05 EXPORT;
  Dcl-Pi *N Packed(20:5);
    #$VALU         Packed(20:5) VALUE;
  End-Pi;

  Return #$RndUp(#$VALU:0.05);

End-Proc;

// ****************************************************************
// #$SPLIT - Split a String into an array
// This procedure splits a character string into an array of
// the pieces. I can be used to split words out in a sentence
// or split any delimited texts.
//
//   INPUT:  data   = The data to be parsed
//           delimiter = Optional, the delimiter
//                       used to seperate words
//                       if not passed a sopace will be used
//   RETURN:        = An array with the data parsed
//
Dcl-Proc #$SPLIT EXPORT;
  Dcl-Pi *N Char(1000) DIM(50);
    DATA           Char(8000) CONST;
    DELIMITER1     Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S RETURNARRAY  Char(1000) DIM(50);
  Dcl-S DELIMITER    Varchar(10);
  Dcl-S STARTPOS     Int(10);
  Dcl-S FOUNDPOS     Int(10);
  Dcl-S INCREMENT    Int(10);
  Dcl-S INDEX        Int(5)     INZ(1);

  If %parms()>1 and %addr(DELIMITER1) <> *null;
    DELIMITER = %trim(DELIMITER1);
  Else;
    DELIMITER = ' ';
  EndIf;

  If DATA <> *blanks;
    INCREMENT = %len(DELIMITER);
    STARTPOS = 1;
    DoU FOUNDPOS = %len(%trim(DATA)) + 1 or
             startPos>%len(%trim(DATA));
      FOUNDPOS = %scan(DELIMITER:%trim(DATA):STARTPOS);
      If FOUNDPOS = 0;
        FOUNDPOS = %len(%trim(DATA)) + 1;
      EndIf;
      RETURNARRAY(INDEX)=%subst(%trim(DATA):STARTPOS:FOUNDPOS - STARTPOS);
      INDEX += 1;
      STARTPOS = FOUNDPOS + INCREMENT;
    EndDo;
  EndIf;

  Return RETURNARRAY;

End-Proc;

// ****************************************************************
// #$TESTN - TEST NUMBERIC
// This procedure test a charactger field for numeric values.
// It has options for all numberic or allow loeading and
// trailing spaces.
//
//   Input: #$CHAR= CHAR(100) Character value to test
//          #$ALLD= Optional NUM(1) Allow leading blanks
//                  pass a 1 to allow, or 0, defaults to 0
//          #$ALTR= Optional NUM(1) Allow trailing blanks
//                  pass a 1 to allow, or 0, defaults to 0
//          #$ALNG= Optional NUM(1) Allow negatives "-"
//                  pass a 1 to allow, or 0, defaults to 0
//   Output Boolean On = Numerics Only
//
//   #$TESTN('12345')             Returns True
//   #$TESTN(' 12345')            Returns False
//   #$TESTN('12345 ')            Returns False
//   #$TESTN(' 12345- ')          Returns False
//   #$TESTN(' 12345':1)          Returns True
//   #$TESTN('12345 ':0:1)        Returns True
//   #$TESTN(' 12345- ':1:1:1)    Returns True
//   #$TESTN(' a1234- ':1:1:1)    Returns False
//
Dcl-Proc #$TESTN EXPORT;
  Dcl-Pi *N Ind;
    #$TEXT         Varchar(100) VALUE;
    PSALLD         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    PSALTR         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    PSALNG         Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$ALLD       Zoned(1:0);
  Dcl-S #$ALTR       Zoned(1:0);
  Dcl-S #$ALNG       Zoned(1:0);
  Dcl-S NUMBERS      Char(10)   INZ('0123456789');

  If %parms() > 1 AND %addr(PSALLD)<>*NULL;
    #$ALLD=PSALLD;
  EndIf;

  If %parms() > 2 AND %addr(PSALTR)<>*NULL;
    #$ALTR=PSALTR;
  EndIf;

  If %parms() > 3 AND %addr(PSALNG)<>*NULL;
    #$ALNG=PSALNG;
  EndIf;

  // If the field is blank, say it's not numeric
  // otherwise a trim on each side will return blank as numeric
  If #$TEXT=' ';
    Return *OFF;
  EndIf;

  // If allow leading blanks trim the field left
  If #$ALLD=1;
    #$TEXT=%triml(#$TEXT);
  EndIf;

  // If allow trailing blanks trim the field right
  If #$ALLD=1;
    #$TEXT=%trimr(#$TEXT);
  EndIf;

  // If allow negatives, remove all - signs
  If #$ALNG=1;
    #$TEXT=%scanrpl('-':'':#$TEXT);
  EndIf;

  If %check(NUMBERS:#$TEXT) > 0;
    Return *OFF;
  Else;
    Return *ON;
  EndIf;

End-Proc;

// ****************************************************************
// #$URIESC - Escapes special characters in a URI
// This procedure replaces special characters for a URI
// output field
//     Space - +       + - %2b      @ - %40
//         ! - %21     , - %2c      [ - %5b
//         " - %22     - - %2d XX   \ - %5c
//         # - %23     . - %2e XX   ] - %5d
//         $ - %24     / - %2f      ^ - %5e
//         % - %25     : - %3a      _ - %5f XX
//         & - %26     ; - %3b      ` - %60
//         ' - %27     < - %3c      { - %7b
//         ( - %28     = - %3d      ¦ - %7c
//         ) - %29     > - %3e      } - %7d
//         * - %2a XX  ? - %3f      ~ - %7e
//
// ADDED SPECIAL CHARACTERS FOR UNPRINTABLE CHARACTERS
//   CR x'0D' - %0D     LF x'25' - %0A     TAB x'05' - %09
// ON SPECIAL CHARACTERS IT HAS TO CONVERT THE EBCIDIC HEX
// VALUES TO THE ASCII HEX VALUES.
//
//        INPUT:  #$TXT = String in
//                #$SPC = Space option
//                        Optional, 1=+, 2=%20
//                        Default = 1
//      RETURNS:  Escaped string
//
// Example #$URIESC('<DATA>')='%3cDATA%3e'
//
Dcl-Proc #$URIESC EXPORT;
  Dcl-Pi *N Varchar(256000);
    #$TXT   Varchar(256000) VALUE;
    #$SPC   Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
    #$UPR   Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$PARMS      Packed(5:0);

  #$TXT = %trim(#$TXT);

  // This has to be first or it will mess up the rest
  #$TXT=%scanrpl('%':'%25':#$TXT);

  #$TXT=%scanrpl('!':'%21':#$TXT);
  #$TXT=%scanrpl('"':'%22':#$TXT);
  #$TXT=%scanrpl('#':'%23':#$TXT);
  #$TXT=%scanrpl('$':'%24':#$TXT);
  #$TXT=%scanrpl('&':'%26':#$TXT);
  #$TXT=%scanrpl('''':'%27':#$TXT);
  #$TXT=%scanrpl('(':'%28':#$TXT);
  #$TXT=%scanrpl(')':'%29':#$TXT);
  #$TXT=%scanrpl('@':'%40':#$TXT);
  #$TXT=%scanrpl('`':'%60':#$TXT);
  #$TXT=%scanrpl(x'05':'%09':#$TXT);

  #$PARMS=%parms();
  If %parms()>2 AND %addr(#$UPR)<>*NULL AND #$UPR=1;
    // #$TXT=%SCANRPL('*':'%2A':#$TXT)
    #$TXT=%scanrpl('+':'%2B':#$TXT);
    #$TXT=%scanrpl(',':'%2C':#$TXT);
    // #$TXT=%SCANRPL('-':'%2D':#$TXT)
    // #$TXT=%SCANRPL('.':'%2E':#$TXT)
    #$TXT=%scanrpl('/':'%2F':#$TXT);
    #$TXT=%scanrpl(':':'%3A':#$TXT);
    #$TXT=%scanrpl(';':'%3B':#$TXT);
    #$TXT=%scanrpl('<':'%3C':#$TXT);
    #$TXT=%scanrpl('=':'%3D':#$TXT);
    #$TXT=%scanrpl('>':'%3E':#$TXT);
    #$TXT=%scanrpl('?':'%3F':#$TXT);
    #$TXT=%scanrpl('[':'%5B':#$TXT);
    #$TXT=%scanrpl('\':'%5C':#$TXT);
    #$TXT=%scanrpl(']':'%5D':#$TXT);
    #$TXT=%scanrpl('^':'%5E':#$TXT);
    // #$TXT=%SCANRPL('_':'%5F':#$TXT)
    #$TXT=%scanrpl('~':'%7E':#$TXT);
    #$TXT=%scanrpl('{':'%7B':#$TXT);
    #$TXT=%scanrpl('¦':'%7C':#$TXT);
    #$TXT=%scanrpl('}':'%7D':#$TXT);
    #$TXT=%scanrpl(x'0D':'%0D':#$TXT);
    #$TXT=%scanrpl(x'25':'%0A':#$TXT);
  Else;
    // #$TXT=%SCANRPL('*':'%2a':#$TXT)
    #$TXT=%scanrpl('+':'%2b':#$TXT);
    #$TXT=%scanrpl(',':'%2c':#$TXT);
    // #$TXT=%SCANRPL('-':'%2d':#$TXT)
    // #$TXT=%SCANRPL('.':'%2e':#$TXT)
    #$TXT=%scanrpl('/':'%2f':#$TXT);
    #$TXT=%scanrpl(':':'%3a':#$TXT);
    #$TXT=%scanrpl(';':'%3b':#$TXT);
    #$TXT=%scanrpl('<':'%3c':#$TXT);
    #$TXT=%scanrpl('=':'%3d':#$TXT);
    #$TXT=%scanrpl('>':'%3e':#$TXT);
    #$TXT=%scanrpl('?':'%3f':#$TXT);
    #$TXT=%scanrpl('[':'%5b':#$TXT);
    #$TXT=%scanrpl('\':'%5c':#$TXT);
    #$TXT=%scanrpl(']':'%5d':#$TXT);
    #$TXT=%scanrpl('^':'%5e':#$TXT);
    // #$TXT=%SCANRPL('_':'%5f':#$TXT)
    #$TXT=%scanrpl('~':'%7e':#$TXT);
    #$TXT=%scanrpl('{':'%7b':#$TXT);
    #$TXT=%scanrpl('¦':'%7c':#$TXT);
    #$TXT=%scanrpl('}':'%7d':#$TXT);
    #$TXT=%scanrpl(x'0D':'%0d':#$TXT);
    #$TXT=%scanrpl(x'25':'%0a':#$TXT);
  EndIf;

  // Escape space last, uses passed space option or default to +
  If %parms() > 1 AND %addr(#$SPC) <> *NULL;
    If #$SPC=2;
      #$TXT=%scanrpl(' ':'%20':#$TXT);
    Else;
      #$TXT=%scanrpl(' ':'+':#$TXT);
    EndIf;
  Else;
    #$TXT=%scanrpl(' ':'+':#$TXT);
  EndIf;

  Return #$TXT;
End-Proc;

// ****************************************************************
// #$URIDESC - De-Escapes special characters in a URI
// This procedure replaces special characters for a URI
// output field
//     Space - +       + - %2b      @ - %40
//         ! - %21     , - %2c      [ - %5b
//         " - %22     - - %2d XX   \ - %5c
//         # - %23     . - %2e XX   ] - %5d
//         $ - %24     / - %2f      ^ - %5e
//         % - %25     : - %3a      _ - %5f XX
//         & - %26     ; - %3b      ` - %60
//         ' - %27     < - %3c      { - %7b
//         ( - %28     = - %3d      ¦ - %7c
//         ) - %29     > - %3e      } - %7d
//         * - %2a XX  ? - %3f      ~ - %7e
//
// ADDED SPECIAL CHARACTERS FOR UNPRINTABLE CHARACTERS
//   CR x'0D' - %0D     LF x'25' - %0A     TAB x'05' - %09
// ON SPECIAL CHARACTERS IT HAS TO CONVERT THE EBCIDIC HEX
// VALUES TO THE ASCII HEX VALUES.
//
//        INPUT:  #$TXT = String in
//                #$SPC = Space option
//                        Optional, 1=+, 2=%20
//                        Default = 1
//      RETURNS:  Escaped string
//
// Example #$URIESC('<DATA>')='%3cDATA%3e'
//
Dcl-Proc #$URIDESC EXPORT;
  Dcl-Pi *N Varchar(256000);
    #$TXT   Varchar(256000) VALUE;
    #$SPC   Packed(1:0) CONST OPTIONS(*NOPASS : *OMIT);

  End-Pi;
  #$TXT = %trim(#$TXT);
  #$TXT=%scanrpl('%21':'!':#$TXT);
  #$TXT=%scanrpl('%22':'"':#$TXT);
  #$TXT=%scanrpl('%23':'#':#$TXT);
  #$TXT=%scanrpl('%24':'$':#$TXT);
  #$TXT=%scanrpl('%26':'&':#$TXT);
  #$TXT=%scanrpl('%27':'''':#$TXT);
  #$TXT=%scanrpl('%28':'(':#$TXT);
  #$TXT=%scanrpl('%29':')':#$TXT);
  // #$TXT=%SCANRPL('%2a':'*':#$TXT)
  // #$TXT=%SCANRPL('%2A':'*':#$TXT)
  #$TXT=%scanrpl('%2b':'+':#$TXT);
  #$TXT=%scanrpl('%2B':'+':#$TXT);
  #$TXT=%scanrpl('%2c':',':#$TXT);
  #$TXT=%scanrpl('%2C':',':#$TXT);
  // #$TXT=%SCANRPL('%2d':'-':#$TXT)
  // #$TXT=%SCANRPL('%2D':'-':#$TXT)
  // #$TXT=%SCANRPL('%2e':'.':#$TXT)
  // #$TXT=%SCANRPL('%2E':'.':#$TXT)
  #$TXT=%scanrpl('%2f':'/':#$TXT);
  #$TXT=%scanrpl('%2F':'/':#$TXT);
  #$TXT=%scanrpl('%3a':':':#$TXT);
  #$TXT=%scanrpl('%3A':':':#$TXT);
  #$TXT=%scanrpl('%3b':';':#$TXT);
  #$TXT=%scanrpl('%3B':';':#$TXT);
  #$TXT=%scanrpl('%3c':'<':#$TXT);
  #$TXT=%scanrpl('%3C':'<':#$TXT);
  #$TXT=%scanrpl('%3d':'=':#$TXT);
  #$TXT=%scanrpl('%3D':'=':#$TXT);
  #$TXT=%scanrpl('%3e':'>':#$TXT);
  #$TXT=%scanrpl('%3E':'>':#$TXT);
  #$TXT=%scanrpl('%3f':'?':#$TXT);
  #$TXT=%scanrpl('%3F':'?':#$TXT);
  #$TXT=%scanrpl('%40':'@':#$TXT);
  #$TXT=%scanrpl('%5b':'[':#$TXT);
  #$TXT=%scanrpl('%5B':'[':#$TXT);
  #$TXT=%scanrpl('%5c':'\':#$TXT);
  #$TXT=%scanrpl('%5C':'\':#$TXT);
  #$TXT=%scanrpl('%5d':']':#$TXT);
  #$TXT=%scanrpl('%5D':']':#$TXT);
  #$TXT=%scanrpl('%5e':'^':#$TXT);
  #$TXT=%scanrpl('%5E':'^':#$TXT);
  // #$TXT=%SCANRPL('%5f':'_':#$TXT)
  // #$TXT=%SCANRPL('%5F':'_':#$TXT)
  #$TXT=%scanrpl('%60':'`':#$TXT);
  #$TXT=%scanrpl('%7b':'{':#$TXT);
  #$TXT=%scanrpl('%7B':'{':#$TXT);
  #$TXT=%scanrpl('%7c':'¦':#$TXT);
  #$TXT=%scanrpl('%7C':'¦':#$TXT);
  #$TXT=%scanrpl('%7d':'}':#$TXT);
  #$TXT=%scanrpl('%7D':'}':#$TXT);
  #$TXT=%scanrpl('%7e':'~':#$TXT);
  #$TXT=%scanrpl('%7E':'~':#$TXT);
  #$TXT=%scanrpl('%09':x'05':#$TXT);
  #$TXT=%scanrpl('%0d':x'0D':#$TXT);
  #$TXT=%scanrpl('%0D':x'0D':#$TXT);
  #$TXT=%scanrpl('%0a':x'25':#$TXT);
  #$TXT=%scanrpl('%0A':x'25':#$TXT);

  // De-escape space last, uses passed space option or default to +
  If %parms() > 2 AND %addr(#$SPC) <> *NULL;
    If #$SPC=2;
      #$TXT=%scanrpl('%20':' ':#$TXT);
    Else;
      #$TXT=%scanrpl('+':' ':#$TXT);
    EndIf;
  Else;
    #$TXT=%scanrpl('+':' ':#$TXT);
  EndIf;

  // This has to be last or it will mess sup the rest
  #$TXT=%scanrpl('%25':'%':#$TXT);

  Return #$TXT;
End-Proc;

// ****************************************************************
// #$VEML - Validate an Email Address
// This Procedure validates an email address. It cannot tell
// if the address actually exists, so it just checks for a
// valid format.
//
//   Input: #$EMAIL= CHAR(100) Email Adress to Test
//   Output Boolean On = Error
//
//   #$VEML('tim@temp.com')       Returns False
//   #$VEML('tim@temp,com')       Returns True
//   #$VEML('tim#temp.com')       Returns True
//   #$VEML('@temp.com   ')       Returns True
//   #$VEML('tim@temp.   ')       Returns True
//   #$VEML('tim@te@p.com')       Returns True
//   #$VEML('tim@.com    ')       Returns True
//   #$VEML('mail:tim@temp.com')  Returns True
//
Dcl-Proc #$VEML EXPORT;
  Dcl-Pi *N Ind;
    #$EMAIL        Varchar(100) VALUE;
  End-Pi;
  Dcl-S X            Packed(3:0);
  Dcl-S PART1        Char(100);
  Dcl-S PART2        Char(100);
  Dcl-S LEN          Packed(3:0);
  If #$VEML2(#$EMAIL)<>' ';
    Return *ON;
  Else;
    Return *OFF;
  EndIf;

End-Proc;

// ****************************************************************
// #$VEML2 - Validate an Email Address
// This Procedure validates an email address. It cannot tell
// if the address actually exists, so it just checks for a
// valid format.
//
// It returns a message if there is an error, otherwise it
// returns blanks. The intent is to move the error into ERM
// and if ERM is not blank redisplay the screen with the error.
//
// The error message is returned centered since it is designed
// to go into ERM. If you need it left justified include it in
// a %TRIM().
//
//   Input: #$EMAIL= CHAR(100) Email Adress to Test
//   Output = Error Message or Blank
//
//   #$VEML2('tim@temp.com')  Returns Blank
//   #$VEML2('tim@temp,com')  Returns Error - Invalid Domain
//   #$VEML2('tim#temp.com')  Returns Error - Invalid Format
//   #$VEML2('@temp.com   ')  Returns Error - Missing Recipient
//   #$VEML2('tim@temp.   ')  Returns Error - Invalid Domain
//   #$VEML2('tim@te@p.com')  Returns Error - Invalid Format
//   #$VEML2('tim@.com    ')  Returns Error - Invalid Domain
//   #$VEML2('t:m@.com    ')  Returns Error - Invalid Characters
//
Dcl-Proc #$VEML2 EXPORT;
  Dcl-Pi *N Char(50);
    #$EMAIL        Varchar(100) VALUE;
  End-Pi;
  Dcl-S X      Packed(3:0);
  Dcl-S LEN    Packed(3:0);
  Dcl-S PART1  Char(100);
  Dcl-S PART2  Char(100);
  Dcl-S VAL1   Char(94)   INZ('ABCDEFGHIJKLMNOPQRSTUVWXYZ+
                               abcdefghijklmnopqrstuvwxyz+
                               0123456789 !#$%&*+-/=?^_`{|+
                               "(),;<>@[\].''');
  Dcl-S BLANK1 Char(94)   INZ(' ');
  Dcl-S VAL2   Char(65)   INZ('ABCDEFGHIJKLMNOPQRSTUVWXYZ+
                               abcdefghijklmnopqrstuvwxyz+
                               0123456789-.>');
  Dcl-S BLANK2 Char(65)   INZ(' ');

  // FIND FIRST INSTANCE OF @, IF IT IS IN POSITION 1 GIVE ERROR
  X=%scan('@':#$EMAIL);
  If X=1;
    Return #$CNTR('ERROR PART BEFORE THE @':50);
  EndIf;
  If X=0;
    Return #$CNTR('ERROR - MISSING @':50);
  EndIf;

  // GET THE TOTAL LENGTH AND SPLIT THE ADDRESS TO 2 PARTS
  LEN=%len(%trimr(#$EMAIL));
  PART1=%subst(#$EMAIL:1:X-1);
  PART2=%subst(#$EMAIL:X+1:(LEN-X));

  // LOOK FOR A SECOND @, IF THERE IS ONE GIVE AN ERROR
  If %scan('@':#$EMAIL:X+1)<>0;
    Return #$CNTR('ERROR CONTAIN MORE THAN 1 @':50);
  EndIf;

  // LOOK FOR A . AFTER THE @, IF THERE IS NOT ONE GIVE AN ERROR
  If %scan('.':#$EMAIL:X+1)=0;
    Return #$CNTR('ERROR AFTER THE @':50);
  EndIf;

  // LOOK FOR A . AFTER THE @, IF IT IS THE NEXT CHARACTER GIVE AN ERROR
  If %scan('.':#$EMAIL:X+1)=X+1;
    Return #$CNTR('ERROR AFTER THE @':50);
  EndIf;

  // LOOK FOR ANYTHING AFTER THE ., IF THERE IS NOTHING THERE GIVE AN ERROR
  If %scan('.':#$EMAIL:X+1)= %len(%trim(#$EMAIL));
    Return #$CNTR('ERROR DOMAIN, (THE .COM PART)':50);
  EndIf;

  // LOOK FOR DOUBLE PERIODS (..), IF THEY EXIST GIVE AN ERROR
  If %scan('..':#$EMAIL)<>0;
    Return #$CNTR('ERROR CONTAIN DUOBLE PERIODS (..)':50);
  EndIf;

  // MAKE SURE THE RECIPIENT PART SO NO LONGER THAN 64 CHARACTERS
  If %len(%trimr(PART1))>64;
    Return #$CNTR('ERROR EXCEED 64 CHARACTERS':50);
  EndIf;

  // MAKE SURE THE ADDRESS ONLY CONTAINS VALID CHARACTERS,
  // REPLACE ALL VALID CHARACTERS WITH BLANK AND IF THE RESULT
  // IS NOT BLANK IT CONTAINS A NON-VALID CHARACTER
  If %xlate(VAL1:BLANK1:#$EMAIL)<>' ';
    Return #$CNTR('ERROR INVALID CHARACTERS':50);
  EndIf;

  // MAKE SURE THE PART AFTER THE @ CONTAINS VALID CHARACTERS,
  // REPLACE ALL VALID CHARACTERS WITH BLANK AND IF THE RESULT
  // ISNOT BLANK IT CONTAINS A NON-VALID CHARACTER
  If %xlate(VAL2:BLANK2:PART2)<>' ';
    Return #$CNTR('ERROR INVALID CHARACTERS':50);
  EndIf;

  Return *BLANKS;

End-Proc;

// ****************************************************************
// #$FLDTXT - Get the text for a field
// This proceudre returns the text for a field in a file.
//
//   Input:  #$FILE  = File the field is in.
//           #$FIELD = Field name.
//           #$LIB   = The library the files is in, optional
//                     Defaults to *LIBL
//   Output: #$FLDTXT  = Field text, if none exists it
//                       returns the column header, if any
//                       errors occure it returns 'ERROR'
//
Dcl-Proc #$FLDTXT EXPORT;
  Dcl-Pi *N Varchar(50);
    #$FILE         Varchar(10) CONST;
    #$FIELD        Varchar(10) CONST;
    #$LIB          Char(10)   CONST OPTIONS(*NOPASS);
  End-Pi;
  Dcl-S PSFLDTXT     Char(50);
  Dcl-S LIB          Char(10);
  Dcl-S FIELD        Char(10);

  If %parms >= 3;
    LIB = #$LIB;
  Else;
    LIB = '*LIBL';
  EndIf;

  #$CMD('DLTF QTEMP/##DSPFFD':1);
  Monitor;
    #$CMD('DSPFFD ' + %trim(LIB) + '/' + %trim(#$FILE) +
                ' OUTPUT(*OUTFILE) OUTFILE(QTEMP/##DSPFFD)':2);
  On-Error;
    Return 'ERROR';
  EndMon;

  Exec SQL
            SELECT  WHFTXT INTO :PSFLDTXT
            FROM      QTEMP/##DSPFFD
            WHERE     WHFLDE = UCASE(:#$FIELD);

  If SQLSTATE = '00000' AND PSFLDTXT<>' ';
    Return    PSFLDTXT;
  Else;
    Exec SQL
              SELECT  WHCHD1 INTO :PSFLDTXT
              FROM      QTEMP/##DSPFFD
              WHERE     WHFLDE = UCASE(:#$FIELD);
    If SQLSTATE <> '00000';
      Return 'ERROR';
    Else;
      Return    PSFLDTXT;
    EndIf;
  EndIf;

End-Proc;

// ****************************************************************
// #$RTVOBJD - RETRIEVE OBJECT DESCRIPTION
// This procedure retreives an object description.
//
//   Input: #$OBJ = CHAR(10) Name of the object
//          #$LIB = CHAR(10) Library the object is in
//          #$TYPE= CHAR(10) Type of the object
//   Output the #$ObjD Data structure, you can see it
//          in the BASFNCV1PR member or the programming
//          standards document
//
Dcl-Proc #$RTVOBJD EXPORT;
  Dcl-Pi *N  LIKE(#$ObjD);
    #$OBJ          Char(10)   VALUE;
    #$LIB          Char(10)   VALUE;
    #$TYPE         Char(10)   VALUE;

    // -- Api error data structure:  -----------------------------------------**
  End-Pi;
  Dcl-Ds apiError;
    AeBytPro       Int(10)    INZ( %size( apiError ));
    AeBytAvl       Int(10)    INZ;
    AeMsgId        Char(7);
    *N             Char(1);
    AeMsgDta       Char(128);
  End-Ds;

  Dcl-Pr RtvObjD  EXTPGM( 'QUSROBJD' );
    RoRcvVar       Char(32767) OPTIONS( *VARSIZE );
    RoRcvVarLen    Int(10)    CONST;
    RoFmtNam       Char(8)    CONST;
    RoObjNamQ      Char(20)   CONST;
    RoObjTyp       Char(10)   CONST;
    RoError        Char(32767) OPTIONS( *VARSIZE );
  End-Pr;

  RtvObjD( #$ObjD : %size( #$ObjD ) : 'OBJD0400' : #$OBJ + #$LIB
                : #$TYPE : apiError );

  If AeBytAvl   >  *Zero         And AeMsgId    =  'CPF9801';
    Clear   #$ObjD;
  EndIf;

  Return #$ObjD;

End-Proc;

// ****************************************************************
// #$SNDMSG - Send Message                                       *
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
//
Dcl-Proc #$SNDMSG EXPORT;
  Dcl-Pi *N;
    MSG            Varchar(1024) CONST;
    PSMSGTYPE      Char(10)   CONST OPTIONS(*NOPASS);
    PSTOPGMQ       Char(10)   CONST OPTIONS(*NOPASS);
  End-Pi;

  Dcl-Ds QUSEC; //QUSEC
    QUSBPRV        Bindec(9)  Pos(1); //Bytes Provided
    QUSBAVL        Bindec(9)  Pos(5); //Bytes Available
    QUSEI          Char(7)    Pos(9); //Exception Id
    QUSERVED       Char(1)    Pos(16); //Reserved
    // QUSED01                17     17
  End-Ds;

  Dcl-Ds QUSC0200; //Qus ERRC0200
    QUSK01         Bindec(9)  Pos(1); //Key
    QUSBPRV00      Bindec(9)  Pos(5); //Bytes Provided
    QUSBAVL14      Bindec(9)  Pos(9); //Bytes Available
    QUSEI00        Char(7)    Pos(13); //Exception Id
    QUSERVED39     Char(1)    Pos(20); //Reserved
    QUSCCSID11     Bindec(9)  Pos(21); //CCSID
    QUSOED01       Bindec(9)  Pos(25); //Offset Exc Data
    QUSLED01       Bindec(9)  Pos(29); //Length Exc Data
    // QUSRSV214              33     33
    // QUSED02                34     34
  End-Ds;

  // Local variables.
  Dcl-S msgType                 LIKE(PSMSGTYPE);
  Dcl-S toPgmQ                  LIKE(PSTOPGMQ);
  Dcl-S msgid        Char(7)    INZ('CPF9897');

  Dcl-Ds msgf Len(21);
    MsgFile        Char(10)   INZ('QCPFMSG');
    MsgLib         Char(10)   INZ('*LIBL');
  End-Ds;

  Dcl-S nRelInv      Int(10)    INZ(2);
  Dcl-S RtnMsgKey    Char(4);

  Dcl-Ds myAPIErrorDS  LIKEDS(QUSEC);

  // PROTOTYPE FOR IBM SEND MESSAGE API
  Dcl-Pr QMHSNDPM  EXTPGM('QMHSNDPM');
    szMsgID        Char(7)    CONST;
    szMsgFile      Char(20)   CONST;
    szMsgData      Char(6000) CONST OPTIONS(*VARSIZE);
    nMsgDataLen    Int(10)    CONST;
    // *  Message Type may be one of the following:
    // *  *COMP    - Completion
    // *  *DIAG    - Diagnostic
    // *  *ESCAPE  - Escape
    // *  *INFO    - Informational
    // *  *INQ     - Inquiry.
    // *             (Only used when ToPgmQ(*EXT) is specified).
    // *  *NOTIFY  - Notify
    // *  *RQS     - Request
    // *  *STATUS  - Status
    PSMSGTYPE      Char(10)   CONST;
    // *  Call Stack Entry may be one of the following:
    // *  *        - *SAME
    // *  *EXT     - The external message queue
    // *  *CTLBDY  - Control Boundary
    szCallStkEntry Char(10)   CONST;
    nRelativeCallStkEntry Int(10)    CONST;
    szRtnMsgKey    Char(4);
    apiErrorDS                LIKEDS(QUSEC) OPTIONS(*VARSIZE);
  End-Pr;

  // ovveride passed parms
  If %parms() >= 2;
    msgType = %upper(PSMSGTYPE);
  Else;
    msgType = '*INFO';
  EndIf;
  If %parms() >= 3;
    toPgmQ = %upper(PSTOPGMQ);
  Else;
    toPgmQ = '*';
  EndIf;

  myAPIErrorDS = *ALLX'00';

  // SET MESSAGE TYPE
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

  // SET TO PROGRAM QUEUE
  toPgmQ='*PRV';
  If %parms()>= 3;
    If PSTOPGMQ <> *BLANKS;
      toPgmQ=  PSTOPGMQ;
    EndIf;
  EndIf;

  If toPgmQ = '*SAME';
    toPgmQ = '*';
  EndIf;

  // STATUS MESSAGES ALWAYS GO TOPGMQ(*EXT)
  If msgType = '*STATUS';
    toPgmQ = '*EXT';
  EndIf;

  // NRELINV TELLS THE MESSAGE TO GO UP THAT MANY
  // ENTRIES IN THE CALL STACK AND GO TO THAT ENTRIES
  // MESSAGE QUEUE. IT IS DEFAULTED TO 1 TO GO TO THE
  // PROGRAM CALLING #$SNDMSG. THE FOLLOWING MOVES IT
  // UP IN THE CALL STACKED BASED ON THE PASSED PARAMETERS.
  SELECT;
      // *SAME
    WHEN toPgmQ  = ' ' OR toPgmQ = '*SAME' OR toPgmQ = '*';
      toPgmQ = '*';
      nRelInv = 2;
      // *PRVPGM
    WHEN toPgmQ = '*PRVPGM';
      toPgmQ = '*CTLBDY';
      nRelInv = 2;
      // *CTLBDY
    WHEN toPgmQ = '*CTLBDY';
      nRelInv = 3;
      // *EXT
    WHEN toPgmQ = '*EXT';
      nRelInv = 2;
      // *PRV OR ANYTHING ELSE
    OTHER;
      toPgmQ = '*';
      nRelInv = 3;
  ENDSL;

  QMHSNDPM(msgid   : msgf : %trim(MSG): %len(%trim(MSG)) : msgType
                : toPgmQ    : nRelInv   : RtnMsgKey : myAPIErrorDS);

  Return;

End-Proc;


// ****************************************************************
// #$FILE - Split File Name From Path
// Procedure to send return the file name from a path.
//  INPUT:   PATH  = An IFS Path Example:'/tog/file.xls'
//  OUTPUT:  FILE  = The file name portion of the path
//                   Example:'file.xls'
//
Dcl-Proc #$FILE EXPORT;
  Dcl-Pi *N Char(2048);
    PATH    Varchar(4096) CONST;
  End-Pi;
  Dcl-S tpPath char(4096);
  Dcl-S l packed(5);

  // CONVERT ANY '\' TO '/'
  tpPath=%scanrpl('\':'/':PATH);

  // FIND THE LAST '/', CAN BE REPLACED WITH SCANR ON 7.3
  l = 0;
  DoW %scan('/':tpPath:l+1)<>0;
    l=%scan('/':tpPath:l+1);
  EndDo;

  // SPLIT OUT THE FILE PORTION
  Return %subst(%trim(tpPath):l+1: %len(%trim(tpPath))-l);

End-Proc;


// ****************************************************************
// #$FOLDER - Split Folder From Path
// Procedure to return folder from path.
//  INPUT:   PATH  = An IFS Path Example:'/tog/file.xls'
//  OUTPUT:  FILE  = The file name portion of the path
//                   Example:'/tog'
//
Dcl-Proc #$FOLDER EXPORT;
  Dcl-Pi *N Char(2048);
    PATH           Varchar(4096) CONST;
  End-Pi;
  Dcl-S l packed(5);

  // CONVERT ANY '\' TO '/'
  Dcl-S tpPath char(4096);
  tpPath=%scanrpl('\':'/':PATH);

  // FIND THE LAST '/', CAN BE REPLACED WITH SCANR ON 7.3
  l = 0;
  DoW %scan('/':tpPath:l+1)<>0;
    l=%scan('/':tpPath:l+1);
  EndDo;

  // SPLIT OUT THE FILE PORTION
  Return %subst(%trim(tpPath):1:l-1);

End-Proc;


// ****************************************************************
// #$SQLESC Converts * to % and double any single quotes.
// This is used to prepare strings to be added to an SQL
// statement.
//
//  INPUT:  #$TEXT = TEXT TO ESCAPE
// RETURN:         = THE SAME TEXT WITH QUOTES DOUBLED
//                   AND * CONVERTED TO %
//
Dcl-Proc #$SQLESC EXPORT;
  Dcl-Pi *N Varchar(512);
    #$TEXT         Varchar(512) VALUE;
    #$CNVAST       Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S TEMP         Varchar(520);
  Dcl-S CNVAST       Zoned(1:0);

  If %parms() > 1 AND %addr(#$CNVAST) <> *NULL;
    CNVAST=#$CNVAST;
  Else;
    CNVAST=1;
  EndIf;

  TEMP=%scanrpl('''':'''''':#$TEXT);

  If CNVAST = 1;
    TEMP=%scanrpl('*':'%':TEMP);
  EndIf;

  Return %trim(TEMP);

End-Proc;


// *************************************************************
// #$SQLSTT checks the last SQL statement for an error. It
// returns *ON if an error occured or an end of file is reached,
// otherwise it returns off. If an error occures it throws an
// escape message by default so it can be monitored for in a
// monitor group or allowed to crash if it is not monitored for.
//
// Use this after an SQL statment like this:
// EXEC SQL SELECT * FROM XYZ;
// #$SQLSTT();
//
// Or use it to loop through fetch statements like this:
// EXEC SQL FECTH ...
// DOW NOT #$SQLSTT();
//    // DO SOMETHING HERE
//    EXEC SQL FECTH ...
// ENDDO;
//
//  INPUT: SQLSTT  = Optional, pass the SQLSTT variable.
//         MSGTYPE = Optional, pass a 1 to send a diagnostic
//                   message instead of an escape message.
//                   Default is 0 for an escape message.
// RETURN:         = *ON if an error or EOF occures
//
Dcl-Proc #$SQLSTT EXPORT;
  Dcl-Pi *N Ind;
    psSqlStt       char(5)    const options(*nopass : *omit);
    psType         zoned(1:0) const options(*nopass : *omit);
  End-Pi;

  // Prototype for error data structure
  Dcl-Ds errorCode;
    bytesProv      int(10)    inz(0);
    bytesAvail     int(10)    inz(0);
  End-Ds;

  // Prototype to send message
  Dcl-Pr QMHSNDPM  EXTPGM('QMHSNDPM');
    messageId      char(7)    const;
    qualMsgF       char(20)   const;
    msgData        char(256)  const;
    msgDtaLen      int(10)    const;
    msgType        char(10)   const;
    callStkEnt     char(10)   const;
    callStkCnt     int(10)    const;
    messageKey     char(4);
    errCode                   likeds(errorCode);
  End-Pr;

  // Stand alone variables
  Dcl-S state        char(5);
  Dcl-S msgText      char(256);
  Dcl-S type         zoned(1:0) inz(0);
  Dcl-S msgType      char(10)   inz(*blanks);
  Dcl-S msgKey       char(4);
  Dcl-S error        ind        inz(*on);

  // Get the last sqlstt and message text
  // if the state is passed, and there is not an error do not run the diagostic,
  // it takes to long to run.
  If %parms() > 1 and psSqlStt <= '02';
    state = psSqlStt;
  Else;
    Exec SQL
              GET Diagnostics Condition 1
                :msgText = message_text,
                :state = returned_sqlstate;
  EndIf;

  If %subst(state:1:2) = '00'; // No error
    error = *off;
  ElseIf %subst(state:1:2) = '02'; // Error, command not proceesed
    error = *on;
  ElseIf %subst(state:1:2) = '01'; // Warning, command processed
    msgType = '*DIAG';
    error = *off;
  Else;
    msgType = '*ESCAPE';
    error = *on;
  EndIf;

  // Send message if selected
  If msgType <> '';
    QMHSNDPM( 'CPF9897' : 'QCPFMSG   *LIBL' : %trim(msgText) :
              %len(%trim(msgText)) : msgType : '*' : 1 : msgKey : errorCode );
  EndIf;

  Return error;

End-Proc;

// ****************************************************************
// #$C1ST Format text so that each word starts with an upper
// case letter and has the rest in lowercase.
//
//  INPUT:  TEXT   = Text to format
// RETURN:         = The formatted text
//
//    EVAL URL=#$C1ST(MODEL)   - LINK TO IMAGE
//
Dcl-Proc #$C1ST EXPORT;
  Dcl-Pi *N Varchar(10000);
    #$TEXT         Varchar(10000) CONST;
  End-Pi;
  Dcl-S txt         Varchar(10000);
  Dcl-S I            Zoned(5:0);


  txt = #$TEXT;

  // LOWERCASE THE WHOLE STRING
  txt=#$lowfy(txt);
  %subst(txt:1:1)=#$upify(%subst(txt:1:1));

  For I = 2 TO %len(%trimr(txt));
    If %subst(txt:I:1) = ' ' AND %subst(txt:I+1:1) < '0';
      I += 1;
      %subst(txt:I:1) = #$upify(%subst(txt:I:1));
    EndIf;
  EndFor;

  Return txt;

End-Proc;

// ****************************************************************
// #$XLDTTM Converts an Excel floating point date to a
// YYYYMMDDHHMMSS field.
//
//  INPUT:  #$DATE = Excel Date, * bit floating point
// RETURN:         = A YYYYMMDDHHMMSS value in a 14,0
//                   packed field.
//
//    MOVE  *ZEROS      DATETIME     14 0
//    EVAL  DATETIME=#$XLDTTM(XLDATE)
//
Dcl-Proc #$XLDTTM EXPORT;
  Dcl-Pi *N Zoned(14:0);
    #$DATE         Float(8)   VALUE;
  End-Pi;
  Dcl-S TEMP         Zoned(14:7);
  Dcl-S DATE         Zoned(7:0);
  Dcl-S TIME         Zoned(7:7);
  Dcl-S SECONDS      Zoned(7:0);
  Dcl-S RDATE        Zoned(8:0);
  Dcl-S RTIME        Zoned(6:0);
  Dcl-S RBOTH        Zoned(14:0);
  Dcl-S WRKDATE      Date(*ISO) INZ(D'1900-01-01');
  Dcl-S WRKTIME      TIME       INZ(T'23.59.59');

  TEMP = #$DATE;
  DATE = TEMP;
  TIME = TEMP;

  // Excel date = days since 1900-01-01 - 2
  WRKDATE+=%days(DATE-2);
  RDATE=%dec(%char(WRKDATE:*ISO0):8:0);

  // Time - fraction of a day, so get number of seconds, then format as hhmms
  SECONDS=(24*60*60)*TIME;
  WRKTIME+=%seconds(SECONDS + 2);
  RTIME=%dec(%char(WRKTIME:*ISO0):6:0);

  Return RDATE * 1000000 + RTIME;

End-Proc;

// ****************************************************************
// #$XLDATE€Converts an Excel floating point date to a
// YYYYMMDD field.
//
//  INPUT:  #$DATE = Excel Date, * bit floating point
// RETURN:         = A YYYYMMDD value in an 8,0 packed field.
//
//    MOVE  *ZEROS      DATE          8 0
//    EVAL  DATE=#$XLDATE(XLDATE)
//
Dcl-Proc #$XLDATE EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$DATE         Float(8)   VALUE;
  End-Pi;
  Dcl-S TEMP         Zoned(14:7);
  Dcl-S DATE         Zoned(7:0);
  Dcl-S RDATE        Zoned(8:0);
  Dcl-S WRKDATE      Date(*ISO) INZ(D'1900-01-01');

  TEMP = #$DATE;
  DATE = TEMP;

  // EXCEL DATE = DAYS SINCE 1900-01-01 - 2
  WRKDATE+=%days(DATE-2);
  RDATE=%dec(%char(WRKDATE:*ISO0):8:0);

  Return RDATE;

End-Proc;

// ****************************************************************
// #$XLTIME€Converts an Excel floating point date to a
// HHMMSS field.
//
//  INPUT:  #$DATE = Excel Date, * bit floating point
// RETURN:         = A HHMMSS value in a 6,0 packed field.
//
//    MOVE  *ZEROS      TIME          6 0
//    EVAL  TIME=#$XLTIME(XLDATE)
//
Dcl-Proc #$XLTIME EXPORT;
  Dcl-Pi *N Zoned(6:0);
    #$DATE         Float(8)   VALUE;
  End-Pi;
  Dcl-S TEMP         Zoned(14:7);
  Dcl-S TIME         Zoned(7:7);
  Dcl-S SECONDS      Zoned(7:0);
  Dcl-S RTIME        Zoned(6:0);
  Dcl-S WRKTIME      TIME       INZ(T'23.59.59');

  TEMP = #$DATE;
  TIME = TEMP;

  // TIME - FRACTION OF A DAY, SO GET NUMBER OF SECONDS, THEN FORMAT AS HHMMS
  SECONDS=(24*60*60)*TIME;
  WRKTIME+=%seconds(SECONDS + 2);
  RTIME=%dec(%char(WRKTIME:*ISO0):6:0);

  Return RTIME;

End-Proc;


// ****************************************************************
// #$VPHN - Validate a Phone Number
// This Procedure validates a phone number. It cannot tell
// if the phone number exists, it just checks the format.
//
// This routine only checks that the field only contains numeric
// characters and the - symbol. It also makes usre that there
// are at least seven digits entered.
//
//   Input: #$PHONE= CHAR(15) The phone number to validate'
//   Output Boolean On = Error
//
//   #$VPHN('9185551234')         Returns False
//   #$VPHN('918-555-1234')       Returns False
//   #$VPHN('918@555-1234')       Returns True
//
//   The longest valid phone number calling from the United
//   State would be an international number in this format:
//   011 44 11 22 33 44 55, so 15 digits, 21 characters.
//   There could also be dashes between the sections, depending
//   on the local convetions uses.
//
Dcl-Proc #$VPHN EXPORT;
  Dcl-Pi *N Ind;
    #$phon         Varchar(30) VALUE;
  End-Pi;
  Dcl-S phon         Char(30);
  phon = #$phon;

  // MAKE TEST FOR ANY INVALID CHARACTERS
  If %check('0123456789- ':phon)<>0;
    Return *ON;
  EndIf;

  // STRIP BLANKS AND DASHES AND MAKE SURE THERE AT LEAST 7 CHARACTERS
  phon=%scanrpl('-':'':phon);
  phon=%scanrpl(' ':'':%trim(phon));
  If %len(%trim(phon))<7;
    Return *ON;
  EndIf;

  // MAKE SURE THERE ARE NOT MORE THAN 15 DIGITS
  If %len(%trim(phon))>15;
    Return *ON;
  EndIf;

  Return *OFF;

End-Proc;

// ****************************************************************
// #$URLTST Check to see if a resource at a URL exists.
//
//  INPUT:  #$URL  = The url to test.
// RETURN:  boolean= RETURNS *ON IF THE URL IS FOUND,
//                   OTHERWISE IT RETURNS *OFF
//
// The point of this program is to pass a URL and find out if
// something exists at that URL. It does not validate the type
// or what exists there, just that some server responded with
// a valid resonce at that address. This was written to ensure
// a picture on our site exists before including a link to it
// in an email.
//
//    URL = 'https://cdn.test.com/img/product_images/+
//                 thumbnails/2272301A.jpg';
//    IF #$URLTST(URL)
//       DO SOMETHING...
//    ENDIF
//
// Dcl-Proc #$URLTST EXPORT;
//   Dcl-PI *N Ind;
//     URL            Varchar(32767)  CONST;
//     End-PI;
//   Dcl-S input char(1);
//
//       // SET TIMEOUT TO 1 SECOND
//   http_setOption('timeout': '1');
//
//     // CALL THE WEB API, RETURNING THE VALUE IN THE IFS FILE
//   MONITOR;
//     INPUT = HTTP_STRING('HEAD':URL);
//   ON-ERROR;
//     RETURN *OFF;
//   ENDMON;
//
//   RETURN *ON;
//
// End-Proc;

// ****************************************************************
// #$SCANR Find the first occurance of a search argument
// starting from the end of the string to be searched or from
// starting possition.
//
//  INPUT:  #$FIND = String to search for
//          #$IN   = String to search in
//          #$STR  = Starting postiion for search
// RETURN:  #$POSN = The postition of a find or 0 if not found
//
Dcl-Proc #$SCANR EXPORT;
  Dcl-Pi *N Packed(5:0);
    #$FIND         Varchar(1024) CONST;
    #$IN           Varchar(32767) CONST;
    #$STR          Packed(5:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S IN           Char(32767);
  Dcl-S STR          Packed(5:0);
  Dcl-S POSN         Packed(5:0);

  // USE START POSTITION IF PASSED, OTHERWISE START AT THE END OF THE STRING
  If %parms() > 2 AND %addr(#$STR)<>*NULL;
    STR=#$STR;
  Else;
    STR=%len(%trim(#$IN));
  EndIf;

  POSN = 0;
  DoW %scan(#$FIND:#$IN:POSN+1)>0 AND %scan(#$FIND:#$IN:POSN+1)<=STR;
    POSN=%scan(#$FIND:#$IN:POSN+1);
  EndDo;

  Return POSN;

End-Proc;

// ****************************************************************
// #$JSONESC Escapes special charaters in a sting to be used
// in as a JSON character value.
//
//
//  INPUT:  #$TEXT = TEXT TO ESCAPE
// RETURN:         = THE SAME TEXT WITH QUOTES DOUBLED
//                   AND * CONVERTED TO %
//
Dcl-Proc #$JSONESC EXPORT;
  Dcl-Pi *N Varchar(4096);
    #$TEXT         Varchar(4096) VALUE;
  End-Pi;
  Dcl-S TEMP         Varchar(4096);

  // The following fields are used to translate out funny
  // characters copied in from other sources. it replaces
  // non-standard characters with a space
  Dcl-C ICHAR      CONST( X'000102030405060708090A0B0C0D0E0F+
                                    101112131415161718191A1B1C1D1E1F+
                                    202122232425262728292A2B2C2D2E2F+
                                    303132333435363738393A3B3C3D3E3F+
                                    404142434445464748494A4B4C4D4E4F+
                                    505152535455565758595A5B5C5D5E5F+
                                    606162636465666768696A6B6C6D6E6F+
                                    707172737475767778797A7B7C7D7E7F+
                                    808182838485868788898A8B8C8D8E8F+
                                    909192939495969798999A9B9C9D9E9F+
                                    A0A1A2A3A4A5A6A7A8A9AAABACADAEAF+
                                    B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF+
                                    C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF+
                                    D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF+
                                    E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF+
                                    F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF');
  Dcl-C OCHAR      CONST( X'40404040404040404040404040404040+
                                    40404040404040404040404040404040+
                                    40404040404040404040404040404040+
                                    404040407F404040407D404040404040+
                                    40404040404040404040404B4C4D4E4F+
                                    504040404040404040405A5B5C5D5E5F+
                                    606140404040404040406A6B6C6D6E6F+
                                    404040404040404040797A7B7C7D7E7F+
                                    40818283848586878889404040404040+
                                    40919293949596979899404040404040+
                                    40A1A2A3A4A5A6A7A8A9404040404040+
                                    40404040404040404040404040404040+
                                    C0C1C2C3C4C5C6C7C8C9404040404040+
                                    D0D1D2D3D4D5D6D7D8D9404040404040+
                                    E040E2E3E4E5E6E7E8E9404040404040+
                                    F0F1F2F3F4F5F6F7F8F9404040404040');

  TEMP=#$TEXT;

  // ESCAPE JSON SPECIAL CHARACTERS
  TEMP=%scanrpl('\':'\\':TEMP); //BACKSLASH
  TEMP=%scanrpl('"':'\"':TEMP); //DOUBLE QUOTE
  TEMP=%scanrpl(X'34':'\"':TEMP); //DOUBLE QUOTE
  TEMP=%scanrpl(X'16':'\b':TEMP); //BACKSPACE
  TEMP=%scanrpl(X'0C':'\f':TEMP); //FORM FEED
  TEMP=%scanrpl(x'25':'\n':TEMP); //NEWLINE
  TEMP=%scanrpl(X'0D':'\r':TEMP); //CARRIAGE RETURN
  TEMP=%scanrpl(X'05':'\t':TEMP); //TAB

  // Get rid of any other funny characters
  TEMP = %xlate(ICHAR:OCHAR:TEMP);

  Return %trim(TEMP);

End-Proc;

// ****************************************************************
// #$ISOUTQ Test if an output queue exists.
//
//  INPUT:  #$FILE = Output Queue Name Char(10)
//          #$LIB  = Library, Optional, defaults to *LIBL
// RETURN:         = *ON if the file exists.
//
Dcl-Proc #$ISOUTQ EXPORT;
  Dcl-Pi *N Ind;
    #$FILE         Char(10)   CONST;
    #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S LIB          Char(10);

  // USE LIB IF PASSED OTHERWISE DEFAULT IT TO *LIBL
  If %parms() > 1 AND %addr(#$LIB)<>*NULL;
    LIB=#$LIB;
  Else;
    LIB='*LIBL';
  EndIf;

  Monitor;
    #$CMD('CHKOBJ OBJ('+%trim(LIB)+'/'+%trim(#$FILE)+') OBJTYPE(*OUTQ)':2);
    Return *ON;
  On-Error;
    Return *OFF;
  EndMon;

End-Proc;

// ****************************************************************
// #$ISLIB Test if a library exists.
//
//  INPUT:  #$LIB  = Library Name Char(10)
// RETURN:         = *ON if the library exists.
//
Dcl-Proc #$ISLIB EXPORT;
  Dcl-Pi *N Ind;
    #$LIB          Char(10)   CONST;

  End-Pi;
  Monitor;
    #$CMD('CHKOBJ OBJ('+%trim(#$LIB)+') OBJTYPE(*LIB)':2);
    Return *ON;
  On-Error;
    Return *OFF;
  EndMon;

End-Proc;

// ****************************************************************
// #$ISFILE Test if a file exists.
//
//  INPUT:  #$FILE = File Name Char(10)
//          #$LIB  = Library, Optional, defaults to *LIBL
// RETURN:         = *ON if the file exists.
//
Dcl-Proc #$ISFILE EXPORT;
  Dcl-Pi *N Ind;
    #$FILE         Char(10)   CONST;
    #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S LIB          Char(10);

  // USE LIB IF PASSED OTHERWISE DEFAULT IT TO *LIBL
  If %parms() > 1 AND %addr(#$LIB)<>*NULL;
    LIB=#$LIB;
  Else;
    LIB='*LIBL';
  EndIf;

  Monitor;
    #$CMD('CHKOBJ OBJ('+%trim(LIB)+'/'+%trim(#$FILE)+') OBJTYPE(*FILE)':2);
    Return *ON;
  On-Error;
    Return *OFF;
  EndMon;

End-Proc;

// ****************************************************************
// #$SQL2JSON Returns a JSON string from the results of an
// SQL statement.
//
// If an error occures it returns the JSON string with a
// {"sucess:false, so scanning the json string for the word
// false in the first 14 chartacters will let you know an
// error occured. False will always be in lower case. The
// statement should also be included in a monitor block in case
// something happens that is not monitored for in this
// prcedure.
//
// Example:
// #$SQL2JSON('SELECT CNUM, CNAM FROM CUST +
//             WHERE CNUM BETWEEN 9624 AND 9625')
// Returns the following:
// {"SUCCESS":True,
//  "ERRMSG":"",
//  "DATA":
//    [{"cnum":9624,"cnam":"TEST TEST TEST"},
//     {"cnum":9625,"cnam":"TEST TEST TEST"}]
// }
//
// The command also works with the as statement, example:
// #$SQL2JSON('SELECT CNUM AS account_id, +
//                    CNAM as account_name +
//             WHERE CNUM BETWEEN 9624 AND 9625')
// Returns
// ... [{"account_id":9624,"account_name":"TEST TEST TEST"},
//      {"account_id":9625,"account_name":"TEST TEST TEST"}]...
//
// The as statement used to not work for calculated rows, so
// example did not work, it does now though.
// #$SQL2JSON('SELECT CNUM * 1 AS account_id, +
//                    CNAM as account_name +
//             WHERE CNUM BETWEEN 9624 AND 9625')
// Returns
// ... [{"":9624,"account_name":"TEST TEST TEST"},
//      {"":9625,"account_name":"TEST TEST TEST"}] ...
//
// Column names can be overriden with the second optional
// parameter. The parameter is an array of column names. It is
// already defiend in the #$SQL2JSON include, so it does not
// need to be defined in the program. If an element in the
// array has a value, it will be used for the field name
// instead of the default. The following example shows how to
// override one column name for the statement, you can do this
// for single columns or all columns depending on your needs.
// Since the AS alias now works for calcualted rows this should
// no longer be used.
//
//                EVAL  #$CLMOVR(1)='account_id'
//                EVAL  SQLSTM='SELECT CNUM * 1, +
//                              CNAM as account_name +
//                       WHERE CNUM BETWEEN 9624 AND 9625'
//                EVAL  JSON=#$SQL2JSON(SQLSTM:#$CLMOVR)
// Returns to the variable JSON
// ... [{"account_id":9624,"account_name":"TEST TEST TEST"},
//      {"account_id":9625,"account_name":"TEST TEST TEST"}]...
//
// On error a message will be sent back with the error
// description and a copy of the SQL statement sent, it looks
// like this:
// {"success":false,"errmsg":"size over 1MB",
//   "sqlstm":"SELECT * FROM CUST"}
//
// Array only option.
// By passing a 1 in the array only column the returned JSON
// string will only include the array of the result set. This
// removes success and error message options. If an error is
// received it still returns the data as shown in the error
// section above. Otherwise it just returns a JSON array. The
// following is an example:
// #$SQL2JSON('SELECT CNUM AS account, +
//                    CNAM as account_name +
//             WHERE CNUM BETWEEN 9624 AND 9625': *OMIT:1)
// Returns
//     [{"account":9624,"account_name":"TEST TEST TEST"},
//      {"account":9625,"account_name":"TEST TEST TEST"}]
//
// Limitations
//   All data keys will be returned in lower case. This was
//   done because that is how the web team wants them.
//
//   The program can only handle 500 columns, an error will be
//   sent if more than that is used.
//
//   The returned JSON string cannot exceed 1mb bytes or
//   an error will be sent.
//
//   Each field will be cut off at 1000 characters.
//
//   Numeric fields are returned with floating decimal point.
//   So 1.10 will be 1.1, 1.00 will just be 1.
//
//   To test for only select statements the program makes sure
//   that the passed sql statement start with one of the
//   following stings:
//       'Select'
//       '(select'
//       '( select'
//   It is not case sensitive. The selects starting with the
//   parenthesis were added so unions could be used to
//   concatenate multiple queries.
//
//  INPUT: SQLSTM  = SQL statement to process.
//                   It must be a SELECT statement.
//         #$CLMOVR= Optional, a predfined array to override
//                   colum names.
//         #$ARYONLY=Optional, pass a 1 to only include the
//                   array data.
// RETURN:         = The results of the statement formatted
//                   as a JSON string or a JSON array.
//
Dcl-Proc #$SQL2JSON EXPORT;
  Dcl-Pi *N Varchar(1024000);
    PSSQLSTM       Varchar(8192)  CONST;
    PSCLMOVR       Char(128)  DIM(200) OPTIONS(*NOPASS: *OMIT) CONST;
    PSARYONLY      Zoned(1:0) OPTIONS(*NOPASS: *OMIT) CONST;
  End-Pi;
  Dcl-S SQLSTMI      Varchar(8192);
  Dcl-S #$CLMOVR     Char(128)  DIM(200);
  Dcl-S #$ARYONLY    Zoned(1:0);

  Dcl-Ds MYDS;
    VAL0001        Char(1000);
    VAL0002        Char(1000);
    VAL0003        Char(1000);
    VAL0004        Char(1000);
    VAL0005        Char(1000);
    VAL0006        Char(1000);
    VAL0007        Char(1000);
    VAL0008        Char(1000);
    VAL0009        Char(1000);
    VAL0010        Char(1000);
    VAL0011        Char(1000);
    VAL0012        Char(1000);
    VAL0013        Char(1000);
    VAL0014        Char(1000);
    VAL0015        Char(1000);
    VAL0016        Char(1000);
    VAL0017        Char(1000);
    VAL0018        Char(1000);
    VAL0019        Char(1000);
    VAL0020        Char(1000);
    VAL0021        Char(1000);
    VAL0022        Char(1000);
    VAL0023        Char(1000);
    VAL0024        Char(1000);
    VAL0025        Char(1000);
    VAL0026        Char(1000);
    VAL0027        Char(1000);
    VAL0028        Char(1000);
    VAL0029        Char(1000);
    VAL0030        Char(1000);
    VAL0031        Char(1000);
    VAL0032        Char(1000);
    VAL0033        Char(1000);
    VAL0034        Char(1000);
    VAL0035        Char(1000);
    VAL0036        Char(1000);
    VAL0037        Char(1000);
    VAL0038        Char(1000);
    VAL0039        Char(1000);
    VAL0040        Char(1000);
    VAL0041        Char(1000);
    VAL0042        Char(1000);
    VAL0043        Char(1000);
    VAL0044        Char(1000);
    VAL0045        Char(1000);
    VAL0046        Char(1000);
    VAL0047        Char(1000);
    VAL0048        Char(1000);
    VAL0049        Char(1000);
    VAL0050        Char(1000);
    VAL0051        Char(1000);
    VAL0052        Char(1000);
    VAL0053        Char(1000);
    VAL0054        Char(1000);
    VAL0055        Char(1000);
    VAL0056        Char(1000);
    VAL0057        Char(1000);
    VAL0058        Char(1000);
    VAL0059        Char(1000);
    VAL0060        Char(1000);
    VAL0061        Char(1000);
    VAL0062        Char(1000);
    VAL0063        Char(1000);
    VAL0064        Char(1000);
    VAL0065        Char(1000);
    VAL0066        Char(1000);
    VAL0067        Char(1000);
    VAL0068        Char(1000);
    VAL0069        Char(1000);
    VAL0070        Char(1000);
    VAL0071        Char(1000);
    VAL0072        Char(1000);
    VAL0073        Char(1000);
    VAL0074        Char(1000);
    VAL0075        Char(1000);
    VAL0076        Char(1000);
    VAL0077        Char(1000);
    VAL0078        Char(1000);
    VAL0079        Char(1000);
    VAL0080        Char(1000);
    VAL0081        Char(1000);
    VAL0082        Char(1000);
    VAL0083        Char(1000);
    VAL0084        Char(1000);
    VAL0085        Char(1000);
    VAL0086        Char(1000);
    VAL0087        Char(1000);
    VAL0088        Char(1000);
    VAL0089        Char(1000);
    VAL0090        Char(1000);
    VAL0091        Char(1000);
    VAL0092        Char(1000);
    VAL0093        Char(1000);
    VAL0094        Char(1000);
    VAL0095        Char(1000);
    VAL0096        Char(1000);
    VAL0097        Char(1000);
    VAL0098        Char(1000);
    VAL0099        Char(1000);
    VAL0100        Char(1000);
    VAL0101        Char(1000);
    VAL0102        Char(1000);
    VAL0103        Char(1000);
    VAL0104        Char(1000);
    VAL0105        Char(1000);
    VAL0106        Char(1000);
    VAL0107        Char(1000);
    VAL0108        Char(1000);
    VAL0109        Char(1000);
    VAL0110        Char(1000);
    VAL0111        Char(1000);
    VAL0112        Char(1000);
    VAL0113        Char(1000);
    VAL0114        Char(1000);
    VAL0115        Char(1000);
    VAL0116        Char(1000);
    VAL0117        Char(1000);
    VAL0118        Char(1000);
    VAL0119        Char(1000);
    VAL0120        Char(1000);
    VAL0121        Char(1000);
    VAL0122        Char(1000);
    VAL0123        Char(1000);
    VAL0124        Char(1000);
    VAL0125        Char(1000);
    VAL0126        Char(1000);
    VAL0127        Char(1000);
    VAL0128        Char(1000);
    VAL0129        Char(1000);
    VAL0130        Char(1000);
    VAL0131        Char(1000);
    VAL0132        Char(1000);
    VAL0133        Char(1000);
    VAL0134        Char(1000);
    VAL0135        Char(1000);
    VAL0136        Char(1000);
    VAL0137        Char(1000);
    VAL0138        Char(1000);
    VAL0139        Char(1000);
    VAL0140        Char(1000);
    VAL0141        Char(1000);
    VAL0142        Char(1000);
    VAL0143        Char(1000);
    VAL0144        Char(1000);
    VAL0145        Char(1000);
    VAL0146        Char(1000);
    VAL0147        Char(1000);
    VAL0148        Char(1000);
    VAL0149        Char(1000);
    VAL0150        Char(1000);
    VAL0151        Char(1000);
    VAL0152        Char(1000);
    VAL0153        Char(1000);
    VAL0154        Char(1000);
    VAL0155        Char(1000);
    VAL0156        Char(1000);
    VAL0157        Char(1000);
    VAL0158        Char(1000);
    VAL0159        Char(1000);
    VAL0160        Char(1000);
    VAL0161        Char(1000);
    VAL0162        Char(1000);
    VAL0163        Char(1000);
    VAL0164        Char(1000);
    VAL0165        Char(1000);
    VAL0166        Char(1000);
    VAL0167        Char(1000);
    VAL0168        Char(1000);
    VAL0169        Char(1000);
    VAL0170        Char(1000);
    VAL0171        Char(1000);
    VAL0172        Char(1000);
    VAL0173        Char(1000);
    VAL0174        Char(1000);
    VAL0175        Char(1000);
    VAL0176        Char(1000);
    VAL0177        Char(1000);
    VAL0178        Char(1000);
    VAL0179        Char(1000);
    VAL0180        Char(1000);
    VAL0181        Char(1000);
    VAL0182        Char(1000);
    VAL0183        Char(1000);
    VAL0184        Char(1000);
    VAL0185        Char(1000);
    VAL0186        Char(1000);
    VAL0187        Char(1000);
    VAL0188        Char(1000);
    VAL0189        Char(1000);
    VAL0190        Char(1000);
    VAL0191        Char(1000);
    VAL0192        Char(1000);
    VAL0193        Char(1000);
    VAL0194        Char(1000);
    VAL0195        Char(1000);
    VAL0196        Char(1000);
    VAL0197        Char(1000);
    VAL0198        Char(1000);
    VAL0199        Char(1000);
    VAL0200        Char(1000);
    VAL0201        Char(1000);
    VAL0202        Char(1000);
    VAL0203        Char(1000);
    VAL0204        Char(1000);
    VAL0205        Char(1000);
    VAL0206        Char(1000);
    VAL0207        Char(1000);
    VAL0208        Char(1000);
    VAL0209        Char(1000);
    VAL0210        Char(1000);
    VAL0211        Char(1000);
    VAL0212        Char(1000);
    VAL0213        Char(1000);
    VAL0214        Char(1000);
    VAL0215        Char(1000);
    VAL0216        Char(1000);
    VAL0217        Char(1000);
    VAL0218        Char(1000);
    VAL0219        Char(1000);
    VAL0220        Char(1000);
    VAL0221        Char(1000);
    VAL0222        Char(1000);
    VAL0223        Char(1000);
    VAL0224        Char(1000);
    VAL0225        Char(1000);
    VAL0226        Char(1000);
    VAL0227        Char(1000);
    VAL0228        Char(1000);
    VAL0229        Char(1000);
    VAL0230        Char(1000);
    VAL0231        Char(1000);
    VAL0232        Char(1000);
    VAL0233        Char(1000);
    VAL0234        Char(1000);
    VAL0235        Char(1000);
    VAL0236        Char(1000);
    VAL0237        Char(1000);
    VAL0238        Char(1000);
    VAL0239        Char(1000);
    VAL0240        Char(1000);
    VAL0241        Char(1000);
    VAL0242        Char(1000);
    VAL0243        Char(1000);
    VAL0244        Char(1000);
    VAL0245        Char(1000);
    VAL0246        Char(1000);
    VAL0247        Char(1000);
    VAL0248        Char(1000);
    VAL0249        Char(1000);
    VAL0250        Char(1000);
    VAL0251        Char(1000);
    VAL0252        Char(1000);
    VAL0253        Char(1000);
    VAL0254        Char(1000);
    VAL0255        Char(1000);
    VAL0256        Char(1000);
    VAL0257        Char(1000);
    VAL0258        Char(1000);
    VAL0259        Char(1000);
    VAL0260        Char(1000);
    VAL0261        Char(1000);
    VAL0262        Char(1000);
    VAL0263        Char(1000);
    VAL0264        Char(1000);
    VAL0265        Char(1000);
    VAL0266        Char(1000);
    VAL0267        Char(1000);
    VAL0268        Char(1000);
    VAL0269        Char(1000);
    VAL0270        Char(1000);
    VAL0271        Char(1000);
    VAL0272        Char(1000);
    VAL0273        Char(1000);
    VAL0274        Char(1000);
    VAL0275        Char(1000);
    VAL0276        Char(1000);
    VAL0277        Char(1000);
    VAL0278        Char(1000);
    VAL0279        Char(1000);
    VAL0280        Char(1000);
    VAL0281        Char(1000);
    VAL0282        Char(1000);
    VAL0283        Char(1000);
    VAL0284        Char(1000);
    VAL0285        Char(1000);
    VAL0286        Char(1000);
    VAL0287        Char(1000);
    VAL0288        Char(1000);
    VAL0289        Char(1000);
    VAL0290        Char(1000);
    VAL0291        Char(1000);
    VAL0292        Char(1000);
    VAL0293        Char(1000);
    VAL0294        Char(1000);
    VAL0295        Char(1000);
    VAL0296        Char(1000);
    VAL0297        Char(1000);
    VAL0298        Char(1000);
    VAL0299        Char(1000);
    VAL0300        Char(1000);
    VAL0301        Char(1000);
    VAL0302        Char(1000);
    VAL0303        Char(1000);
    VAL0304        Char(1000);
    VAL0305        Char(1000);
    VAL0306        Char(1000);
    VAL0307        Char(1000);
    VAL0308        Char(1000);
    VAL0309        Char(1000);
    VAL0310        Char(1000);
    VAL0311        Char(1000);
    VAL0312        Char(1000);
    VAL0313        Char(1000);
    VAL0314        Char(1000);
    VAL0315        Char(1000);
    VAL0316        Char(1000);
    VAL0317        Char(1000);
    VAL0318        Char(1000);
    VAL0319        Char(1000);
    VAL0320        Char(1000);
    VAL0321        Char(1000);
    VAL0322        Char(1000);
    VAL0323        Char(1000);
    VAL0324        Char(1000);
    VAL0325        Char(1000);
    VAL0326        Char(1000);
    VAL0327        Char(1000);
    VAL0328        Char(1000);
    VAL0329        Char(1000);
    VAL0330        Char(1000);
    VAL0331        Char(1000);
    VAL0332        Char(1000);
    VAL0333        Char(1000);
    VAL0334        Char(1000);
    VAL0335        Char(1000);
    VAL0336        Char(1000);
    VAL0337        Char(1000);
    VAL0338        Char(1000);
    VAL0339        Char(1000);
    VAL0340        Char(1000);
    VAL0341        Char(1000);
    VAL0342        Char(1000);
    VAL0343        Char(1000);
    VAL0344        Char(1000);
    VAL0345        Char(1000);
    VAL0346        Char(1000);
    VAL0347        Char(1000);
    VAL0348        Char(1000);
    VAL0349        Char(1000);
    VAL0350        Char(1000);
    VAL0351        Char(1000);
    VAL0352        Char(1000);
    VAL0353        Char(1000);
    VAL0354        Char(1000);
    VAL0355        Char(1000);
    VAL0356        Char(1000);
    VAL0357        Char(1000);
    VAL0358        Char(1000);
    VAL0359        Char(1000);
    VAL0360        Char(1000);
    VAL0361        Char(1000);
    VAL0362        Char(1000);
    VAL0363        Char(1000);
    VAL0364        Char(1000);
    VAL0365        Char(1000);
    VAL0366        Char(1000);
    VAL0367        Char(1000);
    VAL0368        Char(1000);
    VAL0369        Char(1000);
    VAL0370        Char(1000);
    VAL0371        Char(1000);
    VAL0372        Char(1000);
    VAL0373        Char(1000);
    VAL0374        Char(1000);
    VAL0375        Char(1000);
    VAL0376        Char(1000);
    VAL0377        Char(1000);
    VAL0378        Char(1000);
    VAL0379        Char(1000);
    VAL0380        Char(1000);
    VAL0381        Char(1000);
    VAL0382        Char(1000);
    VAL0383        Char(1000);
    VAL0384        Char(1000);
    VAL0385        Char(1000);
    VAL0386        Char(1000);
    VAL0387        Char(1000);
    VAL0388        Char(1000);
    VAL0389        Char(1000);
    VAL0390        Char(1000);
    VAL0391        Char(1000);
    VAL0392        Char(1000);
    VAL0393        Char(1000);
    VAL0394        Char(1000);
    VAL0395        Char(1000);
    VAL0396        Char(1000);
    VAL0397        Char(1000);
    VAL0398        Char(1000);
    VAL0399        Char(1000);
    VAL0400        Char(1000);
    VAL0401        Char(1000);
    VAL0402        Char(1000);
    VAL0403        Char(1000);
    VAL0404        Char(1000);
    VAL0405        Char(1000);
    VAL0406        Char(1000);
    VAL0407        Char(1000);
    VAL0408        Char(1000);
    VAL0409        Char(1000);
    VAL0410        Char(1000);
    VAL0411        Char(1000);
    VAL0412        Char(1000);
    VAL0413        Char(1000);
    VAL0414        Char(1000);
    VAL0415        Char(1000);
    VAL0416        Char(1000);
    VAL0417        Char(1000);
    VAL0418        Char(1000);
    VAL0419        Char(1000);
    VAL0420        Char(1000);
    VAL0421        Char(1000);
    VAL0422        Char(1000);
    VAL0423        Char(1000);
    VAL0424        Char(1000);
    VAL0425        Char(1000);
    VAL0426        Char(1000);
    VAL0427        Char(1000);
    VAL0428        Char(1000);
    VAL0429        Char(1000);
    VAL0430        Char(1000);
    VAL0431        Char(1000);
    VAL0432        Char(1000);
    VAL0433        Char(1000);
    VAL0434        Char(1000);
    VAL0435        Char(1000);
    VAL0436        Char(1000);
    VAL0437        Char(1000);
    VAL0438        Char(1000);
    VAL0439        Char(1000);
    VAL0440        Char(1000);
    VAL0441        Char(1000);
    VAL0442        Char(1000);
    VAL0443        Char(1000);
    VAL0444        Char(1000);
    VAL0445        Char(1000);
    VAL0446        Char(1000);
    VAL0447        Char(1000);
    VAL0448        Char(1000);
    VAL0449        Char(1000);
    VAL0450        Char(1000);
    VAL0451        Char(1000);
    VAL0452        Char(1000);
    VAL0453        Char(1000);
    VAL0454        Char(1000);
    VAL0455        Char(1000);
    VAL0456        Char(1000);
    VAL0457        Char(1000);
    VAL0458        Char(1000);
    VAL0459        Char(1000);
    VAL0460        Char(1000);
    VAL0461        Char(1000);
    VAL0462        Char(1000);
    VAL0463        Char(1000);
    VAL0464        Char(1000);
    VAL0465        Char(1000);
    VAL0466        Char(1000);
    VAL0467        Char(1000);
    VAL0468        Char(1000);
    VAL0469        Char(1000);
    VAL0470        Char(1000);
    VAL0471        Char(1000);
    VAL0472        Char(1000);
    VAL0473        Char(1000);
    VAL0474        Char(1000);
    VAL0475        Char(1000);
    VAL0476        Char(1000);
    VAL0477        Char(1000);
    VAL0478        Char(1000);
    VAL0479        Char(1000);
    VAL0480        Char(1000);
    VAL0481        Char(1000);
    VAL0482        Char(1000);
    VAL0483        Char(1000);
    VAL0484        Char(1000);
    VAL0485        Char(1000);
    VAL0486        Char(1000);
    VAL0487        Char(1000);
    VAL0488        Char(1000);
    VAL0489        Char(1000);
    VAL0490        Char(1000);
    VAL0491        Char(1000);
    VAL0492        Char(1000);
    VAL0493        Char(1000);
    VAL0494        Char(1000);
    VAL0495        Char(1000);
    VAL0496        Char(1000);
    VAL0497        Char(1000);
    VAL0498        Char(1000);
    VAL0499        Char(1000);
    VAL0500        Char(1000);

  End-Ds;
  Dcl-S VAL          Char(1000) DIM(500);

  Dcl-S NULLS        Int(5)     DIM(500);

  // COLUMN NAMES, TYPE(N=NUMERIC), DECIMAL PERCISION
  Dcl-S CNAM         Char(128)  DIM(200);
  Dcl-S CTYP         Char(1)    DIM(200);

  Dcl-S JSON         Varchar(1024800);

  Dcl-S No_Columns   Int(5);
  Dcl-S Name         Varchar(128);
  Dcl-S Column_Name  Varchar(128);
  Dcl-S Column_Type  Varchar(128);
  Dcl-S Base_Column  Varchar(128);
  Dcl-S Base_Schema  Varchar(128);
  Dcl-S Base_Table   Varchar(128);
  Dcl-S Data_Type    Int(10);
  Dcl-S Headings     Varchar(60);
  Dcl-S Label_Text   Varchar(50);
  Dcl-S MSGTEXT      Char(256);
  Dcl-S i            Packed(5);
  Dcl-S NUM          packed(2);
  Dcl-S TPNUM        packed(35:15);
  Dcl-S TPCHAR       char(40);

  // *********************************************************************

  // USING INDICATOR 81 TO SEE IF ANY DETAIL LINES ARE ADDED
  *In81 = *Off;

  SQLSTMI=PSSQLSTM;

  If %parms>=2 AND %addr(PSCLMOVR) <> *NULL;
    #$CLMOVR=PSCLMOVR;
  EndIf;

  If %parms>=3 AND %addr(PSARYONLY) <> *NULL;
    #$ARYONLY=PSARYONLY;
  EndIf;

  // MAKE SURE THIS IS A SELECT STATEMENT
  If #$upify(%subst(SQLSTMI:1:6)) <> 'SELECT'
           AND #$upify(%subst(SQLSTMI:1:7)) <> '(SELECT'
           AND #$upify(%subst(SQLSTMI:1:8)) <> '( SELECT';
    MSGTEXT='error - not a select statement';
    ExSr SNDERR;
    Return JSON;
  EndIf;

  // PREPARE SELECT, DECLARE AND OPEN A CURSOR
  Exec SQL PREPARE SQLSTM FROM :SQLSTMI;
  If %subst(SQLSTT:1:2) > '02';
    Exec SQL Get Diagnostics Condition 1 :MSGTEXT = MESSAGE_TEXT;
    ExSr SNDERR;
  EndIf;

  // GET COLUMN INFORMATION FOR TYPE AND NAME
  ExSr GETCLMS;

  Exec SQL DECLARE SQLCRS1 CURSOR FOR SQLSTM;
  Exec SQL OPEN SQLCRS1;

  If #$ARYONLY=1;
    JSON='[';
  Else;
    JSON='{"success":true,"errmsg":"",+ "data":[';
  EndIf;

  // LOOP THROUGH THE TABLE AND ADD EACH RECORD TO THE EXCEL FILE
  Monitor;
    Exec SQL FETCH NEXT FROM SQLCRS1 INTO :MYDS :NULLS;
  On-Error;
  EndMon;
  DoW SQLCODE = 0 OR SQLCODE=326;
    ExSr ADDDTL;
    Monitor;
      Exec SQL FETCH NEXT FROM SQLCRS1 INTO :MYDS :NULLS;
    On-Error;
    EndMon;
  EndDo;

  // CLOSE SQL CURSOR
  Exec SQL CLOSE SQLCRS1;

  If #$ARYONLY=1;
    JSON=%trim(JSON) + ']';
  Else;
    JSON=%trim(JSON) + ']}';
  EndIf;

  // EMTPY NO DETAIL LINES ADDED, SEND MESSAGE
  If NOT *IN81;
    MSGTEXT='no detail records found';
    ExSr SNDERR;
  EndIf;

  Return JSON;

  // ***********************************************************************
  // GET COLUMN INFORMATION FOR TYPE AND NAME
  BegSr GETCLMS;

    // Allocate descriptor (set aside memory for DESCRIBE to use)
    Exec SQL ALLOCATE SQL DESCRIPTOR 'COLUMNS' WITH MAX 200;

    // Collect metadata from prepared query statement
    // and place the result in the descriptor,
    Exec SQL DESCRIBE SQLSTM USING SQL DESCRIPTOR 'COLUMNS';

    // CHECK STATUS OF LAST STATEMENT AND RETURN AN ERROR IF NEEDED
    If SQLSTT='01005';
      Exec SQL DEALLOCATE DESCRIPTOR 'COLUMNS';
      MSGTEXT='error - to many columns';
      ExSr SNDERR;
    EndIf;

    // No_Columns is the number of columns returned
    Exec SQL GET SQL DESCRIPTOR 'COLUMNS' :No_Columns=COUNT;

    // Get information from each column returned
    For i=1 To No_Columns;
      Exec SQL GET SQL DESCRIPTOR 'COLUMNS'
                VALUE :i :Headings=DB2_LABEL,
                       :Column_Name=DB2_COLUMN_NAME,
                       :Name=NAME,
                       :Base_Column=DB2_BASE_COLUMN_NAME,
                       :Base_Schema=DB2_BASE_SCHEMA_NAME,
                       :Base_Table =DB2_BASE_TABLE_NAME,
                         :Data_Type  =TYPE;

      If HEADINGS<>' ';
        CNAM(i)=%trim(#$lowfy(Headings));
      ElseIf NAME<>' ';
        CNAM(i)=%trim(#$lowfy(Name));
      Else;
        CNAM(i)='undifined'+%char(i);
      EndIf;
      // IF AN OVERRIDE IS PASSED USE IT
      If #$CLMOVR(i)<>' ';
        CNAM(i)=%trim(#$lowfy(#$CLMOVR(i)));
      EndIf;

      // CTYP ONLY CONTAINS AN N FOR NUMERIC FIELDS,
      // THE NUMERIC COLUMN TYPES ARE HARDCODED HERE
      If Data_Type= -360
             OR Data_Type= 2
             or Data_Type= 3
             or Data_Type= 4
             or Data_Type= 5
             or Data_Type= 6
             or Data_Type= 7
             or Data_Type= 8
             or Data_Type= 25; //DECFLOAT
        CTYP(i)='N';
      EndIf;
    EndFor;

    // CLEANUP DESCRIPTION AREA
    Exec SQL DEALLOCATE DESCRIPTOR 'COLUMNS';

  EndSr;
  // ***********************************************************************
  // ADD A DETAIL LINE TO THE JSON STRING
  BegSr ADDDTL;

    VAL = MYDS;

    // START ONE DETAIL ENTRY
    If *In81;
      JSON=%trim(JSON) + ',';
    EndIf;
    JSON=%trim(JSON) + '{';

    *In81 = *On;

    // ADD DETAIL RECORD
    For i=1 To No_Columns;
      If I<>1;
        JSON=%trim(JSON)+',';
      EndIf;
      If NULLS(i)=-1;
        JSON=%trim(JSON)+'"'+ %trim(#$JSONESC(CNAM(i)))+'":null';
      ElseIf CTYP(i)='N';
        ExSr ADDNUM;
      Else;
        JSON=%trim(JSON)+'"'+ %trim(#$JSONESC(CNAM(i)))+'":"'
                    + %trim(#$JSONESC(VAL(i))) +'"';
      EndIf;
      // IF THE JSON STRING GOES OVER 1MB SEND ERROR
      If %len(%trim(JSON))>1023998;
        MSGTEXT='size over 1MB';
        ExSr SNDERR;
      EndIf;
    EndFor;

    JSON=%trim(JSON) + '}';

  EndSr;
  // ***********************************************************************
  // THIS SUBR TRYS TO FORMAT THE NUMERIC FIELDS
  // IT TAKES OFF THE SIGN, USES %EDITC, THEN REMOVES TRAILING ZEROS
  // THEN ADDS THE SIGN BACK ON
  BegSr ADDNUM;

    *In76 = *Off;
    TPNUM=#$RVL(VAL(i));

    // SKIP ALL THE LOGIC IF THE VALUE IS ZERO
    If TPNUM=0;
      JSON=%trim(JSON)+'"'+%trim(CNAM(i))+'":0';
      LeaveSr;
    EndIf;

    // IF NEGATIVE, MAKE POSITIVE AND SAVE
    If TPNUM<0;
      *In76 = *On;
      TPNUM = TPNUM * -1;
    EndIf;

    TPCHAR=%trim(%editc(TPNUM:'M')) +
                 '0000000000000000000000000000000000000000';

    // REMOVE TRAILING ZEROS
    NUM = %checkr('0':TPCHAR);
    If NUM=0;
      TPCHAR='0';
    Else;
      TPCHAR=%subst(TPCHAR:1:NUM);
      // REMOVE THE DECIMAL POINT IF THERE ARE NO MORE CHARACTERS AFTER IT
      If %subst(TPCHAR:NUM:1)='.';
        TPCHAR=%subst(TPCHAR:1:NUM-1);
      EndIf;
      // IF IT STARTS WITH A DECIMAL POINT ADD A 0 IN FRONT
      If %subst(TPCHAR:1:1)='.';
        TPCHAR='0'+%trim(TPCHAR);
      EndIf;
      // ADD THE NEGATIVE SIGN BACK IF NEEDED
      If *In76;
        TPCHAR='-'+%trim(TPCHAR);
      EndIf;
    EndIf;

    JSON=%trim(JSON)+'"'+ %trim(#$JSONESC(CNAM(i)))+'":'
                  + %trim(TPCHAR);

  EndSr;
  // ***********************************************************************
  // SEND AN ESCAPE ERROR AND JSON TEXT BACK.
  // USES MSGTEXT FOR THE ERROR DESCRIPTION
  BegSr SNDERR;

    JSON='{"success":false,"errmsg":"' + %trim(MSGTEXT) +
                    '","sqlstm":"'+ %trim(SQLSTMI) +'"}';
    // CLOSE SQL CURSOR IF OPEN
    Exec SQL CLOSE SQLCRS1;

    Return JSON;

  EndSr;

End-Proc;

// ****************************************************************
// #$BLDSCH - Build Multi Word Search String for SQL
//
//  INPUT:  SearchString = The search string.
//          Fields Array = Up to 500 fields to search.
// RETURN:  String = The search string, see exmaples bellow.
//
// The function breaks down the search string into words,
// and then creates a search string for each field for each
// word. It converts both the search string and the seach
// fields to capital letters so it is not case sensitive.
// it handles -search search fields and quoted string with
// double quotes.
//
// Example: 1
//   Include all customers in texas with tim in the name.
//   #$BLDSCH('tim TX':'CNUM':'CNAM':'CADDL2':'CADDL3':
//            'CADDL4':'CADDL5':'CSTATE':'CZIP':'COWNER')
//   Returns:
//       (UPPER(CNUM) LIKE UPPER('%tim%') or
//        UPPER(CNAM) LIKE UPPER('%tim%') or
//        UPPER(CADDL2) LIKE UPPER('%tim%') or
//        UPPER(CADDL3) LIKE UPPER('%tim%') or
//        UPPER(CADDL4) LIKE UPPER('%tim%') or
//        UPPER(CADDL5) LIKE UPPER('%tim%') or
//        UPPER(CSTATE) LIKE UPPER('%tim%') or
//        UPPER(CZIP) LIKE UPPER('%tim%') or
//        UPPER(COWNER) LIKE UPPER('%tim%') )
//       AND
//       (UPPER(CNUM) LIKE UPPER('%TX%') or
//        UPPER(CNAM) LIKE UPPER('%TX%') or
//        UPPER(CADDL2) LIKE UPPER('%TX%') or
//        UPPER(CADDL3) LIKE UPPER('%TX%') or
//        UPPER(CADDL4) LIKE UPPER('%TX%') or
//        UPPER(CADDL5) LIKE UPPER('%TX%') or
//        UPPER(CSTATE) LIKE UPPER('%TX%') or
//        UPPER(CZIP) LIKE UPPER('%TX%') or
//        UPPER(COWNER) LIKE UPPER('%TX%') )
//
// Example: 2
//   Include all customers in texas with tim as a unique word.
//   #$BLDSCH('" tim " TX':'CNUM':'CNAM':'CADDL2':'CADDL3':
//            'CADDL4':'CADDL5':'CSTATE':'CZIP':'COWNER')
//   Returns:
//       (UPPER(CNUM) LIKE UPPER('% tim %') or
//        UPPER(CNAM) LIKE UPPER('% tim %') or
//        UPPER(CADDL2) LIKE UPPER('% tim %') or
//        UPPER(CADDL3) LIKE UPPER('% tim %') or
//        UPPER(CADDL4) LIKE UPPER('% tim %') or
//        UPPER(CADDL5) LIKE UPPER('% tim %') or
//        UPPER(CSTATE) LIKE UPPER('% tim %') or
//        UPPER(CZIP) LIKE UPPER('% tim %') or
//        UPPER(COWNER) LIKE UPPER('% tim %') )
//       AND
//       (UPPER(CNUM) LIKE UPPER('%TX%') or
//        UPPER(CNAM) LIKE UPPER('%TX%') or
//        UPPER(CADDL2) LIKE UPPER('%TX%') or
//        UPPER(CADDL3) LIKE UPPER('%TX%') or
//        UPPER(CADDL4) LIKE UPPER('%TX%') or
//        UPPER(CADDL5) LIKE UPPER('%TX%') or
//        UPPER(CSTATE) LIKE UPPER('%TX%') or
//        UPPER(CZIP) LIKE UPPER('%TX%') or
//        UPPER(COWNER) LIKE UPPER('%TX%') )
//
// Example: 3
//   Include all customers not in texas with tim in the name.
//   #$BLDSCH('tim -TX':'CNUM':'CNAM':'CADDL2':'CADDL3':
//            'CADDL4':'CADDL5':'CSTATE':'CZIP':'COWNER')
//   Returns:
//       (UPPER(CNUM) LIKE UPPER('%tim%') or
//        UPPER(CNAM) LIKE UPPER('%tim%') or
//        UPPER(CADDL2) LIKE UPPER('%tim%') or
//        UPPER(CADDL3) LIKE UPPER('%tim%') or
//        UPPER(CADDL4) LIKE UPPER('%tim%') or
//        UPPER(CADDL5) LIKE UPPER('%tim%') or
//        UPPER(CSTATE) LIKE UPPER('%tim%') or
//        UPPER(CZIP) LIKE UPPER('%tim%') or
//        UPPER(COWNER) LIKE UPPER('%tim%') )
//       AND
//       (UPPER(CNUM) NOT LIKE UPPER('%TX%') and
//        UPPER(CNAM) NOT LIKE UPPER('%TX%') and
//        UPPER(CADDL2) NOT LIKE UPPER('%TX%') and
//        UPPER(CADDL3) NOT LIKE UPPER('%TX%') and
//        UPPER(CADDL4) NOT LIKE UPPER('%TX%') and
//        UPPER(CADDL5) NOT LIKE UPPER('%TX%') and
//        UPPER(CSTATE) NOT LIKE UPPER('%TX%') and
//        UPPER(CZIP) NOT LIKE UPPER('%TX%') and
//        UPPER(COWNER) NOT LIKE UPPER('%TX%') )
//
// Notes:
//    To actually search for a negative sign(-), include it
//    in duoble quotes.
//    If a negative sign is anywhere but the start of a field
//    it does not have to be in quotes.
//    If a search term is supposed to be both words together,
//    wrap them  in double quotes. For instance if you want
//    to search for patterns that are dark red, put the dark
//    read in double quotes so they words must be found in
//    that order.
//    Since This uses the Like operator it does not work with
//    all fields types. It works with numeric and alpha fields,
//    but not with true date, time or timestamp fields.
//
Dcl-Proc #$BLDSCH EXPORT;
  Dcl-Pi *N Varchar(10000);
    #$SRCHSTR      Varchar(1000)  CONST;
    #$SRCHFLDS     Char(1000) DIM( 500 );
  End-Pi;

  Dcl-S SRCHSTR      Char(10000);
  Dcl-S WORDS        Char(100)  DIM(50);
  Dcl-S FOUNDPOS     Int(10);
  Dcl-S STARTPOS     Int(10);
  Dcl-S INDEX        Int(10);
  Dcl-S i            Int(10);
  Dcl-S j            packed(5);

  // SPLIT SEARCH STRING TO WORDS ARRAY
  If #$SRCHSTR <> *BLANKS;
    STARTPOS = 1;

    DoU FOUNDPOS = %len(%trim(#$SRCHSTR)) + 1;
      If %subst(%trim(#$SRCHSTR):STARTPOS:1)='"';
        FOUNDPOS=%scan('"':%trim(#$SRCHSTR): STARTPOS+1);
        If FOUNDPOS<>0;
          FOUNDPOS+=1;
        EndIf;
      Else;
        FOUNDPOS=%scan(' ':%trim(#$SRCHSTR):STARTPOS);
      EndIf;
      If FOUNDPOS = 0;
        FOUNDPOS = %len(%trim(#$SRCHSTR)) + 1;
      EndIf;
      INDEX += 1;
      WORDS(INDEX) = %subst(%trim(#$SRCHSTR):STARTPOS
                                 : FOUNDPOS - STARTPOS);
      STARTPOS = FOUNDPOS + 1;
    EndDo;

  EndIf;

  // LOOP THROUGH SEARCH WORDS ADD A CLAUSE FOR EACH ONE
  *In77 = *Off;
  For i=1 TO 50;
    If WORDS(i)<>' ';

      If NOT *In77;
        SRCHSTR=%trim(SRCHSTR) + ' (';
      EndIf;
      If *In77;
        SRCHSTR=%trim(SRCHSTR) + ' AND (';
      EndIf;
      *In77 = *On;

      // LOOP THROUGH FIELDS ARRAY AND ADD A LIKE CLAUSE FOR EACH ONE
      *In78 = *Off;
      For j=1 TO 500;
        If #$SRCHFLDS(j)<>' ';

          If %subst(WORDS(i):1:1)='-';
            If *In78;
              SRCHSTR=%trim(SRCHSTR) + ' AND';
            EndIf;
            *In78 = *On;
            SRCHSTR=%trim(SRCHSTR) + ' UPPER(' + %trim(#$SRCHFLDS(j)) +
                      ') NOT LIKE UPPER(''%' + %scanrpl('"':'':
                        %scanrpl('''':'''''': %trim(%subst(WORDS(i):2:99))))
                        + '%'')';
          Else;
            If *In78;
              SRCHSTR=%trim(SRCHSTR) + ' OR';
            EndIf;
            *In78 = *On;
            SRCHSTR=%trim(SRCHSTR) + ' UPPER(' + %trim(#$SRCHFLDS(j)) +
                       ') LIKE UPPER(''%' + %scanrpl('"':'':
                       %scanrpl('''':'''''': %trim(WORDS(i)))) + '%'')';
          EndIf;

        EndIf;
      EndFor;

      If *In77;
        SRCHSTR=%trim(SRCHSTR) + ')';
      EndIf;

    EndIf;
  EndFor;

  Return SRCHSTR;

End-Proc;

// ****************************************************************
// #$ACTJOB - See if an active job exists
//
//   INPUT: JobName  = Name of the job
//          JobUser = Optional, Omittable, Default *ALL
//          JobNumber = Optional, Omittable, Default *ANY
//          SubSystemName = Optional, Default *ALL
//          SubSystemLib  = Optional, Default *ALL
//
// RETURNS: Boolean= *ON at least one active job exists
//                   *OFF no active jobs exist
//
// Examples:
//   Look to see if any active job named ACCOMMERGE exist
//   IF     #$ACTJOB('ACOMMERGE')
//
//   See if ACOMMERGE exists for user QSYSOPR
//   IF     #$ACTJOB('ACOMMERGE':'QSYSOPR')
//
//   See if specific ACOMMERGE job is active
//   IF     #$ACTJOB('ACOMMERGE':'QSYSOPR':'1234546')
//
//   See if ACOMMERGE exists in the SLEEPER subsystem
//   IF     #$ACTJOB('ACOMMERGE':*OMIT:*OMIT:'SLEEPER')
//
//   See if ACOMMERGE exists in the QSYS/SLEEPER subsystem
//   IF     #$ACTJOB('ACOMMERGE':*OMIT:*OMIT:'SLEEPER':'QSYS')
//
//   See if ACOMMERGE exists for QSYSOP in QSYS/SLEEPER sbs
//   IF  #$ACTJOB('ACOMMERGE':'QSYSOPR':*OMIT:'SLEEPER':'QSYS')
//
Dcl-Proc #$ACTJOB EXPORT;
  Dcl-Pi *N Ind;
    JOBNAME        Char(10)   CONST;
    #$JOBUSER      Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
    #$JOBNBR       Char(6)    CONST OPTIONS(*NOPASS:*OMIT);
    #$SBSNAME      Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
    #$SBSLIB       Char(10)   CONST OPTIONS(*NOPASS:*OMIT);
  End-Pi;

  // INPUT FIELDS WITH DEFAULTS IF NOT PASSED
  Dcl-S JOBUSER      Char(10)   INZ('*ALL');
  Dcl-S JOBNBR       Char(6)    INZ('*ALL');
  Dcl-S SBSNAME      Char(10)   INZ('*ALL');
  Dcl-S SBSLIB       Char(10)   INZ('*ALL');

  // CRTUSRSPC: CREATE USER SPACE FOR OS/400 API'S
  Dcl-Pr QUSCRTUS  EXTPGM('QUSCRTUS');
    USRSPC         Char(20)   CONST;
    EXTATTR        Char(10)   CONST;
    INITIALSIZE    Int(10)    CONST;
    INITIALVAL     Char(1)    CONST;
    PUBLICAUTH     Char(10)   CONST;
    Text           Char(50)   CONST;
    REPLACE        Char(10)   CONST;
    ERRORCODE      Char(32766) OPTIONS(*NOPASS: *VARSIZE);
  End-Pr;

  // PROTOTYPE FOR API RETRIVE USER SPACE
  Dcl-Pr QUSRTVUS  EXTPGM( 'QUSRTVUS' );
    USERSPACE      Char(20);
    STRPOS         Bindec(8);
    LENGTHOFDATA   Bindec(8);
    RECVERVAR      Char(32048);
    ERROR          Char(256);
  End-Pr;

  // PROTOTYPE FOR API RETRIVE LIST JOB
  Dcl-Pr QUSLJOB  EXTPGM( 'QUSLJOB' );
    USERSPAC       Char(20)   CONST;
    FORMATNAME     Char(8)    CONST;
    JOBNAME        Char(26)   CONST;
    FLDSTATUS      Char(10)   CONST;
    FLDERROR       Char(256);
    JOBTYPE        Char(1)    CONST;
    NBRFLDRTN      Bindec(8)  CONST;
    KEYFLDRTN      Bindec(8)  DIM( 100 ) CONST;
  End-Pr;

  // DEFINED VARIABLES
  Dcl-S USRSPCNAME   Char(20)   INZ( '#$ACTJOBWKQTEMP     ' );

  Dcl-Ds QUSA0100;
    QUSRSPCOFFSET  Bindec(9)  Pos(1);
    QUSRSPCENTRIES Bindec(9)  Pos(9);
    QUSRSPCSIZE    Bindec(9)  Pos(13);
  End-Ds;
  Dcl-Ds LJOBINPUT  QUALIFIED;
    JOBNAME        Char(10)   Pos(1);
    USERNAME       Char(10)   Pos(11);
    JOBNUMBER      Char(6)    Pos(21);
    STATUS         Char(10)   Pos(27);
    USERSPACE      Char(10)   Pos(37);
    USERSPACELIB   Char(10)   Pos(47);
    FORMAT         Char(8)    Pos(57);
    JOBTYPE        Char(1)    Pos(65);
    RESERVED01     Char(3)    Pos(66);
    RESERVED02     Bindec(9)  Pos(69);

  End-Ds;
  Dcl-Ds LJOB100  QUALIFIED;
    JOBNAME        Char(10)   Pos(1);
    USERNAME       Char(10)   Pos(11);
    JOBNUMBER      Char(6)    Pos(21);
    INTJOBID       Char(16)   Pos(27);
    STATUS         Char(10)   Pos(43);
    JOBTYPE        Char(1)    Pos(53);
    JOBSUBTYPE     Char(1)    Pos(54);
    RESERVED01     Char(2)    Pos(55);

  End-Ds;
  Dcl-Ds LJOB200  QUALIFIED;
    JOBNAME        Char(10)   Pos(1);
    USERNAME       Char(10)   Pos(11);
    JOBNUMBER      Char(6)    Pos(21);
    INTJOBID       Char(16)   Pos(27);
    STATUS         Char(10)   Pos(43);
    JOBTYPE        Char(1)    Pos(53);
    JOBSUBTYPE     Char(1)    Pos(54);
    RESERVED01     Char(2)    Pos(55);
    JOBINFOSTATUS  Char(1)    Pos(57);
    RESERVED02     Char(3)    Pos(58);
    NUMFIELDSRET   Bindec(9)  Pos(61);
    RETURNEDDATA   Char(1000) Pos(65);

  End-Ds;
  Dcl-Ds LJOB200KEY  QUALIFIED;
    KEYNUMBER01    Bindec(9)  Pos(1);
    NUMBEROFKEYS   Bindec(9)  Pos(5);

  End-Ds;
  Dcl-Ds LJOBKEYINFO  QUALIFIED;
    LENOFINFORM    Bindec(9)  Pos(1);
    KEYFIELD       Bindec(9)  Pos(5);
    TYPEOFDATA     Char(1)    Pos(9);
    RESERVED01     Char(3)    Pos(10);
    LENGTHOFDATA   Bindec(9)  Pos(13);
    KEYDATA        Char(1000) Pos(17);

    // STANDARD API ERROR HANDLING STRUCTURE.
  End-Ds;
  Dcl-Ds apiError  QUALIFIED;
    BYTESPROVIED   Bindec(9)  Pos(1) INZ( %len( apiError ) );
    BYTESAVAILBLE  Bindec(9)  Pos(5);
    MESSAGEID      Char(7)    Pos(9);
    RESERVED       Char(1)    Pos(16);
    INFORMATION    Char(240);

    // WORK FIELDS
  End-Ds;
  Dcl-Ds VARIABLES;
    Q              Char(1)    INZ( '''' );
    COUNT          Zoned(15:0) INZ(  0   );
    KEYCOUNT       Zoned(15:0) INZ(  0   );
    SUBSYSTEM      Char(20)   INZ( ' '  );
    RETURNCODE     Ind        INZ(*OFF);
    KEYFLDRTN      Bindec(8)  INZ(  0  ) DIM( 100 );
    STARTINGPOSITION Bindec(8)  INZ(  0  );
    LENGTHOFDATA   Bindec(8)  INZ(  0  );
    RECEIVERVARIABLE Char(32048);
    OS400_CMD      Char(2000) INZ( ' '  );
    CMDLENGTH      Packed(15:5) INZ( %size( OS400_CMD ) );
  End-Ds;

  // SEND MESSAGE API
  Dcl-Pr SNDPGMMSG  EXTPGM('QMHSNDPM');
    MESSAGEID      Char(7)    CONST;
    QUALMSGF       Char(20)   CONST;
    MSGDATA        Char(256)  CONST;
    MSGDTALEN      Int(10)    CONST;
    MSGTYPE        Char(10)   CONST;
    CALLSTKENT     Char(10)   CONST;
    CALLSTKCNT     Int(10)    CONST;
    MESSAGEKEY     Char(4);
    ERRORCODE      Char(32766) OPTIONS(*VARSIZE);
  End-Pr;

  Dcl-S WWMSG        Char(256);
  Dcl-S WWTHEKEY     Char(4);

  // ***********************************************************************

  // GET OPTIONAL INPUT PARAMETERS
  If %parms() >= 2 AND %addr(#$JOBUSER) <> *NULL;
    JOBUSER=#$JOBUSER;
  EndIf;
  If %parms() >= 3 AND %addr(#$JOBNBR) <> *NULL;
    JOBNBR=#$JOBNBR;
  EndIf;
  If %parms() >= 4 AND %addr(#$SBSNAME) <> *NULL;
    SBSNAME=#$SBSNAME;
  EndIf;
  If %parms() >= 5 AND %addr(#$SBSLIB) <> *NULL;
    SBSLIB=#$SBSLIB;
  EndIf;

  // CREATE A USER SPACE
  QUSCRTUS(USRSPCNAME:'USRSPC': 10000:X'00':'*ALL':
                 'TEMP USER SPACE FOR #$ACTJOB': '*YES': apiError);

  // RUN API TO FILL USER SPACE WITH INFORMATION ABOUT ALL ACTIVE ISERIES JOB
  KEYFLDRTN( 1 ) = 1906;
  QUSLJOB( USRSPCNAME : 'JOBL0200' : JOBNAME + JOBUSER + JOBNBR
               : '*ACTIVE   ': apiError    : '*'   : 1 : KEYFLDRTN);

  // IF ERROR MESSAGE FROM THE RETRIEVE JOB API THEN DUMP PROGRAM
  If apiError.MESSAGEID <> ' ';
    WWMSG='ERROR - List jobs API failed.';
    DUMP;
    SNDPGMMSG('CPF9897': 'QCPFMSG   *LIBL': %trim(WWMSG)
                   : %len(%trim(WWMSG)): '*ESCAPE':'*PGMBDY': 1
                   : WWTHEKEY: apiError);
    Return *OFF;
  EndIf;

  // RUN API TO GET USER SPACE ATTRIBUTE
  STARTINGPOSITION = 125;
  LENGTHOFDATA = 16;
  QUSRTVUS( USRSPCNAME   : STARTINGPOSITION  : LENGTHOFDATA
                 : RECEIVERVARIABLE  : apiError );
  QUSA0100 = RECEIVERVARIABLE;

  // IF ERROR MESSAGE FROM THE RETRIEVE USER SPACE API THEN DUMP PROGRAM
  // TODO REPLACE WITH AN EXCEPTION ERROR
  If apiError.MESSAGEID <> ' ';
    WWMSG='ERROR - User space not retrieved.';
    DUMP;
    SNDPGMMSG('CPF9897': 'QCPFMSG   *LIBL': %trim(WWMSG)
                    : %len(%trim(WWMSG)): '*ESCAPE':'*PGMBDY': 1
                    : WWTHEKEY: apiError);
    Return *OFF;
  EndIf;

  // PREPERATION TO READ FROM USER SPACE
  STARTINGPOSITION = QUSRSPCOFFSET + 1;
  LENGTHOFDATA = QUSRSPCSIZE;

  // READ FROM USER SPACE
  For COUNT = 1 TO QUSRSPCENTRIES;
    QUSRTVUS( USRSPCNAME   : STARTINGPOSITION  : LENGTHOFDATA
                   : RECEIVERVARIABLE  : apiError );
    LJOB200 = RECEIVERVARIABLE;

    // TODO REPLACE WITH AN EXCEPTION ERROR
    If apiError.MESSAGEID <> ' ';
      WWMSG='Cannot read from user space.';
      DUMP;
      SNDPGMMSG('CPF9897': 'QCPFMSG   *LIBL': %trim(WWMSG)
                     : %len(%trim(WWMSG)): '*ESCAPE':'*PGMBDY': 1
                     : WWTHEKEY: apiError);
      Return *OFF;
    EndIf;

    // EXTRACT SUB SYSTEM FROM THE RETURNED DATA
    // WE ONLY ASKED FOR ONE KEY SO THIS SKIPS LOOPING THROUGH THE DATASET
    LJOBKEYINFO = LJOB200.RETURNEDDATA;

    LJOBKEYINFO = %subst( LJOB200.RETURNEDDATA : 1
                               : LJOBKEYINFO.LENOFINFORM);
    If LJOBKEYINFO.KEYFIELD = 1906;
      SUBSYSTEM = %subst( LJOBKEYINFO.KEYDATA : 1
                              :  LJOBKEYINFO.LENGTHOFDATA);
    EndIf;

    // IF THE SUB SYSTEM MATCHES THE REQUESTED SUBSYSTEM RETURN *ON
    If (SBSNAME='*ALL' OR SBSNAME=%subst(SUBSYSTEM:1:10))
           AND (SBSLIB='*ALL' OR SBSLIB=%subst(SUBSYSTEM:11:10));
      Return *ON;
    EndIf;

    STARTINGPOSITION += LENGTHOFDATA;
  EndFor;

  // IF NO ACTIVE JOB FOUND RETURN *OFF
  Return *OFF;

  // ***********************************************************************
End-Proc;

// ****************************************************************
// #$CVTDAT - conbert character date to numeric (8,0)
//
//  INPUT:  #$DATE  = CHARACTER DATE
//          #$FORMAT= FORMAT OF CHARACTER DATE
// RETURN:          = 8 DIGIT NUMERIC DATE IN YYYYMMDD FORMAT
//
// FORMAT OPTIONS
//    *USA OR *MDYY - MM/DD/YYYY WITH OR W/OUT LEADING ZEROS,
//                    EXAMPLE  1/1/2019 OR 01/01/2019
//                    THE DEFAULT IF NOT PASSED
//    *ISO OR *YYMD - YYYY/MM/DD WITH OR W/OUT LEADING ZEROS,
//                    EXAMPLE  2019/1/1 OR 2019/01/01
//    *YMD -          YY/MM/DD WITH OR WITHOUT LEADING ZEROS,
//                    EXAMPLE  19/1/1 OR 19/01/01
//    *MDY -          MM/DD/YY WITH OR WITHOUT LEADING ZEROS,
//                    EXAMPLE  1/1/19 OR 01/01/19
//
Dcl-Proc #$CVTDAT EXPORT;
  Dcl-Pi *N Zoned(8:0);
    #$CHAR         Char(10)   CONST;
    #$FMT          Char(5)    CONST OPTIONS(*NOPASS:*OMIT);
  End-Pi;
  Dcl-S fmt          Char(5)    INZ('*USA');
  Dcl-S chr          Char(10);

  If %parms() >= 2 AND %addr(#$FMT) <> *NULL;
    fmt=#$FMT;
  Else;
    fmt='*USA';
  EndIf;

  // CONVERT ALL SEPERATORS TO -
  chr=%scanrpl('-':'/':#$CHAR);
  chr=%scanrpl('.':'/':chr);
  chr=%scanrpl(',':'/':chr);
  chr=%scanrpl('&':'/':chr);

  // CONVERT PASSED FORMAT TO REQUIRED FORMAT
  If fmt='*USA' OR fmt='*MDYY';
    Return    %dec(%char(%date(chr:*USA/):*ISO0):8:0);
  ElseIf fmt='*ISO' OR fmt='*YYMD';
    chr = %scanrpl('/':'-':chr);
    Return    %dec(%char(%date(chr:*ISO-):*ISO0):8:0);
  ElseIf fmt='*MDY';
    Return    %dec(%char(%date(chr:*MDY/):*ISO0):8:0);
  ElseIf fmt='*YMD';
    Return    %dec(%char(%date(chr:*YMD/):*ISO0):8:0);
  Else;
    Return    %dec(%char(%date(chr:*USA/):*ISO0):8:0);
  EndIf;

End-Proc;


// ****************************************************************
// #$INTACT - See if a Job is Interactive
//
//  INPUT:  None
// RETURN:  INTACT = I if the job is interactive.
//
//    EVAL  BORI=#$INTACT
//
Dcl-Proc #$INTACT EXPORT;
  Dcl-Pi *N Char(1);

    // API error information:
  End-Pi;
  Dcl-Ds APIERR  QUALIFIED;
    BytPro         Int(10)    INZ( %size( APIERR ));
    BytAvl         Int(10);
    MsgId          Char(7);
    *N             Char(1);
    MsgDta         Char(256);

    // Return Job Attribute Data Structure, Defined Bellow
  End-Ds;
  Dcl-Pr QUSRJOBI  EXTPGM('QUSRJOBI');
    RcvVar         Char(32766) OPTIONS(*VARSIZE);
    RcvVarLen      Int(10)    CONST;
    Format         Char(8)    CONST;
    QualJob        Char(26)   CONST;
    InternJob      Char(16)   CONST;
    ErrorCode                 LIKE(APIERR);

    // Data Structure job description, used in QUSRJOBI
  End-Pr;
  Dcl-Ds dsJob;
    dsJobBytesRtn  Int(10);
    dsJobBytesAvl  Int(10);
    dsJobName      Char(10);
    dsJobUser      Char(10);
    dsJobNumber    Char(6);
    dsJobIntern    Char(16);
    dsJobStatus    Char(10);
    dsJobType      Char(1);
    dsJobSubtype   Char(1);
    dsJobReserv1   Char(2);
    dsJobRunPty    Int(10);
    dsJobTimeSlc   Int(10);
    dsJobDftWait   Int(10);
    dsJobPurge     Char(10);

  End-Ds;
  Dcl-S APIHANDLE    Int(10);

  APIHANDLE=%size(dsJob);
  QUSRJOBI(dsJob: APIHANDLE:'JOBI0100': '*':' ':APIERR);
  If DSJOBTYPE = 'I';
    Return 'I';
  Else;
    Return ' ';
  EndIf;
End-Proc;


// ****************************************************************
// #$WORDWRP2  - Word Wrap a string based on length
//                and return an array
//
//  INPUT:  StringIn = The string to wrap.
//          TrimLength = The lengthin in which to wrap.
// RETURN:  Array  = The wrapped lines.
//
Dcl-Proc #$WordWrp2 export;
  Dcl-Pi *N Char(250) DIM(250);
    stringIn       Varchar(32000)  CONST OPTIONS(*VARSIZE);
    trimLength     Packed(5:0) CONST;
  End-Pi;

  // Local fields
  Dcl-S i            Packed(5:0); //Current Pos
  Dcl-S strChr       Packed(5:0); //Start of St
  Dcl-S space        Packed(5:0); //Last Space
  Dcl-S endChr       Packed(5:0); //End Of Line
  Dcl-S length       Packed(5:0); //Length
  Dcl-S x            Packed(5:0); //Array Position
  Dcl-S lengthCounter Packed(5:0);
  Dcl-S stringInLen  Packed(5:0);
  Dcl-S WordWrap     Char(80)   DIM(25);

  i = 1;
  strChr = 1;
  space = trimLength;
  endChr = 0;
  length = 0;
  x = 0;
  lengthCounter = 0;
  stringInLen = 0;
  DoW (i < 25);
    WordWrap(i) = ' ';
    i += 1;
  EndDo;

  i = 1;
  stringInLen = %len(%trim(stringIn));

  DoW i <= stringInLen and %subst(stringIn:i) <> ' ';

    // Check to see if it is a space
    If %subst(stringIn:i:1) = ' ';
      space = i;
    EndIf;
    If lengthCounter >= trimLength;
      endChr = space - 1;
      ExSr AddString;
      If %subst(stringIn:space:1) = ' ';
        strChr = space + 1;
      Else;
        strChr = space;
      EndIf;
      lengthCounter = (1 + (i - strChr + 1));
      space += trimLength;
    EndIf;

    i += 1;
    lengthCounter += 1;
  EndDo;

  endChr = i;
  ExSr AddString;

  Return WordWrap;

  // AddString - Add the line to the array
  BegSr AddString;

    x += 1;
    length = endChr - strChr + 1;

    If length < 1;
      length = trimLength;
    EndIf;

    If ((strChr + length) < stringInLen);
      WordWrap(x) = %subst(stringIn:strChr:length);
    Else;
      WordWrap(x) = %subst(stringIn:strChr);
    EndIf;
  EndSr;    // AddString
End-Proc;


// ****************************************************************
// #$WORDWRAP  -  Word Wrap a string based on length
//                  and return a string
//
//  INPUT:  StringIn = The string to wrap.
//          TrimLength = The lengthin in which to wrap.
// RETURN:  String = The wrapped string.
//
Dcl-Proc #$WordWrap export;
  Dcl-Pi *N Char(32000);
    stringIn       Varchar(32000)  CONST OPTIONS(*VARSIZE);
    trimLength     Packed(5:0) CONST;
  End-Pi;

  // Local fields
  Dcl-S i            Packed(5:0); //Current Pos
  Dcl-S temparray    Char(250)  DIM(250);
  Dcl-S outstring    Char(32000) INZ;


  temparray = #$WordWrp2(stringIn:trimLength);
  For i = 1 to 250;
    %subst(outstring:((i-1) * trimLength)+1:trimLength) = temparray(i);
  EndFor;

  Return %trim(outstring);

End-Proc;


// ****************************************************************
// #$PARTITION - Returns the current partition.
//
//  INPUT:  None
// RETURN:  Partition Number.
//
Dcl-Proc #$Partition EXPORT;
  Dcl-Pi *N Bindec(4);
  End-Pi;

  // RETREIVE SYSTEM STATUS API INTERFACE
  Dcl-Pr getSystemStatus  EXTPGM('QWCRSSTS');
    *N             Char(256)  OPTIONS(*VARSIZE);
    *N             Int(10)    CONST;
    *N             Char(8)    CONST;
    *N             Char(10)   CONST OPTIONS(*VARSIZE);
    *N             Char(256);
    *N             Char(1024) OPTIONS(*VARSIZE:*NOPASS);
    *N             Int(10)    OPTIONS(*NOPASS);
  End-Pr;

  // API ERROR DATA STRUCTURE
  Dcl-Ds API_Err Len(256);
  End-Ds;

  // THE FOLLOWING DATA STRUCTURE IS RETURNED FROM THE API
  Dcl-Ds Fmt_002 Len(256);
    Partition      Bindec(9)  Pos(81);
  End-Ds;


  // CALL THE API TO RETRIEVE THE DSPSYSSTS INFO FOR THIS SYS:
  getSystemStatus(Fmt_002:%size(Fmt_002):'SSTS0200':'*YES':API_Err);

  Return PARTITION;

End-Proc;


// ****************************************************************
// #$SYSNAME - Returns the current systems name.
//
//  INPUT:  None
// RETURN:  System Name Char(8).
//
Dcl-Proc #$SysName EXPORT;
  Dcl-Pi *N Char(8);

    // RETREIVE NETWORK ATTRIBUTE API INTERFACE
  End-Pi;
  Dcl-Pr QWCRNETA  EXTPGM('QWCRNETA');
    RcvVar         Char(32766) OPTIONS(*VARSIZE);
    RcvVarLen      Int(10)    CONST;
    NbrNetAtr      Int(10)    CONST;
    AttrNames      Char(10)   CONST;
    ErrorCode      Char(256);

    // Error code structure
  End-Pr;
  Dcl-Ds apiError Len(256);

    // Receiver variable for QWCRNETA
  End-Ds;
  Dcl-Ds apiData;
    Filler         Char(32);
    RtnSystem      Char(8);

    // Call the *API and return the system name
  End-Ds;
  QWCRNETA (apiData : %size(apiData) : 1 : 'SYSNAME' : apiError );
  Return RTNSYSTEM;
End-Proc;


// ****************************************************************
// #$VPATH - Validates an IFS path.
//
//  INPUT:  Path
// RETURN:  Returns *OFF if it exists, *ON if it doesn't.
//
Dcl-Proc #$VPATH EXPORT;
  Dcl-Pi *N Ind;
    #$PATH         Varchar(5000) VALUE;

  End-Pi;
  Dcl-Pr ACCESS Int(10) EXTPROC('access');
    PATH           Pointer    VALUE OPTIONS(*STRING);
    AMODE          Int(10)    VALUE;


    // JUST CHECK IF THE FILE EXISTS
  End-Pr;
  If ACCESS(%trim(#$PATH): 0) < 0;
    Return *ON;
  Else;
    Return *OFF;
  EndIf;

End-Proc;


// ****************************************************************
// #$USRHOME - Returns a Users Home Directory.
//
//  INPUT:  User - Optional, Default=current user
// RETURN:  The home directory or blank if there is an error.
//
Dcl-Proc #$USRHOME EXPORT;
  Dcl-Pi *N Varchar(256);
    #$USER         Char(10)   CONST OPTIONS(*NOPASS);

  End-Pi;
  Dcl-Ds PASSWD  QUALIFIED BASED(TEMPLATE);
    PW_NAME        Pointer;
    PW_UID         Uns(10);
    PW_GID         Uns(10);
    PW_DIR         Pointer;
    PW_SHELL       Pointer;
  End-Ds;

  Dcl-Pr GETPWNAM Pointer EXTPROC('getpwnam');
    NAME           Pointer    VALUE OPTIONS(*STRING);
  End-Pr;

  Dcl-S P_INFO       Pointer;

  Dcl-Ds INFO  LIKEDS(PASSWD) BASED(P_INFO);

  Dcl-S WKUSER       Char(10);
  Dcl-S PEHOMEDIR    Char(256);


  // USER PASSED USER OR CURRENT USER
  If %parms() >= 1 AND %addr(#$USER) <> *NULL AND #$USER<>' ';
    WKUSER=#$USER;
  Else;
    WKUSER=USER;
  EndIf;

  P_INFO = GETPWNAM(%trimr(WKUSER));

  If P_INFO<>*NULL AND INFO.PW_DIR<>*NULL;
    Return %trim(%str(INFO.PW_DIR));
  Else;
    Return ' ';
  EndIf;

End-Proc;


// ****************************************************************
// #$SCANRPL - Same as %SCANRPL without PDM Errors
//
//  INPUT:  String to Find
//          Replacement String
//  INPUT:  Sting to replace in
// RETURN:  The string with the value replaced.
//
Dcl-Proc #$SCANRPL EXPORT;
  Dcl-Pi *N Varchar(32000);
    #$FIND         Varchar(32000) CONST;
    #$REPLACE      Varchar(32000) CONST;
    #$IN           Varchar(32000) CONST;
  End-Pi;

  Return %scanrpl(#$FIND:#$REPLACE:#$IN);

End-Proc;

// ****************************************************************
// #$DBLQ- Double Quotes in a String
//
//  INPUT:  Input Stirng
// RETURN:  The string with all quotes doubled.
//
Dcl-Proc #$DBLQ EXPORT;
  Dcl-Pi *N Varchar(32000);
    #$IN           Varchar(32000) CONST;
  End-Pi;

  Return %scanrpl('''':'''''':#$IN);

End-Proc;

// ****************************************************************
// #$FIXPRMLST = PRODCEDURE TO FIX PARAMETER LISTS
//
// THIS TAKES A STRING LIKE THIS - FAB,tre
// AND CONVERTS IT TO THIS - "FAB","TRE"
//
// THESE TYPES OF LISTS ARE NORMALLY PASSED IN FROM A WEBSITE
//
//  INPUT:  Input Stirng
// RETURN:  The string with all quotes doubled.
//
// Example
//                  EVAL      PSBRAND=#$FIXPRMLST(PSBRAND)
//
Dcl-Proc #$FIXPRMLST EXPORT;
  Dcl-Pi *N Varchar(4096);
    DATAIN         Varchar(4096) CONST;

  End-Pi;
  Dcl-S DATA         Varchar(4096);

  // USED TO CONVERT CASE
  Dcl-C ENGLOW     'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Dcl-C ENGUP      'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  // USED TO SPLIT WORDS INTO AN ARRAY
  Dcl-S ARRAY        Char(1000) DIM(50);
  Dcl-S STARTPOS     Int(10);
  Dcl-S FOUNDPOS     Int(10);
  Dcl-S I            Int(5)     INZ(1);

  DATA=DATAIN;

  // RETURN BLANK IF BLANK IS PASSED IN
  If DATA=' ';
    Return DATA;
  EndIf;

  // CONVERT TO ALL UPPER CASE
  DATA = %xlate(ENGLOW:ENGUP:DATA);

  // SPLIT WORDS INTO ARRAY
  STARTPOS = 1;
  DoU FOUNDPOS = %len(%trim(DATA)) + 1;
    FOUNDPOS = %scan(',':%trim(DATA):STARTPOS);
    If FOUNDPOS = 0;
      FOUNDPOS = %len(%trim(DATA)) + 1;
    EndIf;
    ARRAY(I) = %subst(%trim(DATA): STARTPOS:FOUNDPOS - STARTPOS);
    I += 1;
    STARTPOS = FOUNDPOS + 1;
  EndDo;

  // FORMAT THE OUTPUT CORRECTLY
  DATA=' ';
  *In81 = *Off;
  For I = 1 TO 40;
    If ARRAY(I)<>' ';
      If #$LAST(%trim(ARRAY(I)):1)=',';
        ARRAY(I)=%subst(ARRAY(I):1: %len(%trim(ARRAY(I)))-1);
      EndIf;
      If *In81;
        DATA=%trim(DATA) + ',';
      EndIf;
      *In81 = *On;
      If %subst(ARRAY(I):1:1)<>'''';
        DATA=%trim(DATA) + '''' + %trim(ARRAY(I)) + '''';
      Else;
        DATA=%trim(DATA) + %trim(ARRAY(I));
      EndIf;
    EndIf;
  EndFor;

  Return DATA;

End-Proc;

// ****************************************************************
// #$WAIT - DELAY JOB FOR A NUMBER OF SECONDS
// This procedure delays a job for a number of seconds.
//
//   Input: NBRSECS = The number of seconds to delay the job by.
//                    You can include up to 5 decimal positions.
//   Output: Nothing
//
//   Example to wait for 1.5 seconds
//   CALLP    #$WAIT(1.5)
//
Dcl-Proc #$WAIT EXPORT;
  Dcl-Pi *N;
    NBRSECS        Packed(15:5) VALUE;

    // PROTOTYPE FOR SLEEP, SLEEP FOR A NUMBER OF SECONDS
  End-Pi;
  Dcl-Pr SLEEP Int(10) EXTPROC('sleep');
    SECONDS        Uns(10)    VALUE;

    // PROTOTYPE FOR USLEEP, SLEEP FOR A NUMBER OF MICROSECONDS
  End-Pr;
  Dcl-Pr USLEEP Int(10) EXTPROC('usleep');
    MILISECONDS    Uns(10)    VALUE;

  End-Pr;
  Dcl-S SECONDS      Int(10);
  Dcl-S MICROSECONDS Int(10);
  Dcl-S RETURNSTATUS Int(10);


  // CALCULATE WHOLE SECONDS AND MICROSECONDS FOR DECIMAL POSITIONS
  SECONDS=%int(NBRSECS);
  MICROSECONDS=%rem(%int(NBRSECS*1000000):1000000);

  // SLEEP FOR THE WHOLE SECONDS
  RETURNSTATUS=SLEEP(SECONDS);

  // SLEEP FOR THE FRACTION OF SECONDS
  RETURNSTATUS=USLEEP(MICROSECONDS);

  Return;
End-Proc;

// ****************************************************************
// #$ISOBJ Test if an object exists.
//
//  INPUT:  #$FILE = Object Name Char(10)
//          #$TYPE = Object Type Char(10)
//          #$LIB  = Library, Optional, defaults to *LIBL
// RETURN:         = *ON if the object exists.
//
Dcl-Proc #$ISOBJ EXPORT;
  Dcl-Pi *N Ind;
    #$FILE         Char(10)   CONST;
    #$TYPE         Char(10)   CONST;
    #$LIB          Char(10)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S LIB          Char(10);

  // USE LIB IF PASSED OTHERWISE DEFAULT IT TO *LIBL
  If %parms() > 2 AND %addr(#$LIB)<>*NULL;
    LIB=#$LIB;
  Else;
    LIB='*LIBL';
  EndIf;

  Monitor;
    #$CMD('CHKOBJ OBJ('+%trim(LIB)+'/'+%trim(#$FILE)+') +
                     OBJTYPE('+%trim(#$TYPE)+')':2);
    Return *ON;
  On-Error;
    Return *OFF;
  EndMon;

End-Proc;

// ****************************************************************
// #$ISMBR Test if a member exists.
//
//  INPUT:  #$LIB  = Library Name Char(10)
//          #$FILE = File Name Char(10)
//          #$MBR  = Memeber Name
// RETURN:         = *ON if the member exists.
//
Dcl-Proc #$ISMBR EXPORT;
  Dcl-Pi *N Ind;
    #$LIB          Char(10)   CONST;
    #$FILE         Char(10)   CONST;
    #$MBR          Char(10)   CONST;
  End-Pi;
  Dcl-S LIB          Char(10);

  // USE LIB IF PASSED OTHERWISE DEFAULT IT TO *LIBL
  If %parms() > 1 AND %addr(#$LIB)<>*NULL;
    LIB=#$LIB;
  Else;
    LIB='*LIBL';
  EndIf;

  Monitor;
    #$CMD('CHKOBJ OBJ('+%trim(#$LIB)+'/'+%trim(#$FILE)+') +
                     OBJTYPE(*FILE) MBR('+%trim(#$MBR)+')':2);
    Return *ON;
  On-Error;
    Return *OFF;
  EndMon;

End-Proc;

// ****************************************************************
// #$CCHAR Clean Character, removes un-printable chars from a
//         string.
//
//  INPUT:  #$STR  = string
// RETURN:  #$STR  = the string with un-printable characters
//                   removed or replaced
//
Dcl-Proc #$CCHAR EXPORT;
  Dcl-Pi *N Varchar(32000);
    #$STR          Varchar(32000)  CONST;
    CCSID          Char(4)    CONST OPTIONS(*NOPASS);
  End-Pi;
  Dcl-S STR          Varchar(32000);
  Dcl-C NON_DISPLAY  CONST( X'000102030405060708090A0B0C0D0E0F+
                                     101112131415161718191A1B1C1D1E1F+
                                     202122232425262728292A2B2C2D2E2F+
                                     303132333435363738393A3B3C3D3E3F');
  Dcl-C ALL_NULL     CONST( X'00000000000000000000000000000000+
                                     00000000000000000000000000000000+
                                     00000000000000000000000000000000+
                                     00000000000000000000000000000000');
  Dcl-C ELLIPSIS     CONST(X'15');

  STR=#$STR;

  // Replace line breaks with a space
  // this is done so it doesn't smoosh things together
  STR = %scanrpl(x'0D25' : ' ' : STR);
  STR = %scanrpl(x'0D' : ' ' : STR);
  STR = %scanrpl(x'25' : ' ' : STR);

  If %parms>=2 AND %addr(CCSID)<>*NULL AND CCSID='PC';
    // Replace pc ellipses character with 3 periods
    STR = %scanrpl(X'15' : '...' : STR);
  EndIf;

  // These conversion are for ccsid 1252 specifically also work with pc
  If %parms>=2 AND %addr(CCSID)<>*NULL AND
            (CCSID='PC' OR CCSID='1252');
    // Replace pc ellipses character with 3 periods
    STR = %scanrpl(x'42206A' : '...' : STR);
    // Replace curved single and double quotes with straight ones
    STR = %scanrpl(x'422038' : '''' : STR);
    STR = %scanrpl(x'422039' : '''' : STR);
    STR = %scanrpl(x'422004' : '"' : STR);
    STR = %scanrpl(x'422014' : '"' : STR);
  EndIf;

  // remove any ascii characters under x'40'
  STR = %xlate(NON_DISPLAY : ALL_NULL : STR);
  STR = %scanrpl (X'00' : '' : STR);

  Return STR;

End-Proc;

// ****************************************************************
// #$C2H Convert a character string to a hex string
//
//  INPUT:  #$STR  = a character string
// RETURN:  #$STR  = the string converted to hex, will be
//                   twice as long
//
Dcl-Proc #$C2H EXPORT;
  Dcl-Pi *N Varchar(32000);
    #$STR          Varchar(32000)  CONST;
  End-Pi;
  Dcl-S STR          Varchar(32000);
  Dcl-S HEX          Char(32000);

  Dcl-Pr CHARTOHEX  EXTPROC( 'cvthc' );
    CTHHEX         Pointer    VALUE;
    CTHCHAR        Pointer    VALUE;
    CTHCHARSIZE    Int(10)    VALUE;
  End-Pr;

  STR=#$STR;

  // SINCE STR IS VARRYING WE HAVE TO MOVE THE POINTER OVER 2 CHARACTERS
  // THE LENGTH IS THE RETURN LENGTH SO IT HAS TO BE DOUBLED
  CHARTOHEX (%addr(HEX) : %addr(STR) + 2 : %len(STR)*2);

  Return %trim(HEX);

End-Proc;

// ****************************************************************
// #$H2C Convert a hex string to a character string
//
//  INPUT:  #$STR  = a hex string
// RETURN:  #$STR  = the hext string converted to characters,
//                   will be half as long
//
Dcl-Proc #$H2C EXPORT;
  Dcl-Pi *N Varchar(32000);
    #$HEX          Varchar(32000)  CONST;
  End-Pi;
  Dcl-S HEX          Varchar(32000);
  Dcl-S STR          Char(32000);

  Dcl-Pr HEXTOCHAR  EXTPROC('cvtch');
    HTCCHAR        Pointer    VALUE;
    HTCHEX         Pointer    VALUE;
    HTCCHARSIZE    Int(10)    VALUE;
  End-Pr;

  HEX=#$upify(#$HEX);

  // SINCE HEX IS VARRYING WE HAVE TO MOVE THE POINTER OVER 2 CHARACTERS
  Monitor;
    HEXTOCHAR (%addr(STR) : %addr(HEX) + 2 : %len(HEX));
  On-Error;
    #$SNDMSG('Error call to #$H2C did not complete, +
                   the value passed was ''' + %trim(HEX) + ''', this +
                   value contains invalid hex characters.':'*INFO');
    Return '';
  EndMon;

  // WE CANNOT TRIM THE RESULTS BECASUE WE HAVE TO PRESERVE LEADING AND
  // TRAILING BLANKS, THEREFORE WE USE SUBSTRING TO SET THE LENGTH TO
  // HALF THE LENGTH OF THE HEX STRING COMMING IN
  Return %subst(STR:1:%int(%len(HEX)/2));

End-Proc;

// ****************************************************************
// #$PLAY - Test Playing a WAV on the local computer
// This runs a batch file on the local computer in the
// background. That batch file can be setup to play a sound.
//
// There is a test batch file at D:\Is\IS47\PlayWave\test.bat
// that shows you how to play a sound. The program passes the
// name of the batch file to the ghost_cmd.exe program which
// in turn runs the batch file without displaying a window.
//
// If this is used in production the location of the folder
// will need to be changed to a publicly accessible folder.
//
// INPUT:   file = The batch file to run, full path required.
// RETURN:  nothing
//
Dcl-Proc #$PLAY export;
  Dcl-Pi *N;
    #$file   varchar(100)  CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S file varchar(100);

  // override the file to the passed file name or use the default
  If %parms() > 1 and %addr(#$file) <> *null;
    file=#$file;
  Else;
    file='D:\Is\IS47\PlayWave\test.bat';
  EndIf;

  #$CMD('STRPCO PCTA(*NO)':1);
  #$CMD('STRPCCMD PCCMD(''"D:\Is\IS47\PlayWave\ghost_cmd.exe" +
                                "'+%trim(file)+'"'') +
                        PAUSE(*NO)');

  Return;

End-Proc;

// ****************************************************************
// #$IN - Test if a character value is in a list
//
// INPUT: Value, A variable holding the value to test
//        parm2-21 A list of up to 20 values to test
//
// RETURN: *on or *off
//
// Example:
//
//  if #$IN(value:'ONE':'TWO':'THREE')
//     erm='Value in list.';
//  else;
//     erm='Value not in list.';
//  endif;
//
Dcl-Proc #$IN export;
  Dcl-Pi *N Ind;
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
  End-Pi;

  // override the file to the passed file name or use the default
  If %parms()>=  2 and Value=list01 or
          %parms()>=  3 and Value=list02 or
          %parms()>=  4 and Value=list03 or
          %parms()>=  5 and Value=list04 or
          %parms()>=  6 and Value=list05 or
          %parms()>=  7 and Value=list06 or
          %parms()>=  8 and Value=list07 or
          %parms()>=  9 and Value=list08 or
          %parms()>= 10 and Value=list09 or
          %parms()>= 11 and Value=list10 or
          %parms()>= 12 and Value=list11 or
          %parms()>= 13 and Value=list12 or
          %parms()>= 14 and Value=list13 or
          %parms()>= 15 and Value=list14 or
          %parms()>= 16 and Value=list15 or
          %parms()>= 17 and Value=list16 or
          %parms()>= 18 and Value=list17 or
          %parms()>= 19 and Value=list18 or
          %parms()>= 20 and Value=list19 or
          %parms()>= 21 and Value=list20;
    Return *on;
  Else;
    Return *off;
  EndIf;

End-Proc;

// ****************************************************************
// #$INN - Test if a numeric value is in a list
//
// INPUT: Value, A variable holding the value to test
//        parm2-21 A list of up to 20 values to test
//
// RETURN: *on or *off
//
// Example:
//
//  if #$INN(value:1:2:123.35)
//     erm='Value in list.';
//  else;
//     erm='Value not in list.';
//  endif;
//
Dcl-Proc #$INN export;
  Dcl-Pi *N Ind;
    Value          Packed(20:5) Value;
    list01         Packed(20:5) Value OPTIONS(*NOPASS);
    list02         Packed(20:5) Value OPTIONS(*NOPASS);
    list03         Packed(20:5) Value OPTIONS(*NOPASS);
    list04         Packed(20:5) Value OPTIONS(*NOPASS);
    list05         Packed(20:5) Value OPTIONS(*NOPASS);
    list06         Packed(20:5) Value OPTIONS(*NOPASS);
    list07         Packed(20:5) Value OPTIONS(*NOPASS);
    list08         Packed(20:5) Value OPTIONS(*NOPASS);
    list09         Packed(20:5) Value OPTIONS(*NOPASS);
    list10         Packed(20:5) Value OPTIONS(*NOPASS);
    list11         Packed(20:5) Value OPTIONS(*NOPASS);
    list12         Packed(20:5) Value OPTIONS(*NOPASS);
    list13         Packed(20:5) Value OPTIONS(*NOPASS);
    list14         Packed(20:5) Value OPTIONS(*NOPASS);
    list15         Packed(20:5) Value OPTIONS(*NOPASS);
    list16         Packed(20:5) Value OPTIONS(*NOPASS);
    list17         Packed(20:5) Value OPTIONS(*NOPASS);
    list18         Packed(20:5) Value OPTIONS(*NOPASS);
    list19         Packed(20:5) Value OPTIONS(*NOPASS);
    list20         Packed(20:5) Value OPTIONS(*NOPASS);
  End-Pi;

  // override the file to the passed file name or use the default
  If %parms()>=  2 and Value=list01 or
          %parms()>=  3 and Value=list02 or
          %parms()>=  4 and Value=list03 or
          %parms()>=  5 and Value=list04 or
          %parms()>=  6 and Value=list05 or
          %parms()>=  7 and Value=list06 or
          %parms()>=  8 and Value=list07 or
          %parms()>=  9 and Value=list08 or
          %parms()>= 10 and Value=list09 or
          %parms()>= 11 and Value=list10 or
          %parms()>= 12 and Value=list11 or
          %parms()>= 13 and Value=list12 or
          %parms()>= 14 and Value=list13 or
          %parms()>= 15 and Value=list14 or
          %parms()>= 16 and Value=list15 or
          %parms()>= 17 and Value=list16 or
          %parms()>= 18 and Value=list17 or
          %parms()>= 19 and Value=list18 or
          %parms()>= 20 and Value=list19 or
          %parms()>= 21 and Value=list20;
    Return *on;
  Else;
    Return *off;
  EndIf;

End-Proc;

// ****************************************************************
// #$132OK - Tests if display handles 132 characters
//
// INPUT: None
//
// RETURN: *on or *off, *on = handels 132 cha
//
// Example:
//
//  if #$132OK;
//     ScrSze='2';
//  else;
//     ScrSze='1';
//  endif;
//
Dcl-Proc #$132OK export;
  Dcl-Pi *N Ind;
  End-Pi;

  // Error Data Structure
  Dcl-Ds dsEC  QUALIFIED;
    BytesP         Int(10)    Pos(1) INZ(256);
    BytesA         Int(10)    Pos(5) INZ(0);
    MsgID          Char(7)    Pos(9);
    Reserv         Char(1)    Pos(16);
    MsgDta         Char(240)  Pos(17);
  End-Ds;

  //  Figure out if the display session supports 27x132 format
  Dcl-S APIHANDLE    Int(10);
  Dcl-Pr QryModSup Char(1) EXTPROC( 'QsnQryModSup' );
    DspMode        Char(1)    CONST;
    Handle                    OPTIONS( *NOPASS ) LIKE( APIHANDLE  );
    ErrorDS                   OPTIONS( *NOPASS ) LIKE( dsEC );
  End-Pr;

  //  Return Job Attribute Data Structure, Defined Bellow
  Dcl-Pr QUSRJOBI  EXTPGM('QUSRJOBI');
    RcvVar         Char(32766) OPTIONS(*VARSIZE);
    RcvVarLen      Int(10)    CONST;
    Format         Char(8)    CONST;
    QualJob        Char(26)   CONST;
    InternJob      Char(16)   CONST;
    ErrorCode      Char(32766) OPTIONS(*NOPASS:*VARSIZE);
  End-Pr;

  // Data Structure job description, used in QUSRJOBI
  Dcl-Ds dsJob  QUALIFIED;
    BytesRtn       Int(10);
    BytesAvl       Int(10);
    Name           Char(10);
    User           Char(10);
    Number         Char(6);
    Intern         Char(16);
    Status         Char(10);
    Type           Char(1);
    Subtype        Char(1);
    Reserv1        Char(2);
    RunPty         Int(10);
    TimeSlc        Int(10);
    DftWait        Int(10);
    Purge          Char(10);
  End-Ds;

  // SEE IF 27 BY 132 IS OK
  Monitor;
    // CHECK IF JOB IS INTERACTIVE
    APIHANDLE=%size(dsJob);
    QUSRJOBI(dsJob:%size(dsJob):'JOBI0100':'*':*blanks:dsEC);
    If dsJob.TYPE = 'I';
      // CHECK IF TERMINAL HANDLES 27X132 CHARACTER DISPLAY
      If QryModSup('4') <> X'00';
        Return *ON;
      EndIf;
    EndIf;
  On-Error;
  EndMon;

  Return *OFF;

End-Proc;

// *****************************************************************
// #$SQLMessage - Returns the message text for an SQL statement
//
// INPUT: sqlCode
//        sqlErrMc
//
// RETURN: The error message text for the error code
//
Dcl-Proc #$SQLMessage Export;
  Dcl-Pi *n varchar(500);
    sqlCodeIn packed(4) const;
    sqlErrMc char(500) const options(*nopass);
  End-Pi;

  Dcl-S msgId  char(7);
  Dcl-S repData  char(500);
  Dcl-S sqlCode  packed(4);

  If %parms() >= 2;
    repData = sqlErrMc;
  EndIf;

  sqlCode = sqlCodeIn;
  If sqlCode < 0;
    sqlCode *= -1;
  EndIf;
  msgId = 'SQL' + %editc(sqlCode:'X');

  retrieve_MessageFromMsgF(RTVM0300
                                 :%len(RTVM0300)
                                 :'RTVM0300'
                                 :msgId
                                 :'QSQLMSG   QSYS      '
                                 :repData
                                 :%len(%trim(repData))
                                 :'*YES'
                                 :'*YES'
                                 :apiError);

  If apiError.bytesAvailable = 0 and RTVM0300.messageLenRet > 0;
    Return %subst(RTVM0300 : RTVM0300.messageOffset+1
                       : RTVM0300.messageLenRet);
  EndIf;

  Return '*** Expected Message Not Found ***';

End-Proc;


// ***************************************************************
// #$SQLMessageHelp - Returns the messages help text for an SQL statement
//
// INPUT: sqlCode
//        sqlErrMc
//
// RETURN: The error message help text for the error code
//
Dcl-Proc #$SQLMessageHelp Export;
  Dcl-Pi *n varchar(4000);
    sqlCodeIn packed(4) const;
    sqlErrMc char(500) const options(*nopass);
  End-Pi;

  Dcl-S msgId  char(7);
  Dcl-S repData  char(500);
  Dcl-S sqlCode  packed(4);

  If %parms() >= 2;
    repData = sqlErrMc;
  EndIf;

  sqlCode = sqlCodeIn;
  If sqlCode < 0;
    sqlCode *= -1;
  EndIf;
  msgId = 'SQL' + %editc(sqlCode:'X');

  retrieve_MessageFromMsgF(RTVM0300
                                 :%len(RTVM0300)
                                 :'RTVM0300'
                                 :msgId
                                 :'QSQLMSG   QSYS      '
                                 :repData
                                 :%len(%trim(repData))
                                 :'*YES'
                                 :'*YES'
                                 :apiError);

  If apiError.bytesAvailable = 0 and RTVM0300.messageLenRet > 0;
    Return %subst(RTVM0300 : RTVM0300.helpOffset+1
                       : RTVM0300.helpLenRet);
  EndIf;

  Return '*** Expected Message Not Found ***';

End-Proc;


// *****************************************************************
// #$SQLLstStm - return the last sql statement run
Dcl-Proc #$SQLLstStm Export;
  Dcl-Pi *n varchar(10000);
  End-Pi;

  // Retrieve job information:
  Dcl-Pr RtvJobInf extpgm( 'QUSRJOBI' );
    rcvVar char(32767) options( *varsize );
    rcvVarLen int(10) const;
    fmtNme char(8) const;
    jobName_q char(26) const;
    jobIntId char(16) const;
    ErrDs char(32767) options( *nopass: *varsize );
  End-Pr;

  // JOBI0900 format:
  Dcl-Ds JOBI0900 len(65535) qualified inz;
    allData char(65535) pos( 1 );
    SqlStmOfs int(10) pos(77);
    SqlStmLen int(10) pos(81);
  End-Ds;

  // Api error data structure:
  Dcl-Ds ErrorDs qualified;
    BytPro int(10) inz( %size( ErrorDs ));
    BytAvl int(10) inz;
    MsgId char(7);
    *n char(1);
    MsgDta char(512);
  End-Ds;


  RtvJobInf( JOBI0900 : %size( JOBI0900 ) : 'JOBI0900'
                  : '*' : '' : ErrorDs );

  If JOBI0900.SqlStmOfs <> 0  and JOBI0900.SqlStmLen <> 0;
    Return %subst(JOBI0900.allData:JOBI0900.SqlStmOfs:JOBI0900.SqlStmLen);
  Else;
    Return '';
  EndIf;

End-Proc;

// *****************************************************************
// #$SQLMsgId - returns messageid from sqlCode
Dcl-Proc #$SQLMsgId Export;
  Dcl-Pi *n char(7);
    sqlCode int(10);
  End-Pi;

  If sqlCode >= 10000;
    Return 'SQ' + %editc(%dec(%abs(sqlCode):5:0):'X');
  Else;
    Return 'SQL' + %editc(%dec(%abs(sqlCode):4:0):'X');
  EndIf;

End-Proc;


// ****************************************************************
// #$EDTP2 - Edit Phone Number (Alpha)
// Procedure to edit a phone number
// INPUT:  #$PHNO = CHARACTER FIELD CONTAINING NUMBER
// OUTPUT: #$PHNO = EDITED PHONE NUMBER
//
// EXAMPLES
// INPUT        OUTPUT
// 11235551234  123-555-1234     STRIP LEADING 1, FORMAT
// 01235551234  123-555-1234     STRIP LEADING 0, FORMAT
// 1235551234   123-555-1234
// 5551234      555-1234
// 555-1234     555-1234         NO CHANGE
// 555A234      555A234          NO CHANGE SINCE NOT NUMBERS
// 555234       555234           NO CHANGE SINCE NOT LONG ENOUGH
// 123 5551234  123-555-1234     CHANGED, SPACES IGNORED
// 123-555-1234 123-555-1234     CHANGED, DASHES IGNORED
// (123)5551234 123-555-1234     CHANGED, PAREN. IGNORED
//
Dcl-Proc #$EDTP2 EXPORT;
  Dcl-Pi #$EDTP2 Char(20);
    #$PHNO       Char(20)   CONST;
  End-Pi;
  Dcl-Ds phnDs;
    phn Char(1) DIM(20);
  End-Ds;
  Dcl-S PH2          Char(1)    DIM(20);
  Dcl-S x packed(5);
  Dcl-S cnt packed(5);
  Dcl-S hasDigit Ind;
  Dcl-S firstDigit Ind;

  phnDs = #$PHNO;

  // CHECK FOR NON NUMBERIC DATA, IF FOUND GOTO END
  // CHECK FOR AT LEAST ONE DIGIT, IF NOT BLANK OUT AND GOTO END
  // REMOVE BLANKS, DASHES AND PARENTHESIES - SO PH2 ONLY HAS NUMERIC DATA
  //    SO PH2 ONLY HAS NUMERIC DATA WITHOUT LEADING ZEROS
  Clear PH2;
  firstDigit = *Off;
  hasDigit = *Off;
  For x = 1 to 20;
    If PHN(x) <> ' ' and PHN(x) <> '-' and
              PHN(x) <> '(' and PHN(x) <> ')' and
              (PHN(x) < '0' OR PHN(x) > '9');
      Return #$PHNO;
    EndIf;
    If not hasDigit and PHN(x) >= '1'and PHN(x) <= '9';
      hasDigit = *On;
    EndIf;
    If PHN(x) <> ' ' AND PHN(x) <> '-' AND PHN(x) <> '(' and
              PHN(x) <> ')';
      If not firstDigit and PHN(x) <> '0' or firstDigit;
        cnt = cnt + 1;
        PH2(cnt) = phn(x);
        firstDigit = *On;
      EndIf;
    EndIf;
  EndFor;

  // If not digits were found, return blanks
  If not hasDigit;
    Return *blanks;
  EndIf;

  // IF COUNT = 11 AND HAS LEADING ONE, REMOVE
  If cnt = 11 AND PH2(1) = '1';
    Clear phn;
    For x = 1 to 19;
      PH2(x) = PH2(x - 1);
    EndFor;
    PH2(20) = ' ';
    cnt = cnt - 1;
  EndIf;

  // If count = 7 edit like xxx-xxxx
  If cnt = 7;
    phn(1) = PH2(1);
    phn(2) = PH2(2);
    phn(3) = PH2(3);
    phn(4) = '1';
    phn(5) = PH2(4);
    phn(6) = PH2(5);
    phn(7) = PH2(6);
    phn(8) = PH2(7);
  EndIf;

  // IF COUNT = 10 EDIT LIKE XXX-XXX-XXXX
  If cnt = 10;
    phn(1) = PH2(1);
    phn(2) = PH2(2);
    phn(3) = PH2(3);
    phn(4) = '1';
    phn(5) = PH2(4);
    phn(6) = PH2(5);
    phn(7) = PH2(6);
    phn(8) = '-';
    phn(9) = PH2(7);
    phn(10) = PH2(8);
    phn(11) = PH2(9);
    phn(12) = PH2(10);
  EndIf;

  Return phnDs;

End-Proc;


// Converts a dollar amount to readable text, 2 lines of 73 characters
//   INPUT: valu = dollar amount (13.2)
//  OUTPUT: txt1 = first 73 chars of literal
//          txt2 = next  73 chars of literal
//   INPUT: Cents = char(1): 1(dft) = "xx cents",
//                           2      = "xx/100"
Dcl-Proc #$ALPH EXPORT;
  Dcl-Pi #$ALPH;
    valu packed(13:2) value;
    txt1 char(73);
    txt2 char(73);
    pmrCents char(1) const options(*nopass:*omit);
  End-Pi;
  Dcl-S a1 packed(2) DIM(27);
  Dcl-S a2 varchar(9) DIM(27);
  Dcl-S txt varchar(256);
  Dcl-S amt  packed(13:2);
  Dcl-S y    packed(2);
  Dcl-S cents char(1);

  // populate cents options
  If %parms() >= 4 and %addr(pmrCents) <> *null;
    cents = pmrCents;
  Else;
    cents = '1';
  EndIf;

  // fill array used for lookup
  If a1(1) = 0;
    a1(1) = 01;
    a2(1) = 'One';
    a1(2) = 02;
    a2(2) = 'Two';
    a1(3) = 03;
    a2(3) = 'Three';
    a1(4) = 04;
    a2(4) = 'Four';
    a1(5) = 05;
    a2(5) = 'Five';
    a1(6) = 06;
    a2(6) = 'Six';
    a1(7) = 07;
    a2(7) = 'Seven';
    a1(8) = 08;
    a2(8) = 'Eight';
    a1(9) = 09;
    a2(9) = 'Nine';
    a1(10) = 10;
    a2(10) = 'Ten';
    a1(11) = 11;
    a2(11) = 'Eleven';
    a1(12) = 12;
    a2(12) = 'Twelve';
    a1(13) = 13;
    a2(13) = 'Thirteen';
    a1(14) = 14;
    a2(14) = 'Fourteen';
    a1(15) = 15;
    a2(15) = 'Fifteen';
    a1(16) = 16;
    a2(16) = 'Sixteen';
    a1(17) = 17;
    a2(17) = 'Seventeen';
    a1(18) = 18;
    a2(18) = 'Eighteen';
    a1(19) = 19;
    a2(19) = 'Nineteen';
    a1(20) = 20;
    a2(20) = 'Twenty';
    a1(21) = 30;
    a2(21) = 'Thirty';
    a1(22) = 40;
    a2(22) = 'Forty';
    a1(23) = 50;
    a2(23) = 'Fifty';
    a1(24) = 60;
    a2(24) = 'Sixty';
    a1(25) = 70;
    a2(25) = 'Seventy';
    a1(26) = 80;
    a2(26) = 'Eighty';
    a1(27) = 90;
    a2(27) = 'Ninety';
  EndIf;

  Clear txt;
  amt = valu;

  // If the amount is negative add the word Negative set it to positive
  If amt < 0;
    txt += ' ' + 'Negative';
    amt *= -1;
  EndIf;

  // add billions part and remove form amt
  If amt >= 1000000000;
    // add 21-99 billions (01-99m) just the ninty, eighty, seventy,.. part
    y = %int(amt/10000000000) * 10;
    If y >= 20;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y * 1000000000;
    EndIf;
    // add 1-20 Trillion
    y = %int(amt/1000000000);
    If y <> 0;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y * 1000000000;
    EndIf;
    txt += ' Billion';
  EndIf;

  // add millions part and remove from amt
  If amt >= 1000000;
    // add hundred millions  (100m-999m)
    y = %int(amt/100000000);
    If y <> 0;
      txt += ' ' + a2(%lookup(y:a1)) + ' Hundred';
      amt -= y * 100000000;
    EndIf;
    // add 21-99 millions (01-99m) just the ninty, eighty, seventy,.. part
    y = %int(amt/10000000) * 10;
    If y >= 20;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y * 1000000;
    EndIf;
    // add 1-20 million
    y = %int(amt/1000000);
    If y <> 0;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y * 1000000;
    EndIf;
    txt+= ' Million';
  EndIf;

  // add thousands part and remove from amt
  If amt >= 1000;
    // add hundred thousands
    y = %int(amt/100000);
    If y <> 0;
      txt += ' ' + a2(%lookup(y:a1)) + ' Hundred';
      amt -= y * 100000;
    EndIf;
    // add 21-99 thousand, just the ninty, eighty, seventy,.. part
    y = %int(amt/10000) * 10;
    If y >= 20;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y *1000;
    EndIf;
    // add 1 - 20 thousand
    y = %int(amt/1000);
    If y <> 0;
      txt += ' ' + a2(%lookup(y:a1));
      amt -= y * 1000;
    EndIf;
    txt+= ' Thousand';
  EndIf;

  // add hundreds
  y = %int(amt/100);
  If y <> 0;
    txt += ' ' + a2(%lookup(y:a1)) + ' Hundred';
    amt -= y * 100;
  EndIf;

  // add 21-99, just the ninty, eighty, seventy,.. part
  y = %int(amt/10) * 10;
  If y >= 20;
    txt += ' ' + a2(%lookup(y:a1));
    amt -= y;
  EndIf;

  // add 1 - 20
  y = %int(amt);
  If y <> 0;
    txt += ' ' + a2(%lookup(y:a1));
    amt -= y;
  EndIf;

  // if the original amount was less than a dollar add the word
  // zero because none of the above added anything
  If valu < 1 and valu > -1;
    txt += 'zero';
  EndIf;

  // Add dollars
  txt += ' Dollars and';

  // add the cents part
  If cents = '2';
    txt += ' ' + %editc(%dec(%int(amt*100):2:0):'X') + '/100';
  Else;
    If amt = 0;
      txt += ' zero';
    Else;
      // add 21-99 cents, just the ninty, eight,.. part
      y = %int(amt*10) * 10;
      If y >= 20;
        txt += ' ' + a2(%lookup(y:a1));
        amt -= y/100;
      EndIf;
      // add 1 - 20 cent part
      y = amt*100;
      If y <> 0;
        txt += ' ' + a2(%lookup(y:a1));
        amt -= y/100;
      EndIf;
    EndIf;
    txt = %trim(txt) + ' Cents'; // also removes leading blank
  EndIf;

  // split text to txt1 and txt2 do not split in a word
  If %len(txt) <= 73;
    txt1 = txt;
    txt2 = '';
  Else;
    y = %scanr(' ': txt : 1 : 74);
    txt1 = %subst(txt:1:y);
    txt2 = %trim(%subst(txt:y));
  EndIf;

  Return;
End-Proc;

// See if the current user has a specific role
//   INPUT: rolNme = up to 50 role names
//  OUTPUT: *on./*off, *on if theuser has the role, otherwise *off
Dcl-Proc #$HasRole EXPORT;
  Dcl-Pi *n Ind;
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
  End-Pi;
  Dcl-S found ind;
  Dcl-S parms packed(3);
  Dcl-S sqlStm varchar(2000);

  parms = %parms;

  sqlStm = 'Select ''1'' +
                     From USRROL +
                     Join USRMST on USRMST.usrMstIdn = USRROL.usrMStIdn +
                     Join ROLMST on ROLMST.rolMstIdn = USRROL.rolMStIdn +
                     where usrPrf = ''' + %trim(user) + ''' +
                       and rolNme in (''Super User''';


  // if a parameter is passed, set it's value in roles
  If %parms >= 1 and %addr(rolNme01) <> *null;
    sqlStm += ',''' + %trim(rolNme01) + '''';
  EndIf;
  If %parms >= 2 and %addr(rolNme02) <> *null;
    sqlStm += ',''' + %trim(rolNme02) + '''';
  EndIf;
  If %parms >= 3 and %addr(rolNme03) <> *null;
    sqlStm += ',''' + %trim(rolNme03) + '''';
  EndIf;
  If %parms >= 4 and %addr(rolNme04) <> *null;
    sqlStm += ',''' + %trim(rolNme04) + '''';
  EndIf;
  If %parms >= 5 and %addr(rolNme05) <> *null;
    sqlStm += ',''' + %trim(rolNme05) + '''';
  EndIf;
  If %parms >= 6 and %addr(rolNme06) <> *null;
    sqlStm += ',''' + %trim(rolNme06) + '''';
  EndIf;
  If %parms >= 7 and %addr(rolNme07) <> *null;
    sqlStm += ',''' + %trim(rolNme07) + '''';
  EndIf;
  If %parms >= 8 and %addr(rolNme08) <> *null;
    sqlStm += ',''' + %trim(rolNme08) + '''';
  EndIf;
  If %parms >= 9 and %addr(rolNme09) <> *null;
    sqlStm += ',''' + %trim(rolNme09) + '''';
  EndIf;
  If %parms >= 10 and %addr(rolNme10) <> *null;
    sqlStm += ',''' + %trim(rolNme10) + '''';
  EndIf;
  If %parms >= 11 and %addr(rolNme11) <> *null;
    sqlStm += ',''' + %trim(rolNme11) + '''';
  EndIf;
  If %parms >= 12 and %addr(rolNme12) <> *null;
    sqlStm += ',''' + %trim(rolNme12) + '''';
  EndIf;
  If %parms >= 13 and %addr(rolNme13) <> *null;
    sqlStm += ',''' + %trim(rolNme13) + '''';
  EndIf;
  If %parms >= 14 and %addr(rolNme14) <> *null;
    sqlStm += ',''' + %trim(rolNme14) + '''';
  EndIf;
  If %parms >= 15 and %addr(rolNme15) <> *null;
    sqlStm += ',''' + %trim(rolNme15) + '''';
  EndIf;
  If %parms >= 16 and %addr(rolNme16) <> *null;
    sqlStm += ',''' + %trim(rolNme16) + '''';
  EndIf;
  If %parms >= 17 and %addr(rolNme17) <> *null;
    sqlStm += ',''' + %trim(rolNme17) + '''';
  EndIf;
  If %parms >= 18 and %addr(rolNme18) <> *null;
    sqlStm += ',''' + %trim(rolNme18) + '''';
  EndIf;
  If %parms >= 19 and %addr(rolNme19) <> *null;
    sqlStm += ',''' + %trim(rolNme19) + '''';
  EndIf;
  If %parms >= 20 and %addr(rolNme20) <> *null;
    sqlStm += ',''' + %trim(rolNme20) + '''';
  EndIf;
  If %parms >= 21 and %addr(rolNme21) <> *null;
    sqlStm += ',''' + %trim(rolNme21) + '''';
  EndIf;
  If %parms >= 22 and %addr(rolNme22) <> *null;
    sqlStm += ',''' + %trim(rolNme22) + '''';
  EndIf;
  If %parms >= 23 and %addr(rolNme23) <> *null;
    sqlStm += ',''' + %trim(rolNme23) + '''';
  EndIf;
  If %parms >= 24 and %addr(rolNme24) <> *null;
    sqlStm += ',''' + %trim(rolNme24) + '''';
  EndIf;
  If %parms >= 25 and %addr(rolNme25) <> *null;
    sqlStm += ',''' + %trim(rolNme25) + '''';
  EndIf;
  If %parms >= 26 and %addr(rolNme26) <> *null;
    sqlStm += ',''' + %trim(rolNme26) + '''';
  EndIf;
  If %parms >= 27 and %addr(rolNme27) <> *null;
    sqlStm += ',''' + %trim(rolNme27) + '''';
  EndIf;
  If %parms >= 28 and %addr(rolNme28) <> *null;
    sqlStm += ',''' + %trim(rolNme28) + '''';
  EndIf;
  If %parms >= 29 and %addr(rolNme29) <> *null;
    sqlStm += ',''' + %trim(rolNme29) + '''';
  EndIf;
  If %parms >= 30 and %addr(rolNme30) <> *null;
    sqlStm += ',''' + %trim(rolNme30) + '''';
  EndIf;
  If %parms >= 31 and %addr(rolNme31) <> *null;
    sqlStm += ',''' + %trim(rolNme31) + '''';
  EndIf;
  If %parms >= 32 and %addr(rolNme32) <> *null;
    sqlStm += ',''' + %trim(rolNme32) + '''';
  EndIf;
  If %parms >= 33 and %addr(rolNme33) <> *null;
    sqlStm += ',''' + %trim(rolNme33) + '''';
  EndIf;
  If %parms >= 34 and %addr(rolNme34) <> *null;
    sqlStm += ',''' + %trim(rolNme34) + '''';
  EndIf;
  If %parms >= 35 and %addr(rolNme35) <> *null;
    sqlStm += ',''' + %trim(rolNme35) + '''';
  EndIf;
  If %parms >= 36 and %addr(rolNme36) <> *null;
    sqlStm += ',''' + %trim(rolNme36) + '''';
  EndIf;
  If %parms >= 37 and %addr(rolNme37) <> *null;
    sqlStm += ',''' + %trim(rolNme37) + '''';
  EndIf;
  If %parms >= 38 and %addr(rolNme38) <> *null;
    sqlStm += ',''' + %trim(rolNme38) + '''';
  EndIf;
  If %parms >= 39 and %addr(rolNme39) <> *null;
    sqlStm += ',''' + %trim(rolNme39) + '''';
  EndIf;
  If %parms >= 40 and %addr(rolNme40) <> *null;
    sqlStm += ',''' + %trim(rolNme40) + '''';
  EndIf;
  If %parms >= 41 and %addr(rolNme41) <> *null;
    sqlStm += ',''' + %trim(rolNme41) + '''';
  EndIf;
  If %parms >= 42 and %addr(rolNme42) <> *null;
    sqlStm += ',''' + %trim(rolNme42) + '''';
  EndIf;
  If %parms >= 43 and %addr(rolNme43) <> *null;
    sqlStm += ',''' + %trim(rolNme43) + '''';
  EndIf;
  If %parms >= 44 and %addr(rolNme44) <> *null;
    sqlStm += ',''' + %trim(rolNme44) + '''';
  EndIf;
  If %parms >= 45 and %addr(rolNme45) <> *null;
    sqlStm += ',''' + %trim(rolNme45) + '''';
  EndIf;
  If %parms >= 46 and %addr(rolNme46) <> *null;
    sqlStm += ',''' + %trim(rolNme46) + '''';
  EndIf;
  If %parms >= 47 and %addr(rolNme47) <> *null;
    sqlStm += ',''' + %trim(rolNme47) + '''';
  EndIf;
  If %parms >= 48 and %addr(rolNme48) <> *null;
    sqlStm += ',''' + %trim(rolNme48) + '''';
  EndIf;
  If %parms >= 49 and %addr(rolNme49) <> *null;
    sqlStm += ',''' + %trim(rolNme49) + '''';
  EndIf;
  If %parms >= 50 and %addr(rolNme50) <> *null;
    sqlStm += ',''' + %trim(rolNme50) + '''';
  EndIf;

  sqlStm += ') and USRROL.acvRow = ''1'' +
                       and USRROL.rolApr = ''1''';

  Clear found;
  Exec SQL Prepare hasRoleStm From :sqlStm;
  Exec sql Declare hasRoleCrs Cursor for hasRoleStm;
  Exec SQL Open hasRoleCrs;
  Exec SQL Fetch NExt from hasRoleCrs into :found;
  Exec SQL Close hasRoleCrs;

  Return found;

End-Proc;


// #$ENVNME - Returns the current environments name
//
// Examples:
//
// Dcl-S envNme char(50);
// envNme = #$envNme();
Dcl-Proc #$envNme EXPORT;
  Dcl-Pi *N  char(50);
  End-Pi;

  // Message File used for retrieving message
  Dcl-Ds msgF;
    msgFile    char(10) Inz('ENVIRONMNT');
    msgFileLib char(10) Inz('*LIBL');
  End-Ds;

  Dcl-Ds APIErrorCode Qualified;
    BytesProvided Int(10) INZ(%size(APIErrorCode));  // Number of bytes that caller provides
    BytesAvailable Int(10) INZ(0);                   // Number of bytes for API to return to
    ExceptionID Char(7);                             // The identifier of the error condition
    Reserved Char(1);                                // 1-byte reserved field
    ExceptionData char(32767);                       // Data associated with the exception ID
  End-Ds;

  // Prototype for QMHRTVM API
  Dcl-Pr QMHRTVM ExtPgm;
    MsgInfo char(9999999) options(*varsize);       // Variable that recives information
    MsgInfoLen Int(10) const;                      // Describes the length of the variable
    FormatName Char(8) const;                      // Message information Format
    MsgID char(7) const;                           // Message Identifier
    MsgFileName char(20) const;                    // Library Name Char(10) and File Name  Char(10)
    ReplData char(10000) options(*varsize) const;  // Values inserted into message variable
    ReplDataLen Int(10) const;                     // Length of replacement data
    ReplSubVal Char(10) const;                     // *YES - use replacement data, *NO - opposite
    ReplFormatChar Char(10) const;
    ErrorCode LikeDS(APIErrorCode);                // Generic API Error Code
    // Option Group 1
    RetrieveOption Char(10) options(*nopass);
    CCSIdentifier Int(10) options(*nopass);
    CCSReplData Int(10) options(*nopass);
  End-Pr;

  // Message format data structure RTV0100 Format
  Dcl-Ds RTVM0100 Qualified INZ;
    BytRtn Int(10);
    BytAvl Int(10);
    RtnMsgLen Int(10);
    RtnMsgAvl Int(10);
    RtnHlpLen Int(10);
    RtnHlpAvl Int(10);
    Buffer char(32767);
  End-Ds;

  Dcl-S rtnMsg Char(50);

  QMHRTVM(RTVM0100:%size(RTVM0100):'RTVM0100':'AAA0000'
                         :msgF:'':0:'*NO':'*NO':APIErrorCode);

  // Check if API found an error:
  If APIErrorCode.bytesAvailable > 0;
    rtnMsg = '';
  ElseIf RTVM0100.RtnMsgLen > 0;
    rtnMsg = %subst( RTVM0100.Buffer : 1 : RTVM0100.RtnMsgLen);
  EndIf;

  Return rtnMsg;

End-Proc;


// #$GETKEYS - Returns file key fields
//
// Parameters
//  Input: File libray Char(10)
//         File name Char(10)
//  Output: String ocntainng key list
//
// Examples:
//
// Dcl-S keyLst char(60);
// keyLst = #$GetKeys('APLDCT':'DCTMST');
// after key lsit = "DCTLIB, DCTNME"
Dcl-Proc #$GetKeys EXPORT;
  Dcl-Pi *N  varchar(100);
    fleLib char(10);
    fleNme char(10);
  End-Pi;
  Dcl-S keyLst varchar(100);
  Dcl-S X   packed(5);
  Dcl-S y   packed(5);
  Dcl-Ds errorDs Len(116) INZ;
    bytesPrv       Bindec(9)  Pos(1) INZ(116);
    bytesAvl       Bindec(9)  Pos(5);
    messageId      Char(7)    Pos(9);
    err###         Char(1)    Pos(16);
    messageDta     Char(100)  Pos(17);
  End-Ds;
  Dcl-Ds receiveVar len(32767);
    allData        char(32767) Pos(1);
    fileType       Char(1)     Pos(9);
    attribs        Char(1)     Pos(10);
    nbrOfMbrs      Bindec(4)   Pos(48);
    nbrOfFmts      Bindec(4)   Pos(62);
    filDsc         Char(40)    Pos(85);
    dbFileOff      Bindec(9)   Pos(317);
    dbPhyOff       Bindec(9)   Pos(365);
    dbJrnOff       Bindec(9)   Pos(379);
  End-Ds;
  Dcl-Ds findSelDs Len(139);
    otherStuff     Char(116)  Pos(1);
    nbrOfKeys      Bindec(4)  Pos(117);
    keyOffSet      Bindec(9)  Pos(136);
  End-Ds;
  Dcl-Ds *N;
    spaceLen       Bindec(9)  Pos(1);
    receiveLen     Bindec(9)  Pos(5) inz(32767);
    messageKey     Bindec(9)  Pos(9);
    msgDtaLen      Bindec(9)  Pos(13);
    msgQueNbr      Bindec(9)  Pos(17);
  End-Ds;
  // Dcl-S RECEIVELEN   int(10);
  Dcl-S QualFle      Char(20);
  Dcl-S fileFormat   Char(8) Inz('FILD0100');
  Dcl-S entryFmt     Char(10);
  Dcl-S override     Char(1) inz('0');
  Dcl-S s            Packed(7:0);
  Dcl-S i            Packed(7:0);
  Dcl-S system       Char(10) Inz('*FILETYPE');
  Dcl-S formatType   Char(10) Inz('*EXT');

  // IBM API to Retrieve a Database File Description
  // https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_72/apis/qdbrtvfd.htm
  Dcl-Pr IBMAPI_RtvFileDesc         extpgm('QDBRTVFD');
    filedesc              char(32767) options(*varsize);
    FileDscL              int(10)   const;
    FileQNam              char(20)  const;
    FileDFmt              char(8)   const;
    fileName              char(20)  const;
    FileRFmt              char(10)  const;
    FileOvrP              char(1)   const;
    FileSysN              char(10)  const;
    FileFmtT              char(10)  const;
    FileErrC              likeds(errorDs);
  End-Pr;

  Clear keyLst;
  QualFle = fleNme + fleLib;
  IBMAPI_RtvFileDesc(receiveVar:receiveLen:QualFle:fileFormat
                      :QualFle:entryFmt:override:system:formatType:errorDs);

  // If there is a message just get out
  If messageId <> *BLANKS;
    keyLst = 'Error ' + messageId + '.';
    Return keyLst;
  EndIf;

  // If there are no keys
  If dbFileOff = 0;
    keyLst = 'Not Keyed.';
    Return keyLst;
  EndIf;

  i = dbFileOff;
  For X = 1 to nbrOfFmts;
    findSelDs = %subst(receiveVar:i:139);
    s = (keyOffSet + 1);
    // do for number of key fields
    For y = 1 to nbrOfKeys;
      If NOT *In77;
        keyLst=%trim(%subst(receiveVar:s:10));
      Else;
        keyLst=%trim(keyLst) + ', ' +%trim(%subst(receiveVar:s:10));
      EndIf ;
      *In77 = *On;
      s = (s + 32);
    EndFor;
    i = (i + 160);
  EndFor;

  Return keyLst;

End-Proc;

// ****************************************************************
// Debug batch jobs
//
// Need to pass the user to wait on and the program name
// to debug. Put the call to #$DEBUG
//
Dcl-Proc #$DbgBch EXPORT;
  Dcl-Pi *n;
    user          char(10) const;
  End-Pi;
  Dcl-S tmpDqNm   char(10);
  Dcl-S tmpDqLb   char(10);
  Dcl-S calPgm    char(10);
  Dcl-S calPgmLib char(10);
  Dcl-S queuedata char(1);
  // Prototype for receive data queue api
  Dcl-Pr RCVDTAQ  ExtPgm('QRCVDTAQ');
    dataQueue     char(10)    CONST;
    dataQueueLib  char(10)    CONST;
    dataQueueLen  packed(5:0) CONST;
    queuedata     char(32766) CONST OPTIONS(*VARSIZE);
    dataWait      packed(5:0) CONST;
  End-Pr;

  // get calling program name
  #$CallingPgm(calPgm:calPgmLib);

  // Build temporary data queue name
  tmpDqNm='#$DB' + %char(psdsJobNbr);
  tmpDqLb = 'APLLIB   ';

  // Delete from temp file if exists
  Exec SQL Delete From APLLIB/DBGBCH Where dbgUser=:user;
  #$CMD('DLTDTAQ ' + %trim(tmpDqLb) +'/' + %trim(tmpDqNm):1);

  // Create entry in dbgbch
  Exec SQL Insert Into APLLIB.DBGBCH
                 (dbgUser, dbgJbNm, dbgJbUs, dbgJbNo,
                  dbgDqNm, dbgDqLb, dbgPgm, dbgPgmLib)
          VALUES (:user, :psdsJobNam, :psdsUsrNam, :psdsJobNbr, :tmpDqNm,
                  :tmpDqLb, :calPgm, :calPgmLib);

  // Create data queue
  #$CMD('CRTDTAQ '+%trim(tmpDqLb)+'/'+%trim(tmpDqNm)+' MAXLEN(1)');

  // Wait on data queue entry for up to 5 minutes
  RCVDTAQ (tmpDqNm  : tmpDqLb : 30 : queuedata  : 300);

  // Delete from temp file if exists
  Exec SQL Delete From APLLIB/DBGBCH Where dbgUser=:user;
  #$CMD('DLTDTAQ ' + %trim(tmpDqLb) +'/' + %trim(tmpDqNm):1);

  // Just continue after the queue is answered
  Return;

End-Proc;


// ****************************************************************
// Get the calling program, name and library
// ****************************************************************
Dcl-Proc #$CallingPgm Export;
  Dcl-Pi *n;
    pgmNme char(10);
    pgmLib char(10);
  End-Pi;

  // Retrive call stack info
  Dcl-Pr RtvCallStk  EXTPGM('QWVRCSTK');
    *N             Char(2000);
    *N             Int(10);
    *N             Char(8)    CONST;
    *N             Char(56);
    *N             Char(8)    CONST;
    *N             Char(15);
  End-Pr;

  Dcl-Ds var Len(2000);
    bytRtn         Int(10);
    bytAvl         Int(10);
    entries        Int(10);
    offset         Int(10);
    entryCount     Int(10);
  End-Ds;

  Dcl-S varLen      Int(10)    INZ(%size(var));

  Dcl-S apiErr      Char(15);
  Dcl-S stkCnt      packed(1);
  Dcl-S count       packed(2);

  Dcl-Ds jobIdInf;
    jidQName       Char(26)   INZ('*');
    jidIntID       Char(16);
    jidRes3        Char(2)    INZ(*LOVAL);
    jidThreadInd   Int(10)    INZ(1);
    jidThread      Char(8)    INZ(*LOVAL);
  End-Ds;

  Dcl-Ds entry Len(256) qualified;
    entryLen  Int(10);
    pgmNme    Char(10) pos(25);
    pgmLib    Char(10) pos(35) ;
  End-Ds;

  If %subst(pgmNme:1:1) > 'Z';
    stkCnt = %dec(%subst(pgmNme:1:1):1:0);
  Else;
    stkCnt = 4;
  EndIf;

  RtvCallStk(var:varLen:'CSTK0100':jobIdInf :'JIDF0100':apiErr);
  For count = 1 to entryCount;
    entry = %subst(var:offset + 1);
    offset = offset + entry.entryLen;
    If count = stkCnt;
      pgmNme = entry.pgmNme;
      pgmLib = entry.pgmLib;
    EndIf;
  EndFor;

  Return;

End-Proc;


// ****************************************************************
// Retrieve Member Description
Dcl-Proc #$RtvMbrD Export;
  Dcl-Pi *n char(50);
    lib char(10) const;
    fle char(10) const;
    mbr char(10) const;
  End-Pi;

  // Data structure for format MBRD0100
  Dcl-Ds MBRD0100 qualified;
    bytesReturned int(10) inz(134);
    bytesAvailable int(10);
    fleNme char(10);
    libNme char(10);
    mbrNme char(10);
    fleAtr char(10);
    srcTyp char(10);
    crtDtm char(13);
    mntDtm char(13);
    mbrTxt char(50);
    srcFle char(1);
  End-Ds;

  // IBM API to Retrieve a Member's Description
  Dcl-Pr IBMAPI_RtvMbrDesc          extpgm('QUSRMBRD');
    MbrDesc               likeds(MBRD0100)    options(*varsize);
    MbrDscL               int(10)   const;
    MbrDFmt               char(8)   const;
    MbrFile               char(20)  const;
    MbrName               char(10)  const;
    MbrOvrP               char(1)   const;
    // optional parm group 1
    MbrErrC               likeds(apiError)     options(*nopass:*varsize);
    // optional parm group 2
    MbrFndP               char(1)   const     options(*nopass);
  End-Pr;

  IBMAPI_RtvMbrDesc(MBRD0100: %len(MBRD0100): 'MBRD0100': fle + lib: mbr: '0' : apiError:'0');

  Return MBRD0100.mbrTxt;

End-Proc;
