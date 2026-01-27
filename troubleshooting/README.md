# Troubleshooting Library (Decision Trees + Runbooks)

Objectif : fournir des arbres de dépannage (flowcharts) + commandes terrain pour diagnostiquer vite.
Chaque arbre :
- commence par le symptôme,
- propose des vérifications simples → puis profondes,
- finit par actions correctives + collecte d’infos.

## Convention
- ✅ = étape de vérification
- 🧪 = test reproductible
- 🧾 = preuve à capturer (copier/coller dans un ticket)
- 🔧 = action corrective
- ⚠️ = attention / risque

## Usage
1. Choisir l’arbre lié au symptôme.
2. Suivre les branches, capturer les preuves.
3. Appliquer la correction minimale.
4. Valider (test final) + documenter.

## Mermaid
Les diagrammes utilisent Mermaid `flowchart TD`.
GitHub rend Mermaid nativement.
