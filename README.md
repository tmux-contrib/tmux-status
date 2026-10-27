# tmux-status

> A tmux plugin that dynamically adjusts the status bar content based on terminal width. When your terminal is resized, the status bar automatically switches between compact and full formats.

[![CI](https://github.com/tmux-contrib/tmux-status/actions/workflows/ci.yml/badge.svg)](https://github.com/tmux-contrib/tmux-status/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Features

- Automatically detects terminal resize events using tmux's `client-resized` and `client-attached` hooks
- Switches between compact and full status formats based on configurable width threshold
- Fully customizable status formats for both compact and full modes
- Zero configuration required - works out of the box with sensible defaults

## Installation

### Using [TPM](https://github.com/tmux-plugins/tpm) (recommended)

Add this line to your `~/.tmux.conf`:

```tmux
set -g @plugin 'tmux-contrib/tmux-status'
```

Then press `prefix + I` to install the plugin.

### Manual Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/tmux-contrib/tmux-status ~/.tmux/plugins/tmux-status
   ```

2. Add this line to your `~/.tmux.conf`:

   ```tmux
   run-shell ~/.tmux/plugins/tmux-status/main.tmux
   ```

3. Reload tmux configuration:

   ```bash
   tmux source-file ~/.tmux.conf
   ```

## Configuration

All configuration options are optional and set in your `~/.tmux.conf` file.

### Width Threshold

Set the width threshold (in characters) at which the status bar switches
between compact and full mode:

```tmux
set -g @status-width-threshold 120
```

Default: `120`

### Compact Mode (narrow terminals)

Status formats when terminal width is below the threshold. **These are optional** - only set them if you want the plugin to manage your status bar in compact mode:

```tmux
set -g @status-compact-left "#S"
set -g @status-compact-right "%H:%M"
```

If not set, the plugin will not modify the status bar in compact mode.

### Full Mode (wide terminals)

Status formats when terminal width is at or above the threshold. **These are optional** - only set them if you want the plugin to manage your status bar in full mode:

```tmux
set -g @status-full-left "#S | #(whoami)@#H"
set -g @status-full-right "%Y-%m-%d | %H:%M:%S"
```

If not set, the plugin will not modify the status bar in full mode.

### Status Length

tmux truncates the status sections to `status-left-length` (default 10) and
`status-right-length` (default 40) characters, so long formats get cut off.
Set the length per mode and the plugin switches it along with the format.
**These are optional** - only set the ones you need:

```tmux
set -g @status-full-left-length 60
set -g @status-full-right-length 120
set -g @status-compact-left-length 20
set -g @status-compact-right-length 40
```

If not set, the plugin will not modify the length.

## Example Configurations

### Full Configuration (both modes)

```tmux
# Set width threshold to 100 characters
set -g @status-width-threshold 100

# Compact mode - minimal info
set -g @status-compact-left "#S"
set -g @status-compact-right "%H:%M"

# Full mode - detailed info
set -g @status-full-left "#S | #I:#P | #(whoami)@#H"
set -g @status-full-right "#{battery_percentage} | %Y-%m-%d | %H:%M:%S"

# Load the plugin
set -g @plugin 'tmux-contrib/tmux-status'
```

### Partial Configuration (only compact mode)

```tmux
# Only simplify status bar when terminal is narrow
set -g @status-compact-left "#S"
set -g @status-compact-right "%H:%M"

set -g @plugin 'tmux-contrib/tmux-status'
```

### Partial Configuration (only status-right)

```tmux
# Only modify the right side of status bar
set -g @status-compact-right "%H:%M"
set -g @status-full-right "%Y-%m-%d | %H:%M:%S"

set -g @plugin 'tmux-contrib/tmux-status'
```

## Tmux Format Variables

You can use any tmux format variables in your status configurations. Here are some common ones:

- `#S` - Session name
- `#I` - Window index
- `#P` - Pane index
- `#W` - Window name
- `#H` - Hostname
- `#(command)` - Execute shell command
- `%Y-%m-%d` - Date
- `%H:%M:%S` - Time

See `man tmux` for more format variables.

## How It Works

1. The plugin sets up tmux `client-resized` and `client-attached` hooks (at hook
   index 100, so reloading the config doesn't duplicate them and hooks from other
   plugins are left alone; requires tmux 3.0+)
2. When the terminal is resized or a client attaches, the hook triggers the status handler script
3. The script checks the current client width using `#{client_width}`
4. Based on the width and configured threshold:
   - If width < threshold and compact options are set, applies compact status
   - If width >= threshold and full options are set, applies full status
   - If options are not configured, leaves that part of the status bar unchanged
   - Applies the matching `-length` options the same way
5. The status bar updates immediately (only for configured options)

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
