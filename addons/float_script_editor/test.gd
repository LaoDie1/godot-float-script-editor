@tool
extends EditorScript

var script_editor : ScriptEditor
var search_button : MenuButton
var menu_container : Control


func _run():
	# 代码辑器
	script_editor = get_editor_interface().get_script_editor()
	# 代码编辑器子节点容器
	var script_sub_container = script_editor.get_child(0)
	# 菜单容器
	menu_container = script_sub_container.get_child(0)
	for i in range(menu_container.get_child_count() - 1, -1, -1):
		var child = menu_container.get_child(i)
		if child is HBoxContainer and child.get_child_count() > 0:
			print(child.visible)
	
	
