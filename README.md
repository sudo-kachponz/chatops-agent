# ChatOps class demo — intention in, result out

Type one sentence from your phone (Telegram). A coding agent carries it out on
your machine, inside a locked-down container, and you watch it live on the
projector. The point of the demo is not "look, it codes" — it's that a good
agent **knows when to refuse** and keeps the important decisions with you.

The executor is **OpenClaw**. This repo is the *configuration + teaching
material* that turns a stock OpenClaw install into a safe classroom demo. It
runs on an **isolated profile** (`~/.openclaw-classdemo`) and never touches your
real OpenClaw gateway.

## Prerequisites
- `openclaw` on your PATH (`openclaw --version`) — already here.
- **Podman** (rootless) for the sandbox container:
  `sudo apt update && sudo apt install -y podman`
  (This OpenClaw build only has a "docker" sandbox backend, so `setup.sh`
  drops a tiny `docker`→`podman` shim in `~/.local/bin` and builds the
  `openclaw-sandbox:bookworm-slim` image on first run — a few minutes, one-time.)
- A **Telegram bot token** from [@BotFather](https://t.me/botfather) — use a bot
  that is *not* your personal account.
- A model provider already authenticated in OpenClaw (`openclaw models status`).

## Setup (under 10 minutes)
```bash
./setup.sh                                   # applies all hardening, idempotent
openclaw --profile classdemo channels add --channel telegram   # paste token when asked
OPERATOR_TG_ID=<your-numeric-id> ./setup.sh  # bind + allowlist your id (from @userinfobot)
```
`setup.sh` applies the config in `config.classdemo.json5`, sets the exec-approval
policy, installs the agent persona (`AGENTS.md`), and prints the effective
security posture at the end. Re-run it any time; it's safe.

## Run it
```bash
openclaw --profile classdemo gateway run      # start the demo gateway
openclaw --profile classdemo dashboard         # projector view (chat + live log)
# local dry-run without a phone:
openclaw --profile classdemo agent --local -m "bikin halaman selamat datang"
```

## The six fences (and where each lives)
| # | Fence | How |
|---|-------|-----|
| 1 | Only registered senders | `channels.telegram.dmPolicy: allowlist` + `allowFrom` |
| 2 | One work folder, no escape | sandbox `workspaceAccess: rw`, container FS boundary |
| 3 | Secrets never leak | OpenClaw SecretRef + sentinels + log redaction |
| 4 | Approve every shell command | `exec-policy … --ask always` → Telegram buttons |
| 5 | Time limit + one task at a time | `timeoutSeconds` + `maxConcurrent: 1` |
| 6 | Refuse destructive/exfil | `security: allowlist` + sandbox `network: none` + persona |

Full reasoning, including the honest gaps, is in **decisions.md**.

## If the class internet is slow
Open **offline-projector.html** in any browser — a canned successful run
(including the refusal moment) that needs no network. See **DEMO.md**.

## Troubleshooting
- **Writes fail with "permission denied" in /workspace** — rootless Podman maps
  your host user to container-root, so the sandbox runs as `user: "0:0"` (already
  set in the config). If you change any `sandbox.*` setting, the existing
  container isn't rebuilt automatically (and `openclaw sandbox recreate` can
  crash on this build), so drop it manually: `podman rm -f $(podman ps -aq --filter name=openclaw-sbx)`.
- **"Sandbox backend podman is not registered"** — this build only has the
  `docker` backend; the `docker`→`podman` shim from `setup.sh` handles it.

## Files
- `config.classdemo.json5` — the hardening config (source of truth, commented)
- `AGENTS.md` — the agent's operating + refusal instructions
- `setup.sh` — idempotent one-command setup
- `offline-projector.html` — slow-internet backup projector view
- `decisions.md` — why each choice was made (for non-programmers)
- `WHATSAPP.md` — Telegram vs WhatsApp, official vs unofficial
- `DEMO.md` — the 15-minute classroom sequence
