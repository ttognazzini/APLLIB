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
  APLDES@ Char(1);
  DES@ Char(1);
  DFTAUTDES@ Char(1);
  DSPFLE@ Char(1);
  FRMKEYS@ Char(1);
  MNUNME@ Char(1);
  MNUOBJDES@ Char(1);
  OBJTYP@ Char(1);
  PGMNME@ Char(1);
  PGMNMECPY@ Char(1);
  REQDBA@ Char(1);
  REQITR@ Char(1);
  REQOWN@ Char(1);
  SECAUT@ Char(1);
  SECPGM@ Char(1);
  WEBAPLDES@ Char(1);
End-Ds;
