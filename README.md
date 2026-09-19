# PSN_OS

Système d'exploitation Linux personnalisé, basé sur **Debian (live-build)**, avec :

- **Wifi** géré nativement via NetworkManager (firmwares non-libres inclus)
- **Compatibilité applications Windows** via Wine + Winetricks (préinstallés)
- **Assistant de configuration au premier démarrage** (OOBE) façon Windows 11 :
  langue → wifi → compte utilisateur → fuseau horaire → thème
- Bureau léger **XFCE** (rapide, personnalisable, look modernisé)
- Build automatique de l'**ISO** via **GitHub Actions** (Ubuntu runner + live-build)

## Arborescence

```
PSN_OS/
├── config/
│   ├── package-lists/psnos.list.chroot   # paquets installés dans l'ISO
│   └── includes.chroot/                  # fichiers copiés tels quels dans le système
│       ├── etc/psnos/branding.conf
│       └── usr/local/bin/psnos-oobe      # script de configuration initiale
├── build.sh                              # lance live-build en local (Debian/Ubuntu)
├── .github/workflows/build-iso.yml       # build + release de l'ISO sur GitHub
└── README.md
```

## Builder en local (sur une machine Debian/Ubuntu)

```bash
sudo apt update
sudo apt install -y live-build git
git clone <ton-repo> PSN_OS && cd PSN_OS
sudo ./build.sh
# → génère psnos-<date>.iso à la racine
```

## Builder automatiquement via GitHub

1. Crée un repo GitHub et pousse ce dossier tel quel (`git init && git add . && git commit -m "init" && git push`).
2. Le workflow `.github/workflows/build-iso.yml` se déclenche à chaque push sur `main`
   ou manuellement (onglet **Actions → Run workflow**).
3. Une fois le job terminé, l'ISO est disponible en téléchargement dans
   **Actions → (le run) → Artifacts → psnos-iso**, et aussi attachée automatiquement
   à une **Release** si tu pousses un tag `v*` (ex: `git tag v1.0 && git push --tags`).

## Installation sur le disque (comme le setup Windows)

Sur le bureau du live-CD, une icône **"Installer PSN_OS"** lance **Calamares**,
l'installateur graphique. Étapes dans l'ordre :
1. Bienvenue / vérifications (RAM, espace disque)
2. **Langue** (choix de la langue système + région)
3. **Clavier**
4. Partitionnement du disque (automatique ou manuel)
5. **Création du compte utilisateur local** (nom, nom d'utilisateur, mot de passe, mot de passe root)
6. Résumé puis installation
7. Redémarrage sur le système installé

Configuration de l'installateur : `config/includes.chroot/etc/calamares/`
(`settings.conf` pour l'ordre des étapes, `modules/users.conf` pour le compte local,
`modules/locale.conf` pour la langue, `branding/psnos/` pour l'habillage visuel).

Une fois installé sur disque, l'assistant **psnos-oobe** (voir plus bas) prend le relais
au premier login pour finaliser le Wifi et le thème.


Au premier login, `psnos-oobe` se lance automatiquement (via autostart XFCE) et propose,
dans l'ordre, comme sur Windows 11 :
1. Choix de la langue / clavier
2. Connexion Wifi (liste des réseaux détectés via `nmcli`)
3. Création du compte utilisateur (nom + mot de passe)
4. Fuseau horaire
5. Choix du thème clair/sombre

Ensuite il se désactive tout seul (fichier marqueur `~/.config/psnos/oobe_done`).

## Compatibilité Windows

Wine + Winetricks + `dxvk` sont préinstallés. Pour lancer un `.exe` :
```bash
wine mon_application.exe
```
Un lanceur graphique "Ouvrir avec Wine" est ajouté au clic-droit dans le gestionnaire
de fichiers (Thunar) via `config/includes.chroot`.

## Personnaliser

- Ajouter/retirer des paquets → `config/package-lists/psnos.list.chroot`
- Changer le fond d'écran / logo / nom → `config/includes.chroot/etc/psnos/branding.conf`
  et les fichiers dans `config/includes.chroot/usr/share/backgrounds/`
- Modifier l'assistant de config → `config/includes.chroot/usr/local/bin/psnos-oobe`
