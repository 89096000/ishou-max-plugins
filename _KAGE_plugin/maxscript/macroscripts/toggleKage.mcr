macroScript toggleKage 
	category:"Kage" 
	toolTip:"Open/Close Kage" 
	buttonText:"Open/Close Kage"
	icon:#("icon_main", 1)
(
	global kage;
	global kage_status;

	function kage_get_instance =
	(
		if kage == undefined do
			fileIn ((getDir #userScripts) + "/kage/colored-treeview.ms");
	
		kage;
	)

	on isChecked do 
	(
		if (kage_status == undefined OR kage_status.windowOpen == false) then
			false;
		else
			kage_status.windowOpen;
	)
	
	on execute do 
	(
		local kageInst = kage_get_instance();
	)
		
)