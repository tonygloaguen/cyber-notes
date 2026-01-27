# Windows Server – Decision Trees

Arbres disponibles :
- AD/Logon (authentification / join domain / Kerberos)
- DNS (résolution, zones, forwarders)
- DHCP (baux, autorisations, relay)
- RDP (connexion, NLA, certificats)
- GPO (application, réplication SYSVOL)
- Hyper-V (VM qui ne démarre pas, réseau virtuel)
- Storage (disque plein, iSCSI/SMB, permissions)

Astuce : en Windows, beaucoup de diagnostics se résolvent en partant de :
- DNS (souvent la cause racine)
- Time sync (Kerberos)
- Event Viewer (IDs) / `Get-WinEvent`
