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
  FLDTYPCPY@ Char(1);
  FRMKEYS@ Char(1);
End-Ds;

// Data structure of field attribute fields only used for key fields
Dcl-Ds FldAtrKey;
  FLDTYP@ Char(1);
End-Ds;

// Data structure of field attribute fields used for all other fields
Dcl-Ds FldAtrDta;
  DFTVAL@ Char(1);
  FRCLEN3@ Char(1);
  REQALC@ Char(1);
  FRCLEN2@ Char(1);
  DES@ Char(1);
  FRCLEN4@ Char(1);
  ALWLEN@ Char(1);
  FRCLEN5@ Char(1);
  SYSTYP@ Char(1);
  NMR@ Char(1);
  MAXLEN@ Char(1);
  SMLVAL@ Char(1);
  ALWDEC@ Char(1);
  LRGVAL@ Char(1);
  REQLEN@ Char(1);
  ALWALC@ Char(1);
  SYSLEN@ Char(1);
  FRCLEN1@ Char(1);
  FRCLEN@ Char(1);
End-Ds;
