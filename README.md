# Desktop Pet 项目架构文档

## 一、项目概述

Desktop Pet 是一个基于 Godot 4.3 开发的 AI 桌面宠物应用。项目集成了大语言模型对话、语音合成等 AI 能力，提供了一个可互动的桌面伴侣。

### 核心特性

- AI 对话：集成 LLM API，支持上下文对话
- 语音互动：支持 TTS 语音合成
- 动画效果：角色动画、特效系统
- 窗口管理：支持多功能窗口
- 配置系统：支持多维度配置管理

## 二、系统架构

### 1. 核心组件

```
Core System:
├── 主场景系统
├── AI 服务系统
└── 全局管理系统
```

#### 1.1 主场景系统

- Player 节点：角色渲染与动画控制
- Control 节点：用户界面管理
- AI 系统节点：AI 服务集成
- 窗口管理节点：功能窗口控制

#### 1.2 AI 服务系统

- LLMAPI (scenes/llmapi.gd)：大语言模型服务
- TTSAPI (scenes/ttsapi.gd)：语音合成服务
- STTAPI (scenes/sttapi.gd)：语音识别服务 (暂未上线)

#### 1.3 全局管理系统 (global/)

- ChatSetManager：对话配置管理
- TTSSetManager：语音合成配置管理
- STTSetManager：语音识别配置管理

### 2. 场景结构

#### 2.1 主场景层级

```
Pet (Node2D)
├── Player (Node2D)
│   ├── AnimationPlayer
│   ├── Sprite2D
│   ├── Area2D
│   └── Control
├── AI Services
│   ├── LLMAPI
│   ├── TTSAPI
│   └── STTAPI
└── Windows
    ├── HomeWindow
    ├── FireWindow
    └── SettingsWindow
```

#### 2.2 UI 系统结构

```
Control
├── PanelContainer
│   └── MarginContainer
│       └── VBoxContainer
│           ├── RichTextLabel
│           ├── InputContainer
│           │   ├── LineEdit
│           │   └── VoiceInputButton
│           └── TTSGridContainer
```

## 三、状态系统

### 1. 角色状态管理

```
States:
├── idle：待机状态
├── walk：行走状态
└── chat：对话状态
```

状态转换规则：

1. idle -> walk
   - 触发条件：鼠标距离阈值、跟随模式、非对话状态
2. walk -> idle
   - 触发条件：鼠标接近、跟随关闭、对话开始
3. -> chat
   - 触发条件：用户交互、AI 响应

### 2. 系统状态变量

- show_menu：菜单显示状态
- dragging：拖拽状态
- if_chat_end：对话完成状态
- latest_follow_mouse_state：跟随状态

### 3. AI 服务状态

```gdscript
enum TTSState {
    READY,      // 就绪状态
    CONVERTING, // 转换中
    PLAYING     // 播放中
}
```

## 四、交互系统

### 1. 用户输入处理

```gdscript
Signals:
├── line_edit.text_submitted -> on_submitted
├── area_2d.input_event -> on_input_event
└── voice_input_button.pressed -> _on_voice_input_button_pressed
```

### 2. AI 响应处理

```gdscript
Signals:
├── llmapi.chat_request_finished -> on_chat_request_finished
├── ttsapi.tts_completed -> on_tts_completed
└── sttapi.stt_completed -> _on_stt_completed
```

### 3. 配置信号

```gdscript
Signals:
└── settings_window.follow_mouse_changed -> _on_follow_mouse_changed
```

## 五、功能模块

### 1. 对话系统

#### 1.1 基础对话

- 支持文本输入对话
- 集成 LLM API 服务
- 上下文管理
- 特殊指令处理

#### 1.2 快速对话系统

```
QuickChat System:
├── 类型定义
│   └── enum QuickChatType {QUICKCHAT1, QUICKCHAT2, QUICKCHAT3}
├── UI组件
│   └── TTSGridContainer
│       ├── QuickChat1 Button
│       ├── QuickChat2 Button
│       └── QuickChat3 Button
└── 预设消息
    ├── QUICKCHAT1: 每日穿搭建议
    ├── QUICKCHAT2: 养生建议
    └── QUICKCHAT3: 正能量夸夸
```

快速对话特性：

- 动态时间格式化：支持实时日期插值
- 即时响应：一键触发常用对话

信号流程：

```gdscript
QuickChat Flow:
├── Button.pressed
├── _on_quick_chat_button_pressed(type: QuickChatType)
├── on_submitted(message)
└── llmapi.call_ai_chat(message)
```

### 2. 语音系统

- TTS 语音合成
- 语音播放控制
- 音频资源管理
- STT 语音识别（未上线）

### 3. 动画系统

#### 3.1 角色动画状态

```
Animation States:
├── idle (待机)
├── walk (行走)
└── RESET
```

#### 3.2 场景特效动画

##### 3.2.1 主场景 (scenes/pet.tscn)

- 角色动画
- UI过渡动画
- 对话框缓动效果

##### 3.2.2 休息场景 (scenes/home.tscn)

```
Home Animations:
├── idle
│   ├── 帧序列: [9, 10]
│   ├── 循环模式: loop_mode = 1
│   └── 持续时间: 0.4s
└── RESET
    └── 场景初始化
```

特效元素：

- 背景粒子
- 星星闪烁
- 角色呼吸效果

##### 3.2.3 撒金币场景

- 粒子系统
- 爆炸效果
- 颜色渐变

#### 3.3 动画状态转换

##### 3.3.1 主要状态转换

```
State Transitions:
├── idle -> walk
│   ├── 触发条件
│   │   ├── 鼠标距离超过阈值
│   │   ├── 跟随模式开启
│   │   └── 非对话状态
│   └── 转换效果: 即时切换
├── walk -> idle
│   ├── 触发条件
│   │   ├── 鼠标接近
│   │   ├── 跟随关闭
│   │   └── 对话开始
│   └── 转换效果: 即时切换
└── 场景切换
    ├── 主场景 -> 休息场景
    └── 主场景 -> 撒金币场景
```

##### 3.3.2 UI动画

```
UI Animations:
├── 对话框显示
│   ├── 缓动函数: Tween.TRANS_BACK
│   ├── 缓动类型: Tween.EASE_IN_OUT
│   └── 持续时间: 0.5s
├── 文本显示
│   ├── 类型: visible_ratio tween
│   └── 持续时间: 根据文本长度动态调整
└── 按钮状态
    ├── 普通状态
    ├── 悬停状态
    └── 禁用状态
```

#### 3.4 动画控制器

```
Controllers:
├── AnimationPlayer
│   ├── 角色状态动画
│   └── 场景转换动画
└── Tween
    ├── UI元素动画
    └── 特效动画
```

信号连接：

```gdscript
Signals:
├── animation_finished -> _on_animation_finished
├── tween_completed -> _on_tween_completed
└── state_changed -> _update_animation_state
```

### 4. 窗口系统

- 主窗口管理
- 功能窗口控制
- 窗口状态同步

## 六、配置系统

### 1. 配置项

- AI 服务配置

### 2. 存储位置

- 配置文件：
  - user://chat_settings.json
  - user://tts_settings.json
  - user://stt_settings.json
- 资源文件：res://assets/
- 场景文件：res://scenes/

## 七、扩展开发

### 1. 新功能添加流程

1. 创建场景文件 (.tscn)
2. 实现控制脚本 (.gd)
3. 注册到主场景
4. 添加状态和信号处理
5. 更新配置系统

### 2. 开发规范

- 模块化设计
- 信号通信
- 配置驱动
- 错误处理
- 代码注释

## 八、未来规划

### 1. 功能扩展

- 更多特效支持
- 多角色支持
- 快速对话增强
  - 支持自定义快捷短语
  - 动态调整对话模板
  - 用户偏好学习

### 2. 技术优化

- 性能优化
- 内存管理
- 用户自定义配置管理
- 插件系统
- Agent设计



## 九、致谢

本项目基于 [xccds](https://github.com/xccds) 的开源项目 [DesktopPet:](https://github.com/xccds/DesktopPet) 进行开发。感谢原作者的无私分享和杰出贡献。

联系方式：

- chenxc-cxc（1341837103@qq.com）& nia717（1404199069@qq.com）

  