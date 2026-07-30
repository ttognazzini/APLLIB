**free
// ------------------------------------------------------------------
// APIDSP  the single CGI dispatcher for all APLLIBGUI API calls.
//
// Flow (see ibmi/README.md):
//   1. PATH_INFO (e.g. /segments/add) is looked up in APLLIB.APIRTE 
//      the routing table is the ALLOWLIST; unknown paths never reach SQL.
//   2. The raw UTF-8 JSON body is passed straight through; Db2 rejects
//      malformed data at the CALL (data exceptions map to HTTP 400).
//   3. CALL <procedure>(payload, response)  every API procedure has the
//      same (IN CLOB, OUT CLOB) signature, so this program never changes
//      when endpoints are added.
//   4. RESPONSE is written back as application/json.
//   5. SIGNAL SQLSTATE '75xxx' from a procedure -> HTTP 400 with the
//      procedure's message; other SQL errors -> HTTP 500.
//
// Security: Apache runs this program AS the authenticated user
// (UserID %%CLIENT%% + PasswdFile %%SYSTEM%%  see apihttpd.conf), so
// object authority is enforced by the OS on every request.
//
// One-time setup  the QtmhXxx CGI APIs live in service program
// QHTTPSVR/QZHBCGI (IBM ships no bnddir for it); add it to the APLLIB
// default binding directory:
//   ADDBNDDIRE BNDDIR(APLLIB/APLLIB) OBJ((QHTTPSVR/QZHBCGI *SRVPGM))
//
// Source lives in APLLIB/QSRC mbr APIDSP (stream file in the repo).
// Compile:
//   CRTSQLRPGI OBJ(APLLIB/APIDSP) SRCFILE(APLLIB/QSRC) SRCMBR(APIDSP)
//              OBJTYPE(*PGM) COMMIT(*NONE) RPGPPOPT(*LVL2)
//   (or SRCSTMF('<repo>/ibmi/apidsp.sqlrpgle'))
//
// NOTES on character conversion:
//  * Apache converts CGI HEADERS between EBCDIC and the network CCSID,
//    but converts BODIES only for text/* content types  an
//    application/json body passes through raw in both directions.
//    Therefore this program owns body encoding itself: payload and
//    response are tagged CCSID 1208 (UTF-8), and small literal bodies
//    are converted in respond(). DefaultFsCCSID 37 in apihttpd.conf is
//    still required so the job has a real (non-65535) CCSID for the
//    Db2 JSON functions.
// ------------------------------------------------------------------
Ctl-Opt main(Main) dftactgrp(*no) actgrp('APLLIBAPI')
  option(*srcstmt: *nodebugio)
  bnddir('APLLIB/APLLIB');   // includes QZHBCGI (CGI APIs) and YAJL

/include yajl/qrpglesrc,yajl_h

// ---- IBM HTTP Server CGI APIs ------------------------------------
Dcl-Pr QtmhGetEnv extproc('QtmhGetEnv');
  receiver   char(512) options(*varsize);
  receiverLn int(10) const;
  returnLn   int(10);
  varName    char(64) const options(*varsize);
  varNameLn  int(10) const;
  errCode    likeds(apiErr);
End-Pr;

Dcl-Pr QtmhRdStin extproc('QtmhRdStin');
  receiver   char(65535) options(*varsize);
  receiverLn int(10) const;
  returnLn   int(10);
  errCode    likeds(apiErr);
End-Pr;

Dcl-Pr QtmhWrStout extproc('QtmhWrStout');
  data       char(65535) options(*varsize) const;
  dataLn     int(10) const;
  errCode    likeds(apiErr);
End-Pr;

Dcl-Ds apiErr qualified;
  bytesProv  int(10) inz(0);       // 0 = raise exceptions
  bytesAvail int(10) inz(0);
End-Ds;

Dcl-S CRLF char(2) inz(x'0D25');   // job-CCSID CR/LF; Apache converts

// Request/response bodies  global, as is usual for a CGI program.
// (sqltype(CLOB:n) expands to <name>_len + <name>_data subfields.)
//
// Both are tagged CCSID 1208 (UTF-8): Apache converts CGI HEADERS but
// passes application/json BODIES through untouched in both directions
// (only text/* bodies are converted). So the raw UTF-8 request body
// lands here correctly tagged, Db2 converts at the CALL boundary, and
// the response bytes we write out are already UTF-8  no server
// conversion needed or wanted.
Dcl-S payload   sqltype(CLOB:65535);
Dcl-S response  sqltype(CLOB:1000000);

Exec sql DECLARE :payload  VARIABLE CCSID 1208;
Exec sql DECLARE :response VARIABLE CCSID 1208;

// ------------------------------------------------------------------
Dcl-Proc Main;
  Monitor;
    dispatch();
  On-Error;
    respond(500: '{"error":"Unexpected server error"}');
  EndMon;
End-Proc;

// ------------------------------------------------------------------
Dcl-Proc dispatch;
  Dcl-S path      varchar(128);
  Dcl-S method    varchar(16);
  Dcl-S procName  varchar(140);
  Dcl-S callStmt  varchar(200);
  Dcl-S state     char(5);
  Dcl-S msgText   varchar(1024);
  path   = getEnvVar('PATH_INFO');
  method = getEnvVar('REQUEST_METHOD');

  If method <> 'POST';
    respond(405: '{"error":"Use POST"}');
    Return;
  EndIf;

  readBody();
  If payload_len = 0;                    // empty body = empty object.
    // payload is UTF-8-tagged, so inject UTF-8 bytes for '{}'  an
    // RPG character literal here would be EBCDIC (x'C0D0'), which SQL
    // would reject as malformed UTF-8 (SQL0191).
    payload_data = x'7B7D';
    payload_len = 2;
  EndIf;

  // Note: no JSON pre-validation here. The payload is UTF-8 and
  // yajl_buf_load_tree expects EBCDIC, so it can't check it  instead,
  // malformed bodies fail the CALL with a data exception (e.g. SQL0191)
  // which maps to HTTP 400 below. Db2 is the validator.

  // 1. Route  APIRTE (api_route_registry) is the allowlist (RULES.md S5/S7)
  Exec sql SELECT PRCNME INTO :procName
             FROM APLLIB.APIRTE
            WHERE PTHNME = :path AND ACVROW = '1';
  If sqlcode <> 0;
    respond(404: errorJson('Unknown API path: ' + path));
    Return;
  EndIf;

  // 2. Uniform contract: CALL proc(payload, response)
  callStmt = 'CALL ' + procName + '(?, ?)';
  Exec sql PREPARE CALLPROC FROM :callStmt;
  If sqlcode < 0;
    respond(500: errorJson('API route is misconfigured: ' + procName));
    Return;
  EndIf;

  Exec sql EXECUTE CALLPROC USING :payload, :response;
  If sqlcode < 0;
    Exec sql GET DIAGNOSTICS CONDITION 1
               :state = RETURNED_SQLSTATE, :msgText = MESSAGE_TEXT;
    If %subst(state:1:2) = '75';         // business error via SIGNAL
      respond(400: errorJson(msgText));
    ElseIf %subst(state:1:2) = '22';     // data exception = bad request
      respond(400: errorJson('Request body is not valid: ' + msgText));
    Else;
      respond(500: errorJson('API failure: ' + msgText));
    EndIf;
    Return;
  EndIf;

  respondBig(200: %addr(response_data): response_len);
End-Proc;

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------
Dcl-Proc getEnvVar;
  Dcl-Pi *n varchar(512);
    name varchar(64) const;
  End-Pi;
  Dcl-Ds err likeds(apiErr) inz(*likeds);
  Dcl-S buf char(512);
  Dcl-S len int(10);

  QtmhGetEnv(buf: %size(buf): len: name: %len(name): err);
  If len < 0;
    len = 0;
  EndIf;
  Return %subst(buf: 1: len);
End-Proc;

// Read the request body (CONTENT_LENGTH bytes of stdin) into `payload`
Dcl-Proc readBody;
  Dcl-Ds err likeds(apiErr) inz(*likeds);
  Dcl-S contentLen int(10);
  Dcl-S readLen int(10);

  Monitor;
    contentLen = %int(getEnvVar('CONTENT_LENGTH'));
  On-Error;
    contentLen = 0;
  EndMon;

  payload_len = 0;
  If contentLen > 0;
    If contentLen > %size(payload_data);
      contentLen = %size(payload_data);  // oversized bodies truncated;
    EndIf;                               // fails JSON validation -> 400
    QtmhRdStin(payload_data: contentLen: readLen: err);
    If readLen > 0;
      payload_len = readLen;
    EndIf;
  EndIf;
End-Proc;

Dcl-Proc respond;
  Dcl-Pi *n;
    status int(10) const;
    json   varchar(4096) const;
  End-Pi;
  Dcl-S work varchar(4096) ccsid(*utf8);

  // Local copy converts job-CCSID text to UTF-8 (the body goes out
  // unconverted by Apache  see the payload/response declarations).
  // %addr(x : *data) points straight at the data (no +2 header math).
  work = json;
  respondBig(status: %addr(work : *data): %len(work));
End-Proc;

Dcl-Proc respondBig;
  Dcl-Pi *n;
    status  int(10) const;
    dataPtr pointer const;
    dataLen int(10) const;
  End-Pi;
  Dcl-Ds err likeds(apiErr) inz(*likeds);
  Dcl-S hdr varchar(128);
  Dcl-S big char(1000000) based(dataPtr);

  hdr = 'Status: ' + %char(status) + CRLF
      + 'Content-Type: application/json; charset=utf-8' + CRLF + CRLF;
  QtmhWrStout(hdr: %len(hdr): err);
  If dataLen > 0;
    QtmhWrStout(big: dataLen: err);
  EndIf;
End-Proc;

// Build {"error":"..."} with proper escaping via the YAJL generator
Dcl-Proc errorJson;
  Dcl-Pi *n varchar(2048);
    msg varchar(1536) const;
  End-Pi;
  Dcl-S buf char(2048);
  Dcl-S len int(10);

  yajl_genOpen(*off);
  yajl_beginObj();
  yajl_addChar('error': msg);
  yajl_endObj();
  yajl_copyBuf(0: %addr(buf): %size(buf): len);   // 0 = job CCSID
  yajl_genClose();
  Return %subst(buf: 1: len);
End-Proc;

