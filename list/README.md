# Published block list

The app fetches its block list from a public URL so new blocking rules can reach
users without shipping a new App Store build.

## Single source of truth

There is **one** list file: [`../swisscroche/Resources/SwissList.json`](../swisscroche/Resources/SwissList.json).

The same file is bundled inside the app *and* served publicly. Do not create a
second copy — the bundled list is the offline fallback, and the two drifting
apart would be silently confusing.

## Hosting (GitHub Pages)

GitHub Pages serves this repository from the `main` branch root, so the file is
published at the same path it has in the repo:

```
https://ben-jr.github.io/swisscroche-ios/swisscroche/Resources/SwissList.json
```

That is what `AppConstants.remoteListURL` points at. Pages is already enabled
(Settings → Pages, source `main` / `/`); nothing needs to be rebuilt by hand.

`raw.githubusercontent.com` serves the same file and needs no setup, but GitHub
states it is not a CDN and rate-limits it — not something to depend on from a
distributed app. Pages is backed by a CDN and is the supported way to serve
static files.

## Publishing an update

1. Edit `swisscroche/Resources/SwissList.json`
2. **Bump `version` to today's date** (`YYYY-MM-DD`) — the app compares versions
   to decide whether to apply a list, so an unchanged version is ignored
3. Commit and push — Pages redeploys automatically, usually within a minute

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
