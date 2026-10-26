#!/usr/bin/env bats

load test_helper

setup() {
	test_helper_setup
}

@test "main.tmux registers the client-resized hook" {
	run bash "$ROOT/main.tmux"
	[ "$status" -eq 0 ]
	run tmux show-hooks -g
	[[ "$output" == *"client-resized"* ]]
	[[ "$output" == *"tmux_status.sh handle-resize"* ]]
}

@test "main.tmux applies the initial status" {
	tmux set -g @status-full-right "full-right"
	FAKE_CLIENT_WIDTH=150 run bash "$ROOT/main.tmux"
	[ "$status" -eq 0 ]
	[ "$(tmux show-option -gv status-right)" = "full-right" ]
}

@test "main.tmux is a no-op for status when nothing is configured" {
	local right
	right="$(tmux show-option -gv status-right)"
	run bash "$ROOT/main.tmux"
	[ "$status" -eq 0 ]
	[ "$(tmux show-option -gv status-right)" = "$right" ]
}
