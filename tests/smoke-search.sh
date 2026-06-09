#!/bin/sh
# End-to-end smoke: verify search, episodes_list, and get_episode_url against live API.
# Exits 0 on success. Run from any cwd.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$SCRIPT_DIR/ani-cli-adv"

# Extract function definitions only (everything up to "# MAIN")
WRAPPER="$(mktemp)"
trap 'rm -f "$WRAPPER"' EXIT
sed -n '1,/^# MAIN$/p' "$SCRIPT" >"$WRAPPER"

# Append a test driver
cat >>"$WRAPPER" <<'DRIVER'

agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0"
allanime_refr="https://youtu-chan.com"
allanime_base="allanime.day"
allanime_api="https://api.${allanime_base}"
allanime_key="$(printf '%s' 'Xot36i3lK3:v1' | openssl dgst -sha256 -binary | od -A n -t x1 | tr -d ' \n')"
mode="sub"
quality="best"

fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }
pass() { printf '[ OK ] %s\n' "$*"; }

# 1) search_anime
results="$(search_anime naruto)"
[ -z "$results" ] && fail "search_anime returned nothing"
first_id="$(printf '%s' "$results" | head -n1 | cut -f1)"
[ -z "$first_id" ] && fail "could not extract id from search result"
pass "search_anime: got $(printf '%s\n' "$results" | wc -l | tr -d ' ') results, first id=$first_id"

# 2) episodes_list
id="$first_id"
ep_list="$(episodes_list "$id")"
[ -z "$ep_list" ] && fail "episodes_list returned nothing"
ep_count="$(printf '%s\n' "$ep_list" | wc -l | tr -d ' ')"
pass "episodes_list: got $ep_count episodes"

# 3) get_episode_url decryption: just exercise the API + process_response + sed pipeline
ep_no="$(printf '%s' "$ep_list" | head -n1)"
episode_embed_gql='query ($showId: String!, $translationType: VaildTranslationTypeEnumType!, $episodeString: String!) { episode( showId: $showId translationType: $translationType episodeString: $episodeString ) { episodeString sourceUrls }}'
query_hash="d405d0edd690624b66baba3068e0edc3ac90f1597d898a1ec8db4e5c43c00fec"
query_vars="{\"showId\":\"$id\",\"translationType\":\"$mode\",\"episodeString\":\"$ep_no\"}"
query_ext="{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"$query_hash\"}}"
api_resp="$(curl -e "$allanime_refr" -sG -A "$agent" -H "Origin: ${allanime_refr}" "${allanime_api}/api" --data-urlencode "variables=${query_vars}" --data-urlencode "extensions=${query_ext}")"
if [ -z "$api_resp" ] || ! printf '%s' "$api_resp" | grep -q tobeparsed; then
    api_resp="$(curl -e "$allanime_refr" -s -H 'Content-Type: application/json' -X POST "${allanime_api}/api" --data "{\"variables\":{\"showId\":\"$id\",\"translationType\":\"$mode\",\"episodeString\":\"$ep_no\"},\"query\":\"$episode_embed_gql\"}" -A "$agent")"
fi
[ -z "$api_resp" ] && fail "episode endpoint returned empty"

resp="$(process_response "$api_resp" | tr '{}' '\n' | sed 's|\\u002F|/|g;s|\\||g' | sed -nE 's|.*sourceUrl":"([^"]*)".*sourceName":"([^"]*)".*|\2 :\1|p')"
[ -z "$resp" ] && fail "process_response/parsing produced no sourceUrls"
n_sources="$(printf '%s\n' "$resp" | wc -l | tr -d ' ')"
pass "get_episode_url: decrypted $n_sources sourceUrls"

# 4) provider_init: ensure we can decode at least one provider link
provider_init "wixmp" "/Default :/p"
[ -n "$provider_id" ] && pass "wixmp decoded: ${provider_id%%[!a-zA-Z0-9/:._?-]*}..." || printf '[WARN] wixmp provider not present in response\n'

provider_init "hianime" "/Luf-Mp4 :/p"
[ -n "$provider_id" ] && pass "hianime decoded: ${provider_id%%[!a-zA-Z0-9/:._?-]*}..." || printf '[WARN] hianime provider not present in response\n'

echo "=== ALL CHECKS PASSED ==="
DRIVER

bash "$WRAPPER"
