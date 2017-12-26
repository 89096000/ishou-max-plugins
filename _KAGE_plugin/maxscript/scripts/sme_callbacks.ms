global kage_slate_callbacks;
global kage_slate_zoom;
global kage_node_event_cb;

-- (subobject change)
-- note on subObjectSelectionChanged to get face change
-- http://forums.cgsociety.org/archive/index.php?t-710774.html

fn selectMatsInSME curSME selectedMats = (
   -- GET LIST OF MATERIALS IN SME
   viewNodeCount = curSME.GetNumNodes()
   smeViewMaterials = for n = 1 to viewNodeCount collect (curSME.GetNode n)
   curSME.SelectNone()

   selectedMatsInView = #()
   i = 1
   found_mat = false 
   for m in smeViewMaterials do (
      if found_mat == true do exit
      
      try (
         r = undefined
         rr = undefined
         retry = 0
         while r == undefined and retry <= 25 do (
            rr = trackViewNodes[#sme][(sme.activeView)][i].reference
            -- wrapping name in string accounts for undefined
            if (rr.name as string) == m.name then (
               r = rr
            ) else (
               i += 1
               retry += 1
            )
         )
      ) catch (
         format "unable to get sme trackViewNodes for %" (i as string)
         exit
      )
      
      if r != undefined do (
         if (findItem selectedMats r) > 0 do (
            m.selected = true
            appendIfUnique selectedMatsInView r
            found_mat = true
         )
      )

      i += 1
   )
         
   -- SET CURRENT EDITOR   
   if selectedMatsInView.Count > 0 do (
      --for sm in selectedMatsInView do sme.SetMtlInParamEditor sm
      sme.SetMtlInParamEditor selectedMatsInView[1]

      try (
         kage_slate_zoom = ReadFromIni PRODUCT_INFO_INI "settings" "material_select_zoom"
         if kage_slate_zoom != undefined do (
            if kage_slate_zoom == "true" do curSME.ZoomExtents type: #selected
         )
      ) catch (
         print "seomthing wrong with reading zoom file"
      )
   )
)

struct KageSlateCallbacks (

kage_sm_time,
-- kage_last_obj,

-- function on node events must come first - (change_name change_id are required by default)
fn subSelectionChanged change_name change_id = (

   if sme.IsOpen() == false then (
      format "sme not open\n"
   ) else if selection.count >= 5 then (
      format "too many items selected for SME sub-object select: % items\n" selection.count
   ) else (

      for obj in selection do (

         if obj.material == undefined then (
            exit
         ) else (

            mObj = modPanel.getCurrentObject()
            selectedMats = #()

            case classOf mObj of (
               Edit_Poly : (
                  faces = (mObj.GetSelection #Face) as array
                  selectedMats = for f in faces collect (mObj.GetFaceMaterial f)
               )
               Editable_Poly : (
                  faces = (polyop.getFaceSelection obj) as array
                  selectedMats = for f in faces collect (mObj.GetFaceMaterial f)
               )
               Edit_Mesh : (
                  faces = for sf in obj.selectedFaces collect sf.index
                  selectedMats = for f in faces collect (getFaceMatID obj.mesh f)
               )
               Mesh_Select : (
                  faces = for sf in obj.selectedFaces collect sf.index
                  selectedMats = for f in faces collect (getFaceMatID obj.mesh f)
               )
               default : (
                  print ("UNABLE TO PROCESS CLASS : " + (classOf mObj as string))
               )
            )
            
            usedMaterials = #()
            myMatID = 1
            for om in obj.material.materialList do (
               exists = finditem selectedMats myMatID
               if exists > 0 do (
                  if classOf om == MultiMaterial then (
                     print "this obj is multimaterial - need recursive"
                  ) else (
                     if om != undefined do append usedMaterials om
                  )
                )
               myMatID += 1
            )

            --format "%\n" "Used Materials"
            --for um in usedMaterials do (
            --   print um.name
            --)
            -- SET CURRENT EDITOR
            curSME = sme.GetView (sme.activeView)
            selectMatsInSME curSME usedMaterials 

         ) -- end check obj material is defined
      ) -- end for obj in selection
   ) -- end check selection count
),

function createCallbacks =  (
   print "adding 2 selection callbacks"
   callbacks.addScript #selectionSetChanged "KAGE_SME_CALLBACKS.selectionChanged()" id:#kagesme
   kage_node_event_cb = nodeEventCallback subobjectSelectionChanged:subSelectionChanged
),

function removeCallbacks = (
   print "removing 1 selection callbacks"
   callbacks.removeScripts #selectionSetChanged id:#kagesme
),

function removeNodeEvents = (
   print "removing 1 node events"
   kage_node_event_cb = undefined
   gc light:true
),

-- FN to get get multimaterial object (recursive)
fn get_multimaterial_mats obj = (
   matList = #()
   materialsIds = #()
   try (
      faces = getNumFaces obj
      maxIndex = faces
      if faces > 96 do maxIndex = 96
      for i = 1 to maxIndex do (
         refId = getFaceMatID obj.mesh i
         appendIfUnique materialsIds refId
      )
   ) catch ()
   
   myMatID = 1
   for om in obj.material.materialList do (
      exists = finditem materialsIds myMatID
      if exists > 0 do (
         try (
            if classOf om == MultiMaterial then (
               myMats = get_multimaterial_mats om
               for x in myMats do appendIfUnique matList x
            ) else (
               appendIfUnique matList om
            )
         ) catch()
      )
      myMatID += 1
   )

   --format "Found % materials\n" matList.count
   --for ml in matList do print ml
   
   return matList
),

-- FN to reselect in SME materials used on selected materials
fn sme_selection = (
   -- Add time buffer until next script can run
   kage_sm_time = timeStamp()+100f

   -- check there's an active view
   curSME = sme.GetView (sme.activeView)
   if curSME == undefined do (
      return undefined
   )

   -- GET LIST OF SELECTED MATERIALS FROM SCENE
   selectedMats = #()
   for obj in selection do (      
      if obj.material != undefined do (
         if classof obj.material == MultiMaterial then (
            myMats = get_multimaterial_mats obj
            for x in myMats do appendIfUnique selectedMats x
         ) else (
            appendIfUnique selectedMats obj.material
         )
      )
   )

   -- SET CURRENT EDITOR
   selectMatsInSME curSME selectedMats
),

fn selectionChanged = (
   if kage_sm_time == undefined do kage_sm_time = timeStamp()
   --if kage_last_obj == undefined then (
   --   obj_is_new = true
   --) else (
   --   obj_is_new = kage_last_obj != (selection[1] as string)
   --)

   if sme.IsOpen() == false then (
      
   ) else if selection.count > 20 then (
      format "too many items selected for SME select: % items\n" selection.count
   ) else if kage_sm_time <= timeStamp() and selection.count > 0 then (
      -- format "kage SME callback for % items\n" selection.count
      try (
         sme_selection()
      ) catch (
         format "kage SME callback failed: unknown reason\n"
      )
      --try (
      --   kage_last_obj = (selection[1] as string)
      --) catch (
      --   kage_last_obj = undefined
      --)
   )
)

)--End struct.
