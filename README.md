# ClownWord Desert

ClownWord Desert is a 2D open-world educational browser game where players explore a desert, survive clown hordes, and defeat enemies by correctly spelling sight words.

Circus tents continuously release clown villains. Correct spelling removes nearby clowns, while spelling close to a circus tent gradually seals it. Seal every tent before losing all your hearts to save the desert.

## Features

- Large scrolling 2D desert world
- Circus tents that release clown hordes
- Sight-word spelling combat
- Five vocabulary difficulty levels
- Tent-sealing objectives
- Health and combo systems
- Minimap showing tents and player location
- Particle effects and screen shake
- Synthesized sound effects
- Offline browser support
- Linux desktop application installer
- Linux application-menu launcher
- Linux desktop shortcut
- Linux uninstaller
- No external libraries or game engine required

## Sight-word levels

- Pre-K / Kindergarten
- Grade 1
- Grade 2
- Grade 3+
- Mixed Challenge

## Controls

| Action | Control |
|---|---|
| Move | Arrow keys |
| Sprint | Hold `Shift` |
| Enter spelling letters | Letter keys |
| Remove a typed letter | `Backspace` |
| Cast spelling spell | `Enter` |
| Toggle sound | Speaker button |

Letter keys are reserved entirely for spelling. Words containing `W`, `A`, `S`, or `D`, such as `was`, `as`, `said`, and `down`, do not conflict with movement.

## Gameplay

1. Select a sight-word difficulty.
2. Enter the desert.
3. Move toward an active striped circus tent.
4. Type the sight word displayed at the bottom of the screen.
5. Press `Enter` to cast the spelling spell.
6. Correct answers remove nearby clowns.
7. Correct answers near a tent increase its seal progress.
8. Incorrect answers summon another angry clown.
9. Seal all eight circus tents to win.

A ten-word spelling combo restores one heart when the player is below maximum health.

## Install as a Linux desktop application

Clone the repository:

```bash
git clone https://github.com/iamrichmack111/clownword-desert.git
cd clownword-desert
```

Run the installer:

```bash
chmod +x install.sh
./install.sh
```

After installation, launch **ClownWord Desert** from the Games or Education section of your Linux application menu.

You can also launch it from the terminal:

```bash
clownword-desert
```

The installer places the application files in:

```text
~/.local/share/clownword-desert
```

The command-line launcher is installed at:

```text
~/.local/bin/clownword-desert
```

The application menu entry is installed at:

```text
~/.local/share/applications/clownword-desert.desktop
```

When a `~/Desktop` folder exists, the installer also creates a desktop shortcut.

## Uninstall

Run:

```bash
clownword-desert-uninstall
```

You can also run the uninstaller from the repository folder:

```bash
./uninstall.sh
```

The uninstaller removes:

- Installed game files
- Browser application profile
- Application-menu entry
- Desktop shortcut
- Command-line launcher
- Uninstaller command

It does not delete the cloned Git repository.

## Play without installing

Open `index.html` directly in a modern browser.

You may also start a local web server:

```bash
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080
```

## Project structure

```text
clownword-desert/
├── index.html
├── install.sh
├── uninstall.sh
├── icon.svg
├── manifest.webmanifest
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── README.md
```

## Technology

ClownWord Desert uses:

- HTML5
- CSS
- JavaScript
- Canvas 2D API
- Web Audio API
- `requestAnimationFrame`
- Linux desktop entry files

The graphics, world, player, enemies, tents, particles, props, minimap, interface, and sound effects are generated without external assets or JavaScript frameworks.

## Customize the sight words

Open `index.html` and locate the `WORDS` object:

```javascript
const WORDS = {
  preK: [
    "a",
    "and",
    "away"
  ],

  grade1: [
    "after",
    "again",
    "any"
  ]
};
```

Add lowercase words to the appropriate list.

## Customize difficulty

Difficulty-related settings inside `index.html` include:

- `player.maxHearts`
- `player.speed`
- Tent seal requirements
- Clown movement speed
- Tent spawn timers
- Maximum active clown count
- Number of clowns removed per correct word

## Releases

### v1.1.0

- Added Linux installer
- Added Linux uninstaller
- Added desktop application launcher
- Added application-menu entry
- Added desktop shortcut support
- Fixed spelling conflicts with movement controls

### v1.0.0

- Initial playable release
- Added scrolling desert world
- Added circus tents and clown hordes
- Added sight-word spelling combat
- Added five word levels
- Added tent sealing and win conditions
- Added health, combo, minimap, sound, and visual effects

## Repository

GitHub:

```text
https://github.com/iamrichmack111/clownword-desert
```

Releases:

```text
https://github.com/iamrichmack111/clownword-desert/releases
```

## License

ClownWord Desert is released under the MIT License.

## Author

Created by Richmack as part of the Richmack educational game portfolio.
