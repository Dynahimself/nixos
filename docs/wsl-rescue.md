# WSL rescue (when `wsl -d NixOS` fails with `execvpe(/run/current-system/sw/bin/bash) failed`)

That error means `/run/current-system` (a tmpfs symlink, recreated at every boot)
is missing — the boot didn't activate the NixOS system. Causes so far:
a rebuild without `--flake .#wsl`, or a config missing `wsl.enable = true`.

## Get a shell anyway

`/bin/sh` is NOT in `/run` — it survives. From PowerShell:

```powershell
wsl -d NixOS -u root --exec /bin/sh
```

## Repair

```sh
# repair the current session
/nix/var/nix/profiles/system/activate
export PATH=/run/current-system/sw/bin:$PATH

# verify the current profile is a REAL WSL system (must print > 0)
nix-store -q --references /nix/var/nix/profiles/system | grep -c wsl

# if 0: the wrong system is switched in — build the right one
# ('build' action avoids the dbus error you get without systemd PID1)
cd /etc/nixos
nixos-rebuild build --flake .#wsl
R=$(readlink -f result); rm result
nix-env -p /nix/var/nix/profiles/system --set "$R"
ln -sfn "$R" /run/current-system
"$R/activate"
```

## Prove it's healthy

```powershell
wsl --shutdown
wsl -d NixOS      # must land in zsh as dyna
```

Then confirm `cat /proc/1/comm` prints `systemd`. A healthy WSL system
recreates `/run/current-system` at every boot — if systemd is PID1, this
class of breakage cannot strand you again.

## Never do this

- `nixos-rebuild switch` WITHOUT `--flake .#wsl` — builds the wrong config.
  Use the `rebuild` alias from home-wsl.nix.
