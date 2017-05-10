/*
To Open Rollout UI, Just run this script
*/

_FIRST_OBJ_NAME = ""
_OBJECTS_TO_EXPORT = 0
_SAVE_LOCATION = ""

fn LoadMappingFiles loc = (
	-- do something for each mapping reference
	refFiles = #()
	for bmt in getClassInstances bitmaptex do
	(
		-- get reference info
		fpath = bmt.filename
		if fpath == undefined then (
			print "this path is not defined"
		) else (
			fname = ""
			paths = filterString fpath "\\"
			for p in paths do (
				fname = p as string
			)
			append refFiles fname
			
			-- check if reference is valid
			fpath_exists = doesFileExist fpath
			fstatus = "FOUND"
			if fpath_exists == false then (
				fpath_exists = doesFileExist (maxFilePath + fpath)
				if fpath_exists == false then (
					fstatus = "MISSING"
				)
			)
			
			-- copy files
			print fstatus
			if fstatus == "FOUND" then (
				full_fpath = maxFilePath + fpath
				print full_fpath
				new_path = loc + "\\" + fname
				print new_path
				copyFile full_fpath new_path
			)
		)
	)
)


fn get_friendly_name filename = (
	-- creates a more save-friendly filename
	friendly_name_a = substituteString filename " " "_"
	friendly_name_b = toLower friendly_name_a
	friendly_name_c = substituteString friendly_name_b ":" "_"
	friendly_name_d = substituteString friendly_name_c "\\" "_"
	friendly_name = substituteString friendly_name_d "/" "_"
	return friendly_name
)



rollout export_rollout "Export Options" (

	-- UI
	-- SAVETO Options
	group "保存先" (
		checkbox ck_export_desktop "Desktop" across:2 checked:true
		checkbox ck_export_shared "Shared Drive" across:2 checked:false
	)

	-- project info label
	label lbl_name " " align:#left
	label lbl_objcount " " align:#left
	label lbl_location " " align:#left

	-- CheckBox Handler
	on ck_export_desktop changed theState do (
		ck_export_shared.state = not ck_export_shared.state
		if ck_export_shared.checked then (
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test")
		) else (
			_SAVE_LOCATION = (@"C:\Users\" + sysInfo.username + @"\Desktop")
			placebo = @"\"
		)
		lbl_location.text = _SAVE_LOCATION
	)
	on ck_export_shared changed theState do (
		ck_export_desktop.state = not ck_export_desktop.state
		if ck_export_shared.checked then (
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test")
		) else (
			_SAVE_LOCATION = (@"C:\Users\" + sysInfo.username + @"\Desktop")
			placebo = @"\"
		)
		lbl_location.text = _SAVE_LOCATION
	)

	-- CANCEL BUTTON
	button btn_close "戻る" align:#center width:50 height:30 across:2
	on btn_close pressed do (
		try (DestroyDialog export_rollout) catch ()
	) 

	-- EXPORT BUTTON
	button btn_process "Export" align:#center width:50 height:30 across:2

	on btn_process pressed do (
		-- check if dir exists
		friendly_name = get_friendly_name(_FIRST_OBJ_NAME)
		file_path = _SAVE_LOCATION + "\\" + friendly_name
		export_is_valid = not doesFileExist(file_path)

		if export_is_valid then (
			-- make folder
			print "file_path"
			print file_path
			makeDir file_path

			-- make map directory
			map_path = file_path + @"\map"
			print "map_path"
			print map_path
			makeDir map_path
			
			-- save selection as
			file_name = file_path + "\\" + friendly_name
			print "creating this file"
			print file_name
			saveNodes selection file_name -- quiet:true
			
			-- complete
			shellLaunch "explorer.exe" file_path
			try (DestroyDialog export_rollout) catch ()

			-- copy mapping files
			LoadMappingFiles map_path

		) else (
			-- folder already exists
			try (DestroyDialog export_rollout) catch ()
			messageBox ("Export Failed.\n\n" + \
                file_path + " already exists.") title:"Export Error";

		)
	)

	-- FUNCTIONS
	-- funct for save location
	fn update_location = (
		if ck_export_shared.checked then (
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test")
		) else (
			_SAVE_LOCATION = (@"C:\Users\" + sysInfo.username + @"\Desktop")
			placebo = @"\"
		)
		lbl_location.text = _SAVE_LOCATION
	)


	-- ROLLOUT
	-- On Open, check object export information
	on export_rollout open do (
		_FIRST_OBJ_NAME = ""
		_OBJECTS_TO_EXPORT = 0
		for obj in selection do (
			-- showProperties obj
			if _FIRST_OBJ_NAME == "" then (
				_FIRST_OBJ_NAME = obj.name
			)
			_OBJECTS_TO_EXPORT += 1
		)

		friendly_name = get_friendly_name(_FIRST_OBJ_NAME as string)
		print (friendly_name + " will be exported")
		print ((_OBJECTS_TO_EXPORT as string) + " Objects")

		lbl_name.text = friendly_name as string
		lbl_objcount.text = (_OBJECTS_TO_EXPORT as string) + " Objects" 
		update_location()
	)
)