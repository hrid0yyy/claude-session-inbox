# claude-session-inbox

Send prompts into a running **Claude Code** session from outside it — from another agent, a script, a cron job, or any service that can write a file.

No API key or extra credit is used: delivery happens inside the session you already have open.

---

## How it works

```
other agent / service                Claude Code session
        │                                    │
        │  writes inbox/q1.txt               │  Monitor tool runs inbox-watcher.sh
        ▼                                    │
   ┌─────────┐   watcher sees new file  ┌────┴─────┐
   │  inbox/ │ ───────────────────────▶ │ stdout:  │ ──▶ notification in session
   └─────────┘   prints 1 line, moves   │ "INBOX…" │     → Claude reads & acts
        │        file to inbox/sent/    └──────────┘
```

1. `inbox-watcher.sh` polls a folder every second.
2. For each new `.txt` file it prints one line: `INBOX <filename>: <contents>`, then moves the file to `inbox/sent/` (timestamped) so it is never processed twice.
3. Claude Code's **Monitor** tool turns every stdout line of a script into a notification inside the session, so Claude is woken up and sees the message.

---

## Usage

1. Clone this repo somewhere permanent, e.g. `C:\tools\claude-session-inbox`.
2. In your Claude Code session, ask Claude:

   > Monitor `bash C:/tools/claude-session-inbox/inbox-watcher.sh C:/tools/claude-session-inbox/inbox` with the maximum timeout, and re-arm it whenever it expires.

3. From anywhere, drop a message:

   Bash:

   ```bash
   echo "who is messi" > C:/tools/claude-session-inbox/inbox/q1.txt
   ```

   PowerShell:

   ```powershell
   "who is messi" | Set-Content C:\tools\claude-session-inbox\inbox\q1.txt
   ```

   Python (from another agent):

   ```python
   from pathlib import Path; import time
   Path(r"C:\tools\claude-session-inbox\inbox", f"{int(time.time())}.txt").write_text("who is messi")
   ```

Within ~1 second the session receives `INBOX q1.txt: who is messi`.

The inbox folder defaults to `./inbox` if no argument is given. Requires `bash` (Git Bash on Windows).

---

## Using it properly

- **Use unique filenames** (timestamps / UUIDs). Two writers using the same name can overwrite each other.
- **Write atomically if messages are large**: write to `msg.tmp`, then rename to `msg.txt`. The watcher only reads `*.txt` and waits 300 ms before reading.
- **One message per file.** Newlines are flattened to spaces in the notification.
- **Monitor expires** (max 30 min per arm). Ask Claude to re-arm on expiry for long watches. Files dropped while it is off are not lost — they are picked up on the next start.
- **The session must be running.** If the app or session is closed, nothing listens; files wait in `inbox/` until the watcher is started again.
- **Security:** anyone who can write to the inbox can send Claude text. Claude treats inbox content as *data*, not as your own commands — it will answer questions and do harmless work, but should confirm with you before side-effecting actions (sending, deleting, purchasing, running unknown code). Keep the inbox in a folder only you and your trusted agents can write to.
