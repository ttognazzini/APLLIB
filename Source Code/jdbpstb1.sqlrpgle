**FREE
// This program sets up the Java environment needed to do Postgres connections
// This was abrstracted out so it did not have to duplciated in addtional programs

Ctl-Opt DftActGrp(*No) BndDir('APLLIB/APLLIB') Option(*Srcstmt) DatFmt(*ISO) main(Main);

/copy QSRC,JDBSRVV1PR // Scott Klements JDBCR4 service program headers
/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// Prototypes
Dcl-Pr putenv int(10) extproc('putenv');
  *n pointer value options(*string:*trim) ;
End-Pr;

// -- Get environment variable:
Dcl-Pr getenv Pointer EXTPROC( 'getenv' );
  EnvDta Pointer VALUE OPTIONS(*STRING);
End-Pr;

Dcl-S ok           Ind;

Dcl-Pr CHECKSTDIO extpgm end-pr;

// Program variable definitions...
Dcl-S envVar varchar(1024);

Dcl-Proc Main;

  Monitor;
    // Set CLASSPATH
    #$SNDMSg('Setting classpath');
    envVar= '/java/postgresql-42.7.5.jar';
    putenv('CLASSPATH=' + envVar);

    // Set up parameters for Java exceptions handling
    If putenv('QIBM_USE_DESCRIPTOR_STDIO='+ 'Y') <> 0;
      #$SNDMSg('Error adding environmental variable: QIBM_USE_DESCRIPTOR_STDIO':'*ESCAPE');
    EndIf;

    // first retrieve the env var and see if if needs to append or overwrite it
    envVar = %str( getenv( 'QIBM_RPG_JAVA_PROPERTIES' ));
    If envVar = '' or %scan(envVar:'-Dos400.stderr=') <> 0;
      envVar = '-Dos400.stderr=file:/tog/mystderr.txt;';
    Else;
      // add semicolon to end if it is not already there
      If %subst(envVar:%len(envVar):1) = ';';
        envVar += ';';
      EndIf;
      envVar += ';-Dos400.stderr=file:/tog/mystderr.txt;';
    EndIf;
    // I fnot already in the string, add user time zone, it cannot be the sytem defautl of UTC,
    // that does not work with Postgres
    If envVar = '' or %scan(envVar:'-Duser.timezone=') = 0;
      // add semicolon to end if it is not already there
      If %subst(envVar:%len(envVar):1) = ';';
        envVar += ';';
      EndIf;
      envVar += ';-Duser.timezone=UTC;';
    EndIf;
    If putenv('QIBM_RPG_JAVA_PROPERTIES='+ envVar) <> 0;
      #$SNDMSg('Error adding environmental variable: QIBM_RPG_JAVA_PROPERTIES':'*ESCAPE');
    EndIf;

    If putenv('QIBM_RPG_JAVA_EXCP_TRACE='+ 'Y') <> 0;
      #$SNDMSg('Error adding environmental variable: QIBM_RPG_JAVA_EXCP_TRACE':'*ESCAPE');
    EndIf;

  On-Error;
    #$SNDMSg('Error adding environmental variables':'*ESCAPE');

  EndMon;

  // The below code is used as part of the setup necessary to see
  // the Java output from an interactive job. This code ensures that the
  // three "Standard I/O" descriptors 0, 1, and 2 are opened.
  // The environmental variables above forces the java environment to
  // write exception data to a file in the IFS, I think ensure that it will work

  // Validate or open descriptors 0, 1 and 2
  ok =  chk (0 : 0 + O_CREAT + O_TRUNC + O_RDWR
               : 0 + S_IRUSR + S_IROTH
               : 0 + O_RDONLY)
    and chk (1 : 0 + O_CREAT + O_TRUNC + O_WRONLY
               : 0 + S_IWUSR + S_IWOTH
               : 0 + O_RDWR)
    and chk (2 : 0 + O_CREAT + O_TRUNC + O_WRONLY
               : 0 + S_IWUSR + S_IWOTH
               : 0 + O_RDWR);

  // If the descriptors were not all correct, signal an exception error
  If not ok;
    #$SNDMSg('Descriptors 0, 1 and 2 not opened successfully.':'*ESCAPE');
  EndIf;

End-Proc;

// Does something, see https://www.ibm.com/support/pages/getting-java-exception-trace-file-ile-rpg-calling-java
Dcl-Proc chk;
  Dcl-Pi chk Ind;
    Descriptor     Int(10)    VALUE;
    mode           Int(10)    VALUE;
    aut            Int(10)    VALUE;
    other_valid_mode Int(10)    VALUE;
  End-Pi;
  Dcl-Pr open Int(10) EXTPROC('open');
    filename       Pointer    VALUE OPTIONS(*STRING);
    mode           Int(10)    VALUE;
    aut            Int(10)    VALUE;
    unused         Int(10)    VALUE OPTIONS(*NOPASS);
  End-Pr;

  Dcl-Pr closeFile Int(10) EXTPROC('close');
    handle         Int(10)    VALUE;
  End-Pr;

  Dcl-Pr fcntl Int(10) EXTPROC('fcntl');
    Descriptor     Int(10)    VALUE;
    action         Int(10)    VALUE;
    arg            Int(10)    VALUE OPTIONS(*NOPASS);
  End-Pr;

  Dcl-C F_GETFL    X'06';

  Dcl-S flags        Int(10);
  Dcl-S new_desc     Int(10);

  Dcl-S actual_acc   Int(10);
  Dcl-S required_acc Int(10);
  Dcl-S allowed_acc  Int(10);
  Dcl-S o_accmode    Int(10);

  o_accmode = %bitor(O_RDONLY : %bitor(O_WRONLY : O_RDWR));

  flags = fcntl (Descriptor : F_GETFL);
  If flags < 0;
    // no flags returned, attempt to open this descriptor
    new_desc = open ('/dev/null' : mode : aut);
    If new_desc <> Descriptor;
      // we didn't get the right descriptor number, so
      // close the one we got and return '0'
      If new_desc >= 0;
        closeFile (new_desc);
      EndIf;
      Return '0';
    EndIf;
  Else;
    // check if the file was opened with the correct access mode
    actual_acc = %bitand (flags : o_accmode);
    required_acc = %bitand (mode : o_accmode);
    allowed_acc = %bitand (other_valid_mode : o_accmode);
    If  actual_acc <> required_acc
                  and actual_acc <> allowed_acc;
      Return '0';
    EndIf;
  EndIf;
  Return '1';

End-Proc;
