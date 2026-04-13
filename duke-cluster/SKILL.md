---
name: duke-cluster
description: Trigger before submitting any Slurm job (sbatch/srun), when diagnosing why a job failed to schedule, or when choosing GPU types, partitions, storage paths, or resource limits on the Duke CS compute cluster. Do NOT trigger for non-Slurm tasks or clusters other than Duke CS.
---

# Duke CS Compute Cluster

**Skill version:** 3
**Applies to:** Duke Computer Science Slurm cluster (`login.cs.duke.edu`)
**Last verified:** 2026-04-13 via `sinfo`, `scontrol show partition`, `sacctmgr`, `module avail`, 12 smoke jobs.
**Regenerate with:** `bash scripts/verify_skill.sh` and update tables.
**Docs:** https://computing.cs.duke.edu — subpages: Compute/{cluster, slurm, gpu-computing}, Storage/disk_usage, Software/{environment-modules, apptainer}.

---

## Pre-Flight Checklist

Every job script should do all of the following. Copy from [templates/](templates/) — don't reconstruct from memory.

1. `set -euo pipefail` — fail fast on errors, undefined vars, broken pipes.
2. Set cache dirs explicitly (never rely on inheritance):
   ```bash
   export HF_HOME=/usr/xtmp/$USER/.cache/huggingface
   export TORCH_HOME=/usr/xtmp/$USER/.cache/torch
   export PIP_CACHE_DIR=/usr/xtmp/$USER/.cache/pip
   ```
3. Always specify `--mem` — the default is **4.5 GB**, too low for any real work.
4. Always specify `--time` — the default is **4 days**, which blocks scheduling.
5. Point `--output`/`--error` to `/usr/xtmp/%u/...` or `$HOME` — never `/tmp` (node-local, invisible from login node).
6. Log GPU info: `nvidia-smi -L 2>/dev/null || echo 'none'`

---

## Partitions

Only `compsci` and `compsci-gpu` are generally accessible. Other partitions
(grisman, wiseman, nlplab, nlplab-core, bhuwan, rudin, skynet, wills) are
lab-specific — submit with `-A PARTITIONNAME -p PARTITIONNAME`.

| Partition      | Purpose  | Default time | Max time | Nodes | Total CPUs | GPUs?           | Default mem |
|----------------|----------|-------------|----------|-------|------------|-----------------|-------------|
| `compsci`      | CPU work | **4 days**  | 90 days  | 48    | 2,448      | No              | 4.5 GB      |
| `compsci-gpu`* | GPU work | **4 days**  | 90 days  | 62    | 3,192      | Yes (217 total) | 4.5 GB      |

\* `compsci-gpu` is the **default partition**. No debug partition exists — use `--time=00:05:00` for quick smoke tests. No preemption (`PreemptMode=OFF`).

---

## GPU Types and How to Request Them

`--gres=gpu:<type>:<count>`. The `<type>` must match Slurm's name exactly. Untyped `--gres=gpu:N` also works (accepts any available GPU). All verified 2026-04-13 via smoke jobs.

| GPU (Slurm name) | Full name                 | VRAM  | CUDA / Tensor cores | `--gres` example             | Total | Nodes                              | CPUs/node | RAM/node    |
|-------------------|---------------------------|-------|---------------------|------------------------------|-------|------------------------------------|-----------|-------------|
| `rtx_pro_6000`    | NVIDIA RTX Pro 6000       | 96 GB | 24,064 / 752        | `--gres=gpu:rtx_pro_6000:N`  | 20    | fitz-[45-49]                       | 128       | ~1.1 TB     |
| `a6000`           | NVIDIA RTX A6000          | 48 GB | 10,752 / 336        | `--gres=gpu:a6000:N`         | 16    | fitz-[05-08]                       | 48        | ~750 GB     |
| `rtx_5000`        | RTX 5000 Ada Generation   | 32 GB | 12,800 / 400        | `--gres=gpu:rtx_5000:N`      | 5     | linux[51-55]                       | 24        | ~750 GB     |
| `v100`            | Tesla V100-PCIE-32GB      | 32 GB | 5,120 / 640         | `--gres=gpu:v100:N`          | 5     | gpu-compute[5-6]                   | 40        | ~246 GB     |
| `a5000`           | NVIDIA RTX A5000          | 24 GB | 8,192 / 256         | `--gres=gpu:a5000:N`         | 124   | fitz-[01-04,09-34], linux[41-43,45]| 48-64     | 750 GB-1 TB |
| `p100`            | Tesla P100-PCIE-12GB      | 12 GB | 3,584 / —           | `--gres=gpu:p100:N`          | 25    | gpu-compute[4-5], linux[41-50]     | 40        | 246-496 GB  |
| `rtx_2080`        | GeForce RTX 2080 Ti       | 11 GB | 4,352 / —           | `--gres=gpu:rtx_2080:N`      | 22    | linux[47,50-60]                    | 24        | 640-750 GB  |

**NVIDIA driver:** 570.133.20. CUDA runtime from driver: 12.8.

### Picking a GPU for Your Workload

```
Model fits in 24 GB (with mixed precision / gradient checkpointing)?
  └─ Yes → a5000 (124 GPUs, fastest scheduling)
  └─ No, fits in 48 GB?
       └─ Yes → a6000 (16 GPUs, may queue 3h+ when busy)
       └─ No, fits in 96 GB?
            └─ Yes → rtx_pro_6000 (20 GPUs, may queue 3h+ when busy)
            └─ No → Multi-GPU with FSDP/DeepSpeed on a5000 or a6000 nodes

For inference / small models (≤12 GB): p100 or rtx_2080 (plentiful, low contention)
For 32 GB models: v100 or rtx_5000 (few GPUs, but lower contention than a6000)
```

Some nodes (linux[41-55], gpu-compute5) have mixed GPU types — request a specific type via `--gres`.

### Hardware Details (from Duke docs, verified against `scontrol show node`)

| Node range           | CPU                             | Cores | RAM    | GPUs            |
|----------------------|---------------------------------|-------|--------|-----------------|
| fitz-[01-04,09-21]   | Intel Xeon Gold 5317, 3.0 GHz   | 48    | 768 GB | 4x A5000        |
| fitz-[05-08]          | Intel Xeon Gold 5317, 3.0 GHz   | 48    | 768 GB | 4x A6000        |
| fitz-[24-34]          | Intel Xeon Gold 6346, 3.1 GHz   | 64    | 1 TB   | 4x A5000        |
| fitz-[35-44]          | AMD EPYC 9554, 64c/128t         | 128   | 1.1 TB | None (CPU-only)  |
| fitz-[45-49]          | AMD EPYC 9554, 64c/128t         | 128   | 1.1 TB | 4x RTX Pro 6000 |
| linux[41-50]          | Intel Xeon E5-2640 v4, 2.4 GHz  | 40    | 512 GB | Mixed P100/A5000/2080 |
| linux[51-60]          | Intel Xeon Gold 6226, 2.7 GHz   | 24    | 768 GB | Mixed 2080/RTX 5000 |
| gpu-compute[4-6]      | Intel Xeon E5-2640 v4, 2.4 GHz  | 40    | 256 GB | Mixed P100/V100 |

---

## Storage

### Quotas (verified 2026-04-13 via `quota -v`)

| Filesystem | Mount               | Capacity        | Inode limit | Backed up?      | Retention               |
|------------|----------------------|-----------------|-------------|-----------------|-------------------------|
| `$HOME`    | `/home/users/`       | 100 GB per user | 500,000     | Yes (redundant) | Permanent               |
| `/xtmp`    | `/usr/project/xtmp`  | 400 TB shared   | None known  | **No**          | **180-day purge** (unmodified files auto-deleted) |
| `/var/tmp` | node-local           | Varies          | —           | **No**          | **30-day purge** (unaccessed files auto-deleted)  |

**`/xtmp` warning:** Files not modified for 180 days are automatically removed.
Periodically `touch` important files or copy results to backed-up storage.

**Inode trap:** Hitting the 500k inode limit on `$HOME` produces "No space left on
device" errors even when disk space is free. Check: `du --inodes -s ~` / `quota -v`.
A common pattern is to keep small state files in `$HOME` and bulk data in `/usr/xtmp/$USER/`.

**`/tmp` is node-local.** Files written there are invisible from the login node.
Never point `--output` to `/tmp`. Fine for throwaway scratch within a single job.

**`/usr/project/xtmp/` and `/usr/xtmp/` are the same NFS filesystem.**

---

## Network Access and Pre-Staging

Compute nodes have full outbound internet (verified 2026-04-13). Kaggle, HuggingFace, PyPI, GitHub, Anthropic API, Docker Hub all reachable.

**Download speed:** 678 MB/s from HuggingFace (3.3 GB in 4.9s). Pre-staging is optional for bandwidth but avoids redundant downloads. See [scripts/prestage_hf_model.sh](scripts/prestage_hf_model.sh).

---

## Scheduling Latency

Measured 2026-04-13 (Sunday afternoon, 846 jobs in queue). **Single snapshot — do not extrapolate.**

| Partition     | GPU type      | Wait     | Note                                  |
|---------------|---------------|----------|---------------------------------------|
| `compsci`     | (CPU)         | **0s**   | 27/48 nodes idle at time of test      |
| `compsci-gpu` | a5000         | **8s**   | Largest pool (124 GPUs)               |
| `compsci-gpu` | v100          | **8s**   |                                       |
| `compsci-gpu` | p100          | **8s**   |                                       |
| `compsci-gpu` | rtx_5000      | **8s**   |                                       |
| `compsci-gpu` | rtx_2080      | **8s**   |                                       |
| `compsci-gpu` | (any, untyped)| **8s**   | Picked an a5000 node                  |
| `compsci-gpu` | a6000         | **3h+**  | All 16 GPUs were allocated            |
| `compsci-gpu` | rtx_pro_6000  | **3h+**  | All 20 GPUs were allocated            |

### Checking current congestion

The cluster load varies with the academic calendar. Check before assuming fast scheduling:

```bash
squeue | wc -l                     # Total jobs in queue
sinfo -p compsci-gpu -o '%A'       # Allocated/idle GPU nodes
sinfo -p compsci -o '%A'           # Allocated/idle CPU nodes
```
Or run: `bash scripts/check_cluster_load.sh`

- `squeue` < 200, idle GPU nodes > 0 → cluster is free.
- `squeue` 500–1000, 0 idle → normal mid-semester. A5000 fast; A6000/RTX Pro may queue hours.
- `squeue` > 1500 → end-of-semester crunch. Expect multi-hour waits even for A5000.

---

## Resource Limits and Etiquette

### Hard limits (verified via `sacctmgr show assoc`)

| Resource              | Concurrent limit |
|-----------------------|------------------|
| **CPUs**              | 500              |
| **GPUs**              | 50               |
| **Memory**            | ~10 TB           |
| **Queued/running jobs** | 500            |

These are **group TRES limits** — they cap concurrent allocation, not per-job.

### Etiquette (general, not verified via sacctmgr)

- Use tight `--time` estimates. Cancel idle jobs promptly.
- Prefer fewer multi-GPU jobs over many single-GPU jobs.
- Avoid mass array jobs (>50 tasks) unless they're short.

---

## Modules

Available modules (verified 2026-04-13 via `module avail`):

**CUDA:** `cuda/cuda-9.0`, `9.2`, `10.2`, `11.4`, `12.1`. Driver supports 12.8 — use pip-installed CUDA for newer versions.
**Python:** `python/3.12.8`, `python/3.6.15` (legacy).
**Other:** `miniconda/23.9.0`, `gcc/9.5`, `gcc/13.3`, `cmake/3.31`, `tmux/3.4`.
**Node.js:** No module — load NVM directly: `[ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"`

**Module load order matters.** Load `cuda/...` **before** activating venv/conda. See templates for working examples.

---

## Distributed Training

See [references/distributed_training.md](references/distributed_training.md) for env vars, pitfalls, and multi-node templates.

Key points: use `LOCAL_RANK` (not `RANK`) for device index. Derive `MASTER_PORT` from `$SLURM_JOBID` to avoid collisions. Set `NCCL_DEBUG=INFO` to debug timeouts.

---

## Apptainer (Containers)

See [references/apptainer.md](references/apptainer.md). Key: use `--nv` for GPU access, `-B /usr/xtmp` to bind shared storage.

---

## Common Failure Triage

See [references/failure_modes.md](references/failure_modes.md) for full tables. Quick pointers:

- **Job won't schedule:** Check `squeue -j <jobid>` reason column. `(Priority)` = wait. `(Resources)` = reduce request. `AssocGrpGRES` = hit 50-GPU user cap.
- **Job OOM:** Did you set `--mem`? Default is only 4.5 GB. Check `sacct -j <jobid> --format=MaxRSS`.
- **Works interactively, fails in sbatch:** Jobs don't inherit your shell env. Set all vars explicitly.

---

## Surprises and Caveats

1. **Default memory is 4.5 GB, not 30 GB.** Duke docs mention 30 GB in some contexts but `scontrol show partition` shows `DefMemPerNode=4500`.
2. **A6000 and RTX Pro 6000 can queue for hours** even on a Sunday afternoon. The A5000 pool (124 GPUs) scheduled in 8s in the same conditions.
3. **`/tmp` output trap.** Smoke tests written to `/tmp` produced invisible output. The #1 gotcha for new users.
4. **Untyped `--gres=gpu:N` works.** Slurm picks whatever's available.
5. **No preemption.** `PreemptMode=OFF` on both partitions.
6. **`/xtmp` has a 180-day purge.** Old checkpoints silently disappear.
7. **HuggingFace downloads are blazing fast (678 MB/s).** Pre-staging is good practice but not bandwidth-limited.
8. **`/usr/project/xtmp/` and `/usr/xtmp/` are the same filesystem** (NFS from `xtmp:/xtmp_data`).
9. **Node-local `/var/tmp` has a 30-day purge.** Safer than `/tmp` but still not persistent.

---

## Verification Commands

Run these (or `bash scripts/verify_skill.sh`) to refresh this skill:

```bash
sinfo -o "%P %l %D %N %G"
scontrol show partition compsci-gpu
scontrol show partition compsci
sinfo -p compsci-gpu -o "%N %G %c %m %T"
scontrol show config | grep -i gres
sacctmgr show assoc tree format=account,user,grptres%50,GrpTRESRunMin user=$USER
module avail 2>&1 | head -80
module avail cuda 2>&1
module avail python 2>&1
df -h $HOME && df -h /usr/xtmp/$USER && quota -v && du --inodes -s ~
```
