-- Rollout Settings
_COLOR_BTN_SIZE = 20;
_COLOR_ROLLOUT_ROWS = 6;
_CURRENT_COLOR_VAL

rollout submenu_rollout "何色？" (

	local cbs = _COLOR_BTN_SIZE

	-- close button
	dotNetControl btn_cancel "System.Windows.Forms.Button" pos:[0,0] height:cbs width:(cbs*2)

	-- palette 1
	dotNetControl btn_pink "System.Windows.Forms.Button" pos:[0,cbs*1] height:cbs width:cbs
	dotNetControl btn_orange "System.Windows.Forms.Button" pos:[0,cbs*2] height:cbs width:cbs
	dotNetControl btn_yellow "System.Windows.Forms.Button" pos:[0,cbs*3] height:cbs width:cbs
	dotNetControl btn_tan "System.Windows.Forms.Button" pos:[0,cbs*4] height:cbs width:cbs
	dotNetControl btn_mint "System.Windows.Forms.Button" pos:[0,cbs*5] height:cbs width:cbs

	-- palette 2
	dotNetControl btn_dark "System.Windows.Forms.Button" pos:[cbs,cbs*1] height:cbs width:cbs
	dotNetControl btn_red "System.Windows.Forms.Button" pos:[cbs,cbs*2] height:cbs width:cbs
	dotNetControl btn_violet "System.Windows.Forms.Button" pos:[cbs,cbs*3] height:cbs width:cbs
	dotNetControl btn_blue "System.Windows.Forms.Button" pos:[cbs,cbs*4] height:cbs width:cbs
	dotNetControl btn_grey "System.Windows.Forms.Button" pos:[cbs,cbs*5] height:cbs width:cbs

	on submenu_rollout open do
	(
		btn_cancel.text = "戻る"

		btn_pink.flatStyle=btn_pink.flatStyle.flat
		btn_orange.flatStyle=btn_orange.flatStyle.flat
		btn_yellow.flatStyle=btn_yellow.flatStyle.flat
		btn_tan.flatStyle=btn_tan.flatStyle.flat
		btn_mint.flatStyle=btn_mint.flatStyle.flat

		btn_dark.flatStyle=btn_dark.flatStyle.flat
		btn_red.flatStyle=btn_red.flatStyle.flat
		btn_violet.flatStyle=btn_violet.flatStyle.flat
		btn_blue.flatStyle=btn_blue.flatStyle.flat
		btn_grey.flatStyle=btn_grey.flatStyle.flat

		_CURRENT_COLOR_VAL = KAGE_HITNODE.ToolTipText
		if _CURRENT_COLOR_VAL == "pink" then (
			btn_pink.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_pink.backColor = GetColorForKey "pink"
		)
		if _CURRENT_COLOR_VAL == "orange" then (
			btn_orange.text = "X"
			btn_orange.foreColor = GetColorForKey "red"
		) else (
			btn_orange.backColor = GetColorForKey "orange"
		)
		if _CURRENT_COLOR_VAL == "yellow" then (
			btn_yellow.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_yellow.backColor = GetColorForKey "yellow"
		)
		if _CURRENT_COLOR_VAL == "tan" then (
			btn_tan.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_tan.backColor = GetColorForKey "tan"
		)
		if _CURRENT_COLOR_VAL == "mint" then (
			btn_mint.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_mint.backColor = GetColorForKey "mint"
		)

		if _CURRENT_COLOR_VAL == "dark" then (
			btn_dark.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_dark.backColor = GetColorForKey "dark" 
		)
		if _CURRENT_COLOR_VAL == "red" then (
			btn_red.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_red.backColor = GetColorForKey "red"
		)
		if _CURRENT_COLOR_VAL == "violet" then (
			btn_violet.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_violet.backColor = GetColorForKey "violet"
		)
		if _CURRENT_COLOR_VAL == "blue" then (
			btn_blue.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_blue.backColor = GetColorForKey "blue"
		)
		if _CURRENT_COLOR_VAL == "grey" then (
			btn_grey.text = "X"
			btn_pink.foreColor = GetColorForKey "red"
		) else (
			btn_grey.backColor = GetColorForKey "grey"
		)
	)

	fn change_color color_name = (
		print (color_name + " button has been pressed")
		print (_CURRENT_COLOR_VAL + " is the current color")
		if _CURRENT_COLOR_VAL == color_name then (
			KAGE_HITNODE.backcolor = (GetColorForKey "white")
			KAGE_HITNODE.ToolTipText = "none"
			RemoveFromIni TREE_INI "nodes" (KAGE_HITNODE.text as string)
		) else (
			KAGE_HITNODE.backcolor = (GetColorForKey color_name)
			KAGE_HITNODE.ToolTipText = color_name
			OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		)		
		try (DestroyDialog submenu_rollout) catch()
	)

	on btn_cancel click do (
		try (DestroyDialog submenu_rollout) catch()
	)

	on btn_pink click do (
		change_color("pink")
	)
	on btn_orange click do (
        change_color("orange")
    )
	on btn_yellow click do (
	    change_color("yellow")
    )
	on btn_tan click do (
        change_color("tan")
    )
	on btn_mint click do (
		change_color("mint")
    )

	on btn_dark click do (
		change_color("dark")
    )

	on btn_red click do (
		change_color("red")
    )

	on btn_violet click do (
		change_color("violet")
    )

	on btn_blue click do (
		change_color("blue")
    )

	on btn_grey click do (
		change_color("grey")
	)

-- end sub rollout
)