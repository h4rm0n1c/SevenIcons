#!/usr/bin/env bash
set -euo pipefail

root="SevenIcons"

if [ ! -d "$root" ]; then
  echo "ERROR: missing $root directory (run from repo root)"
  exit 1
fi

pngsig_hex="89504e470d0a1a0a"

is_real_png() {
  local f="$1"
  local sig
  sig="$(head -c 8 "$f" 2>/dev/null | od -An -tx1 | tr -d ' \n' || true)"
  [ "$sig" = "$pngsig_hex" ]
}

fix_one() {
  local f="$1"
  local dir target

  dir="$(dirname "$f")"

  # If it's a symlink, resolve link target from the symlink itself.
  if [ -L "$f" ]; then
    target="$(readlink "$f")"
  else
    # Otherwise treat it as a "symlink blob checked out as file": file content is the target path/name.
    target="$(tr -d '\r\n' < "$f" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  fi

  # Only accept local-ish targets
  case "$target" in
    ""|/*) return 1 ;;
  esac

  if [ -f "$dir/$target" ] && is_real_png "$dir/$target"; then
    rm -f "$f"
    cp -a "$dir/$target" "$f"
    return 0
  fi

  return 2
}

echo "== Pass 1: convert symlinks and text-alias PNGs into real PNG copies =="
fixed=0
moved=0
q="__quarantine__$(date +%Y%m%d_%H%M%S)"
mkdir -p "$q"

while IFS= read -r -d '' f; do
  # already real png -> ok
  if [ -f "$f" ] && is_real_png "$f"; then
    continue
  fi

  # symlink or bogus png-text -> try to fix
  if fix_one "$f"; then
    fixed=$((fixed+1))
    continue
  fi

  # Can't resolve -> quarantine so theme falls back to Adwaita/hicolor
  rel="${f#$root/}"
  mkdir -p "$q/$(dirname "$rel")"
  mv "$f" "$q/$rel"
  moved=$((moved+1))
done < <(find "$root" \( -type l -o -type f \) -iname '*.png' -print0)

echo "FIXED=$fixed  QUARANTINED=$moved  QUAR_DIR=$q"

echo "== Pass 2: assert no symlinks remain in the theme =="
syms="$(find "$root" -type l | wc -l)"
echo "SYMLINKS_REMAINING=$syms"
if [ "$syms" -ne 0 ]; then
  echo "ERROR: symlinks still present under $root"
  exit 3
fi

echo "== Pass 3: assert all remaining *.png are real PNGs =="
bad=0
while IFS= read -r -d '' f; do
  if ! is_real_png "$f"; then
    echo "NOT_PNG: $f"
    bad=1
  fi
done < <(find "$root" -type f -iname '*.png' -print0)

if [ "$bad" -ne 0 ]; then
  echo "ERROR: some .png files are not real PNGs"
  exit 4
fi

echo "OK: materialised icons successfully"
