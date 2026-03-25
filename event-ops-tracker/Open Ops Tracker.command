#!/usr/bin/env bash
# Open Ops Tracker — double-click this to reopen the app
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PORT=8080; if [ -f "$SCRIPT_DIR/.env" ]; then source "$SCRIPT_DIR/.env" 2>/dev/null || true; fi
URL="http://localhost:${PORT:-8080}"

# Already running?
if curl -sf "$URL" &>/dev/null 2>&1; then
    echo "✅ Ops Tracker already running — opening browser..."
    open "$URL" 2>/dev/null || xdg-open "$URL" 2>/dev/null || true
    exit 0
fi

# Docker Desktop running?
if ! docker info &>/dev/null 2>&1; then
    echo "⚙  Docker Desktop isn't running. Starting it..."
    open -a "Docker" 2>/dev/null || true
    for i in $(seq 1 30); do
        docker info &>/dev/null 2>&1 && break
        sleep 2; printf "."
    done
    echo ""
fi

echo "🚀 Starting Ops Tracker Docker stack..."
cd "$SCRIPT_DIR" && docker compose up -d

printf "   Waiting"
for i in $(seq 1 20); do
    curl -sf "$URL" &>/dev/null && break
    sleep 1; printf "."
done
echo ""

echo "✅ Ops Tracker is live at $URL"
open "$URL" 2>/dev/null || xdg-open "$URL" 2>/dev/null || true
