**Free
// Sends an error message with the job log, call stack and optional dump attached
Dcl-Pr EMLERRC1 ExtPgm;
  emlTo1  char(50) const;
  subject char(100) const;
  message char(1000) const;
  incDmp  char(1)  options(*nopass:*omit) const; // Optional, Y if calling program dumped
  emlFrm  char(50) options(*nopass:*omit) const; // Optional
  emlTo2  char(50) options(*nopass:*omit) const; // Optional
  emlTo3  char(50) options(*nopass:*omit) const; // Optional
End-Pr;
