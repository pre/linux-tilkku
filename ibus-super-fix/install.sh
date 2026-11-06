#!/usr/bin/env bash
# Prints the apt command that installs the rebuilt packages that this
# machine has installed now. With --run, runs it with sudo.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
installed="$(dpkg-query -W -f '${binary:Package} ${Version}\n' 'ibus*' 'libibus*' 'gir1.2-ibus*' 'python3-ibus*' 2>/dev/null |
  awk '$2 ~ /^1\.5\.29-2/ {sub(/:amd64$/, "", $1); print $1}')"

debs=()
for package in $installed; do
  debs+=("$here"/build/"${package}"_1.5.29-2ubuntu0~local1_*.deb)
done

echo "sudo apt install ${debs[*]}"
if [[ "${1:-}" == "--run" ]]; then
  sudo apt install "${debs[@]}"
fi
