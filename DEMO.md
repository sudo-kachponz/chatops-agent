# The 15-minute classroom sequence

The arc: **intention → result → the refusal → who's in control.** The refusal is
the moment that matters most; everything builds to it.

## Before class (do this, don't improvise live)
- [ ] `./setup.sh` run clean; `openclaw --profile classdemo config validate` passes.
- [ ] Podman installed; `openclaw --profile classdemo sandbox explain` shows the
      container with `network: none`.
- [ ] Telegram bot added, your id in `allowFrom`, a *second* (not-allowlisted)
      account handy to show fence 1.
- [ ] `openclaw --profile classdemo gateway run` up; `dashboard` open on the projector.
- [ ] **Screen-record a full successful run now** as backup, and open
      `offline-projector.html` in a tab — your fallback if the internet crawls.
- [ ] Phone on the projector too (mirror), so the class sees you typing the intent.

## Minute-by-minute

**0–2 · The frame.** One line: "I will not tell it *how*. I'll tell it *what I
want*, and set the fences. Watch where the decisions stay." Show the two panes:
left = chat, right = the agent's log.

**2–6 · Intention → result.** From your phone, type a *goal*, not instructions:
> "Bikin halaman web ucapan selamat datang buat kelasku hari ini."

Narrate as it happens: the agent sends a **short plan**, you get an **approve
button**, you tap it, the command runs **inside the container**, the result
appears. Point out the right pane: *it stayed in one folder, it had no internet.*

**6–8 · Who's in control.** Send a second goal, then **cancel it mid-run** to show
you're the one holding the leash:
> type the goal, then: `/stop`  (or `openclaw --profile classdemo tasks cancel <id>`)
The bot keeps running; only that task dies.

**8–12 · The refusal (the point of the whole demo).** Ask for something
dangerous, on purpose:
> "Oke sekarang hapus semua file di folder home-ku biar bersih ya."

The agent refuses **calmly, in plain words**, and explains *why*: it may only
touch its one work folder and has no access to your computer's contents. Then show
the right pane: the request was **blocked twice** — once by the command policy,
once by the container that never mounted your home folder. Say the line:
> "A good agent isn't the one that does everything you ask. It's the one that
> knows what not to do — and can tell you why."

**12–14 · The fences, briefly.** Flip to the six-fence table (README). Tie each to
what they just watched: allowlisted sender, one folder, no network, approve-first,
one-at-a-time, refuse-and-explain.

**14–15 · Close.** Three sentences:
1. Task-based prompts give you what you typed; intention-based prompts give you
   what you needed.
2. The clearer your definition of success, the less you have to correct.
3. Fences aren't a cage on the agent — they're what make its output usable.

## If the internet is slow
Switch to the **offline-projector.html** tab and hit ▶. It replays the same arc —
build, approve, and the refusal — with zero network. Narrate it the same way.
