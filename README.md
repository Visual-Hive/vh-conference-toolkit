# VH Conference Toolkit

Free, open-source event planning tools. Download and run them on any desktop OS — no account, no subscription, no data sent anywhere.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Tools

### 🗓 [Event Countdown Task Generator](event-countdown-planner/)
Generate a complete week-by-week task plan for any event type. T-16 weeks to post-event. Edit, track progress, export templates.

**No install required** — just open `index.html` in your browser.

[Download →](https://github.com/Visual-Hive/vh-conference-toolkit/releases/latest)

---

### 📋 [Event Ops Task & Supplier Tracker](event-ops-tracker/)
Kanban board for managing supplier communications. Track tasks from brief to confirmed with staleness alerts and next-action tracking.

**Browser mode:** open `index.html` — data saves in your browser.
**Docker mode:** run `setup.sh` (Mac/Linux) or `setup.bat` (Windows) — data saves to `./data/db.json` on your machine.

[Download →](https://github.com/Visual-Hive/vh-conference-toolkit/releases/latest)

---

## Download

Go to the [**Releases page**](https://github.com/Visual-Hive/vh-conference-toolkit/releases/latest) and download the zip for the tool you want.

Each tool is a self-contained folder — no dependencies between them unless you want them (the Countdown Planner can push tasks directly into the Ops Tracker).

---

## Requirements

| Tool | Requirement |
|---|---|
| Countdown Planner | Any modern browser. Nothing else. |
| Ops Tracker (browser mode) | Any modern browser. Nothing else. |
| Ops Tracker (Docker mode) | [Docker Desktop](https://www.docker.com/products/docker-desktop/) (free) |

---

## Also available on EventHive

These tools are part of [EventHive](https://eventhive.io) — the free platform for event industry professionals. On EventHive, your data is stored securely in the cloud, accessible from any device, with Erleah AI to help you plan and optimise.

The standalone versions here are identical in features — the only differences are:
- Data storage is local (browser or `db.json`) instead of cloud
- The AI assistant (Erleah) is not available

---

## Contributing

PRs welcome. Tools live in their own folders — each is a standalone `index.html` with no build step required.

---

*MIT License — free to use, modify, and distribute*
