_OBJECT_COUNT = 0
_FIRST_OBJECT = ""

_COPYCOUNT = 1
_X_OFFSET = 0
_Y_OFFSET = 0
_Z_OFFSET = 0
_ANGLE_OFFSET = 0

_DIALOG_PREVENT_TIMER = dotNetObject "System.Windows.Forms.Timer";

UNDO_OBJECTS = #()		-- objects created that can be deleted on undo

fn onTick = (
	-- http://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_282F32AC_5A80_4FDB_B8C0_275D2CC15845_htm
	-- exposes window classess
	-- print (windows.getChildrenHWND #max)

	--try (
		child = (windows.getChildHWND 0 "Clone Options" parent:#max)
		if child != undefined do (
			print (windows.getChildrenHWND child[1])
			--h = windows.GetChildWindows child[1]
			--counter = 1
			--for a in (windows.getChildrenHWND child) do (
		--		format "% : %\n" (counter as string) a
		--		counter += 1
		--	)
			for btn in (windows.getChildrenHWND child[1]) where (btn[5] == "OK") do UIAccessor.PressButton btn[1]
		)
	--) catch ()
)

fn get_friendly_name filename = (
	return trimright filename "1234567890\\/:"
)

rollout clone_rollout "クロン" (

	-- checkbox to prevent clone dialog
	-- http://www.scriptspot.com/forums/3ds-max/general-scripting/press-ok-btn-after-copying-an-object-with-shift
	checkbutton preventCloneDialog "クロンダイアログ停止"

	-- prevent clone dialog
	on preventCloneDialog changed theState do (
		print "preventCloneDialog was pressed"
		if preventCloneDialog.checked then (
			print "preventCloneDialog mode ON"
			_DIALOG_PREVENT_TIMER.interval = 1
		  	dotnet.addEventHandler _DIALOG_PREVENT_TIMER "tick" onTick
		  	_DIALOG_PREVENT_TIMER.Start()
		) else (
			print "preventCloneDialog mode OFF"
			_DIALOG_PREVENT_TIMER.Stop()
		)
	)	

	-- listview of objects to copy
	listbox listSelection "下記のオブジェクトをくろんします" items:(for s in selection collect s.name) readOnly:true -- width:50

	-- copy options
	spinner spnCopies "クロン回数" range:[1, 100, 1] type:#integer align:#left
	group "移動" (
		slider offsetX "X " range:[0, 30, 0] type:#integer orient:#horizontal across:2
		slider offsetY "Y " range:[0, 30, 0] type:#integer orient:#horizontal across:2
		slider offsetZ "Z " range:[0, 30, 0] type:#integer orient:#horizontal across:2
		slider ctrAngle "角度" range:[0, 30, 0] type:#integer orient:#horizontal across:2
	)

	on spnCopies changed val do _COPYCOUNT = val
	on offsetX changed val do (
		_X_OFFSET = val * 10
		offsetX.caption = ("X : " + (_X_OFFSET as string))
	)
	on offsetY changed val do (
		_Y_OFFSET = val * 10
		offsetY.caption = ("Y : " + (_Y_OFFSET as string))
	)
	on offsetZ changed val do (
		_Z_OFFSET = val * 10
		offsetZ.caption = ("Z : " + (_Z_OFFSET as string))
	)
	-- This Rotation Is Rotating Only Around the X Axis
	on ctrAngle changed val do (
		_ANGLE_OFFSET = val * 10
		ctrAngle.caption = ("角度 : " + (_ANGLE_OFFSET as string))
	)

	-- post
	button btnConfirm "OK" across: 3
	button btnUndo "Undo" across: 3
	button btnCancel "Cancel" across: 3

	on btnCancel pressed do (
		try (DestroyDialog clone_rollout) catch()
	)

	-- clone
	on btnConfirm pressed do (
		-- check copy is valid
		is_selection_count_match = _OBJECT_COUNT == selection.count
		if is_selection_count_match and _OBJECT_COUNT > 0 then (
			is_first_object_match = _FIRST_OBJECT == selection[1].name
		) else (
			is_first_object_match = false
		)

		if selection.count == 0 then (
			messageBox "オブジェクトをセレクトしてください"
		) else if not is_first_object_match then (
			listSelection.items = (for s in selection collect s.name) 
			messageBox "セレクトの物は変わりました"
			_OBJECT_COUNT = selection.count
			_FIRST_OBJECT = selection[1].name
		) else (

			-- clear cache
			UNDO_OBJECTS = #()

			--clone the selected objects to new array named nnl
			-- offset is point3 value [x,y,z]
			pointx = 0
			pointy = 0
			pointz = 0
			rotation = 0
			for i = 1 to _COPYCOUNT do (
				format "cloning % of %\n" (i as string) (_COPYCOUNT as string)
				pointx += _X_OFFSET
				pointy += _Y_OFFSET
				pointz += _Z_OFFSET
				
				rotation += _ANGLE_OFFSET
				if rotation > 0 then (
					total_angle = (rotation as float)
					format "rotation is at %\n" (total_angle as string)

					rotated_x = cos(total_angle) * _X_OFFSET
					rotated_y = sin(total_angle) * _X_OFFSET
					rotated_z = 0

					point_rotated = [rotated_x, rotated_y + pointy, rotated_z + pointz]
				) else (
					point_rotated = [pointx, pointy, pointz]
				)
				format "%, %, %\n" point_rotated.x point_rotated.y point_rotated.z

				maxOps.cloneNodes (selection as array)\
				    cloneType:#instance\
				    newNodes:&nnl\
				    offset: point_rotated
				    #nodialog

				--Loop through the array of object it returns
				friendly = get_friendly_name selection[1].name
				for i = 1 to nnl.count do (
				    --rename the objects to a unique name
				    nnl[i].name = uniqueName friendly numDigits:3
				    -- add object to cache
				    append UNDO_OBJECTS nnl[i]
				)
			) -- end copy count loop

		) -- end validation
	)

	-- undo
	on btnUndo pressed do (
		for o in UNDO_OBJECTS do delete o
		UNDO_OBJECTS = #()
	)

	on clone_rollout open do (
		_OBJECT_COUNT = selection.count
		_FIRST_OBJECT = selection[1].name
	)

	on clone_rollout close do (
		_DIALOG_PREVENT_TIMER.Stop()
	)

-- end sub rollout
)
