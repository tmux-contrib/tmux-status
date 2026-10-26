#!/usr/bin/env bash

# Shared setup for the bats suite.
#
# Each test gets its own tmux server (isolated via TMUX_TMPDIR) so nothing
# touches a developer's real tmux session.

ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

test_helper_setup() {
	local real_tmux
	real_tmux="$(command -v tmux)"

	export TMUX_TMPDIR="$BATS_TEST_TMPDIR"
	unset TMUX

	# A detached session has no client, so #{client_width} is empty. Shim
	# tmux to answer that one query from FAKE_CLIENT_WIDTH.
	mkdir -p "$BATS_TEST_TMPDIR/bin"
	cat >"$BATS_TEST_TMPDIR/bin/tmux" <<SHIM
#!/usr/bin/env bash
if [ "\$1" = "display-message" ] && [ "\$3" = "#{client_width}" ]; then
	echo "\${FAKE_CLIENT_WIDTH:-200}"
	exit 0
fi
exec "$real_tmux" "\$@"
SHIM
	chmod +x "$BATS_TEST_TMPDIR/bin/tmux"
	export PATH="$BATS_TEST_TMPDIR/bin:$PATH"

	tmux new-session -d -s test
}

test_helper_teardown() {
	tmux kill-server 2>/dev/null || true
}

# Run the resize handler with the given fake client width.
run_resize() {
	FAKE_CLIENT_WIDTH="$1" run bash "$ROOT/scripts/tmux_status.sh" handle-resize
	# shellcheck disable=SC2154 # $status is set by bats' run
	[ "$status" -eq 0 ]
}

teardown() {
	test_helper_teardown
}
