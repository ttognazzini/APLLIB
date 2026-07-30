-- APLLIB.API_VAL_ADD - add an enumerated value (DCTVAL).
-- POST /api/dictionaries/values/add
-- Body: { "dictionary", "field", "value", "description" }
-- Values are stored as typed (not uppercased) - codes like 'y'/'Y' may
-- be case-significant in the data they describe.

CREATE OR REPLACE PROCEDURE APLLIB.API_VAL_ADD (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  MODIFIES SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_DCT VARCHAR(20);
  DECLARE V_FLD VARCHAR(20);
  DECLARE V_VAL VARCHAR(20);
  DECLARE V_DES VARCHAR(40);

  SET V_DCT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.dictionary'), '')));
  SET V_FLD = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.field'), '')));
  SET V_VAL = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.value'), ''));
  SET V_DES = TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.description'), ''));

  IF NOT EXISTS (SELECT 1 FROM APLLIB.DCTFLD
                  WHERE DCTNME = V_DCT AND FLDNME = V_FLD) THEN
    SIGNAL SQLSTATE '75004'
      SET MESSAGE_TEXT = 'Field not found';
  END IF;

  IF V_VAL = '' OR LENGTH(V_VAL) > 10 THEN
    SIGNAL SQLSTATE '75001'
      SET MESSAGE_TEXT = 'Value must be 1 to 10 characters';
  END IF;

  IF V_DES = '' THEN
    SIGNAL SQLSTATE '75002'
      SET MESSAGE_TEXT = 'Description is required';
  END IF;

  IF EXISTS (SELECT 1 FROM APLLIB.DCTVAL
              WHERE DCTNME = V_DCT AND FLDNME = V_FLD
                AND ENMVAL = V_VAL) THEN
    SIGNAL SQLSTATE '75003'
      SET MESSAGE_TEXT = 'Value already exists for this field';
  END IF;

  INSERT INTO APLLIB.DCTVAL (DCTNME, FLDNME, ENMVAL, ENMDES)
  VALUES (V_DCT, V_FLD, V_VAL, V_DES);

  SET RESPONSE = '{"ok":true}';
END;
