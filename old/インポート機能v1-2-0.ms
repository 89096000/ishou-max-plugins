-- vars (RECOMMENDED)
-- プロジェクトの名前は何でもいいです
-- プロジェクトのパス
-- MAXファイルの名前（このファイルをインポートします）
projectName = "007VintageBed"
projectDir = @"\\IMPORT-3\share1\01_Object\家具_Furniture\ベッド_bed\007_Vintage bed\新しいフォルダー"
maxFN = ""

-- セッチング
doAutoRenameDups = true

-- set projectName if not set manually
-- もしプロジェクト名前がないで、今のフォルダの名前を使えます
if projectName == "" then (
	print sysInfo.currentdir
	print "Project Name not Specified"
	cd = filterString sysInfo.currentdir @"\"
	projectName = cd[cd.count]
	print projectName
)

-- set projectDir if not set manually
-- もしプロジェクトのパスがないで、今のパスを探します
if projectDir == "" then (
	print "Project Directory not Specified"
	childFolders = getDirectories(sysInfo.currentdir + @"\*")
	if childFolders.count == 0 then (
		projectDir = sysInfo.currentdir
	) else if childFolders.count > 1 then (
		hasNewFolder = findItem childFolders (sysInfo.currentdir + "新しいフォルダー")
		if hasNewFolder == true then (
			projectDir = sysInfo.currentdir + "新しいフォルダー"
		) else (
			projectDir = childFolders[1]
		)
	) else (
		projectDir = childFolders[1]
	)
	print projectDir
)

-- set maxFN if not set manually
-- もしMAXファイルをないから、最初のMAXファイルを使っています
if maxFN == "" then (
	print "Max File Name not Specified"
	maxFiles = #()
	join maxFiles (getFiles(projectDir + @"\*.max"))
	if maxFiles.count > 0 then(
		firstMaxFilePath = maxFiles[1]
		firstMaxFilePath_array = filterString firstMaxFilePath @"\"
		maxFN = firstMaxFilePath_array[firstMaxFilePath_array.count]
		print maxFN
	) else (
		maxFN = ""
	)
)

-- static vars
-- 以下のはスクリプトのメッセージです
scriptTitle = "意匠計画MAXScript"
introMsg = "[" + (substituteString projectDir @"\\IMPORT-3\share1" "") + "] からスクリプトがダウンロードされ実行されます。よろしいですか？"
finishMsgFail = "インポートに失敗しました。"
finishMsgSuccess = "インポートに成功しました。"
cancelMsg = "スクリプトは停止されました。"
invalidPathMsg = "ERROR: 先MAXファイルを保存して下さい"
noMaxFileMsg = "ERROR: インポートフォだーはMAXファイル無しです"

-- project vars
-- このシステムのヴァリアブル
--localPath = @"C:\Users\" + sysInfo.username + @"\Documents\3dsMax\import"
localPath = maxFilePath + @"\import"
imgFileNames = #()
imgLocalPaths = #()
missingPaths = #()

-- check if the local path exists, if not create it
-- IMPORTフォルダを作ります
makeDir localPath

-- ask if user would like to continue
-- ウザーの注意ー続ける？
prompt = true
if maxFilePath == "" or maxFN == "" then (
	prompt = false
) else (
	prompt = queryBox introMsg title: scriptTitle
)

-- continue
-- もしウザーは続けたいなら
if prompt == true then (
	
	-- load remote project
	-- MAXファイルを合流します
	mergeDir = projectDir + @"\" + maxFN
	print mergeDir
	importTest = false
	if doAutoRenameDups == true then (
		importTest = mergemaxfile mergeDir #noRedraw #autoRenameDups
	) else (
		importTest = mergemaxfile mergeDir #noRedraw 
	)

	-- if able to import then
	-- もしMAXファイルの合流は成功なら
	if importTest == true then (
		
		-- copy mapping files locally to this folder
		-- プロジェクトフォルダに特別フォルダを作ります
		localDir = localPath + @"\" + projectName
		makeDir localDir
		
		-- get each mapping file off network directory
		-- 全てのイメジファイルを探します（.png/.jpg/.gif） これはMappingファイルです
		wildcardDir = projectDir + @"\*"
		networkDirs = getDirectories(wildcardDir)
		for d in networkDirs do (
			join networkDirs (GetDirectories (d as string + "*"))
		)
		imgFiles = #()
		join imgFiles (getFiles(projectDir + @"\*.png"))
		join imgFiles (getFiles(projectDir + @"\*.jpg"))
		join imgFiles (getFiles(projectDir + @"\*.gif"))
		for f in networkDirs do (
			join imgFiles (getFiles(f + @"*.png"))
			join imgFiles (getFiles(f + @"*.jpg"))
			join imgFiles (getFiles(f + @"*.gif"))
		)
		
		-- copy each file
		-- Mappingファイルをコーピーします
		for m in imgFiles do(
			paths = filterString m "\\"
			imgName = ""
			for p in paths do (
				imgName = p as string
			)
			append imgFileNames imgName
			imgLocalPath = @"import\" + projectName + @"\" + imgName
			append imgLocalPaths imgLocalPath
			new_path = localPath + @"\" + projectName + @"\" + imgName
			print "copying file..."
			print m
			print new_path
			copyFile m new_path
		)
		
		-- do something for each mapping reference
		-- 3DSMaxのMappingパスを直します
		refFiles = #()
		for bmt in getClassInstances bitmaptex do
		(
			-- get reference info
			-- 3DSMaxのMappingパスの情報をくれます
			fpath = bmt.filename
			print fpath
			fname = ""
			paths = filterString fpath "\\"
			for p in paths do (
				fname = p as string
			)
			print fname
			append refFiles fname
			
			-- check if reference is local or on network
			-- このMappingパスはどんなパスですか？
			lstatus = "LOCAL PATH"
			if fpath[1] == @"/" then (
				lstatus = "NETWORK PATH"
			) else if (substring fpath 1 6) == "import" then (
				lstatus = "IMPORT PATH"
			)
			print lstatus
			
			-- check if reference is valid
			-- このMappingパスがあるですか？
			fpath_exists = doesFileExist fpath
			fstatus = "FOUND"
			if fpath_exists == false then (
				fpath_exists = doesFileExist (maxFilePath + fpath)
				if fpath_exists == false then (
					fstatus = "MISSING"
				)
			)
			print fstatus
			
			-- check if reference was one of the files that we copied earlier
			-- プロジェクトの特別フォルダにMappingファイルを合われます
			refStatus = "EXCLUDED"
			fref = findItem imgFileNames fname
			if fref > 0 then (				
				refStatus = "INCLUDED"
				-- if reference is like import/ then we dont need to reset the path
				-- パスは[import/]なら、このパスは大丈夫です
				if lstatus == "IMPORT PATH" then (
					refStatus = "PRIOR INCLUDED"
				) else (
					bmt.filename = imgLocalPaths[fref]
				)					
			) else (
			
				if fstatus == "MISSING" then (
					-- this means the file mapping path is missing
					-- このファイルはプロジェクトフォルダにないです
					append missingPaths bmt.filename
				)
			)
			print refStatus
		)
		
		-- コーピーファイルのパスはないなら、消します
		print "--- CHECK COPIED FILE WAS REFERENCED, DELETE IF NOT ---"
		for img in imgFileNames do(
			print img
			copiedRef = findItem refFiles img
			if copiedRef > 0 then (
				print "this file was used"
			) else (
				--deleteFile copiedRef
				delPath = localPath + @"\" + projectName + @"\" + img
				deleteFile delPath
				print "this file wasnt used -> delete"
			)
		)
			
		-- log list of missing file paths
		if missingPaths.count > 0 then (
			for m in missingPaths do(
				finishMsgSuccess += "\n " + m + "のPATHはダメです"
			)
		) else (
			finishMsgSuccess += "\n 全部のMappingPathsは大丈夫です！"
		)
		
		messageBox finishMsgSuccess
		print finishMsgSuccess
		
	) else (
		
		-- もしMAXファイルの合流は失敗なら
		messageBox finishMsgFail
		print finishMsgFail
	)

) else (
	-- error list
	-- エラー
	if maxFilePath == "" then (
		-- filepath is invalid
		-- ファイルパスはダメ
		messageBox invalidPathMsg
		print invalidPathMsg
	) else if maxFN == "" then (
		-- noMaxFile
		-- MAXファイルは無し
		messageBox noMaxFileMsg
		print noMaxFileMsg		
	) else (
		-- user cancelled
		-- ウザーはスクリプトを停止しました
		messageBox cancelMsg
		print cancelMsg
	)

)


/*
TODO:

VERSION NOTES:
1-1-1 : fix bug with typo in when there are more than 1 folders in the parent folder
1-2-0: dont remap files that are already like import
         remove unnecessary files that werent mapped
	    setting to automatically autorename on by default
*/
