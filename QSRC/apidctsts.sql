-- APLLIB.API_DCT_SET_STATUS - deactivate/reactivate a dictionary.
-- POST /api/dictionaries/set-status
-- Body: { "dictionary", "active": true|false }

CREATE OR REPLACE PROCEDURE APLLIB.API_DCT_SET_STATUS (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  MODIFIES SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_DCT  VARCHAR(20);
  DECLARE V_ACT  CHAR(1);
  DECLARE V_ROWS INTEGER;

  SET V_DCT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.dictionary'), '')));
  SET V_ACT = CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.active'), 'false')
                        IN ('true', '1') THEN '1' ELSE '0' END;

  UPDATE APLLIB.DCTMST
     SET ACVROW = V_ACT
   WHERE DCTNME = V_DCT;

  GET DIAGNOSTICS V_ROWS = ROW_COUNT;
  IF V_ROWS = 0 THEN
    SIGNAL SQLSTATE '75004'
      SET MESSAGE_TEXT = 'Dictionary not found';
  END IF;

  SET RESPONSE = '{"ok":true}';
END;
