**free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*New) BndDir('APLLIB') main(Main);

// Build APLLIB - Compile Driver

// This program accepts a library, source file, and memer type.
// It tries to build all object for tyhat passed member type. The
// copile command are based on the member type.

// The allowed member types are DSPF, PRTF, and SQLRPGLE

// The program contains exceptison for service programs and
// A few other specific programs. These do not get rebiult as
// they requrie special handling.


/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures

// DS to read from cursor into
Dcl-Ds dta qualified;
  lib char(10);
  srcFle char(10);
  srcMbr char(10);
  srcTyp char(10);
End-Ds;

// default SQL options, rarely do any of these change
Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endmod,
                    SrtSeq = *langidshr;

Dcl-Proc Main;
  Dcl-Pi *n;
    lib char(10);
    srcFle char(10);
    srcTyp char(10);
  End-Pi;

  // Pull a list of member for this type in the passed source file
  Exec SQL Declare sqlCrs cursor for
    Select
      system_table_schema lib,
      system_table_name srcFle,
      system_table_member as mbr,
      source_type srcTyp
    From QSYS2.SYSPARTITIONSTAT
    Where system_table_schema = :lib
      and system_table_name = :srcFle
      and source_type = :srcTyp
      and source_type is not null;
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next from sqlCrs into :dta;
  DoW sqlState < '02';
    ProcessMember();
    Exec SQL Fetch Next from sqlCrs into :dta;
  EndDo;
  Exec SQL Close sqlCrs;

End-Proc;


Dcl-Proc ProcessMember;

  // Ignore any service programs, they have specail build commands
  If %subst(dta.srcMbr:7:1) = 'V';
    Return;
  EndIf;

  // Ignore any of the BLDAPL programs
  If %subst(dta.srcMbr:1:6) = 'BLDAPL';
    Return;
  EndIf;

  // Run the proper build command
  If dta.srcTyp = 'DSPF';
    #$CMD('+
      CRTDSPF FILE('+%trim(dta.lib) + '/' + %trim(dta.srcMbr) + ') +
              SRCFILE('+%trim(dta.lib) + '/'+%trim(dta.srcFle) + ') +
              SRCMBR(' + %trim(dta.srcMbr) + ') +
              REPLACE(*YES)');
  ElseIf dta.srcTyp = 'PRTF';
    #$CMD('+
      CRTPRTF FILE('+%trim(dta.lib) + '/' + %trim(dta.srcMbr) + ') +
              SRCFILE('+%trim(dta.lib) + '/'+%trim(dta.srcFle) + ') +
              SRCMBR(' + %trim(dta.srcMbr) + ') +
              REPLACE(*YES)');
  ElseIf dta.srcTyp = 'SQLRPGLE';
    #$CMD('+
      CRTSQLRPGI OBJ('+%trim(dta.lib) + '/' + %trim(dta.srcMbr) + ') +
                 SRCFILE('+%trim(dta.lib) + '/'+%trim(dta.srcFle) + ') +
                 SRCMBR(' + %trim(dta.srcMbr) + ') +
                 OBJTYPE(*PGM) +
                 REPLACE(*YES)');
  ElseIf dta.srcTyp = 'PNLGRP';
    #$CMD('+
      CRTPNLGRP PNLGRP('+%trim(dta.lib) + '/' + %trim(dta.srcMbr) + ') +
                SRCFILE('+%trim(dta.lib) + '/'+%trim(dta.srcFle) + ') +
                SRCMBR(' + %trim(dta.srcMbr) + ') +
                REPLACE(*YES)');
  EndIf;


End-Proc;
