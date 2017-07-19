macroScript toggleKageExport 
	category:"Kage" 
	toolTip:"エクスポート" 
	buttonText:"Open/Close Export"
	icon:#("icon_main", 1)
(
	global KAGE_EXPORT_MAIN;
	global KAGE_EXPORT_STATUS;

	function kage_get_instance =
	(
		if KAGE_EXPORT_MAIN == undefined do
			fileIn ((getDir #userScripts) + "/kage/rollout_export.ms");
	
		KAGE_EXPORT_MAIN;
	)

	on isChecked do 
	(
		if (KAGE_EXPORT_STATUS == undefined or KAGE_EXPORT_STATUS.is_open == false) then
			false;
		else
			KAGE_EXPORT_STATUS.is_open;
	)

	on execute do 
	(
		if KAGE_EXPORT_STATUS == undefined or KAGE_EXPORT_STATUS.is_open == false then (
			print "open kage export"
			CreateDialog export_rollout 340\
				200;
		) else (
			print "close kage export"
			try (DestroyDialog export_rollout) catch()
			KAGE_EXPORT_MAIN = undefined
		)
	)
		
)

