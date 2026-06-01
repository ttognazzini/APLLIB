**Free
Ctl-Opt Option(*SrcStmt) DftActGrp(*No) ActGrp(*Caller) Main(Main) BndDir('APLLIB');

// User Master Maintenance - Rebuild file USRMST

// ***** compile as qsecofr or change the owner
// chgobjown obj(usrmstb4) objtype(*pgm) newown(qsecofr)

/Copy QSRC,BASFNCV1PR // prototypes for all #$ procedures
/Copy QSRC,APLSRVV1PR // prototypes for $ procedures used for template programs
/Copy QSRC,USRMSTC1PR // Get User Profile Values
/Copy QSRC,PRCSCRD1PR // Display processing screen

// globals
Dcl-S usrPrf Like(APLDCT.usrPrf);

Exec SQL Set Option Commit = *none, UsrPrf = *owner, datfmt = *ISO, DynUsrPrf = *owner, CloSQLCsr = *endactgrp;

Dcl-Ds dta;
  usrSts like(APLDCT.usrSts);
  usrOqn like(APLDCT.usrOqn);
  usrOql like(APLDCT.usrOql);
  grpPrf like(APLDCT.grpPrf);
  acgCde like(APLDCT.acgCde);
  usrCls like(APLDCT.usrCls);
  usrTxt like(APLDCT.usrTxt);
End-Ds;

// Main program entry procedure
Dcl-Proc Main;
  Dcl-Pi *n ExtPgm('USRMSTB4');
    usrPrf Like(APLDCT.usrPrf) Options(*nopass);
  End-Pi;

  // Update single User
  If %parms() >= 1 and usrPrf <> '';

    Clear found;
    Exec SQL Select '1' into :found from USRMST Where usrPrf = :usrPrf;
    Exec SQL
      Select
        status,
        output_queue_name,
        coalesce(output_queue_library_name,''),
        group_profile_name,
        coalesce(accounting_code,''),
        user_class_name,
        trim(coalesce(text_description,''))
      Into :dta
      From USER_INFO
      Where authorization_name = :usrPrf;
    If SQLState < '02' and found;
      Exec SQL
        Update USRMST
        Set usrSts = :usrSts,
            usrOqn = :usrOqn,
            usrOql = :usrOql,
            grpPrf = :grpPrf,
            acgCde = :acgCde,
            usrCls = :usrCls
        Where usrPrf = :usrPrf;
    ElseIf SQLState < '02' and not found;
      Exec SQL
        Insert Into USRMST
              ( usrPrf, usrSts, usrOqn, usrOql, grpPrf, acgCde, usrCls)
        Values(:usrPrf,:usrSts,:usrOqn,:usrOql,:grpPrf,:acgCde,:usrCls);
    ElseIf found;
      Exec SQL
        Update USRMST Set usrSts = 'NoProfile'
        Where usrPrf = :usrPrf;
    EndIf;

    // Try to build first and last name from the user text, only if it is not populated
    FixName(usrPrf);

  Else;

    // Update all Users
    PRCSCRD1('Rebuilding the user index. This chould take a few minutes.');
    // Merge USRMSMT with the system user profiles
    Exec SQL
      Merge Into USRMST as M
      Using USER_INFO as S
      On M.usrPrf = S.authorization_name
      When Matched Then
        Update
          Set M.usrSts = S.status,
              M.usrOqn = S.output_queue_name,
              M.usrOql = coalesce(S.output_queue_library_name,''),
              M.grpPrf = S.group_profile_name,
              M.acgCde = coalesce(S.accounting_code,''),
              M.usrCls = S.user_class_name,
              M.usrTxt = trim(coalesce(text_description,''))
      When Not Matched Then
          Insert (usrPrf, usrSts, usrOqn, usrOql,
                  grpPrf, acgCde, usrCls,
                  usrTxt)
          Values (S.authorization_name, S.status, S.output_queue_name, coalesce(S.output_queue_library_name,''),
                  S.group_profile_name, coalesce(S.accounting_code,''), S.user_class_name,
                  trim(coalesce(S.text_description,'')));
    // change status of missing user profiles
    Exec SQL
      Update USRMST Set usrSts = 'NoProfile'
      Where usrPrf not in (Select authorization_name From USER_INFO);

    // Try to build first and last name from the user text, only if it is not populated
    FixName('');
  EndIf;


End-Proc;


Dcl-Proc FixName;
  Dcl-Pi *n;
    usrPrf Like(APLDCT.usrPrf) const;
  End-Pi;

  Dcl-Ds dta;
    selUsrPrf like(APLDCT.usrPrf);
    usrTxt like(APLDCT.usrTxt);
  End-Ds;
  Dcl-S fstNme like(APLDCT.fstNme);
  Dcl-S lstNme like(APLDCT.lstNme);

  Exec SQL Declare sqlCrs Cursor for
    Select usrPrf, usrTxt
    From USRMST
    Where usrTxt <> '' and fstNme = '' and lstNme = ''
      and usrTxt <> 'User Profile'
      and usrTxt <> 'IBM-supplied User Profile'
      and :usrPrf in (usrPrf,'');
  Exec SQL Open sqlCrs;
  Exec SQL Fetch Next From sqlCrs into :dta;
  DoW sqlState < '02';

    Clear fstNme;
    Clear lstNme;

    // if the text follow this format Fresche Solutions - fff lll, use lll for last name and fff for first name
    If %len(usrTxt) > 20 and %subst(usrTxt:1:20) = 'Fresche Solutions - ';
      fstNme = %subst(usrTxt:21:%scan(' ':usrTxt:21)-21);
      lstNme = %trim(%subst(usrTxt:%scan(' ':usrTxt:21)+1));

    ElseIf %scan(',':usrTxt) <> 0
       and %scan('-':usrTxt) <> 0
       and %scan(',':usrTxt) < %scan('-':usrTxt);
      // if the text follow this format lll, fff - xxx, use lll for last name and fff for first name
      lstNme = %subst(usrTxt:1:%scan(',':usrTxt)-1);
      fstNme = %trim(%subst(usrTxt:%scan(',':usrTxt)+1:%scan('-':usrTxt)-%scan(',':usrTxt)-1));

    ElseIf %scan(' ':usrTxt) <> 0
       and %scan('-':usrTxt) <> 0
       and %scan(' ':usrTxt) < %scan('-':usrTxt);
      // if the text follow this format lll fff - xxx, use lll for last name and fff for first name
      fstNme = %subst(usrTxt:1:%scan(' ':usrTxt)-1);
      lstNme = %trim(%subst(usrTxt:%scan(' ':usrTxt)+1:%scan('-':usrTxt)-%scan(' ':usrTxt)-1));

    ElseIf %scan(',':usrTxt) <> 0;
      // if the text follow this format lll, fff, use lll for last name and fff for first name
      lstNme = %subst(usrTxt:1:%scan(',':usrTxt)-1);
      fstNme = %trim(%subst(usrTxt:%scan(',':usrTxt)+1));

    ElseIf %scan(' ':usrTxt) <> 0;
      // if there is a blank use the first word for the first name and the rest for the last name
      fstNme = %trim(%subst(usrTxt:1:%scan(' ':usrTxt)-1));
      lstNme = %subst(usrTxt:%scan(' ':usrTxt)+1);

    Else;
      // otherwise use the whole thing as the first name
      fstNme = %trim(usrTxt);

    EndIf;

    // If names were built update the file
    If fstNme <> '' or lstNme <> '';
      Exec SQL Update USRMST set (fstNme,lstNme) = (:fstNme,:lstNme) Where usrPrf = :selUsrPrf;
    EndIf;

    Exec SQL Fetch Next From sqlCrs into :dta;
  EndDo;
  Exec SQL Close sqlCrs;

End-Proc;
