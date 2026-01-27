# Tree – Disk full / Inodes full

```mermaid
flowchart TD
A[Plus d'espace] --> B{Espace ou inodes ?}
B -->|Espace| C[df -h]
B -->|Inodes| D[df -ih]

C --> E{Quel FS ? var home ?}
E --> F[du -xhd1 + tri] --> G[logrotate purge move] --> Z

D --> H[find gros volume de petits fichiers] --> I[purge cache tmp spool] --> Z

Z[OK]
```

## Commandes
```bash
df -h
df -ih
sudo du -xhd1 /var | sort -h
sudo journalctl --disk-usage
sudo journalctl --vacuum-time=7d
sudo apt clean
sudo find /var/log -type f -name "*.gz" -size +100M -print
```
