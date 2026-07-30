-- APLLIB.API_SEG_UPDATE - update an existing segment (key cannot change).
-- POST /api/segments/update - same body as add.

CREATE OR REPLACE PROCEDURE APLLIB.API_SEG_UPDATE (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  MODIFIES SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_SEGMENT  VARCHAR(10);
  DECLARE V_DES      VARCHAR(40);
  DECLARE V_COLTXT   VARCHAR(50);
  DECLARE V_COLHDG   VARCHAR(20);
  DECLARE V_CONFLICT CHAR(1);
  DECLARE V_NOTE     VARCHAR(60);
  DECLARE V_ROWS     INTEGER;

  SET V_SEGMENT  = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.segment'), '')));
  SET V_DES      = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.description'), ''));
  SET V_COLTXT   = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnText'), ''));
  SET V_COLHDG   = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnHeading'), ''));
  SET V_NOTE     = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.note'), ''));
  SET V_CONFLICT = CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.conflict'),
                                      'false') IN ('true', '1')
                        THEN '1' ELSE '0' END;

  IF V_DES = '' THEN
    SIGNAL SQLSTATE '75002'
      SET MESSAGE_TEXT = 'Description is required';
  END IF;

  UPDATE APLLIB.DCTSEG
     SET DES       = V_DES,
         COLTXT    = CASE WHEN V_COLTXT = '' THEN V_DES ELSE V_COLTXT END,
         COLHDGSEG = CASE WHEN V_COLHDG = '' THEN LEFT(V_DES, 20)
                          ELSE V_COLHDG END,
         CNFEXS    = V_CONFLICT,
         NTE       = V_NOTE
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
