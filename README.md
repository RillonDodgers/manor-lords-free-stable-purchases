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
    Scripts/
      main.lua
```

Restart the game. The empty `enabled.txt` enables the mod automatically.

## Remove

Close the game, remove `FreeOxenAndHorses` from the UE4SS Mods directory, and restart. Animals already purchased remain in your settlement.

## Download a package

Open [Actions](https://github.com/RillonDodgers/manor-lords-free-stable-purchases/actions), select a successful **Package mod** run, and download its `FreeStablePurchases-<version>.zip` artifact. Use that ZIP directly for Nexus Mods, Vortex, or manual installation. GitHub's **Source code** archives are not the installable package.

The workflow packages pushes to `main`, `v*` tags, and manual runs. Main-branch builds default to version `1.0.0`; manual runs accept a version, and tags such as `v1.0.1` use their tag version. The artifact contains only the two mod files shown above, without an extra ZIP wrapper.

## Troubleshooting

Check `ue4ss/UE4SS.log` for `[FreeOxenAndHorses] Hook ready` messages. Successful orders log their normal price and before/after regional wealth. A full stable or active monthly cooldown still prevents an order.
