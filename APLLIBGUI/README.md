# APLLIBGUI

Browser-based GUI front end for **APLLIB**, the library of application-development
tools on the IBM i. This project is a proof of concept. The initial goal is a GUI
front end for the **data dictionary system** (Segments, Dictionaries, Files); more
APLLIB tools are expected to land here over time.

> **Before changing anything, read [RULES.md](RULES.md).** It holds the
> security rules (S1–S10), UI standards, and the change checklist. Every
> change — human or AI-assisted — must comply with it.

## Architecture

```
Browser (this app, static files)
   │  HTTPS + Basic auth (real IBM i user profiles)
IBM HTTP Server for i (Apache) — serves the built site from the IFS;
   │                             /api/* → CGI, run AS the calling user
APLLIB/APIDSP — one RPG CGI dispatcher (routing table = allowlist)
   │
SQL stored procedures (APLLIB.API_*)  ←  the only interface to logic and data
```

**All communication with the IBM i happens through SQL stored procedure
calls**, routed by the CGI dispatcher (see [BACKEND.md](BACKEND.md)).
The front end never runs its own SQL and has no other backdoor to the
database; if a screen needs data, a stored procedure provides it.
`src/api/client.ts` is the single module that performs these calls.

## Sign-on and credentials

Users sign on with their **IBM i user profile and password**, verified on the
IBM i itself, and must hold **\*CHANGE authority to the APLLIB library** —
the sign-on stored procedure checks this and the site refuses sign-on
otherwise (contract documented in `src/api/client.ts` above `verifySignOn`).
The credentials are **the only thing the site stores**, and only in
JavaScript memory (`src/api/client.ts`) for the duration of the browser
session:

- Sent as HTTP Basic auth on every stored-procedure call, so Apache
  authenticates every request against the real user profile, runs it AS
  that user, and the operating system enforces authority.
- Never written to localStorage, sessionStorage, cookies, or the server.
- Consequence: refreshing the browser requires signing on again. This is a
  deliberate trade-off; revisit (e.g., session tokens) if it becomes a
  problem.

## Mock mode

While the back end isn't connected, `MOCK = true` in `src/api/client.ts`
makes sign-on accept any non-blank credentials (except user profile
`NOAUTH`, which simulates the missing-\*CHANGE-authority denial so that
path stays testable) and makes `callProcedure()` throw, so the UI is fully
navigable without an IBM i connection and no screen can silently pretend it
fetched real data. Once the APLLIBGUI web server answers (port 8500), set
`MOCK = false` and add the dev proxy to `vite.config.ts`:

```ts
server: {
  proxy: {
    '/api': { target: 'http://<ibm-i-host>:8500', changeOrigin: true },
  },
},
```

## Project layout

```
src/
  api/client.ts        ← ALL stored-procedure calls + credential holding
  stores/auth.ts       ← sign-on state (Pinia)
  navigation.ts        ← sidebar menu entries — add new screens here
  components/
    SideBar.vue        ← collapsible left menu
    AppHeader.vue      ← standard header (user, sign off, ⓘ page help)
    DataGrid.vue       ← standard list: search/sort/filter/export (RULES U4)
    LookupField.vue    ← standard prompt: type-to-filter + F4 list (RULES U6)
    AuditInfo.vue      ← created/maintained footer on detail forms (RULES U7)
    AppIcon.vue        ← inline SVG icons (no icon-font dependency)
  lib/
    xlsx.ts            ← minimal Excel writer for exports (uses fflate)
    download.ts        ← save-to-disk with Save As dialog + fallback
  views/
    SignOnView.vue     ← sign-on page (public)
    HomeView.vue       ← landing page
    PlaceholderView.vue← stand-in for screens not yet built
  router/index.ts      ← routes + "must be signed on" guard
```

### Adding a menu item / screen

1. Add a route in `src/router/index.ts` (point it at `PlaceholderView` until
   the real screen exists).
2. Add one entry to `src/navigation.ts`.
3. If it needs a new icon, add one `<svg v-else-if…>` block to `AppIcon.vue`.

## Developer setup

1. Install Node.js LTS: `winget install OpenJS.NodeJS.LTS --source winget`
2. **Corporate proxy:** the company network re-signs HTTPS traffic with the
   `ARROWHEADWINCH-CA` certificate, which breaks npm out of the box. Fix
   (once, then open a new terminal):

   ```
   setx NODE_USE_SYSTEM_CA 1
   ```

   Never work around this with `strict-ssl false` — that disables
   certificate verification entirely.

3. `npm install`
4. `npm run dev` → http://localhost:5173 (hot reload; sign on with any
   non-blank user/password while mock mode is on)

Other commands: `npm run build` (type-check + production build to `dist/`),
`npm run lint`, `npm run format`.

Editor: [VS Code](https://code.visualstudio.com/) with the
[Vue (Official)](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
extension.

## IBM i back end

One RPG CGI dispatcher + SQL stored procedures, installed by a single CL
program (`APLLIB/APIINS`). Sources, naming conventions, and the full
runbook live in **[BACKEND.md](BACKEND.md)**; the IBM i sources themselves
are in the parent repo's [`QSRC/`](../QSRC) folder (mirroring APLLIB/QSRC
on the system).

## Deployment (target state)

`APLLIB/APIINS` stands up the back end (database objects, dispatcher,
HTTP server instance `APLLIBGUI` on port 8500). The front end is
`npm run build`, then copy `dist/` into `/www/apllibgui/htdocs`. Site and
API share one origin, so there is no CORS anywhere.
