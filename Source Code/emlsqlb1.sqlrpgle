**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) BndDir('APLLIB') actgrp(*new) Main(Main);

// Email the results of an sql table as an excel file

// Uses command EMLSQL, also called from the SQL command which should be used going forward

Dcl-Ds emailDs Template Qualified;
  Count int(5);
  email Char(50) dim(50);
End-Ds;

Dcl-S cmd Varchar(10000);
Dcl-S i int(5);
Dcl-S file Char(128);
Dcl-S zipName Char(128);
Dcl-S distEmls Char(2048);
Dcl-S email Char(50);

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,SQLCMDV1PR // Protypes and definitions for the SQL command

Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;

Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('EMLSQLB1');
    SQLCmd Char(5000);
    fileName Char(123);
    fileType Char(5);
    readAble Char(4);
    zip Char(4);
    useText Char(4);
    sheet Char(32);
    title1 Char(80);
    title2 Char(80);
    title3 Char(80);
    title4 Char(80);
    title5 Char(80);
    emails LikeDs(emailDs);
    rptDstId Char(10);
    subject Char(128);
    message LikeDs(messDs);
    empty Char(4);
    psObjects LikeDs(objectsDs);
    psQueries likeDs(queriesDs);
  End-Pi;
  Dcl-S tpSheet char(32);
  tpSheet=sheet;


  // The objects parameter is passed with a 5i field followed by an array of 6 bytes for each
  // element, then the data, we have to trim off the first part to get the real data
  Clear objects;
  If psObjects.count>0;
    For i=1 To psObjects.count;
      objects(i)=%subst(%subst(psObjects.data:(psObjects.count*2)+1:9000):(i-1)*140+1:140);
    EndFor;
  EndIf;

  // the queries parameter is passed with a 5i field followed by
  // an array of 6 bytes for each element, then the data
  // we have to trim off the first part to get the real data
  Clear queries;
  If psQueries.count>0;
    For i=1 To psQueries.count;
      queries(psQueries.count-i+1)=%subst(psQueries.data:((i-1)*5432)+1+(psQueries.count*2)+(i*2)
                                          :5432);
    EndFor;
  EndIf;

  // Get the current users email address, used as default to and for from address
  // Exec SQL Select ACEMAIL Into :email From ACCESSPF Where acUPrf=:User;

  // If the email is *CURRENT get the email address from the user
  For i=1 To emails.count;
    If emails.email(i)='*CURRENT' or emails.email(i)=' ' and emails.email(i)<>'*RPTDSTID';
      emails.email(i)=email;
      If emails.email(i)=' ';
        #$DSPWIN('Error - Email address not found.');
        Return;
      EndIf;
    EndIf;
  EndFor;

  // Make sure the email address is valid
  For i=1 To emails.count;
    If emails.email(i)>' ' and emails.email(i)<>'*RPTDSTID';
      If #$VEML(emails.email(i));
        #$DSPWIN('Error - Invalid email address: ' + %trim(emails.email(i)) );
        Return;
      EndIf;
    EndIf;
  EndFor;

  // Build default file name if one is not passed
  If fileName=' ';
    fileName='TEMP-' +
        %editw(%dec(%char(%date():*ISO0):8:0):'    -  - 0') + '-' +
        %trim(%editw(%dec(%char(%time():*HMS0):6:0):'  -  -  '));
  EndIf;

  // If the file name does have the correct extension, add it
  If fileType='*XML' and #$UPIFY(#$LAST(fileName:4)) <> '.XML';
    fileName=%trim(fileName)+'.xml';
  EndIf;
  If fileType='*CSV' and #$UPIFY(#$LAST(fileName:4)) <> '.CSV';
    fileName=%trim(fileName)+'.csv';
  EndIf;
  If fileType='*XLS' and #$UPIFY(#$LAST(fileName:5)) <> '.XLSX';
    fileName=%trim(fileName)+'.xlsx';
  EndIf;
  If fileType='*JSON' and #$UPIFY(#$LAST(fileName:5)) <> '.JSON';
    fileName=%trim(fileName)+'.json';
  EndIf;

  // Append '/ACOM/email/tmp/' to the file name so the file is created in that directory
  file='/ACOM/EMAIL/TMP/' + %trim(fileName);

  // Build file
  If fileType='*JSON';
    BuildJson(SQLCmd:file:empty:readAble:useText:title1:title2:title3:title4:title5:queries);
  Else;
    BuildPCFile(SQLCmd:file:fileType:empty:useText:
                tpSheet:title1:title2:title3:title4:title5:queries);
  EndIf;

  // Zip the file if requested
  If zip='*YES';
    // build full zip file path
    zipName=%trim(fileName);
    file=%trim(file)+'.zip';
    cmd='ZIPFILE FROMFILE('''+%trim(fileName)+''') +
                   TOFILE('''+%trim(zipName)+''') +
                   DIRSTR(''/ACOM/EMAIL/TMP'')';
    #$CMD(cmd:2);
  EndIf;

  // Make sure the file is there, if empty=*no then the file may not have been created
  If empty='*NO' and access(%trim(file): F_OK) < 0;
    #$SNDMSG('Empty result set, email not sent.');
    Return;
  EndIf;

  // Build the email command
  cmd='RJSSMTP/SMTPSEND TOADDR(';

  // Add all passed email addresses
  For i=1 To emails.count;
    If emails.email(i)<>' ' and emails.email(i)<>'*RPTDSTID';
      cmd+= ' (' + %trim(emails.email(i)) + ')';
    EndIf;
  EndFor;
  If rptDstId<>' ';   // Add report distribution id if passed
    GetEmailsFromRPT(rptDstId:distEmls);
    cmd+= ' ' + %trim(distEmls);
  EndIf;
  cmd+= ')'; // End the emails section

  // Add the subject if passed
  If subject<>' ' and subject<>'*NONE';
    cmd+= ' SUBJECT('''+ %trim(#$DBLQ(subject)) + ''')';
  EndIf;

  // Add the message if passed
  If message.message<>' ' and message.message<>'*NONE';
    // cmd+= ' MESSAGE(''' + %trim(#$DblQ(message.message)) +''' '+ %trim(message.type) + ')';
    cmd+= ' MESSAGE(''' + %trim(#$DBLQ(message.message)) +''')';
  EndIf;
  // add content typeif HTML
  If message.type = '*TEXTHTML';
    cmd+= ' CONTYPE(''text/html'')';
  EndIf;

  // Add the sql output, this will always be the first object
  cmd+= ' ATTACHMENT((''' + %trim(file) + ''')';
  // Add any passed objects
  If psObjects.count>0;
    For i=1 To psObjects.count;
      If objects(i).name<>' ';
        cmd+= ' (''' + %trim(objects(i).name) + '''';
        If objects(i).type<>' ';
          cmd+= ' ' + %trim(objects(i).type);
        EndIf;
        cmd+= ')';
      EndIf;
    EndFor;
  EndIf;
  cmd+= ')'; // End the object section

  // Append from address if it is populate
  If email<>' ';
    cmd+= ' FROMADDR(''' + %trim(email) + ''')';
  EndIf;

  // Run the email command
  #$CMD(cmd);

  // Delete the temp file
  #$CMD(('DEL ''' + %trim(file) +''''));

End-Proc;
