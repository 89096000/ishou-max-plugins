-- vars
_DEBUG_MODE = false
smeview_dir = (GetDir #userScripts) + "\\kageviews\\"
makeDir smeview_dir
xName = smeview_dir + "sme_testing_log.xml"
viewName = "KageSaved"
print xName

-- XML
fileIn "struct_xml.ms"

-- class for node property
struct MaterialNode(
	property,
	value
)

-- class for new node property
struct NewMaterialNode(
	name,
	type,
	posx,
	posy,
	map
)

-- load xml document
/*
xDoc = XMLDocument()
xDoc.file = xName
xDoc.loaded = True
rNode = xDoc.getNewNode "MaxSlateData"
xDoc.AppendNode rnode
rNode = xDoc.getRootNode()
*/


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

-- test loading

yDoc = XMLDocument()
yDoc.LoadXML xName
yRootNode = yDoc.GetRootNode()
childs = yRootNode.GetChildren()



-- cache collect textures
nameList = #()  	-- name list will be used at end to check for used names
textureList = #()	-- texture list is used to find texture mapped to a material
for ch in childs do (
	chAttrs = ch.GetAllAttributes()
	newTexture = NewMaterialNode()
	for item in chAttrs do (
		if item.Name == "name" then (
			newTexture.name = item.Value
			appendIfUnique nameList item.Value
		) else if item.Name == "type" then (
			newTexture.type = item.Value
		) else if item.Name == "posx" then (
			newTexture.posx = item.Value
		) else if item.Name == "posy" then (
			newTexture.posy = item.Value
		) else if item.Name == "map" then (
			newTexture.map = item.Value
		)
	)
	if newTexture.type == "textureMap" do appendIfUnique textureList newTexture
)

-- test making a new view
deleteMe = sme.GetViewByName viewName
sme.DeleteView deleteMe false

newViewIndex = sme.CreateView viewName
newView = sme.GetView newViewIndex
sme.activeView = newViewIndex

mapObjects = #() -- saved index of objects for reference
for ch in childs do (
	chAttrs = ch.GetAllAttributes()
	newMat = NewMaterialNode()

	-- get material attributes
	mmObjects = #()
	for item in chAttrs do (
		if item.Name == "name" then (
			newMat.name = item.Value
		) else if item.Name == "type" then (
			newMat.type = item.Value
		) else if item.Name == "posx" then (
			newMat.posx = item.Value
		) else if item.Name == "posy" then (
			newMat.posy = item.Value
		) else if item.Name == "map" then (
			newMat.map = item.Value
		) else if item.Name == "multimaterial" then (
			append mmObjects item.Value
		) else (
			print ("No Struct Var for " + item.Name + "(" + newMat.type + ")")
		)
	)
	if _DEBUG_MODE do (
		format "New Item: % % [%, %] %\n" newMat.name newMat.type newMat.posx (newMat.posy as string) newMat.map
	)

	-- depending on type, create node
--	if newMat.type == "multimaterial" then (
--		coords = [(newMat.posx as float),(newMat.posy as float)]
--		childCount = ch.GetChildren()
--		newNode = multimaterial numsubs:childCount.Count
--		nn = newView.CreateNode newNode coords
--		nn.name = newMat.name
		-- for mm in mmObjects do print ("multimaterial " + mm)
--	) else if newMat.type == "material" then (
	newNode == undefined
	if newMat.type == "material" then (
		newNode = StandardMaterial()
		coords = [(newMat.posx as float),(newMat.posy as float)]
		nn = newView.CreateNode newNode coords
		nn.name = newMat.name
		if newMat.map != "" do nn.HDRIMapName = newMat.map
	) else if newMat.type == "vray" then (
		newNode = VRayMtl()
		coords = [(newMat.posx as float),(newMat.posy as float)]
		nn = newView.CreateNode newNode coords
		nn.selected = true
		actionMan.executeAction 369891408 "55573"  -- SME: Open / Close Selected Nodes
		nn.selected = false
		nn.name = newMat.name
		if newMat.map != "" do nn.HDRIMapName = newMat.map
	) else if newMat.type == "category" then (
		refPt = findString newMat.name "Material"
		if refPt == undefined do refPt = 10
		if refPt < 2 then (
			-- not a category but just a blank material
		) else (
			newNode = Bezier_Float()
			coords = [(newMat.posx as float),(newMat.posy as float)]
			nn = newView.CreateNode newNode coords
			nn.name = newMat.name
		)
	) else if newMat.type == "vraylight" then (
		/* VRayLightMtl properties
		.color : RGB color
		.multiplier : float
		.texmap : texturemap
		.texmap_on : boolean
		.twoSided (lightMtl_twoSided) : boolean
		.compensate_exposure : boolean
		.opacity_multiplyColor : boolean
		.opacity_texmap (lightmtl_opacity_texmap) : texturemap
		.opacity_texmap_on (lightmtl_opacity_texmap_on) : boolean
		.directLight_on : boolean
		.directLight_subdivs : integer
		.directLight_cutoffThreshold : float
		.displacement_multiplier : float
		.displacement_texmap : texturemap
		.displacement_texmap_on : boolean
		.texmap_resolution : integer
		.texmap_adaptiveness : float
		*/
		newNode = VRayLightMtl()
		coords = [(newMat.posx as float),(newMat.posy as float)]
		nn = newView.CreateNode newNode coords
		nn.selected = true
		actionMan.executeAction 369891408 "55573"  -- SME: Open / Close Selected Nodes
		--nn.DirectX_Manager.dxStdMat = off
		nn.selected = false
		nn.name = newMat.name
		if newMat.map != "" do nn.HDRIMapName = newMat.map
	) else if newMat.type == "textureMap" then (
	) else ( print (newMat.type + " NOT ACCOUNTED FOR")
	)

	-- vray material properties
	if newNode != undefined and newMat.type != "multimaterial" do (
		materialProperties = ch.GetChildren()
		for materialProperty in materialProperties do (
			attr = materialProperty.GetAllAttributes()
			mName = undefined
			mValue = undefined
			for item in attr do (
				if item.Name == "name" then (
					mName = item.Value
				) else if item.Name == "value" then (
					mValue = item.Value
				) else (
					print ("No MaterialProperty Variable for " + item.Name)
				)
			)
			-- format "Material Property % : %\n" mName mValue
			try (
				if newMat.type == "vray" then (
					if mName == "diffuse" then ( newNode.diffuse = ((execute mValue) as color)
					) else if mName == "diffuse_roughness" then ( newNode.diffuse_roughness = (mValue as float)
					) else if mName == "selfIllumination" then ( newNode.selfIllumination = ((execute mValue) as color)
					) else if mName == "selfIllumination_gi" then ( newNode.selfIllumination_gi = (mValue == "true")
					) else if mName == "selfIllumination_multiplier" then ( newNode.selfIllumination_multiplier = (mValue as float)
					) else if mName == "reflection" then ( newNode.reflection = ((execute mValue) as color)
					) else if mName == "reflection_glossiness" then ( newNode.reflection_glossiness = (mValue as float)
					) else if mName == "hilight_glossiness" then ( newNode.hilight_glossiness = (mValue as float)
					) else if mName == "reflection_subdivs" then ( newNode.reflection_subdivs = (mValue as float)
					) else if mName == "reflection_fresnel" then ( newNode.reflection_fresnel = (mValue == "true")
					) else if mName == "reflection_maxDepth" then ( newNode.reflection_maxDepth = (mValue as float)
					) else if mName == "reflection_exitColor" then ( newNode.reflection_exitColor = ((execute mValue) as color)
					) else if mName == "reflection_useInterpolation" then ( newNode.reflection_useInterpolation = (mValue == "true")
					) else if mName == "reflection_ior" then ( newNode.reflection_ior = (mValue as float)
					) else if mName == "reflection_lockGlossiness" then ( newNode.reflection_lockGlossiness = (mValue == "true")
					) else if mName == "reflection_lockIOR" then ( newNode.reflection_lockIOR = (mValue == "true")
					) else if mName == "reflection_dimDistance" then ( newNode.reflection_dimDistance = (mValue as float)
					) else if mName == "reflection_dimDistance_on" then ( newNode.reflection_dimDistance_on = (mValue == "true")
					) else if mName == "reflection_dimDistance_falloff" then ( newNode.reflection_dimDistance_falloff = (mValue as float)
					) else if mName == "reflection_affectAlpha" then ( newNode.reflection_affectAlpha = (mValue as float)
					) else if mName == "refraction" then ( newNode.refraction = ((execute mValue) as color)
					) else if mName == "refraction_glossiness" then ( newNode.refraction_glossiness = (mValue as float)
					) else if mName == "refraction_subdivs" then ( newNode.refraction_subdivs = (mValue as float)
					) else if mName == "refraction_ior" then ( newNode.refraction_ior = (mValue as float)
					) else if mName == "refraction_fogColor" then ( newNode.refraction_fogColor = ((execute mValue) as color)
					) else if mName == "refraction_fogMult" then ( newNode.refraction_fogMult = (mValue as float)
					) else if mName == "refraction_fogBias" then ( newNode.refraction_fogBias = (mValue as float)
					) else if mName == "refraction_affectShadows" then ( newNode.refraction_affectShadows = (mValue == "true")
					) else if mName == "refraction_affectAlpha" then ( newNode.refraction_affectAlpha = (mValue as float)
					) else if mName == "refraction_maxDepth" then ( newNode.refraction_maxDepth = (mValue as float)
					) else if mName == "refraction_exitColor" then ( newNode.refraction_exitColor = ((execute mValue) as color)
					) else if mName == "refraction_useExitColor" then ( newNode.refraction_useExitColor = (mValue == "true")
					) else if mName == "refraction_useInterpolation" then ( newNode.refraction_useInterpolation = (mValue == "true")
					) else if mName == "refraction_dispersion" then ( newNode.refraction_dispersion = (mValue as float)
					) else if mName == "refraction_dispersion_on" then ( newNode.refraction_dispersion_on = (mValue == "true")
					) else if mName == "translucency_on" then ( newNode.translucency_on = (mValue as float)
					) else if mName == "translucency_thickness" then ( newNode.translucency_thickness = (mValue as float)
					) else if mName == "translucency_scatterCoeff" then ( newNode.translucency_scatterCoeff = (mValue as float)
					) else if mName == "translucency_fbCoeff" then ( newNode.translucency_fbCoeff = (mValue as float)
					) else if mName == "translucency_multiplier" then ( newNode.translucency_multiplier = (mValue as float)
					) else if mName == "translucency_color" then ( newNode.translucency_color = ((execute mValue) as color)
					) else if mName == "brdf_type" then ( newNode.brdf_type = (mValue as float)
					) else if mName == "anisotropy" then ( newNode.anisotropy = (mValue as float)
					) else if mName == "anisotropy_rotation" then ( newNode.anisotropy_rotation = (mValue as float)
					) else if mName == "anisotropy_derivation" then ( newNode.anisotropy_derivation = (mValue as float)
					) else if mName == "anisotropy_axis" then ( newNode.anisotropy_axis = (mValue as float)
					) else if mName == "anisotropy_channel" then ( newNode.anisotropy_channel = (mValue as float)
					) else if mName == "soften" then ( newNode.soften = (mValue as float)
					) else if mName == "brdf_fixDarkEdges" then ( newNode.brdf_fixDarkEdges = (mValue == "true")
					) else if mName == "gtr_gamma" then ( newNode.gtr_gamma = (mValue as float)
					) else if mName == "gtr_oldGamma" then ( newNode.gtr_oldGamma = (mValue == "true")
					) else if mName == "brdf_useRoughness" then ( newNode.brdf_useRoughness = (mValue == "true")
					) else if mName == "option_traceDiffuse" then ( newNode.option_traceDiffuse = (mValue == "true")
					) else if mName == "option_traceReflection" then ( newNode.option_traceReflection = (mValue == "true")
					) else if mName == "option_traceRefraction" then ( newNode.option_traceRefraction = (mValue == "true")
					) else if mName == "option_doubleSided" then ( newNode.option_doubleSided = (mValue == "true")
					) else if mName == "option_reflectOnBack" then ( newNode.option_reflectOnBack = (mValue == "true")
					) else if mName == "option_useIrradMap" then ( newNode.option_useIrradMap = (mValue == "true")
					) else if mName == "refraction_fogUnitsScale_on" then ( newNode.refraction_fogUnitsScale_on = (mValue == "true")
					) else if mName == "option_traceDiffuseAndGlossy" then ( newNode.option_traceDiffuseAndGlossy = (mValue as float)
					) else if mName == "option_cutOff" then ( newNode.option_cutOff = (mValue as float)
					) else if mName == "preservationMode" then ( newNode.preservationMode = (mValue as float)
					) else if mName == "option_environment_priority" then ( newNode.option_environment_priority = (mValue as float)
					) else if mName == "effect_id" then ( newNode.effect_id = (mValue as float)
					) else if mName == "override_effect_id" then ( newNode.override_effect_id = (mValue == "true")
					) else if mName == "option_clampTextures" then ( newNode.option_clampTextures = (mValue == "true")
					) else if mName == "option_opacityMode" then ( newNode.option_opacityMode = (mValue as float)
					) else if mName == "option_glossyFresnel" then ( newNode.option_glossyFresnel = (mValue == "true")
					) else if mName == "texmap_diffuse" then ( newNode.texmap_diffuse = make_temp_texture textureList mValue
					) else if mName == "texmap_diffuse_on" then ( newNode.texmap_diffuse_on = (mValue == "true")
					) else if mName == "texmap_diffuse_multiplier" then ( newNode.texmap_diffuse_multiplier = (mValue as float)
					) else if mName == "texmap_reflection" then ( newNode.texmap_reflection = make_temp_texture textureList mValue
					) else if mName == "texmap_reflection_on" then ( newNode.texmap_reflection_on = (mValue == "true")
					) else if mName == "texmap_reflection_multiplier" then ( newNode.texmap_reflection_multiplier = (mValue as float)
					) else if mName == "texmap_refraction" then ( newNode.texmap_refraction = make_temp_texture textureList mValue
					) else if mName == "texmap_refraction_on" then ( newNode.texmap_refraction_on = (mValue == "true")
					) else if mName == "texmap_refraction_multiplier" then ( newNode.texmap_refraction_multiplier = (mValue as float)
					) else if mName == "texmap_bump" then ( newNode.texmap_bump = make_temp_texture textureList mValue
					) else if mName == "texmap_bump_on" then ( newNode.texmap_bump_on = (mValue == "true")
					) else if mName == "texmap_bump_multiplier" then ( newNode.texmap_bump_multiplier = (mValue as float)
					) else if mName == "texmap_reflectionGlossiness" then ( newNode.texmap_reflectionGlossiness = make_temp_texture textureList mValue
					) else if mName == "texmap_reflectionGlossiness_on" then ( newNode.texmap_reflectionGlossiness_on = (mValue == "true")
					) else if mName == "texmap_reflectionGlossiness_multiplier" then ( newNode.texmap_reflectionGlossiness_multiplier = (mValue as float)
					) else if mName == "texmap_refractionGlossiness" then ( newNode.texmap_refractionGlossiness = make_temp_texture textureList mValue
					) else if mName == "texmap_refractionGlossiness_on" then ( newNode.texmap_refractionGlossiness_on = (mValue == "true")
					) else if mName == "texmap_refractionGlossiness_multiplier" then ( newNode.texmap_refractionGlossiness_multiplier = (mValue as float)
					) else if mName == "texmap_refractionIOR" then ( newNode.texmap_refractionIOR = make_temp_texture textureList mValue
					) else if mName == "texmap_refractionIOR_on" then ( newNode.texmap_refractionIOR_on = (mValue == "true")
					) else if mName == "texmap_refractionIOR_multiplier" then ( newNode.texmap_refractionIOR_multiplier = (mValue as float)
					) else if mName == "texmap_displacement" then ( newNode.texmap_displacement = make_temp_texture textureList mValue
					) else if mName == "texmap_displacement_on" then ( newNode.texmap_displacement_on = (mValue == "true")
					) else if mName == "texmap_displacement_multiplier" then ( newNode.texmap_displacement_multiplier = (mValue as float)
					) else if mName == "texmap_translucent" then ( newNode.texmap_translucent = make_temp_texture textureList mValue
					) else if mName == "texmap_translucent_on" then ( newNode.texmap_translucent_on = (mValue == "true")
					) else if mName == "texmap_translucent_multiplier" then ( newNode.texmap_translucent_multiplier = (mValue as float)
					) else if mName == "texmap_environment" then ( newNode.texmap_environment = make_temp_texture textureList mValue
					) else if mName == "texmap_environment_on" then ( newNode.texmap_environment_on = (mValue == "true")
					) else if mName == "texmap_hilightGlossiness" then ( newNode.texmap_hilightGlossiness = make_temp_texture textureList mValue
					) else if mName == "texmap_hilightGlossiness_on" then ( newNode.texmap_hilightGlossiness_on = (mValue == "true")
					) else if mName == "texmap_hilightGlossiness_multiplier" then ( newNode.texmap_hilightGlossiness_multiplier = (mValue as float)
					) else if mName == "texmap_reflectionIOR" then ( newNode.texmap_reflectionIOR = make_temp_texture textureList mValue
					) else if mName == "texmap_reflectionIOR_on" then ( newNode.texmap_reflectionIOR_on = (mValue == "true")
					) else if mName == "texmap_reflectionIOR_multiplier" then ( newNode.texmap_reflectionIOR_multiplier = (mValue as float)
					) else if mName == "texmap_opacity" then ( newNode.texmap_opacity = make_temp_texture textureList mValue
					) else if mName == "texmap_opacity_on" then ( newNode.texmap_opacity_on = (mValue == "true")
					) else if mName == "texmap_opacity_multiplier" then ( newNode.texmap_opacity_multiplier = (mValue as float)
					) else if mName == "texmap_roughness" then ( newNode.texmap_roughness = make_temp_texture textureList mValue
					) else if mName == "texmap_roughness_on" then ( newNode.texmap_roughness_on = (mValue == "true")
					) else if mName == "texmap_roughness_multiplier" then ( newNode.texmap_roughness_multiplier = (mValue as float)
					) else if mName == "texmap_anisotropy" then ( newNode.texmap_anisotropy = make_temp_texture textureList mValue
					) else if mName == "texmap_anisotropy_on" then ( newNode.texmap_anisotropy_on = (mValue == "true")
					) else if mName == "texmap_anisotropy_multiplier" then ( newNode.texmap_anisotropy_multiplier = (mValue as float)
					) else if mName == "texmap_anisotropy_rotation" then ( newNode.texmap_anisotropy_rotation = make_temp_texture textureList mValue
					) else if mName == "texmap_anisotropy_rotation_on" then ( newNode.texmap_anisotropy_rotation_on = (mValue == "true")
					) else if mName == "texmap_anisotropy_rotation_multiplier" then ( newNode.texmap_anisotropy_rotation_multiplier = (mValue as float)
					) else if mName == "texmap_refraction_fog" then ( newNode.texmap_refraction_fog = make_temp_texture textureList mValue
					) else if mName == "texmap_refraction_fog_on" then ( newNode.texmap_refraction_fog_on = (mValue == "true")
					) else if mName == "texmap_refraction_fog_multiplier" then ( newNode.texmap_refraction_fog_multiplier = (mValue as float)
					) else if mName == "texmap_self_illumination" then ( newNode.texmap_self_illumination = make_temp_texture textureList mValue
					) else if mName == "texmap_self_illumination_on" then ( newNode.texmap_self_illumination_on = (mValue == "true")
					) else if mName == "texmap_self_illumination_multiplier" then ( newNode.texmap_self_illumination_multiplier = (mValue as float)
					) else if mName == "reflect_minRate" then ( newNode.reflect_minRate = (mValue as float)
					) else if mName == "reflect_maxRate" then ( newNode.reflect_maxRate = (mValue as float)
					) else if mName == "reflect_interpSamples" then ( newNode.reflect_interpSamples = (mValue as float)
					) else if mName == "reflect_colorThreshold" then ( newNode.reflect_colorThreshold = (mValue as float)
					) else if mName == "reflect_normalThreshold" then ( newNode.reflect_normalThreshold = (mValue as float)
					) else if mName == "refract_minRate" then ( newNode.refract_minRate = (mValue as float)
					) else if mName == "refract_maxRate" then ( newNode.refract_maxRate = (mValue as float)
					) else if mName == "refract_interpSamples" then ( newNode.refract_interpSamples = (mValue as float)
					) else if mName == "refract_colorThreshold" then ( newNode.refract_colorThreshold = (mValue as float)
					) else if mName == "refract_normalThreshold" then ( newNode.refract_normalThreshold = (mValue as float)
					) else (
						print ("Property " + mName + " NOT Accounted for in VRay Material with val " + (mValue as string))
					)
				) else if newMat.type == "vraylight" then (
					if mName == "color" then ( newNode.color = ((execute mValue) as color)
					) else if mName == "multiplier" then ( newNode.multiplier = (mValue as float)
					) else if mName == "texmap" then ( newNode.texmap = make_temp_texture textureList mValue
					) else if mName == "texmap_on" then ( newNode.texmap_on = (mValue == "true")
					) else if mName == "twoSided" then ( newNode.twoSided = (mValue == "true")
					) else if mName == "compensate_exposure" then ( newNode.compensate_exposure = (mValue == "true")
					) else if mName == "opacity_multiplyColor" then ( newNode.opacity_multiplyColor = (mValue == "true")
					) else if mName == "opacity_texmap" then ( newNode.opacity_texmap = make_temp_texture textureList mValue
					) else if mName == "opacity_texmap_on" then ( newNode.opacity_texmap_on = (mValue == "true")
					) else if mName == "directLight_on" then ( newNode.directLight_on = (mValue == "true")
					) else if mName == "directLight_subdivs" then ( newNode.directLight_subdivs = (mValue as float)
					) else if mName == "directLight_cutoffThreshold" then ( newNode.directLight_cutoffThreshold = (mValue as float)
					) else if mName == "displacement_multiplier" then ( newNode.displacement_multiplier = (mValue as float)
					) else if mName == "displacement_texmap" then ( newNode.displacement_texmap = make_temp_texture textureList mValue
					) else if mName == "displacement_texmap_on" then ( newNode.displacement_texmap_on = (mValue == "true")
					) else if mName == "texmap_resolution" then ( newNode.texmap_resolution = (mValue as float)
					) else if mName == "texmap_adaptiveness" then ( newNode.texmap_adaptiveness = (mValue as float)
					) else (
						print ("Property " + mName + " NOT Accounted for in VRay Light Material with val " + (mValue as string))
					)
				)
			) catch (
				print ("Unable to Process " + newMat.type + " Property " + mName + " for Material with val " + (mValue as string))
			)
		) -- end materialProperty for loop

		if newMat.type != "category" do (
			appendIfUnique mapObjects newNode
		)
		
	) --end material handler

/*
	-- multimaterial
	if newNode != undefined and newMat.type == "multimaterial" do (
		materialProperties = ch.GetChildren()
		for materialProperty in materialProperties do (
			attr = materialProperty.GetAllAttributes()
			mName = undefined
			mId = undefined
			mMat = undefined

			for item in attr do (
				if item.Name == "name" then (
					mName = item.Value
				) else if item.Name == "id" then (
					mId = item.Value
				) else if item.Name == "material" then (
					mMat = item.Value
				) else (
					print ("No MultiMaterialProperty Variable for " + item.Name)
				)
			)
			format "MultiSub % : % -- %\n" mName mId mMat

			-- newNode properties - Multimaterial
			--.materialList (Material) : material array
			--.mapEnabled (Map_1_Enable) : boolean array
			--.names (Map) : string array
			--.materialIDList (Index) : int array
			--.material1 (alias for materialList[0])
			
			newNode.names[(mId as integer)] = mName
			mmSlot = newNode[(mId as integer)]
			mmSlot = undefined
		) -- end materialProperty for loop
	) -- end multimaterial handler
*/

) -- end for ch in childs




-- TODO second loop to map children probably not required
for ch in childs do (
	chAttrs = ch.GetAllAttributes()
	newMat = NewMaterialNode()

	-- get material attributes
	mmObjects = #()
	for item in chAttrs do (
		if item.Name == "name" then (
			newMat.name = item.Value
		) else if item.Name == "type" then (
			newMat.type = item.Value
		) else if item.Name == "posx" then (
			newMat.posx = item.Value
		) else if item.Name == "posy" then (
			newMat.posy = item.Value
		) else if item.Name == "map" then (
			newMat.map = item.Value
		) else if item.Name == "multimaterial" then (
			append mmObjects item.Value
		)
	)
	
	-- depending on type, create node
	newNode = undefined
	if newMat.type == "multimaterial" then (
		coords = [(newMat.posx as float),(newMat.posy as float)]
		childCount = ch.GetChildren()
		newNode = multimaterial numsubs:childCount.Count
		nn = newView.CreateNode newNode coords
		nn.name = newMat.name
	)

	-- multimaterial
	if newNode != undefined and newMat.type == "multimaterial" do (
		materialProperties = ch.GetChildren()
		for materialProperty in materialProperties do (
			attr = materialProperty.GetAllAttributes()
			mName = undefined
			mId = undefined
			mMat = undefined

			for item in attr do (
				if item.Name == "name" then (
					mName = item.Value
				) else if item.Name == "id" then (
					mId = item.Value
				) else if item.Name == "material" then (
					mMat = item.Value
				) else (
					print ("No MultiMaterialProperty Variable for " + item.Name)
				)
			)
			if _DEBUG_MODE do (
				format "MultiSub % : % -- %\n" mName mId mMat
			)

			newNode.names[(mId as integer)] = mName
			newNode[(mId as integer)] = undefined
			mMatClean = substring mMat 1 ((findString mMat ":")-1)
			foundObject = false
			sameNameObjects = for o in mapObjects where o.name == mMatClean collect o
			for mo in sameNameObjects do (
				if not foundObject do (
					foundObject = true
					newNode[(mId as integer)] = mo
				)
			)
		) -- end materialProperty for loop
	) -- end multimaterial handler

) -- end for ch in childs



-- clean nodes
newView.SelectNone()
nodes = for n = 1 to newView.GetNumNodes() collect (newView.GetNode n)
for node in nodes do (
	if findItem nameList node.name == 0 do (
		if _DEBUG_MODE do (
			print ("deleting system generated node " + node.name)
		)
		node.selected = true
		newView.DeleteSelection()
	)
)


-- show viewport previews
for mat in (getClassInstances vrayMtl processAllAnimatables:true) do showTextureMap mat on