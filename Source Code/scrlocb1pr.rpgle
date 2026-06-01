**Free
// Refresh screen field locations

// Parameters
//   1. Source Library   Ex: TOGLIB, ARRLIB
//   2. Source File      Ex: QDDSSRC, SOURCE
//   3. Source Member    Ex: ARR123FM, ARR137F1
Dcl-Pr SCRLOCB1 extPgm('APLLIB/SCRLOCB1');
  sourceLibrary Char(10) const;
  sourceFile    Char(10) const;
  sourceMember  Char(10) const;
End-Pr;
