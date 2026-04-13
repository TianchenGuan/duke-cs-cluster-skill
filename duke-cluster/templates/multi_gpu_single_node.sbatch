#!/bin/bash
# Duke CS cluster — multi-GPU single-node template (4x A5000, PyTorch DDP)
# Based on verified patterns from InterfaceGym and Duke GPU docs.
#
# Lines to modify:  --gres (gpu type/count), --time, --cpus-per-task, --mem,
#                   --output, --nproc_per_node, the python command
# Lines to keep:    set -euo pipefail, cache exports, OMP_NUM_THREADS, nvidia-smi
# Note: create the output directory first: mkdir -p /usr/xtmp/$USER/logs

#SBATCH --partition=compsci-gpu
#SBATCH --gres=gpu:a5000:4
#SBATCH --time=1-00:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --output=/usr/xtmp/%u/logs/%x_%j.out
#SBATCH --error=/usr/xtmp/%u/logs/%x_%j.err

set -euo pipefail

export HF_HOME=/usr/xtmp/$USER/.cache/huggingface
export TORCH_HOME=/usr/xtmp/$USER/.cache/torch
export PIP_CACHE_DIR=/usr/xtmp/$USER/.cache/pip
export OMP_NUM_THREADS=4

echo "Node: $(hostname)"
echo "GPUs: $(nvidia-smi -L)"
echo "Started: $(date -u)"

torchrun --nproc_per_node=4 train.py
