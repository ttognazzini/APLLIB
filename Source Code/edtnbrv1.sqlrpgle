**Free
Ctl-Opt nomain BndDir('APLLIB') Option(*SrcStmt) decedit('0.');

// SQL Function, Edit a Numeric Field

// crtsqlrpgi obj(qtemp/edtnbrv1) srcfile(APLLIB/qsrc)
//            objtype(*module) dbgview(*source)

// crtsrvpgm  srvpgm(APLLIB/edtnbrv1) module(qtemp/edtnbrv1) srcfile(qsrc)
// srcmbr(edtnbrn1) text('SQL Function, Edit a Numeric Field')
// export(*srcfile)

// dltmod     module(qtemp/edtnbrv1)


// EdtNbr - Edit Number

// INPUT:  number = number to edit
//         codes  = edit code/ properties

// OUTPUT: the character value of the edited number

//  Codes is a delimited string containing a list of the options.
//  The list can be delemited by a comma, colon or space, meaning the following are all the same
//    EDTNBR(1.1,'Len(7),Left dec(2)
//    EDTNBR(1.1,'Len(7)   Left dec(2)
//    EDTNBR(1.1,'Len(7):Left,dec(2)

// These are the options that can be passed, case insensitive
//   Sign(x)    - Determines the sign used for negative number, defaults to -
//                can be -,cr, or p for parethesis
//   NoSign     - does nto include any sign, makes the number look positive
//   NoCommas   - removes commas from the result, the defautl includes commas
//   Left       - changes the negative sign to be on the left side of the number
//   Len(xxx)   - causes the returned value to all be the same length
//                this is the lenght of digits indcluding the decimal positions
//   Dec(xxx)   - fixes the number of decimals positions to the passed value
//   Round(xxx) - determines wheather to round, truncate or round up any insignificant decimal positions
//                the program only looks at the first character and it is not case sensitive
//                Anything starting with a U rounds up, so you can pass round(u) or Round(Up)
//                Anything starting with a T truncates, so you can pass round(t) or Round(trunc) or ROUND(TRUNCATE)
//                Anything else performs a half adjust whichi s also the default if it is not passed

Dcl-Proc EdtNbr export;
  Dcl-Pi *n char(60);
    psNbr packed(30:10);
    psOptions Varchar(30) options(*nopass);
  End-Pi;
  Dcl-S len packed(2);
  Dcl-S dec packed(2);
  Dcl-S round Char(1);
  Dcl-S sign Varchar(2);
  Dcl-S words Char(10) dim(8);
  Dcl-S wrkNbr packed(40:10);
  Dcl-S wrkInt packed(30);
  Dcl-S wrkDec packed(10:10);
  Dcl-S Left ind;
  Dcl-S noCommas ind;
  Dcl-S noSign ind;
  Dcl-S returnValue Varchar(30);
  Dcl-S returnValue2 char(30);
  Dcl-S tpval char(15);
  Dcl-S i packed(2);
  Dcl-S totLen packed(5);

  // set defaults
  noCommas = *off;
  noSign = *off;
  Left = *off;
  len = 9;
  dec = 0;
  round = ' ';

  // break the options string into words and check each one
  If %Parms() >= 2;
    words = %split(%upper(psOptions):' ,:;');
    For i = 1 To 8;
      If words(i) = 'LEFT';
        Left = *on;
      ElseIf words(i) = 'NOSIGN';
        noSign = *on;
      ElseIf words(i) = 'NOCOMMAS';
        noCommas = *on;
      ElseIf words(i) <> ''  and %xlate('1234567890.':'           ':%trim(words(i))) = '';
        len = %int(words(i));
        dec = %int(%subst(words(i):%scan('.':words(i))+1:2));
      ElseIf %subst(words(i):1:5) = 'SIGN(';
        Monitor;
          sign = %subst(words(i):6:1);
        On-Error;
        EndMon;
      ElseIf %subst(words(i):1:4) = 'LEN(';
        Monitor;
          len = %Dec(%subst(words(i):5:%Scan(')':words(i))-5):2:0);
        On-Error;
        EndMon;
      ElseIf %subst(words(i):1:4) = 'DEC(';
        Monitor;
          dec = %Dec(%subst(words(i):5:%Scan(')':words(i))-5):2:0);
        On-Error;
        EndMon;
      ElseIf %subst(words(i):1:6) = 'ROUND(';
        Monitor;
          round = %subst(words(i):7:1);
        On-Error;
        EndMon;
      EndIf;
    EndFor;
  EndIf;

  // set the value of sign to add back on later, needs to include the spacing
  If noSign;
    sign = '';
  ElseIf sign = 'C' and psNbr < 0;
    sign = 'CR';
  ElseIf sign = 'C';
    sign = '  ';
  ElseIf sign = 'P';
  ElseIf psNbr < 0;
    sign = '-';
  Else;
    sign = ' ';
  EndIf;

  // save off if the value is negative or not
  If psNbr < 0;
    wrkNbr = psNbr * -1;
  Else;
    wrkNbr = psNbr;
  EndIf;

  // handle the round option
  If dec <> 0;
    wrkNbr = wrkNbr * 10**dec;
  EndIf;
  If round = 'U';
    wrkNbr = %DecH(wrkNbr+.49:40:0) ;
  ElseIf round = 'T';
    wrkNbr = %int(wrkNbr/1);
  Else;
    wrkNbr = %dech(wrkNbr/1:40:0);
  EndIf;
  If dec <> 0;
    wrkNbr = wrkNbr / 10**dec;
  EndIf;
  wrkInt = %int(wrkNbr);
  WrkDec = wrkNbr - %int(wrkNbr);

  // get the integer part of the number, if needs to be cut down to the length - decimal positions
  If noCommas;
    returnValue = %Trim(%EditC(wrkInt:'Z'));
  Else;
    returnValue = %Trim(%EditC(wrkInt:'J'));
  EndIf;

  // add the decimal position to the end
  If dec > 0;
    tpval = %editc(wrkdec:'X');
    returnValue += '.' + %subst(%EditC(wrkDec:'X'):1:dec);
  EndIf;

  // add the negative sign, must leave a space for it either way
  If sign = 'P' and psNbr < 0;
    returnValue =  '(' + returnValue + ')';
  ElseIf sign = 'P';
    returnValue =  ' ' + returnValue + ' ';
  ElseIf Left;
    returnValue = sign + returnValue;
  Else;
    returnValue += sign;
  EndIf;

  // calculate the total field length so it can be right justified
  totLen = len;
  if dec <> 0;
    totLen += 1;
  ENDIF;
  totLen += %len(sign);
  if not nocommas;
    totLen += %int((len-dec-1)/3);
  ENDIF;
  if sign = 'P';
    totLen += 1;
  ENDIF;

  // right justify the result
  returnValue2 = '';
  evalr %subst(returnValue2:1:totLen) = returnValue;

  Return returnValue2;

End-Proc;
