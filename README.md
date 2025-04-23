# 🧠 Professeur Layton : Le Manoir Mystérieux

Bienvenue dans **Le Manoir Mystérieux**, un jeu d'aventure textuelle en ligne de commande inspiré de l’univers du Professeur Layton. Résolvez des énigmes, explorez un vieux manoir et découvrez le secret bien gardé de son propriétaire...

---

## 🎮 Fonctionnalités principales

- Exploration libre d’un manoir en compagnie du Professeur Layton
- 10 salles interconnectées avec des objets à collecter
- 50 énigmes aléatoires à résoudre (une par salle)
- Un système d’inventaire et d’utilisation d’objets
- Sauvegarde et chargement des parties
- Une conclusion scénarisée avec révélation finale

---

## 🛠️ Configuration requise

- Swift 5+
- macOS ou Linux avec `swift` installé  
(📦 Pour l’installer : https://www.swift.org/download/)

---

🚀 Installation et lancement
💻 Option 1 : Jouer en local

    Clonez le projet :

git clone https://github.com/votre-utilisateur/professeur-layton-manoir.git
cd professeur-layton-manoir

Assurez-vous que les fichiers suivants sont présents :

    main.swift

    enigmes.json

    objets.json

    personnages.json

Compilez et exécutez avec Swift :

    swift main.swift

    ℹ️ Si vous n’avez pas Swift installé, vous pouvez le télécharger ici : https://swift.org/download

🌐 Option 2 : Jouer en ligne (sans installer Swift)

Vous pouvez jouer directement dans votre navigateur via :
▶️ https://www.onlinegdb.com/

    Rendez-vous sur le site

    Choisissez Swift comme langage

    Copiez le contenu de main.swift dans l’éditeur

    Créez trois fichiers : enigmes.json, personnages.json, objets.json

    Cliquez sur Run pour lancer le jeu !
🕹️ Comment jouer
🎯 Objectif :

Explorer les différentes pièces du manoir, résoudre les énigmes posées par chaque personnage et découvrir le secret final dans l’observatoire.
🧭 Commandes disponibles :
Commande	Description
aller <direction>	Se déplacer vers une autre salle (nord, sud, est, ouest)
prendre <objet>	Ramasser un objet visible dans la salle
utiliser <objet>	Utiliser un objet de l’inventaire (si pertinent)
inventaire	Affiche votre inventaire actuel
quitter	Sauvegarde et quitte le jeu

📝 Les réponses aux énigmes doivent être données en un mot (ex : ombre, message, temps, etc.).

💡 Tapez indice lors d'une énigme pour obtenir un indice (réduit les points).
💾 Système de sauvegarde

À chaque partie, votre progression est enregistrée dans sauvegarde.json. Lors du lancement, vous pouvez choisir entre :

    Nouvelle partie

    Reprendre une sauvegarde existante (choix du nom enregistré)
