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
  EMLMSG04@ Char(1);
  EMLMSG10@ Char(1);
  EMLMSG03@ Char(1);
  EMLMSG09@ Char(1);
  FAXNBR@ Char(1);
  EMLMSG08@ Char(1);
  EMLMSG11@ Char(1);
  EMLMSG05@ Char(1);
  EMLNME@ Char(1);
  EMLMSG12@ Char(1);
  EMLMSG01@ Char(1);
  EMLMSG02@ Char(1);
  FRMNME@ Char(1);
  EMLMSG06@ Char(1);
  EMLMSG07@ Char(1);
End-Ds;
