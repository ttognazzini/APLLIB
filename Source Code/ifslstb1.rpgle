**free
Ctl-Opt OPTION(*SrcStmt) DFTACTGRP( *NO ) Main(Main);

// Get A list of files in an IFS folder
// This is the command processor program for command IFSLST

// This is a little messy becasue all the #$... procedures were in
// service programs. They were just copied in to this source member
// so there there is probably a lot on unneeded duplication of work
// variables and such.

Dcl-F IFSLSTPF Usage(*Output) USROPN;
Dcl-F IFSLSTEXPF Usage(*Output) USROPN;
Dcl-F IFSLSTPR PRINTER USROPN OFLIND(overflow);

Dcl-Pr Pgm_QWCRSVAL  EXTPGM('QWCRSVAL');
  peRcvVar       Char(1)    DIM(100);
  peRVarLen      Int(10);
  peNumVals      Int(10);
  peSysValNm     Char(10);
  dsErrCode      Char(256);
End-Pr;
// Directory entry structure (dirent)
Dcl-S P_DIRENT     Pointer;
Dcl-S RC           Int(10);
Dcl-Ds DIRENT  BASED( P_DIRENT );
  D_RESERV1      Char(16);
  D_RESERV2      Uns(10);
  D_FILENO       Uns(10);
  D_RECLEN       Uns(10);
  D_RESERV3      Int(10);
  D_RESERV4      Char(8);
  D_NLSINFO      Char(12);
  NLS_CCSID      Int(10)    OVERLAY( D_NLSINFO:1 );
  NLS_CNTRY      Char(2)    OVERLAY( D_NLSINFO:5 );
  NLS_LANG       Char(3)    OVERLAY( D_NLSINFO:7 );
  NLS_RESERV     Char(3)    OVERLAY( D_NLSINFO:10 );
  D_NAMELEN      Uns(10);
  D_NAME         Char(640);
End-Ds;

// Open a directory
Dcl-Pr OPENDIR Pointer EXTPROC( 'opendir' );
  DIRNAME        Pointer    Value OPTIONS( *STRING );
End-Pr;

// Read directory entry
Dcl-Pr READDIR Pointer EXTPROC( 'readdir' );
  DIRP           Pointer    Value OPTIONS( *STRING );
End-Pr;
// Close a directory
Dcl-Pr CLOSEDIR Int(10) EXTPROC( 'closedir' );
  DIRP           Pointer    Value OPTIONS( *STRING );
End-Pr;
// Get IFS object status via UNIX API stat()
Dcl-Pr stat Int(10) EXTPROC('stat');
  filename       Pointer    Value OPTIONS(*STRING); //null terminated str
  statStruct     Pointer    Value; //                          D*
End-Pr;
// A FEW LOCAL VARIABLES...
Dcl-S DH           Pointer;
Dcl-S RPY          Char(1);
Dcl-S NAME         Char(640);
Dcl-S MSG          Char(52);
Dcl-S HHOFFSET     Zoned(2:0);

Dcl-Ds STATDS;
  ST_MODE        Uns(10); //File Mode
  ST_INO         Uns(10); //File Serial Number
  ST_NLINK       Uns(5); //Number of Links
  ST_PAD         Char(2);
  ST_UID         Uns(10); //User ID of Owner
  ST_GID         Uns(10); //Group IF
  ST_SIZE        Int(10); //Size in Bytes
  ST_ATIME       Int(10); //Time of Last Access
  ST_MTIME       Int(10); //Time of Last Modific
  ST_CTIME       Int(10); //Time of Status Chang
  ST_DEV         Uns(10); //ID of Dev Containing
  ST_BLKSIZE     Uns(10); //Block Size
  ST_ALLOCSIZE   Uns(10); //Allocation Size
  ST_OBJTYPE     Char(12); //AS/400 Object Type
  ST_CODEPAGE    Uns(5); //Object Data Codepage
  ST_RESERVED1   Char(62); //Reserved
  ST_INO_GEN_ID  Uns(10); //File Serial Gen ID

End-Ds;

// Program Status Data Structure
Dcl-Ds psds  psds;
  psdsdata       Char(429);
  psdsExcDta     Char(80)   OVERLAY(PSDSDATA:091);
End-Ds;


// -- API error information:
Dcl-Ds ERRC0100  QUALIFIED;
  BytPro         Int(10)    INZ( %size( ERRC0100 ));
  BytAvl         Int(10);
  MsgId          Char(7);
  *N             Char(1);
  MsgDta         Char(256);
End-Ds;

// -- Global variables:
Dcl-S MsgKey       Char(4);
Dcl-S BufSizAvl    Uns(10)    INZ( 0 );
Dcl-S NbrBytRtn    Uns(10)    INZ( 0 );
Dcl-S ApiBytAlc    Uns(10);
Dcl-S Idx          Int(10);
Dcl-S pBuffer      Pointer;
Dcl-S ErrTxt       Char(256);
Dcl-S Value        Varchar(100);

// -- Global constants:
Dcl-C CUR_CCSID  0;
Dcl-C CUR_CTRID  X'0000';
Dcl-C CUR_LNGID  X'000000';
Dcl-C CHR_DLM_1  0;

// -- File attributes constants
Dcl-C QP0L_ATTR_OBJTYPE 0;              // RETURNS 10 CHARACTER OBJECT TYPE
Dcl-C QP0L_ATTR_DATA_SIZE 1;            // RETURNS FILE SIZE IN BYTES
Dcl-C QP0L_ATTR_ALLOC_SIZE 2;           // RETURNS FILE ALLOCTAION SIZE IN BYTES
Dcl-C QP0L_ATTR_EXTENDED_ATTR_SIZE 3;   // RETURNS THE TOTAL NUMBER OF EXTENDED ATRIBUTE BYTES
Dcl-C QP0L_ATTR_CREATE_TIME 4;          // RETURNS CREATION DATE AND TIME IN YYYYMMDDHHMMSS FORMAT
Dcl-C QP0L_ATTR_ACCESS_TIME 5;          // RETURNS LAST ACCESS DATE AND TIME IN YYYYMMDDHHMMSS FORMA
Dcl-C QP0L_ATTR_CHANGE_TIME 6;          // RETURNS LAST CHANGE DATE AND TIME IN YYYYMMDDHHMMSS FORMA
Dcl-C QP0L_ATTR_MODIFY_TIME 7;          // RETURNS LAST CHANGE DATE AND TIME IN YYYYMMDDHHMMSS FORMA
Dcl-C QP0L_ATTR_STG_FREE 8;             // RETURNS *YES OR *NO FOR IS THE OBJECTS DATA IS OFFLINE
Dcl-C QP0L_ATTR_CHECKED_OUT 9;          // RETURNS WHETHER AN OBJECT IS CHECK OUT OR NOT
//                                         RETURS Y/N, USER AND DATE TIM CHECKED OUT IN THIS FORMAT
//                                         YUUUUUUUUUUYYYYMMDDHHMMSS
Dcl-C QP0L_ATTR_LOCAL_REMOTE 10;        // RETURNS WHETHER AN OBJECT IS STORE ON A REMOTE SYSTEM
//                                         *YES = ON REMOTE SYSTEM, *NO = ON LOCAL SYSTEM
Dcl-C QP0L_ATTR_AUT 11;                 // RETURNS PUBIC AND PRIVATE AUTHORITIES,RAW DATA
Dcl-C QP0L_ATTR_FILE_ID 12;             // RETURNS FILE ID, 16 CHARACTERS
Dcl-C QP0L_ATTR_ASP 13;                 // RETURNS AUZILIARY STORAGE POOL THE OBJECT IS STORED IN, N
Dcl-C QP0L_ATTR_DATA_SIZE_64 14;        // RETURNS OBJECTS DATA SIZE IN BYTES, HANDLES BIGGER NUMBER
Dcl-C QP0L_ATTR_ALLOC_SIZE_64 15;       // RETURNS OBJECTS ALLOCATION SIZE IN BYTES,
//                                         HANDLES BIGGER NUMBER, NUMBER
Dcl-C QP0L_ATTR_USAGE_INFORMATION 16;   // RETURNS USAGE DATA, RESET DATE, LAST USED DATE, DAYS USED
//                                         YYYYMMDDHHMMSSYYYYMMDDHHMMSSNNNNNNNNN
Dcl-C QP0L_ATTR_PC_READ_ONLY 17;        // RETURNS READ ONLY AS *YES OR *NO
Dcl-C QP0L_ATTR_PC_HIDDEN 18;           // RETURNS HIDDEN AS *YES OR *NO
Dcl-C QP0L_ATTR_PC_SYSTEM 19;           // RETURNS SYSTEM FILE AS *YES OR *NO
Dcl-C QP0L_ATTR_PC_ARCHIVE 20;          // RETURNS WHETHER THE OBJECT HAS CHANGED SINCE LAST EXMAINE
Dcl-C QP0L_ATTR_SYSTEM_ARCHIVE 21;      // RETURNS Whether the object has changed and needs to be sa
Dcl-C QP0L_ATTR_CODEPAGE 22;            // RETURNS CODE PAGE AS NUMBER, 0 MEANS MORE THAN ONE EXISTS
Dcl-C QP0L_ATTR_FILE_FORMAT 23;         // RETURNS TYPE1 OR TYPE2
Dcl-C QP0L_ATTR_UDFS_DEFAULT_FORMAT 24; // RETURNS TYPE1 OR TYPE2
Dcl-C QP0L_ATTR_JOURNAL_INFORMATION 25; // RETURNS JOURNALLING INFORMATION IN A DATA STRUCTURE
//                                         POS  1- 1  Y/N JOURNALED
//                                         POS  2-11  JOURNAL ID
//                                         POS 12-21  CURRENT OR LAST JOURNAL NAME
//                                         POS 22-31  CURRENT OR LAST JOURNAL LIBRARY
//                                         POS 21-39  LAST JOURNAL START DATE YYYYMMDD
//                                         POS 40-39  LAST JOURNAL START TIME HHMMSS
//                                                    OPTIONS ARE NOT RETURNED FOR NOW MAY ADD LATER
Dcl-C QP0L_ATTR_ALWCKPWRT 26;           // RETURNS *YES OR *NO
Dcl-C QP0L_ATTR_CCSID 27;               // The CCSID of the data and extended attributes of the obje
Dcl-C QP0L_ATTR_SIGNED 28;              // Whether an object has an IBM i digital signature. *YES/*N
Dcl-C QP0L_ATTR_SYS_SIGNED 29;          // Whether the object was signed by a source that is trusted
//                                         *YES/*NO, ONLY IF SIGNED
Dcl-C QP0L_ATTR_MULT_SIGS 30;           // MORE THAN ONE SIGNATURE, *YES/*NO
Dcl-C QP0L_ATTR_DISK_STG_OPT 31;        // HOW AUXILIARY STORAGE IS ALLOCATED, NORMAL, MINIMIZE OR D
Dcl-C QP0L_ATTR_MAIN_STG_OPT 32;        // HOW MAIN STORAGE IS ALLOCATED, NORMAL, MINIMIZE OR DYNAMI
Dcl-C QP0L_ATTR_DIR_FORMAT 33;          // The format of the specified directory object. TYPE1, TYPE
Dcl-C QP0L_ATTR_AUDIT 34;               // The auditing value associated with the object.
//                                         *NONE, *USRPRF, *CHANGE, *ALL, *NOTAVL
Dcl-C QP0L_ATTR_SUID 300;               // Set effective user ID (UID) at execution time. *YES, *NO
Dcl-C QP0L_ATTR_SGID 301;               // Set effective group ID (GID) at execution time. *YES, *NO

// -- API path:
Dcl-Ds Path  QUALIFIED  ALIGN;
  CcsId          Int(10)    INZ( CUR_CCSID );
  CtrId          Char(2)    INZ( CUR_CTRID );
  LngId          Char(3)    INZ( CUR_LNGID );
  *N             Char(3)    INZ( *ALLX'00' );
  PthTypI        Int(10)    INZ( CHR_DLM_1 );
  PthNamLen      Int(10);
  PthNamDlm      Char(2)    INZ( '/ ' );
  *N             Char(10)   INZ( *ALLX'00' );
  PthNam         Char(5000);
End-Ds;

Dcl-Ds AtrIds  QUALIFIED  ALIGN;
  NbrAtr         Int(10);
  AtrId          Int(10)    DIM( 32 );
End-Ds;

Dcl-Ds Buffer  QUALIFIED  ALIGN  BASED( PBUFFERE );
  OfsNxtAtr      Uns(10);
  AtrId          Uns(10);
  SizAtr         Uns(10);
  *N             Char(4);
  AtrDta         Char(1024);
  AtrBin2        Int(5)     OVERLAY( ATRDTA );
  AtrBin4        Int(10)    OVERLAY( ATRDTA );
  AtrBin8        Int(10)    OVERLAY( ATRDTA );
  AtrBin42       Int(10)    OVERLAY( ATRDTA : 5 );
  AtrBin22       Int(10)    OVERLAY( ATRDTA : 9 );
End-Ds;

// -- Get attributes:
Dcl-Pr GetAtr Int(10) EXTPROC( 'Qp0lGetAttr' );
  GaFilNam       Pointer    Value;
  GaAtrLst       Pointer    Value;
  GaBuffer       Pointer    Value;
  GaBufSizPrv    Uns(10)    Value;
  GaBufSizAvl    Uns(10);
  GaBufSizRtn    Uns(10);
  GaFlwSymLnk    Uns(10)    Value;
  GaDots         Int(10)    OPTIONS( *NOPASS );
End-Pr;

// -- Initialize memory:
Dcl-Pr memset Int(10) EXTPROC( 'memset' );
  pStg           Pointer    Value;
  InzVal         Uns(10)    Value;
  InzByt         Int(10)    Value;
End-Pr;

// -- Error number:
Dcl-Pr sys_errno Pointer EXTPROC( '__errno' );
End-Pr;

// -- Error string:
Dcl-Pr sys_strerror Pointer EXTPROC( 'strerror' );
  errno          Int(10)    Value;
End-Pr;

// -- Send program message:
Dcl-Pr SndPgmMsg  EXTPGM( 'QMHSNDPM' );
  SpMsgId        Char(7)    CONST;
  SpMsgFq        Char(20)   CONST;
  SpMsgDta       Char(128)  CONST;
  SpMsgDtaLen    Int(10)    CONST;
  SpMsgTyp       Char(10)   CONST;
  SpCalStkE      Char(10)   CONST  OPTIONS( *VARSIZE );
  SpCalStkCtr    Int(10)    CONST;
  SpMsgKey       Char(4);
  SpError        Char(32767) OPTIONS( *VARSIZE );
End-Pr;

Dcl-S fold124 char(124);
Dcl-S psFile char(10);
Dcl-S psLib char(10);
Dcl-S obj100 char(100);

Dcl-S LADATE packed(8);
Dcl-S LATIME packed(6);
Dcl-S LMDATE packed(8);
Dcl-S LMTIME packed(6);
Dcl-S LCDATE packed(8);
Dcl-S LCTIME packed(6);
Dcl-S lrCnt  packed(6);
Dcl-S lrSize packed(12);
Dcl-S overflow ind;

Dcl-Proc Main;
  Dcl-Pi *n;
    psFold char(256);
    psType char(10);
    psOutF char(20);
    psFType char(10);
    psInDir char(2);
  End-Pi;

  fold124 = %subst(psFold:1:124);

  If PSTYPE<>'*PRINT';
    // Split the input file and library to seperate fields
    psFile=%subst(psOutF: 1:10);
    psLib =%subst(psOutF:11:10);

    // Create the output file, delete it if it exists
    If PSFTYPE<>'*FULL';
      #$CMD('DLTF '+ %trim(psLib) +'/' +%trim(psFile):1);
      #$CMD('CRTDUPOBJ IFSLSTPF *LIBL *FILE '+
                   %trim(psLib) +' '+%trim(psFile));
      #$CMD('OVRDBF IFSLSTPF '+ %trim(psLib) +'/' +%trim(psFile));
    Else;
      #$CMD('DLTF '+ %trim(psLib) +'/' +%trim(psFile):1);
      #$CMD('CRTDUPOBJ IFSLSTEXPF *LIBL *FILE '+
                   %trim(psLib)+' '+%trim(psFile));
      #$CMD('OVRDBF IFSLSTEXPF '+ %trim(psLib) +'/' +%trim(psFile));
    EndIf;
  EndIf;

  // Open up the directory.
  DH = OPENDIR( %trim(psFold) );
  If DH = *NULL;
    #$DSPWIN('OPENDIR: ' + psdsExcDta);
    *INLR = *ON;
    Return;
  EndIf;

  // Get system timezone offset
  HHOFFSET=GETTIMEZONE;

  overflow = *off;
  If psType='*PRINT';
    #$CMD('OVRPRTF IFSLSTPR PAGESIZE(*N 198) CPI(15)');
    Open IFSLSTPR;
    Write #HDR;
  Else;
    If PSFTYPE<>'*FULL';
      Open IFSLSTPF;
    Else;
      Open IFSLSTEXPF;
    EndIf;
  EndIf;

  // Read each entry from the directory (in a loop)
  P_DIRENT = READDIR( DH );
  DoW P_DIRENT <> *NULL;
    If PSFTYPE<>'*FULL' OR psType='*PRINT';
      ExSr ADDREC;
    Else;
      ExSr ADDRECEX;
    EndIf;

    P_DIRENT = READDIR( DH );
  EndDo;
  // Close the directory
  RC = CLOSEDIR( DH );

  If psType='*PRINT';
    Write #TOT;
    Close IFSLSTPR;
    #$CMD('DLTOVR IFSLSTPR');
  Else;
    If PSFTYPE<>'*FULL';
      Close IFSLSTPF;
      #$CMD('DLTOVR IFSLSTPF');
    Else;
      Close IFSLSTEXPF;
      #$CMD('DLTOVR IFSLSTEXPF');
    EndIf;
  EndIf;

  Return;

  // ************************************************************
  BegSr ADDREC;

    // Clear the output record and populate the fields
    Clear  *ALL IFSLSTR;
    IFSFOLD  =  psFold;
    IFSFILE  =  %str( %addr( D_NAME ) );
    IFSPATH  =  %trim(IFSFOLD) + '/' + %trim(IFSFILE);
    IFSFLLN  =  D_NAMELEN;
    IFSFLNO  =  D_FILENO;
    IFSCSID  =  NLS_CCSID;
    IFCNTRY  =  NLS_CNTRY;
    IFSLANG  =  NLS_LANG;

    NAME = %str( %addr( D_NAME ) );

    // Get the status structure to see what type of object it is and get the si
    If stat( %trim(IFSPATH) : %addr(STATDS) ) = 0;
      IFSTYPE  =  ST_OBJTYPE;
      IFSSIZE  =  ST_SIZE;
    EndIf;

    // Skip if a directory and they are not to be included.
    If psInDir='*NO ' AND IFSTYPE='*DIR        ';
      LeaveSr;
    EndIf;

    // Convert  last access, last modified and lastchgsts time/date
    LADATE=GETEDATE(ST_ATIME);
    LATIME=GETETIME(ST_ATIME);
    LMDATE=GETEDATE(ST_MTIME);
    LMTIME=GETETIME(ST_MTIME);
    LCDATE=GETEDATE(ST_CTIME);
    LCTIME=GETETIME(ST_CTIME);

    If psType='*PRINT';
      obj100 = %subst(ifsFile:1:100);
      lrCnt = lrCnt + 1;
      lrSize = lrSize + IFSSIZE;
      If overflow;
        Write #HDR;
        overflow = *off;
      EndIf;
      Write #DTL;
    Else;
      Write IFSLSTR;
    EndIf;

  EndSr;

  // ************************************************************
  BegSr ADDRECEX;

    // Clear the output record and populate the fields
    Clear  *ALL IFSLSTEXR;
    IFSFOLD  =  psFold;
    IFSFILE  =  %str( %addr( D_NAME ) );
    IFSPATH  =  %trim(IFSFOLD) + '/' + %trim(IFSFILE);
    IFSFLLN  =  D_NAMELEN;
    IFSFLNO  =  D_FILENO;
    IFSCSID  =  NLS_CCSID;
    IFCNTRY  =  NLS_CNTRY;
    IFSLANG  =  NLS_LANG;

    NAME = %str( %addr( D_NAME ) );

    // Get the status structure to see what type of object it is and get the si
    If stat( %trim(IFSPATH) : %addr(STATDS) ) = 0;
      IFSTYPE  =  ST_OBJTYPE;
      IFSSIZE  =  ST_SIZE;
    EndIf;

    // Skip if a directory and they are not to be included.
    If psInDir='*NO ' AND IFSTYPE='*DIR        ';
      LeaveSr;
    EndIf;

    // Populate fields from #$getfa
    IFSSIZE   = %dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_DATA_SIZE):10:0);
    IFSDSIZ   = %dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_DATA_SIZE):10:0);
    IFSASIZ   = %dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_ALLOC_SIZE):10:0);
    IFSEASIZ  = %dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_EXTENDED_ATTR_SIZE)
                      :10:0);
    Monitor;
      IFSCRTED  = %timestamp(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CREATE_TIME)
                     +'000000':*ISO0);
    On-Error;
    EndMon;
    Monitor;
      IFSLSTACC = %timestamp(#$GETFA(%trim(IFSPATH):QP0L_ATTR_ACCESS_TIME)
                     +'000000':*ISO0);
    On-Error;
    EndMon;
    Monitor;
      IFSLSTCHG = %timestamp(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CHANGE_TIME)
                     +'000000':*ISO0);
    On-Error;
    EndMon;
    IFSSTGFREE =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_STG_FREE):2:1);
    IFSCHKOUT  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CHECKED_OUT):1:1);
    IFSCOUSER  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CHECKED_OUT):2:10);
    Monitor;
      IFSCOTIME  =%timestamp(
             %subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CHECKED_OUT):12:14)
                     +'000000':*ISO0);
    On-Error;
    EndMon;
    IFSLOCRMT  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CHECKED_OUT):2:1);
    IFSASP     =%dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_ASP):2:0);
    IFSRDONLY  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_PC_READ_ONLY):2:1);
    IFSHIDDEN  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_PC_HIDDEN):2:1);
    IFSSYSTEM  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_PC_SYSTEM):2:1);
    IFSARCHIVE =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_PC_ARCHIVE):2:1);
    IFSSYSARCH =%subst(#$GETFA(%trim(IFSPATH):
                      QP0L_ATTR_SYSTEM_ARCHIVE):2:1);
    IFSCODPAG  =%dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CODEPAGE):10:0);
    Monitor;
      IFSFILEFMT =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_FILE_FORMAT):5:1);
    On-Error;
    EndMon;
    Monitor;
      IFSUDFSFMT =%subst(#$GETFA(%trim(IFSPATH):
                     QP0L_ATTR_UDFS_DEFAULT_FORMAT):5:1);
    On-Error;
    EndMon;
    IFSJRN     =%subst(#$GETFA(%trim(IFSPATH):
                      QP0L_ATTR_JOURNAL_INFORMATION):1:1);
    Monitor;
      IFSJRNID   =%subst(#$GETFA(%trim(IFSPATH):
                      QP0L_ATTR_JOURNAL_INFORMATION):2:10);
      IFSJRNFILE =%subst(#$GETFA(%trim(IFSPATH):
                      QP0L_ATTR_JOURNAL_INFORMATION):12:10);
      IFSJRNLIB  =%subst(#$GETFA(%trim(IFSPATH):
                      QP0L_ATTR_JOURNAL_INFORMATION):22:10);
    On-Error;
    EndMon;
    IFSSVACTF  =#$GETFA(%trim(IFSPATH):QP0L_ATTR_ALWCKPWRT);
    IFSCCSID   =%dec(#$GETFA(%trim(IFSPATH):QP0L_ATTR_CCSID):10:0);
    Monitor;
      IFSSGN     =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_SIGNED):2:1);
    On-Error;
    EndMon;
    Monitor;
      IFSSYSSGN  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_SYS_SIGNED):2:1);
    On-Error;
    EndMon;
    Monitor;
      IFSMLTSGN  =%subst(#$GETFA(%trim(IFSPATH):QP0L_ATTR_MULT_SIGS):2:1);
    On-Error;
    EndMon;
    IFSDSKSO   =#$GETFA(%trim(IFSPATH):QP0L_ATTR_DISK_STG_OPT);
    IFSMAINSO  =#$GETFA(%trim(IFSPATH):QP0L_ATTR_MAIN_STG_OPT);

    Write IFSLSTEXR;

  EndSr;

End-Proc;


// Converts an epcoh date to a numeric yyyymmdd date field
Dcl-Proc GETEDATE;
  Dcl-Pi *N Zoned(8:0);
    EPCOHTZ        Zoned(10:0) CONST;

    // STAND ALONES
  End-Pi;
  Dcl-S TIMESTAMP    TIMESTAMP;
  Dcl-S DATE         Packed(8:0);
  Dcl-S EPCOH        TIMESTAMP  INZ(Z'1970-01-01-00.00.00');


  TIMESTAMP = EPCOH + %seconds(EPCOHTZ) + %hours(HHOFFSET);
  DATE=%int(%char(%date(TIMESTAMP) : *ISO0));

  Return DATE;

End-Proc;


// Converts an epcoh date to a numeric hhmmss time field
Dcl-Proc GETETIME;
  Dcl-Pi *N Zoned(6:0);
    EPCOHTZ        Zoned(10:0) CONST;
  End-Pi;
  // stand alones
  Dcl-S TIMESTAMP    TIMESTAMP;
  Dcl-S TIME1        TIME;
  Dcl-S TIME2        Char(10);
  Dcl-S TIME         Packed(6:0);
  Dcl-S EPCOH        TIMESTAMP  INZ(Z'1970-01-01-00.00.00');

  TIMESTAMP = EPCOH + %seconds(EPCOHTZ) + %hours(HHOFFSET);
  TIME1=%time(TIMESTAMP);
  TIME2=%char(TIME1: *HMS0);
  TIME=%int(TIME2);

  Return TIME;

End-Proc;


// This gets the offset from Universal Coordinated Time (UTC)
// from the system value QUTCOFFSET, in hours
Dcl-Proc GETTIMEZONE;
  Dcl-Pi *N Zoned(2:0);
  End-Pi;

  // Stand alones
  Dcl-S NEWDATE      Zoned(8:0);
  Dcl-S peRcvVar     Char(1)    DIM(100);
  Dcl-S peRVarLen    Int(10)    INZ(100);
  Dcl-S peNumVals    Int(10)    INZ(1);
  Dcl-S peSysValNm   Char(10)   INZ('QUTCOFFSET');
  Dcl-S p_Offset     Pointer;
  Dcl-S wkOffset     Int(10)    BASED(p_Offset);
  Dcl-S p_SV         Pointer;

  Dcl-Ds dsSV  BASED(p_SV);
    dsSVSysVal     Char(10);
    dsSVDtaTyp     Char(1);
    dsSVDtaSts     Char(1);
    dsSVDtaLen     Int(10);
    dsSVtzdir      Char(1);
    dsSVtzHour     Zoned(2:0);
    dsSVtzFrac     Zoned(2:0);
  End-Ds;

  Dcl-Ds dsErrCode;
    dsBytesPrv     Int(10)    INZ(256);
    dsBytesAvl     Int(10)    INZ(0);
    dsExcpID       Char(7);
    dsReserved     Char(1);
    dsExcpData     Char(240);
  End-Ds;

  // Get system value
  Pgm_QWCRSVAL(peRcvVar : peRVarLen : peNumVals : peSysValNm : dsErrCode);

  // If error return 0
  If DSBYTESAVL > 0  OR  %error;
    Return 0;
  EndIf;

  p_Offset = %addr(peRcvVar(5));
  p_SV = %addr(peRcvVar(wkOffset+1));

  // IF DIRECTION IS NEGATIVE MAKE HOURS NEGATIVE
  If DSSVTZDIR='-';
    DSSVTZHOUR=DSSVTZHOUR*-1;
  EndIf;

  Return DSSVTZHOUR;

End-Proc;


// #$CMD - Run a command
// This proceudre runs a command. Errors are displayed in a
// window or ignored.
//
//   Input: #$CMD = Command to run.
//          #$NOE = Optional, 1=Ignore Errors, 2=let errors blow up
//
Dcl-Proc #$CMD;
  Dcl-Pi *N;
    #$CMD          Varchar(32768) Value;
    PSNOE          Zoned(1:0) CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-S #$LEN        Packed(15:5);
  Dcl-S #$NOE        Packed(15:5);
  // PROTOTYPE FOR QCMDEXC
  Dcl-Pr CMD  EXTPGM('QCMDEXC');
    COMMAND        Char(32768) CONST;
    LENGTH         Packed(15:5) CONST;
  End-Pr;
  // Use noe if passed otherwise default it to 0
  If %parms() > 1 AND %addr(PSNOE)<>*NULL;
    #$NOE=PSNOE;
  Else;
    #$NOE=0;
  EndIf;

  // If the error type is window but it is a batch job, change it to 2
  // which just lets the escape error happen uncontrolled
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


// Display Text in a Window
Dcl-Proc #$DSPWIN;
  Dcl-Pi *N;
    #$TEXT         Char(8192) CONST;
    #$MSGID        Char(7)    CONST OPTIONS(*NOPASS : *OMIT);
    #$MSGFILE      Char(21)   CONST OPTIONS(*NOPASS : *OMIT);
  End-Pi;
  Dcl-Ds MYAPIERROR;
    dsECBytesP     Int(10)    Pos(1) INZ(256); // Bytes Provided (size of struct)
    dsECBytesA     Int(10)    Pos(5) INZ(0);   // Bytes Available (returned by API)
    dsECMsgID      Char(7)    Pos(9);          // Msg ID of Error Msg Returned
    dsECReserv     Char(1)    Pos(16);         // Reserved
    dsECMsgDta     Char(240)  Pos(17);         // Msg Data of Error Msg Returned
  End-Ds;
  Dcl-Pr QUILNGTX  EXTPGM('QUILNGTX');
    Text           Char(8192) CONST;
    LEN            Int(10)    CONST;
    MSGID          Char(7)    CONST;
    MSGFILE        Char(21)   CONST;
    APIERROR       LIKE(MYAPIERROR);
  End-Pr;
  Dcl-S MSGID      LIKE(#$MSGID);
  Dcl-S MSGFILE    LIKE(#$MSGFILE);

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

  QUILNGTX ( #$TEXT: %len(#$TEXT) : MSGID : MSGFILE : MYAPIERROR );

End-Proc;


// Get file attribute
Dcl-Proc #$GETFA EXPORT;
  Dcl-Pi *N Varchar(100);
    PxPath         Varchar(5002)  CONST;
    PxCmdNam_q     Packed(4:0) CONST;
  End-Pi;


  Path.PthNam    = PxPath;
  Path.PthNamLen = %len( PxPath );

  ApiBytAlc = 32767;
  pBuffer   = %alloc( ApiBytAlc );
  memset( pBuffer: x'00': ApiBytAlc );
  AtrIds.NbrAtr    = 1;
  AtrIds.AtrId(1)  = PxCmdNam_q;
  If GetAtr( %addr( Path ) : %addr( AtrIds ) : pBuffer : ApiBytAlc
                  : BufSizAvl : NbrBytRtn : 0 ) = 0;
    pBufferE = pBuffer;
    For  Idx = 1  to AtrIds.NbrAtr;
      ExSr  RtvAtrVal;
      If  Buffer.OfsNxtAtr = *Zero;
        Leave;
      EndIf;
      pBufferE = pBuffer + Buffer.OfsNxtAtr;
    EndFor;
  Else;
    SndDiagMsg( %char( errno ) + ': ' + strerror );
    SndEscMsg( 'CPF0011': '' );
  EndIf;
  DeAlloc  pBuffer;

  Return Value;

  // Convert Buffer to Output String
  BegSr  RtvAtrVal;

    Value = ' ';
    // If no data is returned
    If     Buffer.SizAtr = *Zero;
      LeaveSr;
    EndIf;

    Select;

        // handle all values of bin(2) to number
      When  Buffer.AtrId = QP0L_ATTR_ASP;
        Value = %char( Buffer.AtrBin2 );

        // handle all values of bin(4) to number
      When  Buffer.AtrId = QP0L_ATTR_DATA_SIZE
             or Buffer.AtrId = QP0L_ATTR_ALLOC_SIZE
             or Buffer.AtrId = QP0L_ATTR_EXTENDED_ATTR_SIZE
             or Buffer.AtrId = QP0L_ATTR_CODEPAGE
             or Buffer.AtrId = QP0L_ATTR_CCSID;
        Value = %char( Buffer.AtrBin4 );

        // handle all values of bin(4) to date time
      When  Buffer.AtrId = QP0L_ATTR_CREATE_TIME
             or Buffer.AtrId = QP0L_ATTR_ACCESS_TIME
             or Buffer.AtrId = QP0L_ATTR_CHANGE_TIME
             or Buffer.AtrId = QP0L_ATTR_MODIFY_TIME;
        Value = DateTime( Buffer.AtrBin4 );

        // handle all values of bin(8) to number
      When  Buffer.AtrId = QP0L_ATTR_DATA_SIZE_64
             or Buffer.AtrId = QP0L_ATTR_ALLOC_SIZE_64;
        Value = %char( Buffer.AtrBin8 );

        // handle all *YES/*NO options
      When  Buffer.AtrId = QP0L_ATTR_STG_FREE
            or  Buffer.AtrId = QP0L_ATTR_LOCAL_REMOTE
            or  Buffer.AtrId = QP0L_ATTR_STG_FREE
            or  Buffer.AtrId = QP0L_ATTR_PC_READ_ONLY
            or  Buffer.AtrId = QP0L_ATTR_PC_HIDDEN
            or  Buffer.AtrId = QP0L_ATTR_PC_SYSTEM
            or  Buffer.AtrId = QP0L_ATTR_PC_ARCHIVE
            or  Buffer.AtrId = QP0L_ATTR_SYSTEM_ARCHIVE
            or  Buffer.AtrId = QP0L_ATTR_ALWCKPWRT
            or  Buffer.AtrId = QP0L_ATTR_SYS_SIGNED
            or  Buffer.AtrId = QP0L_ATTR_MULT_SIGS
            or  Buffer.AtrId = QP0L_ATTR_ALWCKPWRT;
        If %subst( Buffer.AtrDta: 1: Buffer.SizAtr ) = x'01';
          Value = '*YES';
        Else;
          Value = '*NO';
        EndIf;

        // handle all TYPE1/TYPE2 options
      When  Buffer.AtrId = QP0L_ATTR_FILE_FORMAT
            or  Buffer.AtrId = QP0L_ATTR_UDFS_DEFAULT_FORMAT
            or  Buffer.AtrId = QP0L_ATTR_DIR_FORMAT;
        If %subst( Buffer.AtrDta: 1: Buffer.SizAtr ) = x'01';
          Value = 'TYPE1';
        Else;
          Value = 'TYPE2';
        EndIf;

        // handle creating checked out data structure
      When  Buffer.AtrId = QP0L_ATTR_CHECKED_OUT;
        If  %subst( Buffer.AtrDta: 1: 1 ) = x'01';
          Value = 'Y';
        Else;
          Value = 'N';
        EndIf;
        Value += %subst( Buffer.AtrDta: 2: 10 );
        Value += DateTimeC( %subst( Buffer.AtrDta: 21: 4 ) );

        // handle usage information data structure
      When  Buffer.AtrId = QP0L_ATTR_CHECKED_OUT;
        Value = DateTime( Buffer.AtrBin4 ) +
                       DateTime( Buffer.AtrBin42 ) +
                       %char( Buffer.AtrBin22 );

        // handle Journal Information data structure
      When  Buffer.AtrId = QP0L_ATTR_JOURNAL_INFORMATION;
        If  %subst( Buffer.AtrDta: 1: 1 ) = x'01';
          Value = 'Y';
        Else;
          Value = 'N';
        EndIf;
        Value += %subst( Buffer.AtrDta: 3: 30 ) +
                        DateTimeC( %subst( Buffer.AtrDta: 33: 4 ) );

        // Handle storage options
      When  Buffer.AtrId = QP0L_ATTR_DISK_STG_OPT
            or  Buffer.AtrId = QP0L_ATTR_MAIN_STG_OPT;
        Select;
          When  %subst( Buffer.AtrDta: 1: Buffer.SizAtr ) = x'00';
            Value = 'NORMAL';
          When  %subst( Buffer.AtrDta: 1: Buffer.SizAtr ) = x'01';
            Value = 'MINIMIZE';
          When  %subst( Buffer.AtrDta: 1: Buffer.SizAtr ) = x'02';
            Value = 'DYNAMIC';
        EndSl;

        // handle all rawdata, also works for any character data
      Other;
        Value = %subst( Buffer.AtrDta: 1: Buffer.SizAtr );

    EndSl;

  EndSr;

End-Proc;


// Get runtime error number
Dcl-Proc errno;
  Dcl-Pi *N Int(10);
  End-Pi;
  Dcl-S Error        Int(10)    BASED( PERROR )  NOOPT;
  pError = sys_errno;
  Return  Error;
End-Proc;


// Get runtime error text
Dcl-Proc strerror;
  Dcl-Pi *N Varchar(128);
  End-Pi;
  Return  %str( sys_strerror( errno ));
End-Proc;


// Send diagnostic message
Dcl-Proc SndDiagMsg;
  Dcl-Pi *N Int(10);
    PxMsgDta       Varchar(512) CONST;
  End-Pi;
  Dcl-S MsgKey       Char(4);
  SndPgmMsg( 'CPF9897' : 'QCPFMSG   *LIBL' : PxMsgDta
                 : %len( PxMsgDta ) : '*DIAG' : '*PGMBDY' : 1
                 : MsgKey : ERRC0100 );
  If  ERRC0100.BytAvl > *Zero;
    Return  -1;
  Else;
    Return   0;
  EndIf;
End-Proc;


// Send escape message
Dcl-Proc SndEscMsg;
  Dcl-Pi *N Int(10);
    PxMsgId        Char(7)    CONST;
    PxMsgDta       Varchar(512) CONST;
  End-Pi;
  Dcl-S MsgKey       Char(4);
  SndPgmMsg( PxMsgId : 'QCPFMSG   *LIBL' : PxMsgDta
                 : %len( PxMsgDta ) : '*ESCAPE' : '*PGMBDY' : 1
                 : MsgKey : ERRC0100 );
  If  ERRC0100.BytAvl > *Zero;
    Return  -1;
  Else;
    Return   0;
  EndIf;
End-Proc;


// Convert Epcoh Date to a character YYYYMMDDHHMMSS Field
Dcl-Proc DateTime;
  Dcl-Pi *N Char(14);
    EPCOHTZ        Int(10)    CONST;
  End-Pi;
  Dcl-S TIMESTAMP    TIMESTAMP;
  Dcl-S EPCOH        TIMESTAMP  INZ(Z'1970-01-01-00.00.00');

  // if an offset has not been pulled, get it now
  If HHOFFSET=0;
    HHOFFSET=GETTIMEZONE;
  EndIf;

  TIMESTAMP = EPCOH + %seconds(EPCOHTZ) + %hours(HHOFFSET);
  Return    %char(%date(TIMESTAMP) : *ISO0) +
                  %char(%time(TIMESTAMP) : *HMS0);

End-Proc;


// Convert Epcoh Date to a character YYYYMMDDHHMMSS Field
Dcl-Proc DateTimeC;
  Dcl-Pi *N Char(14);
    EPCOHTZ        Char(4)    CONST;
  End-Pi;

  Dcl-Ds Char;
    Bin4           Int(10);
  End-Ds;

  EVAL      Char= EPCOHTZ;
  Return    DateTime(Bin4);

End-Proc;


// €#$INTACT - See if a Job is Interactive
Dcl-Proc #$INTACT;
  Dcl-Pi *N Char(1);
  End-Pi;

  // API error information:
  Dcl-Ds APIERR  QUALIFIED;
    BytPro         Int(10)    INZ( %size( APIERR ));
    BytAvl         Int(10);
    MsgId          Char(7);
    *N             Char(1);
    MsgDta         Char(256);
  End-Ds;

  // Return Job Attribute Data Structure, Defined Bellow
  Dcl-Pr QUSRJOBI  EXTPGM('QUSRJOBI');
    RcvVar         Char(32766) OPTIONS(*VARSIZE);
    RcvVarLen      Int(10)    CONST;
    Format         Char(8)    CONST;
    QualJob        Char(26)   CONST;
    InternJob      Char(16)   CONST;
    ErrorCode                 LIKE(APIERR);
  End-Pr;

  // Data Structure job description, used in QUSRJOBI
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
  QUSRJOBI(dsJob: APIHANDLE:'JOBI0100': '* ':' ':APIERR);
  If DSJOBTYPE = 'I';
    Return 'I';
  Else;
    Return ' ';
  EndIf;

End-Proc;
