# Tree – SSH impossible

## Diagramme

```mermaid
flowchart TD
A[SSH KO] --> B{IP route OK ?}
B -->|Non| B1[ping, ip r, traceroute] --> Z
B -->|Oui| C{Port 22 ecoute ?}
C -->|Non| C1[sudo ss -lntp puis grep 22] --> C2[systemctl start ssh corriger config] --> Z
C -->|Oui| D{Firewall bloque ?}
D -->|Oui| D1[ufw status iptables -S nft list ruleset] --> D2[ouvrir 22 tcp] --> Z
D -->|Non| E{Auth echoue ?}
E -->|Oui| E1{Mot de passe ou cle ?}
E1 -->|Clé| E2[perms ssh, authorized_keys, ssh -vvv] --> E3[corriger permissions cle sshd_config] --> Z
E1 -->|MDP| E4[PAM, verrouillage, AllowUsers] --> E5[corriger PAM sshd_config] --> Z
E -->|Non| F{Blocage fail2ban IDS ?}
F -->|Oui| F1[fail2ban-client status sshd] --> F2[unban IP] --> Z
F -->|Non| Z[OK]
```

## Runbook

### 1) Réseau
```bash
ping -c 2 <ip>
ip a
ip r
```

### 2) SSH daemon
```bash
sudo systemctl status ssh --no-pager
sudo ss -lntp | grep -E ':(22|2222)\b'
sudo sshd -t
```

### 3) Logs
```bash
sudo journalctl -u ssh -n 200 --no-pager
sudo tail -n 200 /var/log/auth.log
```

### 4) Debug côté client
```bash
ssh -vvv user@host
```

### 5) Permissions clés (classique)
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
```
