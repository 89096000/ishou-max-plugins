/*
TODO init rollout func from some custom menu
To Open Rollout UI, Just run this script
*/
_DEFAULT_INDENT = 13;
_ROLLOUT_WIDTH = 200;
_ROLLOUT_HEIGHT = 400;

_COLOR_BTN_SIZE = 20;

_THE_HITNODE = undefined

rollout submenu_rollout "何色？" (

	local cbs = _COLOR_BTN_SIZE

	-- palette 1
	dotNetControl btn_pink "System.Windows.Forms.Button" pos:[0,0] height:cbs width:cbs
	dotNetControl btn_orange "System.Windows.Forms.Button" pos:[0,cbs*1] height:cbs width:cbs
	dotNetControl btn_yellow "System.Windows.Forms.Button" pos:[0,cbs*2] height:cbs width:cbs
	dotNetControl btn_tan "System.Windows.Forms.Button" pos:[0,cbs*3] height:cbs width:cbs
	dotNetControl btn_mint "System.Windows.Forms.Button" pos:[0,cbs*4] height:cbs width:cbs

	-- palette 2
	dotNetControl btn_dark "System.Windows.Forms.Button" pos:[cbs,0] height:cbs width:cbs
	dotNetControl btn_red "System.Windows.Forms.Button" pos:[cbs,cbs*1] height:cbs width:cbs
	dotNetControl btn_violet "System.Windows.Forms.Button" pos:[cbs,cbs*2] height:cbs width:cbs
	dotNetControl btn_blue "System.Windows.Forms.Button" pos:[cbs,cbs*3] height:cbs width:cbs
	dotNetControl btn_grey "System.Windows.Forms.Button" pos:[cbs,cbs*4] height:cbs width:cbs

	on submenu_rollout open do
	(
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

		btn_pink.backColor = (dotNetClass "System.Drawing.Color").fromARGB 255 107 107
		btn_orange.backColor = (dotNetClass "System.Drawing.Color").fromARGB 252 145 58
		btn_yellow.backColor = (dotNetClass "System.Drawing.Color").fromARGB 249 212 35
		btn_tan.backColor = (dotNetClass "System.Drawing.Color").fromARGB 237 229 116
		btn_mint.backColor = (dotNetClass "System.Drawing.Color").fromARGB 79 240 176

		btn_dark.backColor = (dotNetClass "System.Drawing.Color").fromARGB 25 25 25 
		btn_red.backColor = (dotNetClass "System.Drawing.Color").fromARGB 205 78 80
		btn_violet.backColor = (dotNetClass "System.Drawing.Color").fromARGB 144 96 144
		btn_blue.backColor = (dotNetClass "System.Drawing.Color").fromARGB 153 178 183
		btn_grey.backColor = (dotNetClass "System.Drawing.Color").fromARGB 233 233 233
	)

	on btn_pink click do (
		print "red button has been pressed"
		_THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 255 107 107
		try (DestroyDialog submenu_rollout) catch()
	)
	on btn_orange click do (
        print "btn_orange has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 252 145 58
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_yellow click do (
	    print "btn_yellow has been pressed"
	    _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 249 212 35
	    try (DestroyDialog submenu_rollout) catch()
    )
	on btn_tan click do (
        print "btn_tan has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 237 229 116
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_mint click do (
        print "btn_mint has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 79 240 176
        try (DestroyDialog submenu_rollout) catch()
    )

	on btn_dark click do (
        print "btn_dark has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 25 25 25
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_red click do (
        print "btn_red has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 205 78 80
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_violet click do (
        print "btn_violet has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 144 96 144
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_blue click do (
        print "btn_blue has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 153 178 183
        try (DestroyDialog submenu_rollout) catch()
    )
	on btn_grey click do (
        print "btn_grey has been pressed"
        _THE_HITNODE.backcolor = (dotNetClass "System.Drawing.Color").fromARGB 233 233 233
        try (DestroyDialog submenu_rollout) catch()
	)

-- end sub rollout
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
				try (DestroyDialog submenu_rollout) catch()
				local dialog_pos = GetDialogPos treeview_rollout
				local posx = dialog_pos.x - (_COLOR_BTN_SIZE*2)
				local posy = dialog_pos.y + 50
				CreateDialog submenu_rollout ((_COLOR_BTN_SIZE*2)+2)\
											 ((_COLOR_BTN_SIZE*5)+2)\
											 pos:[posx, posy] \
	                                         style:#(#style_border);
			) catch ( )

			_THE_HITNODE = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			try ( print _THE_HITNODE.tag.value ) catch ( print "fail test 1" )
			try ( print _THE_HITNODE.backcolor ) catch ( print "fail test 2" )
			try ( print _THE_HITNODE.text ) catch ( print "fail test 3" )
			try ( print _THE_HITNODE.item[0].text ) catch ( print "fail test 4" )
			try ( print _THE_HITNODE.name ) catch ( print "fail test 5" )

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
