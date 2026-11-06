# ibus-super-fix

Ubuntu 24.04 ibus 1.5.29-2, built again with two upstream fixes, so that a Super or Hyper shortcut with a non-ASCII key reaches GNOME in text inputs.

## The fault

On GNOME Wayland, a window with an active text input, for example a terminal or a text field, gives each key to IBus before Mutter checks the shortcuts. The IBus simple engine serves the normal keyboard layouts. In `src/ibusenginesimple.c`, `ibus_engine_simple_process_key_event` refuses a key only when Alt or Ctrl is held (`IBUS_MOD1_MASK | IBUS_CONTROL_MASK`). With Super or Hyper it goes on to `no_sequence_matches`, which commits a printable character above U+007F and reports the key as handled. Mutter never sees the shortcut. On a Finnish keyboard Super+§ types § in GNOME Terminal instead of the GNOME shortcut "Switch windows of an application". Super+ä, Super+ö, Super+å and dead keys have the same fault. ASCII keys, for example Super+` on a US keyboard, are not affected.

## The fix

Upstream IBus has two commits:

| Commit | Release | Change |
|---|---|---|
| `4872c1fcd` | 1.5.30 | `no_sequence_matches` does not commit a character any more |
| `48c4a9c90` | 1.5.31 | The Super modifier is ignored for compose keys, as Alt and Ctrl are |

Ubuntu 24.04 (noble) has 1.5.29-2 and noble-updates has no newer package. Ubuntu 25.04 and later have 1.5.32 or later and do not have the fault. The upstream path for 24.04 is Launchpad bug 2086589, "Update ibus to 1.5.30". Note that 1.5.30 alone does not have the second commit.

This directory builds the Ubuntu package 1.5.29-2 again with the two commits as quilt patches `0006` and `0007`. The version is `1.5.29-2ubuntu0~local1`, so that an official update such as `1.5.29-2ubuntu0.1` replaces it.

## Build

```sh
./build.sh
```

The script starts a `ubuntu:24.04` container with podman, installs the build dependencies in the container, gets the source with `apt-get source ibus`, adds the patches and the changelog entry from `patches/`, and runs `dpkg-buildpackage -us -uc -b`. The `.deb` files go to `build/`, which Git ignores. The build takes about two minutes on a fast machine. The container is removed after the build, so nothing stays on the host.

## Install

`install.sh` prints the `apt install` command for the ibus packages that this machine has installed now. With `--run` it runs the command with `sudo`.

```sh
./install.sh
./install.sh --run
```

On a machine with the default GNOME set, the command is:

```sh
sudo apt install ./build/gir1.2-ibus-1.0_1.5.29-2ubuntu0~local1_amd64.deb ./build/ibus_1.5.29-2ubuntu0~local1_amd64.deb ./build/ibus-data_1.5.29-2ubuntu0~local1_all.deb ./build/ibus-gtk_1.5.29-2ubuntu0~local1_amd64.deb ./build/ibus-gtk3_1.5.29-2ubuntu0~local1_amd64.deb ./build/ibus-gtk4_1.5.29-2ubuntu0~local1_amd64.deb ./build/libibus-1.0-5_1.5.29-2ubuntu0~local1_amd64.deb ./build/python3-ibus-1.0_1.5.29-2ubuntu0~local1_all.deb
```

Then log out and log in. GNOME Shell starts `ibus-daemon`, and the running daemon and the GTK modules keep the old code until the session starts again.

Test: open GNOME Terminal and press Super+§ (or Caps Lock+§ with Rektangel). The shortcut must work and must not type §.

## Go back

The official version stays in the archive. Install it again with the version for each package:

```sh
sudo apt install ibus=1.5.29-2 ibus-data=1.5.29-2 ibus-gtk=1.5.29-2 ibus-gtk3=1.5.29-2 ibus-gtk4=1.5.29-2 libibus-1.0-5=1.5.29-2 gir1.2-ibus-1.0=1.5.29-2 python3-ibus-1.0=1.5.29-2
```

Then log out and log in.

## Files

- `build.sh`: the podman build on the host.
- `container-build.sh`: the steps in the container.
- `install.sh`: prints or runs the install command for the installed package set.
- `patches/0006-*.patch`, `patches/0007-*.patch`: the upstream commits as `git format-patch` output.
- `patches/changelog.txt`: the changelog entry of the local version.
