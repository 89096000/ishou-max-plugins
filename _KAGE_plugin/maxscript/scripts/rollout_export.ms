/*
To Open Rollout UI, Just run this script
*/

_FIRST_OBJ_NAME = ""
_OBJECTS_TO_EXPORT = 0
_SAVE_LOCATION = ""

MAX_FILE_LOC = @"\\IMPORT-3\share1\00_Test\ishoukeikaku_3dmax_tool\latest"

fn LoadMappingFiles loc = (
	-- do something for each mapping reference
	return_string = "\nMAPPING FILES:"

	-- BEGIN MAPPING FILE PROCESS
	-- figure out map files with reference id
	selectedMats = for o in selection where o.mat != undefined collect o
	x = 1
	materialsUsed = #()
	usedMaterialsList = #()
	nonMultiObjects = #()

	-- STEP 1
	for obj in selectedMats do (
		if classof obj.material == MultiMaterial  then (
			-- MULTIMATERIAL classes behave differently as they are mapped to a multimaterial mapping object
			--  the mapping object might contain a lot of different ref files but only some are used
			--  VRAY might be required for debugging
			format "% IS multimaterial object\n" obj.name
			
			faces = getNumFaces obj
			maxIndex = faces
			if faces > 24 do maxIndex = 24
			for i = 1 to maxIndex do (
				refId = getFaceMatID obj.mesh i
				appendIfUnique materialsUsed refId
				if i == 1 do format "%|%. % - % (% faces)\n" x i obj.name refId faces
				x += 1
			)
			
			format "There are % materials used!\n" materialsUsed.count
			
			myMatID = 1
			for om in obj.material.materialList do (
				exists = finditem materialsUsed myMatID
				if exists > 0 do (
					try (
						format "ID % : % has multiMATERIAL %\n" myMatID obj.name om.name
						numMaps = getNumSubTexmaps om
						print numMaps
						firstMap = getSubTexmap om 1
						print firstMap.filename
						appendIfUnique usedMaterialsList firstMap.filename
					) catch()
				)
				myMatID += 1
			)
			
		) else (
			
			-- nonmultimaterial objects get processed in step 2
			format "% is not a multimaterial object\n" obj.name
			appendIfUnique nonMultiObjects obj		
		)
	)

	-- STEP 2
	-- THIS IS SCRIPT FOR NON MATERIAL OBJECT
	for bmt in getClassInstances bitmaptex do (
		for nmo in nonMultiObjects do (
			exists = finditem (refs.dependentNodes bmt) nmo
			if exists > 0 do (
				format "Texture % is used in selected Object %\n" bmt.filename nmo.name
				appendIfUnique usedMaterialsList bmt.filename
			)
		)
	)

	-- STEP 3 COPY EACH PATH LOCALLY
	format "THERE ARE % MAPPING FILES!\n" usedMaterialsList.count
	u = 1
	for fpath in usedMaterialsList do (
		format "% : %\n" u fpath
		u += 1
		fname = filenameFromPath fpath

		-- check if reference is local or on network
		lstatus = "LOCAL PATH"
		if (fpath[1] == "/" or fpath[1] == "\\") then (
			lstatus = "NETWORK PATH"
		) else if (substring fpath 1 6) == "import" then (
			lstatus = "IMPORT PATH"
		)

		-- figure out the path to the file
		if lstatus == "LOCAL PATH" then (
			full_fpath = (maxFilePath + fpath)
		) else (
			full_fpath = fpath
		)

		-- check if reference is valid
		fpath_exists = doesFileExist fpath
		fstatus = "FOUND"
		if fpath_exists == false then (
			fpath_exists = doesFileExist full_fpath
			if fpath_exists == false then (
				fstatus = "MISSING"
			)
		)
		return_string += "\n" + fname + " - " + fstatus

		-- create a copy to location
		new_path = loc + "\\" + fname				
		print (fstatus + " file with on " + lstatus)
		print ("copy from : " + full_fpath)
		print ("copy to : " + new_path)

		-- change set path
		for bmt in getClassInstances bitmaptex do (
			if bmt.filename == fpath do (
				bmt.filename = new_path
			)
		)

		-- copy files				
		if fstatus == "FOUND" then (
			copyFile full_fpath new_path
		)

	)

/*		THIS IS THE OLD METHOD WHICH DOESNT ACCOUNT FOR PROJECT LEVEL MULTIMATERIAL OBJECTS
	-- loop through bitmaps
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
			print ("ref file: " + fname + " @ " + fpath)

			-- check if this texture is actually referenced within selected objects
			used = false
			for mapObj in refs.dependentNodes bmt do (
				for obj in selection do (
					if obj.name == mapObj.name do (
						format "Texture % is used in selected Object %\n" obj.name mapObj.name
						used = true
					)
				)
			)

			-- sometimes reference files are empty
			if fname != "" and used then (
				-- check if reference is local or on network
				lstatus = "LOCAL PATH"
				print fpath
				print fpath[1] as string
				if (fpath[1] == "/" or fpath[1] == "\\") then (
					lstatus = "NETWORK PATH"
				) else if (substring fpath 1 6) == "import" then (
					lstatus = "IMPORT PATH"
				)

				-- figure out the path to the file
				if lstatus == "LOCAL PATH" then (
					full_fpath = (maxFilePath + fpath)
				) else (
					full_fpath = fpath
				)
				
				-- check if reference is valid
				fpath_exists = doesFileExist fpath
				fstatus = "FOUND"
				if fpath_exists == false then (
					fpath_exists = doesFileExist full_fpath
					if fpath_exists == false then (
						fstatus = "MISSING"
					)
				)
				return_string += "\n" + fname + " - " + fstatus

				-- create a copy to location
				new_path = loc + "\\" + fname				
				print (fstatus + " file with on " + lstatus)
				print ("copy from : " + full_fpath)
				print ("copy to : " + new_path)

				-- copy files				
				if fstatus == "FOUND" then (
					copyFile full_fpath new_path
				)
			)
		)
	)
*/

	return return_string
)


fn copy_ms_file file_path file_sub_path friendly_name = (
	max_file_included = true
	try (
		ms_file = ""
		ms_filename = ""
		for f in getFiles (MAX_FILE_LOC + "\\*.*") do (
			print f as string
			ms_file = f
			ms_filename = filenameFromPath ms_file
		)

		if ms_file != "" then (
			new_ms_file = (file_path + "\\" + ms_filename)
			copyfile ms_file new_ms_file

			-- edit max file with new project info
			local lines = (dotNetClass "System.IO.File").ReadAllLines new_ms_file
			deleteItem lines 6
			deleteItem lines 5
			deleteItem lines 4
			deleteItem lines 3
			deleteItem lines 2
			deleteItem lines 1

			local newlines = #()
			append newlines ("projectName = @\"" + friendly_name + "\"")
			append newlines ("projectDir = @\"" + file_sub_path + "\"")
			join newlines lines

			(dotNetClass "System.IO.File").WriteAllLines new_ms_file newlines
		) else (
			max_file_included = false
			print "ms_file could not be found"
		)
	) catch (
		max_file_included = false
		print "max file copy failed"
	)
	return max_file_included
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
	group "データ" (
		label lbl_name " " align:#left
		label lbl_location " " align:#left
		edittext txt_filename "ファイル名前:" fieldWidth:225 height: 18 labelOnTop:false
		edittext txt_desc "ファイル説明:" fieldWidth:225 height: 36 labelOnTop:false
	)

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
			_SAVE_LOCATION = (@"\\IMPORT-3\share1\00_Test\自動的")
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
		-- friendly_name = get_friendly_name(_FIRST_OBJ_NAME)
		friendly_name = txt_filename.text
		file_path = _SAVE_LOCATION + "\\" + friendly_name
		file_sub_path = file_path + "\\新しいフォルダー"
		export_is_valid = not doesFileExist(file_path)

		if export_is_valid then (
			-- make folder
			print ("file_path : " + file_sub_path)
			makeDir file_sub_path

			-- make map directory
			map_path = file_sub_path + @"\map"
			print ("map_path : " + map_path)
			makeDir map_path
			
			-- save current list of mapping file paths
			og_map_paths = #()
			for bmt in getClassInstances bitmaptex do (
				append og_map_paths bmt.filename
			)

			-- copy mapping files
			mapping_files = LoadMappingFiles map_path

			-- save selection as
			file_name = file_sub_path + "\\" + friendly_name
			print ("creating this file : " + file_name)
			saveNodes selection file_name -- quiet:true

			-- restore mapping file paths
			p = 1
			for bmt in getClassInstances bitmaptex do (
				bmt.filename = og_map_paths[p]
				p += 1
			)

			-- create description text file
			description = txt_desc.text
			readme = file_path + "\\readMe.txt"
			ts = getLocalTime()
			f = (openFile readme mode:"a")
			format "%\n" friendly_name to:f
			format "%年%月%日 %:%:%\n" ts[1] ts[2] ts[4] ts[5] ts[6] ts[7] to:f
			format "%\n" description to:f
			format "%\n" file_path to:f
			format "%\n" mapping_files to:f
			close f	

			-- try to copy the maxscript file from shared drive
			maxscript_did_copy = copy_ms_file file_path file_sub_path friendly_name
			print maxscript_did_copy as string

			-- complete
			shellLaunch "explorer.exe" file_path
			try (DestroyDialog export_rollout) catch ()

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
		print ((_OBJECTS_TO_EXPORT as string) + " objects found")
		name_desc = friendly_name + " (" + ((_OBJECTS_TO_EXPORT as string) + "個") + ")"

		lbl_name.text = name_desc
		txt_filename.text = friendly_name
		update_location()
	)
)