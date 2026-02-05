**free
Ctl-Opt OPTION(*SRCSTMT) DFTACTGRP(*NO) BNDDIR('APLLIB') Main(Main);

// DSPDTAQD - DISPLAY DATA QUEUE

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,DSPDTQD1PR // prototypes for data queue procedures

Dcl-S queueData char(128);
Dcl-S keyData char(5);

// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;

Dcl-Proc Main;

  // Delete the data queue if it exists
  #$CMD('dltdtaq APLLIB/DSPDTQB1':1);

  Snd-Msg 'Creating a test data queue';
  #$CMD('CRTDTAQ DTAQ(APLLIB/DSPDTQB1) +
                      MAXLEN(128) +
                      SEQ(*KEYED) +
                      KEYLEN(5) +
                      TEXT(''Test Data Queue for DSPDTQB1'')');

  Snd-Msg 'Adding a few entries to it';
  #$SNDDTAQ('DSPDTQB1':'APLLIB':128:'Entry 1, key 3':5:'3');
  #$SNDDTAQ('DSPDTQB1':'APLLIB':128:'Entry 2, key 2':5:'2');
  #$SNDDTAQ('DSPDTQB1':'APLLIB':128:'Entry 3, key 1':5:'1');
  #$SNDDTAQ('DSPDTQB1':'APLLIB':128:'Entry 4, key 3':5:'3');
  #$SNDDTAQ('DSPDTQB1':'APLLIB':128:'Entry 5, key 2':5:'2');

  // test reading the first entry, should be entry 3, since it is the first
  // key 1 entry, since it is keyed, a variable must be supplied to read
  // the key value into and the full second options group must be passed
  Clear keyData;
  #$RCVDTAQ('DSPDTQB1':'APLLIB':128:queueData:1:'GE':5:keyData:%len(#$DTAQSNDINF):#$DTAQSNDINF);
  Snd-Msg 'reading first entry, value of :' + queueData;

End-Proc;
