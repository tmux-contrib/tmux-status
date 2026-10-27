#!/usr/bin/env bash

[ -z "$DEBUG" ] || set -x

_tmux_status_source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tmux_core.sh
source "$_tmux_status_source_dir/tmux_core.sh"

# Apply the formats and lengths configured for a mode (all optional)
#
# Arguments:
#   $1 - mode name (compact or full)
# Side effects:
#   Updates status-left/right and status-left/right-length for options that are set
_tmux_apply_mode() {
	local mode="$1"
	local side value

	for side in left right; do
		value=$(_tmux_get_option "@status-$mode-$side" "")
		if [ -n "$value" ]; then _tmux_set_option "status-$side" "$value"; fi

		value=$(_tmux_get_option "@status-$mode-$side-length" "")
		if [ -n "$value" ]; then _tmux_set_option "status-$side-length" "$value"; fi
	done
}

# Handle client resize event and update status bar accordingly
#
# Side effects:
#   Updates status-left and status-right based on client width and threshold
_tmux_handle_resize() {
	# Get the current client width
	local client_width
	client_width=$(tmux display-message -p '#{client_width}')

	# No client attached yet (e.g. plugin loaded from tmux.conf); the
	# client-resized hook runs the handler again once one attaches
	case "$client_width" in
	'' | *[!0-9]*) return 0 ;;
	esac

	# Get the configured threshold (default: 120)
	local width_threshold
	width_threshold=$(_tmux_get_option "@status-width-threshold" "120")

	# Compare width against threshold and set status accordingly
	if [ "$client_width" -lt "$width_threshold" ]; then
		# Compact mode - narrow terminal
		_tmux_apply_mode "compact"
	else
		# Full mode - wide terminal
		_tmux_apply_mode "full"
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
