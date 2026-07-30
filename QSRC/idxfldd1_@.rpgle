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
  IDXNMECPY@ Char(1);
  FLDENMD1@ Char(1);
  PRIKEY1@ Char(1);
  TYP1@ Char(1);
  IDXNME@ Char(1);
  FRMKEYS@ Char(1);
  FLDNME1@ Char(1);
  ALWNUL1@ Char(1);
  IDXTXT@ Char(1);
  IDXLIB@ Char(1);
  IDXSEQ1@ Char(1);
  IDXUNID@ Char(1);
  IDXLIBCPY@ Char(1);
  COLTXT1@ Char(1);
  IDXSEQ@ Char(1);
End-Ds;

// Data structure of fields for SQL select into for a SFL program
Dcl-Ds dta Qualified Dim(12);
  Key CHAR(20);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  SAVSEQ PACKED(7);
  IDXSEQ ZONED(7);
  PRIKEY CHAR(3);
  FLDNME CHAR(10);
  COLTXT CHAR(40);
  TYP CHAR(30);
  FLDENMD CHAR(3);
  ALWNUL CHAR(3);
End-Ds;

// Data structure of fields for columns in a SFL
// This is used to move all values from DTA to field names on the screen
Dcl-Ds sflFields;
  Key CHAR(20);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  SAVSEQ PACKED(7);
  IDXSEQ ZONED(7);
  PRIKEY CHAR(3);
  FLDNME CHAR(10);
  COLTXT CHAR(40);
  TYP CHAR(30);
  FLDENMD CHAR(3);
  ALWNUL CHAR(3);
End-Ds;

// Data structure of fields for position to columns, used in a SFL program
Dcl-Ds pos Qualified;
  Key CHAR(20);
  FLELIB CHAR(10);
  FLENME CHAR(10);
  SAVSEQ PACKED(7);
  IDXSEQ ZONED(7);
  PRIKEY CHAR(3);
  FLDNME CHAR(10);
  COLTXT CHAR(40);
  TYP CHAR(30);
  FLDENMD CHAR(3);
  ALWNUL CHAR(3);
End-Ds;

// Data structure of default values for position to columns
// This DS is used to compare POS to to see if any position to fields are set.
Dcl-Ds posDefault LikeDs(pos) inz;

// Data structure of position to entry fields
// This is used to move values on line1 to other DS's or to compare them
Dcl-Ds line1;
  Key1 CHAR(20);
  FLELIB1 CHAR(10);
  FLENME1 CHAR(10);
  SAVSEQ1 PACKED(7);
  IDXSEQ1 ZONED(7);
  PRIKEY1 CHAR(3);
  FLDNME1 CHAR(10);
  COLTXT1 CHAR(40);
  TYP1 CHAR(30);
  FLDENMD1 CHAR(3);
  ALWNUL1 CHAR(3);
End-Ds;

// Data structure of position to entry field defaults.
// This is used to compare to lines1 ds to see if any values are entered.
Dcl-Ds line1Defaults LikeDs(line1) inz;

// Data structure containing array of order by values
// This is used so the order by value can be added using the srtCde as the array index.
// This prevents the need to hard code the order by values.
Dcl-Ds orderByDS Qualified;
  values char(220)
    inz('IDXSEQ              +
         upper(PRIKEY)       +
         upper(FLDNME)       +
         upper(COLTXT)       +
         upper(TYP)          +
         upper(FLDENMD)      +
         upper(ALWNUL)       +
          ');
  Value char(20) dim(11) overlay(values);
End-Ds;

// contains the SFLPAG value, or largest value if multiple are present
Dcl-S SFLPage packed(5:0) Inz(12);
