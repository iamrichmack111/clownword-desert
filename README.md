# ClownWord Desert

[![Version](https://img.shields.io/badge/version-1.0.0-f4af39)](../../releases/tag/v1.0.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Made with JavaScript](https://img.shields.io/badge/JavaScript-Canvas-f7df1e?logo=javascript&logoColor=111)](index.html)
[![Play Online](https://img.shields.io/badge/Play-GitHub%20Pages-57c7ff)](https://iamrichmack111.github.io/clownword-desert/)

**ClownWord Desert** is a standalone 2D open-world educational browser game. Circus tents have appeared throughout a scrolling desert and continuously release clown hordes. Players survive by moving through the world and correctly spelling sight words. Correct answers remove clowns; spelling near a tent gradually seals it.

## Play online

**Live game:** https://iamrichmack111.github.io/clownword-desert/

GitHub Pages may take a few minutes to become available after the first publish.

## Highlights

- Large scrolling desert world
- Eight circus tents with escalating clown hordes
- Sight-word spelling as the combat system
- Five selectable word levels
- Tent-sealing objectives and a clear win condition
- Combo system with heart recovery
- Procedural Canvas artwork
- Web Audio sound effects with a mute control
- Minimap, health display, score tracking, particles, and screen shake
- No frameworks, external libraries, accounts, downloads, or internet connection required
- Desktop browser support and offline play

## Controls

| Action | Control |
|---|---|
| Move | Arrow keys |
| Sprint | Hold `Shift` while moving |
| Enter letters | Letter keys |
| Correct typed letters | `Backspace` |
| Cast the spelling spell | `Enter` |
| Toggle sound | Speaker button |

Letter keys are reserved entirely for spelling. Words such as `as`, `was`, `said`, and `down` therefore never conflict with movement.

## How to play

1. Select a sight-word level.
2. Enter the desert.
3. Use the arrow keys to move toward an active striped circus tent.
4. Type the displayed sight word and press `Enter`.
5. Correct spellings remove nearby clown villains.
6. Correct spellings made near a tent increase its seal progress.
7. Wrong spellings summon an additional angry clown.
8. Seal all eight tents before losing all five hearts.

Every ten-word combo restores one heart when the player is below maximum health.

## Sight-word levels

- Pre-K / Kindergarten
- Grade 1
- Grade 2
- Grade 3+
- Mixed Challenge

The included vocabulary is stored directly in `index.html`, making it straightforward to add custom lists.

## Run locally

No build step is required.

### Directly from the browser

Open `index.html` in Chrome, Firefox, Edge, or Safari.

### With a local server

```bash
python3 -m http.server 8080
```

Then open `http://localhost:8080`.

## Project structure

```text
clownword-desert/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── pull_request_template.md
├── .gitignore
├── .nojekyll
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── VERSION
├── icon.svg
├── index.html
├── manifest.webmanifest
└── publish_to_github.sh
```

## Technical design

The complete game is implemented with HTML, CSS, JavaScript, and the Canvas 2D API. The game loop uses `requestAnimationFrame`, while the world, camera, player, tents, enemies, particles, props, minimap, and HUD are rendered without external image assets. Simple synthesized effects are generated through the Web Audio API.

## Customize the game

### Add or change words

Find the `WORDS` object in `index.html`:

```javascript
const WORDS = {
  preK: ["a", "and", "away"],
  grade1: ["after", "again", "any"]
};
```

Add lowercase words to the desired list.

### Adjust difficulty

Useful values in `index.html` include:

- `player.maxHearts`
- `player.speed`
- each tent's `needed` seal count
- clown `speed`
- tent `spawnTimer`
- the maximum active clown count

## Publish with GitHub CLI

The included script initializes Git, creates the initial commit, creates tag `v1.0.0`, creates or updates the public GitHub repository, pushes `main` and the tag, configures topics and repository settings, creates a GitHub Release, and enables GitHub Pages.

```bash
chmod +x publish_to_github.sh
./publish_to_github.sh
```

Override the defaults when needed:

```bash
GITHUB_OWNER=obsidiandevcoder \
REPO_NAME=clownword-desert \
VERSION=v1.0.0 \
./publish_to_github.sh
```

## Roadmap

- Teacher-managed custom word lists
- Mobile touch controls and an on-screen keyboard
- Boss clowns and special tent types
- Multiple desert regions
- Progress saving
- Spoken-word accessibility mode
- Player profiles and classroom scoreboards
- Multiplayer spelling challenges

## Contributing

Bug reports and educational feature ideas are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Released under the [MIT License](LICENSE).

---

Created under the **Richmack** educational game portfolio.
