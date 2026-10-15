#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ Starting WS↔TCP proxy on port 3000..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PROXY_PORT=3000 bun run proxy & PROXY_PID=$!

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "▶ Starting production preview server on port 4173..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bun run preview --host 0.0.0.0 & PREVIEW_PID=$!
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🌐 Client ready → http://localhost:4173/online"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Monitoring both processes; if one goes down, kill the other and exit
monitor() {
  while true; do
    for pid in $PROXY_PID $PREVIEW_PID; do
      if ! kill -0 "$pid" 2>/dev/null; then
        echo "Process $pid went down - shutting down container"
        kill $PROXY_PID $PREVIEW_PID 2>/dev/null || true
        exit 1
      fi
    done
    sleep 2
  done
}

trap 'kill $PROXY_PID $PREVIEW_PID 2>/dev/null; exit 0' SIGTERM SIGINT

monitor
