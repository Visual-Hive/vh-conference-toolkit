# 📋 Event Ops Task & Supplier Tracker

A Kanban-style pipeline for managing supplier communications across your event. Track tasks from first contact to confirmed — with staleness alerts when suppliers go quiet.

**Works on Mac · Windows · Linux · No coding required**

---

## Quick Start — Two options

### Option A: Just open it (solo use, no install)

> Your data is stored in your browser. Export JSON regularly as a backup.

1. [**Download the zip**](https://github.com/Visual-Hive/vh-conference-toolkit/releases/latest) from the releases page
2. Unzip it
3. Double-click `index.html`
4. Done — the tool opens in your browser

---

### Option B: Docker install (recommended for teams or long projects)

> Your data is saved to `./data/db.json` on your computer — **not** inside Docker.
> This file survives Docker restarts, reinstalls, and updates.

**Prerequisites:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) (free, ~500MB)

**Mac / Linux / WSL:**
```bash
./setup.sh
```

**Windows (double-click):**
```
setup.bat
```

The script will:
1. Check Docker is installed and running
2. Create `./data/db.json` if it doesn't exist
3. Start nginx + local API server via Docker Compose
4. Open your browser at `http://localhost:8080`

---

## Your data is safe

| What happens | Your data |
|---|---|
| You restart Docker | ✅ Safe — `./data/db.json` is on your machine |
| You delete and reinstall Docker | ✅ Safe — just run `setup.sh` again |
| You uninstall the tool | ✅ `./data/db.json` stays on your machine |
| You accidentally delete `./data/db.json` | ⚠️ Data is gone — back it up! |

**To back up your data:** copy `./data/db.json` to Dropbox, Google Drive, or email it to yourself.

**To restore:** put `db.json` back in the `./data/` folder and run `setup.sh` again.

---

## AI setup helper (optional)

If something goes wrong during setup, the script can ask Claude for a plain-English fix:

1. Copy `.env.example` to `.env`
2. Add your Anthropic API key: `ANTHROPIC_API_KEY=sk-ant-...`
3. Run `setup.sh` — if it hits an error, it will ask Claude to explain it

Get a free API key at [console.anthropic.com](https://console.anthropic.com/).

---

## Features

- **Kanban board** with drag-and-drop across custom pipeline stages
- **Gantt view** for timeline overview
- **Supplier contacts** with full contact management
- **Staleness alerts** — amber/red warnings when suppliers go quiet
- **Next actions** with due dates and completion history
- **Subtasks & dependencies** between tasks
- **Import from Countdown Planner** — push generated tasks directly into the board
- **JSON backup & restore**
- **CSV export**

---

## Also available on EventHive

This tool is part of [EventHive](https://eventhive.io) — the free platform for event industry professionals. On EventHive, your data is stored securely in the cloud, accessible from any device, and managed by Erleah AI.

---

*MIT License — free to use, modify, and distribute*
