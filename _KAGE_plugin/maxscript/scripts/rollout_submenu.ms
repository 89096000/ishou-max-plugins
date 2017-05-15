-- Rollout Settings
_COLOR_BTN_SIZE = 20;
_COLOR_ROLLOUT_ROWS = 6;

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

		btn_pink.backColor = GetColorForKey "pink"
		btn_orange.backColor = GetColorForKey "orange"
		btn_yellow.backColor = GetColorForKey "yellow"
		btn_tan.backColor = GetColorForKey "tan"
		btn_mint.backColor = GetColorForKey "mint"

		btn_dark.backColor = GetColorForKey "dark" 
		btn_red.backColor = GetColorForKey "red"
		btn_violet.backColor = GetColorForKey "violet"
		btn_blue.backColor = GetColorForKey "blue"
		btn_grey.backColor = GetColorForKey "grey"
	)

	on btn_cancel click do (
		try (DestroyDialog submenu_rollout) catch()
	)

	on btn_pink click do (
		color_name = "pink"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
	)
	on btn_orange click do (
        color_name = "orange"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_yellow click do (
	    color_name = "yellow"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_tan click do (
        color_name = "tan"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_mint click do (
        color_name = "mint"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_dark click do (
        color_name = "dark"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_red click do (
        color_name = "red"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_violet click do (
        color_name = "violet"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_blue click do (
        color_name = "blue"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_grey click do (
        color_name = "grey"
		print (color_name + " button has been pressed")
		KAGE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (KAGE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
	)

-- end sub rollout
)