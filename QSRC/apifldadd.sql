-- APLLIB.API_FLD_ADD - create a dictionary field (DCTFLD).
-- POST /api/dictionaries/fields/add
-- Body: { dictionary, field, fieldSql, description, columnText,
--         heading1, heading2, heading3, type, length, scale, allocation,
--         projectNumber, promptText, allowNull, defaultValue, enumerated }
-- Validates against the FLDTYP rules (RULES.md S7 - the UI does the same
-- checks as a courtesy, the server enforces).

CREATE OR REPLACE PROCEDURE APLLIB.API_FLD_ADD (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  MODIFIES SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_DCT    VARCHAR(20);
  DECLARE V_FLD    VARCHAR(20);
  DECLARE V_TYP    VARCHAR(14);
  DECLARE V_LEN    DECIMAL(5,0);
  DECLARE V_SCL    DECIMAL(2,0);
  DECLARE V_ALC    DECIMAL(5,0);
  DECLARE V_ALWLEN CHAR(1);
  DECLARE V_REQLEN CHAR(1);
  DECLARE V_ALWDEC CHAR(1);
  DECLARE V_ALWALC CHAR(1);
  DECLARE V_REQALC CHAR(1);
  DECLARE V_MAXLEN BIGINT;

  SET V_DCT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.dictionary'), '')));
  SET V_FLD = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.field'), '')));
  SET V_TYP = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.type'), '')));
  SET V_LEN = COALESCE(JSON_VALUE(PAYLOAD, '$.length'
                                  RETURNING DECIMAL(5,0)), 0);
  SET V_SCL = COALESCE(JSON_VALUE(PAYLOAD, '$.scale'
                                  RETURNING DECIMAL(2,0)), 0);
  SET V_ALC = COALESCE(JSON_VALUE(PAYLOAD, '$.allocation'
                                  RETURNING DECIMAL(5,0)), 0);

  IF NOT EXISTS (SELECT 1 FROM APLLIB.DCTMST WHERE DCTNME = V_DCT) THEN
    SIGNAL SQLSTATE '75004'
      SET MESSAGE_TEXT = 'Dictionary not found';
  END IF;

  IF V_FLD = '' OR LENGTH(V_FLD) > 10 THEN
    SIGNAL SQLSTATE '75001'
      SET MESSAGE_TEXT = 'Field name must be 1 to 10 characters';
  END IF;

  IF TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnText'), '')) = '' THEN
    SIGNAL SQLSTATE '75002'
      SET MESSAGE_TEXT = 'Column text is required';
  END IF;

  IF EXISTS (SELECT 1 FROM APLLIB.DCTFLD
              WHERE DCTNME = V_DCT AND FLDNME = V_FLD) THEN
    SIGNAL SQLSTATE '75003'
      SET MESSAGE_TEXT = 'Field already exists in this dictionary';
  END IF;

  -- Field type must exist and be active; pull its rules for validation
  SELECT ALWLEN, REQLEN, ALWDEC, ALWALC, REQALC, MAXLEN
    INTO V_ALWLEN, V_REQLEN, V_ALWDEC, V_ALWALC, V_REQALC, V_MAXLEN
    FROM APLLIB.FLDTYP
   WHERE FLDTYP = V_TYP AND ACVROW = '1';
  IF V_ALWLEN IS NULL THEN
    SIGNAL SQLSTATE '75005'
      SET MESSAGE_TEXT = 'Unknown or inactive field type';
  END IF;

  IF V_REQLEN = 'Y' AND V_LEN = 0 THEN
    SIGNAL SQLSTATE '75006'
      SET MESSAGE_TEXT = 'Length is required for this field type';
  END IF;
  IF V_ALWLEN <> 'Y' AND V_LEN <> 0 THEN
    SIGNAL SQLSTATE '75007'
      SET MESSAGE_TEXT = 'Length is not allowed for this field type';
  END IF;
  IF V_MAXLEN > 0 AND V_LEN > V_MAXLEN THEN
    SIGNAL SQLSTATE '75008'
      SET MESSAGE_TEXT = 'Length exceeds the maximum for this field type';
  END IF;
  IF V_ALWDEC <> 'Y' AND V_SCL <> 0 THEN
    SIGNAL SQLSTATE '75009'
      SET MESSAGE_TEXT = 'Decimal positions are not allowed for this field type';
  END IF;
  IF V_SCL > V_LEN THEN
    SIGNAL SQLSTATE '75010'
      SET MESSAGE_TEXT = 'Decimal positions cannot exceed the length';
  END IF;
  IF V_ALWALC <> 'Y' AND V_ALC <> 0 THEN
    SIGNAL SQLSTATE '75011'
      SET MESSAGE_TEXT = 'Allocation is not allowed for this field type';
  END IF;
  IF V_REQALC = 'Y' AND V_ALC = 0 THEN
    SIGNAL SQLSTATE '75012'
      SET MESSAGE_TEXT = 'Allocation is required for this field type';
  END IF;

  INSERT INTO APLLIB.DCTFLD
         (DCTNME, FLDNME, FLDNMESQL, DES, COLTXT, COLHDG,
          FLDTYP, FLDLEN, FLDSCL, FLDALC, PRJNBR, FLDPMP,
          ALWNUL, DFTVAL, FLDENM)
  VALUES (V_DCT,
          V_FLD,
          TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.fieldSql'), '')),
          TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.description'), '')),
          TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.columnText'), '')),
          CAST(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.heading1'), ''))
               AS CHAR(20))
            || CAST(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.heading2'), ''))
                    AS CHAR(20))
            || CAST(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.heading3'), ''))
                    AS CHAR(20)),
          V_TYP, V_LEN, V_SCL, V_ALC,
          UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.projectNumber'), ''))),
          TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.promptText'), '')),
          CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.allowNull'), 'false')
                    IN ('true', '1') THEN 'Y' ELSE ' ' END,
          TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.defaultValue'), '')),
          CASE WHEN COALESCE(JSON_VALUE(PAYLOAD, '$.enumerated'), 'false')
                    IN ('true', '1') THEN 'Y' ELSE ' ' END);

  SET RESPONSE = '{"ok":true}';
END;
