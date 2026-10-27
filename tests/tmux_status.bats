#!/usr/bin/env bats

load test_helper

setup() {
	test_helper_setup
	tmux set -g @status-full-left "full-left"
	tmux set -g @status-full-right "full-right"
	tmux set -g @status-compact-left "compact-left"
	tmux set -g @status-compact-right "compact-right"
}

@test "wide client uses the full formats" {
	run_resize 150
	[ "$(tmux show-option -gv status-left)" = "full-left" ]
	[ "$(tmux show-option -gv status-right)" = "full-right" ]
}

@test "narrow client uses the compact formats" {
	run_resize 80
	[ "$(tmux show-option -gv status-left)" = "compact-left" ]
	[ "$(tmux show-option -gv status-right)" = "compact-right" ]
}

@test "width equal to the default threshold is full" {
	run_resize 120
	[ "$(tmux show-option -gv status-right)" = "full-right" ]
}

@test "custom threshold is respected" {
	tmux set -g @status-width-threshold 200
	run_resize 150
	[ "$(tmux show-option -gv status-right)" = "compact-right" ]
}

@test "unknown command falls through to the resize handler" {
	FAKE_CLIENT_WIDTH=80 run bash "$ROOT/scripts/tmux_status.sh" bogus
	[ "$status" -eq 0 ]
	[ "$(tmux show-option -gv status-right)" = "compact-right" ]
}

@test "no-op: nothing configured leaves status untouched" {
	tmux set -gu @status-full-left
	tmux set -gu @status-full-right
	tmux set -gu @status-compact-left
	tmux set -gu @status-compact-right
	local left right
	left="$(tmux show-option -gv status-left)"
	right="$(tmux show-option -gv status-right)"

	run_resize 150
	run_resize 80

	[ "$(tmux show-option -gv status-left)" = "$left" ]
	[ "$(tmux show-option -gv status-right)" = "$right" ]
}

@test "no-op: wide client without full formats leaves status untouched" {
	tmux set -gu @status-full-left
	tmux set -gu @status-full-right
	local left right
	left="$(tmux show-option -gv status-left)"
	right="$(tmux show-option -gv status-right)"

	run_resize 150

	[ "$(tmux show-option -gv status-left)" = "$left" ]
	[ "$(tmux show-option -gv status-right)" = "$right" ]
}

@test "no-op: narrow client without compact formats leaves status untouched" {
	tmux set -gu @status-compact-left
	tmux set -gu @status-compact-right
	local left right
	left="$(tmux show-option -gv status-left)"
	right="$(tmux show-option -gv status-right)"

	run_resize 80

	[ "$(tmux show-option -gv status-left)" = "$left" ]
	[ "$(tmux show-option -gv status-right)" = "$right" ]
}

@test "no client attached: exits cleanly, prints nothing, leaves status untouched" {
	local left right
	left="$(tmux show-option -gv status-left)"
	right="$(tmux show-option -gv status-right)"

	run_resize ""

	[ -z "$output" ]
	[ "$(tmux show-option -gv status-left)" = "$left" ]
	[ "$(tmux show-option -gv status-right)" = "$right" ]
}
