#!/usr/bin/env bash
#
# check-secrets.sh — Detect accidental secret leaks in staged files.
# Used as a pre-commit hook and can also be run standalone.
#
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ERRORS=0

# ── 1. Forbidden file patterns ──────────────────────────────────────────────
# Files that should NEVER be committed regardless of content.
# Combined into a single extended regex for one-pass matching.
FORBIDDEN_PATTERN='(\.env|\.env\.local|\.env\.production|\.env\.development|id_rsa|id_ed25519|\.pem|\.key|\.p12|\.pfx|\.keystore|\.jks|credentials\.json|service-account.*\.json|google-services\.json|GoogleService-Info\.plist)$'

# ── 2. Suspicious content patterns ──────────────────────────────────────────
# Combined into a single extended regex for one-pass matching.
# IMPORTANT: Order matters — put longer/more specific patterns first.
COMBINED_SECRET_PATTERN='(AKIA[0-9A-Z]{16}|sk-ant-[a-zA-Z0-9-]{20,}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{22,}|xoxb-[0-9]{10,}-[0-9]{10,}-[a-zA-Z0-9]{24}|xoxp-[0-9]{10,}-[0-9]{10,}-[a-zA-Z0-9]{24}|hooks\.slack\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[a-zA-Z0-9]+|AIza[0-9A-Za-z_-]{35}|-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----|BRIDGE_API_KEY[[:space:]]*=[[:space:]]*["\x27][^"\x27]{8,}|password[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}|secret[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}|token[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,})'

# ── 3. Allowlist ────────────────────────────────────────────────────────────
ALLOWLIST_PATTERN='(YOUR_SECRET_KEY_HERE|YOUR_USERNAME|your[-_]?api[-_]?key|placeholder|example\.com|test[-_]?key|dummy|xxxx|check-secrets\.sh|FIREBASE_API_KEY|mock-id-token)'

# ── Get staged files ────────────────────────────────────────────────────────
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)

if [ -z "$STAGED_FILES" ]; then
  echo "No staged files to check."
  exit 0
fi

# ── Check 1: Forbidden files ───────────────────────────────────────────────
echo "Checking for forbidden files..."
BLOCKED=$(echo "$STAGED_FILES" | grep -E "$FORBIDDEN_PATTERN" || true)
if [ -n "$BLOCKED" ]; then
  while IFS= read -r file; do
    echo -e "${RED}BLOCKED${NC}: $file matches forbidden file pattern"
    ERRORS=$((ERRORS + 1))
  done <<< "$BLOCKED"
fi

# ── Check 2: Secret patterns in staged content ────────────────────────────
# Pure pipe-based approach: extract added lines from diff, grep secrets,
# filter allowlist — all in a single pipeline (3-4 processes total).
echo "Scanning staged content for secrets..."
MATCHES=$(git diff --cached --diff-filter=ACMR -U0 -- . 2>/dev/null \
  | grep -E '^\+[^+]' \
  | grep -Ei "$COMBINED_SECRET_PATTERN" \
  | grep -viE "$ALLOWLIST_PATTERN" \
  || true)

if [ -n "$MATCHES" ]; then
  echo -e "${RED}BLOCKED${NC}: Potential secrets found in staged content:"
  echo "$MATCHES" | head -10 | while IFS= read -r line; do
    echo -e "  ${YELLOW}>${NC} ${line:1}"
  done
  ERRORS=$((ERRORS + 1))
fi

# ── Check 3: Large files (might be binaries / data dumps) ─────────────────
echo "Checking for large files..."
echo "$STAGED_FILES" | while IFS= read -r file; do
  if [ -f "$file" ]; then
    SIZE=$(wc -c < "$file" 2>/dev/null || echo 0)
    # 1MB threshold
    if [ "$SIZE" -gt 1048576 ]; then
      echo -e "${YELLOW}WARNING${NC}: Large file ($((SIZE / 1024))KB): $file"
      echo "  Consider adding to .gitignore if this is generated/binary."
    fi
  fi
done

# ── Result ─────────────────────────────────────────────────────────────────
echo ""
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}Secret check failed with $ERRORS issue(s).${NC}"
  echo ""
  echo "If this is a false positive, you can:"
  echo "  1. Add the pattern to ALLOWLIST in scripts/check-secrets.sh"
  echo "  2. Bypass with: git commit --no-verify (use with caution!)"
  exit 1
else
  echo "Secret check passed."
  exit 0
fi
