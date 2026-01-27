# Tree – DNS resolve Linux (dig/curl OK par IP mais pas par nom)

```mermaid
flowchart TD
A[DNS KO] --> B{Resolution via resolvectl ?}
B -->|Non| C[cat etc resolv conf] --> D[corriger nameservers] --> Z
B -->|Oui| E{Serveur DNS repond ?}
E -->|Non| F[dig DNS google com] --> F1[firewall route DNS down] --> Z
E -->|Oui| G{Split DNS domaine interne ?}
G -->|Oui| G1[config search domain + DNS interne] --> Z
G -->|Non| Z[OK]
```

## Commandes
```bash
resolvectl status || true
cat /etc/resolv.conf
dig google.com
dig @1.1.1.1 google.com
getent hosts google.com
```
