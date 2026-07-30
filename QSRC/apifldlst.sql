-- APLLIB.API_FLD_LIST - all fields of one dictionary (DCTFLD).
-- POST /api/dictionaries/fields/list   Body: { "dictionary" }
-- COLHDG CHAR(60) is three stacked 20-char headings - split for the UI.
-- allowNull/enumerated are 'Y'/blank flags in DCTFLD.

CREATE OR REPLACE PROCEDURE APLLIB.API_FLD_LIST (
  IN  PAYLOAD  CLOB(64K),
  OUT RESPONSE CLOB(1M)
)
  LANGUAGE SQL
  READS SQL DATA
  SET OPTION COMMIT = *NONE
BEGIN
  DECLARE V_DCT VARCHAR(20);

  SET V_DCT = UPPER(TRIM(COALESCE(JSON_VALUE(PAYLOAD, '$.dictionary'), '')));

  SET RESPONSE =
    (SELECT COALESCE(JSON_ARRAYAGG(
              JSON_OBJECT(
                'field'         VALUE TRIM(FLDNME),
                'fieldSql'      VALUE TRIM(FLDNMESQL),
                'description'   VALUE TRIM(DES),
                'columnText'    VALUE TRIM(COLTXT),
                'heading1'      VALUE TRIM(SUBSTR(COLHDG, 1, 20)),
                'heading2'      VALUE TRIM(SUBSTR(COLHDG, 21, 20)),
                'heading3'      VALUE TRIM(SUBSTR(COLHDG, 41, 20)),
                'type'          VALUE TRIM(FLDTYP),
                'length'        VALUE FLDLEN,
                'scale'         VALUE FLDSCL,
                'allocation'    VALUE FLDALC,
                'projectNumber' VALUE TRIM(PRJNBR),
                'promptText'    VALUE TRIM(FLDPMP),
                'allowNull'     VALUE CASE WHEN ALWNUL = 'Y' THEN 'true'
                                      ELSE 'false' END FORMAT JSON,
                'defaultValue'  VALUE TRIM(DFTVAL),
                'enumerated'    VALUE CASE WHEN FLDENM = 'Y' THEN 'true'
                                      ELSE 'false' END FORMAT JSON,
                'active'        VALUE CASE ACVROW WHEN '1' THEN 'true'
                                      ELSE 'false' END FORMAT JSON,
                'created'       VALUE VARCHAR_FORMAT(CRTDTM,
                                      'YYYY-MM-DD HH24:MI:SS')
                                      || '  ' || TRIM(CRTJOB)
                                      || '  ' || TRIM(CRTPGM),
                'maintained'    VALUE VARCHAR_FORMAT(MNTDTM,
                                      'YYYY-MM-DD HH24:MI:SS')
                                      || '  ' || TRIM(MNTJOB)
                                      || '  ' || TRIM(MNTPGM))
              ORDER BY FLDNME
              RETURNING CLOB(1M)), '[]')
       FROM APLLIB.DCTFLD
      WHERE DCTNME = V_DCT);
END;
