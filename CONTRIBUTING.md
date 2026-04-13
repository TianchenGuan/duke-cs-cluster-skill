# Contributing

Thanks for wanting to help keep this skill accurate. The cluster changes — new GPU nodes get added, partitions reshuffle, module versions update, quotas shift — and keeping the skill current matters more than any single correction.

## What's useful to contribute

**High-value contributions:**

- Partition, GPU, or node information that's now wrong
- New or removed CUDA / Python / other module versions
- Quota changes (especially inode limits on `$HOME` or retention rules on `/xtmp`)
- Failure modes you hit that weren't documented, with the specific error message and root cause
- Corrections to scheduling latency numbers when you've observed something substantially different from what's recorded
- Template improvements that make a template schedule more reliably
- New templates for common workflows (e.g., JAX, a specific multi-GPU pattern)

**Lower-value contributions (please think twice before opening a PR):**

- Stylistic rewording without content changes
- Adding more GPUs or partitions you don't actually have access to
- Speculative additions like "I think this might be faster if..." without measurement
- Content duplicated from the official Duke docs without extracting the concrete fact

## How to contribute

### 1. Verify against the live cluster first

Before opening a PR, confirm your correction is real. Most corrections can be verified with the included script:

```bash
bash duke-cluster/scripts/verify_skill.sh > /tmp/live_state.txt
```

Diff the output against the relevant tables in `SKILL.md`, `references/failure_modes.md`, or `references/node_ips.md`. If the skill and the live state disagree, you've found a real stale claim.

For corrections that aren't covered by `verify_skill.sh` (e.g., scheduling latency, specific failure modes), run the relevant command yourself and include the output in your PR description.

### 2. Keep the "Last verified" stamps current

`SKILL.md` has a `**Last verified:**` line at the top. Each template has a `# Verified YYYY-MM-DD: job NNNNN...` comment. When your correction changes a verified fact, update these stamps to today's date and include the new verification evidence in your PR description.

If you're making a correction that *wasn't* re-verified (e.g., fixing a typo, adding a new failure mode), don't update the top-level verification date.

### 3. Scope your PR

One logical change per PR. "Add RTX 4090 support + fix A5000 wait time + reorganize partitions section" should be three PRs, not one. Reviewers can merge each on its own merits, and if one change needs revision the others aren't blocked.

### 4. Open the PR with context

A good PR description includes:

- **What changed.** One sentence.
- **How you verified.** Paste the relevant command output, Slurm job ID, or error message.
- **When it was verified.** Date and roughly what time (cluster load varies — a scheduling claim at 3 AM is different from one at 3 PM).
- **Whether it applies cluster-wide or to a specific scenario.** E.g., "A6000 queue time: measured at end-of-semester crunch" vs "A6000 queue time: measured on a quiet Sunday."

### 5. Style

- Tables for reference data, prose for reasoning.
- Specific commands over descriptions. "Run `quota -v`" beats "check your quota."
- Measurements with context. "3h+ wait on a Sunday afternoon with 846 queued jobs" beats "often slow."
- Don't remove the verification timestamps on templates. They're load-bearing — they prove the template actually ran.

## Reporting problems you can't fix yourself

If you hit something confusing but can't verify the root cause, open an issue instead of a PR. Include:

- What you tried to do
- The exact error message or unexpected behavior
- Your `sbatch` script (or the relevant portion)
- The Slurm job ID if applicable (`sacct -j <id>` output is useful)

Other users or the maintainer can pick it up.

## Publishing your own fork

This skill is MIT-licensed, so you're free to fork it and publish a version specific to another cluster (UNC-Chapel Hill, NC State, UVA, your lab's internal cluster, etc.). A few suggestions if you do:

- Keep the overall structure (`SKILL.md` + `templates/` + `references/` + `scripts/`). Users who know one skill will pick yours up faster.
- Rename the top-level folder and update `name:` in the SKILL.md frontmatter so the two skills don't collide if a user installs both.
- Run your own `verify_skill.sh`-equivalent and update every table. Do not leave Duke data in a non-Duke skill.
- Link back to this repo so users know where the pattern came from. Open an issue here if you'd like me to list your fork in the README.

## Code of conduct

Be kind. Research clusters are shared resources and the people using them are usually stressed. When filing issues, reviewing PRs, or suggesting changes, assume good faith and remember that the person on the other end is probably debugging something under deadline.
