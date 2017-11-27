global kageTools;

struct kage_tools (

--Directories and files.
userscripts_folder           = (GetDir #userScripts),
private product_info_file  = userscripts_folder + "/kage_product_info.ini",

-- get version
public function getVersion asString:false =
(
   if (not asString) then
      (getINISetting product_info_file #General #version) as float;
   else
      getINISetting product_info_file #General #versionString
)

-- end kate_tools struct
)

kageTools = kage_tools();