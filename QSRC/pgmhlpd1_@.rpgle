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
  TXT@ Char(1);
  SEL@ Char(1);
  REFFLE1@ Char(1);
  HLPTYPD1@ Char(1);
  VAL1@ Char(1);
  REFFLD1@ Char(1);
  FLDCOL1@ Char(1);
  FLDROW1@ Char(1);
  FLDNME1@ Char(1);
  SEL1@ Char(1);
  LNECNT1@ Char(1);
  TXT1@ Char(1);
  NOTXT@ Char(1);
  FLDDES1@ Char(1);
End-Ds;

// Data structure of fields for SQL select into for a SFL program
Dcl-Ds dta Qualified Dim(15);
  Key CHAR(40);
  FLDROW ZONED(3);
  FLDCOL ZONED(3);
  FLDNME CHAR(10);
  VAL CHAR(10);
  HLPTYPD CHAR(20);
  LNECNT ZONED(5);
  TXT CHAR(25);
  REFFLE CHAR(10);
  REFFLD CHAR(10);
  FLDDES CHAR(22);
End-Ds;

// Data structure of fields for columns in a SFL
// This is used to move all values from DTA to field names on the screen
Dcl-Ds sflFields;
  Key CHAR(40);
  FLDROW ZONED(3);
  FLDCOL ZONED(3);
  FLDNME CHAR(10);
  VAL CHAR(10);
  HLPTYPD CHAR(20);
  LNECNT ZONED(5);
  TXT CHAR(25);
  REFFLE CHAR(10);
  REFFLD CHAR(10);
  FLDDES CHAR(22);
End-Ds;

// Data structure of fields for position to columns, used in a SFL program
Dcl-Ds pos Qualified;
  Key CHAR(40);
  FLDROW ZONED(3);
  FLDCOL ZONED(3);
  FLDNME CHAR(10);
  VAL CHAR(10);
  HLPTYPD CHAR(20);
  LNECNT ZONED(5);
  TXT CHAR(25);
  REFFLE CHAR(10);
  REFFLD CHAR(10);
  FLDDES CHAR(22);
End-Ds;

// Data structure of default values for position to columns
// This DS is used to compare POS to to see if any position to fields are set.
Dcl-Ds posDefault LikeDs(pos) inz;

// Data structure of position to entry fields
// This is used to move values on line1 to other DS's or to compare them
Dcl-Ds line1;
  Key1 CHAR(40);
  FLDROW1 ZONED(3);
  FLDCOL1 ZONED(3);
  FLDNME1 CHAR(10);
  VAL1 CHAR(10);
  HLPTYPD1 CHAR(20);
  LNECNT1 ZONED(5);
  TXT1 CHAR(25);
  REFFLE1 CHAR(10);
  REFFLD1 CHAR(10);
  FLDDES1 CHAR(22);
End-Ds;

// Data structure of position to entry field defaults.
// This is used to compare to lines1 ds to see if any values are entered.
Dcl-Ds line1Defaults LikeDs(line1) inz;

// Data structure containing array of order by values
// This is used so the order by value can be added using the srtCde as the array index.
// This prevents the need to hard code the order by values.
Dcl-Ds orderByDS Qualified;
  values char(220)
    inz('FLDROW              +
         FLDCOL              +
         upper(FLDNME)       +
         upper(VAL)          +
         upper(HLPTYPD)      +
         LNECNT              +
         upper(TXT)          +
         upper(REFFLE)       +
         upper(REFFLD)       +
         upper(FLDDES)       +
          ');
  Value char(20) dim(11) overlay(values);
End-Ds;

// contains the SFLPAG value, or largest value if multiple are present
Dcl-S SFLPage packed(5:0) Inz(15);
