#!/bin/bash
# check_my_jobs.sh — Show the current user's Slurm jobs with resource totals.
# Usage: bash scripts/check_my_jobs.sh
set -uo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo "Shows your running and pending Slurm jobs with resource totals."
    exit 0
fi

echo "=== Jobs for $USER ==="
echo ""

# Running jobs
RUNNING=$(squeue --noheader -u "$USER" -t RUNNING \
    -o "%.10i %.30j %.12M %.12L %.6C %.20b %.N" 2>/dev/null)

RUNNING_COUNT=$(echo "$RUNNING" | grep -c . 2>/dev/null || true)
if [[ -z "$RUNNING" ]]; then
    RUNNING_COUNT=0
fi

echo "RUNNING ($RUNNING_COUNT jobs):"
if [[ $RUNNING_COUNT -gt 0 ]]; then
    printf "%-12s %-30s %-12s %-12s %-6s %-20s %s\n" "JOBID" "NAME" "ELAPSED" "REMAINING" "CPUS" "GRES" "NODE"
    echo "$RUNNING"
else
    echo "(none)"
fi
echo ""

# Pending jobs
PENDING=$(squeue --noheader -u "$USER" -t PENDING \
    -o "%.10i %.30j %.12l %.6C %.20b %.R" 2>/dev/null)

PENDING_COUNT=$(echo "$PENDING" | grep -c . 2>/dev/null || true)
if [[ -z "$PENDING" ]]; then
    PENDING_COUNT=0
fi

echo "PENDING ($PENDING_COUNT jobs):"
if [[ $PENDING_COUNT -gt 0 ]]; then
    printf "%-12s %-30s %-12s %-6s %-20s %s\n" "JOBID" "NAME" "TIMELIMIT" "CPUS" "GRES" "REASON"
    echo "$PENDING"
else
    echo "(none)"
fi
echo ""

# Resource totals
TOTAL_JOBS=$(( RUNNING_COUNT + PENDING_COUNT ))
TOTAL_CPUS=$(squeue --noheader -u "$USER" -t RUNNING -o "%C" 2>/dev/null \
    | awk '{s+=$1} END {print s+0}')
TOTAL_GPUS=$(squeue --noheader -u "$USER" -t RUNNING -o "%b" 2>/dev/null \
    | grep -oP '\d+$' \
    | awk '{s+=$1} END {print s+0}')

echo "TOTALS:"
echo "  Running CPUs: $TOTAL_CPUS / 500 limit"
echo "  Running GPUs: $TOTAL_GPUS / 50 limit"
echo "  Total jobs:   $TOTAL_JOBS / 500 limit"

# Warnings
if (( TOTAL_GPUS >= 40 )); then
    echo ""
    echo "WARNING: at $(( TOTAL_GPUS * 100 / 50 ))% of GPU cap ($TOTAL_GPUS/50)"
fi
if (( TOTAL_CPUS >= 400 )); then
    echo ""
    echo "WARNING: at $(( TOTAL_CPUS * 100 / 500 ))% of CPU cap ($TOTAL_CPUS/500)"
fi
if (( TOTAL_JOBS >= 400 )); then
    echo ""
    echo "WARNING: at $(( TOTAL_JOBS * 100 / 500 ))% of job cap ($TOTAL_JOBS/500)"
fi
