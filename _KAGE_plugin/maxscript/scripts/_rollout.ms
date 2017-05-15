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

-- MODES ENUM (group, layer)    ENUM(none, color, white)
_TV_MODE = "group"
_VIEW_STYLE = "none"

-- Fonts
fontFam = dotNetObject "system.drawing.fontfamily" "MS Gothic"
fontStyle = dotNetClass "system.drawing.fontStyle"
_ON_FONT = dotNetObject "system.drawing.font" fontFam 8
_OFF_FONT = dotNetObject "system.drawing.font" fontFam 7 fontStyle.italic
_HIDDEN_FONT = dotNetObject "system.drawing.font" fontFam 1


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
	fn addChildren theNode theChildren style = (
		if style == "color" then (
			for i = 1 to theChildren.count do (
				try (
					color_val = ReadFromIni TREE_INI "nodes" (theChildren[i].name as string)
				) catch (
					color_val = "none"
				)

				if color_val != "none" then (

					newNode = theNode.Nodes.add theChildren[i].name
					newNode.tag = dotNetMXSValue theChildren[i]
					newNode.checked = not theChildren[i].isHidden
					newNode.imageIndex = newNode.selectedImageIndex = 0
					newNode.ToolTipText = color_val
					addChildren newNode theChildren[i].children style

					if theChildren[i].isHidden then (
						newNode.foreColor = GetColorForKey "ltblack"
						newNode.nodeFont = _OFF_FONT
					) else (
						newNode.foreColor = GetColorForKey "black"
						newNode.nodeFont = _ON_FONT
					)

					newNode.backcolor = (GetColorForKey color_val) 
				)
			)
		) else if style == "white" then (
			for i = 1 to theChildren.count do (
				try (
					color_val = ReadFromIni TREE_INI "nodes" (theChildren[i].name as string)
				) catch (
					color_val = "none"
				)

				if color_val == "none" then (
					newNode = theNode.Nodes.add theChildren[i].name
					newNode.tag = dotNetMXSValue theChildren[i]
					newNode.checked = not theChildren[i].isHidden
					newNode.imageIndex = newNode.selectedImageIndex = 0
					newNode.ToolTipText = color_val
					addChildren newNode theChildren[i].children style

					if theChildren[i].isHidden then (
						newNode.foreColor = GetColorForKey "ltblack"
						newNode.nodeFont = _OFF_FONT
					) else (
						newNode.foreColor = GetColorForKey "black"
						newNode.nodeFont = _ON_FONT
					)

					WriteToIni TREE_INI "nodes" (newNode.text as string) "none"
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

				newNode = theNode.Nodes.add theChildren[i].name
				newNode.tag = dotNetMXSValue theChildren[i]
				newNode.checked = not theChildren[i].isHidden
				newNode.imageIndex = newNode.selectedImageIndex = 0
				addChildren newNode theChildren[i].children style

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
				color_val = ReadFromIni TREE_INI "nodes" (newNode.text as string)
				newNode.ToolTipText = color_val
				if color_val != "none" then (
					newNode.backcolor = (GetColorForKey color_val)
				)
			)
		)
	)
	
	-- define the content for the treeview
	-- collect all objects that have no parent (top level nodes)
	-- call recursive function to add children to top level nodes
	fn fillInTreeView tv = (
		theRoot = tv.Nodes.add "ルート"
		theRoot.nodeFont = _OFF_FONT
		rootNodes = for o in objects where o.parent == undefined collect o
		-- add to tree
		tv.beginUpdate()
		if _TV_MODE == "group" then (
			addChildren theRoot rootNodes _VIEW_STYLE
		) else if _TV_MODE == "object" then (
			rootNodes_filtered = for r in rootNodes where superclassof(r) != helper collect r
			addChildren theRoot rootNodes_filtered _VIEW_STYLE
		) else (
			rootNodes_filtered = for r in rootNodes where superclassof(r) == helper collect r
			addChildren theRoot rootNodes_filtered _VIEW_STYLE
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
	)

	-- controls ---------------------------------
	group "コントロール" (
		button btn_refresh "refresh" \
		toolTip: "refreshes the screen" \
		align: #left across: 2

		button btn_export "export" \
		toolTip: "exports the selected objects" \
		align: #left across: 2

		button btn_summary "Summary" \
		align: #left  width:50 across:2

		button btn_all "All" \
		align: #left  width:50 across:2
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
	-- tree controls
	on btn_summary pressed do (
		tv.CollapseAll()
		tv.TopNode.Expand()
	)

	on btn_all pressed do (
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
		modeGroup.checked = true
		modeLayer.checked = false
		modeObject.checked = false
		_TV_MODE = "group"		
		refreshTreeView tv
	)

	on modeLayer changed theState do (
		print "modeLayer was pressed"
		modeGroup.checked = false
		modeLayer.checked = true
		modeObject.checked = false
		_TV_MODE = "layer"
		refreshTreeView tv

		tv.CollapseAll()
		tv.TopNode.Expand()
	)

	on modeObject changed theState do (
		print "modeLayer was pressed"
		modeGroup.checked = false
		modeLayer.checked = false
		modeObject.checked = true
		_TV_MODE = "object"
		refreshTreeView tv
	)

	on modeAll changed theState do (
		print "modeAll was pressed"
		modeAll.checked = true
		modeColor.checked = false
		modeWhite.checked = false
		_VIEW_STYLE = "none"
		refreshTreeView tv
	)

	on modeColor changed theState do (
		print "modeColor was pressed"
		modeAll.checked = false
		modeColor.checked = true
		modeWhite.checked = false
		_VIEW_STYLE = "color"
		refreshTreeView tv
	)

	on modeWhite changed theState do (
		print "modeWhite was pressed"
		modeAll.checked = false
		modeColor.checked = false
		modeWhite.checked = true
		_VIEW_STYLE = "white"
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
	)

	-- Filters ---------------------------------
	button TEST_FILTER "TEST" width:60 across:3

	fn test_recursive tv_node = (
		-- print tv_node.text
		color_val = tv_node.ToolTipText	
		if color_val == "pink" then (
			tv_node.nodeFont = _ON_FONT
		) else (
			tv_node.nodeFont = _HIDDEN_FONT
		)
		for n = 0 to (tv_node.Nodes.Count-1) do			
			test_recursive tv_node.Nodes.Item[n]
	)

	on TEST_FILTER pressed do (
		nodes = tv.Nodes
		-- node_x = nodes.Item[0]
		-- showProperties node_x
		-- showMethods nodes
		for n = 0 to (nodes.Count-1) do (
			test_recursive nodes.Item[n]
		)
	)

-- end main rollout
)


-- 1. end previous rollouts
try (DestroyDialog treeview_rollout) catch()
try (DestroyDialog submenu_rollout) catch()

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
