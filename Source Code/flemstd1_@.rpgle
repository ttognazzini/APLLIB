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
  SEL@ Char(1);
  ACVDES1@ Char(1);
  TBLTYP1@ Char(1);
  FLEDES1@ Char(1);
  IDXCNT1@ Char(1);
  FLELIB1@ Char(1);
  FLENME1@ Char(1);
  NTEEXS1@ Char(1);
  SEL1@ Char(1);
  FLEERR1@ Char(1);
  DCTNME1@ Char(1);
  FLDCNT1@ Char(1);
End-Ds;

// Data structure of fields for SQL select into for a SFL program
Dcl-Ds dta Qualified Dim(17);
  Key ZONED(18);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  FLEDES CHAR(50);
  TBLTYP CHAR(10);
  STSDES CHAR(11);
  FLDCNT ZONED(5);
  IDXCNT ZONED(5);
  NTEEXS CHAR(1);
  DCTNME CHAR(10);
  FLEERR CHAR(1);
End-Ds;

// Data structure of fields for columns in a SFL
// This is used to move all values from DTA to field names on the screen
Dcl-Ds sflFields;
  Key ZONED(18);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  FLEDES CHAR(50);
  TBLTYP CHAR(10);
  STSDES CHAR(11);
  FLDCNT ZONED(5);
  IDXCNT ZONED(5);
  NTEEXS CHAR(1);
  DCTNME CHAR(10);
  FLEERR CHAR(1);
End-Ds;

// Data structure of fields for position to columns, used in a SFL program
Dcl-Ds pos Qualified;
  Key ZONED(18);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  FLEDES CHAR(50);
  TBLTYP CHAR(10);
  STSDES CHAR(11);
  FLDCNT ZONED(5);
  IDXCNT ZONED(5);
  NTEEXS CHAR(1);
  DCTNME CHAR(10);
  FLEERR CHAR(1);
End-Ds;

// Data structure of default values for position to columns
// This DS is used to compare POS to to see if any position to fields are set.
Dcl-Ds posDefault LikeDs(pos) inz;

// Data structure of position to entry fields
// This is used to move values on line1 to other DS's or to compare them
Dcl-Ds line1;
  Key1 ZONED(18);
  FLELIB1 CHAR(10);
  FLENME1 CHAR(10);
  FLEDES1 CHAR(50);
  TBLTYP1 CHAR(10);
  STSDES1 CHAR(11);
  FLDCNT1 ZONED(5);
  IDXCNT1 ZONED(5);
  NTEEXS1 CHAR(1);
  DCTNME1 CHAR(10);
  FLEERR1 CHAR(1);
End-Ds;

// Data structure of position to entry field defaults.
// This is used to compare to lines1 ds to see if any values are entered.
Dcl-Ds line1Defaults LikeDs(line1) inz;

// Data structure containing array of order by values
// This is used so the order by value can be added using the srtCde as the array index.
// This prevents the need to hard code the order by values.
Dcl-Ds orderByDS Qualified;
  values char(220)
    inz('upper(FLELIB)       +
         upper(FLENME)       +
         upper(FLEDES)       +
         upper(TBLTYP)       +
         upper(STSDES)       +
         FLDCNT              +
         IDXCNT              +
         upper(NTEEXS)       +
         upper(DCTNME)       +
         upper(FLEERR)       +
          ');
  Value char(20) dim(11) overlay(values);
End-Ds;

// contains the SFLPAG value, or largest value if multiple are present
Dcl-S SFLPage packed(5:0) Inz(17);
