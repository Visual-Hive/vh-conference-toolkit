#!/usr/bin/env bash
# Open Countdown Planner — double-click this to reopen the app
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Self-heal: remove macOS quarantine so future double-clicks work without a security warning
xattr -d com.apple.quarantine "$0" 2>/dev/null || true


# If Ops Tracker running on 8080, that already has our data
if curl -sf "http://localhost:8080/api/local/countdown_state" &>/dev/null 2>&1; then
    echo "✅ Data is in Ops Tracker storage — opening index.html"
    open "$SCRIPT_DIR/index.html" 2>/dev/null || xdg-open "$SCRIPT_DIR/index.html" 2>/dev/null || true
    exit 0
fi

PORT=8081; if [ -f "$SCRIPT_DIR/.env" ]; then source "$SCRIPT_DIR/.env" 2>/dev/null || true; fi
URL="http://localhost:${PORT:-8081}"

if curl -sf "$URL" &>/dev/null 2>&1; then
    echo "✅ Countdown Planner already running — opening browser..."
    open "$URL" 2>/dev/null || xdg-open "$URL" 2>/dev/null || true
    exit 0
fi

if ! docker info &>/dev/null 2>&1; then
    echo "⚙  Docker Desktop isn't running. Starting it..."
    open -a "Docker" 2>/dev/null || true
    for i in $(seq 1 30); do
        docker info &>/dev/null 2>&1 && break
        sleep 2; printf "."
    done
    echo ""
fi

echo "🚀 Starting Countdown Planner Docker stack..."
cd "$SCRIPT_DIR" && docker compose up -d

printf "   Waiting"
for i in $(seq 1 20); do
    curl -sf "$URL" &>/dev/null && break
    sleep 1; printf "."
done
echo ""

echo "✅ Countdown Planner is live at $URL"
open "$URL" 2>/dev/null || xdg-open "$URL" 2>/dev/null || true
