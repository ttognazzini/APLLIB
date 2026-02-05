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
  FLELIBCPY@ Char(1);
  FLENMECPY@ Char(1);
  FRMKEYS@ Char(1);
End-Ds;

// Data structure of field attribute fields only used for key fields
Dcl-Ds FldAtrKey;
  FLELIB@ Char(1);
  FLENME@ Char(1);
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  CHGSCDD@ Char(1);
  PRDFLED@ Char(1);
  TBLNME@ Char(1);
  DCTNME@ Char(1);
  FLEDES@ Char(1);
End-Ds;
