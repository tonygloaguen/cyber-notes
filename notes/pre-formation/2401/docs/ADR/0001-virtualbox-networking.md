# ADR 0001 — Réseaux VirtualBox (NAT + Réseau interne)

- **Statut**: Accepted
- **Date**: 2026-01-24
- **Décideurs**: Tony G.
- **Contexte / Référence**: Lab VirtualBox "secure-infra-lab" — besoin Internet + réseau isolé entre VMs

## Contexte
Le lab doit permettre :
- Accès Internet pour mises à jour/paquets (temporaire ou contrôlé)
- Communication inter-VM stable (Windows Server, Linux, etc.)
- Isolation du réseau "lab" vis-à-vis du LAN physique
- Possibilité de port-forward (SSH/RDP) depuis l’hôte

## Décision
Chaque VM aura **2 cartes réseau** :
1. **Carte 1 : NAT**  
   - Objectif : accès Internet (updates, packages)
   - Optionnellement : port forwarding (SSH/RDP) si nécessaire
2. **Carte 2 : Réseau interne (Internal Network) : `intnet-lab`**  
   - Objectif : réseau privé inter-VM, non routé vers le LAN
   - Adressage IPv4 statique (ex: 192.168.100.0/24)

## Options considérées
1. **NAT + Réseau interne (choisi)**
   - ✅ Simple, reproductible, isolé, compatible port-forward
   - ✅ Pas d’exposition directe sur le LAN
   - ❌ NAT peut masquer certains tests “réalistes” (routage/segmentation)
2. **Bridge + Réseau interne**
   - ✅ Plus “réaliste” côté LAN
   - ❌ Expose les VMs sur le réseau local (risque + contraintes)
   - ❌ Dépend du réseau physique (moins portable)
3. **NAT Network + Réseau interne**
   - ✅ NAT partagé, plus flexible que NAT simple
   - ❌ Plus complexe (DHCP/paramètres VBox), moins nécessaire pour le lab actuel
4. **Host-Only + NAT**
   - ✅ Bon contrôle host<->VM
   - ❌ Réseau host-only parfois moins intuitif, et pas requis si `intnet-lab` suffit

## Conséquences
### Positives
- Architecture claire : Internet (NAT) / Lab isolé (intnet-lab)
- Reproductible sur n’importe quel PC, indépendamment du LAN
- Port-forward possible pour accès admin depuis l’hôte

### Négatives / Risques
- Risque d’erreur de configuration (inversion des cartes, IP mal assignées)
- NAT : visibilité réseau limitée (certains scénarios “entre sous-réseaux” non testables)

### Mesures de mitigation / Suivi
- Standardiser : Carte 1 = NAT, Carte 2 = `intnet-lab`
- Documenter IPs et ports dans le README
- Tests minimum : ping inter-VM via intnet-lab + update via NAT
