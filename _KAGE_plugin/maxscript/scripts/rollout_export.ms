/*
To Open Rollout UI, Just run this script
*/

_FIRST_OBJ_NAME = ""
_OBJECTS_TO_EXPORT = 0
_SAVE_LOCATION = ""


rollout export_rollout "Export Options" (

	-- UI
	-- checkbox buttons flip
	group "保存先" (
		checkbox ck_export_desktop "Desktop" across:2 checked:true
		checkbox ck_export_shared "Shared Drive" across:2 checked:false
	)

	-- project info label
	label lbl_name " " align:#left
	label lbl_objcount " " align:#left
	label lbl_location " " align:#left

	-- close box
	button btn_close "戻る" align:#center
	on btn_close pressed do (
		try (DestroyDialog export_rollout) catch ()
	) 


	-- HANDLERS
	on ck_export_desktop changed theState do (
		ck_export_shared.state = not ck_export_shared.state
		if ck_export_desktop.checked then (
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test")
		) else (
			_SAVE_LOCATION = (@"C:\Users\" + sysInfo.username + @"\Desktop")
			placebo = @"\"
		)
		lbl_location.text = _SAVE_LOCATION
	)
	on ck_export_shared changed theState do (
		ck_export_desktop.state = not ck_export_desktop.state
		if ck_export_desktop.checked then (
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test")
		) else (
			_SAVE_LOCATION = (@"C:\Users\" + sysInfo.username + @"\Desktop")
			placebo = @"\"
		)
		lbl_location.text = _SAVE_LOCATION
	)


	-- TEST BUTTON
	button btn_test "TEST" align:#center

	on btn_test pressed do (

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

		print ((_FIRST_OBJ_NAME as string) + " will be exported")
		print ((_OBJECTS_TO_EXPORT as string) + " Objects")

		lbl_name.text = (_FIRST_OBJ_NAME as string) + " Objects"
		lbl_objcount.text = (_OBJECTS_TO_EXPORT as string) + " Objects" 
		update_location()
	)
)