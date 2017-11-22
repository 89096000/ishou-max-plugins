global kage_callbacks;

struct KageCallbacks (

/**
 * FUNCTION CACHE
 */
tree_beginUpdateFn,
tree_endUpdateFn,
tree_selectAllFn,
tree_selectObjectRangeFn,


--Cache tree functions to minimize lookup time.
function createFunctionCache =
(
   tree_beginUpdateFn            = KAGE_TREE.tree.BeginUpdate;
   tree_endUpdateFn              = KAGE_TREE.tree.EndUpdate;
),

function disposeFunctionCache =
(
   --Set all properties ending in "Fn" to undefined.
   for p in (getPropNames this) where (matchPattern p pattern:"*Fn") do 
      setProperty this p undefined;

   (dotnetClass "System.GC").Collect();
),

nodeEventCB,

function createCallbacks =  (
   createFunctionCache();
   callbacks.addScript #selectionSetChanged "treeview_rollout.tag_search treeview_rollout.tv" id:#kage
   /*
   nodeEventCB = NodeEventCallback mouseUp:true delay:10;
   nodeEventCB.callbackBegin    = (fn a e h = kage_callbacks.callbackBegin e h);
   nodeEventCB.callbackEnd      = (fn a e h = kage_callbacks.callbackEnd e h);
   nodeEventCB.selectionChanged = (fn a e h = kage_callbacks.selectionChanged e h);
   */
),


function removeCallbacks = (
   if nodeEventCB != undefined do
      nodeEventCB.enabled = false;
   nodeEventCB = undefined;
   callbacks.removeScripts id:#kage;
   disposeFunctionCache();
),


function callbackBegin evt handles = (
   tree_beginUpdateFn();
),


function callbackEnd evt handles = (
   tree_endUpdateFn();
),


/*
 * SELECTION CHANGED
 */
fn selectionChanged evt handles = (
   format "kage selection callback for % items\n" selection.count
   try (
      KAGE_TREE.tree.SelectedNode = null
      if selection.count > 0 then (
         tree_beginUpdateFn();
         treeview_rollout.tag_search()
         tree_endUpdateFn();
      )
   ) catch ( )
)

)--End struct.
