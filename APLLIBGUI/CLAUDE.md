# APLLIBGUI — Claude Code Session Notes

This is the browser GUI front end for APLLIB (IBM i application-development
tools), starting with the data dictionary system. Architecture and setup are
in **README.md**.

## Rule zero

**Read [RULES.md](RULES.md) before adding or changing anything, and verify
every change against it — especially the security rules (S1–S10).** If a
requested change conflicts with RULES.md, stop and raise the conflict
instead of implementing it.

Quick orientation:

- All IBM i access goes through SQL stored procedures via
  `src/api/client.ts`, always as the signed-on user (never a service
  account). The back end is one RPG CGI dispatcher behind Apache — see
  BACKEND.md, including the project's IBM i naming conventions. The IBM i
  sources live in the parent repo's `QSRC/` folder (mirroring APLLIB/QSRC
  on the system), NOT in this folder. Toggle `MOCK` in client.ts to work
  without a back-end connection.
- Credentials live in JS memory only — never any browser storage, ever.
- New screens: route (`src/router/index.ts`) + menu entry
  (`src/navigation.ts`) + the standard shell renders header/sidebar
  automatically. Don't hand-build page chrome.
- Verify with `npm run build` and `npm run lint`.
