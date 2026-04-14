#!/bin/bash
# check_gpu_contention.sh — Show who's using a specific GPU type and how much is left.
# Usage: bash scripts/check_gpu_contention.sh <gpu_type>
#   e.g. bash scripts/check_gpu_contention.sh a6000
set -uo pipefail

VALID_TYPES="a5000 a6000 rtx_pro_6000 v100 p100 rtx_2080 rtx_5000"

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") <gpu_type>"
    echo ""
    echo "Shows nodes with the specified GPU type, how many GPUs are idle,"
    echo "and the jobs currently running on those nodes."
    echo ""
    echo "Valid GPU types: $VALID_TYPES"
    exit 0
fi

GPU_TYPE="$1"

# Validate GPU type
if ! echo "$VALID_TYPES" | grep -qw "$GPU_TYPE"; then
    echo "Error: unknown GPU type '$GPU_TYPE'"
    echo "Valid types: $VALID_TYPES"
    exit 1
fi

echo "=== GPU contention: $GPU_TYPE ==="
echo ""

# Find nodes with this GPU type
NODES=$(sinfo -p compsci-gpu -o "%N %G" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:" \
    | awk '{print $1}')

if [[ -z "$NODES" ]]; then
    echo "No nodes found with GPU type '$GPU_TYPE'."
    exit 1
fi

# Expand node ranges and get per-node state
echo "Nodes with $GPU_TYPE:"
sinfo -p compsci-gpu -N -o "%N %G %T %c %m" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:"
echo ""

# Count totals
TOTAL_GPUS=$(sinfo -p compsci-gpu -N -o "%G" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:" \
    | sed 's/.*://' \
    | awk '{s+=$1} END {print s}')

IDLE_NODES=$(sinfo -p compsci-gpu -N -o "%N %G %T" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:" \
    | grep -c "idle" || true)

ALLOC_NODES=$(sinfo -p compsci-gpu -N -o "%N %G %T" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:" \
    | grep -c "alloc\|mixed" || true)

TOTAL_NODES=$(sinfo -p compsci-gpu -N -o "%N %G %T" --noheader 2>/dev/null \
    | grep "gpu:${GPU_TYPE}:" \
    | wc -l)

echo "Summary: $TOTAL_GPUS total GPUs across $TOTAL_NODES nodes ($IDLE_NODES idle, $ALLOC_NODES allocated/mixed)"
echo ""

# Show jobs running on these nodes
NODE_LIST=$(sinfo -p compsci-gpu -N -o "%N" --noheader 2>/dev/null \
    | sort -u \
    | tr '\n' ',' | sed 's/,$//')

echo "Jobs on $GPU_TYPE nodes:"
squeue --noheader -w "$NODE_LIST" \
    -o "%.10i %.8u %.6C %.20b %.12M %.12L %.30j" 2>/dev/null \
    | grep "$GPU_TYPE" || echo "(none)"
echo ""

# Count unique users
USER_COUNT=$(squeue --noheader -w "$NODE_LIST" \
    -o "%u" 2>/dev/null \
    | grep -c . || true)
echo "Active users on $GPU_TYPE nodes: $USER_COUNT"
