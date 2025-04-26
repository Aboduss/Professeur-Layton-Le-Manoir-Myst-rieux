import Foundation

// Fonction pour afficher du texte lentement, caractère par caractère
func afficherTexteLentement(_ texte: String, interval: UInt32 = 50000) {
    for caractere in texte {
        print(caractere, terminator: "") // Affiche chaque caractère sans saut de ligne
        fflush(stdout) // Force l'affichage immédiat du caractère
        usleep(interval) // Pause entre chaque caractère
    }
    print() // Saut de ligne à la fin du texte
}

// Structure représentant un objet avec un nom et une utilisation optionnelle
struct Objet: Codable {
    let nom: String
    let utilisableDans: String?
}

// Structure représentant une énigme avec une question et une réponse
struct Enigme: Codable {
    let question: String
    let reponse: String
}

// Structure représentant un personnage avec un nom et un dialogue
struct Personnage: Codable {
    let nom: String
    let dialogue: String
}

// Structure représentant une salle dans le jeu
struct Salle {
    let nom: String
    let description: String
    var objets: [Objet] // Objets présents dans la salle
    var personnages: [Personnage] // Personnages présents dans la salle
    var enigme: Enigme? // Énigme optionnelle posée dans la salle
    var sorties: [String: String] // Sorties possibles vers d'autres salles
    let position: (x: Int, y: Int) // Position de la salle dans le manoir
    var verrouillee: Bool = false // Indique si la salle est verrouillée
    var enigmeDéjàPosée: Bool = false // Indique si une énigme a déjà été posée dans cette salle
}

// Structure représentant le joueur avec ses attributs
struct Joueur: Codable {
    var nom: String
    var salleActuelle: String
    var inventaire: [String] // Objets dans l'inventaire du joueur
    var score: Int
    var introVue: Bool // Indique si l'introduction a été vue
    var objetsUtilisés: [String] // Objets déjà utilisés par le joueur
}

// Classe principale du jeu
class Jeu {
    var salles: [String: Salle] = [:] // Dictionnaire des salles du manoir
    var joueur: Joueur? // Joueur actuel
    let cheminSauvegarde = "sauvegarde.json" // Chemin du fichier de sauvegarde
    var finie: Bool = false // Indique si le jeu est terminé

    // Initialiseur du jeu, initialise les salles
    init() {
        initialiserSalles()
    }

    // Fonction pour initialiser les salles du manoir
    func initialiserSalles() {
        let objets = chargerObjets() // Charge les objets depuis un fichier JSON
        let personnages = chargerPersonnages() // Charge les personnages depuis un fichier JSON
        let enigmes = chargerEnigmes().shuffled() // Charge et mélange les énigmes depuis un fichier JSON

        // Dictionnaire associant chaque salle à un personnage spécifique
        let persoParSalle: [String: String] = [
            "Atelier": "Ouvrier",
            "Salon": "Vieille dame",
            "Bibliothèque": "Libraire",
            "Débarras": "Fantôme",
            "Hall": "Majordome",
            "Cuisine": "Cuisinier",
            "Entrée": "Portier",
            "Cellier": "Chef de cuisine",
            "Jardin": "Jardinier",
            "Observatoire": "Professeur Layton"
        ]

        // Fonction pour obtenir le personnage associé à une salle
        func persoPourSalle(_ salle: String) -> Personnage {
            return personnages.first(where: { $0.nom == persoParSalle[salle] }) ?? Personnage(nom: "Inconnu", dialogue: "...")
        }

        // Initialisation des salles avec leurs objets, personnages, descriptions, etc.
        salles["Atelier"] = Salle(
            nom: "Atelier",
            description: "Un atelier rempli d’outils anciens.",
            objets: objets.filter { $0.nom == "clé" },
            personnages: [persoPourSalle("Atelier")],
            enigme: nil,
            sorties: ["est": "Salon", "sud": "Débarras"],
            position: (0, 0)
        )

        salles["Salon"] = Salle(
            nom: "Salon",
            description: "Un salon cosy avec une cheminée.",
            objets: [],
            personnages: [persoPourSalle("Salon")],
            enigme: nil,
            sorties: ["ouest": "Atelier", "est": "Bibliothèque", "sud": "Hall"],
            position: (1, 0)
        )

        salles["Bibliothèque"] = Salle(
            nom: "Bibliothèque",
            description: "Des rayonnages de livres mystérieux.",
            objets: objets.filter { $0.nom == "livre ancien" },
            personnages: [persoPourSalle("Bibliothèque")],
            enigme: nil,
            sorties: ["ouest": "Salon", "sud": "Cuisine"],
            position: (2, 0)
        )

        salles["Débarras"] = Salle(
            nom: "Débarras",
            description: "Une pièce poussiéreuse remplie de vieux meubles.",
            objets: [],
            personnages: [persoPourSalle("Débarras")],
            enigme: nil,
            sorties: ["nord": "Atelier"],
            position: (0, 1)
        )

        salles["Hall"] = Salle(
            nom: "Hall",
            description: "Un grand hall avec des portraits anciens.",
            objets: [],
            personnages: [persoPourSalle("Hall")],
            enigme: nil,
            sorties: ["nord": "Salon", "sud": "Entrée"],
            position: (1, 1)
        )

        salles["Cuisine"] = Salle(
            nom: "Cuisine",
            description: "Une cuisine ancienne avec des ustensiles rouillés.",
            objets: objets.filter { $0.nom == "torchon" },
            personnages: [persoPourSalle("Cuisine")],
            enigme: nil,
            sorties: ["nord": "Bibliothèque","sud":"Cellier"],
            position: (2, 1)
        )

        salles["Entrée"] = Salle(
            nom: "Entrée",
            description: "Vous êtes dans le hall d'entrée central.",
            objets: [],
            personnages: [persoPourSalle("Entrée")],
            enigme: nil,
            sorties: ["nord": "Hall", "sud": "Jardin"],
            position: (1, 2)
        )

        salles["Cellier"] = Salle(
            nom: "Cellier",
            description: "Un cellier sombre et humide.",
            objets: objets.filter { $0.nom == "tournevis" },
            personnages: [persoPourSalle("Cellier")],
            enigme: nil,
            sorties: ["nord": "Cuisine"],
            position: (2, 2)
        )

        salles["Jardin"] = Salle(
            nom: "Jardin",
            description: "Un jardin mystérieux, la porte est verrouillée.",
            objets: [],
            personnages: [persoPourSalle("Jardin")],
            enigme: nil,
            sorties: ["nord": "Entrée", "est": "Observatoire"],
            position: (1, 3),
            verrouillee: true
        )

        salles["Observatoire"] = Salle(
            nom: "Observatoire",
            description: "Un dôme avec une lunette astronomique.",
            objets: [],
            personnages: [Personnage(nom: "Propriétaire", dialogue: "Bienvenue. J’attendais votre venue pour lever le voile sur ce mystère...")],
            enigme: nil, // l'énigme sera posée dynamiquement comme les autres
            sorties: ["ouest": "Jardin"],
            position: (2, 3)
        )
    }

    // Fonction pour sauvegarder la progression du joueur
    func sauvegarderProgression() {
        guard let joueur = joueur else { return }

        var sauvegardesExistantes: [String: Joueur] = [:]

        // Charge les sauvegardes existantes si disponibles
        if let data = try? Data(contentsOf: URL(fileURLWithPath: cheminSauvegarde)),
           let existantes = try? JSONDecoder().decode([String: Joueur].self, from: data) {
            sauvegardesExistantes = existantes
        }

        // Ajoute ou met à jour la sauvegarde du joueur actuel
        sauvegardesExistantes[joueur.nom] = joueur

        // Encode et sauvegarde les données mises à jour
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(sauvegardesExistantes) {
            try? data.write(to: URL(fileURLWithPath: cheminSauvegarde))
        }
    }

    // Fonction pour charger les progressions sauvegardées
    func chargerProgression() -> [String: Joueur] {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: cheminSauvegarde)),
           let sauvegardes = try? JSONDecoder().decode([String: Joueur].self, from: data) {
            return sauvegardes
        }
        return [:]
    }

    // Fonction pour démarrer le jeu
    func demarrer() {
        let sauvegardes = chargerProgression()

        print("🎮 Bienvenue dans Professeur Layton : Le Manoir Mystérieux")
        print("1. Nouvelle partie")
        print("2. Reprendre une partie existante")

        print("Choix (1 ou 2) :")
        if let choix = readLine(), choix == "2", !sauvegardes.isEmpty {
            print("\n📂 Parties existantes :")
            let noms = sauvegardes.keys.sorted()

            for (i, nom) in noms.enumerated() {
                print("\(i + 1). \(nom)")
            }

            print("Entrez le numéro du joueur à charger :")
            if let indexStr = readLine(), let index = Int(indexStr),
               index > 0, index <= noms.count {
                let nomChoisi = noms[index - 1]
                self.joueur = sauvegardes[nomChoisi]
                print("🔁 Partie chargée pour \(nomChoisi).")
            } else {
                print("❌ Choix invalide. Lancement d'une nouvelle partie.")
            }
        }

        // Nouvelle partie (ou erreur dans le chargement)
        if joueur == nil {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            afficherTexteLentement("               🧠 Professeur Layton : Le Manoir Mystérieux", interval: 40000)
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            sleep(1)
            print("""
                   *         .              *            _.---._       .
                                 ___   .            ___.'       '.   *
                  .              _____[LLL]______________[LLL]_____     \\
                                 /     [LLL]              [LLL]     \\     |
                                /____________________________________\\    |    .
                                 )==================================(    /
                       *         '|I .-. I .-. I .--. I .-. I .-. I|'  .'
                                  |I |+| I |+| I |. | I |+| I |+| I|-'`       *
                                  |I_|+|_I_|+|_I_|__|_I_|+|_I_|+|_I|      .
                        .       _     |I .-. I .-. I .--. I .-. I .-. I|          *
                       |u|  __|I |+| I |+| I |<>| I |+| I |+| I|    _         .
                   __   |u|_|uu|I |+| I |+| I |~ | I |+| I |+| I| _ |U|     _
               .  |uu|__|u|u|u,|I_|+|_I_|+|_I_|__|_I_|+|_I_|+|_I||n|| |____|u|
                  |uu|uu|_,.-' /I_____I_____I______I_____I_____I\\`'-. |uu u|u|__
                  |uu.-'`      #############(______)#############    `'-. u|u|uu|
                 _.'`              ~"^"~   (________)   ~"^"^~           `'-.|uu|
              ,''          .'    _                             _ `'-.        `'-.
          ~"^"~    _,'~"^"~    _( )_                         _( )_   `'-.        ~"^"~
              _  .'            |___|                         |___|      ~"^"~     _
            _( )_              |_|_|          () ()          |_|_|              _( )_
            |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
            |_|_|\\/\\/\\/\\/\\/\\/|_|_|\\/\\/\\/\\/\\/\\|| ||\\/\\/\\/\\/\\/\\|_|_|\\/\\/\\/\\/\\/\\/|_|_|
            |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
            |_|_|\\/\\/\\/\\/\\/\\/|_|_|\\/\\/\\/\\/\\/\\[===]\\/\\/\\/\\/\\/\\|_|_|\\/\\/\\/\\/\\/\\/|_|_|
            |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
            |_|_|\\/\\/\\/\\/\\/\\/|_|_|\\/\\/\\/\\/\\/\\|| ||/\\/\\/\\/\\/\\|_|_|\\/\\/\\/\\/\\/\\/|_|_|
            |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
        ~""~|_|_|\\/\\/\\/\\/\\/\\/|_|_|\\/\\/\\/\\/\\/\\|| ||\\/\\/\\/\\/\\/\\|_|_|\\/\\/\\/\\/\\/\\/|_lc|~""~
           [_____]            [_____]                       [_____]            [_____]
        """)

            print("\nAppuyez sur Entrée pour commencer...")
            _ = readLine()

            afficherTexteLentement("Depuis des années, un vieux manoir abandonné fait parler de lui dans la région.")
            afficherTexteLentement("On raconte que ses couloirs renferment des énigmes impossibles, et qu’aucun visiteur n’est jamais allé jusqu’au bout...")
            afficherTexteLentement("Curieux et passionné d'aventures, vous décidez un jour d’en franchir les grilles.")
            afficherTexteLentement("Alors que vous approchez de la grande porte, une silhouette trébuche soudainement hors d’un buisson. C’est un homme... élégant, chapeau haut-de-forme vissé sur la tête.")

            afficherTexteLentement("« Oh ! Par toutes les énigmes ! », s’écrie-t-il en se redressant. « Quelle entrée, n’est-ce pas ? Je suis le Professeur Layton. Et vous êtes ? »")
            print("\nEntrez votre nom :")
            if let nom = readLine(), !nom.isEmpty {
                joueur = Joueur(
                    nom: nom,
                    salleActuelle: "Entrée",
                    inventaire: [],
                    score: 0,
                    introVue: true,
                    objetsUtilisés: []
                )
                afficherTexteLentement("Professeur Layton : Enchanté, \(nom).")
                afficherTexteLentement("Vous arrivez au bon moment. J’allais justement explorer ce manoir... Seul, c’est risqué. Ensemble, nous serons plus efficaces.")
                afficherTexteLentement("Entrez avec moi. L'aventure commence...")
            } else {
                print("❌ Nom invalide. Fin du jeu.")
                return
            }
        }

        boucleDeJeu()
    }

    // Fonction principale de la boucle de jeu
    func boucleDeJeu() {
        while true {
            guard let joueur = self.joueur else { return }
            guard var salle = salles[joueur.salleActuelle] else { return }

            // Fin du jeu si dans l'observatoire
            if joueur.salleActuelle == "Observatoire" {
                finie = true
                afficherTexteLentement("Alors que vous reposez votre esprit après cette dernière énigme, une vieille porte s’ouvre lentement dans un grincement sinistre...")
                afficherTexteLentement("Un vieil homme fait son apparition, s'appuyant sur une canne finement sculptée, ses yeux pétillant d'une étrange lueur.")
                afficherTexteLentement("« Félicitations, aventurier », dit-il d'une voix tremblante mais assurée. « Peu nombreux sont ceux qui parviennent jusqu'ici. »")
                afficherTexteLentement("Il esquisse un sourire avant de tendre une petite clef dorée, ornée d’un motif en forme d’énigme.")
                afficherTexteLentement("« Cette clef ouvre une pièce que nul n'a franchie depuis des décennies... Mais ceci, jeune esprit brillant, est une autre histoire. »")
                afficherTexteLentement("")
                afficherTexteLentement("Le Professeur Layton, qui vous a accompagné tout au long de cette aventure, ajuste son chapeau et vous adresse un regard approbateur.")
                afficherTexteLentement("👓 Professeur Layton : « \(joueur.nom)... Ce fut un véritable privilège d'explorer ces mystères à vos côtés. Votre sagacité est remarquable. »")
                afficherTexteLentement("« Mais souvenez-vous : la véritable aventure commence lorsque l'on continue de se poser des questions. »")
                afficherTexteLentement("")
                afficherTexteLentement("Vous quittez le manoir, votre esprit plus aiguisé que jamais, tandis que les portes se referment doucement derrière vous, gardiennes éternelles des secrets encore enfouis...")
                print("\n🏆 Score final : \(joueur.score)")
                sauvegarderProgression()
                exit(0)
            }

            print("\n📍 \(salle.nom) : \(salle.description)")

            // Gestion automatique des objets visibles
            if !salle.objets.isEmpty {
                var objetsARetirer: [Int] = []
                for (index, objet) in salle.objets.enumerated() {
                    print("🧰 Vous voyez un objet : '\(objet.nom)'. Souhaitez-vous le prendre ? (oui/non)")
                    if let reponse = readLine()?.lowercased(), reponse == "oui" {
                        self.joueur?.inventaire.append(objet.nom)
                        print("✅ Objet ajouté à votre inventaire : \(objet.nom)")
                        objetsARetirer.append(index)
                    } else {
                        print("❌ Vous laissez l'objet ici.")
                    }
                }
                // Retirer les objets pris de la salle
                for index in objetsARetirer.reversed() {
                    salle.objets.remove(at: index)
                }
                self.salles[joueur.salleActuelle] = salle
            }

            // Utilisation automatique d’objets utiles
            for objetNom in joueur.inventaire where !(joueur.objetsUtilisés.contains(objetNom)) {
                switch objetNom {
                case "clé" where salle.verrouillee: continue
                case "torchon" where joueur.salleActuelle == "Cuisine":
                    proposerUtilisationObjet(nom: "torchon")
                case "tournevis" where joueur.salleActuelle == "Atelier":
                    proposerUtilisationObjet(nom: "tournevis")
                case "livre ancien" where joueur.salleActuelle == "Bibliothèque":
                    proposerUtilisationObjet(nom: "livre ancien")
                default: continue
                }
            }

            if salle.verrouillee {
                print("🔒 Cette salle est verrouillée.")
            }

            if let personnage = salle.personnages.first {
                print("🗨️ \(personnage.nom) : « \(personnage.dialogue) »")

                if salle.enigme == nil && salle.nom != "Observatoire" {
                    salle.enigme = chargerEnigmes().filter { $0.reponse.lowercased() != "message" }.randomElement()
                    self.salles[joueur.salleActuelle] = salle
                }

                if let enigme = salle.enigme {
                    print("🔎 \(personnage.nom) vous pose une énigme :")
                    print("« \(enigme.question) »")
                    var points = 100
                    var essaisRestants = 3
                    var indicesDonnes = 0

                    while essaisRestants > 0 {
                        print("Votre réponse (ou tapez 'indice') :")
                        if let entree = readLine()?.lowercased() {
                            if entree == "indice" {
                                indicesDonnes += 1
                                let debut = String(enigme.reponse.prefix(1 + indicesDonnes))
                                print("💡 Indice : commence par '\(debut)'")
                                points = max(0, points - 25)
                            } else if entree == enigme.reponse {
                                print("✅ Bonne réponse ! +\(points) points.")
                                self.joueur?.score += points
                                self.salles[joueur.salleActuelle]?.enigme = nil
                                break
                            } else {
                                print("❌ Mauvaise réponse.")
                                essaisRestants -= 1
                                if essaisRestants == 0 {
                                    print("👓 Professeur Layton : « Hmm... La réponse était \(enigme.reponse). Fascinant, n’est-ce pas ? »")
                                }
                            }
                        }
                    }
                }
            }

            afficherCarte()
            afficherCommandes()
            print("🎯 Score actuel : \(self.joueur?.score ?? 0)")
            print("\n👉 Que voulez-vous faire ?")
            if let action = readLine()?.lowercased() {
                traiterCommande(action)
            }
        }
    }

    // Fonction pour traiter les commandes du joueur
    func traiterCommande(_ commande: String) {
        guard let joueur = joueur, let salle = salles[joueur.salleActuelle] else { return }

        let parties = commande.split(separator: " ")
        let action = parties.first ?? ""
        let argument = parties.dropFirst().joined(separator: " ")

        switch action {
        case "aller":
            if let prochaine = salle.sorties[argument] {
                if let cible = salles[prochaine], cible.verrouillee {
                    print("🔐 La salle '\(prochaine)' est verrouillée.")

                    if joueur.inventaire.contains("clé") {
                        print("Souhaitez-vous utiliser la clé ? (oui/non)")
                        if let reponse = readLine()?.lowercased(), reponse == "oui" {
                            salles[prochaine]?.verrouillee = false
                            print("🔓 Vous avez utilisé la clé pour déverrouiller \(prochaine).")
                            self.joueur?.salleActuelle = prochaine
                        } else {
                            print("🚪 Vous n'entrez pas dans la salle verrouillée.")
                        }
                    } else {
                        print("Vous n'avez pas la clé dans votre inventaire.")
                    }
                } else {
                    self.joueur?.salleActuelle = prochaine
                    print("🚪 Vous entrez dans la salle : \(prochaine).")
                }
            } else {
                print("❌ Vous ne pouvez pas aller dans cette direction.")
            }

        case "prendre":
            if let index = salle.objets.firstIndex(where: { $0.nom == argument }) {
                self.joueur?.inventaire.append(argument)
                self.salles[joueur.salleActuelle]?.objets.remove(at: index)
                print("✅ Vous avez pris : \(argument)")
            } else {
                print("❌ Aucun objet de ce nom ici.")
            }

        case "utiliser":
            if joueur.inventaire.contains(argument) {
                switch argument {
                case "torchon":
                    if joueur.salleActuelle == "Cuisine" {
                        print("🧼 Vous frottez une vieille plaque et découvrez un mot : 'OMBRE'... Intrigant.")
                        self.joueur?.score += 10
                    } else {
                        print("Vous n'avez rien à nettoyer ici.")
                    }

                case "tournevis":
                    if joueur.salleActuelle == "Atelier" {
                        print("🔧 Vous ouvrez une trappe secrète... Vous trouvez un objet caché : 'pierre brillante' !")
                        self.joueur?.inventaire.append("pierre brillante")
                        self.joueur?.score += 20
                    } else {
                        print("Il n'y a rien à dévisser ici.")
                    }

                case "livre ancien":
                    if joueur.salleActuelle == "Bibliothèque" {
                        print("📖 Le livre vous murmure : « Plus on m’en retire, plus je grandis... »")
                        self.joueur?.score += 5
                    } else {
                        print("Vous feuilletez le livre sans grand intérêt ici.")
                    }

                default:
                    print("ℹ️ Cet objet ne peut pas être utilisé ici.")
                }
            } else {
                print("❌ Vous n'avez pas cet objet.")
            }

        case "inventaire":
            print("🎒 Inventaire :", joueur.inventaire.isEmpty ? "vide" : joueur.inventaire.joined(separator: ", "))

        case "quitter":
            sauvegarderProgression()
            print("💾 Sauvegarde terminée. À bientôt, \(joueur.nom) !")
            exit(0)

        default:
            print("Commande inconnue.")
        }
    }

    // Fonction pour afficher les commandes disponibles
    func afficherCommandes() {
        print("\n📜 Commandes :")
        print("- aller <direction> (nord/sud/est/ouest)")
        print("- prendre <objet>")
        print("- utiliser <objet>")
        print("- inventaire")
        print("- quitter")
    }

    // Fonction pour afficher la carte du manoir
    func afficherCarte() {
        guard let salleActuelle = joueur?.salleActuelle else { return }

        print("\n🗺️ Carte du Manoir :\n")

        let largeur = 3  // colonnes : x = 0 à 2
        let hauteur = 4  // lignes   : y = 0 à 3

        for y in 0..<hauteur {
            var ligneNoms = ""
            var ligneCases = ""

            for x in 0..<largeur {
                if let salle = salles.values.first(where: { $0.position == (x, y) }) {
                    let nom = salle.nom.padding(toLength: 13, withPad: " ", startingAt: 0)
                    ligneNoms += nom
                    let symbole = salle.nom == salleActuelle ? "🧍" : (salle.verrouillee ? "🔒" : "📦")
                    ligneCases += "     [\(symbole)]    "
                } else {
                    ligneNoms += String(repeating: " ", count: 13)
                    ligneCases += "     [     ]    "
                }
            }

            print(ligneNoms)
            print(ligneCases)
            print()
        }
    }

    // Fonction pour vérifier si toutes les énigmes sont résolues
    func toutesLesEnigmesSontResolues() -> Bool {
        for salle in salles.values {
            if salle.enigme != nil {
                return false
            }
        }
        return true
    }

    // Fonction pour proposer l'utilisation d'un objet
    func proposerUtilisationObjet(nom: String) {
        guard let joueur = joueur, !joueur.objetsUtilisés.contains(nom) else { return }

        print("Souhaitez-vous utiliser l’objet '\(nom)' ? (oui/non)")
        if let reponse = readLine()?.lowercased(), reponse == "oui" {
            switch nom {
            case "torchon":
                print("🧼 Vous nettoyez une surface et découvrez un indice caché : 'OMBRE'.")
                self.joueur?.score += 10
                self.joueur?.objetsUtilisés.append("torchon")
            case "tournevis":
                print("🔧 Vous ouvrez une trappe secrète dans le mur. Vous trouvez une 'pierre brillante'.")
                self.joueur?.inventaire.append("pierre brillante")
                self.joueur?.score += 20
                self.joueur?.objetsUtilisés.append("tournevis")
            case "livre ancien":
                print("📖 Une page annotée vous donne un indice : 'Plus on m’en retire, plus je grandis...'")
                self.joueur?.score += 5
                self.joueur?.objetsUtilisés.append("livre ancien")
            default:
                print("Cet objet ne fait rien ici.")
            }
        } else {
            print("Vous décidez de ne rien faire avec '\(nom)'.")
        }
    }

    // Fonction pour charger les objets depuis un fichier JSON
    func chargerObjets() -> [Objet] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "objets.json")),
              let objets = try? JSONDecoder().decode([Objet].self, from: data) else {
            print("❌ Erreur lors du chargement des objets.")
            return []
        }
        return objets
    }

    // Fonction pour charger les énigmes depuis un fichier JSON
    func chargerEnigmes() -> [Enigme] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "enigmes.json")),
              let enigmes = try? JSONDecoder().decode([Enigme].self, from: data) else {
            print("❌ Erreur lors du chargement des énigmes.")
            return []
        }
        return enigmes
    }

    // Fonction pour charger les personnages depuis un fichier JSON
    func chargerPersonnages() -> [Personnage] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "personnages.json")),
              let personnages = try? JSONDecoder().decode([Personnage].self, from: data) else {
            print("❌ Erreur lors du chargement des personnages.")
            return []
        }
        return personnages
    }
}

// Lancer le jeu
let jeu = Jeu()
jeu.demarrer()
