#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# One-command setup for the ChatOps class demo on an isolated OpenClaw profile.
# Idempotent: safe to run again. Goal: blank laptop -> running in < 10 minutes.
#
#   ./setup.sh
#
# What it does NOT do: touch your real ~/.openclaw gateway, or handle your bot
# token (you paste that into the guided `channels add` so it never hits argv or
# shell history). Everything lives under the throwaway profile ~/.openclaw-classdemo.
# ---------------------------------------------------------------------------
set -euo pipefail

PROFILE="classdemo"
OC() { openclaw --profile "$PROFILE" "$@"; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.openclaw-${PROFILE}"
WS="$STATE/workspace"

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }

# 0. Preflight -------------------------------------------------------------
command -v openclaw >/dev/null || { echo "openclaw not found on PATH"; exit 1; }
say "OpenClaw: $(openclaw --version 2>/dev/null | head -1)"

if command -v podman >/dev/null; then
  ok "Podman: $(podman --version)"
  # This OpenClaw version only registers the "docker" sandbox backend, and that
  # backend shells out to a `docker` CLI. Give it one that forwards to podman.
  if ! command -v docker >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    printf '#!/bin/sh\nexec podman "$@"\n' > "$HOME/.local/bin/docker"
    chmod +x "$HOME/.local/bin/docker"
    ok "Installed docker->podman shim at ~/.local/bin/docker"
    case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
      warn "~/.local/bin is not on PATH — add it so the gateway can find 'docker'";;
    esac
  fi
  # Rootless podman API socket (harmless if already enabled).
  systemctl --user enable --now podman.socket >/dev/null 2>&1 || true
  # The sandbox image is not bundled; build it once (a few minutes, needs network).
  if podman image exists openclaw-sandbox:bookworm-slim 2>/dev/null; then
    ok "Sandbox image present"
  else
    say "Building sandbox image openclaw-sandbox:bookworm-slim (one-time)…"
    docker build -t openclaw-sandbox:bookworm-slim - <<'DOCKERFILE'
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  bash ca-certificates curl git jq python3 ripgrep \
  && rm -rf /var/lib/apt/lists/*
RUN useradd --create-home --shell /bin/bash sandbox
USER sandbox
WORKDIR /home/sandbox
CMD ["sleep", "infinity"]
DOCKERFILE
    ok "Sandbox image built"
  fi
else
  warn "Podman NOT installed. The sandbox (requirement #7: isolated container,"
  warn "no home access, no egress) will NOT work until you install it:"
  warn "    sudo apt update && sudo apt install -y podman"
  warn "Continuing so the rest of the config is applied; fix this before the demo."
fi

# 1. Baseline profile ------------------------------------------------------
if openclaw --profile "$PROFILE" config file >/dev/null 2>&1; then
  ok "Profile '$PROFILE' already initialised ($STATE)"
else
  say "Initialising isolated profile '$PROFILE'"
  OC setup
fi

# 2. Agent workspace + persona/refusal instructions ------------------------
mkdir -p "$WS"
cp "$HERE/AGENTS.md" "$WS/AGENTS.md"
OC config set agents.defaults.workspace "$WS" >/dev/null
ok "Workspace at $WS (persona: AGENTS.md installed)"

# 3. Apply the hardening config (all six fences) ---------------------------
say "Validating hardening config"
OC config patch --file "$HERE/config.classdemo.json5" --dry-run
say "Applying hardening config"
OC config patch --file "$HERE/config.classdemo.json5"
ok "Config applied"

# 4. Exec approval policy -------------------------------------------------
#    The requested policy (allowlist + ask always + host=sandbox) lives in the
#    profile config applied in step 3. We deliberately do NOT run
#    `openclaw exec-policy set` or `approvals allowlist add`: those write the
#    node-global ~/.openclaw/exec-approvals.json, which is SHARED with your real
#    gateway. Effective = requested ∩ host (most-restrictive wins), so the
#    profile config alone gives classdemo allowlist+always while your real
#    gateway keeps its own policy untouched.
ok "Exec policy comes from profile config (no global approvals touched)"

# 6. Telegram channel (fence 1) -------------------------------------------
if OC channels status 2>/dev/null | grep -qi telegram; then
  ok "Telegram channel already added"
  OC agents bind --agent main --bind telegram:default >/dev/null 2>&1 || true
  if [[ -n "${OPERATOR_TG_ID:-}" ]]; then
    OC config set channels.telegram.allowFrom "[\"$OPERATOR_TG_ID\"]" --strict-json >/dev/null
    ok "allowFrom set to [$OPERATOR_TG_ID]"
  else
    warn "Set your Telegram numeric id (from @userinfobot):"
    warn "    OPERATOR_TG_ID=123456789 ./setup.sh   (or)"
    warn "    openclaw --profile $PROFILE config set channels.telegram.allowFrom '[\"123456789\"]' --strict-json"
  fi
else
  warn "Telegram not added yet. Run this ONE interactive step (token stays private):"
  warn "    openclaw --profile $PROFILE channels add --channel telegram"
  warn "then re-run ./setup.sh (optionally: OPERATOR_TG_ID=<your-id> ./setup.sh)"
fi

# 7. Validate + show the effective security posture ------------------------
say "Validating final config"
OC config validate
say "Effective sandbox policy:"; OC sandbox explain 2>/dev/null || warn "sandbox explain needs podman + a session"
say "Effective exec policy:";    OC exec-policy show 2>/dev/null || true

cat <<EOF

$(ok "Setup done.")
Next:
  1. (if skipped) install podman, then re-run ./setup.sh
  2. (if skipped) openclaw --profile $PROFILE channels add --channel telegram
  3. Start the demo gateway:   openclaw --profile $PROFILE gateway run
  4. Projector (Control UI):   openclaw --profile $PROFILE dashboard
  5. Local dry-run w/o chat:   openclaw --profile $PROFILE agent --local -m "your goal"
See DEMO.md for the 15-minute classroom sequence.
EOF
