# Tree – Auth LDAP/SSO (échecs login, SSO cassé)

## Diagramme

```mermaid
flowchart TD
A[Auth KO] --> B{DNS time OK ?}
B -->|Non| B1[corriger DNS + NTP] --> Z
B -->|Oui| C{Connectivite LDAP SSO OK ?}
C -->|Non| C1[test port 389 636 443] --> C2[firewall routes] --> Z
C -->|Oui| D{Identifiants bind DN OK ?}
D -->|Non| D1[verifier secret, rotation, perms] --> Z
D -->|Oui| E{TLS Cert OK ?}
E -->|Non| E1[corriger cert CA] --> Z
E -->|Oui| F{Attributs groupes OK ?}
F -->|Non| F1[mapper attributs, claims, groupes] --> Z
F -->|Oui| Z[OK]
```

## Tests rapides
Linux:
```bash
# TCP
nc -vz <ldap_host> 389
nc -vz <ldap_host> 636
# (si ldap-utils dispo)
ldapsearch -x -H ldap://<ldap_host> -D "<binddn>" -W -b "<base>"
```

Windows:
```powershell
Test-NetConnection <ldap_host> -Port 389
Test-NetConnection <ldap_host> -Port 636
```
