#!/bin/bash
# Duke CS cluster — multi-node template (2 nodes x 4 GPUs, PyTorch DDP)
# Based on Duke GPU docs template.
#
# Lines to modify:  --nodes, --gres (gpu type/count), --time, --cpus-per-task,
#                   --mem, --output, --nproc_per_node, the python command
# Lines to keep:    set -euo pipefail, cache exports, MASTER_PORT derivation,
#                   OMP_NUM_THREADS, srun + torchrun invocation pattern
# Note: create the output directory first: mkdir -p /usr/xtmp/$USER/logs

#SBATCH --partition=compsci-gpu
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:a5000:4
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=2-00:00:00
#SBATCH --output=/usr/xtmp/%u/logs/%x_%j.out
#SBATCH --error=/usr/xtmp/%u/logs/%x_%j.err

set -euo pipefail

export HF_HOME=/usr/xtmp/$USER/.cache/huggingface
export TORCH_HOME=/usr/xtmp/$USER/.cache/torch
export PIP_CACHE_DIR=/usr/xtmp/$USER/.cache/pip
export MASTER_PORT=$(( 29500 + SLURM_JOBID % 1000 ))
export OMP_NUM_THREADS=4

echo "Node: $(hostname)"
echo "GPUs: $(nvidia-smi -L)"
echo "Started: $(date -u)"

srun torchrun \
    --nnodes=$SLURM_NNODES \
    --nproc_per_node=4 \
    --rdzv_id=$SLURM_JOBID \
    --rdzv_backend=c10d \
    --rdzv_endpoint=$(hostname):$MASTER_PORT \
    train.py
