# Exporter un dashboard Grafana en JSON (Windows / PowerShell, sans jq)

Ce document décrit une procédure reproductible pour :
- charger les variables d’environnement depuis un fichier `.env` (non versionné),
- vérifier l’accès à l’API Grafana,
- lister les dashboards,
- exporter un dashboard par `uid` en JSON **portable** (sans dépendance à `jq`),
- versionner l’export dans Git.

## Prérequis

- Grafana accessible (ex: `http://localhost:3000`)
- Un token Grafana (Service Account recommandé) avec droits suffisants (Editor généralement OK)
- Windows PowerShell
- Un fichier `.env` **non committé** contenant :
  - `GRAFANA_URL`
  - `GRAFANA_TOKEN`

### Exemple de `.env` (NE PAS COMMITTER)
```env
GRAFANA_URL=http://localhost:3000
GRAFANA_TOKEN=glsa_xxxxx
