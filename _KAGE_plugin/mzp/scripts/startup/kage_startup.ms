fn kage_startup_duties = 
(
	-- CHECK TO LOAD MATERIAL RENAME SCRIPT

	--format "% --> file opened\n" (maxfilepath + maxfilename)
	product_ini = (GetDir #userScripts) + "/kage_product_info.ini"
	material_rename_script = (GetDir #userScripts) + "/kage/material_map_rename.ms"
	--format "product_ini file loaded\n"

	sect = "settings" 
	k = "material_rename"
	already_there = hasINISetting product_ini sect k
	if already_there then (
		user_checked_material_rename = (getINISetting product_ini sect k)
	) else (
		user_checked_material_rename = "none"
	)

	--format "material_rename: %\n" (user_checked_material_rename as string)
	if user_checked_material_rename == "true" then (
		format "loading material rename script%\n" material_rename_script
		fileIn material_rename_script;
	)

	-- CHECK IF KAGE SHOULD AUTOOPEN
	k = "auto_open"
	already_there = hasINISetting product_ini sect k
	if already_there then (
		user_checked_auto_open = (getINISetting product_ini sect k)
	) else (
		user_checked_auto_open = "none"
	)

	if user_checked_auto_open == "true" then (
		format "auto_open is on"
		macros.run "Kage" "checkKageOpen"
	) else (
		format "auto_open is off"
	)
)
callbacks.removescripts id:#kage_postload
callbacks.addscript #filePostOpenProcess "kage_startup_duties()" id:#kage_postload
