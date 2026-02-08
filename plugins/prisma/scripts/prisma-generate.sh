#!/usr/bin/env bash
#
# Prisma Client Generation and Schema Management Script
# Usage: ./scripts/prisma-generate.sh [command]
#
# Commands:
#   generate    Generate the Prisma Client (default)
#   validate    Validate the Prisma schema
#   format      Format the Prisma schema file
#   push        Push schema changes directly to the database (no migration)
#   pull        Pull the database schema into Prisma schema
#   studio      Open Prisma Studio
#   status      Show migration status
#   migrate     Create and apply a new migration
#   deploy      Deploy pending migrations (production)
#   reset       Reset the database and re-apply all migrations
#   seed        Run the database seed script
#   help        Show this help message

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

check_prerequisites() {
  if ! command -v node &> /dev/null; then
    error "Node.js is not installed. Please install Node.js v18 or later."
  fi

  if ! command -v npx &> /dev/null; then
    error "npx is not available. Please install npm."
  fi

  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 18 ]; then
    warn "Node.js v18+ is recommended. Current version: $(node -v)"
  fi
}

check_schema() {
  if [ ! -f "prisma/schema.prisma" ]; then
    error "prisma/schema.prisma not found. Run 'npx prisma init' first."
  fi
}

check_env() {
  if [ ! -f ".env" ]; then
    warn ".env file not found. Make sure DATABASE_URL is set."
  elif ! grep -q "DATABASE_URL" .env 2>/dev/null; then
    warn "DATABASE_URL not found in .env file."
  fi
}

cmd_generate() {
  info "Generating Prisma Client..."
  check_prerequisites
  check_schema

  npx prisma generate

  success "Prisma Client generated successfully."
}

cmd_validate() {
  info "Validating Prisma schema..."
  check_prerequisites
  check_schema

  npx prisma validate

  success "Schema is valid."
}

cmd_format() {
  info "Formatting Prisma schema..."
  check_prerequisites
  check_schema

  npx prisma format

  success "Schema formatted."
}

cmd_push() {
  info "Pushing schema to database (no migration)..."
  check_prerequisites
  check_schema
  check_env

  npx prisma db push

  success "Schema pushed to database."
}

cmd_pull() {
  info "Pulling schema from database..."
  check_prerequisites
  check_env

  npx prisma db pull

  success "Schema pulled from database into prisma/schema.prisma."
}

cmd_studio() {
  info "Opening Prisma Studio..."
  check_prerequisites
  check_schema
  check_env

  npx prisma studio
}

cmd_status() {
  info "Checking migration status..."
  check_prerequisites
  check_schema
  check_env

  npx prisma migrate status
}

cmd_migrate() {
  info "Creating migration..."
  check_prerequisites
  check_schema
  check_env

  local name="${1:-$(date +%Y%m%d_%H%M%S)}"

  npx prisma migrate dev --name "$name"

  success "Migration '$name' created and applied."
}

cmd_deploy() {
  info "Deploying migrations to production..."
  check_prerequisites
  check_schema
  check_env

  npx prisma migrate deploy

  success "Migrations deployed."
}

cmd_reset() {
  warn "This will reset your database and delete all data!"
  read -r -p "Are you sure? (y/N) " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    info "Resetting database..."
    npx prisma migrate reset --force
    success "Database reset complete."
  else
    info "Reset cancelled."
  fi
}

cmd_seed() {
  info "Running seed script..."
  check_prerequisites
  check_schema
  check_env

  npx prisma db seed

  success "Database seeded."
}

cmd_help() {
  echo ""
  echo "Prisma Client Generation and Schema Management"
  echo "================================================"
  echo ""
  echo "Usage: $0 [command] [args]"
  echo ""
  echo "Commands:"
  echo "  generate          Generate the Prisma Client (default)"
  echo "  validate          Validate the Prisma schema"
  echo "  format            Format the Prisma schema file"
  echo "  push              Push schema to database (no migration history)"
  echo "  pull              Pull database schema into Prisma schema"
  echo "  studio            Open Prisma Studio"
  echo "  status            Show migration status"
  echo "  migrate [name]    Create and apply a new migration"
  echo "  deploy            Deploy pending migrations (production)"
  echo "  reset             Reset the database (with confirmation)"
  echo "  seed              Run the database seed script"
  echo "  help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0                        # Default: generate client"
  echo "  $0 generate               # Generate Prisma Client"
  echo "  $0 validate               # Validate schema"
  echo "  $0 migrate add_users      # Create migration named 'add_users'"
  echo "  $0 deploy                 # Deploy to production"
  echo "  $0 seed                   # Seed the database"
  echo ""
}

# Main command dispatcher
COMMAND="${1:-generate}"
shift || true

case "$COMMAND" in
  generate)  cmd_generate ;;
  validate)  cmd_validate ;;
  format)    cmd_format ;;
  push)      cmd_push ;;
  pull)      cmd_pull ;;
  studio)    cmd_studio ;;
  status)    cmd_status ;;
  migrate)   cmd_migrate "$@" ;;
  deploy)    cmd_deploy ;;
  reset)     cmd_reset ;;
  seed)      cmd_seed ;;
  help)      cmd_help ;;
  *)
    error "Unknown command: $COMMAND. Run '$0 help' for usage."
    ;;
esac
