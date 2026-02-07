#!/usr/bin/env bash
#
# sentry-release.sh — Create a Sentry release, associate commits, upload
# source maps, finalize the release, and record a deployment.
#
# Required environment variables:
#   SENTRY_AUTH_TOKEN   — Sentry API auth token
#   SENTRY_ORG          — Sentry organization slug
#   SENTRY_PROJECT      — Sentry project slug
#
# Optional environment variables:
#   SENTRY_ENVIRONMENT  — Deployment environment (default: production)
#   SENTRY_RELEASE      — Release version (default: short git SHA)
#   SOURCE_MAP_PATH     — Path to source map directory (default: ./dist)
#   URL_PREFIX          — URL prefix for source maps (default: ~/)
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SENTRY_ENVIRONMENT="${SENTRY_ENVIRONMENT:-production}"
SENTRY_RELEASE="${SENTRY_RELEASE:-$(git rev-parse --short HEAD)}"
SOURCE_MAP_PATH="${SOURCE_MAP_PATH:-./dist}"
URL_PREFIX="${URL_PREFIX:-~/}"

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------
missing_vars=()
[ -z "${SENTRY_AUTH_TOKEN:-}" ] && missing_vars+=("SENTRY_AUTH_TOKEN")
[ -z "${SENTRY_ORG:-}" ]        && missing_vars+=("SENTRY_ORG")
[ -z "${SENTRY_PROJECT:-}" ]    && missing_vars+=("SENTRY_PROJECT")

if [ ${#missing_vars[@]} -gt 0 ]; then
  echo "ERROR: Missing required environment variables: ${missing_vars[*]}" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Ensure sentry-cli is available
# ---------------------------------------------------------------------------
if ! command -v sentry-cli &>/dev/null; then
  echo "INFO: sentry-cli not found, installing via npm..."
  npm install -g @sentry/cli
fi

echo "============================================="
echo "  Sentry Release"
echo "============================================="
echo "  Organization : ${SENTRY_ORG}"
echo "  Project      : ${SENTRY_PROJECT}"
echo "  Release      : ${SENTRY_RELEASE}"
echo "  Environment  : ${SENTRY_ENVIRONMENT}"
echo "  Source Maps   : ${SOURCE_MAP_PATH}"
echo "============================================="

# ---------------------------------------------------------------------------
# Step 1: Create the release
# ---------------------------------------------------------------------------
echo ""
echo ">>> Creating release ${SENTRY_RELEASE}..."
sentry-cli releases new "${SENTRY_RELEASE}" \
  --org "${SENTRY_ORG}" \
  --project "${SENTRY_PROJECT}"

# ---------------------------------------------------------------------------
# Step 2: Associate commits
# ---------------------------------------------------------------------------
echo ""
echo ">>> Associating commits..."
sentry-cli releases set-commits "${SENTRY_RELEASE}" \
  --org "${SENTRY_ORG}" \
  --auto || echo "WARN: Could not associate commits (missing repo integration?)"

# ---------------------------------------------------------------------------
# Step 3: Upload source maps
# ---------------------------------------------------------------------------
if [ -d "${SOURCE_MAP_PATH}" ]; then
  echo ""
  echo ">>> Uploading source maps from ${SOURCE_MAP_PATH}..."
  sentry-cli releases files "${SENTRY_RELEASE}" upload-sourcemaps \
    "${SOURCE_MAP_PATH}" \
    --org "${SENTRY_ORG}" \
    --project "${SENTRY_PROJECT}" \
    --url-prefix "${URL_PREFIX}" \
    --rewrite
else
  echo ""
  echo "WARN: Source map directory '${SOURCE_MAP_PATH}' does not exist — skipping upload."
fi

# ---------------------------------------------------------------------------
# Step 4: Finalize the release
# ---------------------------------------------------------------------------
echo ""
echo ">>> Finalizing release ${SENTRY_RELEASE}..."
sentry-cli releases finalize "${SENTRY_RELEASE}" \
  --org "${SENTRY_ORG}"

# ---------------------------------------------------------------------------
# Step 5: Record the deployment
# ---------------------------------------------------------------------------
echo ""
echo ">>> Recording deployment to ${SENTRY_ENVIRONMENT}..."
sentry-cli releases deploys "${SENTRY_RELEASE}" new \
  --org "${SENTRY_ORG}" \
  --env "${SENTRY_ENVIRONMENT}" \
  --name "deploy-$(date +%s)"

echo ""
echo "============================================="
echo "  Sentry release ${SENTRY_RELEASE} complete!"
echo "============================================="
