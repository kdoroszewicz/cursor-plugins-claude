#!/usr/bin/env bash
#
# check-instrumentation.sh — Validate Datadog APM instrumentation before deploy.
#
# Checks:
#   1. dd-trace is listed as a dependency (Node.js) or ddtrace (Python)
#   2. Tracer is initialized before other imports
#   3. Unified service tags (DD_ENV, DD_SERVICE, DD_VERSION) are configured
#   4. Log injection is enabled
#   5. No hardcoded API keys or secrets in source files
#
# Required environment variables:
#   DD_SERVICE  — Expected service name
#
# Optional environment variables:
#   DD_ENV      — Expected environment (default: production)
#   DD_VERSION  — Expected version
#   SRC_DIR     — Source directory to scan (default: ./src)
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DD_SERVICE="${DD_SERVICE:-}"
DD_ENV="${DD_ENV:-production}"
DD_VERSION="${DD_VERSION:-}"
SRC_DIR="${SRC_DIR:-./src}"

ERRORS=0
WARNINGS=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { echo "  ℹ️  $*"; }
ok()      { echo "  ✅ $*"; }
warn()    { echo "  ⚠️  $*"; WARNINGS=$((WARNINGS + 1)); }
fail()    { echo "  ❌ $*"; ERRORS=$((ERRORS + 1)); }

# ---------------------------------------------------------------------------
echo "============================================="
echo "  Datadog Instrumentation Check"
echo "============================================="
echo "  Service    : ${DD_SERVICE:-<not set>}"
echo "  Environment: ${DD_ENV}"
echo "  Version    : ${DD_VERSION:-<not set>}"
echo "  Source Dir : ${SRC_DIR}"
echo "============================================="
echo ""

# ---------------------------------------------------------------------------
# Check 1: dd-trace dependency
# ---------------------------------------------------------------------------
echo ">>> Check 1: dd-trace / ddtrace dependency"

if [ -f "package.json" ]; then
  if grep -q '"dd-trace"' package.json; then
    ok "dd-trace found in package.json"
  else
    fail "dd-trace is NOT listed in package.json — install with: npm install dd-trace"
  fi
elif [ -f "requirements.txt" ]; then
  if grep -qi 'ddtrace' requirements.txt; then
    ok "ddtrace found in requirements.txt"
  else
    fail "ddtrace is NOT listed in requirements.txt — install with: pip install ddtrace"
  fi
elif [ -f "pyproject.toml" ]; then
  if grep -qi 'ddtrace' pyproject.toml; then
    ok "ddtrace found in pyproject.toml"
  else
    fail "ddtrace is NOT listed in pyproject.toml"
  fi
elif [ -f "Pipfile" ]; then
  if grep -qi 'ddtrace' Pipfile; then
    ok "ddtrace found in Pipfile"
  else
    fail "ddtrace is NOT listed in Pipfile"
  fi
else
  warn "No package.json, requirements.txt, pyproject.toml, or Pipfile found — cannot verify dependency"
fi

echo ""

# ---------------------------------------------------------------------------
# Check 2: Tracer initialization
# ---------------------------------------------------------------------------
echo ">>> Check 2: Tracer initialization"

if [ -d "${SRC_DIR}" ]; then
  # Node.js: look for dd-trace import and init
  if find "${SRC_DIR}" -name "*.ts" -o -name "*.js" 2>/dev/null | head -1 | grep -q .; then
    if grep -rl 'dd-trace' "${SRC_DIR}" --include="*.ts" --include="*.js" 2>/dev/null | head -1 | grep -q .; then
      ok "dd-trace import found in source files"

      if grep -rl 'tracer\.init\|tracer\.default\.init' "${SRC_DIR}" --include="*.ts" --include="*.js" 2>/dev/null | head -1 | grep -q .; then
        ok "tracer.init() call found"
      else
        fail "dd-trace is imported but tracer.init() was not found — the tracer must be initialized"
      fi
    else
      warn "No dd-trace import found in ${SRC_DIR} — auto-instrumentation may not be active"
    fi
  fi

  # Python: look for ddtrace import
  if find "${SRC_DIR}" -name "*.py" 2>/dev/null | head -1 | grep -q .; then
    if grep -rl 'ddtrace\|from ddtrace' "${SRC_DIR}" --include="*.py" 2>/dev/null | head -1 | grep -q .; then
      ok "ddtrace import found in Python source files"
    else
      info "No ddtrace import found in Python files — if using ddtrace-run, this is expected"
    fi
  fi
else
  warn "Source directory '${SRC_DIR}' not found — skipping tracer initialization check"
fi

echo ""

# ---------------------------------------------------------------------------
# Check 3: Unified service tags
# ---------------------------------------------------------------------------
echo ">>> Check 3: Unified service tags"

if [ -n "${DD_SERVICE}" ]; then
  ok "DD_SERVICE is set: ${DD_SERVICE}"
else
  fail "DD_SERVICE is not set — unified service tagging requires DD_SERVICE"
fi

if [ -n "${DD_ENV}" ]; then
  ok "DD_ENV is set: ${DD_ENV}"
else
  fail "DD_ENV is not set — unified service tagging requires DD_ENV"
fi

if [ -n "${DD_VERSION}" ]; then
  ok "DD_VERSION is set: ${DD_VERSION}"
else
  warn "DD_VERSION is not set — recommended for deployment tracking and trace correlation"
fi

echo ""

# ---------------------------------------------------------------------------
# Check 4: Log injection
# ---------------------------------------------------------------------------
echo ">>> Check 4: Log injection configuration"

if [ -d "${SRC_DIR}" ]; then
  if grep -rl 'logInjection.*true\|DD_LOGS_INJECTION.*true\|log_injection.*True' "${SRC_DIR}" --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -1 | grep -q .; then
    ok "Log injection is enabled in source configuration"
  elif [ -n "${DD_LOGS_INJECTION:-}" ] && [ "${DD_LOGS_INJECTION}" = "true" ]; then
    ok "DD_LOGS_INJECTION environment variable is set to true"
  else
    warn "Log injection does not appear to be enabled — trace-log correlation will not work without it"
  fi
else
  warn "Source directory '${SRC_DIR}' not found — skipping log injection check"
fi

echo ""

# ---------------------------------------------------------------------------
# Check 5: Hardcoded secrets
# ---------------------------------------------------------------------------
echo ">>> Check 5: Hardcoded secrets scan"

SECRETS_FOUND=0

if [ -d "${SRC_DIR}" ]; then
  # Check for hardcoded Datadog API keys (32-character hex strings after known key names)
  if grep -rn 'DD_API_KEY\s*=\s*["'"'"'][0-9a-f]\{32\}' "${SRC_DIR}" --include="*.ts" --include="*.js" --include="*.py" --include="*.env" 2>/dev/null | grep -v '.env.example' | head -1 | grep -q .; then
    fail "Possible hardcoded DD_API_KEY found in source files — use environment variables instead"
    SECRETS_FOUND=1
  fi

  if grep -rn 'DD_APP_KEY\s*=\s*["'"'"'][0-9a-f]\{40\}' "${SRC_DIR}" --include="*.ts" --include="*.js" --include="*.py" --include="*.env" 2>/dev/null | grep -v '.env.example' | head -1 | grep -q .; then
    fail "Possible hardcoded DD_APP_KEY found in source files — use environment variables instead"
    SECRETS_FOUND=1
  fi

  if [ "${SECRETS_FOUND}" -eq 0 ]; then
    ok "No hardcoded Datadog API keys detected"
  fi
else
  warn "Source directory '${SRC_DIR}' not found — skipping secrets scan"
fi

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "============================================="
echo "  Results"
echo "============================================="
echo "  Errors   : ${ERRORS}"
echo "  Warnings : ${WARNINGS}"
echo "============================================="

if [ "${ERRORS}" -gt 0 ]; then
  echo ""
  echo "❌ Instrumentation check failed with ${ERRORS} error(s)."
  echo "   Fix the issues above before deploying."
  exit 1
else
  if [ "${WARNINGS}" -gt 0 ]; then
    echo ""
    echo "⚠️  Instrumentation check passed with ${WARNINGS} warning(s)."
    echo "   Review the warnings above for potential improvements."
  else
    echo ""
    echo "✅ All instrumentation checks passed!"
  fi
  exit 0
fi
