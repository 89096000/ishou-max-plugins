--Pair structure for general use.
struct Pair
(
   key,
   value
)
   
--Import scripts
fileIn "ini_mgr.ms";            -- scripts to speak with ini files
fileIn "color_mgr.ms";          -- sets up color profiles
fileIn "_rollout.ms";           -- main treeview rollout
fileIn "rollout_export.ms";     -- export interface rollout

function init = 
(
  local success = true;

  try
  (
--    loadAssembly "Outliner.dll";
    loadAssembly "ScriptCenter.Max.dll";
  )
  catch
  (
    print (getCurrentException());
    messageBox ("Loading dlls failed.\n\n" + \
                "Tip: make sure you have the latest .NET Framework installed.\n" + \
        		"Please see the Maxscript Listener for details.") title:"Error";

    destroyDialog outliner_initializing;
     
    return false;
   )

   success;
)