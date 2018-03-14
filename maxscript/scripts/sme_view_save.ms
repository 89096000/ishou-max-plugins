-- Vars
smeview_dir = (GetDir #userScripts) + "\\kageviews\\"
makeDir smeview_dir
xName = smeview_dir + "sme_testing_log.xml"
print xName

-- XML
fileIn "struct_xml.ms"
--fileIn "C:\Users\Orbit-Kwa\Desktop\git\ishous-max-plugins\_KAGE_plugin\maxscript\scripts\struct_xml"

-- class for node property
struct MaterialNode(
	property,
	value
)

-- function for analyzing node properties
fn EvalNodeProperty arr property pname default = (
	-- arr = current property array to check for duplicate values
	-- property = object
	-- pname = property name
	-- default = default value of property (not sure if ill use this to restrict to only certain values)
		
	if (property as string) == default then (
		return undefined
	) else (
		mn = MaterialNode()
		mn.property = pname
		pp = (property as string)
		thisValue = if findString pp ":" == undefined then pp else substring pp 1 ((findString pp ":")-1)
		mn.value = thisValue
		return mn
	)
)



-- save an empty xml document with root node
xDoc = XMLDocument()
xDoc.file = xName
xDoc.loaded = True
rNode = xDoc.getNewNode "MaxSlateData"
xDoc.AppendNode rnode
rNode = xDoc.getRootNode()
xDoc.SaveXML()


-- http://www.scriptspot.com/forums/3ds-max/general-scripting/how-to-loop-the-materials-in-the-slate-material-editor 

start = timestamp()


-- FN to get get multimaterial object (recursive)
fn get_multimaterial_mats obj = (
	matList = #()
	materialsIds = #()
	faces = getNumFaces obj
	maxIndex = faces
	if faces > 24 do maxIndex = 24
	for i = 1 to maxIndex do (
		refId = getFaceMatID obj.mesh i
		appendIfUnique materialsIds refId
	)
	
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
	
	return matList
)

-- FN applies a texture to vray map property
fn make_temp_texture textureList mValue = (
	for t in textureList do (
		if t.name == mValue do (
			bmt = bitmaptexture filename:t.map
			bmt.name = mValue
			return bmt
		)
	)
)

-- FN checks a filename if it has been localized and return full path if it was
fn check_local_map filename = (
	if (substring filename 2 10) == "mapping_fi" then (
		return (maxFilePath + (filename as string))
	) else (
		return filename
	)
)

-- GET LIST OF SELECTED MATERIALS FROM SCENE
selectedMats = #()
-- selectedMats = for obj in selection where obj.material != undefined collect obj.material 
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

-- print "SELECTED MATS"
-- for sm in selectedMats do print sm
-- print "--------------"


-- GET LIST OF MATERIALS IN SME

curSME = sme.GetView (sme.activeView)
if curSME == undefined do (
	print "Slate Material Editor is Not Open"
	return undefined
)
viewNodeCount = curSME.GetNumNodes()
smeViewMaterials = for n = 1 to viewNodeCount collect (curSME.GetNode n)

i = 1
for m in smeViewMaterials do (

	-- default properties
	selectedInScene = false
	mappingFile = ""
	propertiesList = #()

	-- get the sme node reference
	try (
		r = trackViewNodes[#sme][(sme.activeView)][i].reference
	) catch (
		exit
	)

	-- get any vray properties
	rtype = undefined
	if hasProperty r "texmap_diffuse" then (

		rtype = "vray"
		
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.diffuse "diffuse" "(color 225 225 225)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.diffuse_roughness "diffuse_roughness" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.selfIllumination "selfIllumination" "(color 0 0 0)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.selfIllumination_gi "selfIllumination_gi" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.selfIllumination_multiplier "selfIllumination_multiplier" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection "reflection" "(color 0 0 0)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_glossiness "reflection_glossiness" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.hilight_glossiness "hilight_glossiness" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_subdivs "reflection_subdivs" "8")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_fresnel "reflection_fresnel" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_maxDepth "reflection_maxDepth" "5")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_exitColor "reflection_exitColor" "(color 0 0 0)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_useInterpolation "reflection_useInterpolation" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_ior "reflection_ior" "1.6")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_lockGlossiness "reflection_lockGlossiness" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_lockIOR "reflection_lockIOR" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_dimDistance "reflection_dimDistance" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_dimDistance_on "reflection_dimDistance_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_dimDistance_falloff "reflection_dimDistance_falloff" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflection_affectAlpha "reflection_affectAlpha" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction "refraction" "(color 0 0 0)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_glossiness "refraction_glossiness" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_subdivs "refraction_subdivs" "8")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_ior "refraction_ior" "1.6")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_fogColor "refraction_fogColor" "(color 255 255 255)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_fogMult "refraction_fogMult" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_fogBias "refraction_fogBias" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_affectShadows "refraction_affectShadows" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_affectAlpha "refraction_affectAlpha" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_maxDepth "refraction_maxDepth" "5")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_exitColor "refraction_exitColor" "(color 0 0 0)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_useExitColor "refraction_useExitColor" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_useInterpolation "refraction_useInterpolation" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_dispersion "refraction_dispersion" "50.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_dispersion_on "refraction_dispersion_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_on "translucency_on" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_thickness "translucency_thickness" "1000.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_scatterCoeff "translucency_scatterCoeff" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_fbCoeff "translucency_fbCoeff" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_multiplier "translucency_multiplier" "1.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.translucency_color "translucency_color" "(color 255 255 255)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.brdf_type "brdf_type" "1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.anisotropy "anisotropy" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.anisotropy_rotation "anisotropy_rotation" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.anisotropy_derivation "anisotropy_derivation" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.anisotropy_axis "anisotropy_axis" "2")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.anisotropy_channel "anisotropy_channel" "1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.soften "soften" "0.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.brdf_fixDarkEdges "brdf_fixDarkEdges" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.gtr_gamma "gtr_gamma" "2.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.gtr_oldGamma "gtr_oldGamma" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.brdf_useRoughness "brdf_useRoughness" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_traceDiffuse "option_traceDiffuse" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_traceReflection "option_traceReflection" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_traceRefraction "option_traceRefraction" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_doubleSided "option_doubleSided" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_reflectOnBack "option_reflectOnBack" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_useIrradMap "option_useIrradMap" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refraction_fogUnitsScale_on "refraction_fogUnitsScale_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_traceDiffuseAndGlossy "option_traceDiffuseAndGlossy" "1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_cutOff "option_cutOff" "0.001")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.preservationMode "preservationMode" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_environment_priority "option_environment_priority" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.effect_id "effect_id" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.override_effect_id "override_effect_id" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_clampTextures "option_clampTextures" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_opacityMode "option_opacityMode" "0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.option_glossyFresnel "option_glossyFresnel" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_diffuse "texmap_diffuse" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_diffuse_on "texmap_diffuse_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_diffuse_multiplier "texmap_diffuse_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflection "texmap_reflection" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflection_on "texmap_reflection_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflection_multiplier "texmap_reflection_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction "texmap_refraction" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction_on "texmap_refraction_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction_multiplier "texmap_refraction_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_bump "texmap_bump" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_bump_on "texmap_bump_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_bump_multiplier "texmap_bump_multiplier" "30.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionGlossiness "texmap_reflectionGlossiness" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionGlossiness_on "texmap_reflectionGlossiness_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionGlossiness_multiplier "texmap_reflectionGlossiness_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionGlossiness "texmap_refractionGlossiness" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionGlossiness_on "texmap_refractionGlossiness_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionGlossiness_multiplier "texmap_refractionGlossiness_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionIOR "texmap_refractionIOR" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionIOR_on "texmap_refractionIOR_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refractionIOR_multiplier "texmap_refractionIOR_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_displacement "texmap_displacement" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_displacement_on "texmap_displacement_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_displacement_multiplier "texmap_displacement_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_translucent "texmap_translucent" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_translucent_on "texmap_translucent_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_translucent_multiplier "texmap_translucent_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_environment "texmap_environment" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_environment_on "texmap_environment_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_hilightGlossiness "texmap_hilightGlossiness" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_hilightGlossiness_on "texmap_hilightGlossiness_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_hilightGlossiness_multiplier "texmap_hilightGlossiness_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionIOR "texmap_reflectionIOR" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionIOR_on "texmap_reflectionIOR_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_reflectionIOR_multiplier "texmap_reflectionIOR_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_opacity "texmap_opacity" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_opacity_on "texmap_opacity_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_opacity_multiplier "texmap_opacity_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_roughness "texmap_roughness" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_roughness_on "texmap_roughness_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_roughness_multiplier "texmap_roughness_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy "texmap_anisotropy" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy_on "texmap_anisotropy_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy_multiplier "texmap_anisotropy_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy_rotation "texmap_anisotropy_rotation" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy_rotation_on "texmap_anisotropy_rotation_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_anisotropy_rotation_multiplier "texmap_anisotropy_rotation_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction_fog "texmap_refraction_fog" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction_fog_on "texmap_refraction_fog_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_refraction_fog_multiplier "texmap_refraction_fog_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_self_illumination "texmap_self_illumination" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_self_illumination_on "texmap_self_illumination_on" "true")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_self_illumination_multiplier "texmap_self_illumination_multiplier" "100.0")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflect_minRate "reflect_minRate" "-1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflect_maxRate "reflect_maxRate" "-1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflect_interpSamples "reflect_interpSamples" "20")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflect_colorThreshold "reflect_colorThreshold" "0.25")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.reflect_normalThreshold "reflect_normalThreshold" "0.4")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refract_minRate "refract_minRate" "-1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refract_maxRate "refract_maxRate" "-1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refract_interpSamples "refract_interpSamples" "20")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refract_colorThreshold "refract_colorThreshold" "0.25")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.refract_normalThreshold "refract_normalThreshold" "0.4")

	) else if hasProperty r "opacity_texmap" then (

		rtype = "vraylight"
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.color "color" "(color 225 225 225)")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.multiplier "multiplier" "1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap "texmap" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_on "texmap_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.twoSided "twoSided" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.compensate_exposure "compensate_exposure" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.opacity_multiplyColor "opacity_multiplyColor" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.opacity_texmap "opacity_texmap" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.opacity_texmap_on "opacity_texmap_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.directLight_on "directLight_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.directLight_subdivs "directLight_subdivs" "8")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.directLight_cutoffThreshold "directLight_cutoffThreshold" "0.001")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.displacement_multiplier "displacement_multiplier" "1")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.displacement_texmap "displacement_texmap" "undefined")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.displacement_texmap_on "displacement_texmap_on" "false")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_resolution "texmap_resolution" "41")
		appendIfUnique propertiesList (EvalNodeProperty propertiesList r.texmap_adaptiveness "texmap_adaptiveness" "41")

	)

	if findItem propertiesList undefined > 0 do deleteItem propertiesList (findItem propertiesList undefined)
	if rtype == "vray" and propertiesList.Count == 0 do rtype = "category"

	-- check if this sme node is selected in scene
	if (findItem selectedMats r) > 0 do (
		selectedInScene = true
		m.selected = true
	)

	-- write properties of node
	aNode = xDoc.getNewNode "smeNode"
	rNode.AppendNode aNode
	--thisName = if findString m.name ":" == undefined then m.name else substring m.name 1 ((findString m.name ":")-1)
	aNode.AddAttribute "name" m.name

	-- check material type and position
	if rtype == undefined do (
		if superclassof r == material then (
			rtype = if substring (r as string) 2 5 == "Multi" then "multimaterial" else "material"
		) else (
			rtype = "textureMap"
			-- .clipu (Clip_U_Offset) : float
			-- .clipv (Clip_V_Offset) : float
			-- .clipw (Clip_U_Width) : float
			-- .cliph (Clip_V_Width) : float
			-- .jitter (Jitter_Placement) : float
			-- .useJitter : boolean
			-- .apply : boolean
			-- .cropPlace : integer
			-- .filtering : integer
			-- .monoOutput : integer
			-- .rgbOutput : integer
			-- .alphaSource : integer
			-- .preMultAlpha : boolean
			-- .bitmap : bitmap
			-- .coords (Coordinates) : maxObject
			-- .output : maxObject
			-- .fileName (File_Name) : filename
			-- .startTime : time
			-- .playBackRate : float
			-- .endCondition : integer
			-- .tieTimeToMatIDs (Tie_Time_to_Mat_IDs) : boolean
			if hasProperty r "fileName" then (
				mappingFile = check_local_map r.fileName
			) else if hasProperty r "map" then (
				mappingFile = check_local_map r.map.name
			)
		)
	)
	
	aNode.AddAttribute "type" rtype
	aNode.AddAttribute "posx" (m.position[1] as string)
	aNode.AddAttribute "posy" (m.position[2] as string)

	-- check for mapping file
	if hasProperty r "HDRIMapName" do (
		mappingFile = r.HDRIMapName
	)
	aNode.AddAttribute "map" mappingFile

	-- get material list for multimaterials
	if rtype == "multimaterial" and r != undefined do (
		n = 1
		for ml in r.materialList do (
			-- if ml != undefined do append propertiesList ("mm:"+r.names[n]+":"+(ml as string))
			if ml != undefined do (
				aNode.AddAttribute "multimaterial" (r.names[n]+":"+(ml as string))
				mmNode = xDoc.getNewNode "multiMaterialItem"
				aNode.AppendNode mmNode
				mmNode.AddAttribute "id" (n as string)
				mmNode.AddAttribute "name" r.names[n]
				mmNode.AddAttribute "material" (ml as string)
			)
			n += 1
		)
	)
	

	for pl in propertiesList do (
		if pl != undefined do (
			pNode = xDoc.getNewNode "materialProperty"
			aNode.AppendNode pNode
			pNode.AddAttribute "name" pl.property
			pNode.AddAttribute "value" pl.value
		)
	)

	i += 1
)

/*
close f
*/

format "iteration % took % seconds\n" i ((timestamp()-start)/1000.0)


-- back to xml
xDoc.SaveXML()
