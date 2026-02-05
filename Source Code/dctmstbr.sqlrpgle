**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*Caller) BndDir('APLLIB') Main(Main);

// A/P Contact - Master List Driver

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/COPY QSRC,OTOSRVV1PR // Output Options DS and prototypes

/COPY QSRC,DCTMSTBRPR // A/P contact list - driver
/COPY QSRC,DCTMSTB1PR // A/P contact list
/COPY QSRC,DCTMSTDRPR // A/P contact List - Prompt
/COPY QSRC,PRCSCRD1PR // Display processing screen


// Default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, DatFmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('DCTMSTBR');
    pmrKeyPressed like(keyPressed) options(*nopass:*omit);
    pmrDctMstBrDs like(dctMstBrDs) options(*nopass:*omit);
  End-Pi;

  // Build default report parameters and call report prompt program
  Reset dctMstBrDs;
  If %parms >= 2 and %addr(pmrDctMstBrDs) <> *null;
    dctMstBrDs = pmrDctMstBrDs;
  EndIf;

  DoW 1 = 1;

    If #$INTACT() = 'I'; // only if this is an interactive job
      DCTMSTDR(dctMstBrDs:keyPressed);
      If keyPressed<> 'ENTER';
        If %parms >= 1 and %addr(pmrKeyPressed) <> *null;
          pmrKeyPressed = keyPressed;
        EndIf;
        Return;
      EndIf;
    EndIf;

    // build default output options
    OTODFTB1(otoDs:'AP':psDsPgmNam:'DCTMSTO1':'132':'066':'4':dctMstBrDs.rptTtl);

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

  PRCSCRD1('Creating contact list.');

  // call the report printing program
  DCTMSTB1(dctMstBrDs:otoDs);

End-Proc;
