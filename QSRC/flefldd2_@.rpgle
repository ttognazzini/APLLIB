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
  PRIKEYD@ Char(1);
  ENCFLDD@ Char(1);
  STRIDN@ Char(1);
  IDNICM@ Char(1);
  AUDFLD@ Char(1);
  FLDSEQ@ Char(1);
End-Ds;
