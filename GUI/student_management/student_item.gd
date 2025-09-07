extends Control

# 学生项目UI控制器
# 显示单个学生的信息和论文产出情况

signal student_clicked(student_data: Dictionary)

@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var details_label: Label = $HBoxContainer/VBoxContainer/DetailsLabel
@onready var recruited_label: Label = $HBoxContainer/VBoxContainer/RecruitedLabel
@onready var papers_produced_label: Label = $HBoxContainer/VBoxContainer2/PapersProducedLabel
@onready var research_progress_label: Label = $HBoxContainer/VBoxContainer2/ResearchProgressLabel
@onready var current_paper_label: Label = $HBoxContainer/VBoxContainer/CurrentPaperLabel
@onready var click_area: Control = $ClickArea

var student_data: Dictionary = {}

func _ready() -> void:
	# 连接点击区域信号
	click_area.gui_input.connect(_on_click_area_gui_input)

func setup_student(data: Dictionary) -> void:
	student_data = data
	_update_display()

func update_student_data(data: Dictionary) -> void:
	student_data = data
	_update_display()

func _update_display() -> void:
	# 设置学生姓名
	name_label.text = student_data.get("name", "未知学生")
	
	# 设置详细信息
	var major = student_data.get("major", "未知专业")
	var gpa = student_data.get("gpa", 0.0)
	var personality = student_data.get("personality", "未知")
	details_label.text = "专业: " + major + " | GPA: " + str(gpa) + " | 性格: " + personality
	
	# 设置招募信息
	var recruited_days = student_data.get("recruited_days", 0)
	recruited_label.text = "招募天数: " + str(recruited_days) + "天"
	
	# 设置论文产出信息
	var papers_produced = student_data.get("papers_produced", 0)
	papers_produced_label.text = "已产出: " + str(int(papers_produced)) + "篇"
	
	# 设置研究进度信息
	var research_progress = student_data.get("research_progress", 0.0)
	research_progress_label.text = "研究进度: " + str(int(research_progress)) + "%"
	
	# 设置当前论文信息
	var current_paper = student_data.get("current_paper", {})
	var paper_title = current_paper.get("title", "未开始研究")
	current_paper_label.text = "当前论文: " + paper_title
	
	# 根据研究进度设置颜色
	_set_research_progress_color(research_progress)

func _set_research_progress_color(progress: float) -> void:
	# 根据研究进度设置颜色
	if progress >= 80:
		research_progress_label.modulate = Color(0.2, 0.8, 0.2)  # 绿色 - 接近完成
	elif progress >= 50:
		research_progress_label.modulate = Color(0.8, 0.8, 0.2)  # 黄色 - 进行中
	elif progress >= 20:
		research_progress_label.modulate = Color(0.8, 0.5, 0.2)  # 橙色 - 刚开始
	else:
		research_progress_label.modulate = Color(0.8, 0.2, 0.2)  # 红色 - 刚开始

func _on_click_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			student_clicked.emit(student_data)
			print("学生项目被点击: ", student_data.get("name", "未知"))
