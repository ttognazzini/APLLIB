-- APLLIB.API_ROUTE_REGISTRY (system name APIRTE) - API routing table for the CGI
-- dispatcher (APIDSP). One row per endpoint: URL path -> stored procedure.
-- This table is the ALLOWLIST: a path not in it (or with ACVROW='0')
-- returns HTTP 404 and no SQL ever runs (RULES.md S5/S7).
--
-- Follows the APLLIB table conventions (see DCTSEG): active_row first,
-- <file>IDN identity second, audit columns populated by the file system's
-- trigger program. If the standard tooling normally generates the table
-- and trigger, prefer regenerating it there - the dispatcher only reads
-- PTHNME, PRCNME, ACVROW.

CREATE OR REPLACE TABLE APLLIB.API_ROUTE_REGISTRY FOR SYSTEM NAME APIRTE (
  active_row             FOR COLUMN ACVROW    CHAR(1)      NOT NULL DEFAULT '1',
  api_route_id           FOR COLUMN APIRTEIDN BIGINT       NOT NULL
                           GENERATED ALWAYS AS IDENTITY
                           (START WITH 1 INCREMENT BY 1),
  path_name              FOR COLUMN PTHNME    VARCHAR(64)  NOT NULL,
  procedure_name         FOR COLUMN PRCNME    VARCHAR(140) NOT NULL,
  create_time_stamp      FOR COLUMN CRTDTM    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  create_user            FOR COLUMN CRTUSR    CHAR(18)     NOT NULL DEFAULT USER,
  create_job             FOR COLUMN CRTJOB    CHAR(28)     NOT NULL WITH DEFAULT,
  create_program         FOR COLUMN CRTPGM    CHAR(10)     NOT NULL WITH DEFAULT,
  maintenance_time_stamp FOR COLUMN MNTDTM    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  maintenance_user       FOR COLUMN MNTUSR    CHAR(18)     NOT NULL DEFAULT USER,
  maintenance_job        FOR COLUMN MNTJOB    CHAR(28)     NOT NULL WITH DEFAULT,
  maintenance_program    FOR COLUMN MNTPGM    CHAR(10)     NOT NULL WITH DEFAULT,
  PRIMARY KEY (PTHNME)
) ON REPLACE PRESERVE ALL ROWS;

-- Endpoints. MERGE so the script is rerunnable against a table that
-- already has rows: missing paths are added, and existing paths get
-- their procedure name synced to this source (covers procedure
-- renames). ACVROW is deliberately not touched - deactivate an endpoint
-- by setting ACVROW='0' and this script will not reactivate it.
MERGE INTO APLLIB.API_ROUTE_REGISTRY T
USING (VALUES
  ('/signon',                        'APLLIB.API_SIGNON'),
  ('/segments/list',                 'APLLIB.API_SEG_LIST'),
  ('/segments/add',                  'APLLIB.API_SEG_ADD'),
  ('/segments/update',               'APLLIB.API_SEG_UPDATE'),
  ('/segments/set-status',           'APLLIB.API_SEG_SET_STATUS'),
  ('/dictionaries/list',             'APLLIB.API_DCT_LIST'),
  ('/dictionaries/add',              'APLLIB.API_DCT_ADD'),
  ('/dictionaries/update',           'APLLIB.API_DCT_UPDATE'),
  ('/dictionaries/set-status',       'APLLIB.API_DCT_SET_STATUS'),
  ('/dictionaries/fields/list',      'APLLIB.API_FLD_LIST'),
  ('/dictionaries/fields/add',       'APLLIB.API_FLD_ADD'),
  ('/dictionaries/fields/update',    'APLLIB.API_FLD_UPDATE'),
  ('/dictionaries/fields/set-status','APLLIB.API_FLD_SET_STATUS'),
  ('/field-types/list',              'APLLIB.API_FLDTYP_LIST'),
  ('/dictionaries/values/list',      'APLLIB.API_VAL_LIST'),
  ('/dictionaries/values/add',       'APLLIB.API_VAL_ADD'),
  ('/dictionaries/values/update',    'APLLIB.API_VAL_UPDATE'),
  ('/dictionaries/values/set-status','APLLIB.API_VAL_SET_STATUS')
) AS S (PTHNME, PRCNME)
ON T.PTHNME = S.PTHNME
WHEN MATCHED AND T.PRCNME <> S.PRCNME THEN
  UPDATE SET PRCNME = S.PRCNME
WHEN NOT MATCHED THEN
  INSERT (path_name, procedure_name) VALUES (S.PTHNME, S.PRCNME);
