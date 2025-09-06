extends Node

# 学生数据管理器
# 管理学生数据生成和招募逻辑

signal student_recruited(student_data: Dictionary)

# 学生姓名库
var first_names = ["张", "李", "王", "刘", "陈", "杨", "赵", "黄", "周", "吴", "徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"]
var last_names = ["伟", "芳", "娜", "秀英", "敏", "静", "丽", "强", "磊", "军", "洋", "勇", "艳", "杰", "娟", "涛", "明", "超", "秀兰", "霞"]

# 专业列表
var majors = ["计算机科学", "软件工程", "人工智能", "数据科学", "网络安全", "机器学习", "深度学习", "自然语言处理", "计算机视觉", "机器人学"]

# 性格特点
var personalities = ["勤奋", "创新", "严谨", "合作", "独立", "细心", "积极", "耐心", "专注", "灵活"]

# 健康状态
var health_status = ["优秀", "良好", "一般"]

# 潜力等级
var potential_levels = ["高", "中", "低"]

# 性别
var genders = ["男", "女"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# 生成随机学生数据
func generate_random_student() -> Dictionary:
	print("开始生成随机学生...")
	var student_data = {}
	
	# 生成姓名
	var first_name = first_names[randi() % first_names.size()]
	var last_name = last_names[randi() % last_names.size()]
	student_data["name"] = first_name + last_name
	print("生成姓名: ", student_data["name"])
	
	# 生成年龄 (20-25岁)
	student_data["age"] = randi_range(20, 25)
	
	# 生成性别
	student_data["gender"] = genders[randi() % genders.size()]
	
	# 生成GPA (2.0-4.0)
	student_data["gpa"] = round(randf_range(2.0, 4.0) * 10) / 10.0
	
	# 生成专业
	student_data["major"] = majors[randi() % majors.size()]
	
	# 生成论文数量 (0-5篇)
	student_data["papers"] = randi_range(0, 5)
	
	# 生成科研潜力
	student_data["potential"] = potential_levels[randi() % potential_levels.size()]
	
	# 生成健康状态
	student_data["health"] = health_status[randi() % health_status.size()]
	
	# 生成性格特点
	student_data["personality"] = personalities[randi() % personalities.size()]
	
	return student_data

# 生成4个随机学生
func generate_student_batch() -> Array[Dictionary]:
	print("开始生成学生批次...")
	var students: Array[Dictionary] = []
	for i in range(4):
		print("生成第 ", i+1, " 个学生")
		students.append(generate_random_student())
	print("学生批次生成完成，共 ", students.size(), " 个学生")
	return students

# 招募学生
func recruit_student(student_data: Dictionary) -> void:
	# 更新数据管理器中的研究生数量
	if DataManager:
		DataManager.add_graduate(1)
	
	# 发送招募信号
	student_recruited.emit(student_data)
	
	print("成功招募学生: ", student_data.get("name", "未知"))

# 简化的学生数据管理器
