extends Node

# 时间系统管理器
# 负责游戏时间的显示、暂停和恢复

signal time_updated(days: int, hours: int, minutes: int)
signal game_paused
signal game_resumed

var game_time: float = 0.0  # 游戏时间（秒）
var is_paused: bool = false
var time_scale: float = 12.0  # 时间缩放：5秒游戏时间 = 1分钟显示时间 (60/5=12)

# 时间显示格式
var days: int = 0
var hours: int = 0
var minutes: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 连接到暂停菜单的信号
	if PauseMenu:
		PauseMenu.shown.connect(_on_pause_menu_shown)
		PauseMenu.hidden.connect(_on_pause_menu_hidden)

func _process(delta: float) -> void:
	if not is_paused:
		game_time += delta * time_scale
		_update_time_display()

func _update_time_display() -> void:
	var total_minutes = int(game_time / 60)  # 转换为显示分钟
	days = total_minutes / (24 * 60)  # 计算天数
	hours = (total_minutes % (24 * 60)) / 60  # 计算小时
	minutes = total_minutes % 60  # 计算分钟
	
	time_updated.emit(days, hours, minutes)

func pause_time() -> void:
	if not is_paused:
		is_paused = true
		game_paused.emit()

func resume_time() -> void:
	if is_paused:
		is_paused = false
		game_resumed.emit()

func set_time_scale(scale: float) -> void:
	time_scale = scale

func reset_time() -> void:
	game_time = 0.0
	days = 0
	hours = 0
	minutes = 0
	time_updated.emit(days, hours, minutes)

func get_formatted_time() -> String:
	var time_text = "第%d天" % days
	
	if hours > 0:
		time_text += " %dh" % hours
	if minutes > 0:
		time_text += " %dmin" % minutes
	
	# 如果只有天数，显示完整格式
	if hours == 0 and minutes == 0:
		time_text += " 0h 0min"
	
	return time_text

func get_total_seconds() -> int:
	return int(game_time)

func _on_pause_menu_shown() -> void:
	pause_time()

func _on_pause_menu_hidden() -> void:
	resume_time()
