**Free
Ctl-Opt Option(*SRCSTMT) DftActGrp(*no) BndDir('APLLIB') Main(Main);

// DSPDTAQD - Display Data Queue

Dcl-F DSPDTQF1 WORKSTN SFILE(F2S:RRN);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,DSPDTQD1PR // prototypes for data queue procedures

// Convert hex to character
Dcl-Pr CVTHC  EXTPROC('cvthc');
  *N             Pointer    VALUE; //    RECEIVER POINTER
  *N             Pointer    VALUE; //    SOURCE POINTER
  *N             Int(10)    VALUE; //    RECEIVER LENGTH
End-Pr;

// Globals for Paramteres
Dcl-S dtaQ char(20);

// Stand alone variables
Dcl-S I            Packed(5:0);
Dcl-S RRN          Packed(5:0);
Dcl-S TEMPQDS      Char(116);
Dcl-S COLUMNSHIFT  Int(10);
Dcl-S FORCOUNT     Int(10);
Dcl-S OFS          Int(10);
Dcl-S QTRIMLEN     Int(10);
Dcl-S V0200LEN     Int(10);
Dcl-S XX           Int(10);
Dcl-S BYTESAVAIL   Int(10);
Dcl-S FF           Uns(5);
Dcl-S SHIFT        Uns(5)     INZ(58);
Dcl-S ISHEXMODE    Ind;
Dcl-S PAGESIZE     Uns(3)     INZ(14);
Dcl-S STARTPTR     Pointer    INZ(*NULL);
Dcl-S ENTRYCOUNT   Uns(3);

Dcl-C CRULER1 CONST('....+....1....+....2....+....3....+....4+
                     ....+....5....+....6....+....7....+....8+
                     ....+....9....+....0....+....1....+....2+
                     ....+....3....+....4....+....5....+....6+
                     ....+....7....+....8....+....9....+....0+
                     ....+....1....+....2');

Dcl-C CRULER2  CONST('. . . . + . . . . 1 . . . . + . . . . 2 +
                      . . . . + . . . . 3 . . . . + . . . . 4 +
                      . . . . + . . . . 5 . . . . + . . . . 6 +
                      . . . . + . . . . 7 . . . . + . . . . 8 +
                      . . . . + . . . . 9 . . . . + . . . . 0 +
                      . . . . + . . . . 1 . . . . + . . . . 2 +
                      . . . . + . . . . 3 . . . . + . . . . 4 +
                      . . . . + . . . . 5 . . . . + . . . . 6 +
                      . . . . + . . . . 7 . . . . + . . . . 8 +
                      . . . . + . . . . 9 . . . . + . . . . 0 ');

// Move pointer through message entries
Dcl-Ds LISTENTRYDS  QUALIFIED BASED(LISTENTRYPTR);
  NEXTENTRY      Int(10);
  DATETIME       Char(8); //TOD format
  MESSAGEDATA    Char(1000); //Variable text
End-Ds;

// Divide entry up into subfile fields
Dcl-Ds VIEWQDS  INZ;
  VIEWQ1;
  VIEWQ2;
End-Ds;

Dcl-Pr CVTDATTIM  EXTPGM('QWCCVTDT');
  PINPFMT        Char(10)   CONST;
  PINPVAL        Char(8)    CONST;
  POUTFMT        Char(10)   CONST;
  POUTVAL                   LIKEDS(SCDDATTIM);
  ERRORCODE                 LIKEDS(#$DTAQERR) OPTIONS(*NOPASS);
End-Pr;

Dcl-Ds SCDDATTIM;
  SCDDAT         Zoned(8:0);
  SCDHMS         Zoned(6:0);
  SCDMS          Zoned(3:0);
End-Ds;

Dcl-Proc Main;
  Dcl-Pi *n ExtPGm('DSPDTQD1');
    pmrDtaQ char(20);
  End-Pi;

  dtaQ = pmrDtaQ;

  PROCF1();

End-Proc;


// Process Screen 1
Dcl-Proc PROCF1;

  MOVEF1();

  DoW not *inlr;
    Exfmt F1;

    // F3 and F12 = Exit
    If *IN03 OR *IN12;
      Leave;
    EndIf;

    // F5 = Refresh
    If *IN05;
      MOVEF1();
      ITER;
    EndIf;

    // F6 = View entries
    If *IN06;
      If CURMSGS = '0 ';
        ERM = #$CNTR('No entries to display':50);
        *in50 = *on;
        Iter;
      EndIf;
      PROCF2();
      ITER;
    EndIf;

    // FXX=Any other function key so the screen doesnt lock up
    If *IN27;
      ERM = #$CNTR('ERROR - INVALID FUNCTION KEY.':50);
      ITER;
    EndIf;

    Leave;
  EndDo;

End-Proc;


// Load Screen 1
Dcl-Proc MOVEF1;

  // Retrieve data queue information
  Clear   #$DATAF1;
  Clear   #$DATAF2;
  #$RTVDTAQD(#$DATAF1 : %size(#$DATAF1) : 'RDQD0100' : dtaQ );

  If %error AND PSDSEXCTYP = 'CPF' AND PSDSEXCNBR = '9801';
    Clear   F1;
    ERM=%trim(PSDSEXCDTA);
    ERM=#$CNTR(%trim(ERM):50);
    *In50 = *On;
    Return;
  EndIf;

  If #$DTAQ_TYPE = '1' AND NOT %error;
    #$RTVDTAQD(#$DATAF2 : %size(#$DATAF2) : 'RDQD0200' : dtaQ );
  EndIf;

  If #$AUTO_RCL = '1';
    AUTORCL = '*YES';
  Else;
    AUTORCL = '*NO';
  EndIf;

  If #$FORCE_WRITE = 'Y';
    FORCEWRITE = '*YES';
  Else;
    FORCEWRITE = '*NO';
  EndIf;

  If #$SENDER_ID= 'Y';
    SENDERID= '*YES';
  Else;
    SENDERID= '*NO';
  EndIf;

  SELECT;
    WHEN #$Q_SEQ = 'F';
      DTAQSEQ= '*FIFO';
    WHEN #$Q_SEQ = 'K';
      DTAQSEQ= '*KEYED';
    WHEN #$Q_SEQ = 'L';
      DTAQSEQ= '*LIFO';
  ENDSL;

  // Convert the numeric entries to left-justified char values
  MAXLEN = %char(#$MAX_LEN);
  If #$Q_SEQ = 'K';
    KEYLEN = %char(#$KEY_LEN);
  Else;
    KEYLEN = 'N/A';
  EndIf;
  CURMSGS= %char(#$CUR_MSGS);
  CURCAP = %char(#$CURENTRY_CA);
  MAXENTRY = %char(#$MAX_ENTRY);
  INITENTRY = %char(#$INIT_ENTRY);

End-Proc;


// Process Screen 2
Dcl-Proc PROCF2;

  MOVEF2();

  DoW NOT *INLR;
    XX = OFS + 1;
    DoW XX > 100;
      XX -= 100;
    EndDo;
    If ISHEXMODE;
      SCRULER = %subst(CRULER2: (XX*2) - 1);
    Else;
      SCRULER = %subst(CRULER1: XX);
    EndIf;

    If OFS = 0;
      %subst(SCRULER: 1: 1) = '*';
    EndIf;

    *IN31 = (RRN > 0);
    *IN32 = *ON;

    Write F2F;
    Exfmt F2C;

    // F3=Exit
    If *IN03;
      DEALLOC(N) #$RTVDTAQPTR;
      *INLR = *ON;
      Return;

      // F12=Cancel
    ElseIf *IN12;
      DEALLOC(N) #$RTVDTAQPTR;
      Return;

      // *IN25=Screen changed
    ElseIf    *IN25;
      If        VENTNUM = 0;
        EVAL      VENTNUM = 1;
      ElseIf    VENTNUM > #$RTVDTAQDS.MSGRTNCOUNT;
        EVAL      VENTNUM = #$RTVDTAQDS.MSGRTNCOUNT;
      EndIf;
      SRLOADONEPAGE();
      ITER;

      // Pageup
    ElseIf *IN47;
      If VENTNUM - PAGESIZE < 0;
        VENTNUM = 1;
      Else;
        VENTNUM -= PAGESIZE;
      EndIf;
      SRLOADONEPAGE();
      ITER;

      // Pagedown
    ElseIf *IN46;
      If VENTNUM + PAGESIZE <= #$RTVDTAQDS.MSGRTNCOUNT; //;
        VENTNUM += PAGESIZE;
      EndIf;
      SRLOADONEPAGE();
      ITER;

      // F6=Show last message
    ElseIf *IN06;
      VENTNUM = #$RTVDTAQDS.MSGRTNCOUNT;
      SRLOADONEPAGE();

      // F5=Refresh
    ElseIf *IN05;
      MOVEF2();
      ITER;

      // Change display mode
    ElseIf *IN10;
      If ISHEXMODE;
        ISHEXMODE = *OFF;
        SHIFT = 58;
      Else;
        ISHEXMODE = *ON;
        SHIFT = 25;
      EndIf;

      SRUPDSFL();
      ITER;

      // F14=Toggle between key and data
    ElseIf *IN14;
      *IN51 = NOT *IN51;
      SRUPDSFL();

      // F7 or F19 = Shift column position to left
    ElseIf *IN07 OR *IN19;
      COLUMNSHIFT -= SHIFT;
      If COLUMNSHIFT < 0;
        COLUMNSHIFT = 1;
      EndIf;
      VDSPPOS = COLUMNSHIFT;

      // F8 or F20 = Shift column position to right
    ElseIf *IN08 OR *IN20;
      COLUMNSHIFT += SHIFT;
      If COLUMNSHIFT >= #$MAX_LEN;
        COLUMNSHIFT = #$MAX_LEN - 1;
      EndIf;
      VDSPPOS = COLUMNSHIFT;
    EndIf;

    // Determine column offset user wants to display.
    If VDSPPOS > 0;
      OFS = VDSPPOS - 1;
      If OFS < 0;
        OFS = 0;
      EndIf;
      If OFS >= #$MAX_LEN;
        OFS = #$MAX_LEN - 1;
      EndIf;
      SRUPDSFL();
      VPOS = OFS + 1;
      VDSPPOS = 0;
    EndIf;

  EndDo;

End-Proc;


// Load Screen 2
Dcl-Proc MOVEF2;

  VPOS = 1;
  #$RTVDTAQPTR = %alloc(1);

  MOVEF1();

  // Different type dataqs require different parm list to api.
  // an anomaly is that usual method of retrieving 8 bytes to get
  // bytes available does not work.

  If #$Q_SEQ = 'K';
    SACCESSTYP = '*KEYED ('+%char(#$KEY_LEN)+')';
    *In52 = *On;
    rdqs0200DS.MSGBYTERTV = #$MAX_LEN;
    rdqs0200DS.KEYBYTERTV = #$KEY_LEN;
    rdqs0200DS.KEYLEN = #$KEY_LEN;
    V0200LEN = #$MAX_LEN + 16;
    Clear #$DTAQERR;
    Clear #$RTVDTAQDS;

    #$RTVDTAQPTR = %realloc(#$RTVDTAQPTR: %len(#$RTVDTAQDS));
    #$RTVDTAQM(#$RTVDTAQDS: %len(#$RTVDTAQDS): 'RDQM0200': dtaQ: rdqs0200DS
                               : V0200LEN: 'RDQS0200': #$DTAQERR);

    BYTESAVAIL = #$RTVDTAQDS.BYTESAVL;

    // Use pointer based allocated memory as api can return more entries
    // than allowed by normal rpg field lengths or *sgnlvl storage
    #$RTVDTAQPTR= %realloc(#$RTVDTAQPTR:BYTESAVAIL);

    #$RTVDTAQM(#$RTVDTAQDS:BYTESAVAIL:'RDQM0200':dtaQ:rdqs0200DS: V0200LEN:'RDQS0200':#$DTAQERR);
  Else;
    SACCESSTYP = '*NON-KEYED';
    *In52 = *Off;
    rdqs0100DS.MSGBYTERTV = #$MAX_LEN;

    #$RTVDTAQPTR=%realloc(#$RTVDTAQPTR: %len(#$RTVDTAQDS));

    #$RTVDTAQM( #$RTVDTAQDS:%len(#$RTVDTAQDS): 'RDQM0100':dtaQ:
                   rdqs0100DS: %size(rdqs0100DS): 'RDQS0100': #$DTAQERR);
    BYTESAVAIL = #$RTVDTAQDS.BYTESAVL;

    #$RTVDTAQPTR = %realloc(#$RTVDTAQPTR:BYTESAVAIL);
    #$RTVDTAQM( #$RTVDTAQDS: BYTESAVAIL: 'RDQM0100': dtaQ:
                     rdqs0100DS: %size(rdqs0100DS): 'RDQS0100': #$DTAQERR);
  EndIf;

  VENTNUM = 1;
  SRLOADONEPAGE();

  // Display subfile. calc number of screens in subfile.
  VSRECNUM = 1;
  COLUMNSHIFT = 0;
  SENTRYLEN = #$MAX_LEN;
  VQTOTCNT = #$RTVDTAQDS.MSGAVLCOUNT;
  SCOBJHEAD = %subst(dtaQ: 1: 10) + '  ' + #$RTVDTAQDS.DTAQLIB + '  ' +
                      #$TEXTDESC;
End-Proc;


// Spin through allocated memory to load one page from selected list entry
Dcl-Proc SRLOADONEPAGE;

  // CLEAR SFL
  RRN = 0;
  *IN31 = *OFF;
  *IN32 = *OFF;
  Write F2C;

  // I need to get the list entry pointer to where the first subfile record
  // will be loaded from.  only way i know is (since offset to next
  // entry could be variable) is to spin through x number of entries
  // so pointer is in right place to load next page of subfile.

  If #$RTVDTAQDS.MSGRTNCOUNT > 0;
    LISTENTRYPTR = #$RTVDTAQPTR + #$RTVDTAQDS.OFFSETTOENTR;
    *IN34 = *OFF;

    For FORCOUNT = 1 TO (VENTNUM-1);
      If FORCOUNT > #$RTVDTAQDS.MSGRTNCOUNT;
        Leave;
      EndIf;
      LISTENTRYPTR = #$RTVDTAQPTR + LISTENTRYDS.NEXTENTRY;
    EndFor;

    // Save starting pointer position
    STARTPTR =  LISTENTRYPTR;
    ENTRYCOUNT = 0;

    For FORCOUNT = VENTNUM TO VENTNUM+(PAGESIZE-1);
      If FORCOUNT > #$RTVDTAQDS.MSGRTNCOUNT;
        *IN34 = *ON;
        Leave;
      EndIf;

      // Save entry count
      ENTRYCOUNT += 1;

      // Convert *dts system time stamp data to usable date
      CVTDATTIM('*DTS': LISTENTRYDS.DATETIME: '*YYMD': SCDDATTIM:#$DTAQERR);
      QUDATE = %editc(SCDDAT:'Y');
      QUTIME = %editw(SCDHMS:'  :  : 0');

      SRTEMPQDS();
      SRDATATODSP();
      RRN += 1;
      Write F2S;
      If RRN = 9999;
        Leave;
      EndIf;

      LISTENTRYPTR = #$RTVDTAQPTR + LISTENTRYDS.NEXTENTRY;
    EndFor;
  EndIf;

End-Proc;


// Update subfile.
Dcl-Proc SRUPDSFL;

  LISTENTRYPTR = STARTPTR;
  For XX = 1 TO ENTRYCOUNT;
    Chain XX F2S;
    SRTEMPQDS();
    SRDATATODSP();
    Update F2S;
    LISTENTRYPTR = #$RTVDTAQPTR + LISTENTRYDS.NEXTENTRY;
  EndFor;

End-Proc;


// Fill tempqds from allocated memory.
// if keyed data queue, then there is unexplained 5 bytes at beginning of e
// size of msg entry could be larger than msg variable.
// qtrimlen makes sure this does not blow up!
Dcl-Proc SRTEMPQDS;
  QTRIMLEN = #$MAX_LEN - OFS;

  If #$Q_SEQ = 'K';
    If (#$MAX_LEN + 5) + #$MAX_LEN > %size(LISTENTRYDS.MESSAGEDATA);
      QTRIMLEN = %size(LISTENTRYDS.MESSAGEDATA) - (#$KEY_LEN + 5);
    EndIf;

    If QTRIMLEN > %len(VIEWQDS);
      QTRIMLEN = %len(VIEWQDS);
    EndIf;

    // Entry/key display mode.
    If *IN51;
      TEMPQDS = %subst(LISTENTRYDS.MESSAGEDATA: OFS + 5: #$KEY_LEN);
    Else;
      TEMPQDS = %subst(LISTENTRYDS.MESSAGEDATA: #$KEY_LEN+OFS+5:QTRIMLEN);
    EndIf;

  Else;
    If #$MAX_LEN > %size(LISTENTRYDS.MESSAGEDATA);
      QTRIMLEN = %size(LISTENTRYDS.MESSAGEDATA);
    EndIf;

    If QTRIMLEN > %len(VIEWQDS);
      QTRIMLEN = %len(VIEWQDS);
    EndIf;

    // When actual message received is shorter than maximum entry possible
    If OFS + 1 <= %size(LISTENTRYDS.MESSAGEDATA);
      TEMPQDS=%subst(LISTENTRYDS.MESSAGEDATA:OFS+1);
    Else;
      TEMPQDS = *BLANKS;
    EndIf;
  EndIf;

End-Proc;


// Move data to display fields.
Dcl-Proc SRDATATODSP;
  If ISHEXMODE;
    VIEWQDS = '';
    CVTHC(%addr(VIEWQDS): %addr(TEMPQDS): QTRIMLEN * 2);
  Else;
    VIEWQDS = %subst(TEMPQDS: 1);

    // Drop anything below hex 40 before sending to screen.
    FF = QTRIMLEN;
    For I = 1 TO FF;
      If %subst(VIEWQDS: I: 1) < X'40';
        %subst(VIEWQDS: I: 1) = ' ';
      EndIf;
    EndFor;

    If QTRIMLEN + 1 < %len(VIEWQDS);
      %subst(VIEWQDS: QTRIMLEN + 1) = *ALL' ';
    EndIf;
  EndIf;

End-Proc;
