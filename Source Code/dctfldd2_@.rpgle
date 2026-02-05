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
  FLDNMECPY@ Char(1);
  FRMKEYS@ Char(1);
End-Ds;

// Data structure of field attribute fields only used for key fields
Dcl-Ds FldAtrKey;
  FLDNME@ Char(1);
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  DFTVAL@ Char(1);
  COLHDG3@ Char(1);
  FLDALC@ Char(1);
  FLDPMP@ Char(1);
  FLDSCL@ Char(1);
  COLHDG2@ Char(1);
  COLHDG1@ Char(1);
  FLDNMESQL@ Char(1);
  FLDTYP@ Char(1);
  PRJNBR@ Char(1);
  COLTXT@ Char(1);
  FLDLEN@ Char(1);
  ALWNUL@ Char(1);
  FLDENM@ Char(1);
  DSPPMT@ Char(1);
End-Ds;
