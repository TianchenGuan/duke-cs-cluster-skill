#!/bin/bash
# estimate_wait.sh — Use Slurm's --test-only to estimate when a job would start.
# Usage: bash scripts/estimate_wait.sh <gpu_type> <gpu_count>
#   e.g. bash scripts/estimate_wait.sh a6000 1
set -uo pipefail

if [[ $# -lt 2 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") <gpu_type> <gpu_count>"
    echo ""
    echo "Submits a placeholder job with --test-only to get Slurm's estimated"
    echo "start time for the requested GPU type and count."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") a6000 1"
    echo "  $(basename "$0") a5000 4"
    exit 0
fi

GPU_TYPE="$1"
GPU_COUNT="$2"

echo "=== Start estimate: ${GPU_COUNT}x ${GPU_TYPE} ==="
echo ""

# --test-only prints the estimated start time without actually submitting
sbatch --test-only \
    --partition=compsci-gpu \
    --gres="gpu:${GPU_TYPE}:${GPU_COUNT}" \
    --cpus-per-task=4 \
    --mem=16G \
    --time=01:00:00 \
    --wrap="echo placeholder" 2>&1 || echo "sbatch --test-only failed (this is normal if the GPU type is invalid or you've hit a resource cap)"
