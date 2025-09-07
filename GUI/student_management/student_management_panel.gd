extends Control

# 学生信息管理面板控制器
# 管理已招募学生的信息和论文产出

signal panel_opened
signal panel_closed
signal paper_produced(paper_data: Dictionary)

# 论文状态枚举
enum PaperStatus {
	NOT_SUBMITTED,  # 未投递
	ACCEPTED,       # 已录用
	REJECTED        # 被拒绝
}

@onready var student_list: VBoxContainer = $PanelContainer/VBoxContainer/StudentListContainer/StudentList
@onready var student_item_scene = preload("res://GUI/student_management/student_item.tscn")
@onready var collect_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/CollectButton

var student_items: Array = []
var is_panel_open: bool = false
var recruited_students: Array[Dictionary] = []
var paper_production_timer: Timer

func _ready() -> void:
	print("学生信息管理面板初始化开始...")
	# 初始隐藏面板
	visible = false
	
	# 连接收集按钮信号
	collect_button.pressed.connect(_on_collect_button_pressed)
	
	# 创建论文产出定时器
	_setup_paper_production_timer()
	
	# 从全局数据管理器获取已招募的学生
	_load_recruited_students()
	
	# 创建学生列表
	_create_student_list()
	
	# 连接全局信号（如果存在）
	_connect_global_signals()
	
	print("学生信息管理面板初始化完成，创建了 ", student_items.size(), " 个学生项目")

func _connect_global_signals() -> void:
	# 尝试连接全局信号，如果存在的话
	# 这里可以后续实现全局信号系统
	pass

func add_recruited_student(student_data: Dictionary) -> void:
	# 添加新招募的学生到管理系统中
	print("学生管理面板：添加新招募学生到管理系统: ", student_data.get("name", "未知"))
	print("学生管理面板：当前学生数量: ", recruited_students.size())
	
	# 创建管理数据
	var managed_student = student_data.duplicate()
	managed_student["recruited_days"] = 0
	managed_student["recruited_date"] = Time.get_datetime_string_from_system()
	managed_student["papers_produced"] = 0
	managed_student["last_production_time"] = Time.get_unix_time_from_system()
	
	# 初始化研究系统
	managed_student["research_speed"] = _calculate_research_speed(managed_student)
	managed_student["research_progress"] = 0.0
	managed_student["current_paper"] = _generate_new_paper_topic(managed_student)
	
	# 添加到学生列表
	recruited_students.append(managed_student)
	print("学生管理面板：添加后学生数量: ", recruited_students.size())
	
	# 如果面板是打开的，立即更新UI
	if is_panel_open:
		print("学生管理面板：面板已打开，刷新UI")
		_refresh_student_list()
	else:
		print("学生管理面板：面板未打开，不刷新UI")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("student_management_panel"):
		toggle_panel()

func toggle_panel() -> void:
	if is_panel_open:
		close_panel()
	else:
		open_panel()

func open_panel() -> void:
	if is_panel_open:
		return
	
	print("正在打开学生信息管理面板...")
	print("当前已招募学生数量: ", recruited_students.size())
	visible = true
	is_panel_open = true
	
	# 刷新学生列表
	_refresh_student_list()
	
	panel_opened.emit()
	print("学生信息管理面板已打开，可见性: ", visible)

func close_panel() -> void:
	if not is_panel_open:
		return
	
	visible = false
	is_panel_open = false
	
	panel_closed.emit()
	print("学生信息管理面板已关闭")

func _setup_paper_production_timer() -> void:
	paper_production_timer = Timer.new()
	paper_production_timer.wait_time = 1.0  # 1秒更新一次，让进度更平滑
	paper_production_timer.timeout.connect(_on_paper_production_timer_timeout)
	paper_production_timer.autostart = true
	add_child(paper_production_timer)

func _load_recruited_students() -> void:
	# 从全局数据管理器获取已招募的学生
	# 这里只加载真实招募的学生，不生成模拟数据
	recruited_students = []
	print("加载已招募学生数据...")

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

func _create_student_list() -> void:
	print("开始创建学生列表...")
	
	# 清空现有项目
	for child in student_list.get_children():
		child.queue_free()
	student_items.clear()
	
	# 为每个已招募学生创建UI项目
	for student_data in recruited_students:
		var student_item = student_item_scene.instantiate()
		student_list.add_child(student_item)
		student_items.append(student_item)
		
		# 设置学生数据
		student_item.setup_student(student_data)
		
		# 连接点击信号
		student_item.student_clicked.connect(_on_student_clicked)
	
	print("学生列表创建完成")

func _refresh_student_list() -> void:
	# 重新创建学生列表UI，不清空数据
	_create_student_list()

func _on_paper_production_timer_timeout() -> void:
	# 每分钟执行一次，更新所有学生的研究进度
	for student in recruited_students:
		_update_student_research_progress(student)
	
	# 更新UI
	_update_student_items()

func _update_student_research_progress(student: Dictionary) -> void:
	# 更新学生的研究进度
	var research_speed = student.get("research_speed", 0.0)
	var current_progress = student.get("research_progress", 0.0)
	
	# 增加研究进度（每1秒更新一次，所以需要除以60）
	var progress_increment = research_speed / 60.0
	current_progress += progress_increment
	student["research_progress"] = current_progress
	
	# 调试信息（每10秒显示一次，避免刷屏）
	if int(current_progress) % 10 == 0 and current_progress > 0:
		print("学生 ", student["name"], " 研究进度: ", round(current_progress), "% (速度: ", research_speed, "%/分钟)")
	
	# 如果研究进度达到100%，产出论文
	if current_progress >= 100.0:
		_complete_paper_research(student)
		# 重置研究进度，开始新的论文研究
		student["research_progress"] = 0.0
		student["current_paper"] = _generate_new_paper_topic(student)
	
	student["last_production_time"] = Time.get_unix_time_from_system()

func _complete_paper_research(student: Dictionary) -> void:
	# 完成论文研究，产出真实论文
	var paper = student.get("current_paper", {})
	if paper.is_empty():
		paper = _generate_new_paper_topic(student)
	
	# 设置论文为未投递状态
	paper["status"] = 0  # NOT_SUBMITTED
	paper["student_name"] = student["name"]
	paper["submission_date"] = Time.get_datetime_string_from_system()
	
	# 发送论文产出信号（通过信号系统处理保存）
	paper_produced.emit(paper)
	
	# 增加学生产出论文计数
	student["papers_produced"] = student.get("papers_produced", 0) + 1
	
	print("学生 ", student["name"], " 完成了论文研究: ", paper.get("title", "未知标题"))

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
	
	# 根据学生属性生成影响因子
	var impact_factor = _calculate_paper_impact_factor(student)
	
	# 生成论文信息
	paper["id"] = Time.get_unix_time_from_system()  # 使用时间戳作为ID
	paper["title"] = titles[randi() % titles.size()]
	paper["venue"] = venues[randi() % venues.size()]
	paper["research_progress"] = 0.0
	paper["impact_factor"] = impact_factor
	paper["author"] = student["name"]
	paper["status"] = PaperStatus.NOT_SUBMITTED
	paper["submission_date"] = ""
	paper["result_date"] = ""
	paper["journal"] = ""
	paper["student_name"] = student["name"]
	paper["student_major"] = student["major"]
	
	return paper

func _calculate_paper_impact_factor(student: Dictionary) -> float:
	# 根据学生属性计算论文影响因子
	var base_impact = 2.0  # 基础影响因子
	
	# GPA影响
	var gpa_bonus = (student["gpa"] - 2.0) / 2.0 * 3.0  # GPA越高影响因子越高
	
	# 潜力影响
	var potential_multiplier = 1.0
	match student["potential"]:
		"高":
			potential_multiplier = 1.8
		"中":
			potential_multiplier = 1.0
		"低":
			potential_multiplier = 0.6
	
	# 性格影响
	var personality_bonus = 0.0
	match student["personality"]:
		"创新":
			personality_bonus = 2.0  # 创新性格产出高影响因子论文
		"严谨":
			personality_bonus = 1.5  # 严谨性格产出稳定高质量论文
		"勤奋":
			personality_bonus = 1.0  # 勤奋产出较多论文
		"独立":
			personality_bonus = 0.8  # 独立研究
		"合作":
			personality_bonus = 0.5  # 合作研究
	
	# 健康影响
	var health_multiplier = 1.0
	match student["health"]:
		"优秀":
			health_multiplier = 1.3
		"良好":
			health_multiplier = 1.0
		"一般":
			health_multiplier = 0.8
	
	var final_impact = (base_impact + gpa_bonus + personality_bonus) * potential_multiplier * health_multiplier
	return round(final_impact * 10) / 10.0  # 保留一位小数

func _add_paper_to_management_system(paper: Dictionary) -> void:
	# 将论文添加到论文管理系统
	print("添加论文到管理系统: ", paper["title"])
	
	# 通过全局信号通知论文管理面板
	# 这里可以通过全局信号系统或直接访问论文管理面板
	_notify_paper_management_system(paper)

func _notify_paper_management_system(paper: Dictionary) -> void:
	# 通知论文管理面板添加新论文
	# 这里可以通过全局信号或直接访问
	print("通知论文管理面板添加论文: ", paper["title"])

func _update_student_items() -> void:
	# 更新所有学生项目的显示
	for i in range(min(student_items.size(), recruited_students.size())):
		student_items[i].update_student_data(recruited_students[i])

func _on_student_clicked(student_data: Dictionary) -> void:
	print("点击了学生: ", student_data["name"])
	print("招募天数: ", student_data["recruited_days"])
	print("已产出论文: ", student_data["papers_produced"])
	print("研究速度: ", student_data["research_speed"], "%/分钟")
	print("研究进度: ", student_data["research_progress"], "%")
	print("当前论文: ", student_data.get("current_paper", {}).get("title", "未开始研究"))

func _on_collect_button_pressed() -> void:
	# 收集所有学生产出的论文
	var total_papers = 0
	for student in recruited_students:
		total_papers += student["papers_produced"]
		student["papers_produced"] = 0  # 重置产出数量
	
	print("收集了 ", total_papers, " 篇论文")
	
	# 更新UI
	_update_student_items()
	
	# 这里可以将论文添加到论文管理系统中
	# 可以后续与论文管理系统集成
