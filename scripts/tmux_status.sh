#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_status_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tmux_core.sh
source "$_tmux_status_source_dir/tmux_core.sh"

# Handle client resize event and update status bar accordingly
#
# Side effects:
#   Updates status-left and status-right based on client width and threshold
_tmux_handle_resize() {
	# Get the current client width
	local client_width
	client_width=$(tmux display-message -p '#{client_width}')

	# Get the configured threshold (default: 120)
	local width_threshold
	width_threshold=$(_tmux_get_option "@status-width-threshold" "120")

	# Get the compact status formats
	local compact_left
	compact_left=$(_tmux_get_option "@status-compact-left" "#S")

	local compact_right
	compact_right=$(_tmux_get_option "@status-compact-right" "%H:%M")

	# Get the full status formats
	local full_left
	full_left=$(_tmux_get_option "@status-full-left" "#S | #(whoami)@#H")

	local full_right
	full_right=$(_tmux_get_option "@status-full-right" "%Y-%m-%d | %H:%M:%S")

	# Compare width against threshold and set status accordingly
	if [ "$client_width" -lt "$width_threshold" ]; then
		# Compact mode - narrow terminal
		_tmux_set_option "status-left" "$compact_left"
		_tmux_set_option "status-right" "$compact_right"
	else
		# Full mode - wide terminal
		_tmux_set_option "status-left" "$full_left"
		_tmux_set_option "status-right" "$full_right"
	fi
}

# Main command router
#
# Arguments:
#   $1 - Command name
# Commands:
#   handle-resize - Handle client resize event (default)
main() {
	local command="${1:-handle-resize}"
	shift || true

	case "$command" in
	handle-resize)
		_tmux_handle_resize "$@"
		;;
	*)
		_tmux_handle_resize "$@"
		;;
	esac
}

main "$@"
