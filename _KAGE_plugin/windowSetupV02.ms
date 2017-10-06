-- try opening scene explorer and material editor
macros.run "Scene Explorer" "SELayerExplorer"
-- macros.run "Material Explorer" "MaterialExplorerToggle"
-- sme "Slate Mate"
if not sme.isopen() do (
	macros.run "Medit Tools" "advanced_material_editor"
)

-- create custom windows .net class (ugh its in vb)
fn DialogWindowOpsClass = (
	source = "Imports System.Runtime.InteropServices\n"
	source += "Imports System.Drawing\n"
	source += "Public Class DialogWindowOps\n"
	source += "Public Structure RECT\n"
	source += "Public left As Integer\n"
	source += "Public top As Integer\n"
	source += "Public right As Integer\n"
	source += "Public bottom As Integer\n"
	source += "Public ReadOnly Property Width() As Integer\n"
	source += "Get\n"
	source += "Return right - left\n"
	source += "End Get\n"
	source += "End Property\n"
	source += "Public ReadOnly Property Height() As Integer\n"
	source += "Get\n"
	source += "Return bottom - top\n"
	source += "End Get\n"
	source += "End Property\n"
	source += "End Structure\n"
	source += "Public Structure POINTAPI\n"
	source += "Public x As Integer\n"
	source += "Public y As Integer\n"
	source += "End Structure\n"
	source += "Public Structure WINDOWPLACEMENT\n"
	source += "Public Length As Integer\n"
	source += "Public flags As Integer\n"
	source += "Public showCmd As Integer\n"
	source += "Public ptMinPosition As POINTAPI\n"
	source += "Public ptMaxPosition As POINTAPI\n"
	source += "Public rcNormalPosition As RECT\n"
	source += "End Structure\n"
	source += "<DllImport(\"user32.dll\")> _\n"
	source += "Public Shared Function MoveWindow(ByVal hWnd As System.IntPtr, ByVal x As Integer, ByVal y As Integer, ByVal nWidth As Integer, ByVal nHeight As Integer, ByVal bRepaint As Boolean) As Boolean\n"
	source += "End Function\n"
	source += "<DllImport(\"user32.dll\")> _\n"
	source += "Public Shared Function GetWindowRect(ByVal hWnd As System.IntPtr, ByRef lpRect As RECT) As Boolean\n"
	source += "End Function\n"
	source += "<DllImport(\"user32.dll\")> _\n"
	source += "Public Shared Function GetWindowPlacement(ByVal hWnd As System.IntPtr, ByRef lpwndpl As WINDOWPLACEMENT) As Boolean\n"
	source += "End Function\n"
	source += "Public Function WindowSize(ByVal Hwnd As System.IntPtr) As System.Drawing.Size\n"
	source += "Dim LPRECT As RECT\n"
	source += "GetWindowRect(Hwnd, LPRECT)\n"
	source += "Dim WinSize As System.drawing.size = New System.drawing.size(LPRECT.Width, LPRECT.Height)\n"
	source += "Return WinSize\n"
	source += "End Function\n"
	source += "Public Function WindowPosition(ByVal Hwnd As System.IntPtr) As System.Drawing.Point\n"
	source += "Dim intRet As Integer\n"
	source += "Dim wpTemp As WINDOWPLACEMENT = New WINDOWPLACEMENT()\n"
	source += "wpTemp.Length = System.Runtime.InteropServices.Marshal.SizeOf(wpTemp)\n"
	source += "intRet = GetWindowPlacement(Hwnd, wpTemp)\n"
	source += "Dim WinPoint As System.drawing.point = New System.drawing.point(wpTemp.rcNormalPosition.left, wpTemp.rcNormalPosition.top)\n"
	source += "Return WinPoint\n"
	source += "End Function\n"
	source += "End Class"  

	VBProvider = dotnetobject "Microsoft.VisualBasic.VBCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.add "C:\Windows\Microsoft.NET\Framework\v2.0.50727\System.drawing.dll"	
	compilerParams.GenerateInMemory = on
	compilerResults = VBProvider.CompileAssemblyFromSource compilerParams #(source)		
	-- debug source code and check for referencing errors
	if (compilerResults.Errors.Count > 0 ) then (
		errs = stringstream ""
		for i = 0 to (compilerResults.Errors.Count-1) do (
			err = compilerResults.Errors.Item[i]
			format "Error:% Line:% Column:% %\n" \
				err.ErrorNumber err.Line \
				err.Column err.ErrorText to:errs 
		)
		MessageBox (errs as string) title: "Errors encountered while compiling VB code"
		return undefined
	) 	
	return compilerResults.CompiledAssembly.CreateInstance "DialogWindowOps"
)

WindowOps = DialogWindowOpsClass()

-- parent window
print "CHECKING OUT PARENT WINDOW"
maxHWND = windows.getMaxHWND()
maxPosition = WindowOps.WindowPosition maxHWND
format "Max window X: %\n" maxPosition.x
format "Max window Y: %\n" maxPosition.y
maxSize = WindowOps.WindowSize maxHWND
format "Max window Width: %\n" maxSize.width
format "Max window Height: %\n" maxSize.height
horizontalRef = maxPosition.x
verticalRef = maxPosition.y 

-- list out max windows [ parent:#max]
print "LOOPING THROUGH CHILD WINDOWS"
dialogList = for i in (windows.getChildrenHWND 0 parent:#max) \
	where UIAccessor.IsWindow i[1] \
		and (not i[5] == "AdApplicationButton") \
		and (not i[5] == "MAXScript Listener") \
		and (not i[5] == "Enhanced Menus") \
		and (not i[5] == "") \
	collect i

-- loop through windows and do smtn
layerHWND = undefined
materialHWND = undefined
slateHWND = undefined

-- slate small windows
paramHWND = undefined
navigatorHWND = undefined
matHWND = undefined

print "MOVE SCENE EXPLORER"
for i in dialogList do (
	window_name = substring i[5] 1 10
	format "window: %\n" window_name
	format "ref: %\n" i[1]
	dummy = 0
	if window_name == "Scene Expl" or window_name == "シーン　エクスポーロ" then (
		format "moving : %\n" window_name
		layerHWND = dotnetobject "System.Intptr" i[1]
		windowSize = WindowOps.WindowSize layerHWND
		w = windowSize.width
		h = windowSize.height
		if dummy == 0 do (
			horizontalRef = horizontalRef - w
			dummy = 1
		)
		WindowOps.MoveWindow layerHWND horizontalRef verticalRef w h true
	)
)

if layerHWND == undefined do (
	format "Scene Explorer NOT found!\n"
)

-- repeat windows for material editor
print "MOVE MATERIAL EDITOR"
dialogList = for i in (windows.getChildrenHWND 0) \
	where UIAccessor.IsWindow i[1] \
		and (not i[5] == "AdApplicationButton") \
		and (not i[5] == "MAXScript Listener") \
		and (not i[5] == "Enhanced Menus") \
		and (not i[5] == "") \
	collect i

for i in dialogList do (
	window_name = substring i[5] 1 10
	dummy = 0
	if window_name == "Material E" or window_name == "マテリアル　エクスポ" then (
		materialHWND = dotnetobject "System.Intptr" i[1]
		windowSize = WindowOps.WindowSize materialHWND
		w = windowSize.width
		h = windowSize.height
		if dummy == 0 do (
			horizontalRef = horizontalRef - w
			dummy = 1
		)
		WindowOps.MoveWindow materialHWND horizontalRef verticalRef w h true
	)
	if window_name == "Slate Mate" or window_name == "スレート　マテリアル" then (
		slateHWND = dotnetobject "System.Intptr" i[1]
	) else if window_name == "Material P" or window_name == "コマンド パネル" then (
		paramHWND = dotnetobject "System.Intptr" i[1]
	) else if window_name == "Navigator" then (
		navigatorHWND = dotnetobject "System.Intptr" i[1]
	) else if window_name == "Material/" then (
		matHWND = dotnetobject "System.Intptr" i[1]
	)
)

if materialHWND == undefined do (
	format "Material Editor NOT found!\n"
)

-- move slate material editor
print "MOVE SLATE MATERIAL EDITOR"
if sme != undefined and sme.isopen() then  (
	print sme
	windowSize = WindowOps.WindowSize slateHWND
	w = windowSize.width
	h = windowSize.height
	horizontalRef = horizontalRef - w
	WindowOps.MoveWindow slateHWND horizontalRef verticalRef w h true
) else (
	format "Slate Material Editor not found!\n"
)

if paramHWND != undefined then (
	windowSize = WindowOps.WindowSize paramHWND
	w = windowSize.width
	h = windowSize.height	
	WindowOps.MoveWindow slateHWND horizontalRef verticalRef w h true
) else (
	format "Material Parameters NOT found!\n"
)

/*
if navigatorHWND != undefined then (
	windowSize = WindowOps.WindowSize navigatorHWND
	w = windowSize.width
	h = windowSize.height	
	WindowOps.MoveWindow slateHWND horizontalRef verticalRef w h true
) else (
	format "Material Navigator NOT found!\n"
)

if matHWND != undefined then (
	windowSize = WindowOps.WindowSize matHWND
	w = windowSize.width
	h = windowSize.height	
	WindowOps.MoveWindow slateHWND horizontalRef verticalRef w h true
) else (
	format "Material List NOT found!\n"
)
*/