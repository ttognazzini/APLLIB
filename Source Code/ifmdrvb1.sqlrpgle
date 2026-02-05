**FREE
Ctl-Opt DftActGrp(*No) BndDir('APLLIB/APLLIB') Option(*Srcstmt) ActGrp(*new) Main(Main);

// IFS Monitor Driver Program
// This program monitors IFS directories and moves files fin them to a different location.
// The intent is to move file to network shares in batch so suers do not get errors if the
// folder is not accessable.

// The program uses file IFMNDRV to see what directories to monitor for. It logs its
// attempts to file IFMLOG.

// For this to work the job running this needs to run with a user profile that has
// authority to the folder.
// Example Call
//   SBMJOB CMD(CALL APLLIB/IFMDRVB1) JOB(IFSMONITOR) USER(ZZWINCHTAG)
//          JOBD(QGPL/IFSMONITOR)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

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
Dcl-Pr access  int(10) extproc('access');
  path pointer value options(*string);
  amode int(10) value;
End-Pr;

Dcl-C F_OK const(0); // Check for existence
Dcl-S rc   int(10);
Dcl-S DH   Pointer; // Directory Handle
Dcl-S frmObj varchar(132);
Dcl-S cleanName varchar(132);
Dcl-S toPth varchar(132);
Dcl-S orgToPth like(toPth);
Dcl-S cnt packed(5);
Dcl-S splitLoc packed(3);
Dcl-S saveTime timestamp;

// Min repeat time before starting another check, in minutes
Dcl-C MINREPEAT Const(1);

// Directory entry structure (dirent), returned from READDIR
Dcl-S P_DIRENT     Pointer;
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


// DS to read sql into
Dcl-Ds dta;
  frmPth varchar(132);
  dstPth varchar(132);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;

  // Never ending loop
  DoW 1 = 1;
    saveTime = %timestamp();

    // Loop through the driver program and process each folder
    Exec SQL Declare drvCrs Cursor for
      Select frmPth, dstPth From IFMDRV Where acvRow = '1';
    Exec SQL Open drvCrs;
    Clear dta;
    Exec SQL Fetch next from drvCrs into :dta;
    DoW sqlSTate < '02';
      ProcessFolder();
      Exec SQL Fetch next from drvCrs into :dta;
    EndDo;
    Exec SQL Close drvCrs;

    // if it has been less than a minute since the last iteration, wait,
    // otherwise just start over
    If saveTime > %timestamp() - %minutes(MINREPEAT);
      #$wait(%diff(saveTime : %timestamp() - %minutes(MINREPEAT) : *SECONDS));
    EndIf;

  EndDo;

End-Proc;


Dcl-Proc ProcessFolder;

  // Open up the directory.
  DH = OPENDIR( %trim(frmPth) );
  If DH = *NULL;
    #$DSPWIN('OPENDIR: ' + psdsExcDta);
    *INLR = *ON;
    Return;
  EndIf;

  // Read each entry from the directory (in a loop)
  P_DIRENT = READDIR( DH );
  DoW P_DIRENT <> *NULL;
    MoveFile();
    P_DIRENT = READDIR( DH );
  EndDo;

  // Close the directory
  RC = CLOSEDIR( DH );

End-Proc;


Dcl-Proc MoveFile;

  // clean the file name
  cleanName = %trim(%subst(D_NAME:1:D_NAMELEN));

  // Ignore . anbd .. entries
  If cleanName in %list('.':'..');
    Return;
  EndIf;

  // build the full file path, this is used instead of the TODIR on the
  // move statement so a rename can be built in if the file exists
  // Strip off the from directory from the path, then add the to directory
  cnt = 0;
  toPth = dstPth + '/' + cleanName;
  orgToPth = toPth;

  // see if a file with the same name exists
  // Call the access API to check for file existence
  // if it does exist, rename it with a counter and try again till it finds one that does not exist.
  rc = access(%trimr(toPth) : F_OK);
  DoW rc = 0;
    cnt += 1;
    // File exists, rename it and try again.
    // find the last . period after the last / and add the rename counter there.
    splitLoc = %scanr('.':%subst(orgToPth:%scanr('/':orgToPth)+1)) + %len(dstPth) + 1;
    If splitLoc = 0;
      toPth = orgToPth + ' (' + %char(cnt) + ')';
    Else;
      toPth = %subst(orgToPth:1:splitLoc-1) + ' (' + %char(cnt) + ')' + %subst(orgToPth:splitLoc);
    EndIf;
    rc = access(%trimr(toPth) : F_OK);
  EndDo;

  frmObj = %trim(frmPth) + '/' + cleanName;

  // Change the CCSID of the from object
  #$CMD('CHGATR OBJ(''' + frmObj + ''') ATR(*CCSID) VALUE(1252)':1);

  Monitor;
    #$CMD('MOV OBJ(''' + %trim(frmObj) + ''') TOOBJ(''' + toPth + ''') +
               FROMCCSID(37) TOCCSID(*PCASCII)':2);
    Addlog('C');
  On-Error;
    Addlog('E');
  EndMon;

End-Proc;

Dcl-Proc AddLog;
  Dcl-Pi *n;
    ifmsts char(1) const;
  End-Pi;

  Exec SQL
    Insert into IFMLOG
          ( frmPth, dstPth, ifmSts, lngCmt)
    Values(:frmObj,:toPth,:ifmSts,trim(:psdsExcDta));

End-Proc;
