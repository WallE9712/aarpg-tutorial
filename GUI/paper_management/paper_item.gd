extends Control

# 论文项目UI控制器
# 显示单个论文的信息和状态

signal paper_clicked(paper_data: Dictionary)

@onready var title_label: Label = $HBoxContainer/VBoxContainer/TitleLabel
@onready var details_label: Label = $HBoxContainer/VBoxContainer/DetailsLabel
@onready var status_label: Label = $HBoxContainer/StatusLabel
@onready var click_area: Control = $ClickArea
@onready var background: ColorRect = $Background

var paper_data: Dictionary = {}
var is_selected: bool = false

func _ready() -> void:
	# 连接点击区域信号
	click_area.gui_input.connect(_on_click_area_gui_input)

func setup_paper(data: Dictionary) -> void:
	paper_data = data
	
	# 设置标题
	title_label.text = data.get("title", "未知标题")
	
	# 设置详细信息
	var student_name = data.get("student_name", "未知学生")
	var venue = data.get("venue", "未知期刊")
	details_label.text = "学生: " + student_name + " | 期刊: " + venue
	
	# 设置状态
	var status = data.get("status", 0)
	status_label.text = _get_status_text(status)
	
	# 根据状态设置颜色
	_set_status_color(status)
	
	# 重置选择状态
	is_selected = false
	_update_selection_visual()

func _get_status_text(status: int) -> String:
	match status:
		0:  # NOT_SUBMITTED
			return "未投递"
		1:  # ACCEPTED
			return "已录用"
		2:  # REJECTED
			return "被拒绝"
		_:
			return "未知"

func _set_status_color(status: int) -> void:
	match status:
		0:  # NOT_SUBMITTED - 灰色
			status_label.modulate = Color(0.7, 0.7, 0.7)
		1:  # ACCEPTED - 绿色
			status_label.modulate = Color(0.2, 0.8, 0.2)
		2:  # REJECTED - 红色
			status_label.modulate = Color(0.8, 0.2, 0.2)
		_:
			status_label.modulate = Color.WHITE

func set_selected(selected: bool) -> void:
	is_selected = selected
	_update_selection_visual()

func _update_selection_visual() -> void:
	if is_selected:
		background.color = Color(0.3, 0.5, 0.8, 0.9)  # 蓝色高亮
	else:
		# 根据状态设置背景色
		var status = paper_data.get("status", 0)
		match status:
			0:  # NOT_SUBMITTED
				background.color = Color(0.2, 0.2, 0.2, 0.8)
			1:  # ACCEPTED
				background.color = Color(0.1, 0.4, 0.1, 0.8)
			2:  # REJECTED
				background.color = Color(0.4, 0.1, 0.1, 0.8)
			_:
				background.color = Color(0.2, 0.2, 0.2, 0.8)

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			paper_clicked.emit(paper_data)
			print("论文项目被点击: ", paper_data.get("title", "未知"))
