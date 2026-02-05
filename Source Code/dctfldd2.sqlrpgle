**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) BndDir('APLLIB') Main(Main);

// Dictionary Field Maintenance

Dcl-F DCTFLDF2 WORKSTN InfDS(dspDs) UsrOpn;

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,DCTFLDD2_@ // auto generated data structures for field attribute fields
/Copy QSRC,DCTFLDB8PR
/Copy QSRC,DCTFLDB9PR
/Copy QSRC,DCTSEGD1PR
/Copy QSRC,DCTSEGD2PR
/Copy QSRC,PMPWDWD1PR
/Copy QSRC,FLDTYPD1PR
/Copy QSRC,FLDTYPBPPR

Dcl-Ds Dta Qualified;
  FldNme  Like(APLDCT.FldNme);
  COLTXT  Like(APLDCT.COLTXT);
  COLHDG  Like(APLDCT.COLHDG);
  COLHDG1 Char(20) Overlay(ColHdg:1);
  COLHDG2 Char(20) Overlay(ColHdg:21);
  COLHDG3 Char(20) Overlay(ColHdg:41);
  FLDTYP  Like(APLDCT.FLDTYP);
  FLDLEN  Like(APLDCT.FLDLEN);
  FLDSCL  Like(APLDCT.FLDSCL);
  FLDALC  Like(APLDCT.FLDALC);
  PRJNBR  Like(APLDCT.PRJNBR);
  FLDPMP  Like(APLDCT.FLDPMP);
  ALWNUL  Like(APLDCT.ALWNUL);
  DFTVAL  Like(APLDCT.DFTVAL);
  FLDENM  Like(APLDCT.FLDENM);
  FLDNmeSql  Like(APLDCT.FldNmeSql);
  crtStr  Like(APLDCT.crtStr);
  mntStr  Like(APLDCT.mntStr);
End-Ds;

Dcl-S pmrDctFldIdn Like(APLDCT.dctFldIdn);
Dcl-S pmrDctMstIdn Like(APLDCT.dctMstIdn);

Dcl-S DftValUpp Like(DftVal);
Dcl-S Option like(APLDCT.Option);
Dcl-S ProtectCpy Ind;
Dcl-S ProtectKey Ind;
Dcl-S ProtectDta Ind;
Dcl-S DltAct Ind;
Dcl-S prdfle Ind;

Dcl-Ds DspVal ExtName('DCTFLDF2') Inz End-Ds;

Dcl-Pr DCTFLDD3 ExtPgm('DCTFLDD3');
  pmrDctNme Like(APLDCT.DctNme);
  pmrFldNme Like(APLDCT.FldNme);
  pmrColTxt Like(APLDCT.ColTxt);
  pmrColHdg Like(APLDCT.ColHdg);
  pmrKeyPressed Like(keyPressed);
End-Pr;

Dcl-Ds fieldType Qualified;
  found   ind;
  AlwDec  like(APLDCT.AlwDec );
  AlwLen  like(APLDCT.AlwLen );
  ReqLen  like(APLDCT.ReqLen );
  AlwAlc  like(APLDCT.AlwAlc );
  ReqAlc  like(APLDCT.ReqAlc );
  MaxLen  like(APLDCT.MaxLen );
  FrcLen  like(APLDCT.FrcLen );
  FrcLen1 like(APLDCT.FrcLen1);
  FrcLen2 like(APLDCT.FrcLen2);
  FrcLen3 like(APLDCT.FrcLen3);
  FrcLen4 like(APLDCT.FrcLen4);
  FrcLen5 like(APLDCT.FrcLen5);
End-Ds;

Exec SQL Set Option Commit = *none, CloSQLCsr = *endmod, usrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner;

// Main program loop
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTFLDD2');
    pmr1DctFldIdn Like(APLDCT.dctFldIdn);
    pmr1DctMstIdn Like(APLDCT.dctMstIdn);
    pmrOption Like(APLDCT.Option);
    pmrKeyPressed Like(keyPressed);
  End-Pi;

  Dcl-S pmDtaSeg like(APLDCT.DtaSeg);
  Dcl-S pmKeyPressed like(keyPressed);

  // Move parameters to global variables so they can be used in all procedures
  pmrDctFldIdn=pmr1DctFldIdn;
  pmrDctMstIdn=pmr1DctMstIdn;
  Option=pmrOption;

  // Figure out authority stuff, this will be a new system added later
  // for now it defaults to full security
  $securityDs=$Security(psDsPgmNam:psDsUsrPrf:Option);
  If not $securityDs.allowed;
    #$SndMsg('Not authorized to program');
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
    ElseIf keyPressed = 'F6';  // F6=Field Builder
      FieldBuilder();
    ElseIf keyPressed = 'F8';  // F6=Field Builder
      DCTSEGD1(pmDtaSeg:'2':pmKeyPressed);
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
  Close DCTFLDF2;


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
    $SetAttribute(dspPmt@:'ND');
  Else;
    Clear FldAtrDta;
    $SetAttribute(dspPmt@:'');
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

  // if this field is in a production file always protect the column name, type, length and scale
  If prdfle;
    fldNmeSql@ = x'A2';
    fldTyp@ = x'A2';
    fldLen@ = x'A2';
    fldScl@ = x'A2';
  EndIf;

End-Proc;


// Validate screen
Dcl-Proc ValidateScreen;
  Dcl-Pi *n Ind;
  End-Pi;
  Dcl-S error Ind;
  Dcl-S message varchar(100);
  Dcl-S pmFldTyp like(APLDCT.fldTyp);
  Dcl-S pmKeyPressed like(keyPressed);

  error=*off;

  // record exists?
  found=*off;
  Exec SQL
    Select '1' Into :found
    From DCTFLD
    Where DctFldIdn=:pmrDctFldIdn;
  EOF = sqlState > '02';

  // Make sure record doesn't exists if create, copy or rename
  If (Option = '1' or Option = '3' or Option = '7') and not EOF;
    $ErrorMessage('DCT1101':'':error);
  EndIf;

  // Make sure record exists if not create, copy or rename
  If Option <> '1' and Option <> '3' and Option <> '7' and EOF;
    $ErrorMessage('DCT1102':'':error);
  EndIf;

  // On entry or copy check data segments
  // ignroe if the dictionary name ends in LIB, these are for old system fields
  If #$in(Option:'1':'3':'7') and #$Last(dctNme:3)<>'LIB';
    ValidateSegments(error);
  EndIf;

  // Validate Rename
  If Option = '7';
    // code rename edits here,

    // Validate DeActivate
  ElseIf Option = '4';
    // code inactivation edits here,

  EndIf;

  // Check Required Data

  // Validate Column Text Exists
  If ColTxt = *blanks and not ProtectDta;
    $ErrorMessage('DCT2001':'':error:ColTxt@:'ColTxt':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Column Headings Exists
  If ColHdg1 = *blanks and not ProtectDta;
    $ErrorMessage('DCT2002':'':error:ColHdg1@:'ColHdg1':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate/auto prompt field type
  pmFldTyp = fldTyp;
  Callp FLDTYPBP(pmFldTyp:pmKeyPressed);
  If fldTyp <> pmFldTyp; // redisplay if the value changes
    error=*on;
  EndIf;
  fldTyp = pmFldTyp;

  // Get field type options
  Clear fieldType;
  Exec SQL
    Select '1', AlwDec, AlwLen, ReqLen, AlwAlc, ReqAlc,  MaxLen,
      FrcLen, FrcLen1, FrcLen2, FrcLen3, FrcLen4, FrcLen5
    Into :fieldType
    From  fldtyp
    Where FldTyp=:FldTyp
    Fetch First Row Only;

  // Field Type Not Found
  If not fieldType.found and not ProtectDta;
    $ErrorMessage('DCT2003':'':error:FldTyp@:'FldTyp':outRow:outCol:psDsPgmNam);
  EndIf;

  // Type requires length and one is not entered
  If fldLen=0 and fieldType.ReqLen='Y' and not ProtectDta;
    $ErrorMessage('DCT2004':FldTyp:error:FldLen@:'FldLen':outRow:outCol:psDsPgmNam);
  EndIf;

  // Length not allowed and one is entered
  If fldLen<>0 and fieldType.AlwLen<>'Y' and not ProtectDta;
    $ErrorMessage('DCT2005':FldTyp:error:FldLen@:'FldLen':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate field length maximums by type
  If FldLen>fieldType.MaxLen and not ProtectDta;
    $ErrorMessage('DCT2006':FldTyp+%char(fieldType.MaxLen):error:FldLen@:'FldLen'
                  :outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate decimal positions for types that cannot have them
  If FldScl<>0 and fieldType.AlwDec<>'Y' and not ProtectDta;
    $ErrorMessage('DCT2008':FldTyp:error:FldScl@:'FldScl':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Forced Length
  If fieldType.FrcLen='Y'
    and FldLen<>fieldType.FrcLen1
    and FldLen<>fieldType.FrcLen2
    and FldLen<>fieldType.FrcLen3
    and FldLen<>fieldType.FrcLen4
    and FldLen<>fieldType.FrcLen5
    and not ProtectDta;
    message = 'Field length must be ' + %char(fieldType.FrcLen1);
    If fieldType.FrcLen2 <> 0;
      message += ', ' + %char(fieldType.FrcLen2);
    EndIf;
    If fieldType.FrcLen3 <> 0;
      message += ', ' + %char(fieldType.FrcLen3);
    EndIf;
    If fieldType.FrcLen4 <> 0;
      message += ', ' + %char(fieldType.FrcLen4);
    EndIf;
    If fieldType.FrcLen5 <> 0;
      message += ', ' + %char(fieldType.FrcLen5);
    EndIf;
    message += '.';
    $ErrorMessage('':message:error:FldLen@:'FldLen':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Allocation is entered
  If fieldType.ReqAlc='Y' and FldAlc=0 and not ProtectDta;
    $ErrorMessage('':'Allocation size required on ' + %trim(FldTyp) + ' field.'
                 :error:FldAlc@:'FldAlc':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Allocation is not entered on anthing that is not VARCHAR
  If fieldType.ReqAlc<>'Y' and FldAlc<>0 and not ProtectDta;
    $ErrorMessage('':'Allocation not Allowed on ' + %trim(FldTyp) + ' field.'
                 :error:FldAlc@:'FldAlc':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Allow Nulls
  If not #$IN(AlwNul:'Y':'N':' ') and not ProtectDta;
    $ErrorMessage('':'Allow null must be "Y", "N" or blank.'
                 :error:AlwNul@:'AlwNul':outRow:outCol:psDsPgmNam);
  EndIf;

  // Validate Enumerated
  If not #$IN(FldEnm:'Y':'N':' ') and not ProtectDta;
    $ErrorMessage('':'Enumerated must be "Y", "N" or blank.'
                 :error:FldEnm@:'FldEnm':outRow:outCol:psDsPgmNam);
  EndIf;

  // Add quotes around default value if this is a char or varchar field
  // Unless they are valid SQL Key Words
  Exec SQL Set :DftValUpp = trim(upper(:DftVal));
  If (FldTyp='CHAR' or FLDTYP='VARCHAR')
  and DftVal<>'' and %subst(%trim(DftVal):1:1)<>''''
  and (DftValUpp <> 'USER' or FldLen < 18)        // User only valid for FldLen >= 18...
  and not ProtectDta;
    DftVal=''''+%trim(DftVal) + '''';
  EndIf;

  // Build SQL alias if it is empty
  If FldNmeSql='' and not ProtectDta;
    FldNmeSql=$BuildSQLAlias(colTxt:(%trim(colHdg1)+' '+%trim(colHdg2)+' '+%trim(colhdg3)));
    error=*on;
    $GetFieldLocation(pgmNme:'FldNmeSql':outRow:outCol);
  EndIf;

  // validate the SQL alias name
  If $ValidSQLAlias(fldNmeSql)<>' ' and not ProtectDta;
    $ErrorMessage('':$ValidSQLAlias(fldNmeSql)
                 :error:FldNmeSql@:'FldNmeSql':outRow:outCol:psDsPgmNam);
    // clean the SQL alias, if it changes, redisplay and position to the field
  ElseIf FldNmeSql<>$buildSQLAlias(FldNmeSql);
    FldNmeSql=$BuildSQLAlias(FldNmeSql);
    error=*on;
    $GetFieldLocation(pgmNme:'FLDNMESQL':outRow:outCol);
  EndIf;


  Return error;

End-Proc;

// Validate Data Segements
Dcl-Proc ValidateSegments;
  Dcl-Pi *n;
    error ind;
  End-Pi;
  Dcl-S Seg1 like(APLDCT.DtaSeg);
  Dcl-S Seg2 like(APLDCT.DtaSeg);
  Dcl-S Seg3 like(APLDCT.DtaSeg);
  Dcl-S pmKeyPressed Like(keyPressed);
  Dcl-S pmAns Char(1);
  Dcl-S pmOption Like(Option);

  Seg1=%subst(FldNme:1:3);
  Seg2=%subst(FldNme:4:3);
  Seg3=%subst(FldNme:7:3);

  If Seg1<>' ';
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg1;
    // A If they would like to add the segment if it does not exists
    If not found;
      PMPWDWD1('Segment "'+Seg1+'" not found. Would you like to add it?'
               :pmAns:'YN':'Y=Yes, N=No':pmKeyPressed);
      If pmAns = 'Y';
        pmOption = '1';
        DCTSEGD2(Seg1:pmOption:pmKeyPressed);
      EndIf;
    EndIf;
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg1;
    If not found;
      $ErrorMessage('':'Error Segement '+%trim(Seg1) +' not in segment file.'
                   :error:FldNme@:'FldNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  If Seg2<>' ';
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg2;
    // A If they would like to add the segment if it does not exists
    If not found;
      PMPWDWD1('Segment "'+Seg2+'" not found. Would you like to add it?'
               :pmAns:'YN':'Y=Yes, N=No':pmKeyPressed);
      If pmAns = 'Y';
        pmOption = '1';
        DCTSEGD2(Seg2:pmOption:pmKeyPressed);
      EndIf;
    EndIf;
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg2;
    If not found;
      $ErrorMessage('':'Error Segement '+%trim(Seg2) +' not in segment file.'
                   :error:FldNme@:'FldNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;

  If Seg3<>' ';
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg3;
    // A If they would like to add the segment if it does not exists
    If not found;
      PMPWDWD1('Segment "'+Seg3+'" not found. Would you like to add it?'
               :pmAns:'YN':'Y=Yes, N=No':pmKeyPressed);
      If pmAns = 'Y';
        pmOption = '1';
        DCTSEGD2(Seg3:pmOption:pmKeyPressed);
      EndIf;
    EndIf;
    found=*off;
    Exec SQL Select '1' Into :found From DCTSEG Where DtaSeg=:Seg3;
    If not found;
      $ErrorMessage('':'Error Segement '+%trim(Seg3) +' not in segment file.'
                   :error:FldNme@:'FldNme':outRow:outCol:psDsPgmNam);
    EndIf;
  EndIf;


  // Attemp to fill in missing data from segments
  If colTxt = '' or (ColHdg1 = '' and ColHdg2 = '' and ColHdg3 = '');
    BuildColTxt();
  EndIf;


End-Proc;

// Initialization subroutine
Dcl-Proc BuildColTxt;
  Dcl-S Des1 like(APLDCT.Des);
  Dcl-S Des2 like(APLDCT.Des);
  Dcl-S Des3 like(APLDCT.Des);
  Dcl-S ColTxt1 like(APLDCT.ColTxt);
  Dcl-S ColTxt2 like(APLDCT.ColTxt);
  Dcl-S ColTxt3 like(APLDCT.ColTxt);
  Dcl-S ColHdg1N like(APLDCT.ColHdg);
  Dcl-S ColHdg2N like(APLDCT.ColHdg);
  Dcl-S ColHdg3N like(APLDCT.ColHdg);
  Dcl-S word Varchar(20) Dim(20);
  Dcl-S cnt packed(3);
  Dcl-S Seg1 like(APLDCT.DtaSeg);
  Dcl-S Seg2 like(APLDCT.DtaSeg);
  Dcl-S Seg3 like(APLDCT.DtaSeg);

  Seg1=%subst(FldNme:1:3);
  Seg2=%subst(FldNme:4:3);
  Seg3=%subst(FldNme:7:3);

  // pull in column texts and headers
  ColTxt1='';
  ColTxt2='';
  ColTxt3='';
  ColHdg1N='';
  ColHdg2N='';
  ColHdg3N='';
  Des1='';
  Des2='';
  Des3='';
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt1,:ColHdg1N,:Des1
           From DCTSEG Where DtaSeg=:Seg1;
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt2,:ColHdg2N,:Des2
           From DCTSEG Where DtaSeg=:Seg2;
  Exec SQL Select ColTxt,ColHdgSeg,Des
           Into :ColTxt3,:ColHdg3N,:Des3
           From DCTSEG Where DtaSeg=:Seg3;

  // If Column Text or Column headings aer blank override them to the description
  If ColTxt1='';
    ColTxt1=Des1;
  EndIf;
  If ColTxt2='';
    ColTxt2=Des2;
  EndIf;
  If ColTxt3='';
    ColTxt3=Des3;
  EndIf;
  If ColHdg1N='';
    ColHdg1N=ColTxt1;
  EndIf;
  If ColHdg2N='';
    ColHdg2N=ColTxt2;
  EndIf;
  If ColHdg3N='';
    ColHdg3N=ColTxt3;
  EndIf;

  // Build column text if needed
  If colTxt = '';
    ColTxt=%trim(ColTxt1) + ' ' + %trim(ColTxt2) + ' ' + %trim(ColTxt3) + ' ';
  EndIf;

  // Build column headings if needed
  If colHdg1='' and colHdg2 = '' and colHdg3 = '';
    word = %split(ColHdg1N+' '+ColHdg2N+' '+ColHdg3N);
    For cnt = 1 To 20;
      If word(cnt) = ' ';
        cnt -= 1;
        Leave;
      EndIf;
    EndFor;
    If cnt = 1;
      ColHdg1=word(1);
    ElseIf cnt = 2;
      ColHdg1=word(1);
      ColHdg2=word(2);
    ElseIf cnt = 3;
      ColHdg1=word(1);
      ColHdg2=word(2);
      ColHdg3=word(3);
    ElseIf cnt = 4;
      ColHdg1=word(1) + ' ' + word(2);
      ColHdg2=word(3);
      ColHdg3=word(4);
    ElseIf cnt = 5;
      ColHdg1=word(1) + ' ' + word(2);
      ColHdg2=word(3) + ' ' + word(4);
      ColHdg3=word(5);
    ElseIf cnt = 6;
      ColHdg1=word(1) + ' ' + word(2);
      ColHdg2=word(3) + ' ' + word(4);
      ColHdg3=word(5) + ' ' + word(6);
    ElseIf cnt = 7;
      ColHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
      ColHdg2=word(4) + ' ' + word(5);
      ColHdg3=word(6) + ' ' + word(7);
    ElseIf cnt = 8;
      ColHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
      ColHdg2=word(4) + ' ' + word(5) + ' ' + word(6);
      ColHdg3=word(7) + ' ' + word(8);
    ElseIf cnt >= 9;
      ColHdg1=word(1) + ' ' + word(2) + ' ' + word(3);
      ColHdg2=word(4) + ' ' + word(5) + ' ' + word(6);
      ColHdg3=word(7) + ' ' + word(8) + ' ' + word(9);
    EndIf;
  EndIf;

End-Proc;


// select item
Dcl-Proc UpdateScreen;

  // Inactivate
  If Option = '4';
    Exec SQL    Update DCTFLD Set AcvRow = '0' Where dctFldIdn = :pmrDctFldIdn;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Rename
  ElseIf Option = '7';
    Exec SQL Update DCTFLD Set FldNme = :FldNme Where dctFldIdn = :pmrDctFldIdn;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // ReActivate
  ElseIf Option = '13';
    Exec SQL Update DCTFLD Set AcvRow = '1' Where dctFldIdn = :pmrDctFldIdn;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Update
  ElseIf Option = '2';
    Exec SQL
      Update DCTFLD
      Set (ColTxt, ColHdg, FldTyp, FldLen, FldScl, FldAlc,
           PrjNbr, FldPmp, AlwNul, DftVal, FldEnm, FldNmeSql)
        = (:ColTxt, :ColHdg1 Concat :ColHdg2 Concat :ColHdg3,
           :FldTyp, :FldLen, :FldScl, :FldAlc,
           :PrjNbr, :FldPmp, :AlwNul, :DftVal, :FldEnm, :FldNmeSql)
    Where dctFldIdn = :pmrDctFldIdn;
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

    // Create/Copy
  ElseIf Option in %list('1':'3');
    Exec SQL
    Insert Into DCTFLD
          (DctNme,FldNme,ColTxt, ColHdg, FldTyp,
           FldLen, FldScl, FldAlc,
           PrjNbr, FldPmp, AlwNul, DftVal, FldEnm)
    Values(:DctNme,:FldNme,:ColTxt,
           :ColHdg1 Concat :ColHdg2 Concat :ColHdg3,:FldTyp,
           :FldLen,:FldScl,:FldAlc,
           :PrjNbr,:FldPmp,:AlwNul,:DftVal,:FldEnm);
    If sqlState > '02';
      $ErrorMessage('DCT0200');
    EndIf;

  EndIf;

  // Update field in dictionary file
  DCTFLDB9(DctNme:FldNme);

End-Proc;


// Handle prompt key (F4)
Dcl-Proc Prompt;
  Dcl-S pmFldTyp like(APLDCT.fldTyp);
  Dcl-S pmKeyPressed like(keyPressed);
  Dcl-S pmOption like(Option);

  // Prompt State
  If CsrFld = 'FLDTYP' and not ProtectDta;
    pmOption = '1';
    FLDTYPD1(pmFldTyp:pmOption:pmKeyPressed);
    If pmKeyPressed = 'ENTER' and not ProtectDta;
      fldTyp = pmFldTyp;
    EndIf;

    // * Error if not on promptable field
  Else;
    $ErrorMessage('DCT0004');
  EndIf;

End-Proc;


// Call field builder program
Dcl-Proc FieldBuilder;
  Dcl-S pmFldNme like(APLDCT.FldNme);
  Dcl-S pmColTxt like(APLDCT.ColTxt);
  Dcl-S pmColHdg like(APLDCT.ColHdg);

  DCTFLDD3(DctNme:pmFldNme:pmColTxt:pmColHdg:keyPressed);

  If keyPressed='ENTER';
    FldNme=pmFldNme;
    ColTxt=pmColTxt;
    ColHdg1=%subst(pmColHdg:1:20);
    ColHdg2=%subst(pmColHdg:21:20);
    ColHdg3=%subst(pmColHdg:41:20);
  EndIf;

End-Proc;


// Initialization subroutine
Dcl-Proc InitializeProgram;

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
    $GetFieldLocation(psdsPgmNam:'DCTFLD':outRow:outCol);

    // * allow key field changes on revise
  ElseIf Option = '2';
    Mode = 'Revise';
    ProtectDta = *off;
    $GetFieldLocation(psdsPgmNam:'COLTXT':outRow:outCol);

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

  If not %open(DCTFLDF2);
    Open DCTFLDF2;
  EndIf;

  // See if this field is in  use in a production file
  prdfle = *off;
  Exec SQL Select '1' Into :prdfle
           From FLEFLD
           Join FLEMST on (FLEMST.fleLib,FLEMST.fleNme) = (FLEFLD.fleLib,FLEFLD.fleNme)
           Where (FLEMST.dctNme, FLEFLD.fldNme, FLEMST.prdFle) = (:dctNme,:fldNme,'Y');

  SetAttributes();
  Clear DspVal;

  DltAct   = *off;

  // Display and process data
  Clear Dta;
  Exec SQL
    Select FldNme, ColTxt, ColHdg, FldTyp, FldLen, FldScl, FldAlc,
           PrjNbr, FldPmp, AlwNul, DftVal, FldEnm, FldNmeSql,
           to_char(crtDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(crtJob) || ' ' || trim(crtpgm),
           to_char(mntDtm, 'YYYY-MM-DD HH24:MI:SS') || ' ' || trim(mntJob) || ' ' || trim(mntpgm)
      Into :Dta
    From DCTFLD
    Where DctFldIdn = :pmrDctFldIdn;
  Eval-Corr DspVal = Dta;
  FldNmeCpy = fldNme;
  crtStr = Dta.crtStr;
  mntStr = Dta.mntStr;

  // Get Dictionary name
  Exec SQL
    Select Des, dctNme Into :DctDes, :dctNme
    From DCTMST
    Where DctMstIdn=:pmrDctMstIdn;

End-Proc;
