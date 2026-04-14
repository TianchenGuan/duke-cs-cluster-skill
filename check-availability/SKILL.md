---
name: check-availability
description: Check current availability of GPUs on the Duke CS cluster. Use when the user asks about cluster load, GPU contention, wait times, or wants to know if a specific GPU type is free before submitting a job. Optional argument is a GPU type (a5000, a6000, rtx_pro_6000, v100, p100, rtx_2080, rtx_5000).
---

# Check Duke CS Cluster Availability

When invoked, produce a nicely formatted summary of current cluster state to help the user decide where to submit their next job.

## Behavior

**If no GPU type was specified:** give an overall snapshot.

1. Run `bash ~/.claude/skills/duke-cluster/scripts/check_cluster_load.sh` to get the one-liner summary.
2. Also run `sinfo -p compsci-gpu -o '%G %D %t'` to get per-GPU-type idle counts.
3. Format into a single table showing each GPU type, total count, idle count, and a qualitative label ("free", "busy", "full").

**If a specific GPU type was specified:** drill down on that type.

1. Run `bash ~/.claude/skills/duke-cluster/scripts/check_gpu_contention.sh <type>`.
2. Optionally run `bash ~/.claude/skills/duke-cluster/scripts/estimate_wait.sh <type> 1` to get a Slurm start estimate for a single-GPU placeholder.
3. Format the output into three sections: summary line, table of currently-running jobs on those nodes (job ID, user, GPUs, elapsed, remaining), and the Slurm start estimate.

## Output format

Use markdown tables. Keep the response scannable — a user running this before submitting a job wants the answer in 2 seconds, not a paragraph.

For the overall snapshot, target this shape:

| GPU type | Idle / Total | Status |
|----------|--------------|--------|
| a5000 | 18 / 124 | Mostly free |
| a6000 | 0 / 16 | Full |
| rtx_pro_6000 | 0 / 20 | Full |
| v100 | 3 / 5 | Mostly free |
| p100 | 8 / 25 | Free |
| rtx_2080 | 12 / 22 | Free |
| rtx_5000 | 2 / 5 | Mixed |

Add a one-sentence verdict underneath. Examples: "A5000 pool is healthy — submit and expect to start in seconds." / "A6000 and RTX Pro 6000 are fully allocated — consider A5000 or V100 instead."

For a specific GPU type, target:

> **A6000 (fitz-[05-08])** — 0 of 16 GPUs idle, 4 users running jobs.
>
> | Job ID | User | CPUs | GPUs | Elapsed | Remaining | Name |
> |--------|------|------|------|---------|-----------|------|
> | 1234567 | alice | 32 | gpu:a6000:4 | 2h 34m | 5h 26m | finetune |
> | ... |
>
> **Slurm's start estimate for a new 1x A6000 job:** 2026-04-13T18:23:00 (about 4 hours from now).
>
> Verdict: long wait expected. If your job is less than 48GB VRAM, consider A5000 instead.

## Implementation notes

- Call the bash scripts directly; don't reimplement their logic.
- If a script errors or returns unexpected output, show the raw output rather than guessing.
- Idle/total numbers come from parsing `sinfo` output — be defensive about output format.
- Round long uptimes to nearest meaningful unit (e.g., "2h 34m" not "02:34:12").
- Status labels: "Free" if idle > 50% of total, "Mostly free" if 20-50%, "Mixed" if 5-20%, "Busy" if 1-5%, "Full" if 0.
- Don't fabricate data. If a script output looks empty or weird, say so.

## Examples

**User:** `/check-availability`
**Response:** Overall table of all GPU types with idle/total counts and qualitative labels.

**User:** `/check-availability a6000`
**Response:** Detailed drill-down with running jobs table and wait estimate.

**User:** `/check-availability I want to run a 7B model`
**Response:** Don't treat free-form text as a GPU type. Note the request needs 16-24GB VRAM depending on whether they're using LoRA, then show availability for a5000 and a6000 specifically.
