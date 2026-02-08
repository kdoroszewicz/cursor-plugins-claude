#!/usr/bin/env bash
#
# deploy-firebase.sh — Deploy Firebase services with optional target selection
#
# Usage:
#   ./scripts/deploy-firebase.sh                    # Deploy all services
#   ./scripts/deploy-firebase.sh functions           # Deploy only Cloud Functions
#   ./scripts/deploy-firebase.sh hosting             # Deploy only Hosting
#   ./scripts/deploy-firebase.sh firestore           # Deploy Firestore rules + indexes
#   ./scripts/deploy-firebase.sh functions hosting    # Deploy multiple targets
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check prerequisites
if ! command -v firebase &> /dev/null; then
  log_error "Firebase CLI is not installed. Run: npm install -g firebase-tools"
  exit 1
fi

if ! firebase projects:list &> /dev/null 2>&1; then
  log_error "Not authenticated. Run: firebase login"
  exit 1
fi

# Determine deployment targets
TARGETS=("$@")

if [ ${#TARGETS[@]} -eq 0 ]; then
  log_info "Deploying all Firebase services..."
  firebase deploy
else
  ONLY_FLAG=$(IFS=,; echo "${TARGETS[*]}")
  log_info "Deploying: ${ONLY_FLAG}..."

  # Build Cloud Functions before deploying if functions is a target
  for target in "${TARGETS[@]}"; do
    if [ "$target" = "functions" ]; then
      log_info "Building Cloud Functions..."
      if [ -f "functions/package.json" ]; then
        (cd functions && npm run build)
      fi
      break
    fi
  done

  firebase deploy --only "$ONLY_FLAG"
fi

log_info "Deployment complete!"
