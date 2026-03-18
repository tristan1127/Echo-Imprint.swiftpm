<div align="center">


# Echo Imprint

**Every sound leaves a mark.**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20iPadOS-blue?logo=apple)](https://developer.apple.com)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202026-black?logo=apple)](https://developer.apple.com/swift-student-challenge/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

*Read this in:*  
[简体中文](docs/README_zh-Hans.md) · [繁體中文](docs/README_zh-Hant.md) · [Français](docs/README_fr.md)

</div>

---

## Overview

Echo Imprint transforms your acoustic environment into a living, breathing visual organism — an *Imprint* — that morphs and pulses in real time with the sounds around you. Each recording crystallises into a named specimen you can keep, revisit, and compare. Equal parts instrument, art object, and accessibility tool.

Built for **Apple Swift Student Challenge 2026**. First Swift project, developed in approximately six days.

---

## Screenshots

| Onboarding | Recording | Library |
|:---:|:---:|:---:|
| <img src="screenshot_onboarding.png" width="260"/> | <img src="screenshot_main.png" width="260"/> | <img src="screenshot_library.png" width="260"/> |
| *Introduction flow* | *Imprint responding to sound* | *Specimen Library* |

---

## Features

**🎙 Real-Time Audio Visualisation**  
Microphone input is analysed live via FFT. Amplitude drives overall scale and movement; frequency content controls shape deformation and colour hue. The result feels genuinely alive, not mechanical.

**🎛 Drag-Gesture EQ Sculpting**  
Drag directly on the Imprint to reshape its frequency sensitivity in real time. The organism's body *is* the equaliser — drag downward to emphasise bass and expand its form; drag upward to sharpen treble and refine its edges.

**🗂 Specimen Library**  
Each recording is preserved as a named specimen with a visual snapshot and acoustic summary — like pinned specimens in a herbarium, each one unrepeatable. Replay, rename, or delete from the Library at any time.

**♿ VoiceOver Accessibility**  
Full VoiceOver support throughout. Every interactive element carries a meaningful accessibility label. The organism's state — energy, shape quality, intensity — is narrated in descriptive language so the experience remains meaningful without relying on sight. Designed with personal motivation: a family member with hearing loss.

**🌿 Guided Onboarding**  
A minimal, atmospheric first-launch flow that introduces the Imprint concept without overwhelming the user.

---

## Usage Guide

### Requirements

- **macOS** with Xcode 16+ — open `Echo-Imprint.swiftpm` directly in Xcode
- **iPadOS** with Swift Playgrounds 4+ — open the `.swiftpm` package on iPad
- Microphone permission required (prompted on first launch)

---

### Step 1 — Launch & Grant Microphone Access

On first launch, the system will request microphone access. Tap **Allow** — this is the core permission the app needs. Without it, the Imprint cannot respond to sound.

> 💡 Accidentally denied? On Mac: **System Settings → Privacy & Security → Microphone**. On iPad: **Settings → Privacy & Security → Microphone**.

---

### Step 2 — Complete the Onboarding Flow

A short introduction presents the Imprint concept and explains the core interactions. Tap through at your own pace, then press **Begin** to enter the main experience.

> 💡 Onboarding appears only on first install. To replay it, reset its state from within the app's settings.

---

### Step 3 — Start Recording

Tap the **microphone button** at the bottom centre of the screen to begin. The Imprint immediately starts responding to your acoustic environment:

| Input | Effect on Imprint |
|---|---|
| Louder sounds | Larger, more intense movements |
| Low frequencies | Outward expansion, broader form |
| High frequencies | Fine-grained edge trembling |
| Complex sounds | Richer, layered morphological shifts |

Try speaking, playing music, or simply sitting in ambient sound — every soundscape produces a distinct living form.

<img src="screenshot_main.png" width="400" alt="Main screen with Imprint active" />

*Imprint responding to sound. The red button at the bottom indicates active recording.*

---

### Step 4 — Sculpt with Drag-Gesture EQ

While recording, drag your finger directly on the Imprint to reshape its frequency sensitivity:

| Gesture | Effect |
|---|---|
| Drag downward | Boosts low-frequency response — form grows broader and heavier |
| Drag upward | Boosts high-frequency response — edges become finer and more reactive |
| Swipe horizontally | Shifts overall frequency balance |
| Multi-touch | Apply different biases across regions simultaneously |

> 💡 The hint tooltip "Drag to sculpt the Imprint" appears briefly after recording starts as a reminder.

---

### Step 5 — Stop & Save a Specimen

Tap the red **Stop** button at the bottom centre when you are done. The app will prompt you to name your specimen before saving it to the Library.

---

### Step 6 — Browse the Library

Tap the **grid icon** (⊞) in the top-right corner — it displays your current specimen count — to open the Library.

<img src="screenshot_library.png" width="400" alt="Specimen Library" />

*The Library — each specimen card shows a thumbnail, name, and timestamp.*

Each card shows a thumbnail of the Imprint's final form, its name, and the time it was saved. Tap **▶** to replay; tap **⊘** to delete.

---

### Accessibility: VoiceOver Support

With VoiceOver enabled:

- Every interactive element has a descriptive accessibility label read aloud by VoiceOver
- The Imprint's state is communicated in language — energy level, shape quality, intensity — not just visuals
- All onboarding copy was written audio-first

> 💡 On Mac: **System Settings → Accessibility → VoiceOver**. On iPad: **Settings → Accessibility → VoiceOver**, or triple-click the side button.

---

## Technical Details

| | |
|---|---|
| **Platform** | macOS (Xcode) · iPadOS (Swift Playgrounds) |
| **Language** | Swift 5.9 |
| **Frameworks** | SwiftUI, AVFoundation, Accelerate |
| **Audio Analysis** | Real-time FFT via Accelerate framework |
| **Rendering** | SwiftUI Canvas with custom geometry passes |
| **Persistence** | Swift `Codable` + file-based storage |
| **Accessibility** | VoiceOver, Dynamic Type |
| **Dev Environment** | Xcode 16, macOS Sequoia |
| **Development Time** | ~6 days |

---

## Architecture

```
Echo-Imprint.swiftpm/
├── Audio/
│   ├── AudioEngine.swift          # Microphone capture & AVAudioSession management
│   └── FFTProcessor.swift         # Real-time frequency analysis via Accelerate
├── Organism/
│   ├── OrganismView.swift         # SwiftUI Canvas rendering loop
│   ├── OrganismGeometry.swift     # Shape deformation & petal geometry
│   └── EQSculptGesture.swift      # Drag-to-EQ touch interaction
├── Library/
│   ├── SpecimenStore.swift        # Codable persistence layer
│   └── SpecimenCardView.swift     # Library list UI
├── Onboarding/
│   └── OnboardingFlow.swift       # First-launch guided experience
└── App/
    └── EchoImprintApp.swift       # Entry point & environment setup
```

---

## Accessibility Statement

Echo Imprint was built on the belief that a sound-responsive experience should not exclude people with hearing differences. VoiceOver narrates the Imprint's state in descriptive language — shape, energy, intensity — so the experience can be imagined and felt even without hearing the source audio. This was not an afterthought; it was a founding constraint, motivated by a family member with hearing loss.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

**Sylvian**  
📧 [tristanisolde08@gmail.com](mailto:tristanisolde08@gmail.com)  
🐙 [@tristan1127](https://github.com/tristan1127)

---

<div align="center">

*Sound is transient. Echo Imprint makes it stay.*

</div>
