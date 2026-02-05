**Free
Ctl-Opt Option(*SrcStmt);

// Disply Panel Group CPP (DSPPNLGRP)

// Parameters
Dcl-Pi *n;
  P1 LIKEDS(P1mdl); //liste de panneaux
  P2 LIKEDS(P2mdl); // Range
  P3 Char(55);      // titre
  P4 Char(20);      // index
  P5 Char(1);       // plein écran ?
  P6 LIKEDS(P6mdl); // position curseur
  P7 LIKEDS(P7mdl); // Fenêtre;
End-Pi;

Dcl-Ds P1mdl Template;
  NBP INt(5);
  Dep INT(5) DIM(25);
  filler Char(5000);
End-Ds;

Dcl-Ds P2mdl Template;
  NBE2 INT(5);
  RANGE Char(8);
  RG1 INT(10) OVERLAY(RANGE);
  RG2 INT(10) OVERLAy(RANGE : *NEXT);
End-Ds;

Dcl-Ds P6mdl Template;
  NBE6 INT(5);
  PC   Char(8);
  PCC  INT(10) OVERLAY(PC);
  PCL  INT(10) OVERLAY(PC : *NEXT);
End-Ds;

Dcl-Ds P7mdl Template;
  NBE7 INT(5);
  ASG Char(8);
  ASGL INt(10) OVERLAY(ASG);
  ASGC INt(10) OVERLAY(ASG : *NEXT);
  AID Char(8);
  AIDL INt(10) OVERLAY(AID);
  AIDC INt(10) OVERLAY(AID : *NEXT);
End-Ds;

Dcl-S TBi Char(52) DIM(25);

Dcl-Ds ELEMH;
  NBE1 int(5);
  PNL Char(10);
  BIB Char(10);
  HLP Char(32);
End-Ds;

Dcl-Ds DSH;
  PNLDS Char(10);
  BIBDS Char(10);
  HLPDS Char(32);
End-Ds;

Dcl-S X  INt(10);
Dcl-S NH INt(10);

Dcl-Ds ZERROR;
  LGERR INt(10);
  LGRCV INT(10);
  IDRCV Char(7);
  reserved Char(1);
End-Ds;

Dcl-Pr QDCXLATE EXTPGM('QDCXLATE');
  *n PACKED(5:0) const;
  *n Char(52);
  *n Char(10)    const;
  *n Char(10)    const;
End-Pr;

// prototype for QUHDSPH- Display Help API
Dcl-Pr QUHDSPH EXTPGM('QUHDSPH');
  *n Char(52) DIM(25); // help identifier array
  //<-pnlgrp-><-library-><-module->
  //char(10)  char(10)   char(32)
  *n INT(10);          // number of help identifiers
  *n Char(8);          // Help Type
  // (the others are displayed with F2 "EXTENDED HELP")
  *n Char(55);         // Full display
  *n Char(20);         //       Qualified search index object name  <-INDEX(10C)-><-LIBRARY(10C)>
  *n Char(1);          // Display Type  Y=Full Screen, N=Can be window, depends on USROPT
  *n Char(8);          // Upper Left Corner
  *n Char(8);          // Lower Right Corner
  *n Char(8);          // Cursor Location
  *n Char(10);         // Error Code
End-Pr;

// Panel list processing
For x = 1 To P1.NBP;
  ELEMH = %SUBST(P1 : P1.Dep(x)+1 : %size(ELEMH));
  If PNL <> *BLANK  and BIB <> *BLANK  and HLP <> *BLANK;
    PNLDS = PNL;
    BIBDS = BIB;
    HLPDS = HLP;
    // CVt Losercase to Uppercase
    QDCXLATE(32 : DSH : 'QSYSTRNTBL' : '*LIBL');
    NH += 1;
    TBI(NH) = DSH;
  EndIf;
EndFor;

If P2.RG1 > NH;
  P2.RG1 = NH;
EndIf;

If P2.RG2 < P2.RG1 or P2.RG2 > NH;
  P2.RG2 = NH;
EndIf;

LGERR = 15;

// Call display API
QUHDSPH(TBi : NH : P2.RANGE : P3 : P4 : P5 : P7.ASG : P7.AID: P6.PC: ZERROR);

*INLR = *ON;
