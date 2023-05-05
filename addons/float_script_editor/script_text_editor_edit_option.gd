#============================================================
#    Script Text Editor Edit Option
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-23 13:20:45
# - version: 4.0
#============================================================
## 每个脚本对应的 编辑/搜索/转到 菜单
@tool
extends EditorScript


## see: https://github.com/godotengine/godot/blob/4.0/editor/plugins/script_text_editor.h
enum {
	EDIT_UNDO,
	EDIT_REDO,
	EDIT_CUT,
	EDIT_COPY,
	EDIT_PASTE,
	EDIT_SELECT_ALL,
	EDIT_COMPLETE,
	EDIT_AUTO_INDENT,
	EDIT_TRIM_TRAILING_WHITESAPCE,
	EDIT_CONVERT_INDENT_TO_SPACES,
	EDIT_CONVERT_INDENT_TO_TABS,
	EDIT_TOGGLE_COMMENT,
	EDIT_MOVE_LINE_UP,
	EDIT_MOVE_LINE_DOWN,
	EDIT_INDENT,
	EDIT_UNINDENT,
	EDIT_DELETE_LINE,
	EDIT_DUPLICATE_SELECTION,
	EDIT_PICK_COLOR,
	EDIT_TO_UPPERCASE,
	EDIT_TO_LOWERCASE,
	EDIT_CAPITALIZE,
	EDIT_EVALUATE,
	EDIT_TOGGLE_FOLD_LINE,
	EDIT_FOLD_ALL_LINES,
	EDIT_UNFOLD_ALL_LINES,
	SEARCH_FIND,
	SEARCH_FIND_NEXT,
	SEARCH_FIND_PREV,
	SEARCH_REPLACE,
	SEARCH_LOCATE_FUNCTION,
	SEARCH_GOTO_LINE,
	SEARCH_IN_FILES,
	REPLACE_IN_FILES,
	BOOKMARK_TOGGLE,
	BOOKMARK_GOTO_NEXT,
	BOOKMARK_GOTO_PREV,
	BOOKMARK_REMOVE_ALL,
	DEBUG_TOGGLE_BREAKPOINT,
	DEBUG_REMOVE_ALL_BREAKPOINTS,
	DEBUG_GOTO_NEXT_BREAKPOINT,
	DEBUG_GOTO_PREV_BREAKPOINT,
	HELP_CONTEXTUAL,
	LOOKUP_SYMBOL,
}

const ShortcutUtil = preload("shortcut_util.gd")

var script_editor : ScriptEditor
var search_button : MenuButton
var menu_container : Control

var option_keymap : Dictionary = {
	parse_shortcut_to_hash("Ctrl+K"): EDIT_TOGGLE_COMMENT,
	
	parse_shortcut_to_hash("Ctrl+F"): SEARCH_FIND,
	parse_shortcut_to_hash("Ctrl+R"): SEARCH_REPLACE,
	
	parse_shortcut_to_hash("Ctrl+L"): SEARCH_GOTO_LINE,
	parse_shortcut_to_hash("Ctrl+Alt+F"): SEARCH_LOCATE_FUNCTION,
	
	parse_shortcut_to_hash("Ctrl+B"): BOOKMARK_GOTO_NEXT,
	parse_shortcut_to_hash("Ctrl+Alt+B"): BOOKMARK_TOGGLE,
	parse_shortcut_to_hash("Ctrl+Shift+B"): BOOKMARK_GOTO_PREV,
	
	parse_shortcut_to_hash("Ctrl+Space"): EDIT_COMPLETE,
	parse_shortcut_to_hash("Ctrl+Shift+E"): EDIT_EVALUATE,
	
}


#============================================================
#    内置
#============================================================
func _init():
	# 代码辑器
	script_editor = get_editor_interface().get_script_editor()
	# 代码编辑器子节点容器
	var script_sub_container = script_editor.get_child(0)
	# 菜单容器
	menu_container = script_sub_container.get_child(0)


#============================================================
#    自定义
#============================================================
func parse_shortcut_to_hash(shortcut_text: String) -> int:
	return ShortcutUtil.parse_shortcut(shortcut_text).hash()


func edit_option_by_event(event: InputEventKey):
	var event_shortcut_hash : int = ShortcutUtil.event_shortcut_dict(event).hash()
	var option : int = option_keymap.get(event_shortcut_hash, -1)
	if option != -1:
		edit_option(option)
		event.keycode = KEY_NONE


## 编辑选项
func edit_option(index: int):
	# 当前编辑的脚本的菜单容器
	var script_menu_container = get_current_script_menu_container()
	if script_menu_container:
		var search_menu_button = script_menu_container.get_child(1) as MenuButton
		search_menu_button.get_popup().id_pressed.emit(index)
	else:
		printerr("No current menu found")


# 脚本编辑器菜单都会添加到第一个位置，而不是末尾，所以需要倒序查找
func get_current_script_menu_container() -> HBoxContainer:
	for child in menu_container.get_children():
		if child is HBoxContainer:
			if child.visible and child.get_child_count() > 0:
				return child 
	return null


