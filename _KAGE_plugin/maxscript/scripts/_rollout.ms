/*
TODO init rollout func from some custom menu
To Open Rollout UI, Just run this script
*/
_DEFAULT_INDENT = 13;
_ROLLOUT_WIDTH = 200;
_ROLLOUT_HEIGHT = 400;

rollout submenu_rollout "何色？" (

	--checkbutton ckFile "TEST" width:50
	button ckFile "TEST" width:50

	on ckFile pressed do (
		print "test button has been pressed"
		try (DestroyDialog submenu_rollout) catch()
	)

-- end main rollout
)



rollout treeview_rollout "意匠計画の影" (

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
			newNode.backcolor = (dotNetClass "System.Drawing.Color").fromARGB theChildren[i].wirecolor.r theChildren[i].wirecolor.g theChildren[i].wirecolor.b
			addChildren newNode theChildren[i].children
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
				local dialog_pos = GetDialogPos treeview_rollout
				local posx = dialog_pos.x + 60
				local posy = dialog_pos.y + 60
				CreateDialog submenu_rollout (_ROLLOUT_WIDTH/2)\
											 (_ROLLOUT_HEIGHT/2)\
											 pos:[posx, posy] \
	                                         style:#(#style_border);
	            print "successfully got main dialog position"
			) catch (
				CreateDialog submenu_rollout (_ROLLOUT_WIDTH/2)\
											 (_ROLLOUT_HEIGHT/2)\
	                                         style:#(#style_toolwindow);
			)

		) else (
			-- LEFT CLICK - SELECT OBJECT
			hitNode = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
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
	)

	on treeview_rollout close do (
		try (DestroyDialog submenu_rollout) catch()
	)

-- end main rollout
)


try (DestroyDialog treeview_rollout) catch()
try (DestroyDialog submenu_rollout) catch()

-- create new dialog
CreateDialog treeview_rollout \
	_ROLLOUT_WIDTH\
 	_ROLLOUT_HEIGHT\
 	style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
