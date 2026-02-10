# tmux-status

A tmux plugin that dynamically adjusts the status bar content based on terminal
width. When your terminal is resized, the status bar automatically switches
between compact and full formats.

## Features

- Automatically detects terminal resize events using tmux's `client-resized` hook
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

All configuration options are set in your `~/.tmux.conf` file.

### Width Threshold

Set the width threshold (in characters) at which the status bar switches
between compact and full mode:

```tmux
set -g @status-width-threshold 120
```

Default: `120`

### Compact Mode (narrow terminals)

Status formats when terminal width is below the threshold:

```tmux
set -g @status-compact-left "#S"
set -g @status-compact-right "%H:%M"
```

Defaults:

- Left: `#S` (session name)
- Right: `%H:%M` (time in HH:MM format)

### Full Mode (wide terminals)

Status formats when terminal width is at or above the threshold:

```tmux
set -g @status-full-left "#S | #(whoami)@#H"
set -g @status-full-right "%Y-%m-%d | %H:%M:%S"
```

Defaults:

- Left: `#S | #(whoami)@#H` (session | user@host)
- Right: `%Y-%m-%d | %H:%M:%S` (date and time)

## Example Configuration

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

1. The plugin sets up a tmux `client-resized` hook
2. When the terminal is resized, the hook triggers the status handler script
3. The script checks the current client width using `#{client_width}`
4. Based on the width and configured threshold, it sets either compact or full status
5. The status bar updates immediately

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
