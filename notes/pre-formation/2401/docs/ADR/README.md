## Architecture Decision Records (ADR)

Les décisions techniques structurantes du lab sont tracées sous forme d’ADR (Architecture Decision Records).

### Emplacement
- `docs/adr/`

### Règles
- 1 décision importante = 1 ADR
- Nommage : `NNNN-titre-court.md` (ex: `0001-virtualbox-networking.md`)
- Statut : `Proposed | Accepted | Superseded | Deprecated`
- Toute évolution majeure doit :
  1) créer un nouvel ADR (ou “Supersede” l’ancien)
  2) mettre à jour cette liste

### Index des ADR
| ID | Titre | Statut | Date | Fichier |
|---:|-------|--------|------|---------|
| 0001 | Réseaux VirtualBox (NAT + Réseau interne) | Accepted | 2026-02-04 | `docs/adr/0001-virtualbox-networking.md` |
| 0002 | Choix des OS des VMs du lab | Accepted | 2026-02-04 | `docs/adr/0002-os-selection.md` |
