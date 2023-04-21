@tool
extends EditorScript


func _run():
	pass
	
	var code_edit = get_editor_interface().get_script_editor().get_current_editor().get_base_editor() as CodeEdit
	print(code_edit)
	
