**free
// *****************************************************************
// Easy Excel File Parser
//
// See XLPSRVB1 and B2 for examples.
//
// This program can be rebuilt live as long as the functions
// and parameters do not change. You can use these commands
// to build it.
//
// CRTSQLRPGI OBJ(QTEMP/XLPSRVV1) SRCFILE(APLLIB/QSRC)
//            OBJTYPE(*MODULE) DBGVIEW(*SOURCE)
// CRTSRVPGM  SRVPGM(APLLIB/XLPSRVV1) MODULE(QTEMP/XLPSRVV1)
//            TEXT('Easy Excel File Parser')
//            BNDSRVPGM((APLLIB/XLPARSER4)) EXPORT(*SRCFILE)
//            srcfile(APLLIB/QSRC) srcmbr(XLPSRVN1) stgmdl(*inherit)
// DLTMOD     MODULE(QTEMP/XLPSRVV1)
//
// ****************************************************************

Ctl-Opt NOMAIN;
/COPY APLLIB/QSRC,XLPSRVV1PR
// COPIES ALL PROTOTYPES USED IN SCOTT KLEMENTS XLPARSE TOOL
// XLPARSE USES THE APACHE POI SOFTWARE COMES FROM THE FOLLOWING WEBSITE
// https://www.scottklement.com/poi/
/COPY APLLIB/QSRC,XLPARSV1PR

Dcl-Ds psds  psds; //Pgm status DS
  psdsdata       Char(429); //The data
  psdsExcDta     Char(80)   OVERLAY(PSDSDATA:091);
End-Ds;
Dcl-S #$COL        Packed(3:0);
Dcl-Ds FLDSDS;
  FLD001         Char(124);
  FLD002         Char(124);
  FLD003         Char(124);
  FLD004         Char(124);
  FLD005         Char(124);
  FLD006         Char(124);
  FLD007         Char(124);
  FLD008         Char(124);
  FLD009         Char(124);
  FLD010         Char(124);
  FLD011         Char(124);
  FLD012         Char(124);
  FLD013         Char(124);
  FLD014         Char(124);
  FLD015         Char(124);
  FLD016         Char(124);
  FLD017         Char(124);
  FLD018         Char(124);
  FLD019         Char(124);
  FLD020         Char(124);
  FLD021         Char(124);
  FLD022         Char(124);
  FLD023         Char(124);
  FLD024         Char(124);
  FLD025         Char(124);
  FLD026         Char(124);
  FLD027         Char(124);
  FLD028         Char(124);
  FLD029         Char(124);
  FLD030         Char(124);
  FLD031         Char(124);
  FLD032         Char(124);
  FLD033         Char(124);
  FLD034         Char(124);
  FLD035         Char(124);
  FLD036         Char(124);
  FLD037         Char(124);
  FLD038         Char(124);
  FLD039         Char(124);
  FLD040         Char(124);
  FLD041         Char(124);
  FLD042         Char(124);
  FLD043         Char(124);
  FLD044         Char(124);
  FLD045         Char(124);
  FLD046         Char(124);
  FLD047         Char(124);
  FLD048         Char(124);
  FLD049         Char(124);
  FLD050         Char(124);
  FLD051         Char(124);
  FLD052         Char(124);
  FLD053         Char(124);
  FLD054         Char(124);
  FLD055         Char(124);
  FLD056         Char(124);
  FLD057         Char(124);
  FLD058         Char(124);
  FLD059         Char(124);
  FLD060         Char(124);
  FLD061         Char(124);
  FLD062         Char(124);
  FLD063         Char(124);
  FLD064         Char(124);
  FLD065         Char(124);
  FLD066         Char(124);
  FLD067         Char(124);
  FLD068         Char(124);
  FLD069         Char(124);
  FLD070         Char(124);
  FLD071         Char(124);
  FLD072         Char(124);
  FLD073         Char(124);
  FLD074         Char(124);
  FLD075         Char(124);
  FLD076         Char(124);
  FLD077         Char(124);
  FLD078         Char(124);
  FLD079         Char(124);
  FLD080         Char(124);
  FLD081         Char(124);
  FLD082         Char(124);
  FLD083         Char(124);
  FLD084         Char(124);
  FLD085         Char(124);
  FLD086         Char(124);
  FLD087         Char(124);
  FLD088         Char(124);
  FLD089         Char(124);
  FLD090         Char(124);
  FLD091         Char(124);
  FLD092         Char(124);
  FLD093         Char(124);
  FLD094         Char(124);
  FLD095         Char(124);
  FLD096         Char(124);
  FLD097         Char(124);
  FLD098         Char(124);
  FLD099         Char(124);
  FLD100         Char(124);
End-Ds;
Dcl-Ds FLDSDS2;
  FLDS Char(124)  DIM(100) POS(1);
End-Ds;

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// ******************************************************************
//
//  These function are used to read Excel files in the IFS
//
//    XLPOPEN  = Opens an Excel File and Processes It
//    XLPREAD  = Reads the Next Row
//    XLPNEXT  = Reads the Next Field
//    XLPCLOSE = Preforms Some Cleanup
//
//  See Example program XLPTS for specifics
//
// ******************************************************************
// **************************************************************
// XLPOPEN - Process a new Excel File
// **************************************************************
// THIS PROCEDURE OPENS AN EXCEL FILE AND PROCESSES IT INTO
// A TEMP FILE.
//
// The temp file is QTEMP/XLPSRVWK.
//
// **************************************************************
Dcl-Proc XLPOPEN EXPORT;
  Dcl-Pi *N Zoned(1:0);
    #$PATH         Varchar(1024) CONST;
  End-Pi;
  Dcl-S sqlStm  char(1024);

  Exec SQL SET OPTION COMMIT=*NONE;

  // SETUP A TEMPORARY WORK FILE IN QTEMP
  Exec SQL Drop Table QTEMP/XLPSRVWK;
  Exec SQL Create or Replace Table QTEMP/XLPSRVWK (
          FLD001 char(124),
          FLD002 char(124),
          FLD003 char(124),
          FLD004 char(124),
          FLD005 char(124),
          FLD006 char(124),
          FLD007 char(124),
          FLD008 char(124),
          FLD009 char(124),
          FLD010 char(124),
          FLD011 char(124),
          FLD012 char(124),
          FLD013 char(124),
          FLD014 char(124),
          FLD015 char(124),
          FLD016 char(124),
          FLD017 char(124),
          FLD018 char(124),
          FLD019 char(124),
          FLD020 char(124),
          FLD021 char(124),
          FLD022 char(124),
          FLD023 char(124),
          FLD024 char(124),
          FLD025 char(124),
          FLD026 char(124),
          FLD027 char(124),
          FLD028 char(124),
          FLD029 char(124),
          FLD030 char(124),
          FLD031 char(124),
          FLD032 char(124),
          FLD033 char(124),
          FLD034 char(124),
          FLD035 char(124),
          FLD036 char(124),
          FLD037 char(124),
          FLD038 char(124),
          FLD039 char(124),
          FLD040 char(124),
          FLD041 char(124),
          FLD042 char(124),
          FLD043 char(124),
          FLD044 char(124),
          FLD045 char(124),
          FLD046 char(124),
          FLD047 char(124),
          FLD048 char(124),
          FLD049 char(124),
          FLD050 char(124),
          FLD051 char(124),
          FLD052 char(124),
          FLD053 char(124),
          FLD054 char(124),
          FLD055 char(124),
          FLD056 char(124),
          FLD057 char(124),
          FLD058 char(124),
          FLD059 char(124),
          FLD060 char(124),
          FLD061 char(124),
          FLD062 char(124),
          FLD063 char(124),
          FLD064 char(124),
          FLD065 char(124),
          FLD066 char(124),
          FLD067 char(124),
          FLD068 char(124),
          FLD069 char(124),
          FLD070 char(124),
          FLD071 char(124),
          FLD072 char(124),
          FLD073 char(124),
          FLD074 char(124),
          FLD075 char(124),
          FLD076 char(124),
          FLD077 char(124),
          FLD078 char(124),
          FLD079 char(124),
          FLD080 char(124),
          FLD081 char(124),
          FLD082 char(124),
          FLD083 char(124),
          FLD084 char(124),
          FLD085 char(124),
          FLD086 char(124),
          FLD087 char(124),
          FLD088 char(124),
          FLD089 char(124),
          FLD090 char(124),
          FLD091 char(124),
          FLD092 char(124),
          FLD093 char(124),
          FLD094 char(124),
          FLD095 char(124),
          FLD096 char(124),
          FLD097 char(124),
          FLD098 char(124),
          FLD099 char(124),
          FLD100 char(124)
       );


  // CLEAR THE ROW AND COLUMN COUNTERS
  Clear XLPROWS;
  Clear XLPCOLS;
  Clear XLPROW;
  Clear XLPCOL;

  // SETUP THE NOTIFICATION PROCEDURES
  xlparse_notify( %paddr(XLPSTR) : %paddr(XLPEND) );
  If xlparse_workbook(#$PATH:%paddr(XLPNUM):%paddr(XLPCHR):*NULL) <> 0;
    Return 1;
  EndIf;

  // THIS DISABLES NOTIFICATIONS
  xlparse_notify( *NULL: *NULL );

  // SETUP AN SQL STATMENT TO READ THE RECORDS, CREATE A CURSOR AND OPEN
  sqlStm = 'SELECT * FROM QTEMP.XLPSRVWK';
  Exec SQL PREPARE SQL FROM :sqlStm;
  Exec SQL DECLARE SQLCRS CURSOR FOR SQL;
  Exec SQL OPEN SQLCRS;

  Return 0;

End-Proc;


// *************************************************************
// XLPCHR - PROCESS CHARACTER CELL
// *************************************************************
// THIS IS CALLED ONCE FOR EACH CHARACTER CELL IN THE
// SPREADSHEET. IT POPULATES THE GLOBAL VARIBABLES FOR EACH
// CELL READ.
// *************************************************************
Dcl-Proc XLPCHR;
  Dcl-Pi *N Ind;
    SHEET          Varchar(1024)  CONST;
    ROW            Int(10)    Value;
    COLUMN         Int(5)     Value;
    Value          Varchar(32767)  CONST;
  End-Pi;

  // SAVE BIGGEST ROW
  If ROW+1>XLPROWS;
    XLPROWS = ROW + 1;
  EndIf;

  // SAVE BIGGEST COLUMN
  If COLUMN+1>XLPCOLS;
    XLPCOLS = COLUMN + 1;
  EndIf;

  // SAVE VALUE
  FLDS(COLUMN+1)=%trim(Value);

  Return *OFF;

End-Proc;


// **************************************************************
// XLPNUM - PROCESS NUMERIC CELL
// **************************************************************
// THIS IS CALLED ONCE FOR EACH NUMERIC CELL IN THE
// SPREADSHEET. IT POPULATES THE GLOBAL VARIBABLES FOR EACH
// CELL READ.
// **************************************************************
Dcl-Proc XLPNUM;
  Dcl-Pi *N Ind;
    SHEET          Varchar(1024)  CONST;
    ROW            Int(10)    Value;
    COLUMN         Int(5)     Value;
    Value          Float(8)   Value;
  End-Pi;
  Dcl-S VALUE2       Packed(25:10);

  // SAVE BIGGEST ROW
  If ROW+1>XLPROWS;
    XLPROWS = ROW + 1;
  EndIf;

  // SAVE BIGGEST COLUMN
  If COLUMN+1>XLPCOLS;
    XLPCOLS = COLUMN + 1;
  EndIf;

  // SAVE VALUE
  VALUE2 = Value;
  FLDS(COLUMN+1)=%trim(%char(VALUE2));

  Return *OFF;

End-Proc;


// **************************************************************
// XLPSTR - PROCESS NEW ROW
// **************************************************************
// THIS IS CALLED WHEN A NEW ROW IS STARTED
// **************************************************************
Dcl-Proc XLPSTR;
  Dcl-Pi *N;
    SHEET          Varchar(1024)  CONST;
    ROW            Int(10)    VALUE;
  End-Pi;

  // CLEAR OUTPT RECORD
  Clear   FLDS;

End-Proc;

// **************************************************************
// XLPEND - PROCESS END OF ROW
// **************************************************************
// THIS IS CALLED WHEN A THE LAST CELL IN A ROW IS PROCESSED
// IT JUST RIGHTS THE RECORD TO THE OUTPUT FILE
// **************************************************************
Dcl-Proc XLPEND;
  Dcl-Pi *N;
    SHEET          Varchar(1024)  CONST;
    ROW            Int(10)    VALUE;
  End-Pi;

  FLDSDS= FLDSDS2;
  // ADD RECORD TO THE OUTPUT FILE
  Exec SQL INSERT INTO QTEMP.XLPSRVWK VALUES(:FLDSDS);

End-Proc;


// **************************************************************
// XLPREAD - READ THE NEXT ROW FROM AN EXCEL FILE
// **************************************************************
// THIS PROCEDURES POSITIONS THE EXCEL FILE TO THE NEXT ROW
// IT RETURNS OFF IF THERE ARE NO MORE ROWS.
// **************************************************************
Dcl-Proc XLPREAD EXPORT;
  Dcl-Pi *N Ind;
  End-Pi;

  // ADD 1 TO THE CURRENT ROW, IF IT IS GREATER THAN
  // THE TOTAL NUMBER OF ROWS RETURN OFF
  Exec SQL FETCH NEXT FROM SQLCRS INTO :FLDSDS;

  If SQLSTT <> '00000';
    Return *OFF;
  EndIf;

  FLDSDS2=FLDSDS;
  #$COL=0;
  Return *ON;

End-Proc;


// **************************************************************
// XLPNEXT - RETURNS THE VALUE OF THE NEXT FIELD
// **************************************************************
// THIS PROCEDURES RETURNS THE NEXT FIELD IN THE EXCEL FILE,
// IT RETURNS BLANKS IF THERE ARE NO MORE COLUMNS
// **************************************************************
Dcl-Proc XLPNEXT EXPORT;
  Dcl-Pi *N Varchar(1024);
    PSCOL          Zoned(1:0) CONST OPTIONS(*NOPASS);
  End-Pi;

  If %parms>=1 AND %addr(PSCOL)<>*NULL;
    Return FLDS(PSCOL);
  Else;
    #$COL = #$COL + 1;
    Return FLDS(#$COL);
  EndIf;

End-Proc;

// **************************************************************
// XLPCLOSE- CLEANS UP SOME THINGS
// **************************************************************
// THIS PROCEDURES RETURNS THE NEXT FIELD IN THE EXCEL FILE,
// IT RETURNS BLANKS IF THERE ARE NO MORE COLUMNS
// **************************************************************
Dcl-Proc XLPCLOSE EXPORT;
  Dcl-Pi *N;
  End-Pi;

  Exec SQL CLOSE SQLCRS;

End-Proc;
