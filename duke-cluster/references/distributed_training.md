# Distributed Training on the Duke CS Cluster

From Duke docs: https://computing.cs.duke.edu/compute/gpu-computing/

## Environment variables for multi-GPU/multi-node jobs

| Variable               | Purpose                                                |
|------------------------|--------------------------------------------------------|
| `MASTER_ADDR`          | IP/hostname of rank-0 node                             |
| `MASTER_PORT`          | Port for distributed comms — derive from `$SLURM_JOBID` to avoid collisions |
| `CUDA_VISIBLE_DEVICES` | Slurm sets this via `--gres` — don't override manually |
| `NCCL_DEBUG=INFO`      | Enable NCCL logging for debugging communication issues |
| `OMP_NUM_THREADS`      | Set to avoid CPU oversubscription                      |

## Common pitfalls (from Duke docs)

- **LOCAL_RANK vs RANK:** Always use `LOCAL_RANK` (GPU index on current node, e.g. 0-3)
  when setting the device, not `RANK` (global process index). Using `RANK` causes
  "invalid device ordinal" errors.
- **Port conflicts:** Each distributed job needs a unique `MASTER_PORT`. Derive it
  from `$SLURM_JOBID`: `export MASTER_PORT=$(( 29500 + SLURM_JOBID % 1000 ))`.
- **NCCL timeouts:** Usually caused by network issues or misconfigured node addresses,
  not NCCL itself. Set `NCCL_DEBUG=INFO` to diagnose.
- **Mismatched GPU counts:** Ensure `--gres=gpu:N` matches `--nproc_per_node` in your script.
- **Data loading bottlenecks:** Use multiple DataLoader workers (`num_workers`) and
  `pin_memory=True` to keep GPUs fed.

## Job templates

See [../templates/multi_gpu_single_node.sbatch](../templates/multi_gpu_single_node.sbatch)
and [../templates/multi_node.sbatch](../templates/multi_node.sbatch) for copy-paste-ready scripts.

### PyTorch Lightning multi-node

Lightning reads Slurm variables automatically:
```bash
srun python3 train.py
# In code: Trainer(accelerator="gpu", devices=4, num_nodes=2, strategy="ddp")
```

## Node IP addresses

For multi-node work, see [node_ips.md](node_ips.md) for the full IP table.
Slurm handles inter-node communication via hostnames — you typically don't need
raw IPs unless debugging NCCL connectivity.
