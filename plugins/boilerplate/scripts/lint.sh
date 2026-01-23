#!/bin/bash
# Pre-commit lint hook script
# This script runs linting checks before commits

set -e

echo "Running lint checks..."

# TypeScript/JavaScript linting
if command -v npx &> /dev/null; then
    if [ -f "package.json" ]; then
        echo "Running ESLint..."
        npx eslint . --ext .ts,.tsx,.js,.jsx --max-warnings 0 || exit 1
    fi
fi

# Python linting
if command -v ruff &> /dev/null; then
    echo "Running Ruff..."
    ruff check . || exit 1
fi

echo "Lint checks passed!"
