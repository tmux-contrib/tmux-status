#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_status_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux_core.sh
source "$_tmux_status_root/scripts/tmux_core.sh"

# Hook array index owned by this plugin (hooks are arrays since tmux 3.0)
_tmux_status_hook_index=100

# Main entry point for tmux-status plugin
main() {
	# Set up the hooks at a fixed array index so reloading the config replaces
	# our entry instead of duplicating it, and other plugins' hooks are kept
	local event
	for event in client-resized client-attached; do
		tmux set-hook -g "${event}[${_tmux_status_hook_index}]" "run-shell '$_tmux_status_root/scripts/tmux_status.sh handle-resize'"
	done

	# Run the handler once on plugin load to set initial status
	"$_tmux_status_root/scripts/tmux_status.sh" handle-resize
}

main
