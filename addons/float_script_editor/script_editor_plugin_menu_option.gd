#============================================================
#    Script Editor Plugin Menu Option
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-21 12:36:27
# - version: 4.0
#============================================================
## 菜单（File，Online，Help）相关接口
@tool
extends EditorScript


# 菜单项枚举，调用 [method menu_option] 方法传入下面的枚举
# see：https://github.com/godotengine/godot/blob/4.0/editor/plugins/script_editor_plugin.h
enum {
	FILE_NEW,
	FILE_NEW_TEXTFILE,
	FILE_OPEN,
	FILE_REOPEN_CLOSED,
	FILE_OPEN_RECENT,
	FILE_SAVE,
	FILE_SAVE_AS,
	FILE_SAVE_ALL,
	FILE_THEME,
	FILE_RUN,
	FILE_CLOSE,
	CLOSE_DOCS,
	CLOSE_ALL,
	CLOSE_OTHER_TABS,
	TOGGLE_SCRIPTS_PANEL,
	SHOW_IN_FILE_SYSTEM,
	FILE_COPY_PATH,
	FILE_TOOL_RELOAD_SOFT,
	SEARCH_IN_FILES,
	REPLACE_IN_FILES,
	SEARCH_HELP,
	SEARCH_WEBSITE,
	HELP_SEARCH_FIND,
	HELP_SEARCH_FIND_NEXT,
	HELP_SEARCH_FIND_PREVIOUS,
	WINDOW_MOVE_UP,
	WINDOW_MOVE_DOWN,
	WINDOW_NEXT,
	WINDOW_PREV,
	WINDOW_SORT,
	WINDOW_SELECT_BASE = 100
}


var script_editor : ScriptEditor
var search_button : MenuButton


func _init():
	super._init()
	
	# 代码辑器
	script_editor = get_editor_interface().get_script_editor()
	# 代码编辑器子节点容器
	var script_sub_container = script_editor.get_child(0)
	# 菜单容器
	var menu_container = script_sub_container.get_child(0)
	
	# 查找节点
	for i in range(menu_container.get_child_count() - 1, -1, -1):
		var node = menu_container.get_child(i)
		if node is MenuButton and search_button == null:
			var popup_menu : PopupMenu = node.get_popup()
			var callable : Callable = popup_menu.id_pressed.get_connections()[0]['callable']
			if callable.get_method() == "ScriptEditor::_menu_option":
				search_button = node
				break


## 执行菜单项
func menu_option(index: int):
	search_button.get_popup().id_pressed.emit(index)


func search_in_files():
	var code_edit : CodeEdit = get_editor_interface() \
		.get_script_editor() \
		.get_current_editor() \
		.get_base_editor() as CodeEdit
	var selected_text = code_edit.get_selected_text()
	script_editor.get_current_editor().search_in_files_requested.emit(selected_text)


func replace_in_files():
	var code_edit : CodeEdit = get_editor_interface() \
		.get_script_editor() \
		.get_current_editor() \
		.get_base_editor() as CodeEdit
	var selected_text = code_edit.get_selected_text()
	script_editor.get_current_editor().replace_in_files_requested.emit(selected_text)


