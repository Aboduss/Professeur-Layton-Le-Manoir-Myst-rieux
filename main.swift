import Foundation

func afficherTexteLentement(_ texte: String, interval: UInt32 = 50000) {
    for caractere in texte {
        print(caractere, terminator: "")
        fflush(stdout)
        usleep(interval)
    }
    print()
}

struct Objet: Codable {
    let nom: String
    let utilisableDans: String?
}

struct Enigme: Codable {
    let question: String
    let reponse: String
}

struct Personnage: Codable {
    let nom: String
    let dialogue: String
}


struct Salle {
    let nom: String
    let description: String
    var objets: [Objet]
    var personnages: [Personnage]
    var enigme: Enigme?
    var sorties: [String: String]
    let position: (x: Int, y: Int)
    var verrouillee: Bool = false
    var enigmeDéjàPosée: Bool = false

}

struct Joueur: Codable {
    var nom: String
    var salleActuelle: String
    var inventaire: [String]
    var score: Int
    var introVue: Bool
    var objetsUtilisés: [String]
}


class Jeu {
    var salles: [String: Salle] = [:]
    var joueur: Joueur?
    let cheminSauvegarde = "sauvegarde.json"
    var finie: Bool = false

    init() {
        initialiserSalles()
        }

func initialiserSalles() {
    let objets = chargerObjets()
    let personnages = chargerPersonnages()
    let enigmes = chargerEnigmes().shuffled()

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

    func persoPourSalle(_ salle: String) -> Personnage {
        return personnages.first(where: { $0.nom == persoParSalle[salle] }) ?? Personnage(nom: "Inconnu", dialogue: "...")
    }

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

    // ... La suite arrive dans le prochain message ...


func sauvegarderProgression() {
    guard let joueur = joueur else { return }

    var sauvegardesExistantes: [String: Joueur] = [:]

    if let data = try? Data(contentsOf: URL(fileURLWithPath: cheminSauvegarde)),
       let existantes = try? JSONDecoder().decode([String: Joueur].self, from: data) {
        sauvegardesExistantes = existantes
    }

    sauvegardesExistantes[joueur.nom] = joueur

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    if let data = try? encoder.encode(sauvegardesExistantes) {
        try? data.write(to: URL(fileURLWithPath: cheminSauvegarde))
    }
}

func chargerProgression() -> [String: Joueur] {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: cheminSauvegarde)),
       let sauvegardes = try? JSONDecoder().decode([String: Joueur].self, from: data) {
        return sauvegardes
    }
    return [:]
}

func demarrer() {
    let sauvegardes = chargerProgression()

print("🎮 Bienvenue dans Professeur Layton : Le Manoir Mystérieux")
print("1. Nouvelle partie")
print("2. Reprendre une partie existante")

print("Choix (1 ou 2) :")
if let choix = readLine(), choix == "2", !sauvegardes.isEmpty {
    print("\n📂 Parties existantes :")
    let noms = sauvegardes.keys.sorted()  // ✅ CORRIGÉ ICI

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
               *         .              *            _.---._      
                             ___   .            ___.'       '.   *
        .              _____[LLL]______________[LLL]_____     \\
                      /     [LLL]              [LLL]     \\     |
                     /____________________________________\\    |    .
                      )==================================(    /
     .      *         '|I .-. I .-. I .--. I .-. I .-. I|'  .'
                  *    |I |+| I |+| I |. | I |+| I |+| I|-'`       *
                       |I_|+|_I_|+|_I_|__|_I_|+|_I_|+|_I|      .
              .       /_I_____I_____I______I_____I_____I_\\
                       )================================(   *
       *         _     |I .-. I .-. I .--. I .-. I .-. I|          *
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
    |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
    |_|_|\\/\\/\\/\\/\\/\\/|_|_|\\/\\/\\/\\/\\/\\|| ||\\/\\/\\/\\/\\/\\|_|_|\\/\\/\\/\\/\\/\\/|_|_|
    |___|/\\/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\|| ||/\\/\\/\\/\\/\\|___|/\\/\\/\\/\\/\\/\\|___|
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



func boucleDeJeu() {
    while true {
        guard let joueur = joueur, var salle = salles[joueur.salleActuelle] else { return }

        // Vérifier si le joueur est dans l'Observatoire
        if joueur.salleActuelle == "Observatoire" {
            finie = true
            afficherTexteLentement("Alors que vous reposez votre esprit après cette dernière énigme, une vieille porte s’ouvre lentement...")
            afficherTexteLentement("Un vieil homme entre, s'appuyant sur une canne sculptée.")
            afficherTexteLentement("« Je suis le propriétaire de ce manoir », dit-il d'une voix grave. « Et vous avez réussi là où beaucoup auraient échoué. »")
            afficherTexteLentement("« Ces énigmes furent posées ici par ma famille, génération après génération, pour tester la perspicacité des visiteurs. Peu sont allés aussi loin. »")
            afficherTexteLentement("Il s'approche, tendant une petite clef dorée.")
            afficherTexteLentement("« Cette clef ouvre une pièce secrète. Mais ceci... est une autre histoire. »")
            afficherTexteLentement("👓 Professeur Layton : « Bravo, \(joueur.nom). Cette aventure valait chaque minute. »")
            afficherTexteLentement("Vous quittez le manoir, l’esprit plus aiguisé que jamais...")
            print("\n🏆 Score final : \(joueur.score)")
            print("🎉 Merci d’avoir joué à *Professeur Layton : Le Manoir Mystérieux*.\n")
            sauvegarderProgression()
            exit(0)
        }

        print("\n📍 \(salle.nom) : \(salle.description)")

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

        if !salle.objets.isEmpty {
            print("🧰 Objets visibles :", salle.objets.map { $0.nom }.joined(separator: ", "))
        }

        if let personnage = salle.personnages.first {
            print("🗨️ \(personnage.nom) : « \(personnage.dialogue) »")

            // Assigner une énigme si elle n’est pas déjà posée
            if salle.enigme == nil && salle.nom != "Observatoire" {
                salle.enigme = chargerEnigmes().filter { $0.reponse.lowercased() != "message" }.randomElement()
                salles[joueur.salleActuelle] = salle
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
print("👓 Professeur Layton : « Hmm... La réponse était \(enigme.reponse). Fascinant, n’est-ce pas ? Les mystères ont toujours leurs secrets. »")
                            }
                        }
                    }
                }
            }
        }

        afficherCarte()
        afficherCommandes()
        print("🎯 Score actuel : \(joueur.score)")
        print("\n👉 Que voulez-vous faire ?")
        if let action = readLine()?.lowercased() {
            traiterCommande(action)
        }
    }
}


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
            
if let personnage = salle.personnages.first {
    print("🗨️ \(personnage.nom) : « \(personnage.dialogue) »")

    if let enigme = salle.enigme {
        print("🔎 \(personnage.nom) vous pose une énigme :")
        print("« \(enigme.question) »")
        var points = 100
        var repondu = false

        while !repondu {
            print("Votre réponse (ou tapez 'indice') :")
            if let entree = readLine()?.lowercased() {
                if entree == "indice" {
                    let debut = String(enigme.reponse.prefix(2))
                    print("💡 Indice : commence par '\(debut)'")
                    points = max(0, points - 25)
                } else if entree == enigme.reponse {
                    print("✅ Bonne réponse ! +\(points) points.")
                    self.joueur?.score += points
                    self.salles[joueur.salleActuelle]?.enigme = nil
                    repondu = true
                } else {
                    print("❌ Mauvaise réponse.")
                }
            }
        }
    }
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

    func afficherCommandes() {
        print("\n📜 Commandes :")
        print("- aller <direction> (nord/sud/est/ouest)")
        print("- prendre <objet>")
        print("- utiliser <objet>")
        print("- inventaire")
        print("- quitter")
    }

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

    func toutesLesEnigmesSontResolues() -> Bool {
        for salle in salles.values {
            if salle.enigme != nil {
                return false
            }
        }
        return true
    }
    
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


func chargerObjets() -> [Objet] {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: "objets.json")),
          let objets = try? JSONDecoder().decode([Objet].self, from: data) else {
        print("❌ Erreur lors du chargement des objets.")
        return []
    }
    return objets
}

func chargerEnigmes() -> [Enigme] {
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: "enigmes.json")),
          let enigmes = try? JSONDecoder().decode([Enigme].self, from: data) else {
        print("❌ Erreur lors du chargement des énigmes.")
        return []
    }
    return enigmes
}

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
