-- this script will localize mapping files
-- for example, a network mapped file will be moved and mapped to the local project
-- the purpose of this script is to save time on loading mapping files off the network

usedNameList = #()
usedPathList = #()

fn localize_mapping_files = (
	-- make sure there is a folder to save mapping files into
	localDir = maxFilePath + "mapping_files" + "\\"
	makeDir localDir

	-- loop through each mapping file
	for bmt in getClassInstances bitmaptex do (
		fpath = bmt.filename

		if fpath != undefined do (
			print fpath
			
			-- check to make sure file name is unique
			newFileName = (getFilenameFile fpath)
			fileExtension = (getFilenameType fpath)
			newPath = localDir + newFileName + fileExtension
			nameExists = (findItem usedNameList newFileName) > 0

			-- if name exists but was previously used path, we can ignore loading this file
			filePathProcessed = (findItem usedPathList fpath) > 0
			if nameExists and filePathProcessed then (
				format "ALREADY PROCESSED - SKIP : %\n" newPath
				
			) else (	
				-- dedupe names
				while nameExists do (
					newFileName += "|"
					newPath = localDir + newFileName + fileExtension
					nameExists = (findItem usedNameList newFileName) > 0
				)
				
				-- save file locally
				if (substring fpath 1 10) != "mapping_fi" do (
					copyFile fpath newPath
					format "%\n" newPath 
				)
				
				-- save used name to avoid future duplicates
				appendIfUnique usedNameList newFileName
				appendIfUnique usedPathList fpath
			)
			
			-- change path to local referenced path
			relLocalPath = "\\mapping_files\\" + newFileName + fileExtension
			bmt.filename = relLocalPath
		) --end check fpath is valid
	)


	-- PART II : Mapping Files

	try (
		curSME = sme.GetView (sme.activeView)
		viewNodeCount = curSME.GetNumNodes()
		smeViewMaterials = for n = 1 to viewNodeCount collect (getActiveViewSME.GetNode n)

		i = 1
		for m in smeViewMaterials do (
			r = trackViewNodes[#sme][(sme.activeView)][i].reference
			b = curSME.GetNodeByRef r
			if superclassof r == material then (
				rtype = "material"
				--m.selected = true
			) else (
				rtype = "textureMap"
				--m.selected = true
			)
			
			if hasProperty r "HDRIMapName" then (
				mapping_file = r.HDRIMapName
			) else (
				mapping_file = ""
			)
			
			if mapping_file != "" do (
				format "NODE INFO\n"
				print m.name
				print m.position
				print r
				print rtype
				print b.name
				print mapping_file
				
				fpath = mapping_file

				newFileName = (getFilenameFile fpath)
				fileExtension = (getFilenameType fpath)
				newPath = localDir + newFileName + fileExtension
				nameExists = (findItem usedNameList newFileName) > 0

				filePathProcessed = (findItem usedPathList fpath) > 0
				if nameExists and filePathProcessed then (
					format "ALREADY PROCESSED - SKIP : %\n" newPath			
				) else (	
					while nameExists do (
						newFileName += "|"
						newPath = localDir + newFileName + fileExtension
						nameExists = (findItem usedNameList newFileName) > 0
					)
					
					if (substring fpath 1 10) != "mapping_fi" do (
						copyFile fpath newPath
						format "%\n" newPath
					)
					
					appendIfUnique usedNameList newFileName
					appendIfUnique usedPathList fpath
				)
				
				relLocalPath = "\\mapping_files\\" + newFileName + fileExtension
				r.HDRIMapName = relLocalPath
			)
			
			i += 1
		)
	) catch ()
)


-- SCRIPT EXECUTION
if maxFilePath == "" then (
	messageBox "まずプロジェクトを保存してください"
) else (
	queryString = "全てのマッピングファイルは「" + maxFilePath + "」にコピーします。続けますか？"
	if queryBox queryString beep:false then (
		localize_mapping_files()
	)
)
