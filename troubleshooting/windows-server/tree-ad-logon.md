# Tree – AD Logon / Join Domain / Kerberos

## Symptômes
- “The trust relationship… failed”
- “There are currently no logon servers…”
- Join domain impossible
- Login lent / échec SSO

## Diagramme (Mermaid)

```mermaid
flowchart TD
A[Symptome AD Logon] --> B{Cote client ou DC ?}
B -->|Client| C[Client IP DNS Temps]
B -->|DC| D[DC Sante AD DNS Replication]

C --> C1{DNS du client DC ?}
C1 -->|Non| C1a[Mettre DNS primaire IP DC DNS AD] --> C2
C1 -->|Oui| C2{Resolution OK ?}
C2 -->|Non| C2a[nslookup domaine _ldap _tcp dc _msdcs] --> C2b[Corriger DNS zone, enregistrements SRV, forwarders] --> Z
C2 -->|Oui| C3{Heure OK + -5 min ?}
C3 -->|Non| C3a[w32tm resync + verifier source NTP] --> Z
C3 -->|Oui| C4{Port Firewall OK ?}
C4 -->|Non| C4a[Test-NetConnection DC 88 389 445 53] --> C4b[Ouvrir ports corriger reseau] --> Z
C4 -->|Oui| C5{Compte mot de passe verrouillage ?}
C5 -->|Oui| C5a[Deverrouiller reset verifier GPO password] --> Z
C5 -->|Non| C6{Kerberos ticket OK ?}
C6 -->|Non| C6a[klist purge, relog, verifier SPN] --> Z
C6 -->|Oui| C7{GPO SYSVOL DFS OK ?}
C7 -->|Non| C7a[gpresult, dcdiag, dfsrdiag] --> Z
C7 -->|Oui| Z[Test final + collecte preuves]

D --> D1{dcdiag repadmin OK ?}
D1 -->|Non| D1a[dcdiag v repadmin replsummary] --> D1b[Corriger replication, DNS, SYSVOL] --> Z
D1 -->|Oui| D2{DNS AD OK ?}
D2 -->|Non| D2a[Verifier SRV + zone _msdcs] --> D2b[Reparer DNS redemarrer Netlogon] --> Z
D2 -->|Oui| Z
```

## Runbook (pas à pas)

### 1) Vérifs client (priorité)
✅ IP / gateway
```powershell
ipconfig /all
route print
```

✅ DNS doit pointer vers le(s) DC(s)
```powershell
Get-DnsClientServerAddress
nslookup domaine.local
nslookup -type=SRV _ldap._tcp.dc._msdcs.domaine.local
```

✅ Temps (Kerberos)
```powershell
w32tm /query /status
w32tm /resync
```

✅ Connectivité ports essentiels vers DC
- DNS 53
- Kerberos 88
- LDAP 389 (ou LDAPS 636 si utilisé)
- SMB 445 (SYSVOL / scripts)

```powershell
Test-NetConnection DC01 -Port 53
Test-NetConnection DC01 -Port 88
Test-NetConnection DC01 -Port 389
Test-NetConnection DC01 -Port 445
```

### 2) Côté DC – Santé AD
🧪 Diagnostics de base
```powershell
dcdiag /v
repadmin /replsummary
repadmin /showrepl
```

🧪 DNS AD – enregistrements SRV
```powershell
nslookup -type=SRV _ldap._tcp.dc._msdcs.domaine.local 127.0.0.1
```

### 3) Collecte de preuves (à mettre dans un ticket)
🧾
- `ipconfig /all` (client)
- `w32tm /query /status`
- résultats SRV `_ldap._tcp...`
- `dcdiag /v` + `repadmin /replsummary`
- Event Viewer (System, DNS Server, Directory Service)

## Corrections fréquentes (rapides)
🔧 Client DNS mal configuré → corriger DNS (ne pas utiliser 8.8.8.8 en DNS primaire sur un poste joint au domaine)
🔧 Décalage horaire → fixer NTP (PDC Emulator)
🔧 SRV manquants → redémarrer Netlogon sur DC et forcer réenregistrement DNS
```powershell
net stop netlogon
net start netlogon
ipconfig /registerdns
```
