#!/usr/bin/env bats

load test_helper

setup() {
	test_helper_setup
	# shellcheck source=../scripts/tmux_core.sh
	source "$ROOT/scripts/tmux_core.sh"
}

@test "_tmux_get_option returns the default when the option is unset" {
	run _tmux_get_option "@missing" "fallback"
	[ "$status" -eq 0 ]
	[ "$output" = "fallback" ]
}

@test "_tmux_get_option returns the stored value when set" {
	tmux set -g @present "value"
	run _tmux_get_option "@present" "fallback"
	[ "$output" = "value" ]
}

@test "_tmux_set_option stores a plain path verbatim" {
	_tmux_set_option "@path" "$HOME/test/path"
	[ "$(tmux show-option -gqv @path)" = "$HOME/test/path" ]
}

@test "_tmux_set_option preserves tmux format strings" {
	_tmux_set_option "status-right" "Test: #{client_width}"
	[ "$(tmux show-option -gv status-right)" = "Test: #{client_width}" ]
}
