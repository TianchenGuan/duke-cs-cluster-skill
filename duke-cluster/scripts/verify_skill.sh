#!/bin/bash
# verify_skill.sh — Run every verification command from the duke-cluster skill.
# Usage: bash scripts/verify_skill.sh
#        Pipe to a file and diff against SKILL.md tables to refresh the skill.
set -uo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: $(basename "$0")"
    echo "Runs all verification commands from the duke-cluster skill and prints output."
    echo "Pipe to a file to diff against SKILL.md tables."
    exit 0
fi

sep() { echo; echo "===== $1 ====="; echo; }

sep "Partitions, GPU types, and node counts"
sinfo -o "%P %l %D %N %G"

sep "compsci-gpu partition config"
scontrol show partition compsci-gpu

sep "compsci partition config"
scontrol show partition compsci

sep "GPU details per node"
sinfo -p compsci-gpu -o "%N %G %c %m %T"

sep "GRES configuration"
scontrol show config | grep -i gres

sep "Per-user resource limits"
sacctmgr show assoc tree format=account,user,grptres%50,GrpTRESRunMin user="$USER" || echo "sacctmgr not available (restricted account?)"

sep "Current cluster load"
echo "Queue depth: $(squeue --noheader | wc -l) jobs"
echo "compsci-gpu alloc/idle: $(sinfo -p compsci-gpu -o '%A' --noheader)"
echo "compsci alloc/idle: $(sinfo -p compsci -o '%A' --noheader)"

sep "Module list (first 80 lines)"
module avail 2>&1 | head -80

sep "CUDA modules"
module avail cuda 2>&1

sep "Python modules"
module avail python 2>&1

sep "Storage: HOME"
df -h "$HOME"

sep "Storage: xtmp"
df -h "/usr/xtmp/$USER" 2>/dev/null || df -h /usr/project/xtmp 2>/dev/null || echo "xtmp not found"

sep "Quota"
quota -v 2>/dev/null || echo "quota command not available"

sep "Inode usage"
du --inodes -s ~ 2>/dev/null || echo "du --inodes not available"

sep "Node IP addresses (compsci-gpu)"
for node in $(sinfo -p compsci-gpu -N -o "%N" --noheader | sort -u); do
    echo "$node $(getent hosts "$node" 2>/dev/null | awk '{print $1}')"
done

echo
echo "===== Done. Compare output against SKILL.md tables. ====="
