# duke-cluster

A [Claude skill](https://docs.anthropic.com/en/docs/claude-code/skills) for the [Duke Computer Science Slurm cluster](https://computing.cs.duke.edu/compute/cluster/). Gives Claude working knowledge of partitions, GPU types, storage layout, resource limits, and common failure modes so it can submit correct `sbatch` scripts without guessing.

Verified on the real cluster as of April 2026.

## What it knows

- **Partitions and access** — `compsci`, `compsci-gpu`, lab-specific partitions, and which are generally accessible.
- **GPU inventory** — A5000, A6000, RTX Pro 6000, V100, P100, RTX 2080, RTX 5000 Ada, with exact `--gres` syntax, VRAM, and how to pick one for your workload.
- **Storage gotchas** — the 100GB / 500k-inode `$HOME` limit, `/xtmp`'s 180-day purge, the node-local `/tmp` trap.
- **Network** — what compute nodes can and can't reach, plus HuggingFace pre-staging.
- **Scheduling latency** — measured wait times per GPU type and how to check current congestion.
- **Resource limits** — the per-user 50-GPU / 500-CPU / 500-job caps.
- **Modules** — what's available for CUDA, Python, and build tools, and the load-order rules.
- **Distributed training** — environment variables, `LOCAL_RANK` vs `RANK`, `MASTER_PORT` derivation.
- **Failure diagnostics** — `PENDING` reasons, OOM patterns, "works locally but not in sbatch" traps.

## Installation

Claude skills live in `~/.claude/skills/`. Clone and symlink all three skills:

```bash
git clone https://github.com/<your-username>/duke-cs-cluster-skill.git
mkdir -p ~/.claude/skills

# Install all three skills
for skill in duke-cluster check-availability my-jobs; do
    ln -sf "$(pwd)/duke-cs-cluster-skill/$skill" ~/.claude/skills/$skill
done
```

Or copy if you'd rather not symlink:

```bash
for skill in duke-cluster check-availability my-jobs; do
    cp -r "duke-cs-cluster-skill/$skill" ~/.claude/skills/$skill
done
```

Claude Code will automatically pick up the main `duke-cluster` skill when you mention Slurm jobs, GPU requests, or Duke cluster paths. The `check-availability` and `my-jobs` skills register as slash commands.

## Usage examples

Once installed, the skill triggers on prompts like:

- *"Submit a 4-hour training job on an A6000 with 64GB memory."*
- *"My sbatch job is stuck in PENDING — what's wrong?"*
- *"Write a multi-node DDP training script for 2 nodes x 4 A5000s."*
- *"I'm getting 'No space left on device' but my disk isn't full."*

Claude will consult the skill's tables, copy the relevant template from `templates/`, and produce a working script tuned to the Duke cluster.

## Slash commands

Once installed, these commands are available in Claude Code:

- `/check-availability` — Overview of current GPU availability across the cluster
- `/check-availability <gpu_type>` — Detailed drill-down on a specific GPU type (a5000, a6000, rtx_pro_6000, v100, p100, rtx_2080, rtx_5000)
- `/my-jobs` — Your currently running and pending jobs with resource totals

Example:

> User: `/check-availability a6000`
>
> Claude: **A6000 (fitz-[05-08])** — 2 of 16 GPUs idle, 3 users running jobs.
> [table of running jobs]
> Verdict: reasonable wait expected. Submit now if your experiment is under 8 hours.

## Helper scripts

The skill ships with utility scripts you can also run directly from the command line:

```bash
# Is the cluster busy right now?
bash duke-cluster/scripts/check_cluster_load.sh

# Drill down on a specific GPU type
bash duke-cluster/scripts/check_gpu_contention.sh a6000

# Estimate wait time for a GPU request
bash duke-cluster/scripts/estimate_wait.sh a6000 1

# Show your running and pending jobs
bash duke-cluster/scripts/check_my_jobs.sh

# Refresh the skill against live cluster state (run this if something seems off)
bash duke-cluster/scripts/verify_skill.sh > current_state.txt

# Cache a HuggingFace model once so subsequent jobs reuse it
bash duke-cluster/scripts/prestage_hf_model.sh meta-llama/Llama-2-7b-hf
```

## Repository layout

```
duke-cs-cluster-skill/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .gitignore
├── duke-cluster/               # Main skill (reference library)
│   ├── SKILL.md                # Core skill document (always loaded)
│   ├── templates/              # Copy-paste-ready sbatch templates
│   │   ├── cpu_only.sbatch
│   │   ├── single_gpu.sbatch
│   │   ├── multi_gpu_single_node.sbatch
│   │   ├── multi_node.sbatch
│   │   └── smoke_test_gpu.sbatch
│   ├── references/             # Loaded on demand
│   │   ├── failure_modes.md
│   │   ├── distributed_training.md
│   │   ├── node_ips.md
│   │   └── apptainer.md
│   └── scripts/                # Shared helpers (used by slash commands)
│       ├── check_cluster_load.sh
│       ├── check_gpu_contention.sh
│       ├── check_my_jobs.sh
│       ├── estimate_wait.sh
│       ├── prestage_hf_model.sh
│       └── verify_skill.sh
├── check-availability/         # /check-availability slash command
│   └── SKILL.md
└── my-jobs/                    # /my-jobs slash command
    └── SKILL.md
```

## Keeping the skill fresh

The cluster changes. New GPUs get added, old nodes retire, quotas shift, module versions update. If you notice something in the skill that no longer matches live cluster state, you can regenerate the canonical data quickly:

```bash
bash duke-cluster/scripts/verify_skill.sh > /tmp/live_state.txt
# Diff against the tables in SKILL.md and reference files
```

Then open a pull request with the corrections. See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Status and disclaimer

This is a **community-maintained** resource, not an official Duke CS cluster artifact. Cluster state was verified on 2026-04-13 using live commands (`sinfo`, `scontrol`, `sacctmgr`, `module avail`, and 12 smoke jobs). Everything in the skill is information any cluster user can reproduce with those commands — there are no secrets here, just institutional knowledge in one place.

If you're a Duke CS cluster admin and want something changed, removed, or officially endorsed, please open an issue or contact me directly.

## License

MIT. See [LICENSE](LICENSE).

## Acknowledgments

Built on top of the [Duke CS computing documentation](https://computing.cs.duke.edu/). Verified and extended with live cluster data by Duke students using the cluster day-to-day.
