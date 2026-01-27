# Tree – TLS / Certificats (erreurs navigateur, handshake, chaîne)

## Symptômes
- “certificate verify failed”
- “unknown CA”
- “hostname mismatch”
- erreurs TLS après renouvellement

```mermaid
flowchart TD
A[TLS error] --> B{Nom SAN CN correspond ?}
B -->|Non| B1[refaire cert avec bon SAN] --> Z
B -->|Oui| C{Chaine complete servie ?}
C -->|Non| C1[openssl s_client -showcerts] --> C2[installer intermediaire chain] --> Z
C -->|Oui| D{Client trust store OK ?}
D -->|Non| D1[importer CA racine intermediaire] --> Z
D -->|Oui| E{TLS version ciphers compatibles ?}
E -->|Non| E1[ajuster config nginx iis apache] --> Z
E -->|Oui| Z[OK]
```

## Commandes
```bash
openssl s_client -connect host:443 -servername host -showcerts
curl -vk https://host
```
