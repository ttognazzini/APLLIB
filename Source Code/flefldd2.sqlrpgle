**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// File Field Detail

Dcl-F FLEFLDF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,FLEFLDD2_@ // auto generated data structures for field attribute fields
/Copy QSRC,FLEFLDB1PR
/Copy QSRC,DCTFLDD1PR
/Copy QSRC,DCTVALBPPR
/Copy QSRC,DCTVALDPPR


Dcl-S pmrFleLib Like(APLDCT.FleLib);
Dcl-S pmrFleNme Like(APLDCT.FleNme);
Dcl-S pmrFldNme Like(APLDCT.FldNme);
Dcl-S priKey Like(APLDCT.priKey);
Dcl-S encFld Like(APLDCT.encFld);

Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S DltAct Ind;

Dcl-Ds DspVal ExtName('FLEFLDF2') Inz End-Ds;

Exec SQL Set Option Commit = *none, CloSQLCsr = *endmod, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('FLEFLDD2');
    pmr1FleLib Like(APLDCT.FleLib);
    pmr1FleNme Like(APLDCT.FleNme);
    pmr1FldNme Like(APLDCT.FldNme);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  // Move parameters to global variables so they can be used in all procedures
  pmrFleLib = pmr1FleLib;
  FleLib = pmr1FleLib;
  pmrFleNme = pmr1FleNme;
  FleNme = pmr1FleNme;
  pmrFldNme=pmr1FldNme;
  FldNme = pmrFldNme;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SNDMSG('Not authorized to program');
    Return;
  EndIf;

  InitializeProgram();

  DoU keyPressed = 'F3' or keyPressed = 'F12';
    DisplayScreen();

    If not $ValidKeyPressed(keyPressed:fncDs) and KeyPressed<>'F10';
      $ErrorMessage('APL0001':keyPressed);
      iter;
    ElseIf keyPressed = 'F3'; // F3=Exit
      Leave;
    ElseIf keyPressed = 'F4'; // F4=Prompt
      Prompt();
    ElseIf keyPressed = 'F5';  // F5=Refresh
      InitializeProgram();
    ElseIf keyPressed = 'F10';  // F10=Enum Values
      EnumValues();
    ElseIf keyPressed = 'F12'; // F12=Cancel
      Leave;
    ElseIf mode = 'Display'; // If in display mode, don't validate or update, just leave
      keyPressed = 'F12';
      Leave;
    ElseIf ValidateScreen(); // Validate screen entry
      iter;
    Else; // If no errors process screen updates
      UpdateScreen();
      Leave;
    EndIf;
  EndDo;

  pmrKeyPressed = keyPressed;
  Close FLEFLDF2;


End-Proc;


// Display Screen
Dcl-Proc DisplayScreen;

  // Load SFL options if needed
  Write MSGCTL;

  // This only has to be done in screens where a data structure is defined over
  // the screen so individual fields do not need to be moved, this makes the outRow and OutCol
  // zoned instead of packed which messes up the calls to the error message and field location
  // procedures. To fix it we change the screen fields otuRowScr and outRowCol which means we
  // have to move the values into those fields before we display the screen.
  outRowScr=outRow;
  outColScr=outCol;

  Exfmt SCREEN;

  // Convert hex key pressed to alpha key pressed, always leave this here
  keyPressed=$ReturnKey(dspDs.key);

  // The row and column fields are where the cursor will be positioned to, default them
  // to the location it was already at, this may be overridden by an error message later
  outRow=csrRow;
  outCol=csrCol;

  // Clear message SFL and reset error indicator
  $ClearMessages();

  // reset all field attributes
  SetAttributes();

End-Proc;


// Set Field Attributes
Dcl-Proc SetAttributes;

  If ProtectDta;
    FldAtrDta = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrDta;
  EndIf;

  If ProtectKey;
    FldAtrKey = *allx'A2';    // @PrWht
  Else;
    Clear FldAtrKey;
  EndIf;

  If ProtectCpy;
    FldAtrCpy = *allx'A2';    // @PrWht
    $SetAttribute(frmKeys@:'');
  Else;
    FldAtrCpy = *allx'A7';    // @PrND
  EndIf;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);
  Dcl-S fldTyp   Like(APLDCT.fldTyp);

  error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From FLEFLD
    Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and found;
    $ErrorMessage('':'File field already exists.':error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and not found;
    $ErrorMessage('':'File field does not exist,.':error);
  EndIf;

  // Validate Rename
  If Option = '7'  and DctNme <> pmrFldNme;
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Validate that field name exists in the dictionary
  found = *off;
  Exec SQL Select '1' Into :found From DCTFLD Where (dctNme,fldNme) = (:dctNme,:fldnme) limit 1;
  If not found;
    $ErrorMessage('':'Error invalid field name, does not exist in dictionary.'
                    :error:fldNme@:'fldNme':outRow:outCol:psDsPgmNam);
  EndIf;

  // Reload information from the dicitonary incase the field name changes
  GetDctDta();

  // make sure the primary key value is correct, Auto prompt first if not valid, handles ?
  pmEnmVal = '';
  pmEnmDes = priKeyD;
  Callp(e) DCTVALBP('APLDCT':'PRIKEY':pmEnmVal:pmEnmDes:pmKeyPressed);
  If priKeyD <> pmEnmDes;
    priKeyD = pmEnmDes;
    error=*on;
  EndIf;
  If not $ValidEnmDes(#$UPIFY(priKeyD):'APLDCT':'priKey');
    $ErrorMessage('DCT1002':'':error:priKeyD@:'priKeyD':outRow:outCol:psDsPgmNam);
  EndIf;
  Exec SQL select enmVal into :priKey from DCTVAL where (dctNme,fldNme,enmDes) = ('APLDCT','PRIKEY',:priKeyD);

  // Make sure that the increment information is only populated on the primary id field
  If fldNme <> %trim(fleNme) + 'IDN' and strIdn <> 0;
    $ErrorMessage('':'Error starting id should only be populated for the primary id field.'
                    :error:strIdn@:'strIdn':outRow:outCol:psDsPgmNam);
  EndIf;
  If fldNme <> %trim(fleNme) + 'IDN' and idnIcm <> 0;
    $ErrorMessage('':'Error id increment should only be populated for the primary id field.'
                    :error:idnIcm@:'idnIcm':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the audit field value is correct, Auto prompt first if not valid, handles ?
  pmEnmVal = '';
  pmEnmDes = audFld;
  Callp(e) DCTVALBP('APLDCT':'AUDFLD':pmEnmVal:pmEnmDes:pmKeyPressed);
  If audFld <> pmEnmDes;
    audFld = pmEnmDes;
    error=*on;
  EndIf;
  If not $ValidEnmDes(#$UPIFY(audFld):'APLDCT':'audFld');
    $ErrorMessage('DCT1002':'':error:audFld@:'audFld':outRow:outCol:psDsPgmNam);
  EndIf;

  // make sure the field encrypted value is correct, Auto prompt first if not valid, handles ?
  pmEnmVal = '';
  pmEnmDes = encFldD;
  Callp(e) DCTVALBP('APLDCT':'ENCFLD':pmEnmVal:pmEnmDes:pmKeyPressed);
  If encFldD <> pmEnmDes;
    encFldD = pmEnmDes;
    error=*on;
  EndIf;
  If not $ValidEnmDes(#$UPIFY(encFldD):'APLDCT':'encFld');
    $ErrorMessage('':'Invalid encrypt field option.':error:encFldD@:'encFldD':outRow:outCol:psDsPgmNam);
  EndIf;
  Exec SQL select enmVal into :encFld from DCTVAL where (dctNme,fldNme,enmDes) = ('APLDCT','ENCFLD',:encFldD);

  // If the field is encrypted, make sure it is a char or varchar field.
  If encFld = 'Y' and %subst(fldTypD:1:4) <> 'CHAR' and %subst(fldTypD:1:7) <> 'VARCHAR';
    $ErrorMessage('':'Only CHAR and VARCHAR fields can be encrypted.'
                    :error:encFldD@:'encFldD':outRow:outCol:psDsPgmNam);
  EndIf;

  // XML, dataLink, graphic, vargraphic and dbclob cannot be cast to character so they can not be audited
  fldTyp = '';
  Exec SQL Select fldTyp into :fldTyp from DCTFLD where (dctNme,fldNme) = (:dctNme,:fldNme);
  If fldTyp in %list('XML':'DATALINK':'GRAPHIC':'VARGRAPHIC':'DBCLOB') and audFld = 'Yes';
    $ErrorMessage('':'Error this data type cannot be audited.':error:audFld@:'audFld':outRow:outCol:psDsPgmNam);
  EndIf;

  Return error;

End-Proc;


// select item
Dcl-Proc UpdateScreen;
  Dcl-S fldLvl like(APLDCT.fldLvl);
  Dcl-S audFldVal like(APLDCT.audFld);
  Dcl-S fleMstIdn like(APLDCT.fleMstIdn);

  Exec SQL select enmVal into :audFldVal from DCTVAL where (dctNme,fldNme,enmDes) = ('APLDCT','AUDFLD',:audFld);

  // determine field level
  If fldNme = 'ACVROW';
    fldLvl = '1';
  ElseIf fldNme = %trim(fleNme) + 'IDN';
    fldLvl = '2';
  ElseIf priKey = 'Y';
    fldLvl = '3';
  ElseIf fldNme in %list('CRTDTM':'CRTUSR':'CRTJOB':'CRTPGM':'MNTDTM':'MNTUSR':'MNTJOB':'MNTPGM');
    fldLvl = '5';
  Else;
    fldLvl = '4';
  EndIf;

  // Inactivate
  If Option = '4';
    Exec SQL
    Update FLEFLD
    Set AcvRow = '0'
    Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:fldNme);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL
      Update FLEFLD
      Set FldNme = :FldNme
      Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:FldNme);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL
      Update FLEFLD
      Set AcvRow = '1'
      Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:FldNme);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL Select fleMstIdn into :fleMstIdn from fleMst where (fleLib,fleNme) = (:fleLib,:fleNme);
    Exec SQL
      Update FLEFLD
      Set ( fldLvl, fldSeq, priKey, encFld, strIdn, idnIcm, audFld, fleMstIdn)
        = (:fldLvl,:fldSeq,:priKey,:encFld,:strIdn,:idnIcm,:audFldVal,:fleMstIdn)
      Where (fleLib,fleNme,fldNme) = (:fleLib,:fleNme,:FldNme);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Create/Copy
  ElseIf Option = '1' or Option = '3';
    Exec SQL Select fleMstIdn into :fleMstIdn from fleMst where (fleLib,fleNme) = (:fleLib,:fleNme);
    Exec SQL
    Insert Into FLEFLD
          (AcvRow,fleLib, fleNme, fldNme, fldSeq, fldLvl, priKey, encFld, strIdn, idnIcm, audFld, fleMstIdn)
    Values('1',  :fleLib,:fleNme,:FldNme,:fldSeq,:fldLvl,:priKey,:encFld,:strIdn,:idnIcm,:audFldVal,:fleMstIdn);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

  // Resequence/Syncronize file fields
  FLEFLDB1(fleLib:fleNme);

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmOption like(Option);
  Dcl-S pmFldNme like(fldNme);
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmEnmVal Like(APLDCT.EnmVal);
  Dcl-S pmEnmDes Like(APLDCT.EnmDes);

  // Prompt status description
  If CsrFld = 'PRIKEYD';
    Callp DCTVALDP('APLDCT':'PRIKEY':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      priKeyD = pmEnmDes;
    EndIf;

    // Prompt Field Name
  ElseIf CsrFld = 'FLDNME';
    pmOption = '1';
    Callp(e) DCTFLDD1(dctNme:pmFldNme:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER' and not ProtectDta;
      fldNme = pmFldNme;
      GetDctDta();
    EndIf;

    // Prompt Audit Field
  ElseIf CsrFld = 'AUDFLD';
    pmOption = '1';
    Callp DCTVALDP('APLDCT':'AUDFLD':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      audFld = pmEnmDes;
    EndIf;

    // Prompt field incrypted
  ElseIf CsrFld = 'ENCFLDD';
    Callp DCTVALDP('APLDCT':'ENCFLD':pmEnmVal:pmEnmDes:keyPressed);
    If keyPressed = 'ENTER';
      encFldD = pmEnmDes;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Get dictionary data for the field
Dcl-Proc EnumValues;

End-Proc;


// Get dictionary data for the field
Dcl-Proc GetDctDta;

  // get field data
  Clear fldNmeSql;
  Clear colTxt;
  Clear fldTypD;
  Clear alwNulD;
  Clear dftVal;
  Clear enmDes;
  Exec SQL
    Select
      coalesce(DCTFLD.fldNmeSQL,'') fldNmeSql,
      coalesce(DCTFLD.colTxt,'Error') colTxt,
      Coalesce(
        Case When DCTFLD.FldTyp in ('DECIMAL','NUMERIC') and fldScl > 0
             Then trim(DCTFLD.FldTyp)||'('||fldLen||','||fldScl||')'
             When DCTFLD.FldTyp in ('DECIMAL','NUMERIC','CHAR','VARCHAR','CLOB','GRAPHIC',
                                    'VARG','DBCLOB','BINARY','VARBIN','BLOB')
             Then trim(DCTFLD.FldTyp)||'('||fldLen||')'
             Else DCTFLD.FldTyp End,'Error') typ,
      coalesce(nul.enmDes,'N') alwNul,
      coalesce(DCTFLD.dftVal,'') dftVal,
      coalesce(enm.enmDes,'') enmDes
    Into :fldNmeSql,:colTxt,:fldTypD,:alwNulD,:dftVal,:enmDes
    from DCTFLD
    Join DCTMST on DCTMST.dctNme = DCTFLD.dctNme
    Left Join DCTVAL as enm on enm.DctNme='APLDCT' and enm.FldNme='FLDENM'
          and enm.EnmVal=coalesce(Case When DCTFLD.fldEnm = 'Y' Then 'Y' Else 'N' End,'')
    Left Join DCTVAL as nul on nul.DctNme='APLDCT' and nul.FldNme='ALWNUL'
          and nul.EnmVal=coalesce(Case When DCTFLD.alwNul = 'Y' Then 'Y' Else 'N' End,'')
    Where (DCTFLD.dctNme,DCTFLD.fldNme)= (:dctNme,:fldNme);

End-Proc;


// Initialization subroutine
Dcl-Proc
  InitializeProgram;
  Dcl-Ds dta Qualified;
    fldSeq  Like(APLDCT.fldSeq);
    fldStsD Char(20);
    priKeyD  Char(3);
    encFldD  Char(3);
    audFld  Char(3);
    strIdn  Like(APLDCT.strIdn);
    idnIcm  Like(APLDCT.idnIcm);
  End-Ds;

  // Sets the call stack entry name for the MSG SFL, the call stack entry is the procedure name,
  // the first procedure is always Main. pgmNme is used in the screen headers.
  callStk='MAIN';
  pgmNme=psdsPgmNam;

  // Get Valid SFL Options and Function keys data structures
  fncDs=$GetFunctionKeys(psdsPgmNam:Option);
  fncKeys=$NextFunctionKeys(fncDs);

  // * protect fields
  ProtectCpy = *off;
  ProtectKey = *on;
  ProtectDta = *on;

  // * allow key field changes on create
  If Option = '1';
    Mode = 'Create';
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'FLDSEQ':outRow:outCol);

    // allow key field changes on copy
  ElseIf Option = '3';
    Mode = 'Copy';
    ProtectCpy = *on;
    ProtectKey = *off;
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);

    // * disallow key field changes on delete
  ElseIf Option = '4' and DltAct <> '1';
    Mode = 'DeActivate';
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);

    // * disallow field changes on display
  ElseIf Option = '5';
    Mode = 'Display';
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);

    // * allow key field changes on rename
  ElseIf Option = '7';
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);
    Mode = 'Rename';
    ProtectCpy = *on;
    ProtectKey = *off;

    // * disallow key field changes on reactivate
  ElseIf Option = '13';
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);
    Mode = 'ReActivate';

  Else;
    $GetFieldLocation(psdsPgmNam:'FLDNME':outRow:outCol);
    Mode = 'Unknown';
  EndIf;

  If not %open(FLEFLDF2);
    Open FLEFLDF2;
  EndIf;

  SetAttributes();
  Clear DspVal;

  FldNmeCpy = pmrFldNme;
  DltAct   = *off;

  // Display and process data
  Clear dta;
  FleLib = pmrFleLib;
  FleNme = pmrFleNme;
  FldNme = pmrFldNme;

  // get file level data
  Exec SQL
    Select
      fleDes,
      libdes,
      FLEMST.dctNme,
      des dctDes
    Into :fleDes,:libDes,:dctNme,:dctDes
    From FLEMST
    Join APLLIB on libNme = fleLib
    Join DCTMST on DCTMST.dctNme = FLEMST.DCTNME
    Where (fleLib,fleNme)= (:fleLib,:fleNme);

  // get field data
  Exec SQL
    Select
      fldSeq,
      coalesce(sts.enmDes,'') stsDes,
      coalesce(key.enmDes,'') priKeyD,
      coalesce(enc.enmDes,'') encFldD,
      coalesce(aud.enmDes,'No') audFle,
      strIdn,
      idnIcm
    Into :dta
    From FLEFLD
    Join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme)
    Join APLLIB on libNme = FLEFLD.fleLib
    Left Join DCTVAL as sts on sts.DctNme='APLDCT' and sts.FldNme='FLDSTS' and sts.EnmVal=coalesce(FLEFLD.fldSts,'')
    Left Join DCTVAL as key on key.DctNme='APLDCT' and key.FldNme='PRIKEY'
          and key.EnmVal=coalesce(Case When priKey = 'Y' Then 'Y' Else 'N' End,'')
    Left Join DCTVAL as enc on enc.DctNme='APLDCT' and enc.FldNme='ENCFLD'
          and enc.EnmVal=coalesce(Case When encFld = 'Y' Then 'Y' Else 'N' End,'')
    left join DCTVAL as aud on (aud.DctNme,aud.FldNme,aud.enmVal) = ('APLDCT','AUDFLD',audFld)
    Where (FLEFLD.fleLib,FLEFLD.fleNme,FLEFLD.fldNme)= (:fleLib,:fleNme,:fldNme);
  Eval-Corr DspVal = dta;
  // move output only fields manually

  // Load values from the dictionary
  GetDctDta();

  // If in entry mode set the key value to whatever is passed in and move cursor to the next field
  If Option='1' and pmrFldNme<>'';
    FldNme=pmrFldNme;
    $GetFieldLocation(psdsPgmNam:'FLDSEQ':outRow:outCol);
  EndIf;

  // If in entry default the seq number, primary key field and audit flags
  If Option = '1';
    fldSeq = 9999999;
    prikeyd = 'No';
    audFld = 'No';
    encFldD = 'No';
  EndIf;

End-Proc;
