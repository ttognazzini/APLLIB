# APLLIBGUI Rules

**Consult this document before adding or changing ANYTHING in this project.**
Every change must comply with every rule here. If a requested change would
violate a rule, stop and resolve the conflict with the project owner first —
do not code around it. Rules are numbered so reviews can cite them (e.g.
"violates S3").

---

## Security rules

- **S1 — Authentication happens on the IBM i, nowhere else.**
  Users sign on with their IBM i user profile and password, verified by the
  IBM i itself (the HTTP server's Basic authentication against the profile).
  The site has no user table, no app-local accounts, no password of its own.

- **S2 — Sign-on requires \*CHANGE authority to the APLLIB library.**
  The sign-on procedure (`/api/signon`) checks the authenticated caller's
  authority to APLLIB and returns `{ "authorized": false }` if it is less
  than \*CHANGE. The front end must deny the sign-on and say why. The check
  is enforced on the server — the UI message is a courtesy, never the
  security boundary.

- **S3 — Every call to the IBM i runs as the signed-on user.**
  All requests carry the signed-on profile's credentials (HTTP Basic auth).
  Never a service account, never a shared or embedded profile, never a
  cached "system" connection. The web server must be configured to run
  API requests under the **authenticated caller's identity** (Apache
  `UserID %%CLIENT%%` — never a fixed profile) so object authority is
  enforced by the operating system on every single call.

- **S4 — Credentials live in memory only.**
  The profile and password are held in JavaScript memory inside
  `src/api/client.ts` and nowhere else: never localStorage, sessionStorage,
  IndexedDB, cookies, URLs, or log output. A browser refresh therefore
  requires a new sign-on — that is intended. If persisting the password
  ever becomes a requirement, it must be **encrypted** (Web Crypto,
  non-extractable key) and the design must be reviewed against this
  document first; plaintext persistence is never acceptable.

- **S5 — SQL stored procedures are the only interface to data and logic.**
  The front end never composes SQL, never calls any endpoint other than the
  `/api/*` stored-procedure endpoints, and makes every call through
  `callProcedure()` in `src/api/client.ts`. No second HTTP client, no
  direct fetches from views or stores.

- **S6 — TLS in production.**
  Basic auth sends credentials base64-encoded, not encrypted; production
  traffic must be HTTPS end-to-end to the HTTP server. Plain HTTP is
  acceptable only on localhost during development.

- **S7 — The server is the enforcement point.**
  Client-side checks (route guards, disabled buttons, hidden menu items)
  are UX only. Anything security-relevant must also be enforced by the
  IBM i: profile authentication, object authority, and validation inside
  the stored procedures themselves.

- **S8 — No secrets in the repository.**
  No passwords, profiles' credentials, API keys, or certificates are ever
  committed. Host names and ports of internal systems are acceptable.

- **S9 — Keep the dependency surface minimal.**
  Adding an npm package requires a reason the standard library or ~50 lines
  of our own code can't cover. Every dependency is supply-chain exposure on
  a system that talks to the ERP.

- **S10 — Auth failures stay vague; other errors stay honest.**
  A failed sign-on says "Invalid user profile or password" — never which of
  the two was wrong, and never whether a profile exists. All other errors
  should be specific enough to act on but must never echo credentials.

## UI rules

- **U1 — Every signed-on page renders inside the standard shell:** the
  collapsible left sidebar plus the standard header showing the signed-on
  user name and a Sign off button. Only routes marked `meta.public` (the
  sign-on page) may render bare. New pages must not build their own shell,
  header, or sign-off.

- **U2 — Adding a screen follows the standard recipe:** route in
  `src/router/index.ts` (with `meta.title` — the header displays it), menu
  entry in `src/navigation.ts`, icon in `AppIcon.vue` if needed. Point new
  routes at `PlaceholderView` until the real screen exists. A page that
  needs an explainer adds `meta.help` ({ title, paragraphs }) — the standard
  header then shows an ⓘ icon to the left of the page title that opens the
  explainer modal. Don't build one-off info buttons or modals inside pages.

- **U3 — IBM i terminology in the UI:** "user profile", "sign on",
  "sign off" — matching what users know from the green screen.

- **U4 — Standard list behavior.** Every list screen uses the shared
  `DataGrid` component (`src/components/DataGrid.vue`) — never a hand-rolled
  table. It provides, uniformly:
  - a generic search box that filters across all columns;
  - click-to-sort column headers, toggling ascending/descending;
  - Excel-style column filters: a funnel button on each header opens a
    menu with Sort A to Z / Z to A, a condition filter matched to the
    column's declared `type` (text: contains/begins with/equals…;
    number: =, >, <, between…; date: on/before/after/between with date
    pickers), a search box (Enter applies the matching values as the
    filter), and a checklist of that column's distinct values (Select-all
    and "(Blanks)"), cascaded so each list reflects the other columns'
    filters; a condition and a checklist are alternatives per column;
    active funnels highlight, and a "Clear filters" button appears in the
    toolbar while any filter is set;
  - pagination: 15 rows per page by default, a rows-per-page selector
    (15 / 25 / 50 / All), First/Prev/Next/Last controls, and a footer
    reading "Page X of Y. Filtered N rows from M rows available." —
    pages that pre-filter rows (e.g. a Show-inactive toggle) pass
    `totalRows` so M reflects the full dataset;
  - an Export button offering Excel (.xlsx) and CSV, exporting exactly the
    user's current view — search, filters, and sort applied, ALL pages
    (pagination is a viewport, not a filter) — and prompting the user to
    save the file.
  Page-specific controls (toggles, Add buttons) go in the grid's `toolbar`
  slot; per-row actions in its `actions` slot.

- **U5 — Theme-aware colors.** The site supports light and dark themes
  (auto-follows the OS setting; header button overrides, remembered in
  localStorage). All component colors come from the CSS variables in
  `src/assets/main.css` — never hardcode a hex color in a component.
  The full logo ships in two variants (`/apllib-logo.svg` dark-lettered
  for light surfaces, `/apllib-logo-dark.svg` light-lettered for dark) —
  render both `<img>`s with classes `logo-light`/`logo-dark` and let the
  `data-theme` CSS pick one; never put the logo on a hardcoded plate.

- **U6 — Prompting (the F4 pattern).** Promptable values use the shared
  `LookupField` component (`src/components/LookupField.vue`): type to
  filter (the green screen's partial-value-plus-Enter), the ▾ button or
  the **F4 key** to open the full list, arrows + Enter to select. Tiers:
  a native `<select>` only for tiny fixed sets; `LookupField` for coded
  lookups (field types, segments, …); a DataGrid-in-a-modal picker in
  select mode for large entities needing real search/drill-in. Never more
  than two modal layers; a prompt returns focus to its launching field.

- **U7 — Audit info on detail views.** Update and View forms for a single
  record show the trigger-populated create/maintenance info (timestamp,
  job, program) via the shared `AuditInfo` component, mirroring the green
  screens' Created/Last lines. List procedures return these as
  preformatted `created`/`maintained` strings.

## Code rules

- **C1 — TypeScript everywhere;** `npm run build` (which type-checks) and
  `npm run lint` must pass before a change is done.
- **C2 — One API module.** New back-end interactions extend
  `src/api/client.ts`; screens import from it and never call `fetch`
  directly.
- **C3 — Stored procedures are stateless.** Each call stands alone: no
  reliance on QTEMP, session state, or a previous call's side effects, and
  all context travels as parameters. (Each HTTP request is served
  independently; there is no persistent per-user SQL session between
  calls.)
- **C4 — Mock mode must fail loudly.** While `MOCK = true` in
  `src/api/client.ts`, unimplemented calls throw; screens must never fake
  success paths that hide missing back-end work.

## Change checklist

Before considering any change complete:

1. Re-read the security rules above; confirm none is violated.
2. `npm run build` and `npm run lint` pass.
3. New screens follow U1/U2 (shell, route, menu entry, title).
4. No credential can reach storage, logs, or the repo (S4, S8).
5. README.md and this document updated if behavior or rules changed.
