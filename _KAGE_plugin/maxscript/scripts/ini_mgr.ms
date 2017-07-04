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
	try (
		RemoveFromIni ini_file sect k
	) catch ()
	setINISetting ini_file sect (k as string) (v as string) forceUTF16:true
)

fn RemoveFromIni ini_file sect k = (
	already_there = hasINISetting ini_file sect k
	if already_there do
		delIniSetting ini_file sect k
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

-- get all keys from a section
fn ReadFromIniSection ini_file sect = (
	already_there = hasINISetting ini_file sect
	if already_there then (
		v = (getINISetting ini_file sect)
	) else (
		v = "none"
	)
	return v
)