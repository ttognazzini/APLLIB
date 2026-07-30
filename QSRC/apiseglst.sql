-- APLLIB.API_SEG_LIST - all segments as a JSON array (CGI-dispatcher shape).
-- POST /api/segments/list  ->  [ { segment, description, columnText,
--                                 columnHeading, conflict, note, active }, ... ]
-- Booleans are real JSON true/false (FORMAT JSON), matching the front
-- end's Segment type exactly (src/api/segments.ts).

CREATE OR REPLACE PROCEDURE APLLIB.API_SEG_LIST (
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
                'segment'       VALUE TRIM(DTASEG),
                'description'   VALUE TRIM(DES),
                'columnText'    VALUE TRIM(COLTXT),
                'columnHeading' VALUE TRIM(COLHDGSEG),
                'conflict'      VALUE CASE CNFEXS WHEN '1' THEN 'true'
                                      ELSE 'false' END FORMAT JSON,
                'note'          VALUE TRIM(NTE),
                'active'        VALUE CASE ACVROW WHEN '1' THEN 'true'
                                      ELSE 'false' END FORMAT JSON)
              ORDER BY DTASEG
              RETURNING CLOB(1M)), '[]')
       FROM APLLIB.DCTSEG);
END;
