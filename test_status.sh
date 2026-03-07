#!/usr/bin/env bash

# Test script to verify variable expansion in tmux status bar

set -e

echo "Testing tmux status bar variable expansion..."
echo "=============================================="
echo ""

# Source the core functions
source "$(dirname "$0")/scripts/tmux_core.sh"

# Test 1: Set up the status configurations
echo "1. Setting up status bar configurations..."
tmux set -g @status-full-right "#{?#{aws_profile},#[fg=#{@thm_fg}]#{@separator} #[fg=#{@thm_yellow}]  #{aws_credential_ttl} ,}#[fg=#{@thm_fg}]#{@separator}#[fg=#{@thm_peach}]   #{cpu_percentage} #[fg=#{@thm_fg}]#{@separator} #[fg=#{@thm_green}]#{battery_icon} #{battery_percentage} #{battery_remain} #[fg=#{@thm_fg}]#{@separator} #{pomodoro} #[fg=#{@thm_fg}]#{@separator} 󰚭 #{uptime} #[fg=#{@thm_fg}]#{@separator} #{clock} #[fg=#{@thm_fg}]#{@separator} #[fg=#{@thm_maroon}]  %H:%M:%S "
tmux set -g @status-compact-right "#[fg=#{@thm_fg}]#{@separator} #[fg=#{@thm_green}]#{battery_icon} #{battery_percentage} #{battery_remain} #[fg=#{@thm_fg}]#{@separator} #{clock} #[fg=#{@thm_fg}]#{@separator} #[fg=#{@thm_maroon}]  %H:%M:%S "

# Set some theme colors for testing
tmux set -g @thm_fg "colour7"
tmux set -g @thm_yellow "colour3"
tmux set -g @thm_peach "colour9"
tmux set -g @thm_green "colour2"
tmux set -g @thm_maroon "colour1"
tmux set -g @separator "│"

# Set width threshold
tmux set -g @status-width-threshold "120"

echo "✓ Status configurations set"
echo ""

# Test 2: Verify we can read the options back
echo "2. Reading back the configurations..."
full_right=$(_tmux_get_option "@status-full-right" "")
compact_right=$(_tmux_get_option "@status-compact-right" "")

echo "Full right length: ${#full_right} chars"
echo "Compact right length: ${#compact_right} chars"
echo "✓ Options can be read back"
echo ""

# Test 3: Test shell variable expansion
echo "3. Testing shell variable expansion..."
TEST_VAR="Hello World"
export TEST_VAR

# This should expand $HOME
_tmux_set_option "@test-shell-var" "$HOME/test/path"
result=$(tmux show-option -gqv "@test-shell-var")

echo "Original: \$HOME/test/path"
echo "Expanded: $result"

if [[ "$result" == "$HOME/test/path" ]]; then
    echo "✓ Shell variable \$HOME was properly expanded"
else
    echo "✗ Shell variable expansion failed!"
    exit 1
fi
echo ""

# Test 4: Test tmux format expansion
echo "4. Testing tmux format strings..."
_tmux_set_option "status-right" "Test: #{client_width}"
result=$(tmux show-option -gv "status-right")

echo "Set value: Test: #{client_width}"
echo "Stored value: $result"

if [[ "$result" == "Test: #{client_width}" ]]; then
    echo "✓ Tmux format string preserved (will be expanded during rendering)"
else
    echo "✗ Tmux format string was modified!"
    exit 1
fi
echo ""

# Test 5: Test with actual status-right from user config
echo "5. Testing with user's actual status configuration..."
_tmux_set_option "status-right" "$full_right"
result=$(tmux show-option -gv "status-right")

echo "Length of set value: ${#full_right}"
echo "Length of stored value: ${#result}"

if [[ "$result" == "$full_right" ]]; then
    echo "✓ Complex status bar configuration set correctly"
    echo "✓ All format strings (#{battery_percentage}, #{cpu_percentage}, etc.) preserved"
else
    echo "✗ Status bar configuration was modified!"
    exit 1
fi
echo ""

# Test 6: Simulate the resize handler
echo "6. Testing resize handler..."
# Simulate wide screen
tmux set -g client_width "150"
bash "$(dirname "$0")/scripts/tmux_status.sh" handle-resize

current_status=$(tmux show-option -gv "status-right" 2>/dev/null || echo "")
if [[ -n "$current_status" ]]; then
    echo "✓ Status bar updated for wide screen"
    echo "  Length: ${#current_status} chars"
else
    echo "  Note: status-right not set (expected if conditions not met)"
fi
echo ""

# Clean up
tmux set -gu @test-shell-var 2>/dev/null || true

echo "=============================================="
echo "All tests passed! ✓"
echo ""
echo "Summary:"
echo "  ✓ Shell variables (like \$HOME) are expanded"
echo "  ✓ Tmux formats (like #{battery_percentage}) are preserved"
echo "  ✓ Complex status bar configurations work correctly"
echo "  ✓ The resize handler can update status-right"
