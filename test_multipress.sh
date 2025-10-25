#!/usr/bin/env bash

# Test script for multipress
# Tests all major functionality as documented in the help text

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper functions
print_test() {
	echo -e "\n${YELLOW}[TEST $((TESTS_TOTAL + 1))]${NC} $1"
	((TESTS_TOTAL++))
}

pass() {
	echo -e "${GREEN}✓ PASS${NC}: $1"
	((TESTS_PASSED++))
}

fail() {
	echo -e "${RED}✗ FAIL${NC}: $1"
	((TESTS_FAILED++))
}

# Ensure multipress is executable
chmod +x multipress

echo "=========================================="
echo "  MULTIPRESS TEST SUITE"
echo "=========================================="

# Test 1: Version flag
print_test "Testing --version flag"
VERSION_OUTPUT=$(./multipress --version 2>&1)
VERSION_EXIT=$?
if [[ $VERSION_OUTPUT == *"multipress version"* ]] && [[ $VERSION_EXIT -eq 0 ]]; then
	pass "Version output correct: $VERSION_OUTPUT"
else
	fail "Version output incorrect"
fi

# Test 2: Help flag
print_test "Testing --help flag"
HELP_OUTPUT=$(./multipress --help 2>&1)
HELP_EXIT=$?
if [[ $HELP_OUTPUT == *"ARGUMENT"* ]] && [[ $HELP_OUTPUT == *"EXAMPLES"* ]] && [[ $HELP_EXIT -eq 0 ]]; then
	pass "Help documentation displayed"
else
	fail "Help documentation not displayed correctly"
fi

# Test 3: Normal mode dry-run
print_test "Testing normal mode with --dry-run"
DRYRUN_OUTPUT=$(./multipress --dry-run -- echo 'activated once' __ echo 'activated twice' 2>&1)
if [[ $DRYRUN_OUTPUT == *"[DRY-RUN]"* ]] && [[ $DRYRUN_OUTPUT == *"Mode: Normal (eval)"* ]]; then
	pass "Normal mode dry-run works correctly"
else
	fail "Normal mode dry-run failed"
fi

# Test 4: Command String mode dry-run
print_test "Testing command string mode with --dry-run"
DRYRUN_CS_OUTPUT=$(./multipress -c --dry-run -- "echo 'activated once'" "echo 'activated twice'" 2>&1)
if [[ $DRYRUN_CS_OUTPUT == *"[DRY-RUN]"* ]] && [[ $DRYRUN_CS_OUTPUT == *"Mode: Command String"* ]]; then
	pass "Command String mode dry-run works correctly"
else
	fail "Command String mode dry-run failed"
fi

# Test 5: Normal mode execution (2 commands)
print_test "Testing normal mode execution with 2 activations"
OUTPUT=$(./multipress -t 1 -- echo 'once' __ echo 'twice' & sleep 0.1 && ./multipress -t 1 -- echo 'once' __ echo 'twice' && sleep 1.5 2>&1)
if [[ $OUTPUT == *"twice"* ]]; then
	pass "Normal mode correctly executed 2nd command"
else
	fail "Normal mode did not execute 2nd command"
fi

# Test 6: Command String mode execution (2 commands)
print_test "Testing command string mode execution with 2 activations"
OUTPUT_CS=$(./multipress -c -t 1 -- "echo 'once'" "echo 'twice'" & sleep 0.1 && ./multipress -c -t 1 -- "echo 'once'" "echo 'twice'" && sleep 1.5 2>&1)
if [[ $OUTPUT_CS == *"twice"* ]]; then
	pass "Command String mode correctly executed 2nd command"
else
	fail "Command String mode did not execute 2nd command"
fi

# Test 7: Three commands execution
print_test "Testing execution with 3 activations"
OUTPUT_3=$(./multipress -t 1 -- echo 'once' __ echo 'twice' __ echo 'thrice' & sleep 0.1 && ./multipress -t 1 -- echo 'once' __ echo 'twice' __ echo 'thrice' & sleep 0.1 && ./multipress -t 1 -- echo 'once' __ echo 'twice' __ echo 'thrice' && sleep 1.5 2>&1)
if [[ $OUTPUT_3 == *"thrice"* ]]; then
	pass "Three commands correctly executed 3rd command"
else
	fail "Three commands did not execute 3rd command"
fi

# Test 8: Prevent overrun flag
print_test "Testing --prevent-overrun flag"
OUTPUT_PO=$(./multipress -t 1 -p -- echo 'once' __ echo 'twice' & sleep 0.1 && ./multipress -t 1 -p -- echo 'once' __ echo 'twice' & sleep 0.1 && ./multipress -t 1 -p -- echo 'once' __ echo 'twice' && sleep 1.5 2>&1)
if [[ $OUTPUT_PO == *"twice"* ]] && [[ $OUTPUT_PO != *"thrice"* ]]; then
	pass "Prevent overrun correctly stopped at 2nd command"
else
	fail "Prevent overrun did not work correctly"
fi

# Test 9: Custom name flag
print_test "Testing --name flag with custom instance name"
OUTPUT_NAME=$(./multipress -n test_instance -t 1 -- echo 'first' __ echo 'second' & sleep 0.1 && ./multipress -n test_instance -t 1 -- echo 'first' __ echo 'second' && sleep 1.5 2>&1)
if [[ $OUTPUT_NAME == *"second"* ]]; then
	pass "Custom name flag works correctly"
else
	fail "Custom name flag did not work correctly"
fi

# Test 10: Custom delimiter flag
print_test "Testing --delim flag with custom delimiter"
OUTPUT_DELIM=$(./multipress -d '||' -t 1 -- echo 'alpha' '||' echo 'beta' && sleep 1.5 2>&1)
if [[ $OUTPUT_DELIM == *"alpha"* ]]; then
	pass "Custom delimiter flag works correctly"
else
	fail "Custom delimiter flag did not work correctly"
fi

# Test 11: List instances
print_test "Testing --list flag"
LIST_OUTPUT=$(./multipress --list 2>&1)
if [[ $LIST_OUTPUT == *"Active multipress instances"* ]]; then
	pass "List flag works correctly"
else
	fail "List flag did not work correctly"
fi

# Test 12: Cleanup flag
print_test "Testing --cleanup flag"
CLEANUP_OUTPUT=$(./multipress --cleanup 2>&1)
if [[ $CLEANUP_OUTPUT == *"Cleaning up stale FIFO files"* ]]; then
	pass "Cleanup flag works correctly"
else
	fail "Cleanup flag did not work correctly"
fi

# Test 13: Single command execution
print_test "Testing single command execution"
OUTPUT_SINGLE=$(./multipress -t 0.5 -- echo 'single' && sleep 1 2>&1)
if [[ $OUTPUT_SINGLE == *"single"* ]]; then
	pass "Single command execution works correctly"
else
	fail "Single command execution did not work"
fi

# Test 14: Timeout functionality
print_test "Testing timeout functionality (should execute 1st command)"
OUTPUT_TIMEOUT=$(./multipress -t 0.3 -- echo 'first' __ echo 'second' && sleep 0.5 2>&1)
if [[ $OUTPUT_TIMEOUT == *"first"* ]] && [[ $OUTPUT_TIMEOUT != *"second"* ]]; then
	pass "Timeout functionality works correctly"
else
	fail "Timeout functionality did not work correctly"
fi

# Summary
echo ""
echo "=========================================="
echo "  TEST SUMMARY"
echo "=========================================="
echo "Total tests: $TESTS_TOTAL"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo "=========================================="

if [ $TESTS_FAILED -eq 0 ]; then
	echo -e "${GREEN}All tests passed!${NC}"
	exit 0
else
	echo -e "${RED}Some tests failed!${NC}"
	exit 1
fi
