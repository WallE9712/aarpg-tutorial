extends Control

# 学生招募面板控制器
# 管理面板的显示、隐藏和学生卡片

signal panel_opened
signal panel_closed
signal student_recruited(student_data: Dictionary)

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
	
	# 将学生添加到学生管理系统中
	_add_student_to_management_system(student_data)
	
	# 发送学生招募信号
	student_recruited.emit(student_data)
	
	# 禁用被招募的卡片
	for card in student_cards:
		if card.student_data == student_data:
			card.recruit_button.disabled = true
			card.recruit_button.text = "已招募"
			card.modulate = Color(0.5, 0.5, 0.5, 0.7)
			break
	
	print("学生招募成功: ", student_data.get("name", "未知"))

func _add_student_to_management_system(student_data: Dictionary) -> void:
	# 创建学生管理数据
	var managed_student = student_data.duplicate()
	
	# 添加管理相关属性
	managed_student["recruited_days"] = 0
	managed_student["recruited_date"] = Time.get_datetime_string_from_system()
	managed_student["papers_produced"] = 0
	managed_student["research_speed"] = _calculate_research_speed(managed_student)
	managed_student["research_progress"] = 0.0
	managed_student["current_paper"] = _generate_new_paper_topic(managed_student)
	managed_student["last_production_time"] = Time.get_unix_time_from_system()
	
	# 通知学生管理面板更新
	_notify_student_management_system(managed_student)

func _calculate_research_speed(student: Dictionary) -> float:
	# 根据学生属性计算研究速度（每分钟进度百分比）
	var base_speed = 600.0  # 基础研究速度（每分钟600%，10秒完成一篇）
	
	# GPA影响
	var gpa_bonus = (student["gpa"] - 2.0) / 2.0 * 150.0  # GPA越高研究越快
	
	# 潜力影响
	var potential_multiplier = 1.0
	match student["potential"]:
		"高":
			potential_multiplier = 1.5  # 高潜力：6-7秒完成
		"中":
			potential_multiplier = 1.0  # 中等潜力：10秒完成
		"低":
			potential_multiplier = 0.7  # 低潜力：14秒完成
	
	# 性格影响
	var personality_bonus = 0.0
	match student["personality"]:
		"勤奋":
			personality_bonus = 240.0  # 勤奋：6秒完成
		"创新":
			personality_bonus = 150.0  # 创新：8秒完成
		"严谨":
			personality_bonus = 60.0   # 严谨：12秒完成
		"合作":
			personality_bonus = 120.0  # 合作：9秒完成
		"独立":
			personality_bonus = 90.0   # 独立：10秒完成
	
	# 健康影响
	var health_multiplier = 1.0
	match student["health"]:
		"优秀":
			health_multiplier = 1.2  # 优秀：8秒完成
		"良好":
			health_multiplier = 1.0  # 良好：10秒完成
		"一般":
			health_multiplier = 0.8  # 一般：12秒完成
	
	var final_speed = (base_speed + gpa_bonus + personality_bonus) * potential_multiplier * health_multiplier
	return round(final_speed * 10) / 10.0  # 保留一位小数

func _generate_new_paper_topic(student: Dictionary) -> Dictionary:
	# 根据学生专业生成论文主题
	var paper = {}
	
	# 论文标题库（按专业分类）
	var paper_titles = {
		"计算机科学": [
			"基于深度学习的图像识别算法研究",
			"分布式系统性能优化策略",
			"计算机视觉在医疗诊断中的应用",
			"区块链技术在数据安全中的应用",
			"云计算环境下的资源调度算法"
		],
		"软件工程": [
			"敏捷开发方法在大型项目中的应用",
			"软件测试自动化框架设计",
			"微服务架构的性能优化研究",
			"代码质量评估模型构建",
			"软件项目管理工具开发"
		],
		"人工智能": [
			"机器学习算法在自然语言处理中的应用",
			"强化学习在游戏AI中的实现",
			"神经网络模型压缩技术研究",
			"人工智能伦理问题探讨",
			"智能推荐系统算法优化"
		],
		"数据科学": [
			"大数据处理框架性能分析",
			"数据挖掘算法在商业智能中的应用",
			"时间序列数据预测模型研究",
			"数据可视化技术发展",
			"机器学习在数据清洗中的应用"
		],
		"网络安全": [
			"网络入侵检测系统设计",
			"密码学算法安全性分析",
			"网络安全风险评估模型",
			"区块链安全机制研究",
			"网络攻击防护策略"
		]
	}
	
	var major = student.get("major", "计算机科学")
	var titles = paper_titles.get(major, paper_titles["计算机科学"])
	
	# 期刊/会议名称
	var venues = [
		"IEEE Transactions on Pattern Analysis",
		"ACM Computing Surveys",
		"Nature Machine Intelligence",
		"Journal of Machine Learning Research",
		"International Conference on Machine Learning",
		"Conference on Computer Vision and Pattern Recognition",
		"Neural Information Processing Systems",
		"International Conference on Learning Representations",
		"Association for Computational Linguistics",
		"ACM Transactions on Graphics"
	]
	
	# 生成论文信息
	paper["id"] = Time.get_unix_time_from_system()  # 使用时间戳作为ID
	paper["title"] = titles[randi() % titles.size()]
	paper["venue"] = venues[randi() % venues.size()]
	paper["research_progress"] = 0.0
	
	return paper

func _notify_student_management_system(student_data: Dictionary) -> void:
	# 通过全局信号通知学生管理面板
	# 这里可以使用全局信号系统或者直接访问学生管理面板
	print("通知学生管理面板添加新学生: ", student_data["name"])
