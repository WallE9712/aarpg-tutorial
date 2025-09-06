extends Control

# 简单的测试面板，显示4个可点击的学生卡片
var student_cards = []

func _ready():
	print("简单测试面板初始化...")
	
	# 设置面板大小和背景 - 适配项目UI风格
	# 参考项目默认分辨率480x270，但适配1440x810
	var screen_width = 1440
	var screen_height = 810
	
	# 面板大小 - 占屏幕的60%宽度，40%高度
	size = Vector2(screen_width * 0.6, screen_height * 0.4)
	position = Vector2(screen_width * 0.2, screen_height * 0.3)  # 居中显示
	
	# 确保面板在最顶层
	z_index = 50
	z_as_relative = false
	
	# 创建背景
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.size = size
	add_child(background)
	
	# 创建标题
	var title = Label.new()
	title.text = "学生招募面板"
	title.position = Vector2(size.x * 0.3, 20)  # 相对位置
	title.size = Vector2(200, 40)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	# 创建关闭提示
	var close_hint = Label.new()
	close_hint.text = "按O键关闭面板"
	close_hint.position = Vector2(size.x * 0.3, size.y - 30)  # 相对位置
	close_hint.size = Vector2(200, 20)
	close_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(close_hint)
	
	# 创建4个可点击的学生卡片
	for i in range(4):
		_create_student_card(i)
	
	print("简单测试面板初始化完成，创建了 ", student_cards.size(), " 个卡片")

func _create_student_card(index: int):
	# 创建卡片容器 - 根据面板大小动态计算位置
	var card = Button.new()
	
	# 卡片大小 - 根据面板大小计算
	var card_width = size.x * 0.2  # 面板宽度的20%
	var card_height = size.y * 0.6  # 面板高度的60%
	card.size = Vector2(card_width, card_height)
	
	# 卡片位置 - 水平排列，垂直居中
	var card_spacing = size.x * 0.05  # 卡片间距为面板宽度的5%
	var start_x = size.x * 0.1  # 起始位置为面板宽度的10%
	var card_x = start_x + index * (card_width + card_spacing)
	var card_y = size.y * 0.2  # 垂直位置为面板高度的20%
	
	card.position = Vector2(card_x, card_y)
	card.text = ""  # 清空按钮文本
	print("创建卡片 ", index + 1, " 位置: ", card.position, " 大小: ", card.size)
	
	# 设置卡片样式 - 增强边框效果
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.3, 0.5, 0.9)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.8, 0.9, 1.0, 1.0)  # 更亮的边框
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("normal", style)
	
	# 悬停样式
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.4, 0.6, 0.9)
	hover_style.border_width_left = 3
	hover_style.border_width_right = 3
	hover_style.border_width_top = 3
	hover_style.border_width_bottom = 3
	hover_style.border_color = Color(1.0, 1.0, 1.0, 1.0)  # 白色边框
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("hover", hover_style)
	
	# 创建学生信息容器 - 使用MarginContainer控制边距
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_right", 5)
	margin_container.add_theme_constant_override("margin_top", 5)
	margin_container.add_theme_constant_override("margin_bottom", 5)
	card.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)
	
	# 添加学生信息
	var name_label = Label.new()
	name_label.text = "姓名: 学生" + str(index + 1)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)
	
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	var age_label = Label.new()
	age_label.text = "年龄: " + str(20 + index)
	age_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(age_label)
	
	var gpa_label = Label.new()
	gpa_label.text = "GPA: " + str(3.0 + index * 0.2)
	gpa_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(gpa_label)
	
	var major_label = Label.new()
	major_label.text = "专业: 计算机"
	major_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(major_label)
	
	# 添加招募按钮 - 使用容器布局
	var recruit_btn = Button.new()
	recruit_btn.text = "招募"
	recruit_btn.custom_minimum_size = Vector2(0, 30)  # 设置最小高度
	vbox.add_child(recruit_btn)
	
	# 设置招募按钮样式
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.8, 0.2, 0.9)  # 绿色背景
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.1, 0.6, 0.1, 1.0)  # 深绿色边框
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	recruit_btn.add_theme_stylebox_override("normal", btn_style)
	
	# 悬停样式
	var btn_hover_style = StyleBoxFlat.new()
	btn_hover_style.bg_color = Color(0.3, 0.9, 0.3, 0.9)  # 更亮的绿色
	btn_hover_style.border_width_left = 2
	btn_hover_style.border_width_right = 2
	btn_hover_style.border_width_top = 2
	btn_hover_style.border_width_bottom = 2
	btn_hover_style.border_color = Color(0.2, 0.7, 0.2, 1.0)
	btn_hover_style.corner_radius_top_left = 4
	btn_hover_style.corner_radius_top_right = 4
	btn_hover_style.corner_radius_bottom_left = 4
	btn_hover_style.corner_radius_bottom_right = 4
	recruit_btn.add_theme_stylebox_override("hover", btn_hover_style)
	
	# 连接点击事件
	recruit_btn.pressed.connect(_on_recruit_pressed.bind(index))
	
	# 设置卡片在最顶层显示
	card.z_index = 100  # 确保在最顶层
	card.z_as_relative = false
	
	# 添加阴影效果
	var shadow = ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.3)
	shadow.position = Vector2(2, 2)  # 阴影偏移
	shadow.size = card.size
	shadow.z_index = card.z_index - 1
	card.add_child(shadow)
	# 将阴影移到第一个子节点（最底层）
	card.move_child(shadow, 0)
	
	add_child(card)
	student_cards.append(card)
	print("创建了学生卡片 ", index + 1, " 位置: ", card.position, " 大小: ", card.size)
	print("卡片可见性: ", card.visible, " 面板大小: ", size, " Z-Index: ", card.z_index)

func _on_recruit_pressed(student_index: int):
	print("招募学生 ", student_index + 1)
	
	# 更新全局数据管理器
	if DataManager:
		DataManager.add_graduate(1)
		print("研究生数量增加1，当前数量: ", DataManager.graduate_count)
	
	# 禁用被招募的卡片
	var card = student_cards[student_index]
	card.disabled = true
	card.modulate = Color(0.5, 0.5, 0.5, 0.7)
	
	# 更新招募按钮 - 从vbox中获取按钮
	var margin_container = card.get_child(0)  # MarginContainer
	var vbox = margin_container.get_child(0)  # VBoxContainer
	var recruit_btn = vbox.get_child(vbox.get_child_count() - 1)  # 最后一个子节点（招募按钮）
	recruit_btn.text = "已招募"
	recruit_btn.disabled = true
	
	print("学生 ", student_index + 1, " 招募成功！")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recruit_panel"):
		visible = !visible
		print("测试面板可见性切换为: ", visible)
		if visible:
			print("测试面板已显示，包含4个可点击的学生卡片")
