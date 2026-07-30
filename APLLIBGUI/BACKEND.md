# APLLIBGUI back end — one CGI dispatcher + SQL stored procedures

How the API behind the web GUI works and how it is deployed. All IBM i
source lives in **`APLLIB/QSRC`** on the system, mirrored in this repo's
[`QSRC/`](../QSRC) folder (member name = file name).

A single RPG CGI program behind Apache serves the whole API. Chosen for
its **minimal install footprint on systems we don't control**: no Java
app server, no wizards, no PTF-sensitive tooling — just objects in APLLIB
plus two IFS artifacts. (An IWS-based approach was prototyped first and
abandoned: its scripted deployment depends on current HTTP group PTFs,
which target shops often don't have.)

```
Browser
  │ HTTPS + Basic auth (validated against IBM i user profiles)
Apache (5770-DG1)                    ← config is plain IFS files
  │ /            static site (dist/) from the IFS
  │ /api/*       ScriptAlias → APLLIB/APIDSP, run as the CALLING user
APIDSP (one RPG CGI program)         ← never changes per endpoint
  │ routing table APLLIB.APIRTE      ← allowlist: path → procedure
CALL APLLIB.API_xxx(payload, response)   ← SQL stored procedures
```

## Conventions for the API sources in QSRC

- **Programs (RPG + CL):** names start with **`API`** (`APIDSP`, `APIINS`).
- **SQL stored procedures:** prefixed **`API_`** (`API_SIGNON`,
  `API_SEG_LIST`, ...); source members prefixed `api`.
- **Member names** are ≤10 characters, no underscores (file name = member
  name).
- **7-bit ASCII only** in every source: no em dashes, arrows, ellipses,
  or curly quotes — they don't convert to EBCDIC. Use `-`, `->`, `...`,
  and straight quotes.
- **Tables:** APLLIB standards — long SQL name (>10 chars) with
  `FOR SYSTEM NAME`, `active_row`/ACVROW first, `<sysname>IDN` identity
  second, trigger-populated audit columns (`api_route_registry` /
  `APIRTE`).

## Why each request runs as the signed-on user

`apihttp.conf` protects `/api` with:

```
AuthType Basic
PasswdFile %%SYSTEM%%     <- validate against real IBM i user profiles
UserID %%CLIENT%%         <- run the CGI job AS the authenticated user
```

`UserID %%CLIENT%%` has been in the IBM HTTP Server for ~20 years: object
authority is enforced by the OS on every call (RULES.md S1/S3). A wrong
password gets HTTP 401 from Apache before any program runs.

## The uniform procedure contract

Every API procedure has the same signature:

```sql
CREATE PROCEDURE APLLIB.API_xxx (IN PAYLOAD CLOB(64K), OUT RESPONSE CLOB(1M))
```

- PAYLOAD = the raw JSON request body (UTF-8). Extract fields with
  `JSON_VALUE(PAYLOAD, '$.field')`.
- RESPONSE = the JSON to send back, built with `JSON_OBJECT` /
  `JSON_ARRAYAGG` (real JSON booleans via `FORMAT JSON`).
- Business errors: `SIGNAL SQLSTATE '75xxx' SET MESSAGE_TEXT = '...'`.
  The dispatcher maps SQLSTATE 75xxx → HTTP 400 with
  `{"error":"<message>"}`; data exceptions (22xxx) → 400; anything else
  → HTTP 500.

Because the signature never varies, the dispatcher calls every procedure
with the same static two-marker statement — no SQLDA, no descriptors, no
per-endpoint code. **Adding an endpoint = one procedure + one row in
`APLLIB.API_ROUTE_REGISTRY`** (see `QSRC/apirte.sql`, a rerunnable MERGE).
The dispatcher is never touched again.

## Components (QSRC members)

| Member | Object | What it is |
|---|---|---|
| `apidsp.sqlrpgle` | `APLLIB/APIDSP` *PGM | The CGI dispatcher |
| `apiins.clle` | `APLLIB/APIINS` *PGM | Installer: IFS layout, config copy, HTTP instance registration, server start |
| `apihttp.conf` | `/www/apllibgui/conf/httpd.conf` | Apache instance config (copied by APIINS via CPYTOSTMF) |
| `apisrv.text` | `QUSRSYS/QATMHINSTC(APLLIBGUI)` | HTTP instance startup line (copied by APIINS via CPYF) |
| `apirte.sql` | `APLLIB.API_ROUTE_REGISTRY` (`APIRTE`) | Routing/allowlist table + rerunnable MERGE of all endpoints |
| `apisignon.sql` | `APLLIB.API_SIGNON` | Sign-on gate: caller has *CHANGE to APLLIB? |
| `apiseg*.sql` | `APLLIB.API_SEG_*` | Segments: list / add / update / set-status |
| `apidct*.sql` | `APLLIB.API_DCT_*` | Dictionaries: list / add / update / set-status |
| `apifld*.sql` | `APLLIB.API_FLD_*` | Dictionary fields: list / add / update / set-status |
| `apityplst.sql` | `APLLIB.API_FLDTYP_LIST` | Field types + validation rules |
| `apival*.sql` | `APLLIB.API_VAL_*` | Enumerated values: list / add / update / set-status |

## Install / deploy

1. RUNSQLSTM the `api*.sql` members (procedures are CREATE OR REPLACE;
   `apirte.sql` is a MERGE — all rerunnable).
2. Compile `APIDSP` (`CRTSQLRPGI ... SRCFILE(APLLIB/QSRC) SRCMBR(APIDSP)`)
   and `APIINS` (`CRTBNDCL ... SRCMBR(APIINS)`). One-time prerequisite:
   `ADDBNDDIRE BNDDIR(APLLIB/APLLIB) OBJ((QHTTPSVR/QZHBCGI *SRVPGM))`.
3. `CALL APLLIB/APIINS` — creates `/www/apllibgui`, copies the config,
   registers HTTP instance `APLLIBGUI` (port 8500, -AutoStartY), starts it.
4. Front end: `npm run build` in `APLLIBGUI/`, copy `dist/` contents into
   `/www/apllibgui/htdocs`.

## Dependency and CCSID notes (hard-won)

- Apache + CGI + `%%CLIENT%%`: decades old, effectively PTF-immune.
- YAJL: already in the APLLIB binding directory (used by the dispatcher
  for building error JSON).
- `JSON_VALUE` / `JSON_OBJECT` / `JSON_ARRAYAGG` in Db2: base in 7.4+,
  7.3 via TR. Probe: `SELECT JSON_OBJECT('a' VALUE 1) FROM
  SYSIBM.SYSDUMMY1`.
- **CCSID:** the JSON functions emit UTF-8 (1208) and cannot convert
  to/from CCSID 65535 (*HEX). `DefaultFsCCSID 37` in `apihttp.conf` pins
  the server/CGI jobs to a real CCSID regardless of QCCSID. For 5250
  testing run `CHGJOB CCSID(37)` first.
- Apache converts CGI **headers** between EBCDIC and the network CCSID,
  but converts **bodies** only for text/* content types — an
  application/json body passes through raw in both directions. The
  dispatcher therefore owns body encoding itself: its payload/response
  CLOBs are tagged CCSID 1208 (`DECLARE :var VARIABLE CCSID 1208`).
- The CGI jobs need a library list: `SetEnv QIBM_CGI_LIBRARY_LIST` in the
  config (QTMHHTTP's default *LIBL has no APLLIB; *LIBL-qualified
  service-program references fail at activation with MCH3401 without it).

## Smoke test

```
curl -u PROFILE -X POST http://<system>:8500/api/signon -H "Content-Type: application/json" -d "{}"
curl -u PROFILE -X POST http://<system>:8500/api/segments/list -H "Content-Type: application/json" -d "{}"
```

Expected: `{"authorized":true}` / a JSON array of segments; wrong password
→ 401 from Apache; unknown path → 404 `{"error":"Unknown API path..."}`.
