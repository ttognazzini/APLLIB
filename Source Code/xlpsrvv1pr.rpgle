**free
Dcl-S XLPROWS    Packed(9:0);
Dcl-S XLPCOLS    Packed(9:0);
Dcl-S XLPROW     Packed(9:0);
Dcl-S XLPCOL     Packed(9:0);

Dcl-Pr XLPOPEN Zoned(1:0) ExtProc;
  #$PATH         Varchar(1024) CONST;
End-Pr;

Dcl-Pr XLPCHR Ind ExtProc;
  SHEET          Varchar(1024)  CONST;
  ROW            Int(10)    VALUE;
  COLUMN         Int(5)     VALUE;
  Value          Varchar(32767)  CONST;
End-Pr;

Dcl-Pr XLPNUM Ind ExtProc;
  SHEET          Varchar(1024)  CONST;
  ROW            Int(10)    VALUE;
  COLUMN         Int(5)     VALUE;
  Value          Float(8)   VALUE;
End-Pr;

Dcl-Pr XLPSTR ExtProc;
  SHEET          Varchar(1024)  CONST;
  ROW            Int(10)    VALUE;
End-Pr;

Dcl-Pr XLPEND ExtProc;
  SHEET          Varchar(1024)  CONST;
  ROW            Int(10)    VALUE;
End-Pr;

Dcl-Pr XLPREAD Ind ExtProc;
End-Pr;

Dcl-Pr XLPNEXT Varchar(1024) ExtProc;
  PSCOL          Zoned(1:0) CONST OPTIONS(*NOPASS);
End-Pr;

Dcl-Pr XLPCLOSE ExtProc;
End-Pr;
