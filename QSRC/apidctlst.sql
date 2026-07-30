-- APLLIB.API_DCT_LIST - all dictionaries (DCTMST) as a JSON array.
-- POST /api/dictionaries/list  (no input)
-- created/maintained are preformatted audit strings for detail displays
-- (RULES.md U7): timestamp, job, program.

CREATE OR REPLACE PROCEDURE APLLIB.API_DCT_LIST (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  READS SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  SET RESPONSE =
    (SELECT COALESCE(JSON_ARRAYAGG(
              JSON_OBJECT(
                'dictionary'  VALUE TRIM(DCTNME),
                'description' VALUE TRIM(DES),
                'note'        VALUE TRIM(NTE),
                'active'      VALUE CASE ACVROW WHEN '1' THEN 'true'
                                    ELSE 'false' END FORMAT JSON,
                'created'     VALUE VARCHAR_FORMAT(CRTDTM,
                                    'YYYY-MM-DD HH24:MI:SS')
                                    || '  ' || TRIM(CRTJOB)
                                    || '  ' || TRIM(CRTPGM),
                'maintained'  VALUE VARCHAR_FORMAT(MNTDTM,
                                    'YYYY-MM-DD HH24:MI:SS')
                                    || '  ' || TRIM(MNTJOB)
                                    || '  ' || TRIM(MNTPGM))
              ORDER BY DCTNME
              RETURNING CLOB(1M)), '[]')
       FROM APLLIB.DCTMST);
END;
