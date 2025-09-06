extends Node

# 全局数据管理器
# 管理游戏中的全局数据，如研究生个数、职称等

signal data_updated(data_type: String, new_value)
signal graduate_count_changed(new_count: int)
signal title_changed(new_title: String)

# 研究生个数
var graduate_count: int = 0

# 当前职称
var current_title: String = "研究生"

# 职称等级列表
var title_levels: Array[String] = [
	"研究生",
	"博士生", 
	"博士后",
	"助理教授",
	"副教授",
	"教授",
	"院士"
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 初始化数据
	update_graduate_count(0)
	update_title("研究生")

# 更新研究生个数
func update_graduate_count(new_count: int) -> void:
	graduate_count = new_count
	data_updated.emit("graduate_count", graduate_count)
	graduate_count_changed.emit(graduate_count)

# 增加研究生
func add_graduate(count: int = 1) -> void:
	graduate_count += count
	data_updated.emit("graduate_count", graduate_count)
	graduate_count_changed.emit(graduate_count)

# 减少研究生
func remove_graduate(count: int = 1) -> void:
	graduate_count = max(0, graduate_count - count)
	data_updated.emit("graduate_count", graduate_count)
	graduate_count_changed.emit(graduate_count)

# 更新职称
func update_title(new_title: String) -> void:
	current_title = new_title
	data_updated.emit("current_title", current_title)
	title_changed.emit(current_title)

# 升级职称
func upgrade_title() -> bool:
	var current_index = title_levels.find(current_title)
	if current_index >= 0 and current_index < title_levels.size() - 1:
		var new_title = title_levels[current_index + 1]
		update_title(new_title)
		return true
	return false

# 降级职称
func downgrade_title() -> bool:
	var current_index = title_levels.find(current_title)
	if current_index > 0:
		var new_title = title_levels[current_index - 1]
		update_title(new_title)
		return true
	return false

# 获取当前职称等级
func get_title_level() -> int:
	return title_levels.find(current_title)

# 获取下一个职称
func get_next_title() -> String:
	var current_index = title_levels.find(current_title)
	if current_index >= 0 and current_index < title_levels.size() - 1:
		return title_levels[current_index + 1]
	return current_title

# 检查是否可以升级
func can_upgrade() -> bool:
	return get_title_level() < title_levels.size() - 1

# 获取格式化数据字符串
func get_formatted_data() -> String:
	return "研究生: %d | 职称: %s" % [graduate_count, current_title]

# 重置所有数据
func reset_data() -> void:
	update_graduate_count(0)
	update_title("研究生")
