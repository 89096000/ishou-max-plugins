macroScript toggleKageClone 
	category:"Kage" 
	toolTip:"影クローン" 
	buttonText:"Open/Close Clone"
	icon:#("kagemain", 4)
(
	global CLONE_MAIN;
	global KAGE_CLONE_STATUS;

	function kage_get_instance =
	(
		if CLONE_MAIN == undefined do
			fileIn ((getDir #userScripts) + "/kage/rollout_clone.ms");
	
		-- call the main clone struct
		CLONE_MAIN;
	)

	on isChecked do 
	(
		if (KAGE_CLONE_STATUS == undefined or KAGE_CLONE_STATUS.is_open == false) then
			false;
		else
			KAGE_CLONE_STATUS.is_open;
	)

	on execute do 
	(
		local kageInst = kage_get_instance();
		if KAGE_CLONE_STATUS == undefined or KAGE_CLONE_STATUS.is_open == false then (
			print "open kage clone"
			CLONE_MAIN.open_clone()
		) else (
			print "close kage clone"
			CLONE_MAIN.close_clone()
			CLONE_MAIN = undefined
		)
	)
		
)

