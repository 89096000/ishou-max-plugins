macroScript checkKageOpen 
	category:"Kage" 
	toolTip:"Open Kage" 
	buttonText:"Open Kage"
(
	global KAGE_MAIN;
	global KAGE_STATUS;

	function kage_get_instance =
	(
		if KAGE_MAIN == undefined do
			fileIn ((getDir #userScripts) + "/kage/init.ms");
	
		KAGE_MAIN;
	)

	on isChecked do 
	(
		if (KAGE_STATUS == undefined or KAGE_STATUS.is_open == false) then
			false;
		else
			KAGE_STATUS.is_open;
	)

	on execute do 
	(
		local kageInst = kage_get_instance();
		if KAGE_STATUS == undefined or KAGE_STATUS.is_open == false then (
			print "open kage"
			KAGE_MAIN.open_kage()
		)
	)
		
)