#============================================================
#    Shortcut Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-04-24 22:57:12
# - version: 4.0
#============================================================
@tool
extends EditorScript


## 解析快捷键字符串
static func parse_shortcut(shortcut_text: String) -> Dictionary:
	const CONTROL_KEY = {"ctrl": null, "shift": null, "alt": null}
	var list = shortcut_text.split("+")
	var keymap : Dictionary = {
		"keycode": KEY_NONE,
		"ctrl": false,
		"shift": false,
		"alt": false,
	}
	for key in list:
		key = str(key).strip_edges().to_lower()
		if CONTROL_KEY.has(key):
			keymap[key] = true
		else:
			keymap["keycode"] = OS.find_keycode_from_string(key)
	return keymap


## 输入Key事件按键字典
static func event_shortcut_dict(event: InputEventKey) -> Dictionary:
	return {
		"keycode": event.keycode, 
		"ctrl": event.ctrl_pressed, 
		"shift": event.shift_pressed, 
		"alt": event.alt_pressed,
	}

