**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) Main(Main);

// Fix Second level text

// Called from MONMSQC2, replaces &N with <BR> so the text in the email is formatted correctly.
// It also doubles up any quotes so they do not blow up the email command.

Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

// Datastructure used to read an entry from the cursor into
Dcl-Ds msg qualified;
  dtm      timestamp;
  key      char(4);
  id       varchar(7);
  type     varchar(13);
  severity packed(4);
  txt      varchar(1024);
  frmUsr   varchar(10);
  frmJob   varchar(26);
  frmPgm   varchar(10);
  secTxt   varchar(4096);
End-Ds;

Dcl-S msqLib varchar(10) inz('QSYS');
Dcl-S msqNme varchar(10) inz('QSYSOPR');
Dcl-S emlTo  varchar(50) inz('tim.tognazzini@arrowheadwinch.com');
Dcl-S debug  varchar(4) inz('*YES');
Dcl-S lstPrc timestamp;


// Prototype for sleep, sleep for a number of seconds
Dcl-Pr Sleep Int(10) EXTPROC('sleep');
  seconds    Uns(10) VALUE;
End-Pr;

// Prototype for qcmdexc
Dcl-Pr Cmd EXTPGM('QCMDEXC');
  command     Char(32768) const;
  length      Packed(15:5) const;
End-Pr;

// Program status data structure, used to get job infomration
Dcl-Ds psds  psds qualified; //Pgm status DS
  data       Char(429); //The data
  jobNme     Char(10)   OVERLAY(data:244); // Job name
  usrNme     Char(10)   OVERLAY(data:254); // User profile name
  jobNbr     Char(6)    OVERLAY(data:264); // Job number
End-Ds;


// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('MONMSQB1');
    pmrMsqLib char(10);
    pmrMsqNme char(10);
    pmrEmlTo char(51);
    pmrDebug char(4);
  End-Pi;

  If %parms >= 3;
    msqLib = %trim(pmrMsqLib);
    msqNme = %trim(pmrMsqNme);
    emlTo = %trim(%subst(pmrEmlTo:1:50));
  EndIf;
  If %parms >= 4;
    debug = pmrDebug;
  EndIf;

  If debug = '*YES';
    Snd-Msg 'Queue monitoring started for queue ' + %char(msqLib) + '/' + %char(msqNme);
    Snd-Msg 'Messages will be emailed to ' + emlTo;
  EndIf;

  // only start processing from when the program starts
  lstPrc = %timestamp();

  // for testing set the time stamp to one second before last message
  If debug = '*YES';
    Exec SQL
        Select message_timestamp - 1 second
        Into  :lstPrc
        From qsys2.message_queue_info
        Where message_queue_library = :msqLib
          and message_queue_name = :msqNme
          and (severity >= 40 or message_type ='INQUIRY')
          and message_id <> 'CPA3394' // ignore printer forms errors
          and message_id <> 'PQT3625' // ignore connection retries
        ORDER BY message_timestamp DESC
        limit 1;
    If sqlState < '02';
      Snd-Msg 'Starting timestamp set to ' + %char(lstPrc) + '. This is 1 second before the last messsage.';
    ElseIf sqlState = '02000';
      Snd-Msg 'No messages found to test, will monitor till one exists.';
    Else;
      Snd-Msg 'Initial timestamp load failed, sqlState = ' + sqlState;
    EndIf;
  EndIf;


  // never ending loop
  DoW 1 = 1;

    // loop through message queue process all message since the last one processed
    Exec SQL declare sqlCrs cursor for
      Select
        message_timestamp,
        MESSAGE_KEY,
        MESSAGE_ID,
        MESSAGE_TYPE,
        SEVERITY,
        coalesce(cast(message_text as char(1200) ccsid 37),'') msgTxt,
        from_user,
        from_job,
        from_program,
        coalesce(cast(MESSAGE_SECOND_LEVEL_TEXT as char(4096) ccsid 37),'') secLvl
      From qsys2.message_queue_info
      Where message_queue_library = :msqLib
        and message_queue_name = :msqNme
        and (severity >= 40 or message_type ='INQUIRY')
        and message_id <> 'CPA3394' // ignore printer forms errors
        and message_id <> 'PQT3625' // ignore connection retries
        and message_timestamp > :lstPrc
      ORDER BY message_timestamp DESC;
    Exec SQL Open sqlCrs;
    Exec SQL Fetch Next From sqlCrs into :msg;
    If debug = '*YES' and sqlState > '02000';
      Snd-Msg 'Error getting messages, sqlState = ' + sqlState;
    ElseIf debug = '*YES' and sqlState = '02000';
      Snd-Msg 'No messages found to report.';
    EndIf;
    DoW sqlState < '02';
      If debug = '*YES';
        Snd-Msg 'Error message found, sending email';
      EndIf;
      EmailMessage();
      lstPrc = msg.dtm;
      Exec SQL Fetch Next From sqlCrs into :msg;
    EndDo;
    Exec SQL Close sqlCrs;

    // delay job 30 second before trying again
    If debug = '*YES';
      Snd-Msg 'Done processing message, waiting for 30 seconds to try again.';
    EndIf;
    Sleep(30);
    If debug = '*YES';
      Snd-Msg 'Done waiting, starting process over.';
    EndIf;

  EndDo;

End-Proc;


Dcl-Proc EmailMessage;
  Dcl-S subject varchar(100);
  Dcl-S message varchar(8000);
  Dcl-S command varchar(10000);

  // in the second level text, convert &n to <br><br>, &n is for line breaks
  // Then convert &P to <br>, &p in thinks starts a new paragraph
  msg.secTxt = %scanrpl('&N' :'<br><br>':msg.secTxt);
  msg.secTxt = %scanrpl('&P' :'<br>':msg.secTxt);

  subject = 'AS400 Message monitoring, MSGQ(' + %trim(msqLib) + '/' + %trim(msqNme) + ')';

  message = '+
          This message is from a message monitoring job for message queue ' +
          %trim(msqLib) + '/' + %trim(msqNme) +
          '. The message queue received the following message.' +
          '<br><br>Message ID: ' + %trim(msg.id) +
          '.<br>Message Text: ' + %trim(msg.txt) +
          '<br>Job: ' + msg.frmJob +
          '.<br><br>Secondary Message Text: ' +
          %trim(msg.secTxt) +
          '<br><br>The message is still in the message queue to be reviewed.' +
          '<br><br><small>This message is being sent by job ' +
          psds.jobNme + '/' + psds.usrNme + '/' + psds.jobNbr +
          ', this job was started using the command MONMSQ</small>';

  // duoble up an quotes in the subject and message
  subject = %scanrpl('''' :'''''' :subject);
  message = %scanrpl('''' :'''''' :message);

  // email using for RJS
  command = 'RJSSMTP/SMTPSEND +
               TOADDR(' + emlTo + ') +
               SUBJECT(''' + subject + ''') +
               MESSAGE(''' + message + ''') +
               CONTYPE(''text/html'')';

  // email using KeyesMail, doesn't handle HTML -  NOT TESTED
  // command = 'KMLTXTMSG TOADDR(''' + emlTo + ''') +
  //              SUBJECT(''' + subject + ''') +
  //              TEXT(''' + message + ''')';

  // email using GumboMail - NOT TESTED
  // command = 'GUMBOMAIL/GSENDMAIL +
  //              TOSMTPNAME((''' + emlTo + ''')) +
  //              SUBJECT(''' + subject + ''') +
  //              MSG(''' + message + ''' *TEXTHTML)';

  // run the command to send the email
  If debug = '*YES';
    Snd-Msg 'Running command ' + command;
  EndIf;
  Cmd(command:%len(command));

End-Proc;
