# 👀 Professeur Layton : Le Manoir Mystérieux

Bienvenue dans *Professeur Layton : Le Manoir Mystérieux*, un jeu d'énigmes en mode texte inspiré du célèbre univers du Professeur Layton.

---

## 🚀 Installation et démarrage

### 1. Pré-requis
- Avoir **Swift** installé sur votre machine.  
  ➔ [Installer Swift](https://www.swift.org/download/)

**OU**

- Si vous ne souhaitez pas installer Swift :  
  ➔ Vous pouvez jouer en ligne sur [OnlineGDB](https://www.onlinegdb.com/#)  
  (choisissez "Swift" comme langage avant d'exécuter).

---

### 2. Lancer le jeu
- Téléchargez tous les fichiers :
  - `main.swift`
  - `objets.json`
  - `enigmes.json`
  - `personnages.json`

- Ensuite, exécutez dans le terminal :

```bash
swift main.swift
```

---

## 🎮 Comment jouer

### Commandes disponibles :

| Commande           | Description |
|--------------------|-------------|
| `aller <direction>` | Se déplacer (`nord`, `sud`, `est`, `ouest`) |
| `utiliser <objet>`  | Utiliser un objet depuis votre inventaire |
| `inventaire`        | Voir les objets que vous possédez |
| `quitter`           | Quitter et sauvegarder la partie |

---

## 🌟 Objectif du jeu

Explorez les différentes salles du manoir en compagnie du Professeur Layton.  
Résolvez les énigmes posées par les personnages mystérieux, trouvez des objets cachés, et atteignez l'Observatoire pour découvrir le secret final du manoir.

---

## 🛠️ Fonctionnalités

- Système de **sauvegarde automatique** (`sauvegarde.json`).
- Chaque partie peut être **reprise** plus tard.
- **Découverte d'objets** dans certaines salles (prise automatique après confirmation).
- **Énigmes dynamiques** tirées d'une grande banque aléatoire.
- **Utilisation d'objets** pour débloquer certaines zones ou obtenir des bonus.

---

## 👾 À propos du projet

Projet de programmation en Swift pour découvrir :
- Les structures (`struct`) et classes (`class`)
- La sérialisation/désérialisation JSON
- Les interactions utilisateur en ligne de commande
- La gestion d'un inventaire et d'un système de progression
- La création d'un jeu narratif textuel

---

**Merci d'avoir exploré ce manoir mystérieux ! 🔍**  
*Le vrai mystère n’est pas de trouver toutes les réponses, mais de ne jamais arrêter de chercher...*

