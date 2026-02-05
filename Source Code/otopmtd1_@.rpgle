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
  FAXOUT@ Char(1);
  USRDTA@ Char(1);
  HLDOUT@ Char(1);
  PRTOUT@ Char(1);
  PRTOTQ@ Char(1);
  EMLOUTH@ Char(1);
  PRTOUTH@ Char(1);
  ARCOUT@ Char(1);
  PRTFRM@ Char(1);
  NBRCPY@ Char(1);
  PRTDEV@ Char(1);
  ARCOUTH@ Char(1);
  EMLOUT@ Char(1);
  PRTQUL@ Char(1);
  FAXOUTH@ Char(1);
  SAVOUT@ Char(1);
End-Ds;
