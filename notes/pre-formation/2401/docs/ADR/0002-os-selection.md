# ADR 0002 — Choix des OS des VMs du lab (socle actuel)

- **Statut**: Accepted
- **Date**: 2026-01-24
- **Décideurs**: Tony G.
- **Contexte / Référence**: Lab VirtualBox "secure-infra-lab" — objectifs admin sys/cyber (blue team), AD, Linux, automatisation

## Contexte
Le lab doit couvrir :
- Cas “entreprise” : Active Directory / DNS sous Windows Server
- Administration Linux : SSH, services, durcissement, logs
- Expérimentations : segmentation réseau, accès distant, supervision
- Support des scripts/outils (Python, Ansible, agents)

## Décision
Le lab standardise le socle OS suivant (phase actuelle) :
- **1 VM Windows Server** (ex: 2022) : AD DS/DNS (contrôleur de domaine)
- **2 VMs Linux Ubuntu Server LTS** :
  - Ubuntu #1 : serveur/outillage (SSH, services, tests)
  - Ubuntu #2 : serveur secondaire (tests, segmentation, scénarios, redondance)

> Note : une **VM Windows Client (Win10/11)** sera ajoutée ultérieurement pour
> joindre le domaine et tester GPO (ce n’est pas requis pour valider la base réseau/accès distant).

## Options considérées
1. **Windows Server + 2x Ubuntu Server (choisi)**
   - ✅ Colle aux besoins actuels (réseau, SSH/RDP, services Linux, scénarios)
   - ✅ Permet des tests multi-serveurs Linux (segmentation, rôles séparés)
   - ❌ Ne couvre pas encore les tests GPO côté poste client Windows
2. **Windows Server + Windows Client + 1x Ubuntu**
   - ✅ Cible “entreprise” complète pour AD/GPO
   - ❌ Moins flexible si on veut 2 rôles Linux distincts dès le départ
3. **Tout Windows**
   - ✅ AD/GPO maximal
   - ❌ Manque Linux (important DevOps/cyber)
4. **Tout Linux**
   - ✅ Très bon pour Linux/containers
   - ❌ Pas de vrai AD/GPO Windows

## Conséquences
### Positives
- Lab immédiatement opérationnel et aligné avec ton schéma actuel
- Deux serveurs Linux pour séparer les rôles et tester des scénarios réalistes
- Windows Server présent pour AD/DNS

### Négatives / Risques
- Ressources (RAM/CPU/disque) surtout côté Windows Server
- Tests GPO / poste joint au domaine reportés tant que Win Client n’existe pas

### Mesures de mitigation / Suivi
- Ajouter plus tard une VM **Windows Client** si l’objectif AD/GPO devient prioritaire
- Snapshots avant changements majeurs
- Documenter versions ISO + paramètres VirtualBox dans le README
