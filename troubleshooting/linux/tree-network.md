# Tree – Réseau Linux (pas d’IP / pas d’accès)

```mermaid
flowchart TD
A[Pas de reseau] --> B{Lien up ?}
B -->|Non| B1[ethtool, ip link] --> B2[cable virtio vswitch] --> Z
B -->|Oui| C{IP obtenue ?}
C -->|Non| C1{DHCP ou statique ?}
C1 -->|DHCP| C2[journalctl -u NetworkManager dhclient -v] --> C3[DHCP serveur relay, NM netplan] --> Z
C1 -->|Statique| C4[netplan get fichiers] --> C5[corriger netplan + apply] --> Z
C -->|Oui| D{Route par defaut ?}
D -->|Non| D1[ip r] --> D2[ajouter default via gw] --> Z
D -->|Oui| E{DNS OK ?}
E -->|Non| E1[resolvectl status dig] --> E2[corriger DNS resolved] --> Z
E -->|Oui| F{Firewall ?}
F -->|Oui| F1[nft iptables ufw] --> F2[ajuster regles] --> Z
F -->|Non| Z[OK]
```

## Commandes
```bash
ip link
ip a
ip r
resolvectl status || cat /etc/resolv.conf
ping -c 2 1.1.1.1
ping -c 2 google.com
sudo journalctl -u NetworkManager -n 200 --no-pager
```

## Netplan (Ubuntu)
```bash
sudo netplan try
sudo netplan apply
```
