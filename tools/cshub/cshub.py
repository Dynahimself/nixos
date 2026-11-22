#!/usr/bin/env python3
"""
cshub — Dyna's offline-first CLI & sync engine for Pi CS Student Hub (:8200).

Half-dependent on Tailscale:
  * Every read/write hits the local SQLite cache (~/.local/share/cshub/cache.db) first.
  * Works 100% offline; dirty mutations queue automatically with UUIDv4 + UTC timestamps.
  * Whenever the Pi (100.68.54.112:8200) is reachable, performs deterministic
    Last-Write-Wins (LWW) bidirectional merge with tombstone propagation.
  * Atomically exports ~/.cache/cshub/waybar-snapshot.json on every mutation/sync
    for Waybar calendar highlighting, cshub-bar pill, Rofi, and Hyprlock.
"""

import argparse
import calendar
import datetime as dt
import fcntl
import json
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import urllib.error
import urllib.request
import uuid

# ---------------- Config & Paths ----------------

PI_URL = os.environ.get("CSHUB_URL", "http://100.68.54.112:8200").rstrip("/")
DATA_DIR = os.path.expanduser(os.environ.get("CSHUB_DATA_DIR", "~/.local/share/cshub"))
CACHE_DIR = os.path.expanduser(os.environ.get("CSHUB_CACHE_DIR", "~/.cache/cshub"))
DB_PATH = os.path.join(DATA_DIR, "cache.db")
LOCK_PATH = os.path.join(DATA_DIR, "sync.lock")
SNAPSHOT_PATH = os.path.join(CACHE_DIR, "waybar-snapshot.json")

# Catppuccin Mocha ANSI 24-bit palette
USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def _fg(r, g, b):
    return f"\033[38;2;{r};{g};{b}m" if USE_COLOR else ""


RESET = "\033[0m" if USE_COLOR else ""
BOLD = "\033[1m" if USE_COLOR else ""
DIM = "\033[2m" if USE_COLOR else ""
UNDER = "\033[4m" if USE_COLOR else ""
STRIKE = "\033[9m" if USE_COLOR else ""

C = {
    "mauve": _fg(203, 166, 247),
    "lavender": _fg(180, 190, 254),
    "blue": _fg(137, 180, 250),
    "sapphire": _fg(116, 199, 236),
    "teal": _fg(148, 226, 213),
    "green": _fg(166, 227, 161),
    "yellow": _fg(249, 226, 175),
    "peach": _fg(250, 179, 135),
    "red": _fg(243, 139, 168),
    "pink": _fg(245, 194, 231),
    "text": _fg(205, 214, 244),
    "sub": _fg(166, 173, 200),
    "dim": _fg(108, 112, 134),
}

KIND_META = {
    "exam":     ("EXAM",     "red",    "󰑴"),
    "homework": ("HW",       "peach",  "󰈙"),
    "deadline": ("DUE",      "peach",  "󰃰"),
    "lab":      ("LAB",      "yellow", "󰙨"),
    "project":  ("PROJ",     "mauve",  "󰉋"),
    "task":     ("TASK",     "teal",   ""),
}

PRIO_MAP = {"1": 1, "low": 1, "l": 1, "2": 2, "normal": 2, "n": 2, "med": 2,
            "3": 3, "high": 3, "h": 3, "4": 4, "urgent": 4, "u": 4, "!": 4}
PRIO_LABEL = {1: ("low", "dim"), 2: ("", "sub"), 3: ("HIGH", "peach"), 4: ("URGENT", "red")}

SYNC_TABLES = {
    "items": [
        "uid", "kind", "title", "course", "due_date", "due_time",
        "priority", "weight", "status", "notes", "completed_at",
        "created_at", "updated_at", "deleted_at",
    ],
    "courses": [
        "uid", "code", "name", "teacher", "semester", "color",
        "created", "updated_at", "deleted_at",
    ],
    "terms": [
        "uid", "term", "definition", "source", "course", "tags",
        "starred", "reviews", "last_reviewed", "ease", "interval_days",
        "reps", "next_due", "created", "updated", "updated_at", "deleted_at",
    ],
    "sessions": [
        "uid", "day", "kind", "course", "topic", "minutes",
        "quality", "energy", "notes", "created", "updated_at", "deleted_at",
    ],
    "log_entries": [
        "uid", "day", "kind", "text", "created", "updated_at", "deleted_at",
    ],
}

SCHEMA = """
CREATE TABLE IF NOT EXISTS meta (
    k TEXT PRIMARY KEY,
    v TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS items (
    uid TEXT PRIMARY KEY,
    kind TEXT NOT NULL DEFAULT 'task',
    title TEXT NOT NULL,
    course TEXT DEFAULT '',
    due_date TEXT DEFAULT '',
    due_time TEXT DEFAULT '',
    priority INTEGER DEFAULT 2,
    weight REAL DEFAULT 0,
    status TEXT DEFAULT 'todo',
    notes TEXT DEFAULT '',
    completed_at TEXT DEFAULT '',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT DEFAULT '',
    dirty INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS courses (
    uid TEXT PRIMARY KEY,
    code TEXT DEFAULT '',
    name TEXT DEFAULT '',
    teacher TEXT DEFAULT '',
    semester TEXT DEFAULT '',
    color TEXT DEFAULT '#cba6f7',
    created TEXT DEFAULT '',
    updated_at TEXT NOT NULL,
    deleted_at TEXT DEFAULT '',
    dirty INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS terms (
    uid TEXT PRIMARY KEY,
    term TEXT NOT NULL,
    definition TEXT NOT NULL,
    source TEXT DEFAULT '',
    course TEXT DEFAULT '',
    tags TEXT DEFAULT '',
    starred INTEGER DEFAULT 0,
    reviews INTEGER DEFAULT 0,
    last_reviewed TEXT DEFAULT '',
    ease REAL DEFAULT 2.5,
    interval_days INTEGER DEFAULT 0,
    reps INTEGER DEFAULT 0,
    next_due TEXT DEFAULT '',
    created TEXT DEFAULT '',
    updated TEXT DEFAULT '',
    updated_at TEXT NOT NULL,
    deleted_at TEXT DEFAULT '',
    dirty INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS sessions (
    uid TEXT PRIMARY KEY,
    day TEXT NOT NULL,
    kind TEXT DEFAULT 'study',
    course TEXT DEFAULT '',
    topic TEXT DEFAULT '',
    minutes INTEGER DEFAULT 0,
    quality INTEGER DEFAULT 0,
    energy INTEGER DEFAULT 0,
    notes TEXT DEFAULT '',
    created TEXT DEFAULT '',
    updated_at TEXT NOT NULL,
    deleted_at TEXT DEFAULT '',
    dirty INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS log_entries (
    uid TEXT PRIMARY KEY,
    day TEXT NOT NULL,
    kind TEXT DEFAULT 'note',
    text TEXT NOT NULL,
    created TEXT DEFAULT '',
    updated_at TEXT NOT NULL,
    deleted_at TEXT DEFAULT '',
    dirty INTEGER DEFAULT 0
);
"""


def utc_now():
    return dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def local_now():
    return dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def today_iso():
    return dt.date.today().isoformat()


def parse_date(raw):
    """Parse flexible date specs: today, tmr, +3d, +2w, fri, 11-28, 2026-12-04."""
    if not raw:
        return ""
    s = raw.strip().lower()
    today = dt.date.today()
    if s in ("none", "-", "clear"):
        return ""
    if s in ("today", "tod", "now"):
        return today.isoformat()
    if s in ("tomorrow", "tmr", "tom"):
        return (today + dt.timedelta(days=1)).isoformat()
    m = re.match(r"^\+(\d+)([dwm])$", s)
    if m:
        n, unit = int(m.group(1)), m.group(2)
        days = n if unit == "d" else (n * 7 if unit == "w" else n * 30)
        return (today + dt.timedelta(days=days)).isoformat()
    weekdays = {"mon": 0, "monday": 0, "tue": 1, "tues": 1, "tuesday": 1,
                "wed": 2, "wednesday": 2, "thu": 3, "thur": 3, "thurs": 3, "thursday": 3,
                "fri": 4, "friday": 4, "sat": 5, "saturday": 5, "sun": 6, "sunday": 6}
    if s in weekdays:
        delta = (weekdays[s] - today.weekday()) % 7
        if delta == 0:
            delta = 7
        return (today + dt.timedelta(days=delta)).isoformat()
    m = re.match(r"^(\d{1,2})[-/](\d{1,2})$", s)
    if m:
        mo, dy = int(m.group(1)), int(m.group(2))
        yr = today.year
        cand = dt.date(yr, mo, dy)
        if cand < today - dt.timedelta(days=14):
            cand = dt.date(yr + 1, mo, dy)
        return cand.isoformat()
    m = re.match(r"^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$", s)
    if m:
        return dt.date(int(m.group(1)), int(m.group(2)), int(m.group(3))).isoformat()
    raise ValueError(f"Unrecognized date '{raw}'. Try: today, tmr, +3d, fri, 12-04, or 2026-12-04")


def days_until(iso_date):
    if not iso_date:
        return None
    try:
        d = dt.date.fromisoformat(iso_date[:10])
        return (d - dt.date.today()).days
    except Exception:
        return None


def fmt_countdown(iso_date, due_time=""):
    delta = days_until(iso_date)
    if delta is None:
        return f"{C['dim']}no date{RESET}"
    t_s = f" {due_time}" if due_time else ""
    if delta < 0:
        return f"{BOLD}{C['red']}{abs(delta)}d OVERDUE{RESET}"
    if delta == 0:
        return f"{BOLD}{C['red']}TODAY{t_s}{RESET}"
    if delta == 1:
        return f"{BOLD}{C['peach']}TOMORROW{t_s}{RESET}"
    if delta <= 3:
        return f"{C['yellow']}in {delta}d ({iso_date[5:]}{t_s}){RESET}"
    if delta <= 7:
        return f"{C['blue']}in {delta}d ({iso_date[5:]}{t_s}){RESET}"
    return f"{C['sub']}in {delta}d ({iso_date[5:]}{t_s}){RESET}"


# ---------------- Database & Locking ----------------

class HubDB:
    def __init__(self):
        os.makedirs(DATA_DIR, exist_ok=True)
        os.makedirs(CACHE_DIR, exist_ok=True)
        self._lockf = open(LOCK_PATH, "a+")
        fcntl.flock(self._lockf.fileno(), fcntl.LOCK_EX)
        self.con = sqlite3.connect(DB_PATH, timeout=10)
        self.con.row_factory = sqlite3.Row
        self.con.execute("PRAGMA journal_mode=WAL")
        self.con.executescript(SCHEMA)
        self.con.commit()

    def close(self):
        try:
            self.con.close()
        finally:
            fcntl.flock(self._lockf.fileno(), fcntl.LOCK_UN)
            self._lockf.close()

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        self.close()

    def get_meta(self, k, default=""):
        row = self.con.execute("SELECT v FROM meta WHERE k=?", (k,)).fetchone()
        return row["v"] if row else default

    def set_meta(self, k, v):
        self.con.execute("INSERT OR REPLACE INTO meta(k, v) VALUES (?, ?)", (k, str(v)))
        self.con.commit()

    def dirty_count(self):
        total = 0
        for tbl in SYNC_TABLES:
            total += self.con.execute(f"SELECT COUNT(*) c FROM {tbl} WHERE dirty=1").fetchone()["c"]
        return total

    def export_snapshot(self):
        today = today_iso()
        open_items = [
            dict(r) for r in self.con.execute(
                """SELECT uid, kind, title, course, due_date, due_time, priority, weight, status, notes
                   FROM items
                   WHERE COALESCE(deleted_at,'')='' AND status != 'done'
                   ORDER BY CASE WHEN due_date='' THEN 1 ELSE 0 END, due_date ASC, due_time ASC, priority DESC"""
            ).fetchall()
        ]
        for it in open_items:
            it["short_id"] = it["uid"][:4]
            it["days_left"] = days_until(it["due_date"])

        # Build calendar date map (includes open dated items + done items for context)
        cal_rows = [
            dict(r) for r in self.con.execute(
                """SELECT uid, kind, title, course, due_date, due_time, priority, weight, status
                   FROM items
                   WHERE COALESCE(deleted_at,'')='' AND due_date != ''
                   ORDER BY CASE WHEN kind='exam' THEN 0 WHEN kind IN ('homework','deadline') THEN 1 ELSE 2 END,
                            due_time ASC, priority DESC"""
            ).fetchall()
        ]
        cal_map = {}
        for r in cal_rows:
            dkey = r["due_date"][:10]
            cal_map.setdefault(dkey, []).append({
                "uid": r["uid"],
                "short_id": r["uid"][:4],
                "kind": r["kind"],
                "title": r["title"],
                "course": r["course"],
                "due_time": r["due_time"],
                "weight": r["weight"],
                "status": r["status"],
                "priority": r["priority"],
            })

        terms = self.con.execute(
            "SELECT next_due FROM terms WHERE COALESCE(deleted_at,'')=''"
        ).fetchall()
        due_terms = sum(1 for t in terms if (not t["next_due"]) or t["next_due"] <= today)

        sessions = self.con.execute(
            "SELECT day, minutes FROM sessions WHERE COALESCE(deleted_at,'')=''"
        ).fetchall()
        by_day = {}
        for s in sessions:
            by_day[s["day"]] = by_day.get(s["day"], 0) + (s["minutes"] or 0)
        streak = 0
        cur = dt.date.today()
        if by_day.get(cur.isoformat(), 0) == 0:
            cur -= dt.timedelta(days=1)
        while by_day.get(cur.isoformat(), 0) > 0:
            streak += 1
            cur -= dt.timedelta(days=1)

        monday = (dt.date.today() - dt.timedelta(days=dt.date.today().weekday())).isoformat()
        week_min = sum(m for d, m in by_day.items() if d >= monday)

        snap = {
            "generated_at": utc_now(),
            "today": today,
            "online": self.get_meta("last_online", "0") == "1",
            "last_sync": self.get_meta("last_sync", ""),
            "dirty_count": self.dirty_count(),
            "due_terms": due_terms,
            "term_count": len(terms),
            "streak": streak,
            "today_minutes": by_day.get(today, 0),
            "week_minutes": week_min,
            "overdue_count": sum(1 for i in open_items if i["days_left"] is not None and i["days_left"] < 0),
            "open_items": open_items,
            "calendar": cal_map,
        }
        tmp = SNAPSHOT_PATH + ".tmp"
        with open(tmp, "w", encoding="utf-8") as f:
            json.dump(snap, f, ensure_ascii=False)
        os.replace(tmp, SNAPSHOT_PATH)
        return snap


def poke_waybar():
    for sig in ("-RTMIN+8", "-RTMIN+10"):
        subprocess.run(["pkill", sig, "waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)


# ---------------- Bidirectional LWW Sync Engine ----------------

def sync_with_pi(db: HubDB, timeout=2.2):
    """Push dirty local rows and merge Pi snapshot using deterministic UTC LWW."""
    changes = {}
    sent_uids = {}
    for tbl, cols in SYNC_TABLES.items():
        rows = db.con.execute(f"SELECT {','.join(cols)} FROM {tbl} WHERE dirty=1").fetchall()
        changes[tbl] = [dict(r) for r in rows]
        sent_uids[tbl] = {r["uid"]: r["updated_at"] for r in rows}

    payload = json.dumps({
        "client": os.uname().nodename,
        "db_epoch": db.get_meta("db_epoch", ""),
        "changes": changes,
    }).encode("utf-8")

    req = urllib.request.Request(
        f"{PI_URL}/api/sync",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except Exception as exc:
        db.set_meta("last_online", "0")
        db.set_meta("last_error", str(exc)[:180])
        db.export_snapshot()
        return {"online": False, "error": str(exc)}

    server_epoch = data.get("db_epoch", "")
    local_epoch = db.get_meta("db_epoch", "")
    epoch_reset = bool(local_epoch and server_epoch and server_epoch != local_epoch)

    snapshot = data.get("snapshot") or {}
    pulled = 0
    for tbl, cols in SYNC_TABLES.items():
        server_rows = snapshot.get(tbl) or []
        server_uids = set()
        for srec in server_rows:
            uid = srec.get("uid")
            if not uid:
                continue
            server_uids.add(uid)
            s_upd = str(srec.get("updated_at") or "")
            local = db.con.execute(f"SELECT updated_at, dirty FROM {tbl} WHERE uid=?", (uid,)).fetchone()
            if local is None:
                placeholders = ",".join("?" for _ in cols) + ",0"
                vals = [srec.get(c, "") for c in cols]
                db.con.execute(f"INSERT INTO {tbl}({','.join(cols)},dirty) VALUES ({placeholders})", vals)
                pulled += 1
            else:
                l_upd = str(local["updated_at"] or "")
                if s_upd >= l_upd:
                    upd_cols = [c for c in cols if c != "uid"]
                    set_clause = ", ".join(f"{c}=?" for c in upd_cols) + ", dirty=0"
                    vals = [srec.get(c, "") for c in upd_cols]
                    db.con.execute(f"UPDATE {tbl} SET {set_clause} WHERE uid=?", (*vals, uid))
                    if s_upd > l_upd:
                        pulled += 1

        # Clear dirty flag for local rows we pushed whose updated_at didn't change
        for uid, pushed_upd in sent_uids[tbl].items():
            db.con.execute(f"UPDATE {tbl} SET dirty=0 WHERE uid=? AND updated_at=?", (uid, pushed_upd))

        # If server DB was freshly wiped (new epoch), prune clean local ghosts not in snapshot
        if epoch_reset:
            all_clean = db.con.execute(f"SELECT uid FROM {tbl} WHERE dirty=0").fetchall()
            for row in all_clean:
                if row["uid"] not in server_uids:
                    db.con.execute(f"DELETE FROM {tbl} WHERE uid=?", (row["uid"],))

    db.con.commit()
    if server_epoch:
        db.set_meta("db_epoch", server_epoch)
    db.set_meta("last_sync", data.get("server_time") or utc_now())
    db.set_meta("last_online", "1")
    db.set_meta("last_error", "")
    db.export_snapshot()
    poke_waybar()

    pushed = sum(len(v) for v in sent_uids.values())
    return {
        "online": True,
        "pushed": pushed,
        "pulled": pulled,
        "epoch_reset": epoch_reset,
        "server_stats": data.get("stats") or {},
    }


def check_deadline_notifications(db: HubDB):
    """Fire SwayNC notifications for exams/deadlines at 24h & today thresholds (deduped)."""
    if not shutil.which("notify-send"):
        return
    try:
        notified = json.loads(db.get_meta("notified_json", "{}") or "{}")
    except Exception:
        notified = {}

    rows = db.con.execute(
        """SELECT uid, kind, title, course, due_date, due_time, weight
           FROM items
           WHERE COALESCE(deleted_at,'')='' AND status != 'done' AND due_date != ''"""
    ).fetchall()

    today = dt.date.today()
    changed = False
    for r in rows:
        delta = days_until(r["due_date"])
        if delta is None or delta > 1:
            continue
        tag = "overdue" if delta < 0 else ("today" if delta == 0 else "tomorrow")
        nkey = f"{r['uid']}:{tag}:{today.isoformat()}"
        if notified.get(nkey):
            continue
        klabel = KIND_META.get(r["kind"], ("ITEM", "blue", ""))[0]
        course = f" [{r['course']}]" if r["course"] else ""
        weight = f" ({r['weight']:g}%)" if r["weight"] else ""
        t_s = f" at {r['due_time']}" if r["due_time"] else ""
        urg = "critical" if (r["kind"] == "exam" or delta <= 0) else "normal"
        when = f"{abs(delta)}d OVERDUE" if delta < 0 else ("DUE TODAY" + t_s if delta == 0 else "Tomorrow" + t_s)
        subprocess.run(
            ["notify-send", "-u", urg, f"CS Hub · {klabel} {when}", f"{r['title']}{course}{weight}"],
            check=False,
        )
        notified[nkey] = True
        changed = True

    if changed:
        # Prune entries older than 7 days
        cutoff = (today - dt.timedelta(days=7)).isoformat()
        notified = {k: v for k, v in notified.items() if k.rsplit(":", 1)[-1] >= cutoff}
        db.set_meta("notified_json", json.dumps(notified))


# ---------------- Item Lookup Helper ----------------

def resolve_item(db: HubDB, query, include_done=True):
    q = query.strip()
    cond = "COALESCE(deleted_at,'')=''"
    if not include_done:
        cond += " AND status != 'done'"
    # Exact or prefix UID match first
    rows = db.con.execute(f"SELECT * FROM items WHERE {cond} AND uid LIKE ?", (q + "%",)).fetchall()
    if len(rows) == 1:
        return rows[0]
    if len(rows) > 1:
        print(f"{C['red']}Ambiguous ID '{q}' — matches {len(rows)} items. Give 1-2 more chars.{RESET}")
        sys.exit(1)
    # Fallback: case-insensitive title substring
    rows = db.con.execute(f"SELECT * FROM items WHERE {cond} AND LOWER(title) LIKE LOWER(?)", (f"%{q}%",)).fetchall()
    if len(rows) == 1:
        return rows[0]
    if len(rows) > 1:
        print(f"{C['yellow']}Multiple matches for '{q}':{RESET}")
        for r in rows:
            print(f"  {C['mauve']}{r['uid'][:4]}{RESET}  {r['title']} ({r['due_date'] or 'no date'})")
        sys.exit(1)
    print(f"{C['red']}No item found matching '{q}'.{RESET}")
    sys.exit(1)


# ---------------- Rendering Helpers ----------------

def print_item_row(r):
    sid = r["uid"][:4]
    klabel, kcol, kicon = KIND_META.get(r["kind"], ("ITEM", "blue", "•"))
    done = r["status"] == "done"
    doing = r["status"] == "doing"
    box = f"{C['green']}✓{RESET}" if done else (f"{C['yellow']}◐{RESET}" if doing else f"{C['dim']}○{RESET}")
    course = f" {C['lavender']}[{r['course']}]{RESET}" if r["course"] else ""
    weight = f" {C['pink']}{r['weight']:g}%{RESET}" if r["weight"] else ""
    plbl, pcol = PRIO_LABEL.get(int(r["priority"] or 2), ("", "sub"))
    prio = f" {C[pcol]}{BOLD}{plbl}{RESET}" if plbl and not done else ""
    title_s = f"{DIM}{STRIKE}{r['title']}{RESET}" if done else f"{C['text']}{r['title']}{RESET}"
    due_s = f"{C['dim']}{r['due_date'] or 'done'}{RESET}" if done else fmt_countdown(r["due_date"], r["due_time"])
    print(f"  {box} {C['dim']}{sid}{RESET}  {C[kcol]}{BOLD}{kicon} {klabel:<4}{RESET}  {title_s}{course}{weight}{prio}   {due_s}")


def print_sync_footer(res, db: HubDB):
    dirty = db.dirty_count()
    if res and res.get("online"):
        extra = f" · ↑{res.get('pushed',0)} ↓{res.get('pulled',0)}" if (res.get("pushed") or res.get("pulled")) else ""
        print(f"{C['dim']}  ⚡ synced with Pi{extra}{RESET}")
    else:
        q = f" ({dirty} queued)" if dirty else ""
        print(f"{C['yellow']}  ⚡ offline cache{q} — will merge automatically when Pi is reachable{RESET}")


# ---------------- CLI Commands ----------------

def cmd_dash(args):
    with HubDB() as db:
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        today = dt.date.today()
        print(f"\n{BOLD}{C['mauve']}󰑴  CS HUB{RESET}  {C['sub']}{today.strftime('%A, %b %d %Y')}{RESET}")
        print(f"{C['dim']}{'─' * 66}{RESET}")

        open_items = db.con.execute(
            """SELECT * FROM items WHERE COALESCE(deleted_at,'')='' AND status != 'done'
               ORDER BY CASE WHEN due_date='' THEN 1 ELSE 0 END, due_date ASC, due_time ASC, priority DESC"""
        ).fetchall()

        overdue = [r for r in open_items if r["due_date"] and (days_until(r["due_date"]) or 0) < 0]
        exams = [r for r in open_items if r["kind"] == "exam" and r not in overdue]
        deadlines = [r for r in open_items if r["kind"] in ("homework", "deadline", "lab", "project") and r not in overdue]
        tasks = [r for r in open_items if r["kind"] == "task" and r not in overdue]

        if overdue:
            print(f"\n{BOLD}{C['red']}  OVERDUE ({len(overdue)}){RESET}")
            for r in overdue:
                print_item_row(r)

        if exams:
            print(f"\n{BOLD}{C['red']}󰑴  UPCOMING EXAMS ({len(exams)}){RESET}")
            for r in exams[:8]:
                print_item_row(r)

        if deadlines:
            print(f"\n{BOLD}{C['peach']}󰈙  HOMEWORK & DEADLINES ({len(deadlines)}){RESET}")
            for r in deadlines[:10]:
                print_item_row(r)

        if tasks:
            print(f"\n{BOLD}{C['teal']}  TASKS ({len(tasks)}){RESET}")
            for r in tasks[:10]:
                print_item_row(r)

        if not open_items:
            print(f"\n  {C['green']}✓ All clear — no open exams, homework, or tasks!{RESET}")
            print(f"  {C['dim']}Try: cshub exam \"Final Aoop\" 12-10 -c Aoop -w 30  |  cshub hw \"TP03\" +4d -c Aoop{RESET}")

        snap = db.export_snapshot()
        print(f"\n{C['dim']}{'─' * 66}{RESET}")
        print(
            f"  {C['mauve']}Cards due:{RESET} {snap['due_terms']}/{snap['term_count']}   "
            f"{C['peach']}Streak:{RESET} {snap['streak']}d   "
            f"{C['green']}Today:{RESET} {snap['today_minutes']}m   "
            f"{C['blue']}Week:{RESET} {snap['week_minutes']}m"
        )
        print_sync_footer(res, db)
        print()


def cmd_add_item(args, forced_kind=None):
    kind = forced_kind or args.kind
    if kind == "hw":
        kind = "homework"
    due_date = parse_date(args.date) if args.date else ""
    prio = PRIO_MAP.get(str(args.priority).lower(), 2)
    now = utc_now()
    uid = str(uuid.uuid4())
    with HubDB() as db:
        db.con.execute(
            """INSERT INTO items(uid, kind, title, course, due_date, due_time, priority, weight, status, notes, completed_at, created_at, updated_at, deleted_at, dirty)
               VALUES (?,?,?,?,?,?,?,?,?,?,'',?,?, '', 1)""",
            (uid, kind, args.title.strip(), (args.course or "").strip(), due_date,
             (args.time or "").strip(), prio, float(args.weight or 0), "todo",
             (args.notes or "").strip(), now, now),
        )
        db.con.commit()
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        row = db.con.execute("SELECT * FROM items WHERE uid=?", (uid,)).fetchone()
        print(f"{C['green']}Added:{RESET}")
        print_item_row(row)
        print_sync_footer(res, db)


def cmd_ls(args):
    with HubDB() as db:
        if not args.offline:
            sync_with_pi(db, timeout=1.5)
        where = ["COALESCE(deleted_at,'')=''"]
        params = []
        if args.done:
            where.append("status='done'")
        elif not args.all:
            where.append("status!='done'")
        if args.kind:
            k = "homework" if args.kind == "hw" else args.kind
            where.append("kind=?")
            params.append(k)
        if args.course:
            where.append("LOWER(course)=LOWER(?)")
            params.append(args.course)
        rows = db.con.execute(
            f"""SELECT * FROM items WHERE {' AND '.join(where)}
                ORDER BY CASE WHEN status='done' THEN 1 ELSE 0 END,
                         CASE WHEN due_date='' THEN 1 ELSE 0 END, due_date ASC, due_time ASC, priority DESC""",
            params,
        ).fetchall()
        if not rows:
            print(f"{C['dim']}No matching items.{RESET}")
            return
        for r in rows:
            print_item_row(r)


def cmd_agenda(args):
    horizon = dt.date.today() + dt.timedelta(days=args.days)
    with HubDB() as db:
        if not args.offline:
            sync_with_pi(db, timeout=1.5)
        rows = db.con.execute(
            """SELECT * FROM items
               WHERE COALESCE(deleted_at,'')='' AND status != 'done'
                 AND due_date != '' AND due_date <= ?
               ORDER BY due_date ASC, due_time ASC, priority DESC""",
            (horizon.isoformat(),),
        ).fetchall()
        print(f"\n{BOLD}{C['mauve']}  AGENDA (next {args.days} days){RESET}")
        if not rows:
            print(f"  {C['green']}Nothing due in the next {args.days} days.{RESET}\n")
            return
        cur_day = None
        for r in rows:
            if r["due_date"] != cur_day:
                cur_day = r["due_date"]
                d = dt.date.fromisoformat(cur_day)
                print(f"\n  {BOLD}{C['blue']}{d.strftime('%a %b %d')}{RESET}  {fmt_countdown(cur_day)}")
            print_item_row(r)
        print()


def cmd_cal(args):
    today = dt.date.today()
    if args.month:
        m = re.match(r"^(\d{4})-(\d{1,2})$", args.month)
        if not m:
            sys.exit("Use YYYY-MM format, e.g. cshub cal 2026-12")
        yr, mo = int(m.group(1)), int(m.group(2))
    else:
        yr, mo = today.year, today.month

    with HubDB() as db:
        if not args.offline:
            sync_with_pi(db, timeout=1.5)
        snap = db.export_snapshot()

    cal_map = snap["calendar"]
    cal = calendar.Calendar(calendar.SUNDAY)
    header = f"{calendar.month_name[mo]} {yr}".center(20)
    print(f"\n  {BOLD}{C['mauve']}{header}{RESET}")
    print(f"  {BOLD}{C['yellow']}Su Mo Tu We Th Fr Sa{RESET}")
    month_events = []
    for week in cal.monthdayscalendar(yr, mo):
        cells = []
        for d in week:
            if d == 0:
                cells.append("  ")
                continue
            iso = f"{yr:04d}-{mo:02d}-{d:02d}"
            evs = [e for e in cal_map.get(iso, []) if e["status"] != "done"]
            is_today = (yr == today.year and mo == today.month and d == today.day)
            if evs:
                month_events.append((iso, evs))
                kinds = {e["kind"] for e in evs}
                has_exam = "exam" in kinds
                has_hw = bool(kinds & {"homework", "deadline", "lab", "project"})
                if has_exam and (has_hw or len(evs) > 1):
                    col = C["yellow"]
                elif has_exam:
                    col = C["red"]
                elif has_hw:
                    col = C["peach"]
                else:
                    col = C["teal"]
                style = BOLD + (UNDER if is_today else "")
                cells.append(f"{style}{col}{d:2d}{RESET}")
            elif is_today:
                cells.append(f"{BOLD}{UNDER}{C['blue']}{d:2d}{RESET}")
            else:
                cells.append(f"{C['text']}{d:2d}{RESET}")
        print("  " + " ".join(cells))

    print(f"\n  {C['red']}■{RESET} Exam  {C['peach']}■{RESET} HW/Due  {C['teal']}■{RESET} Task  {C['yellow']}■{RESET} Multi  {UNDER}{C['blue']}Today{RESET}")
    if month_events:
        print()
        for iso, evs in month_events:
            for e in evs:
                klbl, kcol, _ = KIND_META.get(e["kind"], ("ITEM", "blue", "•"))
                course = f" [{e['course']}]" if e["course"] else ""
                wt = f" {e['weight']:g}%" if e["weight"] else ""
                print(f"  {C[kcol]}● {iso[5:]} {klbl:<4}{RESET} {e['title']}{C['sub']}{course}{wt}{RESET}  {fmt_countdown(iso, e.get('due_time',''))}")
    print()


def cmd_set_status(args, status):
    with HubDB() as db:
        row = resolve_item(db, args.id, include_done=(status != "done"))
        now = utc_now()
        comp = now if status == "done" else ""
        db.con.execute(
            "UPDATE items SET status=?, completed_at=?, updated_at=?, dirty=1 WHERE uid=?",
            (status, comp, now, row["uid"]),
        )
        db.con.commit()
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        updated = db.con.execute("SELECT * FROM items WHERE uid=?", (row["uid"],)).fetchone()
        print_item_row(updated)
        print_sync_footer(res, db)


def cmd_edit(args):
    with HubDB() as db:
        row = resolve_item(db, args.id, include_done=True)
        fields = {}
        if args.title is not None:
            fields["title"] = args.title.strip()
        if args.course is not None:
            fields["course"] = args.course.strip()
        if args.date is not None:
            fields["due_date"] = parse_date(args.date)
        if args.time is not None:
            fields["due_time"] = args.time.strip()
        if args.kind is not None:
            fields["kind"] = "homework" if args.kind == "hw" else args.kind
        if args.priority is not None:
            fields["priority"] = PRIO_MAP.get(args.priority.lower(), 2)
        if args.weight is not None:
            fields["weight"] = float(args.weight)
        if args.notes is not None:
            fields["notes"] = args.notes.strip()
        if not fields:
            sys.exit("Nothing to update. Pass -t/--title, -d/--date, -c/--course, -k/--kind, -w/--weight, -p/--priority, or -n/--notes.")
        fields["updated_at"] = utc_now()
        set_clause = ", ".join(f"{k}=?" for k in fields) + ", dirty=1"
        db.con.execute(f"UPDATE items SET {set_clause} WHERE uid=?", (*fields.values(), row["uid"]))
        db.con.commit()
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        updated = db.con.execute("SELECT * FROM items WHERE uid=?", (row["uid"],)).fetchone()
        print_item_row(updated)
        print_sync_footer(res, db)


def cmd_rm(args):
    with HubDB() as db:
        row = resolve_item(db, args.id, include_done=True)
        now = utc_now()
        db.con.execute(
            "UPDATE items SET deleted_at=?, updated_at=?, dirty=1 WHERE uid=?",
            (now, now, row["uid"]),
        )
        db.con.commit()
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        print(f"{C['red']}Deleted:{RESET} {row['title']} ({row['uid'][:4]})")
        print_sync_footer(res, db)


def cmd_history(args):
    with HubDB() as db:
        if not args.offline:
            sync_with_pi(db, timeout=1.5)
        done_items = db.con.execute(
            """SELECT * FROM items WHERE COALESCE(deleted_at,'')='' AND status='done'
               ORDER BY completed_at DESC, updated_at DESC LIMIT ?""",
            (args.limit,),
        ).fetchall()
        sessions = db.con.execute(
            """SELECT * FROM sessions WHERE COALESCE(deleted_at,'')=''
               ORDER BY day DESC, updated_at DESC LIMIT ?""",
            (args.limit,),
        ).fetchall()
        notes = db.con.execute(
            """SELECT * FROM log_entries WHERE COALESCE(deleted_at,'')=''
               ORDER BY day DESC, updated_at DESC LIMIT ?""",
            (args.limit,),
        ).fetchall()
        print(f"\n{BOLD}{C['green']}✓  COMPLETED ITEMS ({len(done_items)}){RESET}")
        for r in done_items:
            print_item_row(r)
        if sessions:
            print(f"\n{BOLD}{C['blue']}󰔟  STUDY SESSIONS ({len(sessions)}){RESET}")
            for s in sessions:
                c = f" [{s['course']}]" if s["course"] else ""
                print(f"  {C['dim']}{s['day']}{RESET}  {C['green']}{s['minutes']:>3}m{RESET}  {s['topic'] or s['kind']}{C['lavender']}{c}{RESET}")
        if notes:
            print(f"\n{BOLD}{C['mauve']}📓  JOURNAL ({len(notes)}){RESET}")
            for n in notes:
                print(f"  {C['dim']}{n['day']}{RESET}  {C['peach']}[{n['kind']}]{RESET} {n['text']}")
        print()


def cmd_course(args):
    with HubDB() as db:
        if args.action == "add":
            now = utc_now()
            uid = str(uuid.uuid4())
            db.con.execute(
                """INSERT INTO courses(uid, code, name, teacher, semester, color, created, updated_at, deleted_at, dirty)
                   VALUES (?,?,?,?,?,?,?,?,'',1)""",
                (uid, args.code.strip(), (args.name or "").strip(), (args.teacher or "").strip(),
                 (args.semester or "").strip(), args.color or "#cba6f7", local_now(), now),
            )
            db.con.commit()
            res = sync_with_pi(db, timeout=1.5) if not args.offline else None
            print(f"{C['green']}Added course:{RESET} {BOLD}{args.code}{RESET} {args.name or ''}")
            print_sync_footer(res, db)
        elif args.action == "rm":
            row = db.con.execute(
                "SELECT * FROM courses WHERE COALESCE(deleted_at,'')='' AND (LOWER(code)=LOWER(?) OR uid LIKE ?)",
                (args.code, args.code + "%"),
            ).fetchone()
            if not row:
                sys.exit(f"Course '{args.code}' not found.")
            now = utc_now()
            db.con.execute("UPDATE courses SET deleted_at=?, updated_at=?, dirty=1 WHERE uid=?", (now, now, row["uid"]))
            db.con.commit()
            res = sync_with_pi(db, timeout=1.5) if not args.offline else None
            print(f"{C['red']}Deleted course:{RESET} {row['code']} {row['name']}")
            print_sync_footer(res, db)
        else:
            if not args.offline:
                sync_with_pi(db, timeout=1.5)
            rows = db.con.execute("SELECT * FROM courses WHERE COALESCE(deleted_at,'')='' ORDER BY code").fetchall()
            if not rows:
                print(f"{C['dim']}No courses yet. Add one: cshub course add Aoop \"Object Oriented Programming\"{RESET}")
                return
            for r in rows:
                n_open = db.con.execute(
                    "SELECT COUNT(*) c FROM items WHERE COALESCE(deleted_at,'')='' AND status!='done' AND LOWER(course)=LOWER(?)",
                    (r["code"],),
                ).fetchone()["c"]
                n_terms = db.con.execute(
                    "SELECT COUNT(*) c FROM terms WHERE COALESCE(deleted_at,'')='' AND LOWER(course)=LOWER(?)",
                    (r["code"],),
                ).fetchone()["c"]
                print(f"  {C['mauve']}{BOLD}{r['code']:<10}{RESET} {r['name']:<32} {C['peach']}{n_open} open{RESET} · {C['blue']}{n_terms} cards{RESET} {C['dim']}{r['teacher']}{RESET}")


def cmd_term(args):
    with HubDB() as db:
        if args.action == "add":
            now = utc_now()
            uid = str(uuid.uuid4())
            db.con.execute(
                """INSERT INTO terms(uid, term, definition, source, course, tags, starred, reviews, last_reviewed, ease, interval_days, reps, next_due, created, updated, updated_at, deleted_at, dirty)
                   VALUES (?,?,?,?,?,?,0,0,'',2.5,0,0,'',?,?,?,'',1)""",
                (uid, args.term.strip(), args.definition.strip(), args.source or "CLI",
                 (args.course or "").strip(), (args.tags or "").strip(), local_now(), local_now(), now),
            )
            db.con.commit()
            db.export_snapshot()
            poke_waybar()
            res = sync_with_pi(db, timeout=1.5) if not args.offline else None
            print(f"{C['green']}Saved term:{RESET} {BOLD}{args.term}{RESET} ({uid[:4]})")
            print_sync_footer(res, db)
        else:
            if not args.offline:
                sync_with_pi(db, timeout=1.5)
            where = ["COALESCE(deleted_at,'')=''"]
            params = []
            if args.course:
                where.append("LOWER(course)=LOWER(?)")
                params.append(args.course)
            rows = db.con.execute(f"SELECT * FROM terms WHERE {' AND '.join(where)} ORDER BY updated_at DESC", params).fetchall()
            if not rows:
                print(f"{C['dim']}No terms yet. Add one: cshub term add \"RAII\" \"Resource Acquisition Is Initialization\" -c C++{RESET}")
                return
            today = today_iso()
            for r in rows:
                due = (not r["next_due"]) or r["next_due"] <= today
                badge = f"{C['peach']}DUE{RESET}" if due else f"{C['green']}{r['next_due']}{RESET}"
                c = f" {C['lavender']}[{r['course']}]{RESET}" if r["course"] else ""
                print(f"  {C['dim']}{r['uid'][:4]}{RESET} {BOLD}{r['term']}{RESET}{c} ({badge}) — {C['sub']}{r['definition'][:70]}{RESET}")


def cmd_drill(args):
    with HubDB() as db:
        if not args.offline:
            sync_with_pi(db, timeout=1.5)
        today = today_iso()
        where = ["COALESCE(deleted_at,'')=''", "(next_due='' OR next_due IS NULL OR next_due <= ?)"]
        params = [today]
        if args.course:
            where.append("LOWER(course)=LOWER(?)")
            params.append(args.course)
        queue = db.con.execute(f"SELECT * FROM terms WHERE {' AND '.join(where)} ORDER BY reviews ASC", params).fetchall()
        if not queue:
            print(f"{C['green']}✓ No flashcards due right now!{RESET}")
            return
        print(f"\n{BOLD}{C['mauve']}󰑴  OFFLINE-CAPABLE SM-2 DRILL ({len(queue)} due){RESET}  {C['dim']}(q to quit){RESET}\n")
        done = 0
        for idx, card in enumerate(queue, 1):
            c = f" [{card['course']}]" if card["course"] else ""
            print(f"{C['dim']}({idx}/{len(queue)}){RESET} {BOLD}{C['blue']}{card['term']}{RESET}{C['lavender']}{c}{RESET}")
            ans = input(f"  {C['dim']}[Enter to reveal, q to quit]{RESET} ").strip().lower()
            if ans == "q":
                break
            print(f"  {C['text']}{card['definition']}{RESET}")
            while True:
                g = input(f"  {C['red']}1:Again{RESET}  {C['peach']}2:Hard{RESET}  {C['green']}3:Good{RESET}  {C['teal']}4:Easy{RESET} > ").strip().lower()
                if g == "q":
                    g = None
                    break
                if g in ("1", "2", "3", "4"):
                    g = int(g)
                    break
            if g is None:
                break
            ease = float(card["ease"] or 2.5)
            interval = int(card["interval_days"] or 0)
            reps = int(card["reps"] or 0)
            t0 = dt.date.today()
            if g == 1:
                reps, interval, ease = 0, 0, max(1.3, round(ease - 0.2, 2))
                next_due = t0.isoformat()
            elif g == 2:
                reps = max(1, reps)
                interval = max(1, round(interval * 1.2) if interval > 0 else 1)
                ease = max(1.3, round(ease - 0.15, 2))
                next_due = (t0 + dt.timedelta(days=interval)).isoformat()
            elif g == 3:
                interval = 1 if reps == 0 else (6 if reps == 1 else max(1, round(interval * ease)))
                reps += 1
                next_due = (t0 + dt.timedelta(days=interval)).isoformat()
            else:
                interval = 4 if reps == 0 else max(2, round(interval * ease * 1.3))
                reps += 1
                ease = min(3.5, round(ease + 0.15, 2))
                next_due = (t0 + dt.timedelta(days=interval)).isoformat()
            now = utc_now()
            db.con.execute(
                """UPDATE terms SET reviews=reviews+1, last_reviewed=?, ease=?, interval_days=?, reps=?, next_due=?, updated=?, updated_at=?, dirty=1
                   WHERE uid=?""",
                (local_now(), ease, interval, reps, next_due, local_now(), now, card["uid"]),
            )
            db.con.commit()
            done += 1
            print(f"  {C['dim']}-> next due {next_due} ({interval}d){RESET}\n")
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if (done > 0 and not args.offline) else None
        print(f"{C['green']}Drilled {done} card(s).{RESET}")
        if done > 0:
            print_sync_footer(res, db)


def cmd_note(args):
    now = utc_now()
    uid = str(uuid.uuid4())
    with HubDB() as db:
        db.con.execute(
            """INSERT INTO log_entries(uid, day, kind, text, created, updated_at, deleted_at, dirty)
               VALUES (?,?,?,?,?,?,'',1)""",
            (uid, today_iso(), args.kind, args.text.strip(), local_now(), now),
        )
        db.con.commit()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        print(f"{C['green']}Logged [{args.kind}]:{RESET} {args.text.strip()}")
        print_sync_footer(res, db)


def cmd_study(args):
    if args.minutes <= 0:
        sys.exit("Minutes must be > 0")
    now = utc_now()
    uid = str(uuid.uuid4())
    with HubDB() as db:
        db.con.execute(
            """INSERT INTO sessions(uid, day, kind, course, topic, minutes, quality, energy, notes, created, updated_at, deleted_at, dirty)
               VALUES (?,?,?,?,?,?,?,?,?,?,?, '', 1)""",
            (uid, today_iso(), args.kind, (args.course or "").strip(), (args.topic or "").strip(),
             args.minutes, args.quality, args.energy, (args.notes or "").strip(), local_now(), now),
        )
        db.con.commit()
        db.export_snapshot()
        poke_waybar()
        res = sync_with_pi(db, timeout=1.5) if not args.offline else None
        print(f"{C['green']}Logged {args.minutes}m {args.kind}{RESET}" + (f" [{args.course}]" if args.course else ""))
        print_sync_footer(res, db)


def cmd_sync(args):
    with HubDB() as db:
        res = sync_with_pi(db, timeout=3.0)
        if args.notify:
            check_deadline_notifications(db)
        if args.quiet:
            return
        if res["online"]:
            reset_s = " (new server epoch — pruned stale clean rows)" if res.get("epoch_reset") else ""
            print(f"{C['green']}✓ Synced with Pi{RESET} — pushed {res['pushed']}, pulled {res['pulled']}{reset_s}")
        else:
            print(f"{C['yellow']}⚡ Pi unreachable ({PI_URL}){RESET} — {db.dirty_count()} change(s) safely queued locally")


def cmd_status(args):
    with HubDB() as db:
        snap = db.export_snapshot()
        online_s = f"{C['green']}ONLINE{RESET}" if snap["online"] else f"{C['yellow']}OFFLINE{RESET}"
        print(f"\n{BOLD}{C['mauve']}󰑴  CS Hub Sync & Cache Status{RESET}")
        print(f"  Pi endpoint : {PI_URL}")
        print(f"  Last state  : {online_s}")
        print(f"  Last sync   : {snap['last_sync'] or 'never'}")
        print(f"  DB epoch    : {db.get_meta('db_epoch') or 'uninitialized'}")
        print(f"  Queued sync : {snap['dirty_count']} dirty record(s)")
        print(f"  Open items  : {len(snap['open_items'])} ({snap['overdue_count']} overdue)")
        print(f"  Flashcards  : {snap['due_terms']} due / {snap['term_count']} total")
        print(f"  Cache DB    : {DB_PATH}")
        print(f"  Waybar JSON : {SNAPSHOT_PATH}\n")


def cmd_json(args):
    with HubDB() as db:
        snap = db.export_snapshot()
    print(json.dumps(snap, ensure_ascii=False))


# ---------------- Argument Parser ----------------

def build_parser():
    p = argparse.ArgumentParser(prog="cshub", description="Dyna's offline-first CLI for Pi CS Student Hub")
    p.add_argument("--offline", action="store_true", help="Skip Pi network sync for this command")
    sub = p.add_subparsers(dest="cmd")

    sub.add_parser("dash", help="Show full Mocha dashboard (default)")

    def add_item_opts(sp, require_date=False):
        sp.add_argument("title", help="Item title")
        if require_date:
            sp.add_argument("date", help="Due/exam date (today, tmr, +3d, fri, 12-04, 2026-12-04)")
        else:
            sp.add_argument("-d", "--date", default="", help="Optional due date")
        sp.add_argument("-c", "--course", default="", help="Course code (e.g. Aoop, SQL)")
        sp.add_argument("-t", "--time", default="", help="Optional time (HH:MM)")
        sp.add_argument("-w", "--weight", type=float, default=0, help="Grade weight %% (e.g. 25)")
        sp.add_argument("-p", "--priority", default="normal", help="low | normal | high | urgent")
        sp.add_argument("-n", "--notes", default="", help="Extra notes")

    add_item_opts(sub.add_parser("exam", help="Add an exam"), require_date=True)
    add_item_opts(sub.add_parser("hw", aliases=["homework"], help="Add a homework assignment"), require_date=True)
    add_item_opts(sub.add_parser("deadline", aliases=["due"], help="Add a deadline"), require_date=True)
    add_item_opts(sub.add_parser("lab", help="Add a lab"), require_date=True)
    add_item_opts(sub.add_parser("project", help="Add a project deadline"), require_date=True)
    sp_todo = sub.add_parser("todo", aliases=["task", "add"], help="Add a task")
    add_item_opts(sp_todo, require_date=False)
    sp_todo.add_argument("-k", "--kind", default="task", help="Kind: exam|hw|deadline|lab|project|task")

    sp_ls = sub.add_parser("ls", aliases=["list"], help="List items")
    sp_ls.add_argument("-a", "--all", action="store_true", help="Include completed items")
    sp_ls.add_argument("--done", action="store_true", help="Show only completed items")
    sp_ls.add_argument("-k", "--kind", default="", help="Filter by kind")
    sp_ls.add_argument("-c", "--course", default="", help="Filter by course")

    sp_ag = sub.add_parser("agenda", help="Chronological upcoming schedule")
    sp_ag.add_argument("days", nargs="?", type=int, default=14, help="Days ahead (default 14)")

    sp_cal = sub.add_parser("cal", help="Colorized Mocha calendar")
    sp_cal.add_argument("month", nargs="?", default="", help="YYYY-MM (default current month)")

    sub.add_parser("done", help="Mark item completed").add_argument("id", help="Short ID or title match")
    sub.add_parser("doing", help="Mark item in progress").add_argument("id", help="Short ID or title match")
    sub.add_parser("undo", help="Reopen completed item").add_argument("id", help="Short ID or title match")
    sub.add_parser("rm", aliases=["del"], help="Delete item").add_argument("id", help="Short ID or title match")

    sp_ed = sub.add_parser("edit", help="Edit an existing item")
    sp_ed.add_argument("id", help="Short ID or title match")
    sp_ed.add_argument("--title", default=None)
    sp_ed.add_argument("-d", "--date", default=None)
    sp_ed.add_argument("-t", "--time", default=None)
    sp_ed.add_argument("-c", "--course", default=None)
    sp_ed.add_argument("-k", "--kind", default=None)
    sp_ed.add_argument("-w", "--weight", type=float, default=None)
    sp_ed.add_argument("-p", "--priority", default=None)
    sp_ed.add_argument("-n", "--notes", default=None)

    sp_hist = sub.add_parser("history", aliases=["completed"], help="Show completed items, study sessions & journal")
    sp_hist.add_argument("-n", "--limit", type=int, default=15)

    sp_course = sub.add_parser("course", aliases=["courses"], help="Manage courses")
    c_sub = sp_course.add_subparsers(dest="action")
    c_sub.add_parser("ls")
    c_add = c_sub.add_parser("add")
    c_add.add_argument("code")
    c_add.add_argument("name", nargs="?", default="")
    c_add.add_argument("--teacher", default="")
    c_add.add_argument("--semester", default="")
    c_add.add_argument("--color", default="#cba6f7")
    c_sub.add_parser("rm").add_argument("code")

    sp_term = sub.add_parser("term", aliases=["terms"], help="Manage flashcards (offline-first)")
    t_sub = sp_term.add_subparsers(dest="action")
    t_ls = t_sub.add_parser("ls")
    t_ls.add_argument("-c", "--course", default="")
    t_add = t_sub.add_parser("add")
    t_add.add_argument("term")
    t_add.add_argument("definition")
    t_add.add_argument("-c", "--course", default="")
    t_add.add_argument("-s", "--source", default="CLI")
    t_add.add_argument("--tags", default="")

    sp_drill = sub.add_parser("drill", help="Interactive SM-2 flashcard drill")
    sp_drill.add_argument("-c", "--course", default="")

    sp_note = sub.add_parser("note", help="Quick journal note")
    sp_note.add_argument("text")
    sp_note.add_argument("-k", "--kind", default="note", choices=["note", "win", "fossil", "blocker"])

    sp_study = sub.add_parser("study", help="Log study session minutes")
    sp_study.add_argument("minutes", type=int)
    sp_study.add_argument("-c", "--course", default="")
    sp_study.add_argument("-t", "--topic", default="")
    sp_study.add_argument("-k", "--kind", default="study")
    sp_study.add_argument("-q", "--quality", type=int, default=3)
    sp_study.add_argument("-e", "--energy", type=int, default=3)
    sp_study.add_argument("-n", "--notes", default="")

    sp_sync = sub.add_parser("sync", help="Bidirectional LWW sync with Pi")
    sp_sync.add_argument("--quiet", action="store_true")
    sp_sync.add_argument("--notify", action="store_true", help="Send SwayNC reminders for imminent deadlines")

    sub.add_parser("status", help="Show sync & cache diagnostics")
    sub.add_parser("json", help="Print Waybar/DE JSON snapshot")
    return p


def main():
    parser = build_parser()
    args = parser.parse_args()
    cmd = args.cmd or "dash"
    try:
        if cmd == "dash":
            cmd_dash(args)
        elif cmd == "exam":
            cmd_add_item(args, "exam")
        elif cmd in ("hw", "homework"):
            cmd_add_item(args, "homework")
        elif cmd in ("deadline", "due"):
            cmd_add_item(args, "deadline")
        elif cmd == "lab":
            cmd_add_item(args, "lab")
        elif cmd == "project":
            cmd_add_item(args, "project")
        elif cmd in ("todo", "task", "add"):
            cmd_add_item(args)
        elif cmd in ("ls", "list"):
            cmd_ls(args)
        elif cmd == "agenda":
            cmd_agenda(args)
        elif cmd == "cal":
            cmd_cal(args)
        elif cmd == "done":
            cmd_set_status(args, "done")
        elif cmd == "doing":
            cmd_set_status(args, "doing")
        elif cmd == "undo":
            cmd_set_status(args, "todo")
        elif cmd == "edit":
            cmd_edit(args)
        elif cmd in ("rm", "del"):
            cmd_rm(args)
        elif cmd in ("history", "completed"):
            cmd_history(args)
        elif cmd in ("course", "courses"):
            if not getattr(args, "action", None):
                args.action = "ls"
            cmd_course(args)
        elif cmd in ("term", "terms"):
            if not getattr(args, "action", None):
                args.action = "ls"
                args.course = ""
            cmd_term(args)
        elif cmd == "drill":
            cmd_drill(args)
        elif cmd == "note":
            cmd_note(args)
        elif cmd == "study":
            cmd_study(args)
        elif cmd == "sync":
            cmd_sync(args)
        elif cmd == "status":
            cmd_status(args)
        elif cmd == "json":
            cmd_json(args)
    except ValueError as e:
        print(f"{C['red']}Error:{RESET} {e}", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
