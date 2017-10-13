macroScript GetMatFromSelToMedit
category:             "CG_Tools"
buttonText:           "Get Material"
tooltip:             "Get Material"

(
	on execute do
	(
		if selection.count>0 do
		(
			MatBank=for i in 1 to selection.count where selection[i].material!=undefined  collect selection[i].material
			mySlot=MatBank.count
			
			if mySlot>24 do mySlot=24
			
			for i=1 to mySlot do 
			(
			setmeditmaterial i MatBank[i]
			)
		)
	)
)
