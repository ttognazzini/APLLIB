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
  FNCKEYCPY@ Char(1);
  FRMKEYS@ Char(1);
  OPTIONCPY@ Char(1);
  PGMNMECPY@ Char(1);
End-Ds;

// Data structure of field attribute fields only used for key fields
Dcl-Ds FldAtrKey;
  PGMNME@ Char(1);
  FNCKEY@ Char(1);
  OPTION@ Char(1);
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  DES@ Char(1);
  SEQNBR@ Char(1);
End-Ds;
