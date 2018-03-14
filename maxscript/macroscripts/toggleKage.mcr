macroScript toggleKage 
	category:"Kage" 
	toolTip:"Open/Close Kage" 
	buttonText:"Open/Close Kage"
	icon:#("kagemain", 1)
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
		) else (
			print "close kage"
			KAGE_MAIN.close_kage()
			-- TODO COMMENT BELOW
			--  (NORMALLY WOULD NOT WANT TO REINIT EVERYTHING EACH TIME)
			KAGE_MAIN = undefined
		)
	)
		
)