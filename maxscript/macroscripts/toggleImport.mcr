macroScript toggleKageImport 
	category:"Kage" 
	toolTip:"インポート" 
	buttonText:"Open/Close Import"
	icon:#("kagemain", 3)
(
	global KAGE_IMPORT_MAIN;
	global KAGE_IMPORT_STATUS;

	function kage_get_instance =
	(
		if KAGE_IMPORT_MAIN == undefined do
			fileIn ((getDir #userScripts) + "/kage/rollout_import.ms");
	
		KAGE_IMPORT_MAIN;
	)

	on isChecked do 
	(
		if (KAGE_IMPORT_STATUS == undefined or KAGE_IMPORT_STATUS.is_open == false) then
			false;
		else
			KAGE_IMPORT_STATUS.is_open;
	)

	on execute do 
	(
		if KAGE_IMPORT_STATUS == undefined or KAGE_IMPORT_STATUS.is_open == false then (
			print "open kage import"
			CreateDialog import_rollout 350\
				450;
		) else (
			print "close kage import"
			try (DestroyDialog import_rollout) catch()
			KAGE_IMPORT_MAIN = undefined
		)
	)
		
)

