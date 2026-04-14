---
name: my-jobs
description: Show the current user's running and pending Slurm jobs on the Duke CS cluster, with resource totals and warnings if approaching per-user caps. Use when the user asks about their own jobs, what's running, or how close they are to their GPU/CPU/job limits.
---

# My Jobs on the Duke CS Cluster

When invoked, show the current user's cluster footprint.

## Behavior

1. Run `bash ~/.claude/skills/duke-cluster/scripts/check_my_jobs.sh`.
2. Parse the output into two tables (running, pending) plus a totals summary.
3. Highlight if the user is near their per-user caps (500 CPUs, 50 GPUs, 500 jobs).

## Output format

> **Running ({N} jobs):**
>
> | Job ID | Name | Elapsed | Remaining | CPUs | GPUs | Node |
> |--------|------|---------|-----------|------|------|------|
> | ... |
>
> **Pending ({M} jobs):**
>
> | Job ID | Name | Time limit | CPUs | GPUs | Reason |
> |--------|------|-----------|------|------|--------|
> | ... |
>
> **Totals:** {cpus_running} CPUs and {gpus_running} GPUs currently allocated to you. Limits: 500 CPUs / 50 GPUs / 500 jobs total.
>
> {If near limit:} Warning: You're at {X}% of your GPU cap — new GPU requests may wait.

If the user has zero jobs, say so clearly: "No jobs currently running or pending for $USER."

## Implementation notes

- The script's output is already structured — just reformat it into markdown tables.
- For "Reason" in pending jobs, the common codes have plain-English meanings:
  - `Priority` — other jobs ahead of yours
  - `Resources` — all resources allocated, wait for release
  - `QOSMaxJobsPerUserLimit` — you hit the 500-job cap
  - `AssocGrpGRES` — you hit the 50-GPU cap
  - `AssocGrpCpuLimit` — you hit the 500-CPU cap
  - `ReqNodeNotAvail` — the specific node you asked for is down or drained
- Translate these for the user rather than pasting the raw code.
