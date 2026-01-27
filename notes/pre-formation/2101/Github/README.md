# secure-infra-lab — Documentation Lab v1

Lab VirtualBox (3 VMs) pour administration système / sécurité :
- réseau interne isolé (`intnet-lab`) pour la communication inter-VM
- NAT pour l’accès Internet + administration depuis l’hôte via port-forward (SSH/RDP)
- stratégie de snapshots pour travailler proprement

---

## 1) Définitions

- **Hôte (host)** : PC physique (Windows) qui exécute VirtualBox.
- **VM / invité (guest)** : machine virtuelle (Ubuntu/Windows).
- **Réseau interne** : switch virtuel isolé entre VMs (pas de route vers Internet).
- **NAT** : accès Internet fourni par VirtualBox + port-forwarding depuis l’hôte.

---

## 2) Architecture (réseau + VMs)

### Principe retenu (sur chaque VM)
- **Adapter 1** : `Réseau interne` → `intnet-lab`
- **Adapter 2** : `NAT` → Internet + Port Forwarding (SSH/RDP)

### Diagramme simple (Mermaid)

```mermaid
flowchart TB
  Host[PC Hôte Windows] --> VB[VirtualBox]

  subgraph INTNET["Réseau interne : intnet-lab (Adapter 1)"]
    U1[Ubuntu #1\nSSH] --- U2[Ubuntu #2\nSSH]
    U1 --- W1[Windows Server\nRDP]
    U2 --- W1
  end

  VB --> U1
  VB --> U2
  VB --> W1

  subgraph NAT["NAT (Adapter 2)"]
    Internet[(Internet)]
  end

  U1 --> Internet
  U2 --> Internet
  W1 --> Internet

  Host -. Port Forward NAT .-> U1
  Host -. Port Forward NAT .-> U2
  Host -. Port Forward NAT .-> W1
