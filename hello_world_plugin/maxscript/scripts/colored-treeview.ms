/*
TODO init rollout func from some custom menu
To Open Rollout UI, Just run this script
*/
_DEFAULT_INDENT = 13
_ROLLOUT_WIDTH = 200
_ROLLOUT_HEIGHT = 400
_BTNS_PER_ROW = 4
_ICON_DIR = @"C:\Users\Orbit-Kwa\Desktop\git\ishous-max-plugins\16x16bmps\"
-- image list
IMAGE_LIST = dotNetObject "System.Windows.Forms.ImageList"
IMAGE_LIST.imageSize = dotNetObject "System.Drawing.Size" 16 15


-- cache bmp icons
fn getIconFromBitmap thePath number iconFileName = (
	filename = getDir #image + "\\icon_" + iconFileName + ".bmp"

	if not doesFileExist filename do (
		tempBmp = openBitmap thePath
		iconBmp = bitmap 16 15
		for v = 0 to 14 do (
			setPixels iconBmp [0,v] (
				getPixels tempBmp [0, v] 16
			)
			iconBmp.filename = filename
			save iconBmp
			close iconBmp
			close tempBmp
		)
	)
	img = dotnetClass "System.Drawing.Image"
	IMAGE_LIST.images.add (img.fromFile filename)
)
getIconFromBitmap (_ICON_DIR + "file.bmp") 1 "file"
getIconFromBitmap (_ICON_DIR + "star.bmp") 2 "star"
getIconFromBitmap (_ICON_DIR + "signal.bmp") 3 "signal"
getIconFromBitmap (_ICON_DIR + "check.bmp") 4 "check"
getIconFromBitmap (_ICON_DIR + "arrow.bmp") 5 "arrow"
getIconFromBitmap (_ICON_DIR + "heart.bmp") 6 "heart"
getIconFromBitmap (_ICON_DIR + "cross.bmp") 7 "cross"
getIconFromBitmap (_ICON_DIR + "bomb.bmp") 8 "bomb"


-- returns a string with 2 padded zeros (int)
fn padZeros raw_number = (
	r = raw_number as string
	if (raw_number > 99) then (
		s = r
	) else if (raw_number >9) then (
		s = "0" + r
	) else (
		s = "00" + r
	)
	return s
)


fn GetIntStart text_val = (
	v = substring text_val 1 3
	vint = v as integer
	if vint == undefined then (
		return 0
	) else (
		return vint
	)
)


-- adds to a padded number (string) (int)
fn AddToPadded text_val int_add = (
	v = GetIntStart(text_val)
	text_length = text_val.count - 3
	the_rest = substring text_val 4 text_length
	print the_rest
	w = v + int_add
	x = padZeros(w)
	return x + the_rest
)

-- code inside macroscripts are executed immediately on ActionItem
--macroScript SceneTreeView category:"testing"
--(

    -- rollouts are UI windows
	rollout treeview_rollout "意匠計画シーンブラウザ" (
		
		-- initialize rollout control
		-- init settings found here: https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2015/ENU/MAXScript-Help/files/GUID-C2B51AEE-9C08-4679-B625-A36C72025C91-htm.html
		fn initTreeView tv = (
			tv.Indent = _DEFAULT_INDENT
			tv.CheckBoxes = true
			tv.imageList = IMAGE_LIST
			tv.Sorted = true
		) 

		-- recursive function for node children
		-- tag contains MXS value, whatever that means
		-- ref to dotnet treenode class https://msdn.microsoft.com/en-us/library/system.windows.forms.treenode(v=vs.110).aspx
		fn addChildren theNode theChildren = (

			for i = 1 to theChildren.count do (
				node_number_padded = padZeros(i)
				node_new_name = node_number_padded + " " + theChildren[i].name
				newNode = theNode.Nodes.add node_new_name
				newNode.tag = dotNetMXSValue theChildren[i]
				newNode.checked = not theChildren[i].isHidden
				-- TODO SET THE INDEX AND COLOR ACCORDING TO CUSTOM
				newNode.imageIndex = newNode.selectedImageIndex = 0
				newNode.backcolor = (dotNetClass "System.Drawing.Color").fromARGB theChildren[i].wirecolor.r theChildren[i].wirecolor.g theChildren[i].wirecolor.b
				addChildren newNode theChildren[i].children
			)
		)
		
		-- define the content for the treeview
		-- collect all objects that have no parent (top level nodes)
		-- call recursive function to add children to top level nodes
		fn fillInTreeView tv = (
			theRoot = tv.Nodes.add "ワールドルート"
			rootNodes = for o in objects where o.parent == undefined collect o						
			addChildren theRoot rootNodes
		)
		
		-- create treeview activeX control in rollout
		-- activeXControl tv "MSComctlLib.TreeCtrl" width:190 height:290 align:#center
		dotNetControl tv "TreeView" width:190 height:290 align:#center

		--add up and down move buttons
		button nodeUp "上" width:50 across:2
		button nodeDown "下" width:50
		
		-- add icon options to UI
		checkbutton ckFile "-" width:50 images:#("icon_file.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckStar "-" width:50 images:#("icon_star.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckSignal "-" width:50 images:#("icon_signal.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckCheck "-" width:50 images:#("icon_check.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckArrow "-" width:50 images:#("icon_arrow.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckHeart "-" width:50 images:#("icon_heart.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckCross "-" width:50 images:#("icon_cross.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
		checkbutton ckBomb "-" width:50 images:#("icon_bomb.bmp", undefined, 1, 1, 1, 1, 1) across:_BTNS_PER_ROW
				
		-- add a spinner to test the indentation of the rollout
		spinner spn_indent "Indentation" range:[0,100,_DEFAULT_INDENT] type:#integer fieldwidth:40
		
		-- HANDLERS
		-- add event handler to select the object if user clicks on node
		-- have to get node under mouse cursor, then select using the MXS tag
		on tv Click arg do (
			hitNode = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
			)
		)
		
		-- on clicking up button, move node up
		on nodeUp Pressed do (
			mainNode = tv.Nodes.item[0]
			hitNode = tv.selectedNode
			print "user moving node " + hitNode.text + " UP"
			index = hitNode.index
			nodeCount = mainNode.Nodes.count
			node_id = GetIntStart(hitNode.text)
			if node_id > 1 do (
				try (
					nextNode = mainNode.Nodes.item[index-1]
					hitNodeName = AddToPadded hitNode.text -1
					nextNodeName = AddToPadded nextNode.text 1
					
					hitNode.text = hitNodeName
					nextNode.text = nextNodeName
					tv.Sorted = true
					tv.Refresh()
					mainNode.Refresh()
					
					/*
					-- remake node a rename it with number before it 
					newNode = mainNode.Nodes.Insert (0) hitNodeName
					newNode.tag = hitNode.tag
					newNode.checked = hitNode.checked
					newNode.selectedImageIndex = hitNode.selectedImageIndex
					newNode.backcolor = hitNode.backcolor
					-- remove previous node
					tv.Nodes.Remove hitNode
					-- also rename the next node in the list
					newNode = mainNode.Nodes.Insert (0) nextNodeName
					newNode.tag = nextNode.tag
					newNode.checked = nextNode.checked
					newNode.selectedImageIndex = nextNode.selectedImageIndex
					newNode.backcolor = nextNode.backcolor
					-- remove previous node
					tv.Nodes.Remove nextNode
					*/
					
				) catch ()
			)
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
			)
		)
		
		-- on down button press, move down
		on nodeDown Pressed do (
			mainNode = tv.Nodes.item[0]
			hitNode = tv.selectedNode
			print "user moving node " + hitNode.text + " DOWN"
			index = hitNode.index
			nodeCount = mainNode.Nodes.count
			node_id = GetIntStart(hitNode.text)
			if node_id != 0 and index < nodeCount do (
				try (
					nextNode = mainNode.Nodes.item[index+1]
					hitNodeName = AddToPadded hitNode.text 1
					nextNodeName = AddToPadded nextNode.text -1
					
					hitNode.text = hitNodeName
					nextNode.text = nextNodeName					
					tv.Refresh()
				) catch ()
			)
				
			if hitNode != undefined do try(
				select hitNode.tag.value
			) catch (
				max select none
			)
		)
		
		-- handler for checkbox changing the visibility
		on tv AfterCheck arg do (
			try (
				arg.node.tag.value.isHidden = not arg.node.checked
			) catch ()
		)
		
		-- handler for changing spinner value
		on spn_indent changed val do tv.indent = val
			
		-- call functions on open
		on treeview_rollout open do (
			initTreeView tv
			fillInTreeView tv
		)

	-- end rollout
	)
	
	-- destroy any previous dialogs before opening new
	try (destroyDialog treeview_rollout) catch()
	
	-- create new dialog
	createDialog treeview_rollout _ROLLOUT_WIDTH _ROLLOUT_HEIGHT
	
-- end macroscript
--)
	


	
-- fn saveTreeData 

	
	
	
/*
Footnotes: 
IMAGE LISTS
- When creating icons for DotNet, it is necessary to create one bitmap for each icon,
   because the DotNet image list will lock the file for the duration of the script execution.
- Script writes a separate bitmap with the name passed as third argument
- Only creates bitmaps if they do not exist yet to avoid bitmap access errors
*/