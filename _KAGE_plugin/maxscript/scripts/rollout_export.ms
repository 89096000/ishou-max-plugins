/*
To Open Rollout UI, Just run this script
*/

rollout export_rollout "Export Options" (
	-- UI Controls
	group "保存先" (
		checkbox ck_export_desktop "Desktop" across:2 checked:false
		checkbox ck_export_shared "Shared Drive" across:2 checked:true
	)

	button btn_close "戻る" align:#center

	-- checkbox buttons flip
	on ck_export_desktop changed theState do (
		ck_export_shared.state = not ck_export_shared.state
	)

	on ck_export_shared changed theState do (
		ck_export_desktop.state = not ck_export_desktop.state
	)

	-- close box
	on btn_close pressed do (
		try (DestroyDialog export_rollout) catch ()
	) 
)
