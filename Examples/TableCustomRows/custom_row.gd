extends TableRowComponent

func set_row(header : Array[TableEntity], row : Array, position_idx : int, font_size = 0, font : FontFile = null):
	$Values/Name.text = RowUtils.generate_random_first_name()
	$Values/Age.text = str(RowUtils.generate_random_age())
	$Values/Felling.text = RowUtils.generate_random_feeling()
