# Telegram vs WhatsApp — and official vs unofficial

The brief asks: the chat channel must be swappable between Telegram and
WhatsApp *without changing the core of the system*, and for WhatsApp, to compare
the official and unofficial routes, state the risk of each, and recommend one.

## Swapping is a one-line change
In OpenClaw a channel is bound to an agent; the agent's logic doesn't change.
```bash
openclaw --profile classdemo agents bind --agent main --bind telegram:default
# later, instead:
openclaw --profile classdemo agents bind --agent main --bind whatsapp:default
```
The six fences (allowlist, sandbox, approvals, secrets, limits, refusal) all live
on the agent and the gateway, *not* on the channel — so they carry over
unchanged. That is the whole reason to let the tool own the channel layer.

## WhatsApp: two possible routes

### A. Official — WhatsApp Cloud API / Business API
- **What it is:** Meta's sanctioned API for businesses. Token-based, stable,
  allowed by the terms of service.
- **What it needs:** a Meta developer app, a registered business phone number,
  and (for real use) a reviewed WhatsApp Business account.
- **Risk:** low on the ban/stability front; the cost is setup friction and
  Meta's approval process.
- **Catch:** **OpenClaw does not support this route.** The docs are explicit —
  "there is no separate Twilio WhatsApp channel," and no Cloud/Business API path
  is offered.

### B. Unofficial — WhatsApp Web (Baileys), what OpenClaw actually uses
- **What it is:** OpenClaw drives WhatsApp by pretending to be the WhatsApp Web
  client (the Baileys library). You link it by scanning a QR code, exactly like
  WhatsApp Web in a browser.
- **What it needs:** the `@openclaw/whatsapp` package and a phone to scan the QR;
  `openclaw --profile classdemo channels login --channel whatsapp`.
- **Risk:** **real.** This is reverse-engineered, unofficial access. Automating a
  normal WhatsApp number this way can get it **banned**, and the link needs
  babysitting (QR re-logins, 408 timeouts, random disconnects). OpenClaw's docs
  call it "production-ready" and *do not warn about the ban risk* — so treat that
  framing with caution; the risk is genuine regardless of the label.

## Recommendation
**Use Telegram for the class demo.** It is official, token-based, stable, and its
inline approve/deny buttons are exactly what the "approve from your phone" moment
needs. It will not pick the wrong afternoon to get your number banned.

**If you must show WhatsApp:** use the unofficial Baileys route **only on a
throwaway number you are willing to lose**, link it before class (not live, QR
logins are flaky), and keep Telegram ready as the fallback. Do not use your
personal WhatsApp number.
