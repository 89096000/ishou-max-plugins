-- PURPOSE of this file is to manage color codes

-- load the ini manager, color codes will be written to an ini file
fileIn "ini_mgr.ms";

COLOR_INI = ""
CATEGORY_NAME = "Colors"

struct ColorIro
(
   key,
   r,
   g,
   b
)

default_colors = #(
   (ColorIro key:#pink r:255 g:107 b:107 ),
   (ColorIro key:#orange r:252 g:145 b:58 ),
   (ColorIro key:#yellow r:249 g:212 b:35 ),
   (ColorIro key:#tan r:237 g:229 b:116 ),
   (ColorIro key:#mint r:79 g:240 b:176 ),

   (ColorIro key:#dark r:25 g:25 b:25 ),
   (ColorIro key:#red r:205 g:78 b:80 ),
   (ColorIro key:#violet r:144 g:96 b:144 ),
   (ColorIro key:#blue r:153 g:178 b:183 ),
   (ColorIro key:#grey r:233 g:233 b:233 ),

   (ColorIro key:#white r:255 g:255 b:255 ),
   (ColorIro key:#ltblack r:60 g:60 b:60 ),
   (ColorIro key:#black r:0 g:0 b:0 )
)

-- check for color ini file, if it doesnt exist, create one
fn InitColorSettings settings_folder = (
	-- overwrite settings_folder location with persistent location
	userscripts_folder = (GetDir #userScripts)

	-- check file exists
	COLOR_INI = userscripts_folder + "/kage_colors.ini"
	has_color_ini = (dotNetClass "System.IO.File").Exists(COLOR_INI)

	-- if not exist, make it
	if has_color_ini == false then (
		CreateIniFile COLOR_INI
		for c in default_colors do (
			rgb_string = (c.r as string) + "," + (c.g as string) + "," + (c.b as string)
			print "init default color: rgb_string"
			WriteToIni COLOR_INI CATEGORY_NAME c.key rgb_string
		)
	)
)

fn GetColorForKey key = (
	rgb_string = ReadFromIni COLOR_INI CATEGORY_NAME key
	rgb_stream = rgb_string as stringStream
	r = (readDelimitedString rgb_stream ",") as integer
	g = (readDelimitedString rgb_stream ",") as integer
	b = (readDelimitedString rgb_stream ",") as integer
	requested_color = (dotNetClass "System.Drawing.Color").fromARGB r g b
	return requested_color
)