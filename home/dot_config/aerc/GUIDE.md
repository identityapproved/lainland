# aerc quick guide

Reference for this config (Gmail account, kitty terminal). Reflects the binds in
`binds.conf` and filters in `aerc.conf`.

## Navigation & reading
- `j` / `k` — next / previous message
- `Enter` — open message
- `Tab` / `Shift+Tab` — next / previous tab (account, open message, composer)
- `Ctrl-j` / `Ctrl-k` — next / previous folder in the left sidebar
  (`:next-folder` / `:prev-folder`; the sidebar has no focus cursor, you drive it
  by command)
- `g` / `G` — first / last message (`:select 0` / `:select -1`)
- `q` — close the current tab (message view, composer, terminal)
- `Q` — quit aerc entirely (closing the last/root tab also quits)
- `:cf <folder>` — change folder, e.g. `:cf Inbox`, `:cf "[Gmail]/All Mail"`, `:cf "[Gmail]/Sent Mail"`

## Actions
Bound keys (work on the current message, or on all marked messages):
- `d` — mark read + move to `[Gmail]/Trash` (Gmail-correct delete)
- `e` — `:archive flat` (remove from inbox -> All Mail)
- `r` / `R` — mark read / unread

Commands:
- `:move <folder>` — move, e.g. `:move "[Gmail]/Trash"`
- `:reply` / `:reply -a` (reply-all) / `:forward`

Gmail caveat: the trash folder is usually `[Gmail]/Trash` but can be
`[Google Mail]/Trash` depending on account language. Confirm the exact name from
the sidebar (`:cf <Tab>` autocompletes) and update the `d` binds if it differs.

## Selecting multiple (bulk delete)
aerc marks messages rather than visual-selecting. Bound here:
- `v` — toggle mark on current (`:mark -t`)
- `V` — mark all (`:mark -a`)
- `:mark -T` — invert all marks
- `:mark -v` — visual range-mark mode; `j`/`k` extend the selection

Mark several with `v`, then any action operates on all marked at once:
`v v v` then `:delete <Enter>` removes all three.

## Copy / selection
`pager` is `bat --style=plain --color=always --paging=never`. `--paging=never`
means bat dumps colorized text straight into aerc's view pane with no `less`
underneath, so nothing captures the mouse and kitty's normal selection + copy
works. If colors ever look wrong, drop to `pager = cat` to confirm selection,
then add bat back.

## "Your client may not support HTML" stubs (Epic Games etc.)
That text is the `text/plain` alternative — a stub. The real content is in the
`text/html` part. This config sets `alternatives = text/html,text/plain` so aerc
prefers HTML and renders it via the bundled filter
(`/usr/libexec/aerc/filters/html`, which shells out to `w3m -dump`). To force a
message into a browser instead, use `:open`.

## Attachments / MIME parts
An open message shows the body plus a list of MIME parts. Step onto a part, then
act on it. Bound in `[view]`:
- `J` / `K` — next / previous part (`:next-part` / `:prev-part`)
- `o` — `:open` the selected part in its default app (xdg/mailcap association)
- `s` — `:save ~/Downloads/` the selected part
- `S` — `:save -a ~/Downloads/` saves all attachments at once

Other useful commands:
- `:pipe <cmd>` — pipe the part to a command, e.g. `:pipe chafa`
- `:save ~/dl/file.pdf` — save with an explicit name

Flow: open message -> `J` onto the attachment -> it renders inline (image filter)
or `o` to open externally / `s` to save.

Note: `:open` relies on the system default handler, so `xdg-utils` must be
installed and `XDG_*` associations set, or it does nothing. `:save` always works
regardless, so test with that first.

## Inline images
`image/* = kitten icat --align left --stdin` renders image attachments inline via
the kitty graphics protocol (requires running inside kitty). When you select an
image part with `J`, it renders right there in the view pane; if it does not,
force it with `:pipe kitten icat --align left --stdin`.

## Credentials
App password stored in the keyring; aerc reads it via
`secret-tool lookup service aerc account personal`. To (re)store:

```bash
secret-tool store --label='aerc gmail' service aerc account personal
```

Gmail requires IMAP enabled, 2-Step Verification on, and an app password (16
chars, entered with no spaces) — not the account password.
