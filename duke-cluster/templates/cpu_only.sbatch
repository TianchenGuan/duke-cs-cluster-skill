#!/bin/bash
# Duke CS cluster — CPU-only job template
# Verified 2026-04-13: job 11109699, started in 0s on fitz-36.
#
# Lines to modify:  --time, --cpus-per-task, --mem, --output, the python command
# Lines to keep:    set -euo pipefail, cache exports
# Note: create the output directory first: mkdir -p /usr/xtmp/$USER/logs

#SBATCH --partition=compsci
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=/usr/xtmp/%u/logs/%x_%j.out
#SBATCH --error=/usr/xtmp/%u/logs/%x_%j.err

set -euo pipefail

export PIP_CACHE_DIR=/usr/xtmp/$USER/.cache/pip

echo "Node: $(hostname)"
echo "Started: $(date -u)"

python my_script.py
