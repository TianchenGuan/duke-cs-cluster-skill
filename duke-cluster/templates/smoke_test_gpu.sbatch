#!/bin/bash
# Duke CS cluster — GPU smoke test
# Verified 2026-04-13: job 11109698, started in 8s on fitz-24.
#
# Lines to modify:  --gres (gpu type)
# Lines to keep:    everything else
# Note: create the output directory first: mkdir -p /usr/xtmp/$USER/logs

#SBATCH --partition=compsci-gpu
#SBATCH --gres=gpu:a5000:1
#SBATCH --time=00:05:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --output=/usr/xtmp/%u/logs/smoke_%j.out

set -euo pipefail
nvidia-smi
python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name(0))"
