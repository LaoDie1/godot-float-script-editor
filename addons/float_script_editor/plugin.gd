#============================================================
#    godot-float-script-editor
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-19 13:14:14
# - version: 4.0
#============================================================
@tool
extends EditorPlugin


var script_editor : ScriptEditor
var script_sub_container : Control

var dialog : Window = Window.new()
var float_button : Button = Button.new()

var last_main_screen_name: String
var enable_main_changed: bool = true


#============================================================
#  内置
#============================================================
func _enter_tree():
	# 代码辑器
	script_editor = get_editor_interface().get_script_editor()
	# 代码编辑器子节点容器
	script_sub_container = script_editor.get_child(0)
	
	# 当前屏幕视图
	last_main_screen_name = get_current_screen()
	
	# 浮动窗口
	dialog.title = "Godot Engine Script Editor"
	dialog.size = script_editor.size
	dialog.wrap_controls = true
	dialog.visible = false
	dialog.handle_input_locally = false
	get_editor_interface() \
		.get_base_control() \
		.add_child(dialog)
	dialog.close_requested.connect(func(): float_button.button_pressed = false )
	
	# 容器节点
	var container : MarginContainer = MarginContainer.new()
	var panel : Panel = Panel.new()
	container.add_child(panel)
	dialog.add_child(container)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.size = dialog.size
	dialog.size_changed.connect(func(): 
		container.size = dialog.size
	)
	
	# 添加浮动菜单按钮
	var menu_container = script_sub_container.get_child(0)
	menu_container.add_child(float_button)
	float_button.icon = get_editor_icon("ActionCopy")
	float_button.toggle_mode = true
	float_button.toggled.connect(func(button_pressed: bool):
		if button_pressed:
			# 浮动
			script_editor.remove_child(script_sub_container)
			container.add_child(script_sub_container)
			
			await Engine.get_main_loop().process_frame
			_change_to_last_screen()
			dialog.popup_centered()
		
		else:
			# 取消浮动
			if script_sub_container != script_editor.get_child(0):
				script_sub_container \
					.get_parent() \
					.remove_child(script_sub_container)
				script_editor.add_child(script_sub_container, true)
				script_editor.move_child(script_sub_container, 0)
			if dialog.visible:
				dialog.hide()
			
			if dialog.visible:
				dialog.hide()
			get_editor_interface().set_main_screen_editor("Script")
		
	)
	
	self.main_screen_changed.connect(_main_changed)
	
	# 解决快捷键问题
	dialog.window_input.connect(func(event):
		if event is InputEventKey:
			if event.pressed:
				if event.ctrl_pressed:
					if event.keycode in [KEY_S, KEY_L]:
						Engine.get_main_loop().root.push_unhandled_input(event, true)
						dialog.move_to_foreground()
					elif event.keycode in [KEY_F, KEY_F5] and event.shift_pressed:
						Engine.get_main_loop().root.push_unhandled_input(event, true)
				elif event.alt_pressed:
					if event.keycode in [KEY_LEFT, KEY_RIGHT]:
						Engine.get_main_loop().root.push_unhandled_input(event, true)
						dialog.move_to_foreground()
					
				else:
					if event.keycode in [KEY_F1, KEY_F5, KEY_F6, KEY_F7, KEY_F8]:
						Engine.get_main_loop().root.push_unhandled_input(event, true)
			
		
	)


func _exit_tree():
	float_button.button_pressed = false
	main_screen_changed.disconnect(_main_changed)
	
	dialog.queue_free()
	float_button.queue_free()


func _handles(object):
	if float_button.button_pressed and object is GDScript:
		_popup()


#============================================================
#  自定义
#============================================================
func _popup():
	dialog.popup()
	dialog.gui_release_focus()
	dialog.move_to_foreground()
	if get_current_screen() == "Script":
		_change_to_last_screen()


func _change_to_last_screen():
	get_editor_interface().set_main_screen_editor("Script")
	if last_main_screen_name == "Script": 
		last_main_screen_name = "2D"
	get_editor_interface().set_main_screen_editor(last_main_screen_name)


func get_current_screen_node() -> Control:
	for child in get_editor_interface() \
		.get_editor_main_screen() \
		.get_children():
		if child is Control and child.visible:
			return child
	return null

func get_current_screen() -> String:
	var child = get_current_screen_node()
	if child is Control and child.visible:
		match child.get_class():
			"CanvasItemEditor":
				return "2D"
			"Node3DEditor":
				return "3D"
			"ScriptEditor":
				return "Script"
			"EditorAssetsLibrary":
				return "AssetLib"
			_:
				if str(child.name).contains("@"):
					return child.get_class()
				return child.name
	
	# default 2D viewport
	return "2D"

func get_editor_icon(icon_name):
	if Engine.is_editor_hint:
		var godot_theme = get_editor_interface().get_base_control().theme
		return godot_theme.get_icon(icon_name, 'EditorIcons')

#============================================================
#  连接信号
#============================================================
func _main_changed(screen_name: String):
	if enable_main_changed:
		if screen_name == "Script":
			if float_button.button_pressed:
				_popup()
				
				# 如果当前是 Script 视图，则切换到 Script 以外的视图中
				if get_current_screen() == "Script":
					_change_to_last_screen()
		
		else:
			last_main_screen_name = screen_name

