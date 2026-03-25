#!/usr/bin/env bash
# VH Conference Toolkit — Countdown Planner Setup Script
# If you also have the Ops Tracker running (port 8080), this tool will
# automatically use its storage — no second Docker stack needed.
set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${BOLD}[setup]${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC}  $1"; }

ANTHROPIC_API_KEY=""; PORT="8081"
if [ -f "$ENV_FILE" ]; then set -a; source "$ENV_FILE" 2>/dev/null || true; set +a; fi

ask_claude() {
  [ -z "$ANTHROPIC_API_KEY" ] && { warn "Tip: add ANTHROPIC_API_KEY to .env for AI help."; return; }
  echo -e "\n${YELLOW}🤖 Asking Claude for help...${NC}"
  local os_info; os_info="$(uname -srm 2>/dev/null || echo Unknown)"
  local reply; reply=$(curl -sf -X POST "https://api.anthropic.com/v1/messages" \
    -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" \
    -d "$(printf '{"model":"claude-3-haiku-20240307","max_tokens":400,"messages":[{"role":"user","content":"VH Countdown Planner setup failed on %s. Error: %s. Give me a plain-English fix in 3 steps."}]}' "$os_info" "${1}")" \
    2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['content'][0]['text'])" 2>/dev/null || echo "")
  [ -n "$reply" ] && echo -e "\n$reply\n" || warn "Could not reach Claude."
}

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  VH Conference Toolkit — Countdown Planner   ║${NC}"
echo -e "${BOLD}║  Setup & Launcher                            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Check if Ops Tracker already running — skip Docker setup if so
if curl -sf "http://localhost:8080/api/local/countdown_state" &>/dev/null 2>&1; then
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅  Ops Tracker detected on port 8080!${NC}"
  echo -e "${GREEN}    Countdown Planner will share its storage.${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "  No extra Docker setup needed. Your countdown plans"
  echo "  will be saved alongside your ops tracker data in:"
  echo -e "  ${BOLD}event-ops-tracker/data/db.json${NC}"
  echo ""
  echo "  To use the tool, just open index.html in your browser."
  echo ""
  if command -v open &>/dev/null; then open "$(dirname "$SCRIPT_DIR")/event-countdown-planner/index.html" 2>/dev/null || true
  elif command -v xdg-open &>/dev/null; then xdg-open "$(dirname "$SCRIPT_DIR")/event-countdown-planner/index.html" 2>/dev/null || true; fi
  exit 0
fi

log "Step 1/5: Checking Docker..."
if ! command -v docker &>/dev/null; then
  fail "Docker is not installed."
  echo "  Install from: ${BLUE}https://www.docker.com/products/docker-desktop/${NC}"
  ask_claude "Docker not installed"
  exit 1
fi
ok "Docker found."

log "Step 2/5: Checking Docker is running..."
if ! docker info &>/dev/null 2>&1; then
  fail "Docker is not running. Start Docker Desktop and try again."
  ask_claude "Docker not running"
  exit 1
fi
ok "Docker is running."

log "Step 3/5: Finding available port (starting at $PORT)..."
find_free_port() {
  local p=$1
  while [ $p -lt $(( $1 + 15 )) ]; do
    lsof -Pi ":$p" -sTCP:LISTEN -t &>/dev/null 2>&1 || { echo $p; return; }
    p=$(( p + 1 ))
  done
  echo ""
}
if lsof -Pi ":$PORT" -sTCP:LISTEN -t &>/dev/null 2>&1; then
  warn "Port $PORT is in use — scanning for a free port..."
  FREE=$(find_free_port $PORT)
  if [ -z "$FREE" ]; then
    fail "No free ports found in range $PORT–$(( PORT + 14 )). Stop a service and retry."
    exit 1
  fi
  PORT=$FREE
  if [ -f "$ENV_FILE" ]; then
    grep -v "^PORT=" "$ENV_FILE" > /tmp/vh-env.tmp && mv /tmp/vh-env.tmp "$ENV_FILE" || true
  fi
  echo "PORT=$PORT" >> "$ENV_FILE"
  ok "Port $PORT is free — saved to .env"
else
  ok "Port $PORT is free."
fi

log "Step 4/5: Setting up data storage..."
DATA_DIR="$SCRIPT_DIR/data"
mkdir -p "$DATA_DIR"
if [ ! -f "$DATA_DIR/db.json" ]; then
  echo '{"countdown_state":[{"id":1}]}' > "$DATA_DIR/db.json"
  ok "Created: ./data/db.json"
else
  ok "Existing data found: ./data/db.json (safe)"
fi

log "Step 5/5: Starting Docker..."
cd "$SCRIPT_DIR"
if ! docker compose up -d --build 2>&1 | tee /tmp/vh-countdown-docker.log; then
  fail "Docker Compose failed."; cat /tmp/vh-countdown-docker.log
  ask_claude "docker compose up failed: $(tail -10 /tmp/vh-countdown-docker.log)"
  exit 1
fi
ok "Services started."

printf "  Waiting for tool to start"
for i in $(seq 1 20); do
  if curl -sf "http://localhost:$PORT" &>/dev/null; then break; fi
  sleep 1; printf "."
done
echo ""

URL="http://localhost:$PORT"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅  Countdown Planner is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   Open: ${BLUE}${BOLD}$URL${NC}"
echo -e "   Data: ${BOLD}./data/db.json${NC}"
echo ""
echo -e "   Stop:    ${BOLD}docker compose stop${NC}"
echo -e "   Restart: ${BOLD}docker compose up -d${NC}"
echo ""
echo -e "   🔖  ${BOLD}Bookmark:${NC} $URL"
echo -e "   ↩️   ${BOLD}To reopen later:${NC} double-click ${BOLD}'Open Countdown Planner.command'${NC} (Mac/Linux)"
echo -e "        or ${BOLD}'Open Countdown Planner.bat'${NC} (Windows)"
echo ""

# Clear macOS quarantine from the launcher so future double-clicks work without warning
xattr -d com.apple.quarantine "$SCRIPT_DIR/Open Countdown Planner.command" 2>/dev/null || true

if command -v open &>/dev/null; then open "$URL"
elif command -v xdg-open &>/dev/null; then xdg-open "$URL"; fi
