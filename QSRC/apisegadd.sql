-- APLLIB.API_SEG_ADD - create a segment (CGI-dispatcher shape).
-- POST /api/segments/add
-- Body: { "segment", "description", "columnText", "columnHeading",
--         "conflict": true|false, "note" }
-- The UI defaults blank columnText/columnHeading to the description, but
-- the procedure enforces the same rule (RULES.md S7).

CREATE OR REPLACE PROCEDURE APLLIB.API_SEG_ADD (
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

  SET V_SEGMENT  = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.segment'), '')));
  SET V_DES      = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.description'), ''));
  SET V_COLTXT   = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnText'), ''));
  SET V_COLHDG   = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnHeading'), ''));
  SET V_NOTE     = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.note'), ''));
  SET V_CONFLICT = CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.conflict'),
                                      'false') IN ('true', '1')
                        THEN '1' ELSE '0' END;

  IF V_SEGMENT = '' OR LENGTH(V_SEGMENT) > 3 THEN
    SIGNAL SQLSTATE '75001'
      SET MESSAGE_TEXT = 'Segment must be 1 to 3 characters';
  END IF;

  IF V_DES = '' THEN
    SIGNAL SQLSTATE '75002'
      SET MESSAGE_TEXT = 'Description is required';
  END IF;

  IF EXISTS (SELECT 1 FROM APLLIB.DCTSEG WHERE DTASEG = V_SEGMENT) THEN
    SIGNAL SQLSTATE '75003'
      SET MESSAGE_TEXT = 'Segment already exists';
  END IF;

  -- Audit columns and DCTSEGIDN are trigger-populated; ACVROW defaults '1'.
  INSERT INTO APLLIB.DCTSEG
         (DTASEG, DES, COLTXT, COLHDGSEG, CNFEXS, NTE)
  VALUES (V_SEGMENT,
          V_DES,
          CASE WHEN V_COLTXT = '' THEN V_DES ELSE V_COLTXT END,
          CASE WHEN V_COLHDG = '' THEN LEFT(V_DES, 20) ELSE V_COLHDG END,
          V_CONFLICT,
          V_NOTE);

  SET RESPONSE = '{"ok":true}';
END;
