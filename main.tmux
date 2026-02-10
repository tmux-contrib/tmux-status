#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_status_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/tmux_core.sh
source "$_tmux_status_root/scripts/tmux_core.sh"

# Main entry point for tmux-status plugin
main() {
	# Set up the client-resized hook
	tmux set-hook -g client-resized "run-shell '$_tmux_status_root/scripts/tmux_status.sh handle-resize'"

	# Run the handler once on plugin load to set initial status
	"$_tmux_status_root/scripts/tmux_status.sh" handle-resize
}

main
