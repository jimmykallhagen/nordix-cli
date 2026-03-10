# Nordix CLI Tools

**Part of:** [Nordix](https://github.com/jimmykallhagen/Nordix)  
**License:** GPL-3.0-or-later  
**Author:** Jimmy Källhagen

## Overview

Nordix CLI is a collection of interactive terminal tools designed to make complex Linux tasks accessible to everyone. Each tool provides a user-friendly TUI (Terminal User Interface) with menus, confirmations, and helpful explanations.

**Philosophy:** Give the "Linux Power User" experience to everyone — even new users.

## Tools

| Tool | Description |
|------|-------------|
| `nordix-cli-arch` | Arch Linux package management (pacman/paru), system maintenance, boot optimization |
| `nordix-cli-zfs` | ZFS pool/dataset management, snapshots, scrub, ARC monitoring |
| `nordix-cli-snapshot` | ZFS snapshot creation, rollback, and management |
| `nordix-cli-dataset` | ZFS dataset operations and property management |
| `nordix-cli-media` | Media conversion, metadata cleaning, format conversion |
| `nordix-cli-image` | Image processing, conversion, optimization |
| `nordix-cli-pdf` | PDF manipulation, merging, splitting, compression |
| `nordix-cli-compress` | File compression/decompression (tar, zip, zstd, etc.) |
| `nordix-cli-wine` | Wine prefix management, Windows application setup |
| `nordix-cli-hugepages` | HugePages configuration for performance optimization |

## Installation

The CLI tools are included with Nordix. They are located in:

```
/usr/lib/nordix/scripts/
```

To run any tool:

```bash
nordix-cli-arch
nordix-cli-zfs
nordix-cli-media
# etc.
```

## Features

### Interactive Menus

Every tool provides a numbered menu system:

```
===============================
What would you like to do?
===============================

 1 - Update system
 2 - System maintenance
 3 - System repair
 4 - Manage services
 5 - Install package
 ...
 0 - Exit

Enter your choice (0-18):
❯ 
```

### Safety First

- Confirmation prompts before destructive actions
- Clear explanations of what each action does
- Automatic dependency checks
- Graceful error handling

### Nordix Theme

All tools share a consistent visual style with the Nordix color palette:
- Arctic blues and glacial colors
- ASCII art headers
- Decorative borders
- Color-coded status messages (green=success, red=error, yellow=warning)

## Tool Details

### nordix-cli-arch

The most comprehensive tool — a complete Arch Linux system management suite.

**Features:**
- System updates (pacman + AUR via paru)
- Package search, install, remove
- System maintenance (cache cleanup, orphan removal)
- System repair (keyring refresh, package database repair)
- Service management (systemctl wrapper)
- Boot optimization analysis
- AUR security checks
- Network diagnostics
- Package history and information
- Learning mode (explains pacman commands)

**Auto-installs paru** if not present — no manual AUR helper setup needed.

### nordix-cli-zfs

Complete ZFS management for Nordix's ZFS-first architecture.

**Features:**
- Pool status and health monitoring
- Dataset creation and management
- Snapshot operations (create, rollback, destroy)
- Scrub scheduling and monitoring
- ARC statistics and tuning
- Pool import/export
- Property management
- Space usage analysis

### nordix-cli-media

Media file processing without remembering ffmpeg syntax.

**Features:**
- Video format conversion
- Audio extraction
- Metadata cleaning (privacy)
- Batch processing
- Quality presets

### nordix-cli-image

Image processing made simple.

**Features:**
- Format conversion (PNG, JPG, WebP, etc.)
- Batch resize
- Optimization for web
- Metadata stripping

### nordix-cli-pdf

PDF manipulation without GUI tools.

**Features:**
- Merge multiple PDFs
- Split PDF pages
- Compress PDF size
- Extract pages

### nordix-cli-compress

Unified interface for all compression formats.

**Features:**
- Compress files/folders
- Extract archives
- Supports: tar, gz, bz2, xz, zstd, zip, 7z
- Automatic format detection

### nordix-cli-wine

Wine and Windows compatibility management.

**Features:**
- Create Wine prefixes (32-bit/64-bit)
- Install Windows dependencies (vcrun, dotnet, etc.)
- Manage prefix settings
- Application shortcuts

### nordix-cli-hugepages

Performance optimization for applications that benefit from HugePages.

**Features:**
- Calculate optimal HugePages count
- Configure system settings
- Enable/disable HugePages
- Monitor usage

## Creating Your Own CLI Tool

All Nordix CLI tools follow the same pattern:

```bash
#!/bin/bash
# nordix-cli-example.sh

# Colors (copy from any existing tool)
source /usr/lib/nordix/scripts/nordix-colors.sh

# Startup checks
startup_check() {
    # Verify dependencies
}

# Helper functions
draw_box() { ... }
draw_border() { ... }
confirm_action() { ... }

# Menu functions
show_menu() {
    clear
    # Draw ASCII header
    # Draw menu options
}

# Feature functions
feature_one() { ... }
feature_two() { ... }

# Main loop
while true; do
    show_menu
    read choice
    case $choice in
        1) feature_one ;;
        2) feature_two ;;
        0) exit 0 ;;
    esac
done
```

## Contributing

Contributions are welcome! When creating new CLI tools:

1. Follow the existing visual style (colors, borders, menus)
2. Include confirmation prompts for destructive actions
3. Provide helpful error messages
4. Add a startup check for dependencies
5. Include an "About" or "Help" option

## Nordix Goal

> *"Give the Linux Power User experience to everyone"*

These tools exist because:
- Complex commands shouldn't require memorization
- New users deserve the same power as experts
- Interactive menus reduce errors
- Learning happens through doing, not reading man pages

## License

```
SPDX-License-Identifier: GPL-3.0-or-later
Copyright (c) 2025 Jimmy Källhagen
Part of Nordix - https://github.com/jimmykallhagen/Nordix
Nordix and Yggdrasil are trademarks of Jimmy Källhagen
```
