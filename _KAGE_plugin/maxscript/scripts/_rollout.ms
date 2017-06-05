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

-- FONTS
fontFam = dotNetObject "system.drawing.fontfamily" "MS Gothic"
fontStyle = dotNetClass "system.drawing.fontStyle"
_ON_FONT = dotNetObject "system.drawing.font" fontFam 8
_OFF_FONT = dotNetObject "system.drawing.font" fontFam 7 fontStyle.italic

-- ICONS
_ICON_DIR = ((GetDir #userIcons) + "/kage")
IMAGE_LIST = dotNetObject "System.Windows.Forms.ImageList"
IMAGE_LIST.imageSize = dotNetObject "System.Drawing.Size" 24 23

-- CACHE
pink_cache = #()
orange_cache = #()
yellow_cache = #()
tan_cache = #()
mint_cache = #()
dark_cache = #()
red_cache = #()
violet_cache = #()
blue_cache = #()
grey_cache = #()
LAYER_NODES = #()


-- FUNCTIONS

-- cache bmp icons
fn getIconFromBitmap number iconFileName = (
	filepath = (_ICON_DIR + "/" + iconFileName + ".bmp")
	-- print ("loading icon from : " + filepath)
	filename = GetDir #image +"\\icon_"+ iconFileName +".bmp"
	-- print ("loading icon to : " + filename)

	-- TODO does it need to delete and remake each time?
	deleteFile filename

	if not doesFileExist filename do (
		tempBmp = openBitmap filepath
		iconBmp = bitmap 24 23
		for v = 0 to 22 do (
			setPixels iconBmp [0,v] (
				getPixels tempBmp [0, v] 24
			)
			iconBmp.filename = filename
			save iconBmp
			close iconBmp
			close tempBmp
		)
	)
	img = dotnetClass "System.Drawing.Image"
	IMAGE_LIST.images.add (img.fromFile filename)
)
getIconFromBitmap 0 "max"
getIconFromBitmap 1 "camera"
getIconFromBitmap 2 "layer"
getIconFromBitmap 3 "light"
getIconFromBitmap 4 "sphere"
getIconFromBitmap 5 "root"
getIconFromBitmap 6 "group"
getIconFromBitmap 7 "particle"
getIconFromBitmap 8 "line"
getIconFromBitmap 9 "vray"
getIconFromBitmap 10 "box"


-- kills secondary rollouts
fn killRollouts = (
	try (DestroyDialog submenu_rollout) catch()
	try (DestroyDialog export_rollout) catch()
	try (DestroyDialog filter_rollout) catch()
	try (DestroyDialog select_rollout) catch()
)


-- load color data from ini files into cache arrays
fn load_color_cache = (
	-- clear cache
	pink_cache = #()
	orange_cache = #()
	yellow_cache = #()
	tan_cache = #()
	mint_cache = #()
	dark_cache = #()
	red_cache = #()
	violet_cache = #()
	blue_cache = #()
	grey_cache = #()

	-- load cache
	color_keys = ReadFromIniSection TREE_INI "nodes"
	for k in color_keys do (
		v = ReadFromIni TREE_INI "nodes" k
		-- format "Key: %; Value: %\n" k v
		if v == "pink" then (
			insertItem k pink_cache 1
		) else if v == "orange" then (
			insertItem k orange_cache 1
		) else if v == "yellow" then (
			insertItem k yellow_cache 1
		) else if v == "tan" then (
			insertItem k tan_cache 1
		) else if v == "mint" then (
			insertItem k mint_cache 1
		) else if v == "dark" then (
			insertItem k dark_cache 1
		) else if v == "red" then (
			insertItem k red_cache 1
		) else if v == "violet" then (
			insertItem k violet_cache 1
		) else if v == "blue" then (
			insertItem k blue_cache 1
		) else if v == "grey" then (
			insertItem k grey_cache 1
		) else if v == "none" then (
		)
	)
)


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


rollout treeview_rollout (_MAIN_ROLLOUT_NAME + " V" + _VERSION) (
	-- create treeview activeX control in rollout
	-- activeXControl tv "MSComctlLib.TreeCtrl" width:190 height:290 align:#center
	dotNetControl tv "TreeView" width:_TV_WIDTH height:_TV_HEIGHT align:#center

	-- init settings found here: https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2015/ENU/MAXScript-Help/files/GUID-C2B51AEE-9C08-4679-B625-A36C72025C91-htm.html
	fn initTreeView tv = (
		tv.Indent = _DEFAULT_INDENT
		tv.CheckBoxes = true
		tv.imageList = IMAGE_LIST
		tv.Sorted = true
	) 

	-- return id from class
	fn getIconId layer_obj = (
		superclassy = (superclassof(layer_obj) as string)
		classy = (classof(layer_obj) as string)
		if superclassy == "camera" then (
			id = 1
		) else if superclassy == "MixinInterface" or superclassy == "Value" then (
			id = 2
		) else if superclassy == "light" then (
			subname = substring layer_obj.name 1 4
			if subname == "VRay" then(
				id = 9
			) else (
				id = 3
			)
		) else if superclassy == "helper" then (
			id = case classy of (
				"Dummy": 6
				"Particle_View": 7
				default: 6
			)
		) else if superclassy == "GeometryClass" then (
			subname = substring layer_obj.name 1 3
			-- print subname
			if subname == "Cyl" then (
				id = 4
			) else if subname == "Lin" then(
				id = 8
			) else if subname == "Box" then(
				id = 10
			) else (
				id = 0
				--"Editable_Poly": 0
				--"PolyMeshObject": 0
				--"Editable_mesh": 0
			)
		) else if superclassy == "shape" then (
			subname = substring layer_obj.name 1 3
			id = case classy of (
				cylinder: 4
				sphere: 4
				"line": 8
				box: 10
				default: 0
			)
		) else (
			print "unidentified"
			print superclassy
			print classy
			print layer_obj.name
			id = 2
		)

		--print superclassy
		--print classy
		--print (" returned id of " + (id as string))
		return id
	)

	/*
	-- function to select same object as in scene
	*/
 	fn recursive_tag_search the_node tag = (
 		if CALLBACKS_MODE then (
	 		try (
		 		if the_node.tag == tag do
		 			tv.SelectedNode = the_node
		 	) catch ()
			for x = 0 to (the_node.Nodes.Count - 1) do (
				node_x = the_node.Nodes.Item[x]
				if node_x.tag == tag do
					tv.SelectedNode = node_x
				recursive_tag_search node_x tag
			)
		)
 	)

 	fn tag_search tv = (
 		-- select object thats selected in scene
 		if tv != undefined do (
	 		tag = undefined
	 		for o in selection do (
	 			--format "% is in selection\n" o.name
	 			if tag == undefined do
		 			tag = dotNetMXSValue o
	 		)

	 		-- search and select
	 		tv.SelectedNode = null
	 		-- node_x = nodes.Item[0]
	 		-- showProperties node_x
	 		-- showMethods nodes
			for x = 0 to (tv.Nodes.Count - 1) do (
				recursive_tag_search tv.Nodes.Item[x] tag
			)
		)
 	)

	-- *******************************************************
	-- TREE FULFILLMENT SUBFUNC- Adds an object for a layer to the treeview

	fn set_node_properties obj newNode color_val = (
		newNode.tag = dotNetMXSValue obj
		newNode.checked = not obj.isHidden
		icon_ref = getIconId(obj)
		newNode.imageIndex = newNode.selectedImageIndex = icon_ref
		newNode.ToolTipText = color_val

		if obj.isHidden then (
			newNode.foreColor = GetColorForKey "ltblack"
			newNode.nodeFont = _OFF_FONT
		) else (
			newNode.foreColor = GetColorForKey "black"
			newNode.nodeFont = _ON_FONT
		)

		if color_val != "none" do
			newNode.backcolor = (GetColorForKey color_val)
	)

	fn add_object tv the_node obj = (
		newNode = undefined

		color_val = getColorFromName(obj.name as string)
		-- VIEW STYLES: color, white, default
		-- CURRENT FILTER: *color name, all
		if VIEW_STYLE == "color" then (
			if color_val == "none" then (
				node_is_valid = false
			) else (
				node_is_valid = (CURRENT_FILTER == "all" or CURRENT_FILTER == color_val)
			)
		) else if VIEW_STYLE == "white" then (
			node_is_valid = color_val == "none"
		) else (
			node_is_valid = (CURRENT_FILTER == "all" or CURRENT_FILTER == color_val)
		)

		-- TV_MODE: layer, detail, group, object
		if TV_MODE == "object" then (
			superclassy = (superclassof(obj) as string)
			if superclassy == "helper" do
				node_is_valid = false
		)

		-- format "node_is_valid for % : %\n" theChildren[i].name color_val
		-- print node_is_valid

		if node_is_valid then (
			if FLAT_MODE then (
				newNode = tv.Nodes.add obj.name
			) else (
				newNode = the_node.Nodes.add obj.name
			)
			set_node_properties obj newNode color_val
		)

		if FLAT_MODE then (
			newNode = undefined
			-- addChildren tv newNode obj.children
			for i = 1 to obj.children.count do (
				add_object tv newNode obj.children[i]
			)
		) else (
			if newNode == undefined then (
				-- addChildren tv the_node obj.children
				for i = 1 to obj.children.count do (
					add_object tv the_node obj.children[i]
				)
			) else (
				-- addChildren tv newNode obj.children
				for i = 1 to obj.children.count do (
					add_object tv newNode obj.children[i]
				)
			)
		)


	)

	-- recursive function for node children
	-- tag contains MXS value, whatever that means
	-- ref to dotnet treenode class https://msdn.microsoft.com/en-us/library/system.windows.forms.treenode(v=vs.110).aspx
	fn addChildren tv the_node theChildren = (
		for i = 1 to theChildren.count do (
			add_object tv the_node theChildren[i]
		)
		/*
		if TV_MODE == "layer" or TV_MODE == "detail" then (
		) else (
			if FLAT_MODE then (
				newNode = undefined
				addChildren tv newNode theChildren[i].children
			) else (
				if newNode != undefined then
					addChildren tv newNode theChildren[i].children
			)
		)
		*/
	)

	-- *******************************************************
	-- TREE FULFILLMENT SUBFUNC - Adds a layer to the treeview
	fn add_layer tv layer = (
		the_node = undefined
		node_is_valid = false

		newNode = undefined	
		parent = layer.getParent()
		if parent == undefined then (
			-- root layers get added to root
			-- format "root layer name : %\n" layer.name
			if layer.name != "0" do
				node_is_valid = true
				the_node = tv
				--newNode = tv.Nodes.add layer.name
				--append LAYER_NODES newNode
		) else (
			-- format "child layer name %, parent %\n" layer.name parent.name
			-- find the parent node
			parent_node = undefined
			for n = 1 to LAYER_NODES.count do (
				if parent_node == undefined do
					if parent.name == "0" then (
						parent_node = LAYER_NODES[n]
					) else (
						try (
							layer_node_name = LAYER_NODES[n].text
						) catch (
							layer_node_name = ''
						)
						if layer_node_name == parent.name then (
							parent_node = LAYER_NODES[n]
						)
					)
			)

			-- note if parent is undedfined the first time, it will be retried 1 time
			if parent_node != undefined then (
				node_is_valid = true
				the_node = parent_node
				--newNode = parent_node.Nodes.add layer.name
				--append LAYER_NODES newNode
			)
		)

		if node_is_valid then (
			color_val = getColorFromName(layer.name as string)
			if the_node.name == "ControlAxSourcingSite" then (
				node_is_valid = true
			) else if VIEW_STYLE == "color" then (
				if color_val == "none" then (
					node_is_valid = false
				) else (
					node_is_valid = (CURRENT_FILTER == "all" or CURRENT_FILTER == color_val)
				)
			) else if VIEW_STYLE == "white" then (
				node_is_valid = color_val == "none"
			) else (
				node_is_valid = (CURRENT_FILTER == "all" or CURRENT_FILTER == color_val)
			)

			if node_is_valid then (

				newNode = the_node.Nodes.add layer.name
				append LAYER_NODES newNode
				try (
					set_node_properties layer newNode color_val
				) catch ()

				return true

			) else (
				return false
			)
		) else (
			return false
		)


/*
		-- new layer properties
		if newNode == undefined then (
			return false
		) else (
			try (
				color_val = getColorFromName(layer.name as string)

				newNode.tag = dotNetMXSValue layer
				newNode.checked = not layer.isHidden
				icon_ref = getIconId(layer)
				newNode.imageIndex = newNode.selectedImageIndex = icon_ref

				if layer.isHidden then (
					newNode.foreColor = GetColorForKey "ltblack"
					newNode.nodeFont = _OFF_FONT
				) else (
					newNode.foreColor = GetColorForKey "black"
					newNode.nodeFont = _ON_FONT
				)

				-- read node ini file data
				newNode.ToolTipText = color_val
				if color_val != "none" then (
					newNode.backcolor = (GetColorForKey color_val)
				)

			) catch ()
			return true
		)
*/

	)

	-- *******************************************************
	-- TREE FULFILLMENT LOGIC- finds layer parent, adds layer, retries 1 time
	fn add_layer_children tv layers = (
		-- 1 get layer parent
		for x = 1 to layers.count do (
			p = layers[x].getParent()
			if p == undefined then (
				pname = "undefined"
			) else (
				pname = p.name
			)
			-- 	format "Layer: %; parent: %\n" layers[x].name pname
		)

		-- print "LAYER ADD LOGIC"
		missed_layers = #()
		for i = 1 to layers.count do (  -- layers.count do (		
			new_node_found = add_layer tv layers[i]
			if not new_node_found do
				append missed_layers layers[i]
		)

		-- rereun missed layers
		missed_layers_final = #()
		for i = 1 to missed_layers.count do (
			new_node_found = add_layer tv missed_layers[i]
			if not new_node_found do
				append missed_layers_final missed_layers[i]
		)

		/*
		-- alert any layers that werent added
		if missed_layers_final.count > 0 then (
			for i = 1 to missed_layers_final.count do (
				format "ERROR: % could not be found\n" missed_layers_final[i].name
			)
		)
		*/
	)

	-- *******************************************************
	-- TREE FULFILLMENT LOGIC- finds layer parent, adds layer, retries 1 time
	fn add_obj_children tv objs = (
		
		-- https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2018/ENU/MAXScript-Help/files/GUID-79537E16-FE25-4567-BEA6-06F39E0A5C1F-htm.html
		for o = 1 to objs.count do (

			-- format "finding objs for layers mode for %\n" obj.name
			obj = objs[o]
			obj_layer = undefined
			obj_layer_node = undefined

			-- loops through every layer (cached)
			for x = 0 to (layerManager.count-1) do (

				if obj_layer == undefined then (

					-- get layer dependencies
					try (
						xlayer = layerManager.getLayer x
						layer = ILayerManager.getLayerObject x
						xlayer_nodes = refs.dependents layer
						--format "Layer: %; nodes: %\n" xlayer.text xlayer_nodes
					) catch (
						--format "error on layer at index %\n" (x as string)
						xlayer_nodes = #()
					)

					-- search through layer dependencies for ob
					for dependent in xlayer_nodes do (
						try (
							if dependent.name == obj.name do
								obj_layer = xlayer
						) catch ()
					)
				)-- end seach for object's layer
			
			) -- end layer iterator

			-- get the layer node for found layer (fromm cache)
			if obj_layer != undefined then (
				for y = 1 to LAYER_NODES.count do (
					if obj_layer_node == undefined then (
						ynode = LAYER_NODES[y]
						try (
							if ynode.text == obj_layer.name do
								obj_layer_node = ynode
						) catch ()
					)
				)
			)

			-- was there a layer dependencies match?  if not, should be layer 0
			if obj_layer_node == undefined then (
				format "ERROR: layer was NOT found for %\n" obj.name
			) else (
				-- successful: add object into respective layer
				add_object tv obj_layer_node obj
			)

		) -- end object iterator
	)
	
	-- define the content for the treeview
	-- collect all objects that have no parent (top level nodes)
	-- call recursive function to add children to top level nodes
	fn fillInTreeView tv = (
		-- set up root
		if TV_MODE == "layer" or TV_MODE == "detail" then (
			theRoot = tv.Nodes.add "0 (default)"
			theRoot.imageIndex = 5

			LAYER_NODES = #()
			append LAYER_NODES theRoot
		) else (
			if not FLAT_MODE then (
				theRoot = tv.Nodes.add "ルート"				
				theRoot.nodeFont = _OFF_FONT
				theRoot.imageIndex = 5
			)
		)
		rootNodes = for o in objects where o.parent == undefined collect o

		-- load color information
		-- TODO dont need to reload the cache every single time!
		load_color_cache()

		-- add to tree
		tv.beginUpdate()
		if TV_MODE == "layer" or TV_MODE == "detail" then (

			-- LAYER MODE TESTING
			layerNodes_filtered = #()
			for i = 0 to layerManager.count-1 do
			(
				ilayer = layerManager.getLayer i
				layerName = ilayer.name
				append layerNodes_filtered ilayer
			)

			add_layer_children tv layerNodes_filtered

			-- ADD OBJECTS TO LAYER
			if TV_MODE == "detail" then (
				add_obj_children tv rootNodes
			)

		) else (
			-- THIS IS THE NON LAYER CASE
			addChildren tv theRoot rootNodes
		)
		tv.endUpdate()
	)

	----- ----- -----
	-- refresh button
	fn refreshTreeView tv = (
		tv.FullRowSelect = true
		tv.HideSelection = false
		tv.Nodes.Clear()
		fillInTreeView tv
		tv.ExpandAll()
		if TV_MODE == "layer" or TV_MODE == "detail" then (
			for ln in LAYER_NODES do (
				try (
					if ln.text == "0 (default)" do
						ln.collapse()
				) catch ( )
			)
		)
		tag_search tv
	)

	-- controls ---------------------------------
	group "コントロール" (
		button btn_refresh "Refresh" \
		toolTip: "refreshes the screen" \
		align: #left width:60 across: 3

		button btn_export "Export" \
		toolTip: "exports the selected objects" \
		align: #left width:60 across: 3

		button btn_order "Order" \
		toolTip: "Sorts the tree" \
		align: #left width:60 across: 3

		button btn_summary "Collapse" \
		align: #left  width:50 across:4

		button btn_all "Expand" \
		align: #left  width:50 across:4

		button btn_filter "Filter" \
		align: #left  width:50 across:4

		button btn_select "Select" \
		align: #left  width:50 across:4
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
		try (DestroyDialog select_rollout) catch()

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
	-- special select button
	on btn_select pressed do (
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()
		try (DestroyDialog select_rollout) catch()

		-- local mousepoint = dotNetObject "System.Drawing.Point" arg.x arg.y
		local dialog_pos = GetDialogPos treeview_rollout
		--local posx = dialog_pos.x + mousepoint.X + 30
		--local posy = dialog_pos.y + mousepoint.Y + 30
		local posx = dialog_pos.x - 30 + _TV_WIDTH
		local posy = dialog_pos.y - 50 + _TV_HEIGHT
		CreateDialog select_rollout ((_COLOR_BTN_SIZE*2)+2)\
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
		if TV_MODE != "layer" and TV_MODE != "detail" do 
			tv.TopNode.Expand()
	)

	on btn_all pressed do (
		CURRENT_FILTER = "all"
		FLAT_MODE = false
		tv.ExpandAll()
		if TV_MODE != "layer" and TV_MODE != "detail" then (
			for ln in LAYER_NODES do (
				try (
					if ln.text == "0 (default)" do
						ln.collapse()
				) catch ( )
			)
		)
	)

	-- mode ---------------------------------
	group "モード" (
		checkbutton modeSummary "Summary" width:60 across:4 checked:true
		checkbutton modeLayer "Layer" width:60 across:4 checked:false
		checkbutton modeGroup "Scene" width:60 across:4 checked:false
		checkbutton modeObject "Object" width:60 across:4 checked:false
		checkbutton modeAll "All" width:60 across:3 checked:true
		checkbutton modeColor "Color" width:60 across:3 checked:false
		checkbutton modeWhite "White" width:60 across:3 checked:false
		-- slider slr_width "Tree Width" range:[100,1000,_E_ROLLOUT_WIDTH] type:#integer orient:#horizontal width:200
	)

	----- ----- -----
	-- checkbutton states
	on modeSummary changed theState do (
		print "modeSummary was pressed"
		print TV_MODE
		if TV_MODE != "layer" and modeSummary.checked then (
			CURRENT_FILTER = "all"
			FLAT_MODE = false
			if modeLayer.checked do
				modeLayer.checked = false
			if modeGroup.checked do
				modeGroup.checked = false
			if modeObject.checked do
				modeObject.checked = false
			TV_MODE = "layer"
			refreshTreeView tv
			--TV_MODE = "layer"
			--modeLayer.checked = true
		)
	)

	on modeLayer changed theState do (
		print "modeLayer was pressed"
		print TV_MODE
		if TV_MODE != "detail" and modeLayer.checked then (
			CURRENT_FILTER = "all"
			FLAT_MODE = false
			if modeSummary.checked do
				modeSummary.checked = false
			if modeGroup.checked do
				modeGroup.checked = false
			if modeObject.checked do
				modeObject.checked = false
			TV_MODE = "detail"
			refreshTreeView tv
		)
	)

	on modeGroup changed theState do (
		print "modeGroup was pressed"
		print TV_MODE
		if TV_MODE != "group" and modeGroup.checked then (
			CURRENT_FILTER = "all"
			FLAT_MODE = false
			if modeSummary.checked do
				modeSummary.checked = false
			if modeLayer.checked do
				modeLayer.checked = false
			if modeObject.checked do
				modeObject.checked = false
			TV_MODE = "group"
			refreshTreeView tv
			--TV_MODE = "group"
			--modeGroup.checked = true
		)
	)

	on modeObject changed theState do (
		print "modeObject was pressed"
		print TV_MODE
		if TV_MODE != "object" and modeObject.checked then (
			CURRENT_FILTER = "all"
			FLAT_MODE = true
			if modeSummary.checked do
				modeSummary.checked = false
			if modeLayer.checked do
				modeLayer.checked = false
			if modeGroup.checked do
				modeGroup.checked = false			
			TV_MODE = "object"
			refreshTreeView tv
			-- TV_MODE = "object"
			-- modeObject.checked = true
		)
	)

	on modeAll changed theState do (
		print "modeAll was pressed"
		CURRENT_FILTER = "all"
		modeAll.checked = true
		modeColor.checked = false
		modeWhite.checked = false
		VIEW_STYLE = "none"
		refreshTreeView tv
	)

	on modeColor changed theState do (
		print "modeColor was pressed"
		CURRENT_FILTER = "all"
		modeAll.checked = false
		modeColor.checked = true
		modeWhite.checked = false
		VIEW_STYLE = "color"
		refreshTreeView tv
	)

	on modeWhite changed theState do (
		print "modeWhite was pressed"
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

	-- option to refresh the tree
	fn refresh_tree_externally = (
		treeview_rollout.refreshTreeView(tv)
	)

	-- call functions on open
	on treeview_rollout open do (
		try (
			initTreeView tv
			refreshTreeView tv
		) catch ()
		KAGE_MAIN.setTreeInst tv
	)

	on treeview_rollout close do (
		KAGE_MAIN.close_kage()
	)

	on treeview_rollout help do (
		print "help requested which refreshes the callout"
		refreshTreeView tv
	)

	-- TEST ---------------------------------
 	button TEST_ME "TEST" width:60 across:3
 	on TEST_ME pressed do (
 		tag_search tv
 	)

	-- HANDLERS
	-- add event handler to select the object if user clicks on node
	-- have to get node under mouse cursor, then select using the MXS tag
	on tv Click arg do (
		CALLBACKS_MODE = false
		if arg.button == tv.mousebuttons.right then(
			-- RIGHT CLICK - bring up color menu
			KAGE_HITNODE = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			try (
				try (DestroyDialog submenu_rollout) catch()
				try (DestroyDialog export_rollout) catch()
				try (DestroyDialog filter_rollout) catch()
				try (DestroyDialog select_rollout) catch()
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
			
			-- print "start variable tests"
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
		CALLBACKS_MODE = true
	)

	fn recursive_select my_node = (
		nodes = my_node.Nodes
 		for i = 0 to (nodes.count-1) do ( 				
			try (
				selectmore nodes.item[i].tag.value
			) catch ()
			recursive_select nodes.item[i]
		)
	)

	on tv DoubleClick arg do (
		print "there was a double click" 		
 		if TV_MODE == "detail" then (
	 		if tv.selectedNode.imageIndex == 2 then (
	 			disableSceneRedraw() 
	 			max select none
	 			recursive_select tv.selectedNode
	 			enableSceneRedraw() 
	 		)
	 	)

 		if TV_MODE == "layer" then (
 			modeLayer.checked = true
 			CURRENT_FILTER = "all"
			FLAT_MODE = false
			if modeSummary.checked do
				modeSummary.checked = false
			if modeGroup.checked do
				modeGroup.checked = false
			if modeObject.checked do
				modeObject.checked = false
			TV_MODE = "detail"
			refreshTreeView tv
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

	on treeview_rollout resized val do (
		format "rollout: %\n" val
		tv.width = (val.x - _ROLLOUT_WIDTH + _TV_WIDTH)
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_width" val.x
		tv.height = (val.y - _ROLLOUT_HEIGHT + _TV_HEIGHT)
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_height" val.y
	)

	on tv Close arg do(
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()
		try (DestroyDialog select_rollout) catch()
	)

	on treeview_rollout close do (
		try (DestroyDialog treeview_rollout) catch()
		try (DestroyDialog submenu_rollout) catch()
		try (DestroyDialog export_rollout) catch()
		try (DestroyDialog filter_rollout) catch()
		try (DestroyDialog select_rollout) catch()
		KAGE_CALLBACKS.removeCallbacks()
		KAGE_STATUS.is_open = false
		print "kage was closed"
	)

-- end main rollout
)


struct KageStatus (
	is_open,

	function reset = (
		is_open = false
	),

	on create do ( 
      reset()
    )
)


struct KageMain (

tree,
scene,
kbdFile,  --not working?
 
function setTreeInst tv = (
   tree = tv
),

function open_kage = (
	-- 1. end previous rollouts
	try (DestroyDialog treeview_rollout) catch()
	try (DestroyDialog submenu_rollout) catch()
	try (DestroyDialog export_rollout) catch()
	try (DestroyDialog filter_rollout) catch()
	try (DestroyDialog select_rollout) catch()

	-- 2. load user settings
	try (
		user_set_width = ReadFromIni PRODUCT_INFO_INI "settings" "main_width"
		format "user set width: %\n" (user_set_width as string)
		if user_set_width != "none" do (
			_ROLLOUT_WIDTH = (user_set_width as Integer)
			_TV_WIDTH = _ROLLOUT_WIDTH - 10;
		)

		user_set_height = ReadFromIni PRODUCT_INFO_INI "settings" "main_height"
		format "user set height: %\n" (user_set_height as string)
		if user_set_height != "none" do (
			_ROLLOUT_HEIGHT = (user_set_height as Integer)
			_TV_HEIGHT = _ROLLOUT_HEIGHT - 165;
		)
	) catch (
		print "error loading settings"
	)

	-- 3. check for settings folder
	if maxFilePath == "" then (
		messageBox "Unable to load settings, max file not saved"
	) else (
		SETTINGS_FILE_LOCATION = maxFilePath + @"\settings"
		makeDir SETTINGS_FILE_LOCATION
		TREE_INI = SETTINGS_FILE_LOCATION + @"\kage_tree.ini"
	)

	if SETTINGS_FILE_LOCATION != "" then (
		-- 4. check for settings file
		CreateIniFile TREE_INI

		-- 5. check for color settings file
		InitColorSettings(SETTINGS_FILE_LOCATION)
	)

	-- 6. create new dialog
	CreateDialog treeview_rollout \
		_ROLLOUT_WIDTH\
	 	_ROLLOUT_HEIGHT\
	 	style:#(#style_toolwindow, #style_sysmenu, #style_resizing)

	-- 7. callbacks
	KAGE_CALLBACKS.createCallbacks()
	

	KAGE_STATUS = KageStatus()
	KAGE_STATUS.is_open = true
),

function close_kage = (
	try (DestroyDialog treeview_rollout) catch()
	try (DestroyDialog submenu_rollout) catch()
	try (DestroyDialog export_rollout) catch()
	try (DestroyDialog filter_rollout) catch()
	try (DestroyDialog select_rollout) catch()

	KAGE_CALLBACKS.removeCallbacks()

	KAGE_STATUS.is_open = false
)

-- END STRUCT
)