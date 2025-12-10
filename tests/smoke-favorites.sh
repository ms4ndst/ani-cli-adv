#!/usr/bin/env sh
set -eu

# Simple smoke test for favorites helpers (no network, no player).
# It validates add/remove behavior and file format.

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

favorites_file="$tmpdir/favorites"
: >"$favorites_file"

add_favorite_current() {
    [ ! -f "$favorites_file" ] && : >"$favorites_file"
    if ! grep -q "^${id}\t" "$favorites_file" 2>/dev/null; then
        printf "%s\t%s\n" "$id" "$title" >>"$favorites_file"
    fi
}

remove_favorite_current() {
    [ -f "$favorites_file" ] || return 0
    if grep -q "^${id}\t" "$favorites_file" 2>/dev/null; then
        sed "/^${id}\t/d" "$favorites_file" >"${favorites_file}.new" && mv "${favorites_file}.new" "$favorites_file"
    fi
}

list_favorites() {
    [ -f "$favorites_file" ] && [ -s "$favorites_file" ] && cat "$favorites_file" || true
}

fail() { echo "FAIL: $*" >&2; exit 1; }
assert_grep() { pattern="$1"; file="$2"; grep -q "$pattern" "$file" || fail "pattern not found: $pattern in $file"; }
assert_lines() { expected="$1"; file="$2"; c=$(wc -l <"$file" | tr -d '[:space:]'); [ "$c" = "$expected" ] || fail "expected $expected lines, got $c"; }

# Add once
id="abc"; title="Dummy (12 episodes)"; add_favorite_current
# Validate using field-based checks to avoid regex tab portability issues
f1=$(cut -f1 "$favorites_file" | tr -d '\r')
f2=$(cut -f2 "$favorites_file" | tr -d '\r')
[ "$f1" = "abc" ] || fail "id field mismatch: $f1"
[ "$f2" = "Dummy (12 episodes)" ] || fail "title field mismatch: $f2"
assert_lines 1 "$favorites_file"

# Add again (should not duplicate)
add_favorite_current
assert_lines 1 "$favorites_file"

# Remove
remove_favorite_current
[ ! -s "$favorites_file" ] || fail "favorites file not empty after removal"

echo "OK: smoke-favorites passed"
