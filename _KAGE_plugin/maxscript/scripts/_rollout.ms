/*
To Open Rollout UI, Just run this script
*/

-- Name
_MAIN_ROLLOUT_NAME = "意匠計画の影"
_VERSION = kageTools.getVersion asString:true

-- Rollout Settings
_DEFAULT_INDENT = 13;
_ROLLOUT_WIDTH = 250;
_ROLLOUT_HEIGHT = 580;

-- TREEVIEW SETTINGS
_TV_WIDTH = 240;
_TV_HEIGHT = 415;

-- Export Rollout
_E_ROLLOUT_WIDTH = 340;
_E_ROLLOUT_HEIGHT = 200;

-- Save Settings
SETTINGS_FILE_LOCATION = ""
TREE_INI = ""

-- Fonts
fontFam = dotNetObject "system.drawing.fontfamily" "MS Gothic"
fontStyle = dotNetClass "system.drawing.fontStyle"
_ON_FONT = dotNetObject "system.drawing.font" fontFam 8
_OFF_FONT = dotNetObject "system.drawing.font" fontFam 7 fontStyle.italic

-- kills secondary rollouts
fn killRollouts = (
	try (DestroyDialog submenu_rollout) catch()
	try (DestroyDialog export_rollout) catch()
	try (DestroyDialog filter_rollout) catch()
)

rollout treeview_rollout (_MAIN_ROLLOUT_NAME + " V" + _VERSION) (
	-- initialize rollout control
	-- init settings found here: https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2015/ENU/MAXScript-Help/files/GUID-C2B51AEE-9C08-4679-B625-A36C72025C91-htm.html
	fn initTreeView tv = (
		tv.Indent = _DEFAULT_INDENT
		tv.CheckBoxes = true
		tv.imageList = IMAGE_LIST
		tv.Sorted = true
	) 

	-- recursive function for node children
	-- tag contains MXS value, whatever that means
	-- ref to dotnet treenode class https://msdn.microsoft.com/en-us/library/system.windows.forms.treenode(v=vs.110).aspx
	fn addChildren tv theNode theChildren = (		
		if VIEW_STYLE == "color" then (
			for i = 1 to theChildren.count do (
				newNode = undefined

				try (
					color_val = ReadFromIni TREE_INI "nodes" (theChildren[i].name as string)
				) catch (
					color_val = "none"
				)

				if color_val != "none" then (

					if CURRENT_FILTER == color_val or CURRENT_FILTER == "all" then (
						if FLAT_MODE then (
							newNode = tv.Nodes.add theChildren[i].name
						) else (
							newNode = theNode.Nodes.add theChildren[i].name
						)
						newNode.tag = dotNetMXSValue theChildren[i]
						newNode.checked = not theChildren[i].isHidden
						newNode.imageIndex = newNode.selectedImageIndex = 0
						newNode.ToolTipText = color_val

						if theChildren[i].isHidden then (
							newNode.foreColor = GetColorForKey "ltblack"
							newNode.nodeFont = _OFF_FONT
						) else (
							newNode.foreColor = GetColorForKey "black"
							newNode.nodeFont = _ON_FONT
						)

						newNode.backcolor = (GetColorForKey color_val) 
					);
				);

				if FLAT_MODE then (
					newNode = undefined
					addChildren tv newNode theChildren[i].children
				) else (
					if newNode != undefined then
						addChildren tv newNode theChildren[i].children
				)
			)

		) else if VIEW_STYLE == "white" then (
			for i = 1 to theChildren.count do (
				newNode = undefined

				try (
					color_val = ReadFromIni TREE_INI "nodes" (theChildren[i].name as string)
				) catch (
					color_val = "none"
				)

				if color_val == "none" then (
					if FLAT_MODE then (
						newNode = tv.Nodes.add theChildren[i].name
					) else (
						newNode = theNode.Nodes.add theChildren[i].name
					)
					newNode.tag = dotNetMXSValue theChildren[i]
					newNode.checked = not theChildren[i].isHidden
					newNode.imageIndex = newNode.selectedImageIndex = 0
					newNode.ToolTipText = color_val
					-- addChildren tv newNode theChildren[i].children style

					if theChildren[i].isHidden then (
						newNode.foreColor = GetColorForKey "ltblack"
						newNode.nodeFont = _OFF_FONT
					) else (
						newNode.foreColor = GetColorForKey "black"
						newNode.nodeFont = _ON_FONT
					)

					WriteToIni TREE_INI "nodes" (newNode.text as string) "none"
				);

				if FLAT_MODE then (
					newNode = undefined
					addChildren tv newNode theChildren[i].children
				) else (
					if newNode != undefined then
						addChildren tv newNode theChildren[i].children
				)
			)

		) else (
			for i = 1 to theChildren.count do (
				-- node_number_padded = padZeros(i)
				-- node_new_name = node_number_padded + " " + theChildren[i].name
				-- newNode = theNode.Nodes.add node_new_name

				-- uncomment if you want to see properties
				-- print (theChildren[i].name)
				-- print (classof(theChildren[i]))
				-- print (superclassof(theChildren[i]))
				newNode = undefined
				color_val = ReadFromIni TREE_INI "nodes" (theChildren[i].name as string)

				if CURRENT_FILTER == color_val or CURRENT_FILTER == "all" then (
					if FLAT_MODE then (
						newNode = tv.Nodes.add theChildren[i].name
					) else (
						newNode = theNode.Nodes.add theChildren[i].name
					)
					newNode.tag = dotNetMXSValue theChildren[i]
					newNode.checked = not theChildren[i].isHidden
					newNode.imageIndex = newNode.selectedImageIndex = 0
					-- addChildren tv newNode theChildren[i].children

					if theChildren[i].isHidden then (
						newNode.foreColor = GetColorForKey "ltblack"
						newNode.nodeFont = _OFF_FONT
					) else (
						newNode.foreColor = GetColorForKey "black"
						newNode.nodeFont = _ON_FONT
					)

					-- add node data to ini file
					WriteToIni TREE_INI "nodes" (newNode.text as string) "none"

					-- read node ini file data
					newNode.ToolTipText = color_val
					if color_val != "none" then (
						newNode.backcolor = (GetColorForKey color_val)
					)
				);

				if FLAT_MODE then (
					newNode = undefined
					addChildren tv newNode theChildren[i].children
				) else (
					if newNode != undefined then
						addChildren tv newNode theChildren[i].children
				)
			)
		)
	)
	
	-- define the content for the treeview
	-- collect all objects that have no parent (top level nodes)
	-- call recursive function to add children to top level nodes
	fn fillInTreeView tv = (
		if not FLAT_MODE then (
			theRoot = tv.Nodes.add "ルート"
			theRoot.nodeFont = _OFF_FONT
		)		
		rootNodes = for o in objects where o.parent == undefined collect o
		-- add to tree
		tv.beginUpdate()
		if TV_MODE == "group" then (
			addChildren tv theRoot rootNodes
		) else if TV_MODE == "object" then (
			rootNodes_filtered = for r in rootNodes where superclassof(r) != helper collect r
			addChildren tv theRoot rootNodes_filtered
		) else (
			rootNodes_filtered = for r in rootNodes where superclassof(r) == helper collect r
			addChildren tv theRoot rootNodes_filtered
		)
		tv.endUpdate()
	)

	----- ----- -----
	-- refresh button
	fn refreshTreeView tv = (
		tv.Nodes.Clear()
		fillInTreeView tv			
		tv.ExpandAll()
	)
	
	-- create treeview activeX control in rollout
	-- activeXControl tv "MSComctlLib.TreeCtrl" width:190 height:290 align:#center
	dotNetControl tv "TreeView" width:_TV_WIDTH height:_TV_HEIGHT align:#center

	-- HANDLERS
	-- add event handler to select the object if user clicks on node
	-- have to get node under mouse cursor, then select using the MXS tag
	on tv Click arg do (
		if arg.button == tv.mousebuttons.right then(
			-- RIGHT CLICK - bring up color menu
			try (
				try (DestroyDialog submenu_rollout) catch()
				try (DestroyDialog export_rollout) catch()
				try (DestroyDialog filter_rollout) catch()
				local mousepoint = dotNetObject "System.Drawing.Point" arg.x arg.y
				local dialog_pos = GetDialogPos treeview_rollout
				-- local posx = dialog_pos.x - (_COLOR_BTN_SIZE*2)
				local posx = dialog_pos.x + mousepoint.X + 30
				local posy = dialog_pos.y + mousepoint.Y + 30
				CreateDialog submenu_rollout ((_COLOR_BTN_SIZE*2)+2)\
											 ((_COLOR_BTN_SIZE*_COLOR_ROLLOUT_ROWS)+2)\
											 pos:[posx, posy] \
	                                         style:#(#style_border);
			) catch ( )

			KAGE_HITNODE = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			print "start variable tests"
			-- try ( print mousepoint.Y ) catch ( print "fail xy test")
			-- try ( print KAGE_HITNODE.tag.value ) catch ( print "fail test 1" )
			-- try ( print mainVars.THE_HITNODE.backcolor ) catch ( print "fail test 2" )
			-- try ( print KAGE_HITNODE.text ) catch ( print "fail test 3" )
			-- try ( print mainVars.THE_HITNODE.name ) catch ( print "fail test 4" )
			-- try ( print (KAGE_HITNODE.isVisible as string) ) catch ( print "fail test 6" )

		) else (
			-- LEFT CLICK - SELECT OBJECT
			hitNode = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
			)

			for obj in selection do (
				-- try ( print obj.name ) catch ( print "fail test 5" )
				if obj.children != undefined do(
					selectmore obj.children
				)
			)


		)
	)
	
	-- handler for checkbox changing the visibility
	on tv AfterCheck arg do (
		try (
			arg.node.tag.value.isHidden = not arg.node.checked
			if arg.node.checked then (
				arg.node.foreColor = GetColorForKey "black"
				arg.node.nodeFont = _ON_FONT
			) else (
				arg.node.foreColor = GetColorForKey "ltblack"
				arg.node.nodeFont = _OFF_FONT
			)
		) catch ()
	)

	on tv Close arg do(
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()
	)

	-- controls ---------------------------------
	group "コントロール" (
		button btn_refresh "Refresh" \
		toolTip: "refreshes the screen" \
		align: #left across: 3

		button btn_export "Export" \
		toolTip: "exports the selected objects" \
		align: #left across: 3

		button btn_order "Order" \
		toolTip: "Sorts the tree" \
		align: #left across: 3

		button btn_summary "Summary" \
		align: #left  width:50 across:3

		button btn_all "All" \
		align: #left  width:50 across:3

		button btn_filter "Filter" \
		align: #left  width:50 across:3
	)

	----- ----- -----
	-- refresh button
	on btn_refresh pressed do (
		refreshTreeView tv
	)

	----- ----- -----
	-- export button
	on btn_export pressed do (
		if selection.count > 0 then (
			-- call the export rollout
			CreateDialog export_rollout _E_ROLLOUT_WIDTH _E_ROLLOUT_HEIGHT \
				style:#(#style_border, #style_sunkenedge)
		) else (
			messageBox "Please select an object group to export."
		)
	)

	----- ----- -----
	-- order button
	on btn_order pressed do (
		messageBox "This feature is not yet available."
	)

	----- ----- -----
	-- filter button
	on btn_filter pressed do (
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()

		-- local mousepoint = dotNetObject "System.Drawing.Point" arg.x arg.y
		local dialog_pos = GetDialogPos treeview_rollout
		--local posx = dialog_pos.x + mousepoint.X + 30
		--local posy = dialog_pos.y + mousepoint.Y + 30
		local posx = dialog_pos.x - 30 + _TV_WIDTH
		local posy = dialog_pos.y - 50 + _TV_HEIGHT
		CreateDialog filter_rollout ((_COLOR_BTN_SIZE*2)+2)\
									 ((_COLOR_BTN_SIZE*_COLOR_ROLLOUT_ROWS)+2)\
									 pos:[posx, posy] \
                                     style:#(#style_border);
	)

	----- ----- -----
	-- tree controls
	on btn_summary pressed do (
		CURRENT_FILTER = "all"
		FLAT_MODE = false
		tv.CollapseAll()
		tv.TopNode.Expand()
	)

	on btn_all pressed do (
		CURRENT_FILTER = "all"
		FLAT_MODE = false
		tv.ExpandAll()	
	)

	-- mode ---------------------------------
	group "モード" (
		checkbutton modeGroup "Group" width:60 across:3 checked:true
		checkbutton modeLayer "Layer" width:60 across:3 checked:false
		checkbutton modeObject "Object" width:60 across:3 checked:false
		checkbutton modeAll "All" width:60 across:3 checked:true
		checkbutton modeColor "Color" width:60 across:3 checked:false
		checkbutton modeWhite "White" width:60 across:3 checked:false
		-- slider slr_width "Tree Width" range:[100,1000,_E_ROLLOUT_WIDTH] type:#integer orient:#horizontal width:200
	)

	----- ----- -----
	-- checkbutton states
	on modeGroup changed theState do (
		print "modeGroup was pressed"
		CURRENT_FILTER = "all"
		FLAT_MODE = false
		modeGroup.checked = true
		modeLayer.checked = false
		modeObject.checked = false
		TV_MODE = "group"		
		refreshTreeView tv
	)

	on modeLayer changed theState do (
		print "modeLayer was pressed"
		CURRENT_FILTER = "all"
		FLAT_MODE = false
		modeGroup.checked = false
		modeLayer.checked = true
		modeObject.checked = false
		TV_MODE = "layer"
		refreshTreeView tv

		tv.CollapseAll()
		tv.TopNode.Expand()
	)

	on modeObject changed theState do (
		print "modeLayer was pressed"
		CURRENT_FILTER = "all"
		FLAT_MODE = true
		modeGroup.checked = false
		modeLayer.checked = false
		modeObject.checked = true
		TV_MODE = "object"
		refreshTreeView tv
	)

	on modeAll changed theState do (
		print "modeAll was pressed"
		CURRENT_FILTER = "all"
		FLAT_MODE = true
		modeAll.checked = true
		modeColor.checked = false
		modeWhite.checked = false
		VIEW_STYLE = "none"
		refreshTreeView tv
	)

	on modeColor changed theState do (
		print "modeColor was pressed"
		FLAT_MODE = true
		CURRENT_FILTER = "all"
		modeAll.checked = false
		modeColor.checked = true
		modeWhite.checked = false
		VIEW_STYLE = "color"
		refreshTreeView tv
	)

	on modeWhite changed theState do (
		print "modeWhite was pressed"
		FLAT_MODE = true
		modeAll.checked = false
		modeColor.checked = false
		modeWhite.checked = true
		VIEW_STYLE = "white"
		refreshTreeView tv
	)

	-- -- tree height slider handler
	-- on slr_width changed val do (
	-- 	tv.width = val
	-- )

	-- call functions on open
	on treeview_rollout open do (
		initTreeView tv
		fillInTreeView tv
		tv.ExpandAll()
	)

	on treeview_rollout close do (
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()
	)

	on treeview_rollout help do (
		print "help requested which refreshes the callout"
		refreshTreeView tv
	)

	-- TEST ---------------------------------
-- 	button TEST_FILTER "TEST" width:60 across:3

-- 	fn test_recursive tv_node = (
-- 		-- print tv_node.text
-- 		color_val = tv_node.ToolTipText	
-- 		if color_val == "pink" then (
-- 			tv_node.nodeFont = _ON_FONT
-- 		) else (
-- 			tv_node.nodeFont = _OFF_FONT
-- 		)
-- 		for n = 0 to (tv_node.Nodes.Count-1) do			
-- 			test_recursive tv_node.Nodes.Item[n]
-- 	)

-- 	on TEST_FILTER pressed do (
-- 		nodes = tv.Nodes
-- 		-- node_x = nodes.Item[0]
-- 		-- showProperties node_x
-- 		-- showMethods nodes
-- 		for n = 0 to (nodes.Count-1) do (
-- 			test_recursive nodes.Item[n]
-- 		)
-- 	)

-- end main rollout
)


-- 1. end previous rollouts
try (DestroyDialog treeview_rollout) catch()
try (DestroyDialog submenu_rollout) catch()
try (DestroyDialog export_rollout) catch()
try (DestroyDialog filter_rollout) catch()

-- 2. check for settings folder
if maxFilePath == "" then (
	messageBox "Unable to load settings, max file not saved"
) else (
	SETTINGS_FILE_LOCATION = maxFilePath + @"\settings"
	makeDir SETTINGS_FILE_LOCATION
	TREE_INI = SETTINGS_FILE_LOCATION + @"\kage_tree.ini"
)

if SETTINGS_FILE_LOCATION != "" then (
	-- 3. check for settings file
	CreateIniFile TREE_INI

	-- 4. check for color settings file
	InitColorSettings(SETTINGS_FILE_LOCATION)
)

-- 5. create new dialog
CreateDialog treeview_rollout \
	_ROLLOUT_WIDTH\
 	_ROLLOUT_HEIGHT\
 	style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
