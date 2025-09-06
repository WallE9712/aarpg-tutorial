# 全局数据系统使用说明

## 功能概述
已为你的Godot项目添加了一个全局数据管理系统，用于管理研究生个数和当前职称。

### 主要特性
1. **研究生管理** - 跟踪和管理研究生个数
2. **职称系统** - 管理当前职称和职称升级
3. **数据显示** - 在屏幕最上方中间位置显示数据
4. **全局访问** - 数据管理器作为全局单例，可在任何地方访问

## 数据内容

### 研究生个数
- 初始值：0
- 可以增加、减少、重置
- 最小值：0（不能为负数）

### 职称等级
1. 研究生
2. 博士生
3. 博士后
4. 助理教授
5. 副教授
6. 教授
7. 院士

## 使用方法

### 基本操作
- **查看数据**：数据自动显示在屏幕最上方中间
- **数据格式**：`研究生: X | 职称: XXX`

### 代码访问
```gdscript
# 获取当前数据
var graduate_count = DataManager.graduate_count
var current_title = DataManager.current_title

# 研究生管理
DataManager.add_graduate(1)          # 增加1个研究生
DataManager.remove_graduate(1)       # 减少1个研究生
DataManager.update_graduate_count(5) # 设置研究生个数为5

# 职称管理
DataManager.upgrade_title()          # 升级职称
DataManager.downgrade_title()        # 降级职称
DataManager.update_title("教授")     # 直接设置职称

# 获取信息
var can_upgrade = DataManager.can_upgrade()     # 是否可以升级
var next_title = DataManager.get_next_title()   # 获取下一个职称
var title_level = DataManager.get_title_level() # 获取职称等级(0-6)
var formatted = DataManager.get_formatted_data() # 获取格式化字符串

# 重置数据
DataManager.reset_data()
```

### 信号监听
```gdscript
# 监听数据更新
DataManager.graduate_count_changed.connect(_on_graduate_changed)
DataManager.title_changed.connect(_on_title_changed)

func _on_graduate_changed(new_count: int):
    print("研究生个数: ", new_count)

func _on_title_changed(new_title: String):
    print("职称变更: ", new_title)
```

## 使用示例

### 游戏开始时初始化
```gdscript
func _ready():
    # 设置初始数据
    DataManager.update_graduate_count(3)
    DataManager.update_title("博士生")
```

### 完成任务时奖励
```gdscript
func complete_quest():
    # 完成任务，获得研究生和职称提升
    DataManager.add_graduate(2)
    DataManager.upgrade_title()
```

### 检查条件
```gdscript
func check_promotion_requirements():
    if DataManager.graduate_count >= 10 and DataManager.current_title == "副教授":
        DataManager.upgrade_title()
        print("恭喜晋升为教授！")
```

## 注意事项
1. 数据管理器使用 `PROCESS_MODE_ALWAYS`，确保在所有场景中都能正常工作
2. 研究生个数不能为负数
3. 职称升级/降级有边界检查
4. 所有数据变化都会触发相应的信号
5. 数据显示会自动与数据管理器同步

## 测试建议
1. 启动游戏，确认数据显示在屏幕最上方中间
2. 在代码中调用 `DataManager.add_graduate(1)` 测试研究生增加
3. 调用 `DataManager.upgrade_title()` 测试职称升级
4. 观察数据显示是否正确更新
