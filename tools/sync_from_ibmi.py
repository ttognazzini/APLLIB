"""Refresh the repo's QSRC folder from the IBM i, which holds the master copy of the source.

Every member of APLLIB/QSRC on the IBM i is written to QSRC/<member>.<source type> (lower case),
in arrival order with trailing blanks trimmed and CRLF line ends. A member whose source type changed
has its old file removed, so git sees a rename. Files with no member on the IBM i are listed, and
deleted only with --prune. The report at the end names every member that changed.

Connects with Kerberos single sign-on as the person running it; nothing is stored. Needs pyodbc and
the IBM i Access ODBC Driver.

    python tools/sync_from_ibmi.py                     # WINCH400 -> QSRC, report only what changed
    python tools/sync_from_ibmi.py --commit            # ...and commit the changes to the current branch
    python tools/sync_from_ibmi.py --commit --push     # ...and push that branch
    python tools/sync_from_ibmi.py --system winchtst.arrowheadwinch.com --dry-run
"""
import argparse
import subprocess
import sys
from pathlib import Path

import pyodbc

REPO = Path(__file__).resolve().parent.parent


def connect(system):
    return pyodbc.connect("Driver={IBM i Access ODBC Driver};"
                          f"System={system};SSO=1;SIGNON=4;PROMPT=0;CCSID=1208;",
                          timeout=30, autocommit=True)


def members(cur, lib, srcf):
    cur.execute("select table_partition, coalesce(source_type, ''), last_source_update_timestamp "
                "from qsys2.syspartitionstat where table_schema = ? and table_name = ? "
                "order by table_partition", (lib, srcf))
    return [(r[0].strip(), r[1].strip(), r[2]) for r in cur.fetchall()]


SUB = "\x1a"  # what the IBM i stores for a character its CCSID cannot hold (an em dash, an ellipsis)


def clean(line):
    """SEU display attributes (EBCDIC x'20'-x'3F', arriving as control characters) become a blank,
    so every column stays where it was."""
    return "".join(" " if (ord(ch) < 32 and ch not in "\t" + SUB) or 0x7F <= ord(ch) < 0xA0 or ch == "�"
                   else ch for ch in line).rstrip()


def restore(line, old_lines):
    """A line holding SUB takes the repo's characters at those positions, when the repo has the same
    line otherwise unchanged; the IBM i never had them to give back."""
    if SUB not in line:
        return line, 0
    for old in old_lines:
        if len(old) == len(line) and all(a == b or a == SUB for a, b in zip(line, old)):
            return old, 0
    return line, line.count(SUB)


def member_text(cur, lib, srcf, mbr, old_text):
    cur.execute(f'create or replace alias qtemp.syncsrc for "{lib}"."{srcf}"("{mbr}")')
    cur.execute("select s.srcdta from qtemp.syncsrc s order by rrn(s)")
    old_lines = old_text.splitlines() if old_text else []
    lines, lost = [], 0
    for (srcdta,) in cur.fetchall():
        line, n = restore(clean(srcdta or ""), old_lines)
        lines.append(line)
        lost += n
    return "".join(line + "\r\n" for line in lines), lost


def git(*args):
    return subprocess.run(["git", "-C", str(REPO), *args], check=True, capture_output=True, text=True).stdout


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--system", default="winch400.arrowheadwinch.com")
    ap.add_argument("--lib", default="APLLIB")
    ap.add_argument("--srcf", default="QSRC")
    ap.add_argument("--dry-run", action="store_true", help="report what would change, write nothing")
    ap.add_argument("--prune", action="store_true", help="delete repo files with no member on the IBM i")
    ap.add_argument("--commit", action="store_true", help="commit the changes to the current branch")
    ap.add_argument("--push", action="store_true", help="push the current branch after committing")
    a = ap.parse_args()

    folder = REPO / a.srcf
    existing = {}
    for f in folder.iterdir():
        if f.is_file():
            existing.setdefault(f.stem.upper(), []).append(f)

    cur = connect(a.system).cursor()
    mbrs = members(cur, a.lib, a.srcf)
    if not mbrs:
        sys.exit(f"No members found in {a.lib}/{a.srcf} on {a.system}.")

    added, changed, renamed, unknown = [], [], [], []
    for mbr, typ, _ in mbrs:
        target = folder / f"{mbr.lower()}.{(typ or 'txt').lower()}"
        old = existing.pop(mbr, [])
        old_text = "".join(f.read_bytes().decode("utf-8", "replace") for f in old)
        text, lost = member_text(cur, a.lib, a.srcf, mbr, old_text)
        if lost:
            unknown.append(f"{target.name} ({lost})")
        for f in old:
            if f.name != target.name:
                renamed.append(f"{f.name} -> {target.name}")
                if not a.dry_run:
                    f.unlink()
        current = target.read_bytes().decode("utf-8", "replace") if target.exists() else None
        if current == text:
            continue
        (added if current is None and not old else changed).append(target.name)
        if not a.dry_run:
            target.write_bytes(text.encode("utf-8"))

    orphans = sorted(f.name for fs in existing.values() for f in fs)
    if a.prune and not a.dry_run:
        for fs in existing.values():
            for f in fs:
                f.unlink()

    print(f"{a.system} {a.lib}/{a.srcf}: {len(mbrs)} members")
    print(f"changed {len(changed)}, added {len(added)}, type renamed {len(renamed)}, "
          f"no member on the IBM i {len(orphans)}{' (deleted)' if a.prune else ''}")
    for title, names in (("changed", changed), ("added", added), ("renamed", renamed),
                         ("no member on the IBM i", orphans),
                         ("characters the IBM i could not hold and the repo had no copy of", unknown)):
        for n in names:
            print(f"  {title}: {n}")

    if a.commit and not a.dry_run and (changed or added or renamed or (a.prune and orphans)):
        git("add", "--all", a.srcf)
        body = "\n".join(changed + added + renamed)
        git("commit", "-m", f"Refresh {a.srcf} from {a.lib} on {a.system.split('.')[0].upper()}\n\n{body}")
        print("committed")
        if a.push:
            git("push", "--set-upstream", "origin", git("branch", "--show-current").strip())
            print("pushed")


if __name__ == "__main__":
    main()
