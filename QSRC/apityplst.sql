-- APLLIB.API_FLDTYP_LIST - active field types with their validation rules.
-- POST /api/field-types/list  (no input)
-- Drives the type combobox and the live length/scale/allocation
-- validation in the field form. forceLengths lists the only lengths
-- permitted when forceLength is true (zero entries are unused slots).

CREATE OR REPLACE PROCEDURE APLLIB.API_FLDTYP_LIST (
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
                'fieldType'         VALUE TRIM(FLDTYP),
                'description'       VALUE TRIM(DES),
                'isNumeric'         VALUE CASE WHEN TRIM(NMR) = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'allowDecimals'     VALUE CASE WHEN ALWDEC = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'allowLength'       VALUE CASE WHEN ALWLEN = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'requireLength'     VALUE CASE WHEN REQLEN = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'allowAllocation'   VALUE CASE WHEN ALWALC = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'requireAllocation' VALUE CASE WHEN REQALC = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'maxLength'         VALUE MAXLEN,
                'forceLength'       VALUE CASE WHEN FRCLEN = 'Y'
                                         THEN 'true' ELSE 'false' END
                                         FORMAT JSON,
                'forceLengths'      VALUE JSON_ARRAY(FRCLEN1, FRCLEN2,
                                         FRCLEN3, FRCLEN4, FRCLEN5)
                                         FORMAT JSON,
                'typeDefault'       VALUE TRIM(DFTVAL))
              ORDER BY FLDTYP
              RETURNING CLOB(1M)), '[]')
       FROM APLLIB.FLDTYP
      WHERE ACVROW = '1');
END;
