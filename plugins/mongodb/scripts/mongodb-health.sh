#!/usr/bin/env bash
#
# mongodb-health.sh — Check MongoDB connection health, replica set status, and basic diagnostics
#
# Usage:
#   ./scripts/mongodb-health.sh                  # Check health using MONGODB_URI env var
#   ./scripts/mongodb-health.sh <connection-uri>  # Check health using provided URI
#   ./scripts/mongodb-health.sh --status          # Show detailed replica set and server status
#   ./scripts/mongodb-health.sh --indexes <db>    # Show index usage for all collections in a database
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_title() { echo -e "\n${BLUE}=== $* ===${NC}"; }

# Check prerequisites
if ! command -v mongosh &> /dev/null; then
  log_error "mongosh is not installed."
  echo "  Install via: brew install mongosh (macOS) or see https://www.mongodb.com/docs/mongodb-shell/install/"
  echo "  Or use Docker: docker exec -it mongodb-dev mongosh"
  exit 1
fi

# Determine connection URI
MONGO_URI="${1:-${MONGODB_URI:-mongodb://localhost:27017}}"
COMMAND="${1:-}"

# Remove command flags from URI
if [[ "$COMMAND" == --* ]]; then
  MONGO_URI="${MONGODB_URI:-mongodb://localhost:27017}"
fi

# --- Ping Test ---
check_connection() {
  log_title "Connection Check"
  if mongosh "$MONGO_URI" --quiet --eval "db.runCommand({ ping: 1 }).ok" 2>/dev/null | grep -q "1"; then
    log_info "MongoDB is reachable at: $MONGO_URI"
  else
    log_error "Cannot connect to MongoDB at: $MONGO_URI"
    exit 1
  fi
}

# --- Basic Server Info ---
show_server_info() {
  log_title "Server Information"
  mongosh "$MONGO_URI" --quiet --eval "
    const info = db.serverStatus();
    print('  Version:       ' + info.version);
    print('  Uptime:        ' + Math.round(info.uptime / 3600) + ' hours');
    print('  Connections:   ' + info.connections.current + ' current / ' + info.connections.available + ' available');
    print('  Storage Engine:' + info.storageEngine.name);
  " 2>/dev/null || log_warn "Could not retrieve server info (may lack permissions)"
}

# --- Database Stats ---
show_db_stats() {
  log_title "Database Statistics"
  mongosh "$MONGO_URI" --quiet --eval "
    const stats = db.stats();
    print('  Database:      ' + stats.db);
    print('  Collections:   ' + stats.collections);
    print('  Documents:     ' + stats.objects);
    print('  Data Size:     ' + (stats.dataSize / 1024 / 1024).toFixed(2) + ' MB');
    print('  Storage Size:  ' + (stats.storageSize / 1024 / 1024).toFixed(2) + ' MB');
    print('  Index Size:    ' + (stats.indexSize / 1024 / 1024).toFixed(2) + ' MB');
    print('  Indexes:       ' + stats.indexes);
  " 2>/dev/null || log_warn "Could not retrieve database stats"
}

# --- Collection Details ---
show_collections() {
  log_title "Collections"
  mongosh "$MONGO_URI" --quiet --eval "
    const colls = db.getCollectionInfos();
    if (colls.length === 0) {
      print('  No collections found.');
    } else {
      colls.forEach(c => {
        const stats = db.getCollection(c.name).stats();
        print('  ' + c.name.padEnd(30) + ' docs: ' + String(stats.count).padStart(8) + '   size: ' + (stats.size / 1024).toFixed(1).padStart(8) + ' KB   indexes: ' + stats.nindexes);
      });
    }
  " 2>/dev/null || log_warn "Could not retrieve collection info"
}

# --- Replica Set Status ---
show_replica_status() {
  log_title "Replica Set Status"
  mongosh "$MONGO_URI" --quiet --eval "
    try {
      const status = rs.status();
      print('  Set Name:    ' + status.set);
      print('  Members:');
      status.members.forEach(m => {
        const state = m.stateStr.padEnd(12);
        const health = m.health === 1 ? 'healthy' : 'UNHEALTHY';
        print('    ' + m.name.padEnd(30) + ' ' + state + ' ' + health);
      });
    } catch (e) {
      print('  Not a replica set (standalone instance)');
    }
  " 2>/dev/null || log_warn "Could not retrieve replica set status"
}

# --- Index Usage ---
show_index_usage() {
  local db_name="${2:-}"
  log_title "Index Usage Statistics"
  if [ -z "$db_name" ]; then
    db_name=$(mongosh "$MONGO_URI" --quiet --eval "db.getName()" 2>/dev/null)
  fi
  mongosh "$MONGO_URI" --quiet --eval "
    const colls = db.getCollectionNames();
    colls.forEach(collName => {
      print('\\n  Collection: ' + collName);
      const indexes = db.getCollection(collName).aggregate([{\$indexStats: {}}]).toArray();
      if (indexes.length === 0) {
        print('    No index stats available');
      } else {
        indexes.forEach(idx => {
          const ops = String(idx.accesses.ops).padStart(8);
          print('    ' + idx.name.padEnd(40) + ' ops: ' + ops + '   since: ' + idx.accesses.since.toISOString().split('T')[0]);
        });
      }
    });
  " 2>/dev/null || log_warn "Could not retrieve index stats (requires replica set)"
}

# --- Main ---
case "${COMMAND}" in
  --status)
    check_connection
    show_server_info
    show_db_stats
    show_collections
    show_replica_status
    ;;
  --indexes)
    check_connection
    show_index_usage "$@"
    ;;
  *)
    check_connection
    show_server_info
    show_db_stats
    show_collections
    ;;
esac

echo ""
log_info "Health check complete."
