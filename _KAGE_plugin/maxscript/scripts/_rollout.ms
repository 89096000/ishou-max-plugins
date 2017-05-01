/*
To Open Rollout UI, Just run this script
*/

-- Name
_MAIN_ROLLOUT_NAME = "意匠計画の影"
_VERSION = kageInstaller.getVersion asString:true

-- Rollout Settings
_DEFAULT_INDENT = 13;
_ROLLOUT_WIDTH = 200;
_ROLLOUT_HEIGHT = 400;
_COLOR_BTN_SIZE = 20;
_COLOR_ROLLOUT_ROWS = 7;

-- Scripting Vars
_THE_HITNODE = undefined

-- Save Settings
SETTINGS_FILE_LOCATION = ""
TREE_INI = ""


-- ROLLOUTS

rollout submenu_rollout "何色？" (

	local cbs = _COLOR_BTN_SIZE

	-- close button
	dotNetControl btn_cancel "System.Windows.Forms.Button" pos:[0,0] height:cbs width:(cbs*2)
	dotNetControl btn_export "System.Windows.Forms.Button" pos:[0,cbs*6] height:cbs width:(cbs*2)

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
		btn_export.flatStyle=btn_export.flatStyle.flat
		btn_export.text = "Export"

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
			-- newNode.backcolor = (dotNetClass "System.Drawing.Color").fromARGB theChildren[i].wirecolor.r theChildren[i].wirecolor.g theChildren[i].wirecolor.b
			addChildren newNode theChildren[i].children

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
		theRoot = tv.Nodes.add "ワールドルート"
		rootNodes = for o in objects where o.parent == undefined collect o
		addChildren theRoot rootNodes
	)
	
	-- create treeview activeX control in rollout
	-- activeXControl tv "MSComctlLib.TreeCtrl" width:190 height:290 align:#center
	dotNetControl tv "TreeView" width:(190) height:290 align:#center

	-- HANDLERS
	-- add event handler to select the object if user clicks on node
	-- have to get node under mouse cursor, then select using the MXS tag
	on tv Click arg do (
		if arg.button == tv.mousebuttons.right then(
			-- RIGHT CLICK - bring up color menu
			try (
				try (DestroyDialog submenu_rollout) catch()
				local dialog_pos = GetDialogPos treeview_rollout
				local posx = dialog_pos.x - (_COLOR_BTN_SIZE*2)
				local posy = dialog_pos.y + 50
				CreateDialog submenu_rollout ((_COLOR_BTN_SIZE*2)+2)\
											 ((_COLOR_BTN_SIZE*_COLOR_ROLLOUT_ROWS)+2)\
											 pos:[posx, posy] \
	                                         style:#(#style_border);
			) catch ( )

			_THE_HITNODE = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			try ( print _THE_HITNODE.tag.value ) catch ( print "fail test 1" )
			try ( print _THE_HITNODE.backcolor ) catch ( print "fail test 2" )
			try ( print _THE_HITNODE.text ) catch ( print "fail test 3" )
			try ( print _THE_HITNODE.name ) catch ( print "fail test 4" )

		) else (
			-- LEFT CLICK - SELECT OBJECT
			hitNode = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
			)

			for obj in selection do (
				try ( print obj.name ) catch ( print "fail test 5" )
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
