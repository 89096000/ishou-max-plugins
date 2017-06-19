-- retreives the color of the object name from the cache 
fn getColorFromName node_name = (
	x = findItem pink_cache node_name
	if x > 0 then ( return "pink" )
	x = findItem orange_cache node_name
	if x > 0 then ( return "orange" )
	x = findItem yellow_cache node_name
	if x > 0 then ( return "yellow" )
	x = findItem tan_cache node_name
	if x > 0 then ( return "tan" )
	x = findItem mint_cache node_name
	if x > 0 then ( return "mint" )
	x = findItem dark_cache node_name
	if x > 0 then ( return "dark" )
	x = findItem red_cache node_name
	if x > 0 then ( return "red" )
	x = findItem violet_cache node_name
	if x > 0 then ( return "violet" )
	x = findItem blue_cache node_name
	if x > 0 then ( return "blue" )
	x = findItem grey_cache node_name
	if x > 0 then ( return "grey" )
	return "none"
)

-- Rollout Settings
rollout select_rollout "何色？" (

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

	on select_rollout open do
	(
		btn_cancel.text = "帰る"

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

	fn change_select color_name = (
		if color_name != "cancel" then (
			format "selecting only color %\n" color_name
			max select none
			object_list = for o in objects where o.parent == undefined collect o
			for obj in object_list do (
				color_val = getColorFromName(obj.name as string)
				if color_val == color_name do
					selectmore obj
				for obj in selection do (
					if obj.children != undefined do
						selectmore obj.children
				)
			)
		)
		try (DestroyDialog select_rollout) catch()
	)

	on btn_cancel click do (
		change_select("cancel")
	)

	on btn_pink click do (
		change_select("pink")
	)
	on btn_orange click do (
        change_select("orange")
    )
	on btn_yellow click do (
	    change_select("yellow")
    )
	on btn_tan click do (
        change_select("tan")
    )
	on btn_mint click do (
		change_select("mint")
    )

	on btn_dark click do (
		change_select("dark")
    )
	on btn_red click do (
		change_select("red")
    )
	on btn_violet click do (
		change_select("violet")
    )
	on btn_blue click do (
		change_select("blue")
    )
	on btn_grey click do (
		change_select("grey")
	)

-- end sub rollout
)