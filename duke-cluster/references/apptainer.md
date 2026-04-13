# Apptainer (Containers)

From Duke docs: https://computing.cs.duke.edu/software/apptainer/

Use Apptainer for containerized environments (TensorFlow, custom CUDA builds, etc.).

## Examples

```bash
# Interactive GPU session with container
srun -p compsci-gpu --gres=gpu:1 --mem=70g --pty zsh -l
apptainer run --nv docker://tensorflow/tensorflow:latest-gpu

# Bind /usr/xtmp into the container (not mounted by default)
apptainer run --nv -B /usr/xtmp docker://nvcr.io/nvidia/pytorch:24.01-py3

# Batch job with a local .sif image
apptainer exec --nv /usr/xtmp/$USER/my_container.sif python3 train.py
```

## Key flags

- `--nv` — enables GPU access inside the container.
- `-B /usr/xtmp` — binds `/usr/xtmp` into the container (not mounted by default).

## Storage

Store container images in `/usr/xtmp/$USER/`, not `$HOME` (they're large and inode-heavy).

## Container sources

- Docker Hub
- NVIDIA GPU Cloud (nvcr.io)
- Sylab's Container Library
- Red Hat Quay
