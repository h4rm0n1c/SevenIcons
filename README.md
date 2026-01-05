# SevenIcons

A “no surprises” compatibility fork of **SevenIcons** that works reliably on Linux desktops (including Xfce on Devuan/Debian) by **removing symlink/alias traps** and ensuring the theme contains **real icon files**.

New: I have started replacing more of the default/fallback icons in this pack with icons pulled from an old install of Mac OS 7, some manual editing was required in some places like where icon masks were missing preventing export, this is now the most comprehensive Mac OS 7 Icon pack on Github as far as I know.

still have a lot of work to do, there's a load of text formats to do with coding that need classic style icons if they can't be retrieved.

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

##  NEW Icons that have been added since fork
- Images: image-bmp.png, image-gif.png, image-jpeg.png, image-jpeg2000.png, image-png.png, image-tiff.png, image-x-* variants, plus gnome-mime-image-{bmp,jpeg,png,x-cmu-raster,x-portable-bitmap,x-psd,x-xpixmap}.
- Archives: application-{7zip,epub+zip,vnd.ms-cab-compressed,x-7z-compressed,x-arj,x-bzip(-compressed-tar),x-compressed-tar,x-gzip,x-jar,x-java-archive,x-lzma(-compressed-tar),x-lzop,x-rar,x-stuffit,x-zip,zip}, archive.png, folder_tar.png, rar.png, tar.png, and gnome-mime-application-* counterparts for the same archive families.
- Fonts: font.png, font-x-generic.png, font_bitmap.png, font_truetype.png, font_type1.png, gnome-mime-application-x-font-{afm,bdf,linux-psf,pcf,sunos-news,ttf}, gnome-mime-x-font-afm.png.
- Audio: application-ogg.png, audio-mpeg.png, audio-x-{adpcm,flac+ogg,generic,mp3-playlist,mpeg,mpegurl,ms-wma,playlist,scpls,smart-playlist,speex+ogg,vorbis+ogg,wav}, gnome-mime-application-ogg.png, media-audio.png.
- Library/Object: application-x-object.png (library/shared-object replacement).
- PDF: application-pdf.png, gnome-mime-application-pdf.png.

## Install (per-user, recommended)

Download the repo, then copy **only the theme directory** into your icons path (avoid copying helper scripts from the repo root).

    tmpdir=$(mktemp -d)
    git clone --depth 1 https://github.com/h4rm0n1c/SevenIcons "$tmpdir"
    mkdir -p ~/.local/share/icons
    rm -rf ~/.local/share/icons/SevenIcons
    cp -a "$tmpdir/SevenIcons" ~/.local/share/icons/SevenIcons

    # Select it in Xfce (run inside your X session)
    xfconf-query -c xsettings -p /Net/IconThemeName -s SevenIcons
    xfce4-panel -r

You can also select it via: **Settings → Appearance → Icons**.

## Install (system-wide)

    tmpdir=$(mktemp -d)
    git clone --depth 1 https://github.com/h4rm0n1c/SevenIcons "$tmpdir"
    sudo rm -rf /usr/local/share/icons/SevenIcons
    sudo cp -a "$tmpdir/SevenIcons" /usr/local/share/icons/SevenIcons

## Notes about icon caches

Xfce does not require an icon cache to use a theme.
It is NOT reccomended that you generate a cache.
I had issues with this bringing down my entire X Session, so, beware.

If you want to build one anyway:

    gtk-update-icon-cache -f ~/.local/share/icons/SevenIcons

If cache generation fails on your system, you can simply remove the cache file and continue using the theme:

    rm -f ~/.local/share/icons/SevenIcons/.icon-theme.cache \
          ~/.local/share/icons/SevenIcons/icon-theme.cache

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

