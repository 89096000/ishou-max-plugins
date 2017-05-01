--Pair structure for general use.
struct Pair
(
   key,
   value
)
   
--Import scripts
fileIn "ini_mgr.ms";
fileIn "color_mgr.ms";
fileIn "_rollout.ms";

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