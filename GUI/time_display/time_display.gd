extends Control

# 时间显示UI控制器
# 显示游戏时间并处理暂停状态指示

@onready var time_label: Label = $TimeLabel
@onready var pause_indicator: Label = $PauseIndicator

var is_visible: bool = true

func _ready() -> void:
	# 连接到时间管理器的信号
	if TimeManager:
		TimeManager.time_updated.connect(_on_time_updated)
		TimeManager.game_paused.connect(_on_game_paused)
		TimeManager.game_resumed.connect(_on_game_resumed)
	
	# 初始隐藏暂停指示器
	pause_indicator.visible = false
	
	# 设置位置到左上角
	position = Vector2(20, 20)

func _on_time_updated(days: int, hours: int, minutes: int) -> void:
	if is_visible:
		var time_text = "第%d天" % days
		
		time_text += " %dh" % hours
		time_text += " %dmin" % minutes
		
		time_label.text = time_text

func _on_game_paused() -> void:
	pause_indicator.visible = true

func _on_game_resumed() -> void:
	pause_indicator.visible = false

func show_time_display() -> void:
	visible = true
	is_visible = true

func hide_time_display() -> void:
	visible = false
	is_visible = false

func toggle_time_display() -> void:
	if is_visible:
		hide_time_display()
	else:
		show_time_display()
