**Free
Ctl-Opt Option(*SrcStmt) Actgrp(*new) DftActGrp(*No) BndDir('APLLIB/APLLIB') Main(Main);

// Update SCRLOC File for a DSPF Source Member
// Also creates the XXXXXXDX_Q member for the screen


Dcl-Ds SCRLOC extname('SCRLOC') Qualified Template End-Ds;

// globals for input parameters
Dcl-S sourceLibrary Char(10);
Dcl-S sourceFile    Char(10);
Dcl-S sourceMember  Char(10);

// globals for file level values
Dcl-S fileReferenceLibrary Char(10);
Dcl-S fileReferenceFile Char(10);
Dcl-S sflPage packed(5);
Dcl-S isSFLDrop ind;
Dcl-S currentFormat Char(10);
Dcl-S currentFormatType Char(10);
Dcl-S columns int(5);

Dcl-S sqlStm Varchar(500);
Dcl-S found Ind;

Dcl-Ds dta2;
  fldNme like(SCRLOC.fldNme);
  fldLen like(SCRLOC.fldLen);
  fldScl like(SCRLOC.fldScl);
  fldTyp like(SCRLOC.fldTyp);
  refFle like(SCRLOC.refFle);
  refFld like(SCRLOC.refFld);
  fldCol like(SCRLOC.fldCol);
  extTyp like(SCRLOC.extTyp);
End-Ds;

// Flags that the lines are still in a record format definition, This is turned on when a record format is started
// and then turned off when the first field definition starts
Dcl-S recordDefinition ind;

// For one line read from a source file, breaks the columns out
Dcl-Ds lineBreakDown;
  line Char(100) ;
  comm Char(5) overlay(line:1);
  type Char(1) overlay(line:6);
  comment Char(1) overlay(line:7);
  comment5 Char(5) overlay(line:7);
  record Char(1) overlay(line:17);
  name Char(10) overlay(line:19);
  ref Char(1) overlay(line:29);
  length Char(3) overlay(line:32);
  dataType Char(1) overlay(line:35);
  scale Char(2) overlay(line:36);  // scale = decimal positions
  use Char(1) overlay(line:38);
  rowNumber Char(3) overlay(line:39);
  colNumber Char(3) overlay(line:42);
  function  Char(36) overlay(line:45);
End-Ds;

// Accumulation of details for one field on the screen
// Since one fields spans multiple source lines, this program accumlates all the information and then
// writes the field record before the next break is found.
Dcl-Ds field Qualified;
  // this first group of fields is from the dds directly
  comm Char(5);     // this is the first 5 characters of the line, before the A
  name Char(10);    // field name from DDS
  ref Char(1);      // ref flag from DDS
  length Char(3);   // the length from the DDS
  dataType Char(1); // data type from DDS
  scale Char(2);    // the scale from the DDS
  use Char(1);      // use column from DDS
  line Char(3);     // the row on the screen
  position Char(3); // the column on the screen
  functionCount int(5); // the number of functions found in dds
  functions Varchar(500) Dim(20);  // Array containing each function found in dds
  // the rest of these are calculated
  type Char(10);    // type spelled out
  extendedType like(SCRLOC.extTyp); // DTA if in a SFL, ATTR-KEY, ATTR-Copy, ATTR, POS-Postion to field
  Row packed(3:0); // the row on the screen
  col packed(3:0); // the column on the screen
  len packed(3:0); // the caluclated length, including referenced sizes
  scl like(SCRLOC.fldScl); // the calculated scale, including referenced sizes
  referenceField Char(10);
  referenceLibrary Char(10);
  referenceFile Char(10);
  sortDesc Char(1);  // Makes the sort descending for SFL columns
End-Ds;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
// Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,SCRLOCB1PR // Always include the prototype for the current program

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Proc Main;
  Dcl-Pi *n extPgm('SCRLOCB1');
    pmrSourceLibrary Char(10) const;
    pmrSourceFile    Char(10) const;
    pmrSourceMember  Char(10) const;
  End-Pi;
  sourceLibrary = pmrSourceLibrary;
  sourceFile    = pmrSourceFile;
  sourceMember  = pmrSourceMember;

  // Make sure the file exists
  If not #$ISMBR(sourceLibrary:sourceFile:sourceMember);
    #$SNDMSG('Error member '+%trim(sourceLibrary)+'/'+%trim(sourceFile)+','+
              %trim(sourceMember) + ' not found, SCRLOC not updated.':'*INFO');
  EndIf;

  // Create an alias to the member
  Exec SQL Drop Alias QTEMP/SCRLOCALS;
  sqlStm='Create or Replace Alias QTEMP/SCRLOCALS For ' +
        %trim(sourceLibrary) +'/' + %trim(sourceFile) + '("' +
        %trim(sourceMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // Remove all entries for the file
  Exec SQL Delete From SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember;

  // Loop through the alias, add each field to the file
  currentFormat='';
  recordDefinition=*off;
  Exec SQL Declare SQLCrs Cursor For Select srcDta From QTEMP/SCRLOCALS;
  Exec SQL Open SQLCrs;
  Exec SQL Fetch Next From SQLCRS Into :line;
  DoW sqlState<'02';
    processLine();
    Exec SQL Fetch Next From SQLCRS Into :line;
  EndDo;
  Exec SQL Close SQLCrs;

  // Add the last field if one was started
  If field.name<>' ';
    writeField();
    Clear field;
  EndIf;

  // Create the XXXXXXFX_@ member
  Create_@();

  // Create the XXXXXXDX_2 member, only if there is at least one POS type entry
  found=*off;
  Exec SQL Select '1' Into :found
           From SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%';
  If found;
    Create_2();
  EndIf;

End-Proc;


// Process one line for a source file
Dcl-Proc processLine;

  // If a comment of *DESC, flag the current field as sort descending
  If %upper(comment5)='*DESC';
    field.sortDesc = 'Y';
  EndIf;

  // Ignore if a comment line or not an A spec
  If comment='*' or type<>'A';
    Return;
  EndIf;

  // If in header, see if there is a file level reference file and lib
  If currentFormat=' ' and %scan('REF(':#$UPIFY(function))<>0;
    ParseRefFile(function:fileReferenceLibrary:fileReferenceFile);
  EndIf;

  // Start checking for record format definittions, once an R is found, it will be turned
  // off on the first line that has something in any field except the function. This is needed
  // because all prameters for a record format can be on any line after the R line until
  // something else is started.
  If record='R';
    recordDefinition=*on;
  ElseIf recordDefinition
     and (name<>'' or ref<>'' or length<>'' or dataType<>'' or scale<>'' or use<>'' or rowNumber<>'' or colNumber<>'');
    recordDefinition=*off;
  EndIf;

  // If it is a new record format and a field is already started write it out and reset the field values.
  If record='R' and field.name<>' ';
    writeField();
    Clear field;
  EndIf;

  // populate current format type for a SFL or SFLCTL
  If recordDefinition and %scan('SFL ':function)>0;
    currentFormatType = 'SFL';
  ElseIf recordDefinition and %scan('SFLCTL(':function)>0;
    currentFormatType = 'SFLCTL';
  EndIf;

  // If it is a new record format, set the currentFormat and leave
  If record = 'R' and name <> ' ';
    // If a field is already started write it out nd reset the field values.
    If field.name <> ' ';
      writeField();
      Clear field;
    EndIf;
    currentFormat = name;
    Return;
  EndIf;

  // ignore if not in a record format yet
  If currentFormat = ' ';
    Return;
  EndIf;

  // if there is a SFLPAG property save the highest value
  // skip if in record format MSGCTL, MSGCTL always has a SFL page even if the screen does not
  If recordDefinition and %scan('SFLPAG(':function) > 0 and currentFormat <> 'MSGCTL';
    SetSFLPage(function);
  EndIf;

  // test if there is a SFLDROP
  If recordDefinition and %scan('SFLDROP(':function)>0;
    isSFLDrop = *on;
  EndIf;

  // if there is a screen location or name we have started a new field, write the old one if it exists, clear the field
  // data structure and start accumulating new field data
  If name <> '' or rowNumber <> '' or use <> '';
    If field.name <> ' ';
      writeField();
    EndIf;
    Clear field;
    field.comm = comm;
    field.name = name;
    field.ref = ref;
    field.length = length;
    field.dataType = dataType;
    field.scale = scale;
    field.use = use;
    field.line = rowNumber;
    field.position = colNumber;
  EndIf;

  // if there is anything in the function, add it to the fields function array
  If field.name<>'' and function<>'';
    field.functionCount+=1;
    field.functions(field.functionCount)=function;
    // if the function ends in - it means it runs to the next line, so get the next line and concatinate it to this
    // one, if could span several lines so loop until there is not more than one.
    DoW #$LAST(function:1)='-';
      // strip the last character, because it is the -
      field.functions(field.functionCount)=
        %subst(field.functions(field.functionCount):1:%len(field.functions(field.functionCount))-1);
      Exec SQL Fetch Next From SQLCRS Into :line;
      field.functions(field.functionCount)+=function;
    EndDo;
  EndIf;


End-Proc;


// Writes one line for a field file, this only gets called before the next field starts, this is required because the
// functions on the field can go on for several lines after the field is started.
Dcl-Proc writeField;
  Dcl-S i int(5);

  // If the name is populated we need to figure out the field type.
  // If it is a passed field that ends with @ we force it to type of "Attr"
  // If it is a displayed or hidden field, we use the type based on the data type character
  If field.name<>' ';
    If field.use='P' and #$LAST(field.name:1)='@';
      field.type='ATTR';
    ElseIf field.dataType='A';
      field.type='CHAR';
    ElseIf field.dataType='D' and field.scale='';
      field.type='CHAR';
    ElseIf field.dataType='D' and field.scale<>'';
      field.type='ZONED';
    ElseIf field.dataType='E';
      field.type='DBCS-EITHER';
    ElseIf field.dataType='F';
      field.type='FLOAT';
    ElseIf field.dataType='G';
      field.type='DBCS-GRAPHIC';
    ElseIf field.dataType='I' and field.scale='';
      field.type='CHAR';
    ElseIf field.dataType='I' and field.scale<>'';
      field.type='ZONED';
    ElseIf field.dataType='J';
      field.type='DBCS-ONLY';
    ElseIf field.dataType='L';
      field.type='DATE';
    ElseIf field.dataType='M';
      field.type='CHAR';
    ElseIf field.dataType='N' and field.scale='';
      field.type='CHAR';
    ElseIf field.dataType='N' and field.scale<>'';
      field.type='ZONED';
    ElseIf field.dataType='O';
      field.type='DBCS-OPEN';
    ElseIf field.dataType='S';
      field.type='ZONED';
    ElseIf field.dataType='T';
      field.type='TIME';
    ElseIf field.dataType='W';
      field.type='CHAR';
    ElseIf field.dataType='X';
      field.type='CHAR';
    ElseIf field.dataType='Y';
      field.type='ZONED';
    ElseIf field.ref='R';
      field.type='REFERENCED';
    ElseIf field.ref=' ';
      field.type='CHAR';
    Else;
      field.type='ERROR';
    EndIf;
  EndIf;

  // set class
  // class will include atrribute fields, atrribute keys,atrrbiute copy, dta and pos
  // these will be used to create the XXXXXXDX_@ member for the display program
  If currentFormatType = 'SFL' and #$IN(field.use:'O':'B':'H':'I') and field.name<>'SEL';
    field.extendedType='DTA';
  ElseIf field.use='P' and #$LAST(field.name:1)='@' and #$UPIFY(%trim(field.comm))='KEY';
    field.extendedType='ATTR-KEY';
  ElseIf field.use='P' and #$LAST(field.name:1)='@' and #$UPIFY(%trim(field.comm))='COPY';
    field.extendedType='ATTR-COPY';
  ElseIf field.use='P' and #$LAST(field.name:1)='@';
    field.extendedType='ATTR';
  ElseIf currentFormatType = 'SFLCTL' and field.use='B' and #$LAST(field.name:1)='1' and field.name<>'SEL1';
    // make sure the position to field exists in the SFL, another field may end in a 1 like and address line 1
    Clear found;
    Exec SQL
      Select '1' into :found from SCRLOC
      Where (lib,fle,mbr) = (:sourceLibrary,:sourceFile,:sourceMember)
        and rcdFmtTyp = 'SFL'
        and fldNme = substr(:field.name,1,length(trim(:field.name)) - 1)
        Limit 1;
    If found and field.sortDesc = 'Y';
      field.extendedType='POSDESC';
    ElseIf found;
      field.extendedType='POS';
    EndIf;
  Else;
    field.extendedType=' ';
  EndIf;

  // get the row and column number
  field.row=#$RVL(field.line);
  field.col=#$RVL(field.position);

  // if the field is a reference field, default to the field name and the file reference,
  // the is will be overridden later if a REFFLD keyword is found
  If field.ref='R';
    field.referenceLibrary=fileReferenceLibrary;
    field.referenceFile=fileReferenceFile;
    field.referenceField=field.name;
  Else;
    Clear field.referenceLibrary;
    Clear field.referenceFile;
    Clear field.referenceField;
  EndIf;

  // If a REFFLD keyword is found in the functions, update the refields.
  For i = 1 To field.functionCount;
    If %scan('REFFLD(':field.functions(i))<>0;
      ParseRefField(field.functions(i):field.referenceLibrary:field.referenceFile:field.referenceField);
      If field.referenceLibrary='';
        field.referenceLibrary=fileReferenceLibrary;
      EndIf;
      If field.referenceFile='';
        field.referenceFile=fileReferenceFile;
      EndIf;
      If field.referenceField='';
        field.referenceField=name;
      EndIf;
    EndIf;
  EndFor;

  // if any of field reference values are missing, set them to the default
  If field.ref='R';
    If field.referenceLibrary='';
      field.referenceLibrary=fileReferenceLibrary;
    EndIf;
    If field.referenceFile='';
      field.referenceFile=fileReferenceFile;
    EndIf;
    If field.referenceField='';
      field.referenceField=field.name;
    EndIf;
  EndIf;

  // if the refrence library is *LIBL get the actual name
  If field.referenceLibrary = '*LIBL';
    #$ObjD=#$RTVOBJD(field.referenceFile:'*LIBL':'*FILE');
    If #$ODRTNLIB<>'';
      field.referenceLibrary= #$ODRTNLIB;
    EndIf;
  EndIf;

  // If a field is referenced and the type is not overridden on the screen, get the length and type from the dictionary
  If field.ref='R' and field.dataType='';
    Exec SQL Select fldTyp, fldLen, fldScl Into :field.type, :field.len, :field.scl
             From dctfld Where dctnme=:field.referenceFile and fldNme=:field.referenceField;
    // if not found in the dictionary get the values from syscolumns, happens if any non-dictionary file is referenced
    If sqlState>='02';
      Exec SQL
        Select data_type,   length,     coalesce(scale,0)
        Into   :field.type, :field.len, :field.scl
        From   syscolumns
        Where  SYS_CNAME = :field.referenceField
          and  SYS_TNAME = :field.referenceFile
          and  SYS_DNAME = :field.referenceLibrary;
    EndIf;
  EndIf;

  // If the length is 0 try to populate it from the the type for types that are fixed lengths
  If field.len = 0 and field.Type = 'SMALLINT';
    field.Len = 5;
  ElseIf field.len = 0 and field.type = 'INTEGER';
    field.Len = 10;
  ElseIf field.len = 0 and field.type = 'BIGINT';
    field.Len = 20;
  ElseIf field.len = 0 and field.type = 'TIMESTAMP';
    field.Len = 16;
  ElseIf field.len = 0 and field.type = 'DATE';
    field.Len = 10;
  ElseIf field.len = 0 and field.type = 'TIME';
    field.Len = 8;
  EndIf;

  // Get the length and scale if populated, if the field is referenced, this can be a plus, minus or overide value
  // Examples:
  //  Length: +5, -10, 45
  //  Scale:  +1, -1,  2
  If %scan('-':field.length)<>0 or %scan('+':field.length)<>0;
    field.len+=#$RVL(field.length);
  ElseIf #$RVL(field.length)<>0;
    field.len=#$RVL(field.length);
  EndIf;
  If %scan('-':field.scale)<>0 or %scan('+':field.scale)<>0;
    field.scl+=#$RVL(field.scale);
  ElseIf #$RVL(field.scale)<>0;
    field.scl=#$RVL(field.scale);
  EndIf;

  // add the record
  Exec SQL Insert Into SCRLOC
                 (lib,fle,mbr,
                  RcdFmt,RcdFmtTyp,fldNme,fldCol,fldRow,
                  fldLen, fldScl, fldTyp, extTyp,
                  crtDtm,crtJob,CrtPgm,crtUsr,
                  Reflib,refFle,Reffld)
           values(:sourceLibrary,:sourceFile, :sourceMember,
                  :currentFormat,:currentFormatType,:field.name,:field.col,:field.row,
                  :field.len,:field.scl,:field.type,:field.extendedType,
                  CURRENT_TIMESTAMP,:psdsJobNam,:psdsPgmNam,:psdsUsrNam,
                  :field.referenceLibrary,:field.referenceFile,:field.referenceField);

End-Proc;

// Get reference file and library from REF(xxx/xxx)
Dcl-Proc ParseRefFile;
  Dcl-Pi *n;
    function Char(36) Const;
    library Char(10);
    file Char(10);
  End-Pi;
  Dcl-S startPosition int(5);
  Dcl-S endPosition int(5);

  Clear file;
  Clear library;

  startPosition=%scan('REF(':function) +4;

  // see if a library is specified
  endPosition=%scan('/':function:startPosition)-1;
  If endPosition>0;
    library= %subst(function:startPosition:endPosition-startPosition+1);
    startPosition=endPosition+2;
    endPosition=%scan(')':function:startPosition)-1;
    file= %subst(function:startPosition:endPosition-startPosition+1);
  Else;
    library= '*LIBL';
    endPosition=%scan(')':function:startPosition)-1;
    file= %subst(function:startPosition:endPosition-startPosition+1);
  EndIf;

End-Proc;


// Get reference info for a field.
// If a REFFLD parameter is found, strip the fields, record format
// file and library from it and update the current field
// reffld(fldnme)
// reffld(rcdfmt/fldnme)
// REFFLD(RCDFMT/FLDNME LIB/File)
// REFFLD(RCDFMT/FLDNME File)
// REFFLD(FLDNME LIB/File)
// REFFLD(FLDNME File)
// The function can also have more than one values like this:
// reffld(dftval) dspatr(&dftval1@)
Dcl-Proc ParseRefField;
  Dcl-Pi *n;
    pmrFunction Varchar(72) Const;
    library Char(10);
    file Char(10);
    field Char(10);
  End-Pi;
  Dcl-S function Varchar(72);
  Dcl-S startPosition int(5);
  Dcl-S endPosition int(5);
  Dcl-S mid int(5);
  Dcl-S slash int(5);
  Dcl-S data Varchar(43);
  Dcl-S firstWord Varchar(21);
  Dcl-S secondWord Varchar(21);

  Clear file;
  Clear library;
  Clear field;
  function=%trim(pmrFunction);

  // strip the data between the () out
  startPosition=%scan('REFFLD(':function) + 7;
  endPosition=%scan(')':function:startPosition) - 1;
  data = %trim(%subst(function:startPosition:endPosition-startPosition+1));

  // see if there is a space, if so, strip out the first word and second word
  mid=%scan(' ':data);
  If mid<>0;
    firstWord=%subst(data:1:mid-1);
    secondWord=%subst(data:mid+1:%len(data)-(mid));
  Else;
    firstWord=data;
    secondWord='';
  EndIf;

  // The first word consists of either RcdFmt/Fleid or just a field, we only
  // need the field so if it has a / only get the data after the slash
  slash= %scan('/':firstWord);
  If slash>0;
    field=%subst(firstWord:slash+1:%len(firstWord)-(slash));
  Else;
    field=firstWord;
  EndIf;

  // The second word consists of either Library/File or just a file, so split out one or both
  If secondWord<>'';
    slash= %scan('/':secondWord);
    If slash>0;
      library= %subst(secondWord:1:slash-1);
      file=%subst(secondWord:slash+1:%len(secondWord)-(slash));
    Else;
      file=secondWord;
    EndIf;
  EndIf;

End-Proc;


// Saves the highest SFLPAG property in the file
Dcl-Proc SetSFLPage;
  Dcl-Pi *n;
    function Char(36) Const;
  End-Pi;
  Dcl-S startPosition int(5);
  Dcl-S endPosition int(5);
  Dcl-S tpSFLPage packed(5);

  // strip the data between the () out
  startPosition=%scan('SFLPAG(':function) + 7;
  endPosition=%scan(')':function:startPosition) - 1;
  tpSFLPage=#$RVL(%trim(%subst(function:startPosition:endPosition-startPosition+1)));

  If tpSFLPage>sflPage;
    sflPage=tpSFLPage;
  EndIf;

End-Proc;


// create the _@ copy book
Dcl-Proc Create_@;
  Dcl-S outputMember Char(10);
  Dcl-S outputFile Char(10);
  Dcl-S pgmDes char(50);
  Dcl-S pgmNme char(10);
  Dcl-S Inz Char(9);
  Dcl-S temp20 Char(20);
  Dcl-S minFldRow like(SCRLOC.fldRow);
  Dcl-S maxFldRow like(SCRLOC.fldRow);

  // build file name, map XXXXXXFX to XXXXXXDX_@
  outputMember = %trim(%subst(sourceMember:1:6)) + 'D' +
                 %trim(%subst(sourceMember:8:1)) + '_@';

  // set source file
  If sourceFile='QDDSSRC';
    outputFile='QRPGLESRC';
  Else;
    outputFile=sourceFile;
  EndIf;

  // if there is a SFL drop defined then we have to figure out how many lines are in the SFL
  // and times that by the number of records in the sfl to get the sfl page size.
  If isSFLDrop;
    Exec SQL
      Select min(fldRow), max(fldRow)
      Into  :minFldRow,  :maxFldRow
      From SCRLOC
      Where mbr = :sourceMember
        and rcdfmt = 'SFL'
        and fldRow <> 0;
    sflPage *= (maxFldRow - minFldRow + 1);
  EndIf;

  // SQL will not create the member so The following section creates it

  // create the source member if it does not exist, ignore errors
  #$CMD('ADDPFM FILE('+%trim(sourceLibrary)+'/' + %trim(outputFile) + ') +
                MBR('+%trim(outputMember)+')':1);

  // get program name from PGMMST, used for the source file description
  pgmNme=%subst(sourceMember:1:6) + 'D' + %subst(sourceMember:8:1);
  Exec SQL Select des Into :pgmDes From pgmmst Where pgmnme=:pgmNme;

  // make the source type PNLGRP and make the text the program name
  #$CMD('CHGPFM FILE('+%trim(sourceLibrary)+'/' + %trim(outputFile) + ') +
                MBR('+%trim(outputMember)+') +
                SRCTYPE(RPGLE) +
                Text('''+%trim(pgmDes)+''')   ':1);

  // create an alias to the source member
  Exec SQL Drop Alias QTEMP/SCRLOCALS;
  sqlStm='Create or Replace Alias QTEMP/SCRLOCALS2 For ' +
        %trim(sourceLibrary) +'/' + %trim(outputFile) + '("' +
        %trim(outputMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // clear the source member if it already exists
  Exec SQL Delete From QTEMP/SCRLOCALS2;

  // add the **free to the first line and a comment
  write_@('**free');
  write_@('// ************************************************************************************');
  write_@('// *                              *** Warning ***                                     *');
  write_@('// ************************************************************************************');
  write_@('// * Do not manually build or change this, it is rebuilt from the screen, any changes *');
  write_@('// * will be overridden. It can be rebuilt manually using custom PDM option SC in     *');
  write_@('// * front of the display file. If SC is not setup add it with the following command  *');
  write_@('// *    call scrlocb1 (&l &f &n)                                                      *');
  write_@('// ************************************************************************************');

  // add FldAtrCpy DS
  found=*off;
  write_@('');
  write_@('// Data structure of field attribute fields only used for copy Options');
  write_@('Dcl-Ds FldAtrCpy;');
  Exec SQL Declare crsFldAtrCpy Cursor For
    With
      First as (
        Select fldNme fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) sort
        From SCRLOC
        Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and extTyp='ATTR-COPY'
        GROUP by FLDNME)
    Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
    From SCRLOC
    Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=first.sort
    Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and extTyp='ATTR-COPY'
    Order by first.sort;
  Exec SQL Open crsFldAtrCpy;
  Exec SQL Fetch Next From crsFldAtrCpy Into :dta2;
  DoW sqlState<'02';
    write_@('  ' + %trim(fldNme) + ' Char(1);');
    Exec SQL Fetch Next From crsFldAtrCpy Into :dta2;
  EndDo;
  Exec SQL Close crsFldAtrCpy;
  write_@('End-Ds;');

  // add FldAtrKey DS
  write_@('');
  write_@('// Data structure of field attribute fields only used for key fields');
  write_@('Dcl-Ds FldAtrKey;');
  Exec SQL Declare crsFldAtrKey Cursor For
    With
      First as (
        Select FLDNME fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) SORT
        From SCRLOC
        Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='ATTR-KEY'
        GROUP by FLDNME)
    Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
    From SCRLOC
    Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=first.sort
    Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='ATTR-KEY'
    Order by first.sort;
  Exec SQL Open crsFldAtrKey;
  Exec SQL Fetch Next From crsFldAtrKey Into :dta2;
  DoW sqlState<'02';
    write_@('  ' + %trim(fldNme) + ' Char(1);');
    Exec SQL Fetch Next From crsFldAtrKey Into :dta2;
  EndDo;
  Exec SQL Close crsFldAtrKey;
  write_@('End-Ds;');

  // add FldAtrDta DS
  write_@('');
  write_@('// Data structure of field attribute fields used for all other fields');
  write_@('Dcl-Ds FldAtrDta;');
  Exec SQL Declare crsFldAtr Cursor For
    With
      First as (
        Select FLDNME fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) SORT
        From SCRLOC
        Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='ATTR'
        GROUP by FLDNME)
    Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
    From SCRLOC
    Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=first.sort
    Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='ATTR'
    Order by first.sort;
  Exec SQL Open crsFldAtr;
  Exec SQL Fetch Next From crsFldAtr Into :dta2;
  DoW sqlState<'02';
    write_@('  ' + %trim(fldNme) + ' Char(1);');
    Exec SQL Fetch Next From crsFldAtr Into :dta2;
  EndDo;
  Exec SQL Close crsFldAtr;
  write_@('End-Ds;');

  // add dta DS, only if there is at least one SFL type entry
  found=*off;
  Exec SQL Select '1' Into :found
           From SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='DTA'
             and RcdFmt not in ('DUMMY','MSGCTL','MSGRCD');
  If found;
    write_@('');
    write_@('// Data structure of fields for SQL select into for a SFL program');
    write_@('Dcl-Ds dta Qualified Dim('+%char(sflPage)+');');
    write_fields();
    write_@('End-Ds;');
    write_@('');

    write_@('// Data structure of fields for columns in a SFL');
    write_@('// This is used to move all values from DTA to field names on the screen');
    write_@('Dcl-Ds sflFields;');
    write_fields();
    write_@('End-Ds;');
  EndIf;

  // add POS DS, only if there is at least one POS type entry
  // This also adds the lines1 ds, defaults for both and the orderBy ds.
  found=*off;
  Exec SQL Select '1' Into :found
           From SCRLOC
           Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%';
  If found;
    write_@('');
    write_@('// Data structure of fields for position to columns, used in a SFL program');
    write_@('Dcl-Ds pos Qualified;');
    write_fields();
    write_@('End-Ds;');
    write_@('');

    write_@('// Data structure of default values for position to columns');
    write_@('// This DS is used to compare POS to to see if any position to fields are set.');
    write_@('Dcl-Ds posDefault LikeDs(pos) inz;');
    write_@('');

    write_@('// Data structure of position to entry fields');
    write_@('// This is used to move values on line1 to other DS''s or to compare them');
    write_@('Dcl-Ds line1;');
    write_fields('1');
    write_@('End-Ds;');
    write_@('');

    write_@('// Data structure of position to entry field defaults.');
    write_@('// This is used to compare to lines1 ds to see if any values are entered.');
    write_@('Dcl-Ds line1Defaults LikeDs(line1) inz;');
    write_@('');

    write_@('// Data structure containing array of order by values');
    write_@('// This is used so the order by value can be added using the srtCde as the array index.');
    write_@('// This prevents the need to hard code the order by values.');
    write_@('Dcl-Ds orderByDS Qualified; ');
    write_@('  values char('+%char(columns*20)+')');
    Inz='    inz(''';
    Exec SQL Declare crsPos4 Cursor For
      With
        First as (
          Select FLDNME fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) SORT
          From SCRLOC
          Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%'
          GROUP by FLDNME)
      Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
      From SCRLOC
      Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=
           first.sort
      Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%'
      Order by first.sort;
    Exec SQL Open crsPos4;
    Exec SQL Fetch Next From crsPos4 Into :dta2;
    DoW sqlState<'02';
      If fldTyp in %list('CHAR':'VARCHAR');
        temp20='upper(' + %subst(fldNme:1:%len(%trim(fldnme))-1) + ')';
      Else;
        temp20=%subst(fldNme:1:%len(%trim(fldnme))-1);
      EndIf;
      If extTyp = 'POSDESC';
        temp20 = %trim(temp20) + ' desc';
      EndIf;
      write_@(Inz+ temp20 + '+');
      Inz='';
      Exec SQL Fetch Next From crsPos4 Into :dta2;
    EndDo;
    Exec SQL Close crsPos4;

    write_@('          '');');
    write_@('  Value char(20) dim('+%char(columns)+') overlay(values);');
    write_@('End-Ds;');
  EndIf;

  // add the SFLPage variable if n any SFLPAG values found
  If sflPage>0;
    write_@('');
    write_@('// contains the SFLPAG value, or largest value if multiple are present');
    write_@('Dcl-S SFLPage packed(5:0) Inz('+%char(sflPage)+');');
  EndIf;

  // delete the alias to the source member
  Exec SQL Drop Alias QTEMP/SCRLOCALS2;

End-Proc;


// create the _2 copy book
Dcl-Proc Create_2;
  Dcl-S outputMember Char(10);
  Dcl-S outputFile Char(10);
  Dcl-S pgmDes Char(50);
  Dcl-S pgmNme char(10);
  Dcl-S temp10 Char(10);
  Dcl-S gtLt Char(1); // Hold > or < sign
  Dcl-S i packed(5);

  // build file name, map XXXXXXFX to XXXXXXDX_@
  outputMember = %trim(%subst(sourceMember:1:6)) + 'D' +
                 %trim(%subst(sourceMember:8:1)) + '_2';

  // set source file
  If sourceFile='QDDSSRC';
    outputFile='QRPGLESRC';
  Else;
    outputFile=sourceFile;
  EndIf;

  // SQL will not create the member so The following section creates it

  // create the source member if it does not exist, ignore errors
  #$CMD('ADDPFM FILE('+%trim(sourceLibrary)+'/' + %trim(outputFile) + ') +
                MBR('+%trim(outputMember)+')':1);

  // get program name from PGMMST, used for the source file description
  pgmNme=%subst(sourceMember:1:6) + 'D' + %subst(sourceMember:8:1);
  Exec SQL Select des Into :pgmDes From pgmmst Where pgmnme=:pgmNme;

  // make the source type RPGLE and make the text the program name
  #$CMD('CHGPFM FILE('+%trim(sourceLibrary)+'/' + %trim(outputFile) + ') +
                MBR('+%trim(outputMember)+') +
                SRCTYPE(RPGLE) +
                Text('''+%trim(pgmDes)+''')   ':1);

  // create an alias to the source member
  Exec SQL Drop Alias QTEMP/SCRLOCALS;
  sqlStm='Create or Replace Alias QTEMP/SCRLOCALS2 For ' +
        %trim(sourceLibrary) +'/' + %trim(outputFile) + '("' +
        %trim(outputMember) + '")';
  Exec SQL Execute Immediate :sqlStm;

  // clear the source member if it alreay exists
  Exec SQL Delete From QTEMP/SCRLOCALS2;

  // add the **free to the first line and a comment
  write_@('**free');
  write_@('// ************************************************************************************');
  write_@('// *                              *** Warning ***                                     *');
  write_@('// ************************************************************************************');
  write_@('// * Do not manually build or change this, it is rebuilt from the screen, any changes *');
  write_@('// * will be overridden. It can be rebuilt manually using custom PDM option SC in     *');
  write_@('// * front of the display file. If SC is not setup add it with the following command  *');
  write_@('// *    call scrlocb1 (&l &f &n)                                                      *');
  write_@('// ************************************************************************************');

  // add SetSortCde procedure
  found=*off;
  write_@('');
  write_@('');
  write_@('// Sets the sort code based on which position to field is entered');
  write_@('Dcl-Proc SetSrtCde;');
  write_@('');
  i = 0;
  Exec SQL Declare crsPos10 Cursor For
      With
        First as (
          Select FLDNME fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) SORT
          From SCRLOC
          Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%' and fldCol <> 0
          GROUP by FLDNME)
      Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
      From SCRLOC
      Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=
           first.sort
      Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember
      Order by first.sort;
  Exec SQL Open crsPos10;
  Exec SQL Fetch Next From crsPos10 Into :dta2;
  DoW sqlState<'02';
    temp10=%subst(fldNme:1:%len(%trim(fldnme))-1);
    If fldTyp in %list('DECIMAL':'ZONED':'NUMERIC') and i = 0;
      write_@('  If ' + %trim(temp10) + ' <> 0;');
    ElseIf fldTyp in %list('DECIMAL':'ZONED':'NUMERIC');
      write_@('  ElseIf ' + %trim(temp10) + ' <> 0;');
    ElseIf i = 0;
      write_@('  If ' + %trim(temp10) + ' <> '''';');
    Else;
      write_@('  ElseIf ' + %trim(temp10) + ' <> '''';');
    EndIf;
    i += 1;
    write_@('    filterDs.SrtCde = ' + %char(i) + ';');
    Exec SQL Fetch Next From crsPos10 Into :dta2;
  EndDo;
  Exec SQL Close crsPos10;

  write_@('  EndIf;');
  write_@('');
  write_@('End-Proc;');


  // add PositionSLF procedure
  found=*off;
  write_@('');
  write_@('');
  write_@('// Find the record number of the entered position to data ');
  write_@('Dcl-Proc PositionSFL;');
  write_@('  Dcl-S SQLStmPos Varchar(10000);');
  write_@('');
  write_@('  SQLStmPos = sqlStm;');
  write_@('');
  i = 0;
  Exec SQL Declare crsPos11 Cursor For
      With
        First as (
          Select FLDNME fld, MIN(RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)) SORT
          From SCRLOC
          Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP like 'POS%' and fldCol <> 0
          GROUP by FLDNME)
      Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
      From SCRLOC
      Join First on fldnme=first.fld and RcdFmt Concat Digits(fldRow) Concat Digits(fldCol)=
           first.sort
      Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember
      Order by first.sort;
  Exec SQL Open crsPos11;
  Exec SQL Fetch Next From crsPos11 Into :dta2;
  DoW sqlState<'02';
    // sort descending if the field says to
    If extTyp = 'POSDESC';
      gtLt = '>';
    Else;
      gtLt = '<';
    EndIf;
    temp10=%subst(fldNme:1:%len(%trim(fldnme))-1);
    If fldTyp in %list('DECIMAL':'ZONED':'NUMERIC');
      If i = 0;
        write_@('  If pos.' + %trim(temp10) + ' <> 0;');
      Else;
        write_@('  ElseIf pos.' + %trim(temp10) + ' <> 0;');
      EndIf;
      write_@('    SQLStmPos += '' '' + Where + '' ' + %trim(temp10) + ' '
               + gtLt +' '' + %char(pos.' + %trim(temp10) + ');');
    Else;
      If i = 0;
        write_@('  If pos.' + %trim(temp10) + ' <> '''';');
      Else;
        write_@('  ElseIf pos.' + %trim(temp10) + ' <> '''';');
      EndIf;
      write_@('    SQLStmPos += '' '' + Where + '' ucase(' + %trim(temp10) + ') '
               + gtLt +' uCase('''''' + %trim(pos.' + %trim(temp10) + ') + '''''')'';');
    EndIf;
    write_@('    Where = ''and'';');
    i += 1;
    Exec SQL Fetch Next From crsPos11 Into :dta2;
  EndDo;
  Exec SQL Close crsPos11;

  write_@('  EndIf;');
  write_@('');
  write_@('  // Add order by');
  write_@('  SQLStmPos += '' '' + OrderBy;');
  write_@('');
  write_@('  Exec SQL Prepare SQLStmPos From :SQLStmPos;');
  write_@('  Exec SQL Declare SQLCrsPos insensitive Cursor For SQLStmPos;');
  write_@('  Exec SQL Open SQLCrsPos;');
  write_@('  Exec SQL Get DIAGNOSTICS :currentRow = DB2_NUMBER_ROWS;');
  write_@('  Exec SQL Close SQLCrsPos;');
  write_@('');
  write_@('  Clear Pos;');
  write_@('');
  write_@('End-Proc;');


  // delete the alias to the source member
  Exec SQL Drop Alias QTEMP/SCRLOCALS2;

End-Proc;


// write fields for one of the data structures
Dcl-Proc write_fields;
  Dcl-Pi *n;
    addAOne Char(1) const options(*nopass);
  End-Pi;
  Dcl-S addOne Varchar(1);

  If %parms() >= 1 and addAOne = '1';
    addOne = '1';
  Else;
    addOne = '';
  EndIf;

  columns=0;
  Exec SQL Declare crsPos2 Cursor For
    With
      First as (
        Select FLDNME fld, MIN(RcdFmt || Digits(fldRow) || Digits(fldCol) || Digits(scrLocIdn)) SORT
        From SCRLOC
        Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='DTA'
        GROUP by FLDNME)
    Select fldNme, fldLen, fldScl, fldTyp, refFle, refFld, fldCol, extTyp
    From SCRLOC
    Join First on fldnme=first.fld and RcdFmt || Digits(fldRow) || Digits(fldCol) || Digits(scrLocIdn) = first.sort
    Where lib=:sourceLibrary and fle=:sourceFile and mbr=:sourceMember and EXTTYP='DTA'
    Order by first.sort;
  Exec SQL Open crsPos2;
  Exec SQL Fetch Next From crsPos2 Into :dta2;
  DoW sqlState<'02';
    // This just keeps VS code from showing calitalization erros for the member
    If fldNme = 'KEY';
      fldNme = 'Key';
    EndIf;
    // convert SQL types from dictionary to RPG types
    // If the field is displayed on the screen and is packed it compiles as zoned
    If fldtyp='DECIMAL' and fldCol<>0;
      fldtyp='ZONED';
    ElseIf fldtyp='DECIMAL';
      fldtyp='PACKED';
    ElseIf fldtyp='NUMERIC';
      fldtyp='ZONED';
    EndIf;
    If fldTyp='SMALLINT'; // special types
      write_@('  '+%trim(fldNme)+addOne+' ZONED(4);');
    ElseIf fldTyp='INTEGER'; // special types
      write_@('  '+%trim(fldNme)+addOne+' ZONED(8);');
    ElseIf fldTyp='BIGINT'; // special types
      write_@('  '+%trim(fldNme)+addOne+' ZONED(18);');
    ElseIf fldScl<>0; // types that have decimal positions
      write_@('  '+%trim(fldNme)+addOne+' '+%trim(fldTyp)+'('+%char(fldLen)+':'+%char(fldScl)+');');
    ElseIf fldLen<>0 and fldTyp='VARCHAR'; // Varchar to Char, on a screen they get converted
      write_@('  '+%trim(fldNme)+addOne+' CHAR('+%char(fldLen)+');');
    ElseIf fldLen<>0; // types that have lengths
      write_@('  '+%trim(fldNme)+addOne+' '+%trim(fldTyp)+'('+%char(fldLen)+');');
    Else;  // all others
      write_@('  '+%trim(fldNme)+addOne+' '+%trim(fldTyp)+';');
    EndIf;
    columns+=1;
    Exec SQL Fetch Next From crsPos2 Into :dta2;
  EndDo;
  Exec SQL Close crsPos2;

End-Proc;


// write one line to the _@ copybook
Dcl-Proc write_@;
  Dcl-Pi *n;
    data Varchar(250) const;
  End-Pi;
  Dcl-S srcSeq zoned(6:2);

  // add the string into the source file
  srcSeq+=1;
  Exec SQL Insert Into QTEMP/SCRLOCALS2
                 (srcSeq,srcDta)
           values(:srcSeq,:data);

End-Proc;
