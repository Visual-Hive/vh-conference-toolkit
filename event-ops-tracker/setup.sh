#!/usr/bin/env bash
# VH Conference Toolkit — Ops Tracker Setup Script
# Runs on Mac, Linux, and WSL on Windows.
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${BOLD}[setup]${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC}  $1"; }

# Load .env if present
ANTHROPIC_API_KEY=""
PORT="8080"
if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE" 2>/dev/null || true; set +a
fi

ask_claude() {
  local error_msg="$1"
  [ -z "$ANTHROPIC_API_KEY" ] && { warn "Tip: add ANTHROPIC_API_KEY to .env for AI-powered help."; return; }
  echo ""
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}🤖 Asking Claude for help...${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  local os_info; os_info="$(uname -srm 2>/dev/null || echo Unknown)"
  local payload; payload=$(printf '{"model":"claude-3-haiku-20240307","max_tokens":400,"messages":[{"role":"user","content":"VH Conference Toolkit setup failed on %s. Error: %s. Give me a plain-English fix in 3 steps or fewer."}]}' "$os_info" "$error_msg")
  local reply; reply=$(curl -sf -X POST "https://api.anthropic.com/v1/messages" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$payload" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['content'][0]['text'])" 2>/dev/null || echo "")
  [ -n "$reply" ] && echo -e "\n$reply\n" || warn "Could not reach Claude — check ANTHROPIC_API_KEY."
}

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  VH Conference Toolkit — Ops Tracker     ║${NC}"
echo -e "${BOLD}║  Setup & Launcher                        ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── Step 1: Docker installed? ────────────────────────────────────────────
log "Step 1/5: Checking Docker..."
if ! command -v docker &>/dev/null; then
  fail "Docker is not installed."
  echo ""
  echo "  Install Docker Desktop (free) from:"
  echo "  ${BLUE}https://www.docker.com/products/docker-desktop/${NC}"
  echo ""
  ask_claude "Docker not installed"
  exit 1
fi
ok "Docker found."

# ── Step 2: Docker running? ──────────────────────────────────────────────
log "Step 2/5: Checking Docker is running..."
if ! docker info &>/dev/null 2>&1; then
  fail "Docker is installed but not running."
  echo "  Start Docker Desktop and try again."
  echo "  (Look for the whale icon in your menu bar / system tray.)"
  ask_claude "Docker is installed but not running (docker info failed)"
  exit 1
fi
ok "Docker is running."

# ── Step 3: Port free? ───────────────────────────────────────────────────
log "Step 3/5: Checking port $PORT..."
if lsof -Pi ":$PORT" -sTCP:LISTEN -t &>/dev/null 2>&1; then
  BLOCKER=$(lsof -Pi ":$PORT" -sTCP:LISTEN 2>/dev/null | tail -1 || echo "unknown process")
  fail "Port $PORT is already in use: $BLOCKER"
  echo "  Stop that service, or set PORT=XXXX in .env to use a different port."
  ask_claude "Port $PORT is already in use. Process: $BLOCKER"
  exit 1
fi
ok "Port $PORT is free."

# ── Step 4: Data directory ───────────────────────────────────────────────
log "Step 4/5: Setting up data storage..."
DATA_DIR="$SCRIPT_DIR/data"
mkdir -p "$DATA_DIR"
if [ ! -f "$DATA_DIR/db.json" ]; then
  echo '{"ops_state":[{"id":1}]}' > "$DATA_DIR/db.json"
  ok "Created fresh data file: ./data/db.json"
else
  ok "Existing data found: ./data/db.json (your data is safe)"
fi

# ── Step 5: Start services ───────────────────────────────────────────────
log "Step 5/5: Starting Docker services..."
cd "$SCRIPT_DIR"
if ! docker compose up -d --build 2>&1 | tee /tmp/vh-docker.log; then
  DOCKER_ERR=$(tail -20 /tmp/vh-docker.log)
  fail "Docker Compose failed."
  echo ""
  cat /tmp/vh-docker.log
  ask_claude "docker compose up failed: $DOCKER_ERR"
  exit 1
fi
ok "Services started."

# ── Wait for ready ───────────────────────────────────────────────────────
printf "  Waiting for tool to start"
for i in $(seq 1 20); do
  if curl -sf "http://localhost:$PORT" &>/dev/null; then break; fi
  sleep 1; printf "."
done
echo ""

URL="http://localhost:$PORT"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅  Ops Tracker is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   Open: ${BLUE}${BOLD}$URL${NC}"
echo ""
echo -e "   📁 Your data: ${BOLD}./data/db.json${NC}"
echo "   This file survives Docker restarts, updates, and reinstalls."
echo "   Back it up by copying ./data/db.json anywhere safe."
echo ""
echo -e "   Stop:    ${BOLD}docker compose stop${NC}"
echo -e "   Restart: ${BOLD}docker compose up -d${NC}"
echo ""

# Auto-open browser
if command -v open &>/dev/null; then open "$URL"
elif command -v xdg-open &>/dev/null; then xdg-open "$URL"; fi
