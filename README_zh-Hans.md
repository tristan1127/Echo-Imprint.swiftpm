<div align="center">

# Echo Imprint

**每一声音，都留下印记。**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/平台-iOS%20%7C%20iPadOS%2016%2B-blue?logo=apple)](https://developer.apple.com)
[![Swift Student Challenge](https://img.shields.io/badge/Apple-Swift%20Student%20Challenge%202026-black?logo=apple)](https://developer.apple.com/swift-student-challenge/)

[English](../README.md) · **简体中文** · [繁體中文](README_zh-Hant.md) · [Français](README_fr.md)

</div>

---

## 简介

Echo Imprint 将你的声音环境转化为一个活生生的视觉生命体——**Imprint（印记）**——它随着周围的声音实时变形与脉动。每次录音都凝固成一个具名标本，供你保存、回放与对比。它是乐器、艺术品，也是一款无障碍工具。

为 **Apple Swift Student Challenge 2026** 而作。第一个 Swift 项目，历时约六天完成。

---

## 截图

| 引导界面 | 录制中 | 标本库 |
|:---:|:---:|:---:|
| <img src="../screenshot_onboarding.png" width="260"/> | <img src="../screenshot_main.png" width="260"/> | <img src="../screenshot_library.png" width="260"/> |
| *引导流程* | *Imprint 响应声音* | *标本库* |

---

## 功能

**🎙 实时音频可视化**  
通过 FFT 实时分析麦克风输入。振幅驱动整体体积与运动强度，频率内容控制形体变形与色相。效果是真正活生生的，而非机械动画。

**🎛 拖动手势 EQ 塑形**  
直接在 Imprint 上拖动手指，实时重塑其频率灵敏度。生物体的身体本身就是均衡器——向下拖动强化低频，使形体扩张；向上拖动强化高频，使边缘更精细。

**🗂 标本库**  
每次录音都以具名标本的形式保存，附带视觉快照与声学摘要——如同植物标本馆中的压制标本，每一个都无法复制。随时可以回放、重命名或删除。

**♿ VoiceOver 无障碍**  
全程完整支持 VoiceOver。每个交互元素都有语义化标签；Imprint 的状态以语言描述——能量、形态、强度——无需依赖视觉也能感知。设计灵感来自家人的听力损失经历。

**🌿 引导流程**  
简洁大气的首次启动引导，介绍 Imprint 的概念，不令用户感到不知所措。

---

## 使用指南

### 系统要求

- iPhone 或 iPad，运行 **iOS / iPadOS 16** 或更高版本
- 需要麦克风权限（首次启动时弹出授权请求）
- 使用 **Xcode 15+** 或 **Swift Playgrounds 4+** 打开 `Echo-Imprint.swiftpm`

---

### 第一步 — 启动与授权麦克风

首次打开 App，系统将请求麦克风权限。点击**允许**——这是 App 运行的核心权限。没有麦克风输入，Imprint 将无法响应声音。

> 💡 不慎拒绝？前往**设置 → 隐私与安全性 → 麦克风**重新开启 Echo Imprint 的权限。

---

### 第二步 — 完成引导流程

简短的引导介绍了 Imprint 的概念与基本交互方式。按照屏幕提示轻触推进，最后点击 **Begin** 进入主体验。

> 💡 引导流程仅在首次安装后出现。若想重新查看，可在 App 设置中重置引导状态。

---

### 第三步 — 开始录制

点击屏幕底部中央的**麦克风按钮**开始录制。Imprint 将立即响应你的声音环境：

| 输入 | 对 Imprint 的影响 |
|---|---|
| 音量更大 | 体积更大，运动更剧烈 |
| 低频内容 | 向外膨胀，形体更宽阔 |
| 高频内容 | 边缘细密颤动 |
| 复杂声音 | 更丰富、多层次的形态变化 |

试着说话、播放音乐，或静静让环境音流淌——每一种声景都塑造出独一无二的生命形态。

---

### 第四步 — 拖动手势 EQ 塑形

录制过程中，直接用手指在 Imprint 上拖动，实时重塑其频率灵敏度：

| 手势 | 效果 |
|---|---|
| 向下拖动 | 增强低频响应，形体更宏大厚重 |
| 向上拖动 | 增强高频响应，边缘更精细活跃 |
| 横向滑动 | 整体频率平衡左右偏移 |
| 多点触控 | 同时在不同区域施加不同频率偏向 |

> 💡 录制开始后，界面会短暂显示提示「Drag to sculpt the Imprint」，这是手势提醒。

---

### 第五步 — 停止录制并保存标本

完成后，点击底部中央的红色**停止**按钮。App 将提示你为标本命名，然后自动保存入库。

---

### 第六步 — 浏览标本库

点击右上角的**宫格图标**（⊞，显示当前标本数量）打开标本库。

每张卡片显示：Imprint 最终形态的缩略图、标本名称与保存时间。点击 **▶** 回放，点击 **⊘** 删除。

---

### 无障碍：VoiceOver 支持

开启 VoiceOver 后：

- 每个交互元素都有描述性无障碍标签，VoiceOver 将朗读这些标签
- Imprint 的状态以语言传达——能量强度、形态描述、变化过程——无需依赖视觉
- 引导流程的所有文案以「音频优先」方式设计

> 💡 开启方式：**设置 → 辅助功能 → VoiceOver**，或三击侧边按钮快速切换。

---

## 联系方式

**Sylvian**  
📧 [tristan112767@gmail.com](mailto:tristan112767@gmail.com)  
🐙 [@tristan1127](https://github.com/tristan1127)

---

<div align="center">

*声音转瞬即逝。Echo Imprint 让它留下来。*

</div>
