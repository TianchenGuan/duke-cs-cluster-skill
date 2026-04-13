# Common Failure Modes

Read this when a job has failed unexpectedly. Match the symptom column against your actual error.

## Scheduling failures

| Symptom                                          | Cause                                                            | Fix                                                                |
|--------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------------|
| `Invalid partition name specified`               | Partition name typo or no access                                  | Use `compsci` or `compsci-gpu`. Check: `sinfo -s`.                 |
| `Requested node configuration is not available`  | Requested more GPUs than any node has, or bad `--gres` type       | Check GPU table in SKILL.md. Max per node varies (1–4).            |
| Job stuck `PENDING` with `(Priority)`            | Other jobs ahead in queue                                         | Wait, or request a less-popular GPU (a5000 >> a6000).              |
| Job stuck `PENDING` with `(Resources)`           | Resources exist but fully allocated                               | Wait, or reduce `--mem`/`--cpus-per-task`/`--gres`.                |
| `QOSMaxJobsPerUserLimit`                         | Hit 500-job cap                                                   | Wait for running jobs to finish, or cancel queued ones.            |
| `AssocGrpGRES` / `AssocGrpCpuLimit`              | Hit 50-GPU or 500-CPU per-user concurrent cap                     | Wait for running jobs to release resources.                        |

## Runtime failures

| Symptom                                          | Cause                                                            | Fix                                                                |
|--------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------------|
| `oom-killed` / `Exceeded job memory limit`       | Job used more RAM than `--mem` requested                          | Increase `--mem`. Check: `sacct -j <jobid> --format=MaxRSS`.      |
| Job OOM but `--mem` not set                      | Default is only 4.5 GB                                            | **Always specify `--mem` explicitly.**                             |
| `CUDA out of memory`                             | Model + batch too large for GPU VRAM                              | Reduce batch size, gradient checkpointing, mixed precision, or larger GPU. |
| `No space left on device` (but `df` shows space) | `$HOME` inode limit (500k) hit                                    | Move files to `/usr/xtmp/$USER/`. Check: `du --inodes -s ~`.      |
| Output file missing after job completes          | `--output` pointed to `/tmp` (node-local)                         | Always point to `/usr/xtmp/%u/...` or `$HOME`.                    |
| Job completed but output file doesn't exist at all | `--output` directory doesn't exist (Slurm won't create it)       | Create the directory before submitting: `mkdir -p /usr/xtmp/$USER/logs`. |
| `invalid device ordinal`                         | Used global `RANK` instead of `LOCAL_RANK` for device index       | Use `LOCAL_RANK` to set the GPU device.                            |
| NCCL timeout in distributed training             | Network issue or misconfigured addresses                          | Set `NCCL_DEBUG=INFO`, check `MASTER_ADDR`/`MASTER_PORT`.         |
| `ModuleNotFoundError: No module named 'torch'`   | venv/conda not activated, or module load order wrong               | Activate venv **after** `module load`. Check `which python`.       |
| `libcudnn.so: cannot open shared object file`    | CUDA module not loaded, or wrong version                          | `module load cuda/cuda-12.1` before activating env, or use pip-installed CUDA runtime. |

## "Works locally but not in sbatch"

| Symptom                                          | Cause                                                            | Fix                                                                |
|--------------------------------------------------|------------------------------------------------------------------|--------------------------------------------------------------------|
| Script works in interactive shell, fails in job  | Job doesn't inherit your shell environment                        | Set all env vars explicitly in the script. Don't rely on `.bashrc`. |
| Job ran but didn't use the GPU                   | Forgot `--gres=gpu:...` or framework defaulting to CPU            | Check `nvidia-smi` output in job log. Verify `CUDA_VISIBLE_DEVICES` is set. |
| Job extremely slow (uses GPU but training crawls)| DataLoader bottleneck, or single-threaded data loading             | Set `num_workers>0`, `pin_memory=True`. Check CPU utilization in job. |
| Job cancels with `TIMEOUT`                       | `--time` was too short                                            | Increase `--time`. Check `sacct -j <jobid> --format=Elapsed`.     |
| Job cancels with `OUT_OF_MEMORY`                 | Slurm killed it for exceeding `--mem`                             | Increase `--mem`. Profile actual usage first.                      |
