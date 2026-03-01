#!/usr/bin/env bash
# verify_guide.sh
# Verifies that a guide YAML has been CUE-validated and has not changed since
# it was signed by validate_and_sign.sh.
#
# Usage:  ./verify_guide.sh <guide.yml>
# Exit code 0: valid and unmodified
# Exit code 1: missing signature or hash mismatch

set -euo pipefail

FILE="${1:?Usage: verify_guide.sh <guide.yml>}"

if [ ! -f "$FILE" ]; then
  echo "Error: file not found: $FILE" >&2
  exit 1
fi

# Extract the stored hash value
STORED_HASH=$(yq '."cue.verified" // ""' "$FILE")

if [ -z "$STORED_HASH" ] || [ "$STORED_HASH" = "null" ]; then
  echo "FAIL: no 'cue.verified' field found in $FILE" >&2
  echo "      Run validate_and_sign.sh to validate with CUE and embed a hash." >&2
  exit 1
fi

# Strip the cue.verified field and recompute the hash, identical to validate_and_sign.sh
TMPFILE=$(mktemp /tmp/guide_XXXXXX.yml)
trap 'rm -f "$TMPFILE"' EXIT

yq 'del(.["cue.verified"])' "$FILE" > "$TMPFILE"
CURRENT_HASH="sha256:$(sha256sum "$TMPFILE" | cut -d' ' -f1)"

# Compare stored vs recomputed
if [ "$STORED_HASH" = "$CURRENT_HASH" ]; then
  echo "OK: $FILE"
  echo "    Signed with: $STORED_HASH"
else
  echo "FAIL: $FILE — hash mismatch, file was modified after signing." >&2
  echo "  stored:  $STORED_HASH" >&2
  echo "  current: $CURRENT_HASH" >&2
  exit 1
fi
