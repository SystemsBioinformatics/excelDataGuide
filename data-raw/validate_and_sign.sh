#!/usr/bin/env bash
# validate_and_sign.sh
#
# Validates a guide YAML file against the CUE schema and, on success, embeds a
# SHA256 hash of the validated content into the file as the 'cue.verified' field.
# Running this script a second time on an already-signed file is safe: the
# existing 'cue.verified' field is stripped before hashing so the hash is stable.
#
# Usage:
#   ./validate_and_sign.sh <guide.yml>
#
# Example:
#   ./validate_and_sign.sh guide_competition_1_0_source.yml
#
# Requirements: cue, yq (go-yq), sha256sum
# Install via the accompanying shell.nix: nix-shell

set -euo pipefail

FILE="${1:?Usage: validate_and_sign.sh <guide.yml>}"
SCHEMA="$(dirname "$0")/excelguide_schema.cue"

# --------------------------------------------------------------------------- #
# Sanity checks
# --------------------------------------------------------------------------- #

if [ ! -f "$FILE" ]; then
  echo "Error: file not found: $FILE" >&2
  exit 1
fi

if [ ! -f "$SCHEMA" ]; then
  echo "Error: schema not found: $SCHEMA" >&2
  exit 1
fi

for cmd in cue yq sha256sum; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: required command not found: $cmd" >&2
    echo "       Start a nix-shell in this directory to get all dependencies." >&2
    exit 1
  fi
done

# --------------------------------------------------------------------------- #
# Prepare a stripped temporary copy (without any existing cue.verified field)
# --------------------------------------------------------------------------- #

TMPFILE=$(mktemp /tmp/guide_XXXXXX.yml)
trap 'rm -f "$TMPFILE"' EXIT

yq 'del(.["cue.verified"])' "$FILE" > "$TMPFILE"

# --------------------------------------------------------------------------- #
# CUE validation
# --------------------------------------------------------------------------- #

echo "Validating ${FILE} ..."

if ! cue vet -c "$SCHEMA" "$TMPFILE"; then
  echo ""
  echo "CUE validation FAILED — 'cue.verified' was NOT embedded." >&2
  exit 1
fi

# --------------------------------------------------------------------------- #
# Hash the yq-normalised content and embed it in the original file
#
# The hash is computed over the yq-normalised YAML (without cue.verified).
# yq normalises whitespace, quoting style, and key order within scalars,
# making the hash stable across cosmetic edits to the original file.
# --------------------------------------------------------------------------- #

HASH=$(sha256sum "$TMPFILE" | cut -d' ' -f1)

yq -i ".\"cue.verified\" = \"sha256:${HASH}\"" "$FILE"

echo "Validation passed."
echo "Embedded: sha256:${HASH}"
