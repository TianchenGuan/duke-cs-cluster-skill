#!/bin/bash
# prestage_hf_model.sh — Download a HuggingFace model to the shared /xtmp cache.
# Usage: bash scripts/prestage_hf_model.sh <model-name>
#   e.g. bash scripts/prestage_hf_model.sh google-bert/bert-base-uncased
#
# Sets HF_HOME to /usr/xtmp/$USER/.cache/huggingface so subsequent jobs
# that set the same HF_HOME will use the cached model without re-downloading.
set -euo pipefail

command -v huggingface-cli >/dev/null || { echo "Install with: pip install huggingface_hub[cli]"; exit 1; }

if [[ $# -eq 0 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0") <huggingface-model-name>"
    echo ""
    echo "Downloads a HuggingFace model to /usr/xtmp/\$USER/.cache/huggingface"
    echo "so that Slurm jobs with HF_HOME set to the same path can reuse it."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") google-bert/bert-base-uncased"
    echo "  $(basename "$0") meta-llama/Llama-2-7b-hf"
    exit 0
fi

MODEL="$1"
export HF_HOME="/usr/xtmp/$USER/.cache/huggingface"
mkdir -p "$HF_HOME"

echo "Model:   $MODEL"
echo "HF_HOME: $HF_HOME"
echo ""

START=$(date +%s)
huggingface-cli download "$MODEL"
END=$(date +%s)

ELAPSED=$(( END - START ))
echo ""
echo "Download complete in ${ELAPSED}s."
echo "Cache location: $HF_HOME"
echo ""
echo "To use in job scripts, add:"
echo "  export HF_HOME=/usr/xtmp/\$USER/.cache/huggingface"
