**free
Ctl-Opt Option(*srcStmt) DftActGrp(*NO) BndDir('APLLIB/APLLIB') Main(Main) ActGrp(*new);

// Check Status of Batch Jobs

/Copy APLLIB/QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Data structure to reference all fields from dictionaries
Dcl-Ds APLDCT extname('APLLIB/APLDCT') Qualified Template End-Ds;

Dcl-S emlMsg varchar(10000);
Dcl-S error ind;
Dcl-S oddRow ind;
Dcl-S tdStyle varchar(200);

Dcl-Ds dta;
  jobNme like(APLDCT.jobNme);
  sbsNme like(APLDCT.sbsNme);
  sbsLib like(APLDCT.sbsLib);
  jobTtl like(APLDCT.jobTtl);
  strCmd like(APLDCT.strCmd);
  lngCmt like(APLDCT.lngCmt);
End-Ds;

Dcl-Proc Main;
  tdStyle = ' style="border: 1px solid #444; padding: 5px; min-width: 100px;"';

  Clear error;
  Clear oddRow;
  emlMsg = 'The following is a list of batch jobs a that should be running.<br><br> +
            This email is only sent if at least 1 of the background jobs is not +
            running.<br><br>+
            <table style="table-layout: fixed; border-collapse: collapse;">+
              <thead bgColor="#1b6b9c" style="background-color: #1b6b9c; color: #ffffff;">+
                <tr bgColor="#1b6b9c" style="background-color: #1b6b9c; color: #ffffff;">+
                  <td' + tdStyle + '><strong>Job Name</strong></td>+
                  <td' + tdStyle + '><strong>Subsystem</strong></td>+
                  <td' + tdStyle + '><strong>Status</strong></td>+
                  <td' + tdStyle + '><strong>Job Description</strong></td>+
                </tr>+
              </thead>+
              <tbody>';

  Clear dta;
  Exec SQL Declare sqlCrs Cursor for
    Select jobNme, sbsNme,sbsLib,jobTtl,strCmd,lngCmt
    From APLLIB.CHKBJB
    Where acvRow = '1';
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs into :dta;
  DoW sqlState < '02';
    CheckJob();
    Exec SQL Fetch Next From sqlCrs into :dta;
  EndDo;
  Exec SQL Close sqlCrs;

  emlMsg += '</tbody></table><br><br>+
             <small>+
               This email is created by program ' + %trim(psdsPgmNam) + '. +
               The to email addresses are hard coded in the program and may need +
               to be changed as employees come and go. The batch jobs it monitors +
               are in file APLLIB/CHKBJB. +
               The job is run in the Robot job sceduler job name CHKBJBB1.+
             </small>';

  // for testing set always send the email
  // error = *on;

  If error;
    #$CMD('RJSSMTP/SMTPSEND +
             TOADDR(''tim.tognazzini@arrowheadwinch.com'' +
                    ''mike.reese@arrowheadwinch.com'') +
             FROMADDR(''as400@arrowheadwinch.com'') +
             SUBJECT(''AS400 Batch Jobs Not Running (' + %trim(psdsPgmNam) + ')'') +
             MESSAGE(''' + #$DBLQ(emlMsg) + ''') +
             CONTYPE(''text/html'')');
  EndIf;

End-Proc;


Dcl-Proc CheckJob;
  Dcl-S status varchar(20);
  Dcl-S style varchar(200);
  Dcl-S trStyle varchar(200);

  If #$ACTJOB(jobNme:*OMIT:*OMIT:sbsNme:sbsLib);
    status = 'Active';
    style = ' style="border: 1px solid #404040; padding: 5px; min-width: 100px; color: #175317;"';
  Else;
    status = 'Inactive';
    style = ' style="border: 1px solid #404040; padding: 5px; min-width: 100px; color: #ff0000;"';
    error = *on;
    If strCmd <> '';
      Monitor;
        #$CMD(%trim(strCmd):2);
        jobTtl += ', attemping to start.';
      On-Error;
        jobTtl += ', attemp to start failed.';
      EndMon;
    EndIf;
  EndIf;

  // setup an alternating row background color change
  If oddRow;
    trStyle = ' bgColor=#abd7fb style="background-color: #abd7fb;"';
    oddRow = *off;
  Else;
    trStyle = ' bgColor=#ffffff style="background-color: #fefefe;"';
    oddRow = *on;
  EndIf;

  emlMsg += '<tr' + trStyle + '>+
               <td' + tdStyle + '>' + %trim(jobNme) + '</td>+
               <td' + tdStyle + '>' + %trim(sbsLib) + '/' + %trim(sbsNme) + '</td>+
               <td' + style + '>' + status +'</td>+
               <td' + tdStyle + '>' + %trim(jobTtl) + '</td>+
            </tr>';

End-Proc;
