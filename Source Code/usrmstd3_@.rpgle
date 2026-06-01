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
  SPOQLB@ Char(1);
  JDVLOC@ Char(1);
  JDLOG1@ Char(1);
  JDAREM@ Char(1);
  JDLOG3@ Char(1);
  JDJQLB@ Char(1);
  JDJOBQ@ Char(1);
  JDJPTY@ Char(1);
  JDMENU@ Char(1);
  JDEXCP@ Char(1);
  JDLOG2@ Char(1);
  SPOQNM@ Char(1);
  JDOUTQ@ Char(1);
  JDOQLB@ Char(1);
  JDOPTY@ Char(1);
End-Ds;
