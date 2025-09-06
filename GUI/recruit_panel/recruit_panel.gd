extends Control

# 学生招募面板控制器
# 管理面板的显示、隐藏和学生卡片

signal panel_opened
signal panel_closed

@onready var cards_container: HBoxContainer = $PanelContainer/VBoxContainer/CardsContainer
@onready var student_card_scene = preload("res://GUI/recruit_panel/student_card.tscn")

var student_cards: Array = []
var is_panel_open: bool = false

func _ready() -> void:
	print("招募面板初始化开始...")
	# 初始隐藏面板
	visible = false
	
	# 创建学生卡片
	_create_student_cards()
	print("招募面板初始化完成，创建了 ", student_cards.size(), " 个卡片")
	
	# 学生数据管理器已通过全局访问

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recruit_panel"):
		toggle_panel()

func toggle_panel() -> void:
	if is_panel_open:
		close_panel()
	else:
		open_panel()

func open_panel() -> void:
	if is_panel_open:
		return
	
	print("正在打开学生招募面板...")
	visible = true
	is_panel_open = true
	
	# 生成新的学生数据
	_refresh_student_cards()
	
	panel_opened.emit()
	print("学生招募面板已打开，可见性: ", visible)

func close_panel() -> void:
	if not is_panel_open:
		return
	
	visible = false
	is_panel_open = false
	
	panel_closed.emit()
	print("学生招募面板已关闭")

func _create_student_cards() -> void:
	print("开始设置学生卡片...")
	
	# 获取场景中预设的卡片
	var preset_cards = [
		$PanelContainer/VBoxContainer/CardsContainer/StudentCard1,
		$PanelContainer/VBoxContainer/CardsContainer/StudentCard2,
		$PanelContainer/VBoxContainer/CardsContainer/StudentCard3,
		$PanelContainer/VBoxContainer/CardsContainer/StudentCard4
	]
	
	# 设置HBoxContainer的布局属性，确保均衡分布
	var cards_container = $PanelContainer/VBoxContainer/CardsContainer
	cards_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 为每个预设卡片添加学生卡片实例
	for i in range(4):
		print("设置第 ", i+1, " 个学生卡片")
		var card_instance = student_card_scene.instantiate()
		preset_cards[i].add_child(card_instance)
		student_cards.append(card_instance)
		
		# 设置每个卡片的布局属性，确保均衡分布
		preset_cards[i].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preset_cards[i].custom_minimum_size = Vector2(80, 200)
		
		print("卡片已添加到预设位置，卡片可见性: ", card_instance.visible)
		
		# 连接招募信号
		card_instance.student_recruited.connect(_on_student_card_recruited)
	
	# 立即生成学生数据并设置到卡片
	_refresh_student_cards()
	print("学生卡片设置完成")

func _refresh_student_cards() -> void:
	# 直接生成4个学生数据，不依赖StudentDataManager
	var students_data = _generate_students_directly()
	print("生成了 ", students_data.size(), " 个学生数据")
	
	# 更新卡片数据
	for i in range(min(student_cards.size(), students_data.size())):
		print("设置学生卡片 ", i, ": ", students_data[i].get("name", "未知"))
		student_cards[i].setup_student(students_data[i])
		student_cards[i].reset_card()

# 直接生成学生数据，不依赖外部管理器
func _generate_students_directly() -> Array[Dictionary]:
	var students: Array[Dictionary] = []
	
	# 学生姓名库
	var first_names = ["张", "李", "王", "刘", "陈", "杨", "赵", "黄", "周", "吴"]
	var last_names = ["伟", "芳", "娜", "秀英", "敏", "静", "丽", "强", "磊", "军"]
	var majors = ["计算机科学", "软件工程", "人工智能", "数据科学", "网络安全"]
	var personalities = ["勤奋", "创新", "严谨", "合作", "独立"]
	var health_status = ["优秀", "良好", "一般"]
	var potential_levels = ["高", "中", "低"]
	var genders = ["男", "女"]
	
	for i in range(4):
		var student = {}
		
		# 生成姓名
		var first_name = first_names[randi() % first_names.size()]
		var last_name = last_names[randi() % last_names.size()]
		student["name"] = first_name + last_name
		
		# 生成其他属性
		student["age"] = randi_range(20, 25)
		student["gender"] = genders[randi() % genders.size()]
		student["gpa"] = round(randf_range(2.0, 4.0) * 10) / 10.0
		student["major"] = majors[randi() % majors.size()]
		student["papers"] = randi_range(0, 5)
		student["potential"] = potential_levels[randi() % potential_levels.size()]
		student["health"] = health_status[randi() % health_status.size()]
		student["personality"] = personalities[randi() % personalities.size()]
		
		students.append(student)
		print("生成学生 ", i+1, ": ", student["name"])
	
	return students

func _on_student_card_recruited(student_data: Dictionary) -> void:
	# 直接更新全局数据管理器
	if DataManager:
		DataManager.add_graduate(1)
		print("研究生数量增加1，当前数量: ", DataManager.graduate_count)
	
	# 禁用被招募的卡片
	for card in student_cards:
		if card.student_data == student_data:
			card.recruit_button.disabled = true
			card.recruit_button.text = "已招募"
			card.modulate = Color(0.5, 0.5, 0.5, 0.7)
			break
	
	print("学生招募成功: ", student_data.get("name", "未知"))
