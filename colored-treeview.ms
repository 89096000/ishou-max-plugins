-- code inside macroscripts are executed immediately on ActionItem
--macroScript SceneTreeView category:"testing"
--(
	-- rollouts are UI windows
	rollout treeview_rollout "意匠計画シーンブラウザ" (

		-- initialize rollout control
		-- init settings found here: https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/2015/ENU/MAXScript-Help/files/GUID-C2B51AEE-9C08-4679-B625-A36C72025C91-htm.html
		-- measurement is in pixels
		fn initTreeView tv = (
			tv.Indent = 18
			-- tv.LineStyle = #tvwTreeLines
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
		spinner spn_indent "Indentation" range:[0,100,28] type:#integer fieldwidth:40
		
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