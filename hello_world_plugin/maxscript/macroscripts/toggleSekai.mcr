macroScript toggleSekai 
	category:"Sekai" 
	toolTip:"Open/Close Sekai" 
	buttonText:"Open/Close Sekai"
	icon:#("icon_main", 1)
(
	global sekai;
	global sekai_status;

	function sekai_get_instance =
	(
		if sekai == undefined do
			fileIn ((getDir #userScripts) + "/sekai/colored-treeview.ms");
	
		sekai;
	)

	on isChecked do 
	(
		if (sekai_status == undefined OR sekai_status.windowOpen == false) then
			false;
		else
			sekai_status.windowOpen;
	)
	
	on execute do 
	(
		local sekaiInst = sekai_get_instance();
--		if (sekaiInst != undefined) do
--		(
--			if (sekai_status == undefined OR sekai_status.windowOpen == false) then
--				sekaiInst.open();
--			else
--				sekaiInst.close();
--		) else (
--			print "Error in initializing main init script"
--		)
	)
		
)