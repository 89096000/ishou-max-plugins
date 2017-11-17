/*
To Open Rollout UI, Just run this script
*/

-- Name
_MAIN_ROLLOUT_NAME = "意匠計画の影"
_VERSION = kageTools.getVersion asString:true

-- Rollout Settings
_DEFAULT_INDENT = 13;
_ROLLOUT_WIDTH = 250;
_ROLLOUT_HEIGHT = 600;
_ROLLOUT_X_POS = 0;
_ROLLOUT_Y_POS = 0;

_btnvertpadding = 20
_btnvertspacing = 5
_btnhoripadding = 10
_btnhorispacing = 5
_btnheight = 25
_btnwidth = 70

_option_start = 5
_option_height = 87
_control_start = 5 + (55*2)
_control_height = 87
_tool_start = 5 + (50*2) + (55*2)
_tool_height = 46
_template_start = 5 + (50*2) + (55*3)
_template_height = 70

-- Export Rollout
_E_ROLLOUT_WIDTH = 340;
_E_ROLLOUT_HEIGHT = 200;

-- Save Settings
SETTINGS_FILE_LOCATION = ""

-- TIMERS
_DIALOG_PREVENT_TIMER = dotNetObject "System.Windows.Forms.Timer";

-- FUNCTIONS

-- returns a position
fn returnPos xpos ypos starting_pos = (
	xval = _btnhoripadding + ((_btnhorispacing+_btnwidth)*(xpos-1))
	yval = _btnvertpadding + ((_btnvertspacing+_btnheight)*(ypos-1)) + starting_pos
	return [xval, yval]
)

-- kills secondary rollouts
fn killRollouts = (
	try (DestroyDialog tree_rollout) catch()
	try (DestroyDialog submenu_rollout) catch()
	try (DestroyDialog export_rollout) catch()
	try (DestroyDialog filter_rollout) catch()
	try (DestroyDialog select_rollout) catch()
	try (DestroyDialog import_rollout) catch()
	try (DestroyDialog clone_rollout) catch()
)

-- DragNDrop functionality
fn load_image_to_plane f = (
	if (doesFileExist f) do (
		-- SAVE MAPPING FILE LOCALLY
		if maxFilePath == "" then (
			print "max file not saved, no directory to save mapping file to\n"
			new_path = f
		) else (
			paths = filterString f "\\"
			imgName = ""
			for p in paths do (
				imgName = p as string
			)
			map_folder = pathConfig.removePathLeaf maxFilePath
			map_folder += ("\\" + "2_map" + "\\")

			try(
				map_folder2 = pathConfig.removePathLeaf maxFilePath
				map_folder2 = pathConfig.removePathLeaf map_folder2
				map_folder2 += ("\\" + "2_map" + "\\")
			) catch (
				map_folder2 = "-x-"
			)

			try(
				map_folder3 = pathConfig.removePathLeaf maxFilePath
				map_folder3 = pathConfig.removePathLeaf map_folder3
				map_folder3 = pathConfig.removePathLeaf map_folder3
				map_folder3 += ("\\" + "2_map" + "\\")
			) catch (
				map_folder3 = "-x-"
			)

			local_path = ""
			if (doesFileExist map_folder) then (
				local_path = map_folder
			) else if (doesFileExist map_folder2) then (
				local_path = map_folder2
			) else if (doesFileExist map_folder3) then (
				local_path = map_folder3
			) else (
				local_path = maxFilePath + "import" + "\\"
			)
			
			print local_path
			makeDir local_path
			new_path = local_path + imgName
			format "file from %\n" new_path
			format "saving %\n" f
			copyFile f new_path
		)

		-- ADD FILE				
		bmt = BitmapTexture filename:new_path
		difMap = bmt
		theMat = Standard  twosided:true naerm:(uniqueName "Ref_Plane_Mat") showInViewport:true
		theMat.diffuseMap = difMap
		map_scale = 0.100
		if pbRatio.selected == "90%" then (
			map_scale = 0.090
		) else if pbRatio.selected == "80%" then (
			map_scale = 0.080
		) else if pbRatio.selected == "70%" then (
			map_scale = 0.070
		) else if pbRatio.selected == "60%" then (
			map_scale = 0.060
		) else if pbRatio.selected == "50%" then (
			map_scale = 0.050
		) else if pbRatio.selected == "40%" then (
			map_scale = 0.040
		) else if pbRatio.selected == "30%" then (
			map_scale = 0.030
		) else if pbRatio.selected == "20%" then (
			map_scale = 0.020
		) else if pbRatio.selected == "10%" then (
			map_scale = 0.010
		)
		format "mapping file scale picked as %\n" map_scale
		pln = Plane width:(bmt.bitmap.width*map_scale) length:(bmt.bitmap.height*map_scale) material:theMat lengthsegs:1 widthsegs:1
		pln.name = "Template"
		rotate pln (angleaxis 90 [1,0,0])
		-- add map
		m = uvwmap() 
		m.maptype = 5
		addModifier pln (copy m)
		select pln
	)
)

rollout main_rollout (_MAIN_ROLLOUT_NAME + " V" + _VERSION) (

	-- options ---------------------------------
	checkbox chkAutoOpen "影を自動に開く"
	toolTip: "automatically opens kage" \
	pos:(returnPos 1 1 _option_start)
	checkbox chkRenameMaterials "スレートマテリアルの自動にレネーム"
	toolTip: "automatically renames slate material editor" \
	pos:(returnPos 1 2 _option_start)
	groupBox grpOptions "オプション" \
	pos:[5,_option_start] \
	width:(_ROLLOUT_WIDTH-_btnhoripadding) \
	height: _option_height

	-- controls ---------------------------------
	button btn_import "インポート" \
	toolTip: "import an object into project" \
	pos:(returnPos 1 1 _control_start) \ 
	align: #left width:_btnwidth
	button btn_export "エクスポート" \
	toolTip: "exports the selected objects" \
	pos:(returnPos 2 1 _control_start) \ 
	align: #left width:_btnwidth
	button btn_tree "エクスポーローラ" \
	toolTip: "shows scene explorer" \
	pos:(returnPos 1 2 _control_start) \ 
	align: #left width:(_btnwidth*2)
	groupBox grpControls "コントロール" \
	pos:[5,_control_start] \
	width:(_ROLLOUT_WIDTH-_btnhoripadding) \
	height: _control_height

	-- TOOLS
	--   clone tool
	checkbutton preventCloneDialog "クローンダイアログ停止" \
	toolTip: "automatically closes clone dialog" \
	pos:(returnPos 1 1 _tool_start) \
	width: (_btnwidth*2)
	dropdownlist cloneType "" items:#("Copy", "Instance", "Reference") \
	toolTip: "select default for clone dialog" \
	pos:(returnPos 3 1 _tool_start) \
	width: _btnwidth
	groupBox grpTools "ツール" \
	pos:[5,_tool_start] \
	width:(_ROLLOUT_WIDTH-_btnhoripadding) \
	height: _tool_height

	--   drag drop image
	dotNetControl pb "System.Windows.Forms.PictureBox" \
	pos:(returnPos 1 1 _template_start)
	width: (_btnwidth) \
	height: (_btnheight + 20)
	dropdownlist pbRatio "Drop Mapping File Scale" items:#("100%", "90%", "80%", "70%", "60%", "50%", "40%", "30%", "20%", "10%") \
	toolTip: "Select mapping file import ratio" \
	pos:(returnPos 2 1 _template_start)
	width: (_btnwidth*2)
	groupBox grpTemplate "テンプレート" \
	pos:[5,_template_start] \
	width:(_ROLLOUT_WIDTH-_btnhoripadding) \
	height: _template_height

	----- ----- -----
	-- kage auto-open checkbox
	on chkAutoOpen changed theState do (
		if chkRenameMaterials.checked then (
			OverwriteToIni PRODUCT_INFO_INI "settings" "auto_open" "true"
		) else (
			OverwriteToIni PRODUCT_INFO_INI "settings" "auto_open" "false"
		)
	)

	----- ----- -----
	-- slate material rename checkbox
	on chkRenameMaterials changed theState do (
		if chkRenameMaterials.checked then (
			OverwriteToIni PRODUCT_INFO_INI "settings" "material_rename" "true"
			fileIn "material_map_rename.ms";
		) else (
			OverwriteToIni PRODUCT_INFO_INI "settings" "material_rename" "false"
		)
	)

	----- ----- -----
	-- export button
	on btn_export pressed do (
		killRollouts()
		if selection.count > 0 then (
			-- call the export rollout
			CreateDialog export_rollout _E_ROLLOUT_WIDTH _E_ROLLOUT_HEIGHT \
				style:#(#style_border, #style_sunkenedge)
		) else (
			messageBox "オブジェクトをセレクトしてください"
		)
	)

	----- ----- -----
	-- import button
	on btn_import pressed do (
		killRollouts()
		local dialog_pos = GetDialogPos main_rollout
		local posx = dialog_pos.x - 250 + _TV_WIDTH
		local posy = dialog_pos.y - 250 + _TV_HEIGHT
		CreateDialog import_rollout 350\
									450\
									pos:[posx, posy] \
                                    style:#(#style_border);
	)

	----- ----- -----
	-- treeview button
	on btn_tree pressed do (
		KAGE_TREE.open_tree()
	)

	-- prevent clone dialog
	fn onTick = (
		try (
			child = (windows.getChildHWND 0 "Clone Options" parent:#max)
			if child == undefined do child = (windows.getChildHWND 0 "クローン オプション" parent:#max)
			if child != undefined do (
				if cloneType.selected == "Instance" then (
					nihongoCloneOpt = "インスタンス"
				) else if cloneType.selected == "Reference" then (
					nihongoCloneOpt = "参照"
				) else (
					nihongoCloneOpt = "コピー"
				)

				for btn in (windows.getChildrenHWND child[1]) where (btn[5] == cloneType.selected or btn[5] == nihongoCloneOpt) do UIAccessor.PressButton btn[1]
				for btn in (windows.getChildrenHWND child[1]) where (btn[5] == "OK") do UIAccessor.PressButton btn[1]
			)
		) catch ()
	)

	on preventCloneDialog changed theState do (
		format "preventCloneDialog was pressed for copy type %s\n" cloneType.selected
		if preventCloneDialog.checked then (
			_DIALOG_PREVENT_TIMER.interval = 1
		  	dotnet.addEventHandler _DIALOG_PREVENT_TIMER "tick" onTick
		  	_DIALOG_PREVENT_TIMER.Start()
		) else (
			_DIALOG_PREVENT_TIMER.Stop()
		)
	)

	-- repositions buttons
	fn reposition_buttons = (
		format "repositioning buttons\n"
		-- option buttons
		grpOptions.pos = [5,_option_start]

		-- control buttons
		btn_import.pos = (returnPos 1 1 _control_start)
		btn_export.pos = (returnPos 2 1 _control_start)
		grpControls.pos = [5,_control_start]

		-- tools
		preventCloneDialog.pos = (returnPos 1 1 _tool_start)
		cloneType.pos = (returnPos 3 1 _tool_start)
		grpTools.pos = [5,_tool_start]

		-- template
		pb.pos = (returnPos 1 1 _template_start)
		pbRatio.pos = (returnPos 2 1 _template_start)
		grpTemplate.pos = [5,_template_start]
	)

	on pb Click e do (
		print "picture button clicked"
		f = ""
		try (
			f = getOpenFileName \
				types:"Image Files(*.bmp;*.jpg;*.gif)|*.bmp;*.jpg;*.gif|All files (*.*)|*.*"
				load_image_to_plane(f)
		) catch ( )
	)

	on pb DragOver s e do (
		e.Effect = if e.data.ContainsFileDropList() then e.Effect.Move else e.Effect.None
	)
	on pb DragDrop s e do (
		if e.data.ContainsFileDropList() do (
			print "drag DROPPED"
			data = e.data.GetFileDropList()
			f = data.item[0]
			load_image_to_plane(f)
		)
	)

	-- rollout functions	
	-- call functions on open
	on main_rollout open do (
		user_checked_material_rename = ReadFromIni PRODUCT_INFO_INI "settings" "material_rename"
		format "material_rename: %\n" (user_checked_material_rename as string)
		if user_checked_material_rename == "none" then (
			chkRenameMaterials.checked = false
		) else (
			chkRenameMaterials.checked = user_checked_material_rename == "true"
		)

		user_checked_auto_open = ReadFromIni PRODUCT_INFO_INI "settings" "auto_open"
		format "auto_open: %\n" (user_checked_auto_open as string)
		if user_checked_auto_open == "none" then (
			chkAutoOpen.checked = false
		) else (
			chkAutoOpen.checked = user_checked_auto_open == "true"
		)

		pb_image = (_ICON_DIR + @"\mapping_file_uploader.jpg")
		pb.AllowDrop = on
		pb.image = (dotnetclass "System.Drawing.Image").FromFile(pb_image)
	)

	on main_rollout resized val do (
		format "rollout resized: %\n" val
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_width" val.x
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_height" val.y
		_ROLLOUT_WIDTH = main_rollout.width
		_ROLLOUT_HEIGHT = main_rollout.height

		reposition_buttons()
	)

	on main_rollout moved pos do (
		format "rollout moved: %\n" pos
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_x_pos" pos.x
		OverwriteToIni PRODUCT_INFO_INI "settings" "main_y_pos" pos.y
	)

	on tv Close arg do(
		killRollouts()
	)

	on main_rollout close do (
		KAGE_MAIN.close_kage()
		try (DestroyDialog main_rollout) catch()
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

function open_kage = (
	-- 1. end previous rollouts
	try (DestroyDialog main_rollout) catch()
	killRollouts()

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
		)

		user_set_x = ReadFromIni PRODUCT_INFO_INI "settings" "main_x_pos"
		format "user set x pos: %\n" (user_set_x as string)
		if user_set_x != "none" do (
			_ROLLOUT_X_POS = (user_set_x as Integer)
		)
		
		user_set_y = ReadFromIni PRODUCT_INFO_INI "settings" "main_y_pos"
		format "user set y pos: %\n" (user_set_y as string)
		if user_set_y != "none" do (
			_ROLLOUT_Y_POS = (user_set_y as Integer)
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

	-- 4. create new dialog
	if _ROLLOUT_X_POS > 0 and _ROLLOUT_Y_POS > 0 then (
		CreateDialog main_rollout \
			_ROLLOUT_WIDTH \
		 	_ROLLOUT_HEIGHT \
		 	pos:[_ROLLOUT_X_POS, _ROLLOUT_Y_POS] \
		 	style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
	) else (
		CreateDialog main_rollout \
			_ROLLOUT_WIDTH \
		 	_ROLLOUT_HEIGHT \
		 	style:#(#style_toolwindow, #style_sysmenu, #style_resizing)
	)

	-- 5. callbacks
	KAGE_STATUS = KageStatus()
	KAGE_STATUS.is_open = true
),

function close_kage = (
	try (DestroyDialog main_rollout) catch()
	killRollouts()

	KAGE_CALLBACKS.removeCallbacks()

	KAGE_STATUS.is_open = false
)

-- END STRUCT
)