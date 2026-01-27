# Déploiement “confort SSH” — Scripts templates (Windows PowerShell + Linux Bash)

Ce dépôt contient deux scripts complémentaires pour mettre en place **une connexion SSH par clé** (sans mot de passe) entre un poste **Windows** (client) et une **VM Linux Ubuntu/Debian** (serveur), puis **durcir** la configuration SSH **sans se verrouiller dehors**.

- `Deploy-SSHKey.ps1` : côté **Windows** (client) — génère la clé si besoin, pousse la clé publique sur la VM, teste la connexion, optionnellement crée un alias dans `~/.ssh/config`.
- `deploy_ssh_server.sh` : côté **Linux** (serveur) — installe/active `openssh-server`, crée un utilisateur non-root, applique une configuration SSH via **drop-in** (`sshd_config.d`), valide la config avant redémarrage, optionnellement installe/ajoute une clé publique.

---

## Sommaire

- [Objectif](#objectif)
- [Pré-requis](#pré-requis)
- [Usage recommandé](#usage-recommandé-ordre-sûr)
- [Script 1 — Deploy-SSHKey.ps1 (Windows / Client)](#script-1--deploy-sshkeyps1-windows--client)
- [Script 2 — deploy_ssh_serversh (Linux / Serveur)](#script-2--deploy_ssh_serversh-linux--serveur)
- [Scénarios VirtualBox : NAT + port-forward vs IP directe](#scénarios-virtualbox--nat--port-forward-vs-ip-directe)
- [Dépannage (erreurs fréquentes)](#dépannage-erreurs-fréquentes)
- [Bonnes pratiques sécurité](#bonnes-pratiques-sécurité)

---

## Objectif

1. **Préparer la VM Linux** : `sshd` installé, service actif, utilisateur non-root prêt, root interdit.
2. **Déployer la clé publique** depuis Windows vers `~/.ssh/authorized_keys` du user Linux.
3. **Valider** que la connexion par clé fonctionne.
4. **Durcir** : désactiver le mot de passe, réduire les fonctionnalités SSH (optionnel).

---

## Pré-requis

### Côté Windows (client)
- **OpenSSH Client** installé (Windows Optional Features) : commandes `ssh` et `ssh-keygen` disponibles.
- Accès réseau à la VM :
  - VirtualBox NAT + port-forward : `127.0.0.1:2224` (exemple) → VM port `22`.
  - Bridge / Host-only : IP directe de la VM (ex. `192.168.100.11`) sur port `22`.

### Côté Linux (serveur)
- Ubuntu/Debian.
- Exécution du script bash en root : `sudo`.
- **Important** : le mot de passe doit être autorisé **au moins une fois** pour pousser la clé (ensuite on le coupe).

---

## Usage recommandé (ordre sûr)

### 1) Sur la VM Linux (serveur) : préparer SSH + utilisateur
```bash
sudo ./deploy_ssh_server.sh --user gloaguen
2) Sur Windows (client) : pousser la clé publique
Exemple VirtualBox NAT + port-forward

.\Deploy-SSHKey.ps1 -HostName 127.0.0.1 -Port 2224 -User gloaguen -Alias ubuntuserver -Verbose
3) Tester la connexion par clé
ssh ubuntuserver
# ou
ssh -p 2224 gloaguen@127.0.0.1
4) Sur la VM Linux : durcir (désactiver le mot de passe)
Uniquement après validation que la clé marche :

sudo ./deploy_ssh_server.sh --user gloaguen --harden --disable-password
Script 1 — Deploy-SSHKey.ps1 (Windows / Client)
À quoi il sert
Automatiser le “bootstrap” côté Windows :

Vérifie que ssh et ssh-keygen sont disponibles.

Génère une clé Ed25519 si elle n’existe pas.

Pousse la clé publique sur la VM dans ~/.ssh/authorized_keys.

Teste la connexion par clé en mode non-interactif.

Optionnel : ajoute un alias Host dans ~/.ssh/config.

Paramètres
Paramètre	Obligatoire	Défaut	Description
-HostName	✅	—	IP/hostname cible (ex. 127.0.0.1 ou 192.168.100.11).
-Port	❌	22	Port SSH (ex. 2224 si port-forward).
-User	✅	—	Utilisateur Linux (non-root) qui recevra la clé.
-Alias	❌	""	Alias optionnel pour ~/.ssh/config.
-KeyPath	❌	%USERPROFILE%\.ssh\id_ed25519	Chemin de la clé privée (publique = .pub).
Fonctionnement détaillé (étapes)
Vérification prérequis

Get-Command ssh et Get-Command ssh-keygen.

Génération clé

Si la clé n’existe pas : ssh-keygen -t ed25519 -a 64 -f <KeyPath> -N ""

Lecture de la clé publique

Get-Content -Raw pour éviter les soucis de lecture “ligne par ligne”.

Déploiement sur la VM

Connexion SSH en forçant l’auth par mot de passe pour cette étape :

PreferredAuthentications=password

PubkeyAuthentication=no

Commande distante bash qui :

crée ~/.ssh, fixe les permissions

ajoute la clé uniquement si absente (idempotent)

supprime \r (CRLF Windows)

Test de connexion par clé

ssh ... -o BatchMode=yes "echo OK" → si ça passe, la clé fonctionne.

Option alias

Ajoute (si absent) un bloc Host <Alias> dans ~/.ssh/config.

Exemple (VirtualBox port-forward)
.\Deploy-SSHKey.ps1 -HostName 127.0.0.1 -Port 2224 -User gloaguen -Alias ubuntuserver -Verbose
Script 2 — deploy_ssh_server.sh (Linux / Serveur)
À quoi il sert
Préparer et durcir sshd sans casser /etc/ssh/sshd_config :

Installe openssh-server.

Active le service ssh.

S’assure qu’un utilisateur non-root existe (et optionnellement l’ajoute au groupe sudo).

Crée un drop-in /etc/ssh/sshd_config.d/99-lab-hardening.conf.

Valide la config SSH via sshd -t avant de redémarrer.

Optionnel : ajoute une clé publique dans authorized_keys sans écraser les clés existantes.

Options
Option	Obligatoire	Description
--user <name>	✅	Utilisateur non-root à créer/assurer.
--pubkey <file>	❌	Ajoute la clé publique dans authorized_keys (append si absent).
--harden	❌	Ajoute des options de durcissement (désactive X11, forwarding…).
--disable-password	❌	Met PasswordAuthentication no (à faire après test clé).
Fonctionnement détaillé (étapes)
apt-get update + apt-get install openssh-server

systemctl enable --now ssh

Création user si absent (adduser --disabled-password ...)

Création du fichier drop-in :

PermitRootLogin no

PubkeyAuthentication yes

PasswordAuthentication yes (par défaut, pour bootstrap)

Si --harden :

KbdInteractiveAuthentication no

ChallengeResponseAuthentication no

X11Forwarding no

AllowTcpForwarding no

Si --disable-password :

force PasswordAuthentication no (idempotent)

Validation : sshd -t (si invalide → pas de restart)

Restart : systemctl restart ssh

Si --pubkey :

crée ~/.ssh, fixe permissions

ajoute la clé sans doublon dans authorized_keys

Exemples
Préparation simple :

sudo ./deploy_ssh_server.sh --user gloaguen
Préparation + ajout clé :

sudo ./deploy_ssh_server.sh --user gloaguen --pubkey /tmp/id_ed25519.pub
Durcissement après test clé :

sudo ./deploy_ssh_server.sh --user gloaguen --harden --disable-password
Scénarios VirtualBox : NAT + port-forward vs IP directe
NAT + port-forward (classique)
Depuis Windows, tu te connectes à l’hôte 127.0.0.1 avec un port “mappé” (ex. 2224) :

ssh -p 2224 gloaguen@127.0.0.1
Bridge / Host-only (IP directe VM)
Tu te connectes directement à l’IP de la VM, port 22 :

ssh gloaguen@192.168.100.11
Dépannage (erreurs fréquentes)
ssh-copy-id introuvable (Windows)
Normal : Windows PowerShell n’a pas ssh-copy-id.
Utilise Deploy-SSHKey.ps1 (c’est précisément son rôle).

Permission denied (publickey)
Cause fréquente : tu as déjà désactivé le mot de passe côté serveur (PasswordAuthentication no) avant d’avoir copié la clé.

Sur la VM : réautoriser temporairement le mot de passe via drop-in, puis :

sudo sshd -t && sudo systemctl restart ssh
Ensuite relancer Deploy-SSHKey.ps1.

ssh.service failed après modification
Cause : config invalide.

Toujours valider avant restart :

sudo sshd -t
Voir logs :

sudo journalctl -xeu ssh.service --no-pager
Ce dépôt privilégie les drop-ins pour éviter de casser le fichier principal.

Problèmes CRLF / clés mal copiées
Le script PowerShell supprime \r avant insertion côté serveur, ce qui évite les clés “cassées”.

Bonnes pratiques sécurité
Toujours travailler avec un utilisateur non-root.

Tester la connexion par clé avant de désactiver le mot de passe.

Utiliser sshd -t avant tout redémarrage de ssh.

Après durcissement, conserver un accès console VM (VirtualBox) “au cas où”.