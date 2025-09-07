extends Button

# 学生卡片控制器
# 显示学生信息并处理招募逻辑

signal student_recruited(student_data: Dictionary)

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var age_label: Label = $MarginContainer/VBoxContainer/AgeLabel
@onready var gender_label: Label = $MarginContainer/VBoxContainer/GenderLabel
@onready var gpa_label: Label = $MarginContainer/VBoxContainer/GpaLabel
@onready var major_label: Label = $MarginContainer/VBoxContainer/MajorLabel
@onready var papers_label: Label = $MarginContainer/VBoxContainer/PapersLabel
@onready var potential_label: Label = $MarginContainer/VBoxContainer/PotentialLabel
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var personality_label: Label = $MarginContainer/VBoxContainer/PersonalityLabel
@onready var recruit_button: Button = $MarginContainer/VBoxContainer/RecruitButton

var student_data: Dictionary = {}
var is_recruited: bool = false

func _ready() -> void:
	print("学生卡片初始化...")
	# 连接招募按钮信号
	recruit_button.pressed.connect(_on_recruit_button_pressed)
	
	# 设置按钮样式
	_setup_button_style()
	
	# 设置字体样式
	_setup_font_style()
	
	# 测试显示
	name_label.text = "测试学生"
	print("学生卡片初始化完成，可见性: ", visible)

func setup_student(student_info: Dictionary) -> void:
	print("设置学生数据到卡片: ", student_info.get("name", "未知"))
	student_data = student_info
	
	# 更新显示信息
	name_label.text = "姓名: " + student_info.get("name", "未知")
	age_label.text = "年龄: " + str(student_info.get("age", 0))
	gender_label.text = "性别: " + student_info.get("gender", "未知")
	gpa_label.text = "GPA: " + str(student_info.get("gpa", 0.0))
	major_label.text = "专业: " + student_info.get("major", "未知")
	papers_label.text = "论文: " + str(student_info.get("papers", 0)) + "篇"
	potential_label.text = "潜力: " + student_info.get("potential", "未知")
	health_label.text = "健康: " + student_info.get("health", "未知")
	personality_label.text = "性格: " + student_info.get("personality", "未知")
	
	print("卡片文本已更新: ", name_label.text)
	
	# 根据潜力设置颜色
	_set_potential_color(student_info.get("potential", "中等"))

func _setup_button_style() -> void:
	# 设置招募按钮的字体样式
	if recruit_button:
		recruit_button.add_theme_font_size_override("font_size", 12)
		recruit_button.add_theme_color_override("font_color", Color.WHITE)
		recruit_button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		recruit_button.add_theme_constant_override("outline_size", 1)
		recruit_button.custom_minimum_size= Vector2(80,20)

func _setup_font_style() -> void:
	# 确保所有标签都使用正确的字体设置
	var labels = [name_label, age_label, gender_label, gpa_label, major_label, 
				  papers_label, potential_label, health_label, personality_label]
	
	for label in labels:
		if label:
			# 设置字体大小和颜色 - 增强清晰度
			label.add_theme_font_size_override("font_size", 12)
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			label.add_theme_constant_override("outline_size", 2)

func _set_potential_color(potential: String) -> void:
	var color = Color.WHITE
	
	match potential:
		"高":
			color = Color(0.2, 1.0, 0.2)  # 绿色
		"中":
			color = Color(1.0, 1.0, 0.2)  # 黄色
		"低":
			color = Color(1.0, 0.2, 0.2)  # 红色
	
	potential_label.modulate = color

func _on_recruit_button_pressed() -> void:
	if not is_recruited:
		_recruit_student()

func _recruit_student() -> void:
	if is_recruited:
		return
	
	is_recruited = true
	
	# 更新UI状态
	recruit_button.text = "已招募"
	recruit_button.disabled = true
	
	# 改变卡片外观
	modulate = Color(0.5, 0.5, 0.5, 0.7)
	
	# 发送招募信号
	student_recruited.emit(student_data)
	
	print("招募学生: ", student_data.get("name", "未知"))

func reset_card() -> void:
	is_recruited = false
	recruit_button.text = "招募"
	recruit_button.disabled = false
	modulate = Color.WHITE
