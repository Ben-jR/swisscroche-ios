# Published block list

The app fetches its block list from a public URL so new blocking rules can reach
users without shipping a new App Store build.

## Single source of truth

There is **one** list file: [`../swisscroche/Resources/SwissList.json`](../swisscroche/Resources/SwissList.json).

The same file is bundled inside the app *and* served publicly. Do not create a
second copy — the bundled list is the offline fallback, and the two drifting
apart would be silently confusing.

## Hosting (Cloudflare Pages)

Connect this repository as a Cloudflare Pages project:

| Setting | Value |
|---|---|
| Framework preset | None |
| Build command | *(leave empty)* |
| Build output directory | `swisscroche/Resources` |

That serves the file at `https://<project>.pages.dev/SwissList.json`, which is
what `AppConstants.remoteListURL` points at. Change that constant if the project
name or a custom domain differs.

> ⚠️ Everything in `swisscroche/Resources/` becomes publicly downloadable.
> Keep only the block list there.

## Publishing an update

1. Edit `swisscroche/Resources/SwissList.json`
2. **Bump `version` to today's date** (`YYYY-MM-DD`) — the app compares versions
   to decide whether to apply a list, so an unchanged version is ignored
3. Commit and push — Cloudflare Pages redeploys automatically

Devices pick it up within 24 hours (`AppConstants.listDownloadInterval`).

## Format

```json
{
  "version": "2026-08-07",
  "name": "Liste Suisse (BAKOM 090x)",
  "patterns": [
    { "name": "BAKOM 0900 – Services à valeur ajoutée", "action": "block", "pattern": "41900######" }
  ]
}
```

- `version` — ISO date, compared numerically to decide which list is newer
- `action` — `block` or `identify`
- `pattern` — international format **without** the leading `+`, with `#` as a
  trailing wildcard. Each `#` multiplies the covered numbers by ten, so
  `41900######` covers one million numbers.

## Safety rules

The client refuses a list that is empty or has no version, so a truncated upload
cannot wipe every blocking rule — it keeps the previous one. Two consequences:

- **You cannot ship an empty list to clear everyone's rules.** That is deliberate.
- A malformed file leaves devices on their cached or bundled list, so a bad
  deploy degrades quietly instead of breaking call blocking.

Keep the total number of covered numbers reasonable: CallKit holds a finite
number of entries and every pattern is expanded and pushed to the system in
chunks of 10,000.
