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
  CPYDSP@ Char(1);
  CPYFNC@ Char(1);
  CPYOPT@ Char(1);
  CPYPRT@ Char(1);
  CPYSRC@ Char(1);
  CPYVIW@ Char(1);
  FRMDLB@ Char(1);
  FRMLIB@ Char(1);
  FRMPLB@ Char(1);
  FRMVLB@ Char(1);
  TODLB@ Char(1);
  TOLIB@ Char(1);
  TOPLB@ Char(1);
  TOVLB@ Char(1);
End-Ds;
