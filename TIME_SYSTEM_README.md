# 时间系统使用说明

## 功能概述
已为你的Godot项目添加了一个完整的时间系统，具有以下功能：

### 主要特性
1. **实时时间显示** - 在游戏左上角显示当前游戏时间（格式：第X天 Xh Xmin）
2. **快速时间流逝** - 5秒游戏时间 = 1分钟显示时间
3. **暂停/恢复功能** - 按ESC键可以暂停和恢复时间
4. **暂停指示器** - 暂停时显示暂停图标（⏸）
5. **全局管理** - 时间系统作为全局单例，可在任何地方访问

## 文件结构
```
00_Globals/
├── global_time_manager.gd          # 时间管理器脚本

GUI/
├── time_display/
│   ├── time_display.tscn          # 时间显示UI场景
│   └── time_display.gd            # 时间显示UI脚本

GUI/player_hud/
└── player_hud.gd                  # 已修改，集成时间显示
```

## 使用方法

### 基本操作
- **查看时间**：时间自动显示在屏幕左上角
- **暂停时间**：按ESC键打开暂停菜单，时间会自动暂停
- **恢复时间**：关闭暂停菜单，时间会自动恢复

### 代码访问
```gdscript
# 获取当前时间（秒）
var current_time = TimeManager.get_total_seconds()

# 获取格式化时间字符串（格式：第X天 Xh Xmin）
var time_string = TimeManager.get_formatted_time()

# 获取时间组件
var days = TimeManager.days
var hours = TimeManager.hours
var minutes = TimeManager.minutes

# 暂停时间
TimeManager.pause_time()

# 恢复时间
TimeManager.resume_time()

# 重置时间
TimeManager.reset_time()

# 设置时间缩放（12.0 = 5秒游戏时间=1分钟显示时间）
TimeManager.set_time_scale(12.0)
```

### 信号监听
```gdscript
# 监听时间更新
TimeManager.time_updated.connect(_on_time_updated)

func _on_time_updated(days: int, hours: int, minutes: int):
    print("时间更新: 第%d天 %dh %dmin" % [days, hours, minutes])

# 监听暂停/恢复
TimeManager.game_paused.connect(_on_game_paused)
TimeManager.game_resumed.connect(_on_game_resumed)
```

## 技术细节

### 自动加载配置
时间管理器已添加到项目的自动加载列表中：
```
TimeManager="*res://00_Globals/global_time_manager.gd"
```

### UI集成
时间显示UI已集成到玩家HUD中，会在游戏开始时自动显示。

### 暂停系统集成
时间系统已与现有的暂停菜单系统完全集成，无需额外配置。

## 自定义选项

### 修改显示位置
在 `GUI/player_hud/player_hud.gd` 中修改：
```gdscript
time_display_instance.position = Vector2(20, 20)  # 修改坐标
```

### 修改时间格式
在 `GUI/time_display/time_display.gd` 中修改：
```gdscript
time_label.text = "第%d天 %dh %dmin" % [days, hours, minutes]
```

### 修改暂停指示器
在 `GUI/time_display/time_display.tscn` 中修改暂停图标。

## 注意事项
1. 时间系统使用 `PROCESS_MODE_ALWAYS`，确保在暂停时仍能正常工作
2. 时间从游戏开始计算，不包括暂停时间
3. 时间显示会自动与暂停菜单同步
4. 所有时间相关功能都通过全局 `TimeManager` 访问
5. **时间缩放**：5秒游戏时间 = 1分钟显示时间（time_scale = 12.0）
6. **时间格式**：显示为"第X天 Xh Xmin"格式，适合长期游戏

## 测试建议
1. 启动游戏，确认时间显示在左上角（格式：第0天 0h 0min）
2. 等待5秒，确认时间显示为"第0天 0h 1min"
3. 等待5分钟（300秒），确认时间显示为"第0天 1h 0min"
4. 按ESC键暂停，确认时间停止并显示暂停图标
5. 关闭暂停菜单，确认时间恢复
6. 在不同场景间切换，确认时间持续计算
