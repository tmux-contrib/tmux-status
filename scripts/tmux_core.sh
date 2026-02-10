#!/usr/bin/env bash

# Get tmux option with default fallback
#
# Arguments:
#   $1 - option name
#   $2 - default value
# Outputs:
#   Option value or default
_tmux_get_option() {
	local option="$1"
	local default="$2"
	local value

	value="$(tmux show-option -gqv "$option")"
	echo "${value:-$default}"
}

# Set tmux option
#
# Arguments:
#   $1 - option name
#   $2 - option value
_tmux_set_option() {
	local option="$1"
	local value="$2"

	tmux set-option -g "$option" "$value"
}
