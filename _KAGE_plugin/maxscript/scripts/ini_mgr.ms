-- PURPOSE of this file is to manage calls to ini files

-- create fn file if not exists
fn CreateIniFile ini_file = (
	has_tree_ini = (dotNetClass "System.IO.File").Exists(ini_file)
	if has_tree_ini == false then (
		f = createFile ini_file
		close f
		free f
	)
)

-- write to ini file but doesnt overwrite
fn WriteToIni ini_file sect k v = (
	already_there = hasINISetting ini_file sect k
	if already_there == false then (
		setINISetting ini_file sect k v forceUTF16:true
	)
)

-- write to ini file and overwrites current setting
fn OverwriteToIni ini_file sect k v = (
	already_there = hasINISetting ini_file sect k
	if already_there == true then (
		delIniSetting ini_file k v
	)
	setINISetting ini_file sect k v forceUTF16:true
)

-- return a specified value
fn ReadFromIni ini_file sect k = (
	already_there = hasINISetting ini_file sect k
	if already_there then (
		v = (getINISetting ini_file sect k)
	) else (
		v = "none"
	)
	return v
)
