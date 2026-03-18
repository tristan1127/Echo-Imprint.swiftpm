<div align="center">

# Echo Imprint

**每一聲音，都留下印記。**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/平台-iOS%20%7C%20iPadOS%2016%2B-blue?logo=apple)](https://developer.apple.com)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202026-black?logo=apple)](https://developer.apple.com/swift-student-challenge/)

[English](../README.md) · [简体中文](README_zh-Hans.md) · **繁體中文** · [Français](README_fr.md)

</div>

---

## 簡介

Echo Imprint 將你的聲音環境轉化為一個活生生的視覺生命體——**Imprint（印記）**——它隨著周圍的聲音即時變形與脈動。每次錄音都凝固成一個具名標本，供你保存、回放與對比。它是樂器、藝術品，也是一款無障礙工具。

為 **Apple Swift Student Challenge 2026** 而作。第一個 Swift 專案，歷時約六天完成。

---

## 截圖

| 引導介面 | 錄製中 | 標本庫 |
|:---:|:---:|:---:|
| <img src="../screenshot_onboarding.png" width="260"/> | <img src="../screenshot_main.png" width="260"/> | <img src="../screenshot_library.png" width="260"/> |
| *引導流程* | *Imprint 響應聲音* | *標本庫* |

---

## 功能

**🎙 即時音訊視覺化**  
透過 FFT 即時分析麥克風輸入。振幅驅動整體體積與運動強度，頻率內容控制形體變形與色相。效果是真正活生生的，而非機械動畫。

**🎛 拖曳手勢 EQ 塑形**  
直接在 Imprint 上拖曳手指，即時重塑其頻率靈敏度。生物體的身體本身就是等化器——向下拖曳強化低頻，使形體擴張；向上拖曳強化高頻，使邊緣更精細。

**🗂 標本庫**  
每次錄音都以具名標本的形式保存，附帶視覺快照與聲學摘要——如同植物標本館中的壓製標本，每一個都無法複製。隨時可以回放、重新命名或刪除。

**♿ VoiceOver 無障礙**  
全程完整支援 VoiceOver。每個互動元素都有語意化標籤；Imprint 的狀態以語言描述——能量、形態、強度——無需依賴視覺也能感知。設計靈感來自家人的聽力損失經歷。

**🌿 引導流程**  
簡潔大氣的首次啟動引導，介紹 Imprint 的概念，不令使用者感到不知所措。

---

## 使用指南

### 系統需求

- iPhone 或 iPad，運行 **iOS / iPadOS 16** 或更高版本
- 需要麥克風權限（首次啟動時彈出授權請求）
- 使用 **Xcode 15+** 或 **Swift Playgrounds 4+** 開啟 `Echo-Imprint.swiftpm`

---

### 第一步 — 啟動與授權麥克風

首次開啟 App，系統將請求麥克風權限。點選**允許**——這是 App 運作的核心權限。沒有麥克風輸入，Imprint 將無法響應聲音。

> 💡 不慎拒絕？前往**設定 → 隱私權與安全性 → 麥克風**重新開啟 Echo Imprint 的權限。

---

### 第二步 — 完成引導流程

簡短的引導介紹了 Imprint 的概念與基本互動方式。依照畫面提示輕觸推進，最後點選 **Begin** 進入主體驗。

> 💡 引導流程僅在首次安裝後出現。若想重新查看，可在 App 設定中重置引導狀態。

---

### 第三步 — 開始錄製

點選畫面底部中央的**麥克風按鈕**開始錄製。Imprint 將立即響應你的聲音環境：

| 輸入 | 對 Imprint 的影響 |
|---|---|
| 音量更大 | 體積更大，運動更劇烈 |
| 低頻內容 | 向外膨脹，形體更寬闊 |
| 高頻內容 | 邊緣細密顫動 |
| 複雜聲音 | 更豐富、多層次的形態變化 |

試著說話、播放音樂，或靜靜讓環境音流淌——每一種聲景都塑造出獨一無二的生命形態。

---

### 第四步 — 拖曳手勢 EQ 塑形

錄製過程中，直接用手指在 Imprint 上拖曳，即時重塑其頻率靈敏度：

| 手勢 | 效果 |
|---|---|
| 向下拖曳 | 增強低頻響應，形體更宏大厚重 |
| 向上拖曳 | 增強高頻響應，邊緣更精細活躍 |
| 橫向滑動 | 整體頻率平衡左右偏移 |
| 多點觸控 | 同時在不同區域施加不同頻率偏向 |

> 💡 錄製開始後，介面會短暫顯示提示「Drag to sculpt the Imprint」，這是手勢提醒。

---

### 第五步 — 停止錄製並儲存標本

完成後，點選底部中央的紅色**停止**按鈕。App 將提示你為標本命名，然後自動儲存入庫。

---

### 第六步 — 瀏覽標本庫

點選右上角的**宮格圖示**（⊞，顯示目前標本數量）開啟標本庫。

每張卡片顯示：Imprint 最終形態的縮圖、標本名稱與儲存時間。點選 **▶** 回放，點選 **⊘** 刪除。

---

### 無障礙：VoiceOver 支援

開啟 VoiceOver 後：

- 每個互動元素都有描述性無障礙標籤，VoiceOver 將朗讀這些標籤
- Imprint 的狀態以語言傳達——能量強度、形態描述、變化過程——無需依賴視覺
- 引導流程的所有文案以「音訊優先」方式設計

> 💡 開啟方式：**設定 → 輔助使用 → VoiceOver**，或三次點按側邊按鈕快速切換。

---

## 聯絡方式

**Sylvian**  
📧 [tristan112767@gmail.com](mailto:tristan112767@gmail.com)  
🐙 [@tristan1127](https://github.com/tristan1127)

---

<div align="center">

*聲音轉瞬即逝。Echo Imprint 讓它留下來。*

</div>
