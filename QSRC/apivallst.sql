-- APLLIB.API_VAL_LIST - enumerated values for one dictionary field (DCTVAL).
-- POST /api/dictionaries/values/list   Body: { "dictionary", "field" }

CREATE OR REPLACE PROCEDURE APLLIB.API_VAL_LIST (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  READS SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_DCT VARCHAR(20);
  DECLARE V_FLD VARCHAR(20);

  SET V_DCT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.dictionary'), '')));
  SET V_FLD = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.field'), '')));

  SET RESPONSE =
    (SELECT COALESCE(JSON_ARRAYAGG(
              JSON_OBJECT(
                'value'       VALUE TRIM(ENMVAL),
                'description' VALUE TRIM(ENMDES),
                'active'      VALUE CASE ACVROW WHEN '1' THEN 'true'
                                    ELSE 'false' END FORMAT JSON)
              ORDER BY ENMVAL
              RETURNING CLOB(1M)), '[]')
       FROM APLLIB.DCTVAL
      WHERE DCTNME = V_DCT AND FLDNME = V_FLD);
END;
