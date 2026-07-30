-- APLLIB.API_SEG_SET_STATUS - deactivate/reactivate (never delete).
-- POST /api/segments/set-status
-- Body: { "segment": "TST", "active": true|false }

CREATE OR REPLACE PROCEDURE APLLIB.API_SEG_SET_STATUS (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  MODIFIES SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_SEGMENT VARCHAR(10);
  DECLARE V_ACTIVE  CHAR(1);
  DECLARE V_ROWS    INTEGER;

  SET V_SEGMENT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.segment'), '')));
  SET V_ACTIVE  = CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.active'),
                                     'false') IN ('true', '1')
                       THEN '1' ELSE '0' END;

  UPDATE APLLIB.DCTSEG
     SET ACVROW = V_ACTIVE
   WHERE DTASEG = V_SEGMENT;

  -- SQLCODE isn't usable as a variable in a SQL procedure (SQL0312);
  -- GET DIAGNOSTICS is the supported way to check the row count.
  GET DIAGNOSTICS V_ROWS = ROW_COUNT;
  IF V_ROWS = 0 THEN
    SIGNAL SQLSTATE '75004'
      SET MESSAGE_TEXT = 'Segment not found';
  END IF;

  SET RESPONSE = '{"ok":true}';
END;
