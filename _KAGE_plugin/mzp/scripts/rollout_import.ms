/*
Opens an import listview
*/

_IMAGE_FILE = "";
_SCRIPT_FILE = "";
_ICON_DIR = ((GetDir #userIcons) + "/kage")
_ITEM_LIST = #()

alpha_icon = bitmap 128 128 color:black
car_path = (_ICON_DIR + "/_cars.bmp")
car_icon = (openBitmap car_path)
chair_path = (_ICON_DIR + "/_chairs.bmp")
chair_icon = (openBitmap chair_path)
curtain_path = (_ICON_DIR + "/_curtains.bmp")
curtain_icon = (openBitmap curtain_path)
lighting_path = (_ICON_DIR + "/_lightings.bmp")
lighting_icon = (openBitmap lighting_path)
plant_path = (_ICON_DIR + "/_plants.bmp")
plant_icon = (openBitmap plant_path)
shop_path = (_ICON_DIR + "/_shops.bmp")
shop_icon = (openBitmap shop_path)
sofa_path = (_ICON_DIR + "/_sofas.bmp")
sofa_icon = (openBitmap sofa_path)
table_path = (_ICON_DIR + "/_tables.bmp")
table_icon = (openBitmap table_path)
tableware_path = (_ICON_DIR + "/_tablewares.bmp")
tableware_icon = (openBitmap tableware_path)


rollout import_rollout "Import File" (

button cat_car "t" \
width:96 height:96 \
toolTip: "車_cars" \
images:#(car_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[10, 10]

button cat_chair "t" \
width:96 height:96 \
toolTip: "椅子_chair" \
images:#(chair_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[126, 10]

button cat_curtain "t" \
width:96 height:96 \
toolTip: "カーテン ブラインド_curtain" \
images:#(curtain_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[242, 10]

button cat_lighting "t" \
width:96 height:96 \
toolTip: "照明_lighting" \
images:#(lighting_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[10, 126]

button cat_plant "t" \
width:96 height:96 \
toolTip: "植栽_Plants" \
images:#(plant_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[126, 126]

button cat_shop "t" \
width:96 height:96 \
toolTip: "店舗関連_shop related" \
images:#(shop_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[242, 126]

button cat_sofa "t" \
width:96 height:96 \
toolTip: "椅子_chair_Sofa" \
images:#(sofa_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[10, 242]

button cat_table "t" \
width:96 height:96 \
toolTip: "テーブル_table" \
images:#(table_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[126, 242]

button cat_tableware "t" \
width:96 height:96 \
toolTip: "食器、調味料_tableware" \
images:#(tableware_icon,alpha_icon, 1, 1, 1, 1, 1) \
pos:[242, 242]

fn closeCatButtons = (
	cat_car.visible = false
	cat_chair.visible = false
	cat_curtain.visible = false
	cat_lighting.visible = false
	cat_plant.visible = false
	cat_shop.visible = false
	cat_sofa.visible = false
	cat_table.visible = false
	cat_tableware.visible = false
)

fn initListView lv = (
	lv.gridLines = true
	lv.checkboxes = false
	lv.labeledit = false
	lv.showitemtooltips = true
	lv.View = (dotNetClass "System.Windows.Forms.View").Details
	lv.fullRowSelect = true
	lv.Columns.add "Object" 350 -- object
	lv.Columns.add "Address" 50 -- url
	lv.Columns.add "Image" 50 -- img
	lv.Columns.add "Script" 50 -- script
)

fn fillInSpreadSheet lv = (
	theRange = #()
	for o in _ITEM_LIST do (
		--li = dotNetObject "System.Windows.Forms.ListViewItem" "002 Cobra Chiar"
		--h = hyperLink "test" "test" address:"http:i-keikaku.co.jp" 
		--sub_li = li.SubItems.add "chair"
		--sub_li = li.SubItems.add test_url

		li = dotNetObject "System.Windows.Forms.ListViewItem" o.key
		sub_li = li.SubItems.add o.url
		sub_li = li.SubItems.add o.img
		sub_li = li.SubItems.add o.scr

		append theRange li
	)
	lv.Items.AddRange theRange--when done, we populate the ListView
)

fn loadPictureBox pb = (
	imageObject = (dotNetClass "System.Drawing.Image").fromFile _IMAGE_FILE
	pb.backGroundImage = imageObject
	pb.SizeMode = (dotNetClass "System.Windows.Forms.PictureBoxSizeMode").StretchImage
	pb.BackgroundImageLayout = (dotNetClass "System.Windows.Forms.ImageLayout").Zoom
	pb.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").Fixed3D
)

-- listview ---------------------------------
dotNetControl lv_objects "System.Windows.Forms.ListView" \
	width:340 height:240 align:#center pos:[5,5]

-- image preview ---------------------------------
dotNetControl pictureBox "System.Windows.Forms.PictureBox" \
	width:340 height:140 align:#center pos:[5,255]

-- buttons ---------------------------------
button btn_back "帰る" \
toolTip: "go back" \
align: #left width:60 across:2

button btn_import "インポート" \
toolTip: "import this file" \
align: #left  width:60 across:2

on btn_back pressed do (
	try (DestroyDialog import_rollout) catch ()
	if _ITEM_LIST.count > 0 then (
		local dialog_pos = GetDialogPos treeview_rollout
		local posx = dialog_pos.x - 250 + _TV_WIDTH
		local posy = dialog_pos.y - 250 + _TV_HEIGHT
		CreateDialog import_rollout 350\
									450\
									pos:[posx, posy] \
                                    style:#(#style_border)
	)
)

-- test only
on btn_import pressed do (
	try (
		fileIn _SCRIPT_FILE
		format "% was loaded!\n" _SCRIPT_FILE
		try (DestroyDialog import_rollout) catch ()
	) catch (
		format "% FAILED!\n" _SCRIPT_FILE
	)
)


-- rollout events -------------------------------
on import_rollout open do (
	btn_back.visible = true
	btn_import.visible = false
	lv_objects.width = 1
	lv_objects.height = 1
	pictureBox.width = 1
	pictureBox.height = 1
	_ITEM_LIST = #()
)

fn render_listview_mode = (
	closeCatButtons()
	lv_objects.width = 340
	lv_objects.height = 240
	pictureBox.width = 340
	pictureBox.height = 140
	btn_back.visible = true
	btn_import.visible = true
	initListView lv_objects
	fillInSpreadSheet lv_objects
)

on cat_car pressed do (
	_ITEM_LIST = KAGE_IMPORTS.CAR_LIST
	render_listview_mode()
)

on cat_chair pressed do (
	_ITEM_LIST = KAGE_IMPORTS.CHAIR_LIST
	render_listview_mode()
)

on cat_curtain pressed do (
	_ITEM_LIST = KAGE_IMPORTS.CURTAIN_LIST
	render_listview_mode()
)

on cat_lighting pressed do (
	_ITEM_LIST = KAGE_IMPORTS.LIGHTING_LIST
	render_listview_mode()
)

on cat_plant pressed do (
	_ITEM_LIST = KAGE_IMPORTS.PLANT_LIST
	render_listview_mode()
)

on cat_shop pressed do (
	_ITEM_LIST = KAGE_IMPORTS.SHOP_LIST
	render_listview_mode()
)

on cat_sofa pressed do (
	_ITEM_LIST = KAGE_IMPORTS.SOFA_LIST
	render_listview_mode()
)

on cat_table pressed do (
	_ITEM_LIST = KAGE_IMPORTS.TABLE_LIST
	render_listview_mode()
)

on cat_tableware pressed do (
	_ITEM_LIST = KAGE_IMPORTS.TABLEWARE_LIST
	render_listview_mode()
)

-- listview events ------------------------------

on lv_objects mouseDown arg do (
	try (
		-- get object info
		hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))

		import_name = hit.item.text
		url = hit.item.subItems.item[1].text
		img = hit.item.subItems.item[2].text
		img_url = url + "\\" + img

		-- set image
		_IMAGE_FILE = img_url
		loadPictureBox pictureBox

		-- set script location
		_SCRIPT_FILE = url + "\\" + hit.item.subItems.item[3].text
		format "SCR:%\n" _SCRIPT_FILE
	) catch ()
)

on lv_objects mouseDoubleClick arg do (
	try (
		hit=(lv_objects.HitTest (dotNetObject "System.Drawing.Point" arg.x arg.y))

		url = hit.item.subItems.item[1].text
		format "URL: %\n" url

		shellLaunch "explorer.exe" url
	) catch ()
)




) -- end rollout