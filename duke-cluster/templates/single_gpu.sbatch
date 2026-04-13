#!/bin/bash
# Duke CS cluster — single-GPU job template (A5000)
# Verified 2026-04-13: job 11109691, started in 8s on fitz-24.
#
# Lines to modify:  --gres (gpu type/count), --time, --cpus-per-task, --mem,
#                   --output, the python command
# Lines to keep:    set -euo pipefail, cache exports, nvidia-smi logging
# Note: create the output directory first: mkdir -p /usr/xtmp/$USER/logs

#SBATCH --partition=compsci-gpu
#SBATCH --gres=gpu:a5000:1
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=/usr/xtmp/%u/logs/%x_%j.out
#SBATCH --error=/usr/xtmp/%u/logs/%x_%j.err

set -euo pipefail

export HF_HOME=/usr/xtmp/$USER/.cache/huggingface
export TORCH_HOME=/usr/xtmp/$USER/.cache/torch
export PIP_CACHE_DIR=/usr/xtmp/$USER/.cache/pip

echo "Node: $(hostname)"
echo "GPUs: $(nvidia-smi -L 2>/dev/null || echo 'none')"
echo "Started: $(date -u)"

python train.py
