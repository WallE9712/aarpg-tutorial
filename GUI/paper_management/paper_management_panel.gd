extends Control

# 论文管理面板控制器
# 管理面板的显示、隐藏和论文列表

signal panel_opened
signal panel_closed
signal paper_added(paper_data: Dictionary)

@onready var paper_list: VBoxContainer = $PanelContainer/VBoxContainer/PaperListContainer/PaperList
@onready var paper_item_scene = preload("res://GUI/paper_management/paper_item.tscn")
@onready var submit_button: Button = $PanelContainer/VBoxContainer/HBoxContainer/SubmitButton
@onready var accepted_papers_label: Label = $PanelContainer/VBoxContainer/StatsContainer/AcceptedPapersLabel
@onready var current_title_label: Label = $PanelContainer/VBoxContainer/StatsContainer/CurrentTitleLabel

var papers: Array[Dictionary] = []
var paper_items: Array = []
var is_panel_open: bool = false
var selected_paper: Dictionary = {}

# 论文状态枚举
enum PaperStatus {
	NOT_SUBMITTED,  # 未投递
	ACCEPTED,       # 已录用
	REJECTED        # 被拒绝
}

func _ready() -> void:
	print("论文管理面板初始化开始...")
	# 初始隐藏面板
	visible = false
	
	# 连接投递按钮信号
	submit_button.pressed.connect(_on_submit_button_pressed)
	
	# 从全局数据管理器加载论文数据
	_load_papers_from_global()
	
	# 创建论文列表
	_create_paper_list()
	
	# 更新统计信息
	_update_stats()
	
	print("论文管理面板初始化完成，创建了 ", paper_items.size(), " 个论文项目")

# 从全局数据管理器加载论文数据
func _load_papers_from_global() -> void:
	if DataManager.has_data("papers"):
		papers = DataManager.get_data("papers", [])
		print("从全局数据管理器加载了 ", papers.size(), " 篇论文")
	else:
		papers = []
		print("全局数据管理器中暂无论文数据")

# 保存论文数据到全局数据管理器
func _save_papers_to_global() -> void:
	DataManager.set_data("papers", papers)
	print("保存 ", papers.size(), " 篇论文到全局数据管理器")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("paper_management_panel"):
		toggle_panel()

func toggle_panel() -> void:
	if is_panel_open:
		close_panel()
	else:
		open_panel()

func open_panel() -> void:
	if is_panel_open:
		return
	
	print("正在打开论文管理面板...")
	visible = true
	is_panel_open = true
	
	# 刷新论文列表
	_refresh_paper_list()
	
	panel_opened.emit()
	print("论文管理面板已打开，可见性: ", visible)

func close_panel() -> void:
	if not is_panel_open:
		return
	
	visible = false
	is_panel_open = false
	
	panel_closed.emit()
	print("论文管理面板已关闭")

func _create_paper_list() -> void:
	print("开始创建论文列表...")
	
	# 清空现有项目
	for child in paper_list.get_children():
		child.queue_free()
	paper_items.clear()
	
	# 为每篇论文创建UI项目
	for paper_data in papers:
		var paper_item = paper_item_scene.instantiate()
		paper_list.add_child(paper_item)
		paper_items.append(paper_item)
		
		# 设置论文数据
		paper_item.setup_paper(paper_data)
		
		# 连接点击信号
		paper_item.paper_clicked.connect(_on_paper_clicked)
	
	print("论文列表创建完成，显示 ", papers.size(), " 篇论文")
	
	# 更新统计信息
	_update_stats()

func _update_stats() -> void:
	# 统计已录用论文数量
	var accepted_count = 0
	for paper in papers:
		if paper.get("status", 0) == PaperStatus.ACCEPTED:
			accepted_count += 1
	
	# 更新已录用论文标签
	accepted_papers_label.text = "已录用论文: " + str(accepted_count) + " 篇"
	
	# 更新当前职称标签
	current_title_label.text = "当前职称: " + DataManager.current_title
	
	# 检查职称升级
	_check_title_upgrade(accepted_count)

func _check_title_upgrade(accepted_count: int) -> void:
	# 根据已录用论文数量升级职称
	var required_papers = [0, 1, 3, 5, 8, 12, 20]  # 对应职称等级所需的论文数量
	var current_level = DataManager.get_title_level()
	
	# 检查是否可以升级
	if current_level < required_papers.size() - 1 and accepted_count >= required_papers[current_level + 1]:
		var old_title = DataManager.current_title
		DataManager.upgrade_title()
		var new_title = DataManager.current_title
		print("🎉 职称升级！从 ", old_title, " 升级到 ", new_title)
		print("需要 ", required_papers[current_level + 1], " 篇已录用论文，当前有 ", accepted_count, " 篇")

func _refresh_paper_list() -> void:
	# 重新生成论文数据并更新列表
	_create_paper_list()

func add_paper(paper_data: Dictionary) -> void:
	# 添加新论文到列表中
	print("添加论文到管理系统: ", paper_data.get("title", "未知标题"))
	
	# 添加到papers数组
	papers.append(paper_data)
	
	# 保存到全局数据管理器
	_save_papers_to_global()
	
	# 重新创建论文列表UI
	_create_paper_list()
	
	# 发送论文添加信号
	paper_added.emit(paper_data)

# 生成模拟论文数据
func _generate_mock_papers() -> Array[Dictionary]:
	var papers: Array[Dictionary] = []
	
	# 论文标题库
	var titles = [
		"基于深度学习的图像识别算法研究",
		"区块链技术在供应链管理中的应用",
		"人工智能在医疗诊断中的创新方法",
		"云计算环境下的数据安全保护机制",
		"机器学习在金融风险评估中的应用",
		"物联网设备的安全通信协议设计",
		"大数据分析在智慧城市建设中的作用",
		"虚拟现实技术在教育领域的应用研究",
		"5G网络下的边缘计算优化策略",
		"自然语言处理在智能客服系统中的应用"
	]
	
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
	
	# 学生姓名库
	var student_names = ["张伟", "李芳", "王磊", "刘敏", "陈静", "杨强", "赵丽", "黄军", "周娜", "吴秀英"]
	
	# 生成10篇论文
	for i in range(10):
		var paper = {}
		
		# 基本信息
		paper["id"] = i + 1
		paper["title"] = titles[i]
		paper["venue"] = venues[i]
		paper["student_name"] = student_names[i % student_names.size()]
		paper["submission_date"] = "2024-" + str(randi_range(1, 12)).pad_zeros(2) + "-" + str(randi_range(1, 28)).pad_zeros(2)
		
		# 随机分配状态
		var status_rand = randi() % 100
		if status_rand < 30:  # 30% 未投递
			paper["status"] = PaperStatus.NOT_SUBMITTED
		elif status_rand < 70:  # 40% 已录用
			paper["status"] = PaperStatus.ACCEPTED
		else:  # 30% 被拒绝
			paper["status"] = PaperStatus.REJECTED
		
		# 影响因子（仅对已投递的论文）
		if paper["status"] != PaperStatus.NOT_SUBMITTED:
			paper["impact_factor"] = round(randf_range(1.0, 10.0) * 10) / 10.0
		else:
			paper["impact_factor"] = 0.0
		
		papers.append(paper)
		print("生成论文 ", i+1, ": ", paper["title"], " - 状态: ", _get_status_text(paper["status"]))
	
	return papers

func _get_status_text(status: PaperStatus) -> String:
	match status:
		PaperStatus.NOT_SUBMITTED:
			return "未投递"
		PaperStatus.ACCEPTED:
			return "已录用"
		PaperStatus.REJECTED:
			return "被拒绝"
		_:
			return "未知"

func _on_paper_clicked(paper_data: Dictionary) -> void:
	print("点击了论文: ", paper_data["title"])
	print("状态: ", _get_status_text(paper_data["status"]))
	print("学生: ", paper_data["student_name"])
	print("期刊/会议: ", paper_data["venue"])
	if paper_data["impact_factor"] > 0:
		print("影响因子: ", paper_data["impact_factor"])
	
	# 选择论文（只有未投递的论文才能被选择）
	if paper_data["status"] == PaperStatus.NOT_SUBMITTED:
		_select_paper(paper_data)
	else:
		print("该论文已经投递过了，无法再次投递")

func _select_paper(paper_data: Dictionary) -> void:
	# 取消之前的选择
	_clear_selection()
	
	# 选择新论文
	selected_paper = paper_data
	submit_button.disabled = false
	submit_button.text = "投递: " + paper_data["title"].substr(0, 10) + "..."
	print("已选择论文: ", paper_data["title"])
	
	# 更新选中论文的视觉反馈
	_update_selection_visual()

func _clear_selection() -> void:
	# 清除所有论文的选择状态
	for paper_item in paper_items:
		paper_item.set_selected(false)

func _update_selection_visual() -> void:
	# 更新选中论文的视觉反馈
	for paper_item in paper_items:
		if paper_item.paper_data == selected_paper:
			paper_item.set_selected(true)
		else:
			paper_item.set_selected(false)

func _on_submit_button_pressed() -> void:
	if selected_paper.is_empty():
		print("没有选择论文")
		return
	
	# 显示投递确认对话框
	_show_submit_confirmation()

func _show_submit_confirmation() -> void:
	# 简单的确认对话框（可以后续改进为更美观的UI）
	var confirm_text = "确定要投递论文《" + selected_paper["title"] + "》到《" + selected_paper["venue"] + "》吗？"
	print(confirm_text)
	
	# 模拟投递过程
	_submit_paper()

func _submit_paper() -> void:
	if selected_paper.is_empty():
		return
	
	print("正在投递论文: ", selected_paper["title"])
	
	# 随机决定投递结果（70%被拒绝，30%被录用）
	var is_accepted = randf() < 0.3
	var new_status = PaperStatus.ACCEPTED if is_accepted else PaperStatus.REJECTED
	
	# 更新论文状态
	selected_paper["status"] = new_status
	selected_paper["submission_date"] = Time.get_datetime_string_from_system()
	
	# 如果被录用，设置影响因子
	if is_accepted:
		selected_paper["impact_factor"] = round(randf_range(1.0, 10.0) * 10) / 10.0
	
	# 保存论文标题用于显示结果
	var paper_title = selected_paper.get("title", "")
	var impact_factor = selected_paper.get("impact_factor", 0)
	
	# 保存到全局数据管理器
	_save_papers_to_global()
	
	# 更新UI
	_refresh_paper_list()
	
	# 更新统计信息
	_update_stats()
	
	# 重置选择
	selected_paper = {}
	submit_button.disabled = true
	submit_button.text = "投递选中论文"
	_clear_selection()
	
	# 显示结果
	var result_text = "论文《" + paper_title + "》投递结果: " + _get_status_text(new_status)
	if is_accepted:
		print("✅ " + result_text + " (影响因子: " + str(impact_factor) + ")")
	else:
		print("❌ " + result_text)
