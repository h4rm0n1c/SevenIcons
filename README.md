# SevenIcons-compat

A “no surprises” compatibility fork of **SevenIcons** that works reliably on Linux desktops (including Xfce on Devuan/Debian) by **removing symlink/alias traps** and ensuring the theme contains **real icon files**.

## Why this fork exists

The upstream theme uses many **symlink-style aliases** (common in icon themes). On some setups, those don’t check out as real symlinks and instead become **plain text files containing the link target** (e.g. a “.png” file whose content is `text-x-script.png`). When that happens:

- GTK/Xfce treat them as images, fail to decode them, and
- icon lookup/caching can become unstable (panels/launchers can misbehave).

This fork **materialises** those aliases into real files and adds checks to keep it that way.

## What’s different vs upstream

- **No symlinks inside the theme.** Everything is a normal file/directory.
- **No “fake PNGs”.** Every `*.png` is a real PNG (validated by magic header).
- **CI validation** to prevent regressions.
- Keeps `Inherits=Adwaita,hicolor` so missing icons fall back cleanly on Debian/Devuan systems.

## Install (per-user, recommended)

    mkdir -p ~/.local/share/icons
    rm -rf ~/.local/share/icons/SevenIcons-compat
    git clone https://github.com/<YOUR_GITHUB_USERNAME>/SevenIcons-compat ~/.local/share/icons/SevenIcons-compat

    # Select it in Xfce (run inside your X session)
    xfconf-query -c xsettings -p /Net/IconThemeName -s SevenIcons-compat
    xfce4-panel -r

You can also select it via: **Settings → Appearance → Icons**.

## Install (system-wide)

    sudo rm -rf /usr/local/share/icons/SevenIcons-compat
    sudo git clone https://github.com/<YOUR_GITHUB_USERNAME>/SevenIcons-compat /usr/local/share/icons/SevenIcons-compat

    # Optional cache build
    sudo gtk-update-icon-cache -f /usr/local/share/icons/SevenIcons-compat

## Notes about icon caches

Xfce does not require an icon cache to use a theme.

If you want to build one anyway:

    gtk-update-icon-cache -f ~/.local/share/icons/SevenIcons-compat

If cache generation fails on your system, you can simply remove the cache file and continue using the theme:

    rm -f ~/.local/share/icons/SevenIcons-compat/.icon-theme.cache \
          ~/.local/share/icons/SevenIcons-compat/icon-theme.cache

## Development

### Validations enforced

- No symlinks under the theme directory
- All `*.png` files are real PNGs (correct magic header)
- `gtk-update-icon-cache -f` succeeds

### Keeping the repo portable

This repo is intended to stay “materialised”. If you import updates from upstream, re-run your materialisation step to convert symlinks/alias-stubs into real files again, then commit the result.

## Credits

All icon art credit remains with the original **SevenIcons** authors and contributors.  
This fork exists purely to improve portability and reduce platform-specific breakage.

## License

Same as upstream (see `LICENSE`).

