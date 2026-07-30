**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*New) BndDir('APLLIB') Main(Main);

// Role - Master List Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/COPY QSRC,OTOSRVV1PR // Output Options DS and prototypes

/COPY QSRC,USRROLBRPR // A/P contact list - driver
/COPY QSRC,USRROLB1PR // A/P contact list
/COPY QSRC,USRROLDRPR // A/P contact List - Prompt
/COPY QSRC,PRCSCRD1PR // Display processing screen


// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRROLBR');
    pmrKeyPressed like(keyPressed) options(*nopass:*omit);
    pmrUsrRolBrDs like(usrRolBrDs) options(*nopass:*omit);
  End-Pi;

  // Build default report parameters and call report prompt program
  Reset usrRolBrDs;
  If %parms >= 2 and %addr(pmrUsrRolBrDs) <> *null;
    usrRolBrDs = pmrUsrRolBrDs;
  EndIf;

  DoW 1 = 1;

    If #$INTACT() = 'I'; // only if this is and interactive job
      USRROLDR(usrRolBrDs:keyPressed);
      If keyPressed<> 'ENTER';
        If %parms >= 1 and %addr(pmrKeyPressed) <> *null;
          pmrKeyPressed = keyPressed;
        EndIf;
        Return;
      EndIf;
    EndIf;

    // build default output options
    OTODFTB1(otoDs:'AP':psDsPgmNam:'USRROLO1':'198':'066':'4':usrRolBrDs.rptTtl);

    // display the output option prompt screen
    If #$INTACT() = 'I'; // only if this is and interactive job
      OTOPMTD1(otoDs:keyPressed);
      If keyPressed<> 'ENTER';
        Iter;
      EndIf;
    EndIf;

    Leave;
  EndDo;

  If %parms >= 1 and %addr(pmrKeyPressed) <> *null;
    pmrKeyPressed = keyPressed;
  EndIf;

  PRCSCRD1('Creating role list.');

  // call the report printing program
  USRROLB1(usrRolBrDs:otoDs);

End-Proc;
