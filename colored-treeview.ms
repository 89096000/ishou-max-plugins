_DEFAULT_INDENT = 18
_ICON_DIR = @"C:\Users\Orbit-Kwa\Desktop\git\ishous-max-plugins\16x16bmps\"

-- code inside macroscripts are executed immediately on ActionItem
--macroScript SceneTreeView category:"testing"
--(

    -- image list
	image_list = dotNetObject "System.Windows.Forms.ImageList"
	image_list.imageSize = dotNetObject "System.Drawing.Size" 16 15
	
    -- rollouts are UI windows
	rollout treeview_rollout "意匠計画シーンブラウザ" (

		-- cache bmp icons
		fn getIconFromBitmap thePath number iconFileName = (
			filename = getDir #image + "\\icon_" + iconFileName + ".bmp"

			if not doesFileExist filename do (
				-- create bmp pixel by pixel
				tempBmp = openBitmap thePath
				iconBmp = bitmap 16 15
				for v = 0 to 14 do (
					setPixels iconBmp [0,v] (
						getPixels tempBmp [(number-1)*16, v] 16
					)
					iconBmp.filename = filename
					save iconBmp
					close iconBmp
					close tempBmp
				)
				img = dotnetClass "System.Drawing.Image"
				image_list.images.add (img.fromFile filename)
			)
		)

		-- initialize rollout control
		-- init settings found here: https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2015/ENU/MAXScript-Help/files/GUID-C2B51AEE-9C08-4679-B625-A36C72025C91-htm.html
		fn initTreeView tv = (
			tv.Indent = _DEFAULT_INDENT
			tv.CheckBoxes = true
			-- get bmps and assign image list to treeview
			getIconFromBitmap (_ICON_DIR + "bulb.bmp") 1 "bulb"
			tv.imageList = image_list
		) 

		-- recursive function for node children
		-- tag contains MXS value, whatever that means
		-- ref to dotnet treenode class https://msdn.microsoft.com/en-us/library/system.windows.forms.treenode(v=vs.110).aspx
		fn addChildren theNode theChildren = (
			for c in theChildren do (
				newNode = theNode.Nodes.add c.name
				newNode.tag = dotNetMXSValue c
				newNode.backcolor = (dotNetClass "System.Drawing.Color").fromARGB c.wirecolor.r c.wirecolor.g c.wirecolor.b
				addChildren newNode c.children
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
	createDialog treeview_rollout 200 320
	
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