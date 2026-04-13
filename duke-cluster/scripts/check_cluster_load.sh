#!/bin/bash
# check_cluster_load.sh — Print a one-line summary of current Duke CS cluster load.
# Usage: bash scripts/check_cluster_load.sh
#        No arguments required.
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo "Prints a one-line summary of current cluster load (queue depth, allocated/idle nodes)."
    exit 0
fi

queue_depth=$(squeue --noheader 2>/dev/null | wc -l)
gpu_alloc_idle=$(sinfo -p compsci-gpu -o '%A' --noheader 2>/dev/null | tr '/' ' ')
cpu_alloc_idle=$(sinfo -p compsci -o '%A' --noheader 2>/dev/null | tr '/' ' ')

gpu_alloc=$(echo "$gpu_alloc_idle" | awk '{print $1}')
gpu_idle=$(echo "$gpu_alloc_idle" | awk '{print $2}')
cpu_alloc=$(echo "$cpu_alloc_idle" | awk '{print $1}')
cpu_idle=$(echo "$cpu_alloc_idle" | awk '{print $2}')

if (( queue_depth < 200 )) && (( gpu_idle > 0 )); then
    verdict="low load"
elif (( queue_depth > 1500 )); then
    verdict="heavy load (end-of-semester crunch?)"
elif (( queue_depth > 800 )) || (( gpu_idle == 0 )); then
    verdict="busy load"
else
    verdict="moderate load"
fi

echo "Queue: ${queue_depth} jobs | compsci-gpu: ${gpu_alloc}/${gpu_idle} alloc/idle | compsci: ${cpu_alloc}/${cpu_idle} alloc/idle | verdict: ${verdict}"
