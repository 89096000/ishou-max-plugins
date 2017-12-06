global kage_slate_callbacks;
global kage_slate_zoom;

struct KageSlateCallbacks (

kage_sm_time,
-- kage_last_obj,

function createCallbacks =  (
   callbacks.addScript #selectionSetChanged "KAGE_SME_CALLBACKS.selectionChanged()" id:#kagesme
),

function removeCallbacks = (
   callbacks.removeScripts #selectionSetChanged id:#kagesme;
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
      print "no SME view"
      return undefined
   )

   -- GET LIST OF SELECTED MATERIALS FROM SCENE
   selectedMats = #()
   selectedMatsInView = #()
   for obj in selection do (
      isPoly = (classOf obj) == Editable_Poly
      if isPoly do (
         format "% will convert to poly and then convert back\n" obj.name
         convertToMesh obj
      )

      if obj.material != undefined do (
         if classof obj.material == MultiMaterial then (
            myMats = get_multimaterial_mats obj
            for x in myMats do appendIfUnique selectedMats x
         ) else (
            appendIfUnique selectedMats obj.material
         )
      )

      if isPoly do (
         max undo
      )
   )

   -- GET LIST OF MATERIALS IN SME
   viewNodeCount = curSME.GetNumNodes()
   smeViewMaterials = for n = 1 to viewNodeCount collect (curSME.GetNode n)
   curSME.SelectNone()

   i = 1
   for m in smeViewMaterials do (
      try (
         r = trackViewNodes[#sme][(sme.activeView)][i].reference
      ) catch (
         format "unable to get sme trackViewNodes for %" (i as string)
         exit
      )
      
      if (findItem selectedMats r) > 0 do (
         m.selected = true
         appendIfUnique selectedMatsInView r
      )

      i += 1
   )
         
   -- SET CURRENT EDITOR
   if selectedMatsInView.Count > 0 do (
      --for sm in selectedMatsInView do sme.SetMtlInParamEditor sm
      sme.SetMtlInParamEditor selectedMatsInView[1]
   )
   if selectedMatsInView.Count > 0 do (
      try (
         kage_slate_zoom = ReadFromIni PRODUCT_INFO_INI "settings" "material_select_zoom"
         if kage_slate_zoom != undefined do (
            if kage_slate_zoom == "true" do curSME.ZoomExtents type: #selected
         )
      ) catch (
         print "seomthing wrong with reading zoom file"
      )
   )
),

fn selectionChanged = (
   if kage_sm_time == undefined do kage_sm_time = timeStamp()
   --if kage_last_obj == undefined then (
   --   obj_is_new = true
   --) else (
   --   obj_is_new = kage_last_obj != (selection[1] as string)
   --)

   if selection.count > 25 then (
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
