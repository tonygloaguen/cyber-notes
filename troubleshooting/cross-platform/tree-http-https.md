# Tree – HTTP/HTTPS inaccessible (client → service)

```mermaid
flowchart TD
A[Site app KO] --> B{DNS OK ?}
B -->|Non| B1[nslookup dig Resolve-DnsName] --> Z
B -->|Oui| C{TCP 80 443 OK ?}
C -->|Non| C1[curl -v Test-NetConnection] --> C2[firewall NAT SG] --> Z
C -->|Oui| D{TLS OK ?}
D -->|Non| D1[openssl s_client curl -vk] --> D2[cert chain SNI protocole] --> Z
D -->|Oui| E{HTTP 5xx ?}
E -->|Oui| E1[logs app nginx iis] --> E2[backend db dep] --> Z
E -->|Non| F{HTTP 4xx ?}
F -->|Oui| F1[auth routing] --> Z
F -->|Non| Z[OK]
```

## Tests (Linux)
```bash
dig +short example.com
curl -vk https://example.com
openssl s_client -connect example.com:443 -servername example.com
```

## Tests (Windows)
```powershell
Resolve-DnsName example.com
Test-NetConnection example.com -Port 443
curl.exe -vk https://example.com
```
