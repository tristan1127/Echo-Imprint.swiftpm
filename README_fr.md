<div align="center">

# Echo Imprint

**Chaque son laisse une trace.**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/Plateforme-iOS%20%7C%20iPadOS%2016%2B-blue?logo=apple)](https://developer.apple.com)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202026-black?logo=apple)](https://developer.apple.com/swift-student-challenge/)

[English](../README.md) · [简体中文](README_zh-Hans.md) · [繁體中文](README_zh-Hant.md) · **Français**

</div>

---

## Présentation

Echo Imprint transforme votre environnement acoustique en un organisme visuel vivant — un *Imprint* — qui se déforme et pulse en temps réel avec les sons qui vous entourent. Chaque enregistrement se cristallise en un spécimen nommé que vous pouvez conserver, réécouter et comparer. À la fois instrument, objet d'art et outil d'accessibilité.

Créé pour l'**Apple Swift Student Challenge 2026**. Premier projet Swift, développé en environ six jours.

---

## Captures d'écran

| Introduction | Enregistrement | Bibliothèque |
|:---:|:---:|:---:|
| <img src="../screenshot_onboarding.png" width="260"/> | <img src="../screenshot_main.png" width="260"/> | <img src="../screenshot_library.png" width="260"/> |
| *Flux d'introduction* | *L'Imprint répondant au son* | *Bibliothèque de spécimens* |

---

## Fonctionnalités

**🎙 Visualisation audio en temps réel**  
L'entrée microphone est analysée en direct via FFT. L'amplitude pilote la taille globale et l'intensité des mouvements ; le contenu fréquentiel contrôle la déformation de la forme et la teinte. Le résultat est véritablement vivant, pas mécanique.

**🎛 Sculpture EQ par geste de glissement**  
Faites glisser votre doigt directement sur l'Imprint pour remodeler sa sensibilité fréquentielle en temps réel. Le corps de l'organisme *est* l'égaliseur — glisser vers le bas accentue les graves et élargit la forme ; vers le haut, les aigus s'affûtent et les bords se raffinent.

**🗂 Bibliothèque de spécimens**  
Chaque enregistrement est conservé sous la forme d'un spécimen nommé, avec un instantané visuel et un résumé acoustique — comme des spécimens pressés dans un herbier, chacun unique. Relisez, renommez ou supprimez à tout moment.

**♿ Accessibilité VoiceOver**  
Compatibilité VoiceOver complète. Chaque élément interactif possède une étiquette d'accessibilité significative. L'état de l'Imprint est narré en langage descriptif — énergie, forme, intensité — pour que l'expérience reste accessible sans recourir à la vue. Conçu avec une motivation personnelle : un membre de la famille malentendant.

**🌿 Flux d'introduction guidé**  
Une première expérience minimale et atmosphérique qui présente le concept de l'Imprint sans submerger l'utilisateur.

---

## Guide d'utilisation

### Configuration requise

- iPhone ou iPad sous **iOS / iPadOS 16** ou version ultérieure
- Permission d'accès au microphone (demandée au premier lancement)
- Ouvrir `Echo-Imprint.swiftpm` dans **Xcode 15+** ou **Swift Playgrounds 4+**

---

### Étape 1 — Lancement et autorisation du microphone

Au premier lancement, le système demande l'accès au microphone. Appuyez sur **Autoriser** — c'est l'autorisation essentielle dont l'application a besoin. Sans elle, l'Imprint ne peut pas répondre au son.

> 💡 Accès refusé par erreur ? Allez dans **Réglages → Confidentialité et sécurité → Microphone** et réactivez Echo Imprint.

---

### Étape 2 — Parcourir le flux d'introduction

Une courte introduction présente le concept de l'Imprint et explique les interactions principales. Parcourez chaque écran à votre rythme, puis appuyez sur **Begin** pour entrer dans l'expérience principale.

> 💡 L'introduction n'apparaît qu'une fois après l'installation. Pour la rejouer, réinitialisez son état depuis les réglages de l'application.

---

### Étape 3 — Démarrer l'enregistrement

Appuyez sur le **bouton microphone** en bas au centre de l'écran pour commencer. L'Imprint commence immédiatement à répondre à votre environnement acoustique :

| Entrée | Effet sur l'Imprint |
|---|---|
| Sons plus forts | Taille plus grande, mouvements plus intenses |
| Basses fréquences | Expansion vers l'extérieur, forme plus large |
| Hautes fréquences | Vibrations fines sur les bords |
| Sons complexes | Transformations morphologiques plus riches |

Essayez de parler, de jouer de la musique, ou laissez simplement les sons ambiants s'écouler — chaque paysage sonore produit une forme vivante distincte.

---

### Étape 4 — Sculpter avec le geste EQ

Pendant l'enregistrement, faites glisser votre doigt directement sur l'Imprint pour remodeler sa sensibilité fréquentielle :

| Geste | Effet |
|---|---|
| Glisser vers le bas | Accentue les graves — la forme s'élargit et s'alourdit |
| Glisser vers le haut | Accentue les aigus — les bords deviennent plus fins et plus réactifs |
| Glisser horizontalement | Décale l'équilibre fréquentiel global |
| Multi-touch | Appliquer différents biais sur plusieurs zones simultanément |

> 💡 L'info-bulle « Drag to sculpt the Imprint » apparaît brièvement au début de l'enregistrement en guise de rappel.

---

### Étape 5 — Arrêter et sauvegarder un spécimen

Appuyez sur le bouton rouge **Stop** en bas au centre lorsque vous avez terminé. L'application vous invite à nommer le spécimen avant de le sauvegarder dans la bibliothèque.

---

### Étape 6 — Parcourir la bibliothèque

Appuyez sur l'**icône grille** (⊞) en haut à droite — elle affiche votre nombre de spécimens — pour ouvrir la bibliothèque.

Chaque carte affiche : la miniature de la forme finale de l'Imprint, son nom, et l'heure de sauvegarde. Appuyez sur **▶** pour relire ; sur **⊘** pour supprimer.

---

### Accessibilité : VoiceOver

Avec VoiceOver activé :

- Chaque élément interactif possède une étiquette d'accessibilité descriptive que VoiceOver lira à voix haute
- L'état de l'Imprint est communiqué en langage — niveau d'énergie, qualité de la forme, intensité — sans recourir aux visuels
- Tout le texte d'introduction a été rédigé en priorité pour une lecture audio

> 💡 Activez VoiceOver via **Réglages → Accessibilité → VoiceOver**, ou triple-cliquez sur le bouton latéral pour le basculer.

---

## Contact

**Sylvian**  
📧 [tristan112767@gmail.com](mailto:tristan112767@gmail.com)  
🐙 [@tristan1127](https://github.com/tristan1127)

---

<div align="center">

*Le son est éphémère. Echo Imprint le fait durer.*

</div>
