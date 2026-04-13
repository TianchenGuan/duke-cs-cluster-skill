# Node IP Addresses

Needed only for multi-node distributed training or network debugging.
For single-node work, ignore this file.

Verified 2026-04-13 via `getent hosts`. Re-resolve with: `getent hosts <hostname>`.

## Subnet summary

| Subnet          | Nodes                     | Type    |
|-----------------|---------------------------|---------|
| `10.138.29.x`   | All fitz-* nodes          | Private |
| `152.3.140.x`   | gpu-compute*, some linux* | Public  |
| `152.3.141.x`   | Some linux*               | Public  |
| `10.236.184.x`  | Some linux*               | Private |

Nodes across different subnets can reach each other (shared NFS mounts and Slurm
connectivity). For multi-node distributed training, Slurm sets `SLURM_JOB_NODELIST`
and handles inter-node communication via hostnames.

## compsci-gpu partition

| Hostname                    | IP              | GPU type            |
|-----------------------------|-----------------|---------------------|
| compsci-cluster-fitz-01     | 10.138.29.2     | a5000               |
| compsci-cluster-fitz-02     | 10.138.29.3     | a5000               |
| compsci-cluster-fitz-03     | 10.138.29.4     | a5000               |
| compsci-cluster-fitz-04     | 10.138.29.5     | a5000               |
| compsci-cluster-fitz-05     | 10.138.29.6     | a6000               |
| compsci-cluster-fitz-06     | 10.138.29.22    | a6000               |
| compsci-cluster-fitz-07     | 10.138.29.23    | a6000               |
| compsci-cluster-fitz-08     | 10.138.29.24    | a6000               |
| compsci-cluster-fitz-09     | 10.138.29.25    | a5000               |
| compsci-cluster-fitz-10     | 10.138.29.26    | a5000               |
| compsci-cluster-fitz-11     | 10.138.29.27    | a5000               |
| compsci-cluster-fitz-12     | 10.138.29.28    | a5000               |
| compsci-cluster-fitz-13     | 10.138.29.29    | a5000               |
| compsci-cluster-fitz-14     | 10.138.29.30    | a5000               |
| compsci-cluster-fitz-15     | 10.138.29.31    | a5000               |
| compsci-cluster-fitz-16     | 10.138.29.32    | a5000               |
| compsci-cluster-fitz-17     | 10.138.29.33    | a5000               |
| compsci-cluster-fitz-18     | 10.138.29.40    | a5000               |
| compsci-cluster-fitz-19     | 10.138.29.34    | a5000               |
| compsci-cluster-fitz-20     | 10.138.29.35    | a5000               |
| compsci-cluster-fitz-21     | 10.138.29.36    | a5000               |
| compsci-cluster-fitz-22     | 10.138.29.37    | a5000               |
| compsci-cluster-fitz-23     | 10.138.29.38    | a5000               |
| compsci-cluster-fitz-24     | 10.138.29.39    | a5000               |
| compsci-cluster-fitz-25     | 10.138.29.73    | a5000               |
| compsci-cluster-fitz-26     | 10.138.29.75    | a5000               |
| compsci-cluster-fitz-27     | 10.138.29.77    | a5000               |
| compsci-cluster-fitz-28     | 10.138.29.79    | a5000               |
| compsci-cluster-fitz-29     | 10.138.29.81    | a5000               |
| compsci-cluster-fitz-30     | 10.138.29.87    | a5000               |
| compsci-cluster-fitz-31     | 10.138.29.88    | a5000               |
| compsci-cluster-fitz-32     | 10.138.29.89    | a5000               |
| compsci-cluster-fitz-33     | 10.138.29.90    | a5000               |
| compsci-cluster-fitz-34     | 10.138.29.91    | a5000               |
| compsci-cluster-fitz-45     | 10.138.29.151   | rtx_pro_6000        |
| compsci-cluster-fitz-46     | 10.138.29.153   | rtx_pro_6000        |
| compsci-cluster-fitz-47     | 10.138.29.155   | rtx_pro_6000        |
| compsci-cluster-fitz-48     | 10.138.29.157   | rtx_pro_6000        |
| compsci-cluster-fitz-49     | 10.138.29.159   | rtx_pro_6000        |
| gpu-compute4                | 152.3.140.39    | p100                |
| gpu-compute5                | 152.3.140.41    | v100 + p100         |
| gpu-compute6                | 152.3.140.49    | v100                |
| linux41                     | 152.3.140.75    | p100 + a5000        |
| linux42                     | 10.236.184.101  | p100 + a5000        |
| linux43                     | 152.3.140.237   | p100 + a5000        |
| linux44                     | 152.3.140.238   | p100                |
| linux45                     | 152.3.140.239   | p100 + a5000        |
| linux46                     | 10.236.184.97   | p100                |
| linux47                     | 152.3.140.241   | p100 + rtx_2080     |
| linux48                     | 10.236.184.102  | p100                |
| linux49                     | 152.3.140.243   | p100                |
| linux50                     | 152.3.140.244   | p100 + rtx_2080     |
| linux51                     | 152.3.141.133   | rtx_2080 + rtx_5000 |
| linux52                     | 152.3.141.135   | rtx_2080 + rtx_5000 |
| linux53                     | 152.3.141.136   | rtx_2080 + rtx_5000 |
| linux54                     | 152.3.141.137   | rtx_2080 + rtx_5000 |
| linux55                     | 152.3.141.139   | rtx_2080 + rtx_5000 |
| linux56                     | 10.236.184.89   | rtx_2080            |
| linux57                     | 10.236.184.90   | rtx_2080            |
| linux58                     | 10.236.184.94   | rtx_2080            |
| linux59                     | 10.236.184.91   | rtx_2080            |
| linux60                     | 10.236.184.95   | rtx_2080            |

## compsci (CPU) partition

| Hostname                    | IP              |
|-----------------------------|-----------------|
| compsci-cluster-fitz-35     | 10.138.29.130   |
| compsci-cluster-fitz-36     | 10.138.29.132   |
| compsci-cluster-fitz-37     | 10.138.29.134   |
| compsci-cluster-fitz-38     | 10.138.29.136   |
| compsci-cluster-fitz-39     | 10.138.29.138   |
| compsci-cluster-fitz-40     | 10.138.29.140   |
| compsci-cluster-fitz-41     | 10.138.29.143   |
| compsci-cluster-fitz-42     | 10.138.29.145   |
| compsci-cluster-fitz-43     | 10.138.29.147   |
| compsci-cluster-fitz-44     | 10.138.29.149   |
| linux1                      | 10.236.184.79   |
| linux2                      | 152.3.140.189   |
| linux3                      | 152.3.140.194   |
| linux4                      | 152.3.140.196   |
| linux5                      | 152.3.140.197   |
| linux6                      | 152.3.140.198   |
| linux7                      | 152.3.140.199   |
| linux9                      | 152.3.140.203   |
| linux10                     | 152.3.140.209   |
| linux11                     | 10.236.184.63   |
| linux12                     | 10.236.184.73   |
| linux13                     | 10.236.184.74   |
| linux14                     | 10.236.184.76   |
| linux15                     | 10.236.184.78   |
| linux16                     | 152.3.141.196   |
| linux17                     | 152.3.141.197   |
| linux18                     | 10.236.184.25   |
| linux19                     | 152.3.141.199   |
| linux20                     | 10.236.184.104  |
| linux21                     | 152.3.141.201   |
| linux22                     | 152.3.141.83    |
| linux24                     | 152.3.141.183   |
| linux25                     | 152.3.141.177   |
| linux26                     | 152.3.141.175   |
| linux27                     | 152.3.141.174   |
| linux28                     | 152.3.141.172   |
| linux29                     | 152.3.141.171   |
| linux30                     | 152.3.141.158   |
| linux31                     | 10.236.184.85   |
| linux32                     | 10.236.184.86   |
| linux33                     | 10.236.184.92   |
| linux34                     | 10.236.184.88   |
| linux35                     | 10.236.184.93   |
| linux36                     | 10.236.184.96   |
| linux37                     | 152.3.140.184   |
| linux38                     | 152.3.140.185   |
| linux39                     | 152.3.140.186   |
| linux40                     | 10.236.184.61   |
