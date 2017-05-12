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
_COLOR_BTN_SIZE = 20;
_COLOR_ROLLOUT_ROWS = 6;

-- TREEVIEW SETTINGS
_TV_WIDTH = 240;
_TV_HEIGHT = 430;

-- Export Rollout
_E_ROLLOUT_WIDTH = 340;
_E_ROLLOUT_HEIGHT = 200;

-- Scripting Vars
_THE_HITNODE = undefined

-- Save Settings
SETTINGS_FILE_LOCATION = ""
TREE_INI = ""

-- MODES ENUM (group, layer)
_TV_MODE = "group"

-- Fonts
fontFam = dotNetObject "system.drawing.fontfamily" "MS Gothic"
fontStyle = dotNetClass "system.drawing.fontStyle"
_ON_FONT = dotNetObject "system.drawing.font" fontFam 8
_OFF_FONT = dotNetObject "system.drawing.font" fontFam 7 fontStyle.italic


-- ROLLOUTS

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
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
	)
	on btn_orange click do (
        color_name = "orange"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_yellow click do (
	    color_name = "yellow"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_tan click do (
        color_name = "tan"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )
	on btn_mint click do (
        color_name = "mint"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_dark click do (
        color_name = "dark"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_red click do (
        color_name = "red"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_violet click do (
        color_name = "violet"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_blue click do (
        color_name = "blue"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
    )

	on btn_grey click do (
        color_name = "grey"
		print (color_name + " button has been pressed")
		_THE_HITNODE.backcolor = (GetColorForKey color_name)
		OverwriteToIni TREE_INI "nodes" (_THE_HITNODE.text as string) color_name
		try (DestroyDialog submenu_rollout) catch()
	)

-- end sub rollout
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
	fn addChildren theNode theChildren = (

		for i = 1 to theChildren.count do (
			-- node_number_padded = padZeros(i)
			-- node_new_name = node_number_padded + " " + theChildren[i].name
			-- newNode = theNode.Nodes.add node_new_name
			newNode = theNode.Nodes.add theChildren[i].name
			newNode.tag = dotNetMXSValue theChildren[i]
			newNode.checked = not theChildren[i].isHidden
			newNode.imageIndex = newNode.selectedImageIndex = 0
			addChildren newNode theChildren[i].children

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
			if color_val != "none" then (
				newNode.backcolor = (GetColorForKey color_val)
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
		if _TV_MODE == "group" then (
			addChildren theRoot rootNodes
		) else (
			rootNodes_filtered = for r in rootNodes where superclassof(r) != helper collect r
			addChildren theRoot rootNodes_filtered
		)
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

			_THE_HITNODE = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			print "start variable tests"
			-- try ( print mousepoint.Y ) catch ( print "fail xy test")
			-- try ( print _THE_HITNODE.tag.value ) catch ( print "fail test 1" )
			-- try ( print _THE_HITNODE.backcolor ) catch ( print "fail test 2" )
			-- try ( print _THE_HITNODE.text ) catch ( print "fail test 3" )
			-- try ( print _THE_HITNODE.name ) catch ( print "fail test 4" )

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
	)
	
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
		if _TV_MODE == "group" then (
			tv.CollapseAll()
			tv.TopNode.Expand()
		)
	)

	on btn_all pressed do (
		if _TV_MODE == "group" then (
			tv.ExpandAll()
		)
	)

	-- mode ---------------------------------
	group "モード" (
		checkbutton modeGroup "Group" width:50 across:2 checked:true
		checkbutton modeLayer "Layer" width:50 across:2 checked:false
		-- slider slr_width "Tree Width" range:[100,1000,_E_ROLLOUT_WIDTH] type:#integer orient:#horizontal width:200
	)

	----- ----- -----
	-- checkbutton states
	on modeGroup changed theState do (
		print "modeGroup was pressed"
		if theState == true then (
			modeGroup.checked = true
			modeLayer.checked = false
			_TV_MODE = "group"
		) else (
			modeLayer.checked = false
			modeLayer.checked = true
			_TV_MODE = "layer"
		)
		refreshTreeView tv
	)

	on modeLayer changed theState do (
		print "modeLayer was pressed"
		if theState == true then (
			modeLayer.checked = true
			modeGroup.checked = false
			_TV_MODE = "layer"
		) else (
			modeLayer.checked = false
			modeGroup.checked = true
			_TV_MODE = "group"
		)
		refreshTreeView tv
	)

	-- -- tree height slider handler
	-- on slr_width changed val do (
	-- 	tv.width = val
	-- )

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
