# Free Stable Purchases

Buy oxen and horses from stables and hitching posts for **zero net regional wealth**.

The mod credits the current purchase price when you click, runs the game's normal purchase, then removes any unused credit. The normal price remains visible in the tooltip. Insufficient wealth no longer blocks these two purchases; capacity, monthly cooldowns, and other requirements still apply.

Other animals, upgrades, and normal livestock trading are unchanged. This is a Lua-only UE4SS mod: no DLLs, external helpers, or executable patches.

## Requirements

- Manor Lords. Verified with **0.8.117**.
- A Manor Lords-compatible [UE4SS installation](https://github.com/UE4SS-RE/RE-UE4SS/releases). Verified with **UE4SS 3.0.1**.

## Install

### Vortex

Install the [Manor Lords Vortex extension](https://www.nexusmods.com/site/mods/868) and UE4SS first. Install the packaged ZIP through Vortex, enable it, and deploy. If asked for a mod type, choose **UE4SS Scripts**.

### Manual

Extract the packaged ZIP into:

```text
<Manor Lords>/ManorLords/Binaries/Win64/ue4ss/Mods/
```

The result must be:

```text
Mods/
  FreeOxenAndHorses/
    enabled.txt
    VERSION
    Scripts/
      main.lua
```

Restart the game. The empty `enabled.txt` enables the mod automatically.

## Remove

Close the game, remove `FreeOxenAndHorses` from the UE4SS Mods directory, and restart. Animals already purchased remain in your settlement.

## Download a package

Open [Actions](https://github.com/RillonDodgers/manor-lords-free-stable-purchases/actions), select a successful **Package mod** run, and download its `FreeOxenAndHorses-<version>.zip` artifact. Use that ZIP directly for Nexus Mods, Vortex, or manual installation.

## Version and releases

Edit the root `VERSION` file to set the mod version. It is the single source for the mod's `FreeOxenAndHorses.version` value, startup log, ZIP filename, Actions artifact, Git tag, and GitHub release.

Push a `VERSION` change to `main` to build the ZIP and publish a matching release automatically. For example, setting it to `1.0.1` produces `FreeOxenAndHorses-1.0.1.zip` and release/tag `v1.0.1`. Versions such as `1.0.1-beta.1` create prereleases. There is no separate workflow version input or manual tagging step.

Manual workflow runs package the current `VERSION`. Existing releases are preserved; bump `VERSION` to publish a new release. Ordinary code or README commits do not publish a release until the version changes.

The same ZIP is uploaded as the Actions artifact and release asset. It contains the three mod files shown above, without an extra ZIP wrapper. Published packages are also available under [Releases](https://github.com/RillonDodgers/manor-lords-free-stable-purchases/releases).

The repository root is the mod folder: `Scripts/`, `enabled.txt`, and `VERSION`, alongside this README and `.github/`. The packaging script at `.github/scripts/package.py` adds the `FreeOxenAndHorses/` install folder to the ZIP.

To package locally:

```sh
python .github/scripts/package.py --output-dir /path/to/output
```

## Troubleshooting

Check `ue4ss/UE4SS.log` for `[FreeOxenAndHorses] Hook ready` messages. Successful orders log their normal price and before/after regional wealth. A full stable or active monthly cooldown still prevents an order.
