local smeview_dir = (GetDir #userScripts) + "\\kage\\smeviews\\"
local smefiles = #()

-- loop through smeview_dir to get all sme files
fn list_smefiles = (
	
)

rollout sme_rollout "Material Editor Save" (
	-- close button
	button btnCancel "Cancel" \
	pos:[0,0] \ 
	align: #left \
	width: 100

	on btnCancel pressed do (
		try (DestroyDialog sme_rollout) catch()
	)

	on sme_rollout open do
	(
		
	)

-- end sub rollout
)


CreateDialog sme_rollout 500 500 style:#(#style_border, #style_sunkenedge)