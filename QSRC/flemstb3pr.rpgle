**Free
Dcl-Pr FLEMSTB3 ExtPgm('FLEMSTB3');
  pmrFleLib Like(APLDCT.FleLib);
  pmrFleNme Like(APLDCT.FleNme);
  pmrChkSrc char(1) const Options(*nopass); // send a Y or N, defaults to Y
End-Pr;
