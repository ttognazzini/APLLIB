**Free
Dcl-Pr IFSPMTD1 ExtPgm('APLLIB/IFSPMTD1');
  pmrStrDir varchar(999) const; // Starting Directory
  pmrRtnPth varchar(999); // returned path
  pmrAlwFlr varchar(1) options(*nopass:*omit) const; // Allow a folder to be selected - Default N
  pmrAlwFle varchar(1) options(*nopass:*omit) const; // Allow a file to be selected - Default Y
  pmrKeyPressed Like(keyPressed) options(*nopass:*omit); // key pressed, = ENTER if selected
  pmrSchVal like(APLDCT.schVal) options(*nopass:*omit) const; // Optional default search string
End-Pr;
