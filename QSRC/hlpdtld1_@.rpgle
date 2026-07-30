**free
// ************************************************************************************
// *                              *** Warning ***                                     *
// ************************************************************************************
// * Do not manually build or change this, it is rebuilt from the screen, any changes *
// * will be overridden. It can be rebuilt manually using custom PDM option SC in     *
// * front of the display file. If SC is not setup add it with the following command  *
// *    call scrlocb1 (&l &f &n)                                                      *
// ************************************************************************************

// Data structure of field attribute fields only used for copy Options
Dcl-Ds FldAtrCpy;
End-Ds;

// Data structure of field attribute fields only used for key fields
Dcl-Ds FldAtrKey;
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  HLPTXT@ Char(1);
  DES@ Char(1);
  FLDNME@ Char(1);
  HLPREF@ Char(1);
  VAL@ Char(1);
  DSPFLE@ Char(1);
  DCTNME@ Char(1);
End-Ds;

// Data structure of fields for SQL select into for a SFL program
Dcl-Ds dta Qualified Dim(14);
  SEQNBR ZONED(4);
  HLPTXT CHAR(79);
End-Ds;

// Data structure of fields for columns in a SFL
// This is used to move all values from DTA to field names on the screen
Dcl-Ds sflFields;
  SEQNBR ZONED(4);
  HLPTXT CHAR(79);
End-Ds;

// contains the SFLPAG value, or largest value if multiple are present
Dcl-S SFLPage packed(5:0) Inz(14);
