-- Pair structure for general use.
struct Pair
(
  key,
  value
)

-- Public shared variables
global KAGE_MAIN;               -- main kage struct
global KAGE_STATUS;             -- rollout status struct
global KAGE_HITNODE;            -- current selected node
global KAGE_CALLBACKS;          -- callbacks struct
global KAGE_IMPORTS;			-- import folder lists
global CALLBACKS_MODE = true;	-- set to false for actions to not trigger callbacks
global CURRENT_FILTER = "all";  -- all or some color
global TV_MODE = "layer";       -- layer / scene / object
global VIEW_STYLE = "none";     -- none / color / white
global FLAT_MODE = false;       -- doesnt draw any nodes

global PRODUCT_INFO_INI = (GetDir #userScripts) + "/kage_product_info.ini"
global treeview_rollout			-- main treeview

-- Import scripts
fileIn "ini_mgr.ms";            -- scripts to speak with ini files
fileIn "color_mgr.ms";          -- sets up color profiles
fileIn "tools.ms";              -- tool palette for misc functions
fileIn "import_files.ms";       -- list of share drive import folders and files

fileIn "_rollout.ms";           -- main treeview rollout
fileIn "rollout_import.ms";     -- import interface rollout
fileIn "rollout_export.ms";     -- export interface rollout
fileIn "rollout_submenu.ms";    -- submenu (color picker) rollout
fileIn "rollout_filter.ms";     -- filter tree rollout
fileIn "rollout_select.ms";     -- select tree rollout
fileIn "callbacks.ms";     		-- event callbacks

-- load scripts
/*
try
(
  loadAssembly "ScriptCenter.Max.dll";
) catch (
  print (getCurrentException());
  messageBox ("Loading dlls failed.\n\n" + \
              "Tip: make sure you have the latest .NET Framework installed.\n" + \
          "Please see the Maxscript Listener for details.") title:"Error";
)
*/

-- init rollout
KAGE_MAIN = KageMain()
KAGE_CALLBACKS = KageCallbacks()
KAGE_IMPORTS = ImportFolders()