#!/usr/bin/env bash
set -euo pipefail

THEME_DIR="SevenIcons"   # change if needed, e.g. "SevenIcons-compat"
INDEX="$THEME_DIR/index.theme"

test -d "$THEME_DIR"
test -f "$INDEX"

cp -a "$INDEX" "/tmp/index.theme.bak.$(date +%Y%m%d_%H%M%S)"

python3 - <<'PY'
import os
from pathlib import Path

theme_dir = Path("SevenIcons")  # change if you changed THEME_DIR above
index = theme_dir / "index.theme"

ctx_map = {
  "actions": "Actions",
  "apps": None,
  "categories": None,
  "devices": "Devices",
  "menu": "Menu",
  "mimes": "MimeTypes",
  "places": "FileSystems",
  "status": None,
}

dirs = []
sections = []

for top in sorted([p for p in theme_dir.iterdir() if p.is_dir()]):
  topname = top.name
  context = ctx_map.get(topname)
  for sub in sorted([p for p in top.iterdir() if p.is_dir()]):
    subname = sub.name
    rel = f"{topname}/{subname}"

    if subname.isdigit():
      size = int(subname)
      dirs.append(rel)
      sections.append((rel, size, context, "Fixed", None, None))
    elif subname == "symbolic":
      dirs.append(rel)
      sections.append((rel, 16, context, "Scalable", 8, 512))
    else:
      # ignore unexpected dirs to keep the theme file strict
      pass

out = []
out.append("[Icon Theme]\n")
out.append("Name=SevenIcons\n")
out.append("Comment=SevenIcons compat index (GTK cache safe)\n")
out.append("Inherits=Adwaita,hicolor\n")
out.append("Directories=" + ",".join(dirs) + "\n\n")

for name, size, context, typ, mn, mx in sections:
  out.append(f"[{name}]\n")
  out.append(f"Size={size}\n")
  out.append(f"Type={typ}\n")
  if context:
    out.append(f"Context={context}\n")
  if typ == "Scalable":
    out.append(f"MinSize={mn}\n")
    out.append(f"MaxSize={mx}\n")
  out.append("\n")

index.write_text("".join(out), encoding="utf-8")
print("Wrote", index)
print("Directories", len(dirs))
PY
