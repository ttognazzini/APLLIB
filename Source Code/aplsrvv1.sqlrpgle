**Free
Ctl-Opt NoMain Option(*NoDebugIO:*NoShowCpy:*SrcStmt) STGMDL(*INHERIT);

// Service program used in template programs
//   All exported procedures start with $

// To create this run the following commands:

// crtsqlrpgi obj(qtemp/aplsrvv1) srcfile(APLLIB/QSRC)
//            objtype(*module) dbgview(*source)

// crtsrvpgm  srvpgm(APLLIB/aplsrvv1) module(qtemp/aplsrvv1)
//   TEXT('Service program for Program Templates') BNDSRVPGM((APLLIB/BASFNCV1))
//   export(*srcfile) srcfile(APLLIB/QSRC) srcmbr(APLSRVN1) stgmdl(*inherit)

/Copy QSRC,BASFNCV1PR
/Copy QSRC,APLSRVV1PR
/Copy QSRC,SCRLOCB1PR

// Set the attributes of a field
Dcl-Proc $SetAttribute Export;
  Dcl-Pi *n;
    field Char(1);
    attributes Varchar(50) const;
  End-Pi;
  Dcl-S words Char(6) dim(10);
  Dcl-S i int(5);

  // set to green
  field=x'20';

  // break the attributes into words
  words=%split(#$UPIFY(attributes):', -/\');

  // If a ND is found set as on-display and leave
  For i = 1 To 10;
    If words(i)='ND';
      field = %bitor(field:x'27');
    ElseIf words(i)='PR';
      field=%bitor(field:x'80');
    EndIf;
  EndFor;
  // if non-display leave
  If %bitand(field:x'07')=x'07'; // 07 = 0000 0111
    Return;
  EndIf;

  // Process each color attribute, these replace the current value

  // If you care about how this works
  //   Attributes fields are binary flags passed in one byte variables
  //   the colors are set using bits 4, 5 and 6. The following is the table of colors

  //             bits
  //   Colors  4  5  7
  //   Grn     0  0  0
  //   Wht     0  0  1
  //   Red     0  1  0
  //   Trq     1  0  0  includes column seperators
  //   Ylw     1  0  1  includes column seperators
  //   Pnk     1  1  0
  //   Blu     1  1  1

  For i = 1 To 10;
    If words(i)='GRN' or words(i)='GREEN';
      field=x'20';
    ElseIf words(i)='WHT' or words(i)='WHITE';
      field=x'22';
    ElseIf words(i)='RED';
      field=x'28';
    ElseIf words(i)='TRQ' or words(i)='CS';
      field=x'30';
    ElseIf words(i)='YLW' or words(i)='YELLOW';
      field=x'32';
    ElseIf words(i)='PNK' or words(i)='PINK';
      field=x'38';
    ElseIf words(i)='BLU' or words(i)='BLUE';
      field=x'3A';
    EndIf;
  EndFor;

  // Process each non-color attribute, these turn on bits
  // RI = Reverse image, bit 8
  // PR = Protect, bit 1
  // ND = Non-display, bit 6,7,8
  // UL = Underline, bit 6
  // BL = Blink, only on red, bit 7
  // HI = High Intensity only on not red, bit 7
  // CS = Column Seperators, handled via color turquoise and yellow

  // If you care about how this works:
  //   here is the hex to binary table for single flags
  //     1000 0000 = 80 bit 1
  //     0100 0000 = 40 bit 2
  //     0010 0000 = 20 bit 3
  //     0001 0000 = 10 bit 4
  //     0000 1000 = 08 bit 5
  //     0000 0100 = 04 bit 6
  //     0000 0010 = 02 bit 7
  //     0000 0001 = 01 bit 8
  //   %bitor turns a bit on if it is on in either of the input strings
  //   so %BitOr(x'40':X'20') essential turns on bit 2 and 3
  //   since the color is already set we can turn on the bits for the new attribute
  For i = 1 To 10;
    If words(i)='RI';
      field=%bitor(field:x'01');
    ElseIf words(i)='PR';
      field=%bitor(field:x'80');
    ElseIf words(i)='UL';
      field=%bitor(field:x'04');
    ElseIf words(i)='ND';
      field=%bitor(field:x'07');
    ElseIf words(i)='BL';
      field=%bitor(field:x'02');
    ElseIf words(i)='HI';
      field=%bitor(field:x'02');
    EndIf;
  EndFor;

  // If bits 6,7 and 8 are on the field will be non-displayed, since ND already exited the
  // program, if this happens turn off bit 6. This removes the under line for reverse imaged
  // high intensity fields. This fixes a problem where white, ul, ri is non-dispalyed. SDA
  // works the same way, if you set white, underline and reverse image, the under line will
  // not be displayed.
  If %bitand(field:x'07')=x'07'; // 07 = 0000 0111
    field = %bitand(field:x'FB'); // turn off bit 6, FE = 1111 1011
    // bit and says they both have to be on for the result bit to be on
  EndIf;

End-Proc;


// Handles all error messages
//   adds error to message SFL, turns on error indicator
//   Optionally positions cursor to and highlights a field
// Example for error message only
//   $ErrorMessage('NVT0001');
// Example for error with substitution text and error flag
//   $ErrorMessage('NVT0001':brand:error);
// Example for message with field and substitution text
//   $ErrorMessage('NVT0001':brand1:error:brand1@:'brand1':outRow:outCol:psDsPgmNam);
// Example for message with field, substitution text and an additional flied to highlight
//   $ErrorMessage('NVT0001':brand1:error:brand1@:'brand1':outRow:outCol:psDsPgmNam:brand1@);
// Up to 20 additional attribute fields can be passed.
Dcl-Proc $ErrorMessage Export;
  Dcl-Pi *n;
    parmMessageIdentifier Char(7) const;
    parmMessageSubstituionText Varchar(256) const options(*nopass);
    errorIndicator Ind options(*nopass);
    attributeField Char(1) options(*nopass);
    posToFieldName Char(10) const options(*nopass);
    Row zoned(3:0) options(*nopass);
    col zoned(3:0) options(*nopass);
    programName Char(10) options(*nopass);
    AdditionalAttributeField01 Char(1) options(*nopass);
    AdditionalAttributeField02 Char(1) options(*nopass);
    AdditionalAttributeField03 Char(1) options(*nopass);
    AdditionalAttributeField04 Char(1) options(*nopass);
    AdditionalAttributeField05 Char(1) options(*nopass);
    AdditionalAttributeField06 Char(1) options(*nopass);
    AdditionalAttributeField07 Char(1) options(*nopass);
    AdditionalAttributeField08 Char(1) options(*nopass);
    AdditionalAttributeField09 Char(1) options(*nopass);
    AdditionalAttributeField10 Char(1) options(*nopass);
    AdditionalAttributeField11 Char(1) options(*nopass);
    AdditionalAttributeField12 Char(1) options(*nopass);
    AdditionalAttributeField13 Char(1) options(*nopass);
    AdditionalAttributeField14 Char(1) options(*nopass);
    AdditionalAttributeField15 Char(1) options(*nopass);
    AdditionalAttributeField16 Char(1) options(*nopass);
    AdditionalAttributeField17 Char(1) options(*nopass);
    AdditionalAttributeField18 Char(1) options(*nopass);
    AdditionalAttributeField19 Char(1) options(*nopass);
    AdditionalAttributeField20 Char(1) options(*nopass);
  End-Pi;
  Dcl-S rtnMsgKey Char(4);
  Dcl-S messageIdentifier Char(7);
  Dcl-S messageFile Char(20);
  Dcl-S messageSubstituionText Varchar(256);
  Dcl-Ds errorDs;
    bytesProvided int(10) Inz(0); // no bytes provided will cause it through an exception error
    bytesAvailable int(10);
    exceptionID Char(7);
    reserved Char(1);
    // returnData varchar(xxx);
  End-Ds;
  // Prototype for ibm send message api
  Dcl-Pr QMHSNDPM extpgm('QMHSNDPM');
    msgID Char(7) const;
    msgFile Char(20) const;
    msgData Char(1024) const options(*varsize);
    msgDataLen int(10) const;
    msgType Char(10) const;
    callStkEntry Char(10) const;
    relativeCallStkEntr int(10) const;
    rtnMsgKey Char(4);
    apiErrorDS likeds(errorDs) options(*varsize);
  End-Pr;

  If %parms()>=8;
    // Set the field attributes to reverse image and high intensity
    $SetAttribute(attributeField:'Ri,Cs,Ul');
    // Position to the passed field name
    $GetFieldLocation(programName:posToFieldName:Row:col:errorIndicator);
    // set any additional attribute fields that were passed
    If %parms()>=9;
      $SetAttribute(AdditionalAttributeField01:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=10;
      $SetAttribute(AdditionalAttributeField02:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=11;
      $SetAttribute(AdditionalAttributeField03:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=12;
      $SetAttribute(AdditionalAttributeField04:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=13;
      $SetAttribute(AdditionalAttributeField05:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=14;
      $SetAttribute(AdditionalAttributeField06:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=15;
      $SetAttribute(AdditionalAttributeField07:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=16;
      $SetAttribute(AdditionalAttributeField08:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=17;
      $SetAttribute(AdditionalAttributeField09:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=18;
      $SetAttribute(AdditionalAttributeField10:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=19;
      $SetAttribute(AdditionalAttributeField11:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=20;
      $SetAttribute(AdditionalAttributeField12:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=21;
      $SetAttribute(AdditionalAttributeField13:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=22;
      $SetAttribute(AdditionalAttributeField14:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=23;
      $SetAttribute(AdditionalAttributeField15:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=24;
      $SetAttribute(AdditionalAttributeField16:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=25;
      $SetAttribute(AdditionalAttributeField17:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=26;
      $SetAttribute(AdditionalAttributeField18:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=27;
      $SetAttribute(AdditionalAttributeField19:'Ri,Cs,Ul');
    EndIf;
    If %parms()>=28;
      $SetAttribute(AdditionalAttributeField20:'Ri,Cs,Ul');
    EndIf;
  EndIf;

  // If there is no message id, default it to FAB0000 so the text is just shown
  If parmMessageIdentifier<>'';
    messageIdentifier=parmMessageIdentifier;
  Else;
    messageIdentifier='APL0000';
  EndIf;

  // If the message id, starts with SQ make thw message file the sql one, otherwise
  // use APLMSGF
  If %subst(parmMessageIdentifier:1:2) = 'SQ';
    messageFile = 'QSQLMSG   *LIBL     ';
  Else;
    messageFile = 'APLMSGF   APLLIB    ';
  EndIf;

  // Populate the message substitution text
  If %parms>=2;
    messageSubstituionText=parmMessageSubstituionText;
  Else;
    messageSubstituionText='';
  EndIf;

  // Write error message to the joblog
  Monitor;
    QMHSNDPM(messageIdentifier
          : messageFile
          : messageSubstituionText
          : %size(messageSubstituionText)
          : '*INFO'
          : 'MAIN'
          : 0
          : rtnMsgKey
          : errorDs);
  On-Error;
    QMHSNDPM(messageIdentifier
          : 'QSQLMSG   *LIBL     '
          : messageSubstituionText
          : %size(messageSubstituionText)
          : '*INFO'
          : 'MAIN'
          : 0
          : rtnMsgKey
          : errorDs);
  EndMon;

  // Turn on the passed error indicator
  If %parms>=3;
    errorIndicator=*on;
  EndIf;

End-Proc;


// Clear all subfile messages
Dcl-Proc $ClearMessages Export;
  Dcl-Pr clearMsg extPgm('QMHRMVPM');
    messageq   Char(276)  const;
    CallStack  int(10) const;
    Messagekey Char(4) const;
    messagermv Char(10) const;
    ErrorCode  Char(256);
  End-Pr;
  Dcl-S APIError Char(256);

  clearMsg('MAIN' : 0 : '    ': '*ALL':APIError);

End-Proc;

// Returns a text version of a pressed key
Dcl-Proc $ReturnKey Export;
  Dcl-Pi *n Char(10);
    Key Char(1);
  End-Pi;

  If Key=x'F1';
    Return 'ENTER';
  ElseIf Key=x'F5';
    Return 'PAGEDOWN';
  ElseIf Key=x'F4';
    Return 'PAGEUP';
  ElseIf Key=x'F3';
    Return 'HELP';
  ElseIf Key=x'F6';
    Return 'PRINT';
  ElseIf Key=x'F8';
    Return 'BSPACE';
  ElseIf Key=x'BD';
    Return 'CLEAR1';
  ElseIf Key=x'31';
    Return 'F1';
  ElseIf Key=x'32';
    Return 'F2';
  ElseIf Key=x'33';
    Return 'F3';
  ElseIf Key=x'34';
    Return 'F4';
  ElseIf Key=x'35';
    Return 'F5';
  ElseIf Key=x'36';
    Return 'F6';
  ElseIf Key=x'37';
    Return 'F7';
  ElseIf Key=x'38';
    Return 'F8';
  ElseIf Key=x'39';
    Return 'F9';
  ElseIf Key=x'3A';
    Return 'F10';
  ElseIf Key=x'3B';
    Return 'F11';
  ElseIf Key=x'3C';
    Return 'F12';
  ElseIf Key=x'B1';
    Return 'F13';
  ElseIf Key=x'B2';
    Return 'F14';
  ElseIf Key=x'B3';
    Return 'F15';
  ElseIf Key=x'B4';
    Return 'F16';
  ElseIf Key=x'B5';
    Return 'F17';
  ElseIf Key=x'B6';
    Return 'F18';
  ElseIf Key=x'B7';
    Return 'F19';
  ElseIf Key=x'B8';
    Return 'F20';
  ElseIf Key=x'B9';
    Return 'F21';
  ElseIf Key=x'BA';
    Return 'F22';
  ElseIf Key=x'BB';
    Return 'F23';
  ElseIf Key=x'BC';
    Return 'F24';
  ElseIf Key=x'70';
    Return 'E00';
  ElseIf Key=x'71';
    Return 'E01';
  ElseIf Key=x'72';
    Return 'E02';
  ElseIf Key=x'73';
    Return 'E03';
  ElseIf Key=x'74';
    Return 'E04';
  ElseIf Key=x'75';
    Return 'E05';
  ElseIf Key=x'76';
    Return 'E06';
  ElseIf Key=x'77';
    Return 'E07';
  ElseIf Key=x'78';
    Return 'E08';
  ElseIf Key=x'79';
    Return 'E09';
  ElseIf Key=x'7A';
    Return 'E10';
  ElseIf Key=x'7B';
    Return 'E11';
  ElseIf Key=x'7C';
    Return 'E12';
  ElseIf Key=x'7D';
    Return 'E13';
  ElseIf Key=x'7E';
    Return 'E14';
  ElseIf Key=x'7F';
    Return 'E15';
  Else;
    Return '';
  EndIf;

End-Proc;

// Security Information
// This returns an instance of the $securityDs which contains information about what options
// the user has available in the program, like if they can do maintenance or inquiry or not
// have access at all. Downgrades or set the Option based on authorization
Dcl-Proc $Security Export;
  Dcl-Pi *n likeds($securityDs);
    program Char(10);
    user Char(10);
    option like(APLDCT.option);
  End-Pi;
  Dcl-Ds security likeds($securityDs);

  // everything set to allowed for now, this needs to come from the security system later
  security.allowed=*on;
  security.upd=*on;
  security.create=*on;
  security.inquiry=*on;

  // set Option if not already set
  If option='' and security.upd;
    option='2';
  ElseIf option='' and security.inquiry;
    option='5';
  EndIf;

  // if the Option is maintenance but the user does not have authority cahnge it to inquiry
  If option='2' and not security.upd;
    option='5';
  EndIf;

  Return security;

End-Proc;


// Get the location of a field on the screen

// Pass in the program name for display file name, the field name on the screen,
// and variables to receive the row and column of the screen position.

// The error indicator can be passed as well, if it is and there is no error, the
// location will be set, if there is an error the location will only changed if it
// is further up the screen than the current location.

// The record format/screen name may be passed if there are more than one in the display file
Dcl-Proc $GetFieldLocation Export;
  Dcl-Pi *n;
    programName Char(10);
    fieldName Char(10) const;
    Row zoned(3:0);
    col zoned(3:0);
    error ind options(*nopass:*omit);
    screen Char(10) options(*nopass:*omit);
  End-Pi;
  Dcl-S sourceLibrary Char(10);
  Dcl-S sourceFile Char(10);
  Dcl-S lastUpdate timestamp;
  Dcl-S created timestamp;
  Dcl-S time time;
  Dcl-S date date;
  Dcl-S displayFile Char(10);
  Dcl-S len packed(2:0);
  Dcl-S row2 packed(3:0);
  Dcl-S col2 packed(3:0);

  // Convert the program name to the screen format name. The D in the
  // second to last character becomes an F, check if it exists
  displayFile=programName;
  len=%len(%trimr(programName));
  If len>1 and %subst(programName:len-1:1)='D';
    %subst(displayFile:len-1:1)='F';
  EndIf;
  If not #$ISOBJ(displayFile:'*FILE');
    Return;
  EndIf;

  // see if the SCRLOC file needs to be refreshed
  // compare object creation date to the time stamp on the first field
  // if it was created after the last update, refresh the field list first
  #$ObjD=#$RTVOBJD(displayFile:'*LIBL':'*FILE');
  sourceLibrary=#$ODSrcLib;
  If sourceLibrary = 'QTEMP';
    sourceLibrary=#$ODRtnLib;
  EndIf;
  sourceFile=#$ODSrcFil;
  date=%date(%int(%dec(#$ODcrtDat:13:0)/1000000):*CYMD);
  time=%time(%rem(%dec(#$ODcrtDat:13:0):1000000));
  created = %timestamp(date+time);
  Exec SQL Select crtDtm Into :lastUpdate From APLLIB/SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:displayFile
           Fetch First Row Only;
  If sqlState>='02' or lastUpdate<created;
    SCRLOCB1(sourceLibrary:sourceFile:displayFile);
  EndIf;

  // get the row and column of the field
  If %parms>=6 and %addr(screen) <> *null;
    Exec SQL Select fldRow,fldCol Into :row2,:col2
             From APLLIB/SCRLOC
             Where lib=:sourceLibrary and fle=:sourceFile
               and mbr=upper(:displayFile) and fldNme=upper(:fieldName)
               and RcdFmt=:screen;
  Else;
    Exec SQL Select fldRow,fldCol Into :row2,:col2
             From APLLIB/SCRLOC
             Where lib=:sourceLibrary and fle=:sourceFile
               and mbr=upper(:displayFile) and fldNme=upper(:fieldName);
  EndIf;

  // If an error location is already set and the new one is on a higher
  // line or the same line and an earlier position, set it to the new location
  If %parms<5 or %addr(error) = *null;
    Row=row2;
    col=col2;
  ElseIf error and row2<Row;
    Row=row2;
    col=col2;
  ElseIf error and row2=Row and col2<col;
    Row=row2;
    col=col2;
  ElseIf not error;
    Row=row2;
    col=col2;
  EndIf;

End-Proc;


// Get function key information for this program

// Returns instance of fncDs

// Parameters
//  1. Program Name
//  2. Option, Optional Defaults to 1, 1=Select,2=Maintenance,5=Inquiry
//  3. optDs, optional, omittable, subfile options DS to see if F23 needs to be added
//  4. Screen Size, optional, 40-80 or 132 for screen size width, defaults to 80,
//     builds output string 1 character smaller than the size

// Examples:
//  fncDs=#$GetFunctionKeys(psdsPgmNam);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:Option);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:Option:optDs);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:0:optDs);
//  fncDs=#$GetFunctionKeys(psdsPgmNam:0:*omit:132);
Dcl-Proc $GetFunctionKeys Export;
  Dcl-Pi *n likeds(fncDs);
    programName Char(10) CONST;
    option like(APLDCT.option) const options(*nopass);
    opt LikeDs(optDs) options(*nopass:*omit);
    screenSize Packed(3:0) Value options(*nopass);
  End-Pi;
  Dcl-Ds fnc likeDs(fncDs);
  Dcl-S sqlStm Varchar(500);
  Dcl-S fncKey like(APLDCT.fncKey);
  Dcl-S des like(APLDCT.des);

  Clear fnc;

  // Build SQL statement to retrieve valid command keys
  sqlStm='Select FncKey, Des from APLLIB/PGMFNC Where pgmNme='''+%trim(programName)+''' and acvRow=''1''';
  // add section based on Option
  If %parms()<2;
    sqlStm=sqlStm + ' and Option in ('''',''1'')';
  ElseIf Option<>' ';
    sqlStm=sqlStm + ' and Option in ('''','''+%trim(option)+''')';
  Else;
    sqlStm=sqlStm + ' and Option in ('''',''1'')';
  EndIf;
  sqlStm=sqlStm+' Order by SEQNBR';

  // loop through the file and populate the function key arrays
  Exec SQL Prepare $GetFunctionKeyStm From :sqlStm;
  Exec SQL Declare $GetFunctionKeyCrs Cursor For $GetFunctionKeyStm;
  Exec SQL Open $GetFunctionKeyCrs;
  Exec SQL Fetch Next From $GetFunctionKeyCrs Into :fncKey, :des;
  DoW sqlState<'02';
    fnc.numberOfKeys+=1;
    fnc.function(fnc.numberOfKeys)=fncKey;
    fnc.description(fnc.numberOfKeys)=des;
    $SetAttribute(fnc.attribute(fnc.numberOfKeys):'blue');
    Exec SQL Fetch Next From $GetFunctionKeyCrs Into :fncKey, :des;
  EndDo;
  Exec SQL Close $GetFunctionKeyCrs;

  // Add F23=More Options if there are more than one line of SFL options
  If %parms()>=3 and %addr(opt)<>*Null and opt.numberOfLines>1;
    fnc.F23=*on;
    fnc.numberOfKeys+=1;
    fnc.function(fnc.numberOfKeys)='F23';
    fnc.description(fnc.numberOfKeys)='F23=More Options';
    $SetAttribute(fnc.attribute(fnc.numberOfKeys):'blue');
  EndIf;

  // Set screen size
  If %parms()>=4 and screenSize>=40;
    fnc.screenSize=screenSize;
  EndIf;
  If fnc.screenSize<40;
    fnc.screenSize=80;
  ElseIf fnc.screenSize>132;
    fnc.screenSize=132;
  EndIf;

  // build lines for in data structure
  $BuildFunctionKeyLines(fnc);

  Return fnc;

End-Proc;

Dcl-Proc $BuildFunctionKeyLines;
  Dcl-Pi *n;
    fnc likeDs(fncDs);
  End-Pi;
  Dcl-S totalLength int(5);
  Dcl-S i Int(5);

  // Clear the lines and reset the counter
  Clear fnc.Lines;
  fnc.numberOfLines=1;

  // Get the length of all the command keys to see if the F24=More Keys is needed
  totalLength=0;
  For i = 1 To fnc.numberOfKeys;
    If i = 1;
      totalLength+=1;
    Else;
      totalLength+=3;
    EndIf;
    totalLength+=%len(%trim(fnc.description(i)));
  EndFor;
  If totalLength>fnc.ScreenSize;
    fnc.f24=*on;
  EndIf;

  // loop through the function keys and build the lines
  For i = 1 To fnc.numberOfKeys;
    // see if the description fits into the current line, go to next line if it doesn't
    If %len(%trim(fnc.lines(fnc.numberOfLines)))+3+
       %len(%trim(fnc.description(i)))>fnc.screenSize-1
         and not fnc.F24
      or %len(%trim(fnc.lines(fnc.numberOfLines)))+3+
         %len(%trim(fnc.description(i)))>fnc.screenSize-17
         and fnc.F24;
      If fnc.F24;
        fnc.lines(fnc.numberOfLines)=%trim(fnc.lines(fnc.numberOfLines))+'   F24=More keys';
      EndIf;
      fnc.numberOfLines+=1;
    EndIf;
    // append this key to the line
    If i = 1;
      fnc.lines(fnc.numberOfLines)=%trimr(fnc.lines(fnc.numberOfLines))+
          %trim(fnc.attribute(i))+%trim(fnc.description(i));
    Else;
      fnc.lines(fnc.numberOfLines)=%trimr(fnc.lines(fnc.numberOfLines))+'  '+
          %trim(fnc.attribute(i))+%trim(fnc.description(i));
    EndIf;
    // add to the list of valid funciton keys
    fnc.validationString=%trimr(fnc.validationString) + ' ' + fnc.function(i);
  EndFor;

  // Add F24 if more keys was needed to the last line and the validation
  If fnc.F24;
    fnc.lines(fnc.numberOfLines)=%trim(fnc.lines(fnc.numberOfLines))+'   F24=More keys';
    fnc.validationString=%trimr(fnc.validationString) + ' F24';
  EndIf;

  // if this is being re-built the current line may be greater than the number of lines,
  // if it is change the current line to 1
  If fnc.currentLine>fnc.numberOfLines;
    fnc.currentLine=1;
  EndIf;

End-Proc;


// Validate Key Pressed

// Returns true if a keypressed is valid, otherwise false

// Parameters
//   1. keyPressed, the key pressed
//   2. fncDs, Function key Data Structure

Dcl-Proc $ValidKeyPressed Export;
  Dcl-Pi *n ind;
    keyPressed Char(10) CONST;
    fnc likeds(fncDs);
  End-Pi;

  // Always allow non-funciton keys
  If %subst(keyPressed:1:1)<>'F';
    Return *on;
  EndIf;

  If %scan(' '+%trim(keyPressed):fnc.validationString) = 0;
    Return *Off;
  Else;
    Return *On;
  EndIf;

End-Proc;


// Next Command Keys
// Returns the text for the next line of command keys

// Parameters
//   1. fncDs, Function key Data Structure

Dcl-Proc $NextFunctionKeys Export;
  Dcl-Pi *n Char(131);
    fnc likeds(fncDs);
  End-Pi;

  fnc.currentLine+=1;

  If fnc.currentLine>fnc.numberOfLines;
    fnc.currentLine=1;
  EndIf;

  Return fnc.lines(fnc.currentLine);

End-Proc;


// Changes the text on a function key
// Returns the text for the current line of function keys with any updates
// Parameters
//   1. fncDs, Function key Data Structure
//   2. Function key
//   3. New Text
// Example:
//   fncKeys=$ChangeFuntionKey(fncDs:'F11':'F11=Less Detail');
Dcl-Proc $ChangeFunctionKey Export;
  Dcl-Pi *n Char(131);
    fnc likeds(fncDs);
    functionKey like(APLDCT.FncKey) Const;
    newText like(APLDCT.Des) Const;
  End-Pi;
  Dcl-S i int(5);

  // Find and change the text for the passed function key
  For i = 1 To fnc.numberOfKeys;
    If fnc.function(i) = functionKey;
      fnc.description(i) = newText;
    EndIf;
  EndFor;

  // build lines for in data structure
  $BuildFunctionKeyLines(fnc);

  // return the current line in case it changed
  Return fnc.lines(fnc.currentLine);

End-Proc;


// Changes the attrubutes of a function key
// Returns the text for the current line of function keys with any updates
// Attribute string is the same a for $SetAttributes
// You have to cahnge it back if you want it regular
// Parameters
//   1. fncDs, Function key Data Structure
//   2. Function key
//   3. Attribute String
// Example, changes F2 to red:
//   fncKeys=$ChangeFuntionKeyAttributes(fncDs:'F2':'Red');
// Example, changes F2 back to the default:
//   fncKeys=$ChangeFuntionKeyAttributes(fncDs:'F2':'');
Dcl-Proc $ChangeFunctionKeyAttributes Export;
  Dcl-Pi *n Char(131);
    fnc LikeDs(fncDs);
    functionKey Like(APLDCT.FncKey) Const;
    newAttributes Varchar(50) Const;
  End-Pi;
  Dcl-S i Int(5);

  // Find and change the attribute for the passed function key
  For i = 1 To fnc.numberOfKeys;
    If fnc.function(i) = functionKey;
      $SetAttribute(fnc.attribute(i):newAttributes);
    EndIf;
  EndFor;

  // build lines for in data structure
  $BuildFunctionKeyLines(fnc);

  // return the current line in case it changed
  Return fnc.lines(fnc.currentLine);

End-Proc;


// Get SFL Options for this program

// Returns instance of optDs

// Parameters
//  1. Program Name
//  2. Option, Optional Defaults to 1, 1=Select,2=Maintenance,5=Inquiry
//  3. Screen Size, optional, 40-80 or 132 for screen size width, defaults to 80,
//     builds output string 1 character smaller than the size

// Example: optDs=#$GetSFLOptions(psdspgmNam);
//          optDs=#$GetSFLOptions(psdspgmNam:Option);
//          optDs=#$GetSFLOptions(psdspgmNam:1:132);
Dcl-Proc $GetSFLOptions Export;
  Dcl-Pi *n likeds(optDs);
    programName Char(10) CONST;
    option like(APLDCT.option) const options(*nopass);
    screenSize packed(3:0) Value options(*nopass);
  End-Pi;
  Dcl-Ds opt likeDs(optDs);
  Dcl-S sqlStm Varchar(500);
  Dcl-S optn like(APLDCT.option);
  Dcl-S des like(APLDCT.des);

  Clear opt;

  // Build SQL statement to retrieve valid SFL options
  sqlStm='Select opt, Des from APLLIB/PGMOPT Where pgmNme='''+%trim(programName)+''' and acvRow=''1''';
  // add section based on Option
  If %parms()<2;
    sqlStm=sqlStm + ' and Option in ('''',''1'')';
  ElseIf option<>' ';
    sqlStm=sqlStm + ' and Option in ('''',''' + %trim(option) + ''')';
  Else;
    sqlStm=sqlStm + ' and Option in ('''',''1'')';
  EndIf;
  sqlStm=sqlStm+' Order by opt';

  // loop through the file and populate the SFL options arrays
  Exec SQL Prepare $GetSFLOptionsStm From :sqlStm;
  Exec SQL Declare $GetSFLOptionsCrs Cursor For $GetSFLOptionsStm;
  Exec SQL Open $GetSFLOptionsCrs;
  Exec SQL Fetch Next From $GetSFLOptionsCrs Into :optn, :des;
  DoW sqlState<'02';
    opt.numberOfOptions+=1;
    opt.option(opt.numberOfOptions)=optn;
    opt.description(opt.numberOfOptions)=des;
    $SetAttribute(opt.attribute(opt.numberOfOptions):'blue');
    Exec SQL Fetch Next From $GetSFLOptionsCrs Into :optn, :des;
  EndDo;
  Exec SQL Close $GetSFLOptionsCrs;

  // Set screen size
  If %parms()>=3 and screenSize>=40;
    opt.screenSize=screenSize;
  EndIf;
  If opt.screenSize<40;
    opt.screenSize=80;
  ElseIf opt.screenSize>132;
    opt.screenSize=132;
  EndIf;

  // build lines for in data structure
  $BuildSFLOptionsLines(opt);

  Return opt;
End-Proc;


// Get Next SFL Options String
// Returns the text for the next line of SFL Options
// Parameters
//   1. optDs, SFL Options Data Structure
Dcl-Proc $NextSFLOption export;
  Dcl-Pi *n Char(131);
    opt likeds(optDs);
  End-Pi;
  opt.currentLine+=1;

  If opt.currentLine>opt.numberOfLines;
    opt.currentLine=1;
  EndIf;

  Return opt.lines(opt.currentLine);

End-Proc;


// Changes the text on a SFL option
// Returns the text for the current line of options any updates
// Parameters
//   1. optDs, Function key Data Structure
//   2. option
//   3. New Text
// Example:
//   options=$ChangeSFLOption(optDs:'1':'1=Select');
Dcl-Proc $ChangeSFLOption export;
  Dcl-Pi *n Char(131);
    opt likeds(optDs);
    option like(APLDCT.option) CONST;
    newText like(APLDCT.Des) CONST;
  End-Pi;
  Dcl-S i Int(5);

  // Find and change the text for the passed function key
  For i = 1 To opt.numberOfOptions;
    If opt.option(i) = option;
      opt.description(i) = newText;
    EndIf;
  EndFor;

  // build lines for in data structure
  $BuildSFLOptionsLines(opt);

  // return the current line in case it changed
  Return opt.lines(opt.currentLine);

End-Proc;


// Changes the attrubutes of a SFL option
// Returns the text for the current line of SFL options with any updates
// Attribute string is the same as for $SetAttributes
// You have to change it back if you want it regular
// Parameters
//   1. optDs, SFL Options Data Structure
//   2. Option
//   3. Attribute String
// Example, changes 1 to red:
//   options=$ChangeSFLOptionAttributes(optDs:'1':'Red');
// Example, changes 12 back to the default:
//   options=$ChangeSFLOptionAttributes(optDs:'1':'');
Dcl-Proc $ChangeSFLOptionAttributes Export;
  Dcl-Pi *n Char(131);
    opt likeds(optDs);
    option like(APLDCT.option) CONST;
    newAttributes Varchar(50) CONST;
  End-Pi;
  Dcl-S i Int(5);

  // Find and change the attribute for the passed function key
  For i = 1 To opt.numberOfOptions;
    If opt.option(i) = option;
      $SetAttribute(opt.attribute(i):newAttributes);
    EndIf;
  EndFor;

  // build lines for in data structure
  $BuildSFLOptionsLines(opt);

  // return the current line in case it changed
  Return opt.lines(opt.currentLine);

End-Proc;

// Buil SFL Options Lines
Dcl-Proc $BuildSFLOptionsLines;
  Dcl-Pi *n;
    opt likeDs(optDs);
  End-Pi;
  Dcl-S i Int(5);

  // Clear the lines and reset the counter
  Clear opt.Lines;
  opt.numberOfLines=1;

  // loop through the SFL options and build the lines
  For i = 1 To opt.numberOfOptions;
    // see if the description fits into the current line, go to next line if it doesn't
    If %len(%trim(opt.lines(opt.numberOfLines)))+3+
       %len(%trim(opt.description(i)))>opt.screenSize-3;
      opt.lines(opt.numberOfLines)=%trimr(opt.lines(opt.numberOfLines))+'...';
      opt.numberOfLines+=1;
    EndIf;
    // append this option to the line
    If opt.lines(opt.numberOfLines)='';
      opt.lines(opt.numberOfLines)= %trim(opt.attribute(i))+%trim(opt.description(i));
    Else;
      opt.lines(opt.numberOfLines)=%trimr(opt.lines(opt.numberOfLines))+'  '+
          %trim(opt.attribute(i))+%trim(opt.description(i));
    EndIf;
  EndFor;

  // if there are more than 1 lines, add ... to the last line
  If opt.numberOfLines>1;
    opt.lines(opt.numberOfLines)=%trimr(opt.lines(opt.numberOfLines))+'...';
  EndIf;

  // if this is being re-built the current line may be greater than the number of lines,
  // if it is change the current line to 1
  If opt.currentLine>opt.numberOfLines;
    opt.currentLine=1;
  EndIf;

End-Proc;


// Tests if a SFL option is valid

// Parameters
//   1. options, the entered SFL option
//   2. optDs, SFL Options Data Structure

// Returns true if the option is valid, otherwise false
Dcl-Proc $ValidSFLOption Export;
  Dcl-Pi *n ind;
    option like(APLDCT.option) CONST;
    opt likeds(optDs);
  End-Pi;
  Dcl-S i Int(5);

  // Find and change the attribute for the passed function key
  For i = 1 To opt.numberOfOptions;
    If opt.option(i) = option;
      Return *on;
    EndIf;
  EndFor;

  Return *off;

End-Proc;


// Toggle SFLMode between 1 and 0
Dcl-Proc $ToggleSFLMode Export;
  Dcl-Pi *n;
    sflMode Char(1);
  End-Pi;

  If sflMode='1';
    sflMode='0';
  Else;
    sflMode='1';
  EndIf;

End-Proc;


// Validate an Enumerated Value Description

// Parameters
//   1. Value to test
//   2. Dictionary
//   3. Field Name

// Returns true if the value is valid, otherwise false
Dcl-Proc $ValidEnmDes Export;
  Dcl-Pi *n Ind;
    EnmDes like(APLDCT.EnmDes) Const;
    DctNme like(APLDCT.DctNme) Const;
    FldNme like(APLDCT.FldNme) Const;
  End-Pi;
  Dcl-S found Ind;

  found=*off;
  Exec SQL Select 1 Into :found
           From DctVal
           Where Ucase(DctNme)=Ucase(:DctNme)
             and Ucase(FldNme)=Ucase(:FldNme)
             and ucase(EnmDes)=Ucase(:EnmDes);

  Return found;

End-Proc;


// Validate an SQL Alias

// Parameters
//   1. SQL Alias

// Returns message if invalid, otherwise nothing

// Rules
//   1. Has to start with a character
//   2. Cannot have imbedded spaces
//   3. Can only contain letters, numbers and underscore
Dcl-Proc $ValidSQLAlias Export;
  Dcl-Pi *n Varchar(100);
    SQLAlias like(APLDCT.FldNmeSql) Const;
  End-Pi;
  Dcl-C VALIDCHARACTERS Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_');
  Dcl-C VALIDFIRSTCHARACTER Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ');

  // Make sure the first character is valid
  If %scan(#$UPIFY(%subst(SQLAlias:1:1)):VALIDFIRSTCHARACTER)=0;
    Return 'Invalid first character, must be a letter (A-Z).';
  EndIf;

  // Check for imbedded spaces
  If %scan(' ':%subst(SQLAlias:1:%len(%trimr(#$UPIFY(SQLAlias)))))<>0;
    Return 'Name cannot contain imbedded spaces.';
  EndIf;

  // Check for Valid Characters
  If %check(VALIDCHARACTERS:#$UPIFY(%trim(SQLAlias)))<>0;
    Return 'Name can only contain letters, numbers and the underscore symbol.';
  EndIf;

  Return '';

End-Proc;


// Builld or clean an SQL Alias Field Name

// Parameters
//   1. Column Text or existing SQL alias
//   2. ColHdg, Optional

// Returns generated SQL Alias Name
Dcl-Proc $BuildSQLAlias Export;
  Dcl-Pi *n Like(APLDCT.FldNmeSql);
    ColTxt Like(APLDCT.ColTxt) const;
    ColHdg Like(APLDCT.ColHdg) const Options(*nopass);
  End-Pi;
  Dcl-C VALIDCHARACTERS Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_ ');
  Dcl-C VALIDFIRSTCHARACTER Const('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  Dcl-S Chr Varchar(60);
  Dcl-S ChrUpp Varchar(60);
  Dcl-S Pos Int(3);
  Dcl-S EOP Ind;

  // Start with the column text if populated, otherwise use the column headings
  If ColTxt > *blanks;
    Chr = %trim(ColTxt);
  ElseIf %parms>1 and ColHdg > *blanks;
    Chr = %trim(ColHdg);
  Else;
    Return '';
  EndIf;

  // Remove invalid characters
  EOP=*off;
  DoW not EOP;
    Exec SQL Set :ChrUpp = ucase(:Chr);
    Pos = %check(VALIDCHARACTERS:ChrUpp);
    If Pos = *zeros;
      EOP = *on;
    Else;
      Chr = %replace ('': Chr: Pos: 1);
    EndIf;
  EndDo;

  // Remove double spaces
  Chr=%scanrpl('  ':' ':Chr);

  // replace imbedded blanks with an underscore
  Chr=%scanrpl(' ':'_':Chr);

  // If the length is 10 or less, append an underscore so it does not risk
  // createing a duplciate name with a regular field.
  // Only do this if auto generating.
  If %parms>1 and
     %len(%trim(Chr)) < 11 and %scan('_':%trim(Chr)) = *zeros;
    Chr = %trim(Chr) + '_';
  EndIf;

  // If the first character is not valid, just put an A in front, the user can clean this
  // up in the maintenace if they do not like it
  If %scan(#$UPIFY(%subst(Chr:1:1)):VALIDFIRSTCHARACTER)=0;
    Chr = 'A' + Chr;
  EndIf;

  // make lowercase becasue this is how the web wants them
  Chr=#$LOWFY(Chr);

  Return Chr;


End-Proc;


// Builds search parameter comparisons for where clause in an SQL statement

// This procedure works just like #$BLDSCH, except that it gets the field names
// from the screen. This prevents the need to hardcode all the screen names in the
// new template list programs.

// Parameters
//   1. Program name
//   2. Search string

// Returns generated SQL Alias Name
Dcl-Proc $BuildSearch Export;
  Dcl-Pi *n Varchar(10000);
    pgmNme Char(10) const;
    schVal Varchar(1000) const;
  End-Pi;
  Dcl-S found ind;
  Dcl-S sourceLibrary Char(10);
  Dcl-S sourceFile Char(10);
  Dcl-S sourceMember Char(10);
  Dcl-S len packed(2);
  Dcl-S Count packed(5);
  Dcl-S fldNme Char(10);

  // Convert the program name to the screen format name. The D in the
  // second to last character becomes an F, check if it exists
  sourceMember=pgmNme;
  len=%len(%trimr(pgmNme));
  If len>1 and %subst(pgmNme:len-1:1)='D';
    %subst(sourceMember:len-1:1)='F';
  EndIf;
  If not #$ISOBJ(sourceMember:'*FILE');
    Return '';
  EndIf;

  // Get the source library and file form the objects description
  #$ObjD=#$RTVOBJD(sourceMember:'*LIBL':'*FILE');
  sourceLibrary=#$ODSrcLib;
  sourceFile=#$ODSrcFil;

  // if the source file is not found, try to see if the source is in the objects library and use that if found
  // this is required because the display file is now built out of augmented source in QTEMP.
  If not #$ISMBR(sourceLibrary:sourceFile:sourceMember);
    If  #$ISMBR(#$ODRtnLib:sourceFile:sourceMember);
      sourceLibrary = #$ODRtnLib;
    ElseIf  #$ISMBR(#$ODRtnLib:'QDDSSRC':sourceMember);
      sourceLibrary = #$ODRtnLib;
      sourceFile = 'QDDSSRC';
    ElseIf  #$ISMBR(#$ODRtnLib:'QSRC':sourceMember);
      sourceLibrary = #$ODRtnLib;
      sourceFile = 'QSRC';
    EndIf;
  EndIf;

  // get field names from screen, these will be any field that is displayed and has has a type of SFL
  Clear #$BLDSCHF;
  Count=0;
  found=*off;
  Exec SQL Select '1' Into :found
           From APLLIB/SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='DTA';
  // if no DTA fields found, return nothing, otherwise get the fields
  If not found;
    Return '';
  Else;
    Exec SQL Declare crsDta Cursor For
      Select Distinct fldNme
      From APLLIB/SCRLOC
      Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and extTyp='DTA' and fldCol<>0;
    Exec SQL Open crsDta;
    Exec SQL Fetch Next From crsDta Into :fldNme;
    DoW sqlState<'02';
      Count+=1;
      #$BLDSCHF(Count)=fldNme;
      Exec SQL Fetch Next From crsDta Into :fldNme;
    EndDo;
    Exec SQL Close crsDta;
  EndIf;

  Return %trim(#$BLDSCH(schVal:#$BLDSCHF));

End-Proc;


// Builds message string for the bottom of a SFL screen
Dcl-Proc $BuildSFLMessage Export;
  Dcl-Pi *n Varchar(132);
    numberOfRows Packed(9) Value;
    totalNumberOfRows Packed(9) Value;
    sflPage Packed(9) Value;
    currentRow Packed(9) Value;
    rrn1 Packed(9) Value;
  End-Pi;
  Dcl-S pages packed(7);
  Dcl-S pageNbr packed(7);
  Dcl-S message Varchar(132);

  // Build a message for the page of entries in the SFL. Append filters allied if applicable.
  message='';
  pages=%int(#$RNDUP(numberOfRows/sflPage));
  pageNbr=%int(%int(#$RNDUP((currentRow+rrn1)/sflPage)));

  // if the current record is not the first entry in a page we have to add 1 to the number of pages
  If %rem(currentRow:sflPage)<>0;
    pages+=1;
  EndIf;
  // If the last record is shown force the page to the last page and show last page message
  If numberOfRows-currentRow<=sflPage;
    message='Page '+%char(pages)+' of '+%char(pages) +', last page shown.';
  Else;
    message='Page '+%char(pageNbr)+' of '+%char(pages)+'.';
  EndIf;

  // If the total rows are not equal to number of rows, add it to the message
  If numberOfRows<>totalNumberOfRows;
    message += ' Filtered ' + %char(numberOfRows) + ' rows from ' + %char(totalNumberOfRows) +
               ' rows available.';
  Else;
    message += ' ' + %char(numberOfRows) + ' rows available.';
  EndIf;

  Return message;

End-Proc;


// Gets an attribute field for the user from the User Defaults system
// Decapricated, use $GetUserAttributes going forward.
Dcl-Proc $GetUserAttribute Export;
  Dcl-Pi *n Char(1);
    usr like(APLDCT.usr) Const;
    pgmNme like(APLDCT.pgmNme) Const;
    UDFKey like(APLDCT.UDFKey) Const;
    AdditionalAttributes like(APLDCT.UDFVal) Const options(*nopass);
  End-Pi;
  Dcl-S Value Char(41);
  Dcl-S attr Char(1);

  // Get the default value
  Exec SQL Select UDFDFT Into :Value From UDFMST Where (pgmNme,UDFKey) = (upper(:pgmNme),upper(:UDFKey));

  // Get the department override if found
  Exec SQL Select UDFVal Into :Value
           From UDFDTL
           Where UDFDpt = case when Coalesce((Select acDept From ACCESSPF Where acUprf = upper(:usr)),' ') = ''
                               then 'O/E FAB'
                               else Coalesce((Select acDept From ACCESSPF Where acUprf = upper(:usr)),' ') end
             and (pgmNme,UDFKey) = (upper(:pgmNme),upper(:UDFKey));

  // Get the User override if found
  Exec SQL Select UDFVal Into :Value From UDFDTL
           Where (UDFUsr,pgmNme,UDFKey) = (upper(:usr),upper(:pgmNme),upper(:UDFKey));

  // add additional Attribures if passed
  If %parms()>=4 and %addr(AdditionalAttributes) <> *null;
    Value = %trim(Value) + ',' + %trim(AdditionalAttributes);
  EndIf;

  // get attrbiute from options
  $SetAttribute(attr:Value);

  Return attr;

End-Proc;

// Gets an attribute field for the user from the User Defaults system
// Includes optionl label attribute field
Dcl-Proc $GetUserAttributes Export;
  Dcl-Pi *n;
    atrFld Char(1);
    usr like(APLDCT.usr) Const;
    pgmNme like(APLDCT.pgmNme) Const;
    UDFKey like(APLDCT.UDFKey) Const;
    AdditionalAttributes like(APLDCT.UDFVal) Const options(*nopass:*omit);
    lblAtrFld Char(1) options(*nopass:*omit);
  End-Pi;
  Dcl-S Value Char(41);
  Dcl-S dptValue Char(41);
  Dcl-S usrValue Char(41);

  // Get the default value
  Exec SQL Select UDFDFT Into :Value From UDFMST Where (pgmNme,UDFKey) = (upper(:pgmNme),upper(:UDFKey));

  // Get the department override if found
  Exec SQL Select UDFVal Into :dptValue
           From UDFDTL
           Where UDFDpt = case when Coalesce((Select acDept From ACCESSPF Where acUprf = upper(:usr)),' ') = ''
                               then 'O/E FAB'
                               else Coalesce((Select acDept From ACCESSPF Where acUprf = upper(:usr)),' ') end
             and (pgmNme,UDFKey) = (upper(:pgmNme),upper(:UDFKey));
  If dptValue<>'';
    Value = dptValue;
  EndIf;

  // Get the User override if found
  Exec SQL Select UDFVal Into :usrValue From UDFDTL
           Where (UDFUsr,pgmNme,UDFKey) = (upper(:usr),upper(:pgmNme),upper(:UDFKey));
  If usrValue<>'';
    Value = usrValue;
  EndIf;

  // add additional Attribures if passed
  If %parms()>=5 and %addr(AdditionalAttributes) <> *null;
    Value = %trim(Value) + ',' + %trim(AdditionalAttributes);
  EndIf;

  // get attrbiute from options
  $SetAttribute(atrFld:Value);

  // build and return label attributes if passed
  If %parms()>=6 and %addr(lblAtrFld) <> *null;
    // if non-display return non-display otherwise return green
    If %bitand(atrFld:x'07')=x'07';
      lblAtrFld = x'27';
    Else;
      lblAtrFld = '';
    EndIf;
  EndIf;

  Return;

End-Proc;


// Validate an Enumerated Value Value

// Parameters
//   1. Value to test
//   2. Dictionary
//   3. Field Name

// Returns true if the value is valid, otherwise false
Dcl-Proc $ValidEnmVal Export;
  Dcl-Pi *n Ind;
    EnmVal like(APLDCT.EnmVal) Const;
    DctNme like(APLDCT.DctNme) Const;
    FldNme like(APLDCT.FldNme) Const;
  End-Pi;
  Dcl-S found Ind;

  found=*off;
  Exec SQL Select 1 Into :found
           From DctVal
           Where Ucase(DctNme)=Ucase(:DctNme)
             and Ucase(FldNme)=Ucase(:FldNme)
             and ucase(EnmVal)=Ucase(:EnmVal);

  Return found;

End-Proc;
