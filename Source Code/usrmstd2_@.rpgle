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
  USRPRF@ Char(1);
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  USREML@ Char(1);
  ACGCDE@ Char(1);
  PHNEXT@ Char(1);
  USRTXT@ Char(1);
  USRDPT@ Char(1);
  EMPNBR@ Char(1);
  USRINT@ Char(1);
  FRMKEYS@ Char(1);
  PHNNBR@ Char(1);
  LSTNME@ Char(1);
  USRTTL@ Char(1);
  GRPPRF@ Char(1);
  FSTNME@ Char(1);
  CPYUSR@ Char(1);
End-Ds;
