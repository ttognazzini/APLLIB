-- APLLIB.API_SIGNON - sign-on gate (RULES.md S2), CGI-dispatcher shape.
-- Apache has already authenticated the profile (Basic auth against user
-- profiles) and the job runs AS that user (UserID %%CLIENT%%), so CHKOBJ
-- checks the CALLER's authority to the APLLIB library.
--
-- POST /api/signon  ->  {"authorized":true|false}

CREATE OR REPLACE PROCEDURE APLLIB.API_SIGNON (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    SET RESPONSE = '{"authorized":false}';

  SET RESPONSE = '{"authorized":true}';
  CALL QSYS2.QCMDEXC('CHKOBJ OBJ(QSYS/APLLIB) OBJTYPE(*LIB) AUT(*CHANGE)');
END;
