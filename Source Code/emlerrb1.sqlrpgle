**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) actgrp(*new) Main(Main) Debug;

// Test EMLERRC1 from RPG

/Copy APLLIB/QSRC,EMLERRC1PR // Sends an email with the Job Log, Call stack and optional dump attached

Exec SQL Set Option Commit    = *none,
                    CloSQLCsr = *endactgrp,
                    UsrPrf    = *owner,
                    datfmt    = *ISO,
                    DynUsrPrf = *owner;


Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('EMLERRB1');
  End-Pi;

  // Test 1
  EMLERRC1('tim.tognazzini@arrowheadwinch.com'
          :'Test 1 (EMLERRB1)'
          :'This email should contain a joblog and call stack attachment');

  // Test 2 - with 2 email address
  EMLERRC1('tim.tognazzini@arrowheadwinch.com'
          :'Test 2 (EMLERRB1)'
          :'This email should go to 2 addresses'
          :*omit
          :*omit
          :'tognazzini@hotmail.com');

  // Test 3 - with dump, this is probably the most perferred example
  //          make sure the Ctl-Opt or H specs have the DEBUG keyword
  dump;
  EMLERRC1('tim.tognazzini@arrowheadwinch.com'
          :'Test 3 (EMLERRB1)'
          :'This email should go to 2 addresses'
          :'Y');

  // Test 4 - different from address
  EMLERRC1('tim.tognazzini@arrowheadwinch.com'
          :'Test 4 (EMLERRB1)'
          :'This email should go to 2 addresses'
          :*omit
          :'tognazzini@hotmail.com');


End-Proc;
