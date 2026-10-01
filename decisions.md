# Decision notes

Written for someone who is *not* a programmer. Each note says what was chosen,
what the alternative was, and why the alternative was rejected. These are the
decisions a human made — the kind an AI agent should surface, not hide.

## 1. We used OpenClaw instead of building a bot from scratch
**Chosen:** configure the existing OpenClaw tool. **Alternative:** write our own
Telegram bot and glue a coding agent onto it. **Why not:** the hard parts —
checking who's allowed to talk, asking permission before acting, hiding secrets,
boxing the agent into a container — already exist in OpenClaw, tested. Rewriting
them would be more code *and* less safe. The lazy choice here is also the safer
choice.

## 2. A separate, throwaway "profile" — not your real setup
**Chosen:** everything runs under an isolated profile (`~/.openclaw-classdemo`).
**Alternative:** reuse the OpenClaw you already run day-to-day. **Why not:** a
classroom demo pokes at dangerous settings on purpose. Keeping it in its own
sandbox-of-config means a mistake on stage can't disturb your real assistant,
and you can delete the whole thing afterward with one folder.

## 3. The agent gets ONE folder and NO internet
**Chosen:** the agent runs inside a container that can only see a single work
folder and has its network switched completely off. **Alternative:** let it run
directly on the laptop. **Why not:** if an instruction (or a trick) tells it to
read your private files or phone something home, there is simply nowhere to go —
the walls are real, not just a polite request. Your home folder and your saved
passwords are never even mounted into the box.

## 4. It asks before every command, and you answer from your phone
**Chosen:** every shell command pauses and waits for your tap in Telegram.
**Alternative:** let it run freely and trust it. **Why not:** the whole lesson is
that the human keeps the final say. A tap to approve is cheap; an un-asked
destructive command is not.

## 5. Dangerous requests are refused *and explained*
**Chosen:** two layers. The agent is told, in plain language, to refuse things
that would delete data, leak secrets, or escape its folder — and to say why. And
underneath, the command allowlist + the sandbox make the refusal real even if the
agent were somehow talked into trying. **Alternative:** rely on the agent's good
manners alone. **Why not:** manners can be argued with; walls cannot. We keep
both so the class *sees* the reasoning and *trusts* the enforcement.

## 6. Telegram for the demo, not WhatsApp
**Chosen:** Telegram. **Alternative:** WhatsApp. **Why not now:** OpenClaw only
talks to WhatsApp through an *unofficial* back door that can get a number banned
and needs babysitting. Telegram's bot system is official and stable. Swapping to
WhatsApp later is a one-line change — see `WHATSAPP.md` for the full comparison.

## The honest gaps (what is *not* perfect)
A good agent reports what it couldn't fully deliver. Three things:

- **File edits aren't approved one-by-one.** OpenClaw asks before every *shell
  command*, but not before every single *file write*. We close this by locking
  the agent inside the container: any file it writes can only land in its one
  work folder, so an un-approved write can't reach anything that matters.
- **"No internet except what I allow" is really "the agent has no internet at
  all."** The agent's box has networking switched off entirely. The *gateway*
  (the part that talks to the AI model) still needs the internet; this OpenClaw
  version has no built-in per-website allowlist for it, so if you want that extra
  fence you'd point the gateway at a filtering proxy (noted in the README).
- **"One task at a time" relies on using one agent session.** There's no single
  global switch; we get the behaviour by routing everything to one agent whose
  turns run one after another, plus a setting that stops it spawning helpers in
  parallel.
- **The approval rulebook is shared across the whole machine.** OpenClaw keeps
  one exec-approvals file per machine, not per profile — so naively "setting the
  policy for the demo" silently changes your real assistant too (we hit exactly
  this while building, and reverted it). We avoid it by putting the strict policy
  in the *demo profile's own config* instead; because the effective rule is
  always the stricter of (demo config, machine default), the demo is locked down
  while your everyday assistant is left exactly as it was.

## A note on versions
OpenClaw's public documentation was ahead of the version installed here
(2026.5.28). Rather than trust the docs, every setting in `config.classdemo.json5`
was checked against the *installed* program's own configuration schema. Where the
docs described a feature this version doesn't have (a per-website egress
allowlist), we said so above instead of pretending.
