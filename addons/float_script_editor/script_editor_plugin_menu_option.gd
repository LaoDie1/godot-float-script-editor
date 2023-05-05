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


const ShortcutUtil = preload("shortcut_util.gd")


## 按键映射
var option_keymap : Dictionary = {
	parse_shortcut_to_hash("Ctrl+N"): FILE_NEW,
	parse_shortcut_to_hash("Ctrl+Shift+N"): FILE_NEW_TEXTFILE,
	parse_shortcut_to_hash("Ctrl+Shift+T"): FILE_REOPEN_CLOSED,
	parse_shortcut_to_hash("Ctrl+Alt+S"): FILE_SAVE,
	parse_shortcut_to_hash("Shift+Alt+S"): FILE_SAVE_ALL,
	parse_shortcut_to_hash("Ctrl+Alt+R"): FILE_TOOL_RELOAD_SOFT,
	parse_shortcut_to_hash("Ctrl+W"): FILE_CLOSE,
	parse_shortcut_to_hash("Ctrl+Shift+X"): FILE_RUN,
	parse_shortcut_to_hash("Ctrl+BackSlash"): TOGGLE_SCRIPTS_PANEL,
	
	parse_shortcut_to_hash("Alt+Left"): WINDOW_PREV,
	parse_shortcut_to_hash("Alt+Right"): WINDOW_NEXT,
	
	parse_shortcut_to_hash("Ctrl+Shift+F"): SEARCH_IN_FILES,
	parse_shortcut_to_hash("Ctrl+Shift+R"): REPLACE_IN_FILES,
}

## 按下之后会再次让此窗口显示到最前显示的快捷键hash值
var move_to_foreground_keymap_hash_list : Array[int] = [
	parse_shortcut_to_hash("Ctrl+S"), 
]

## 输入到 Godot 编辑器窗口上的快捷键hash值
var editor_input_keymap_hash_list : Array[int] = [
	parse_shortcut_to_hash("Ctrl+S"), 
	parse_shortcut_to_hash("Ctrl+O"), 
	parse_shortcut_to_hash("Ctrl+Shift+O"), 
	parse_shortcut_to_hash("Ctrl+Alt+O"),
	parse_shortcut_to_hash("Shift+Alt+O"),
	parse_shortcut_to_hash("Ctrl+F12"),
	parse_shortcut_to_hash("Shift+F11"),
]


var script_editor : ScriptEditor
var search_button : MenuButton


#============================================================
#    内置
#============================================================
func _init():
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


#============================================================
#    自定义
#============================================================
func parse_shortcut_to_hash(shortcut_text: String) -> int:
	return ShortcutUtil.parse_shortcut(shortcut_text).hash()


func menu_option_by_event(event: InputEventKey, dialog: Window) -> void:
	var event_shortcut_hash : int = ShortcutUtil.event_shortcut_dict(event).hash()
	if event_shortcut_hash in editor_input_keymap_hash_list:
		Engine.get_main_loop().root.push_unhandled_input(event, true)
		event.keycode = KEY_NONE
		
	else:
		
		var option : int = option_keymap.get(event_shortcut_hash, -1)
		if option != -1:
			
			if option in [SEARCH_IN_FILES, REPLACE_IN_FILES]:
				var current_editor = get_editor_interface() \
					.get_script_editor() \
					.get_current_editor()
				if current_editor:
					var code_edit : CodeEdit = current_editor.get_base_editor() as CodeEdit
					var selected_text : String = code_edit.get_selected_text()
					if option == SEARCH_IN_FILES:
						script_editor.get_current_editor().search_in_files_requested.emit(selected_text)
					else:
						script_editor.get_current_editor().replace_in_files_requested.emit(selected_text)
			
			else:
				menu_option(option)
			
			event.keycode = KEY_NONE
			
		else:
			if event.keycode in [KEY_F1, KEY_F5, KEY_F6, KEY_F7, KEY_F8]:
				Engine.get_main_loop().root.push_unhandled_input(event, true)
				event.keycode = KEY_NONE
	
	if event_shortcut_hash in move_to_foreground_keymap_hash_list:
		event.keycode = KEY_NONE
		await Engine.get_main_loop().process_frame
		dialog.move_to_foreground()


## 执行菜单项
func menu_option(index: int):
	search_button.get_popup().id_pressed.emit(index)


