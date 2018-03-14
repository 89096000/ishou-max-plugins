-- name limit
NAME_LIMIT = 10

-- output message
displayLog = false
changeCount = 0
user_msg = ""
maxCount = 20

-- save names that were used before
usedNames = #()

-- if user wishes to also rename maps
RENAME_MAPS = true

-- create a list of multimaterial objects
mmAllList = for o in material.classes where (o as string) == "Multimaterial" collect (getClassInstances o processAllAnimatables:true)
mmList = (for o in sceneMaterials where classof(o) == Multimaterial collect o)
for matType in mmAllList do (
	for o in matType do (
		appendIfUnique mmList o
	)
)

-- fn process find materials in object
fn process_material nstring ml m = (
	if m != undefined do (
		has_smtn = false

		if isProperty m #fileName do (
			if m.fileName != undefined do (
				has_smtn = true
				fname = nstring + "-" + substring (filenameFromPath m.fileName) 1 NAME_LIMIT
				-- format "object % mapped to %\n" (m as string) fname
				m.name = fname
			)
		)

		if isProperty m #map do (
			if m.map != undefined do (
				has_smtn = true
				fname = nstring + "-" + substring (filenameFromPath m.map.fileName) 1 NAME_LIMIT
				m.map.name = fname
			)
		)

		if isProperty m #map1 do (
			if m.map1 != undefined do (
				has_smtn = true
				process_material nstring ml m.map1
			)
		)

		if isProperty m #map2 do (
			if m.map2 != undefined do (
				has_smtn = true
				process_material nstring ml m.map2
			)
		)

		if isProperty m #normal_map do (
			if m.normal_map != undefined do (
				has_smtn = true
				process_material nstring ml m.normal_map
			)
		)

		if isProperty m #bump_map do (
			if m.bump_map != undefined do (
				has_smtn = true
				process_material nstring ml m.bump_map
			)
		)

		-- if not has_smtn do (
		-- 	print ("TESTING" + ml.name)
		-- 	print (classOf ml)
		-- 	format "object % mapped but no file\n" (m as string)
		-- 	showProperties m
		-- )
	)
)

-- loop through multimaterial objects
for sm in mmList do (

	-- loop through multimaterials
	n = 1
	subCount = 0
	overCount = 0
	userSubMsg = ""
	for ml in sm.materialList do (

		-- eval material name
		nstring = (if n > 9 then (n as string) else ("0" + (n as string)))
		if ml != undefined and sm.names[n] != "" then (

			-- new name's params
			if displayLog do (
				format "UPDATING ml.name % with mapping %\n" ml.name sm.names[n]
			)
			new_name = (if sm.names[n] == "" then "(No Name)" else sm.names[n])
			nstring = (if n > 9 then (n as string) else ("0" + (n as string)))
			old_name = ml.name
			new_name = nstring + "-" + new_name

			-- check first 2 chars in name is digits
			txt = substring ml.name 1 2
			try (
				txt = (trimLeft txt "0123456789")
				txt = (trimLeft txt "0123456789")
				firstIsNumber = txt == ""
			) catch (
				firstIsNumber = false
			)

			-- check the third characters is a hyphen
			txt2 = substring ml.name 3 1
			checkHyphen = txt2 == "-"

			-- check if the name was assigned as blank
			txt3 = (ml.name as string)
			nameWasBlank = (findString txt3 "(No Name)") != undefined

			-- check that name wasnt used before
			nameIsUnique = (findItem usedNames old_name) == 0
			appendIfUnique usedNames old_name

			-- if conditions are met, this name was already updated so ignore
			if firstIsNumber and checkHyphen and not nameWasBlank and not nameIsUnique then (
				if displayLog do (
					format "IGNORING index %:name % mapped to ml.name  %\n" (n as string) sm.names[n] ml.name
				)
			) else (

				-- only name
				if ml.name != new_name do (
					ml.name = new_name
					if changeCount <= maxCount then (
						userSubMsg += nstring + " : 「" + old_name + "」は「" + new_name + "」に名前変更した" + "\n"
					) else (
						overCount += 1
					)
					subCount += 1
					changeCount += 1
				)
			)

			-- Rename related map slate material objects
			if RENAME_MAPS do (

				if isProperty ml #texmap_bump do (
					if ml.texmap_diffuse != undefined do process_material nstring ml ml.texmap_diffuse
					if ml.texmap_roughness != undefined do process_material nstring ml ml.texmap_roughness
					if ml.texmap_self_illumination != undefined do process_material nstring ml ml.texmap_self_illumination
					if ml.texmap_reflection != undefined do process_material nstring ml ml.texmap_reflection
					if ml.texmap_hilightGlossiness != undefined do process_material nstring ml ml.texmap_hilightGlossiness
					if ml.texmap_reflectionGlossiness != undefined do process_material nstring ml ml.texmap_reflectionGlossiness
					if ml.texmap_reflectionIOR != undefined do process_material nstring ml ml.texmap_reflectionIOR
					if ml.texmap_anisotropy != undefined do process_material nstring ml ml.texmap_anisotropy
					if ml.texmap_anisotropy_rotation != undefined do process_material ml nstring ml.texmap_anisotropy_rotation
					if ml.texmap_refraction != undefined do process_material nstring ml ml.texmap_refraction
					if ml.texmap_refractionGlossiness != undefined do process_material nstring ml ml.texmap_refractionGlossiness
					if ml.texmap_refractionIOR != undefined do process_material nstring ml ml.texmap_refractionIOR
					if ml.texmap_translucent != undefined do process_material nstring ml ml.texmap_translucent
					if ml.texmap_refraction_fog != undefined do process_material nstring ml ml.texmap_refraction_fog
					if ml.texmap_bump != undefined do process_material nstring ml ml.texmap_bump
					if ml.texmap_displacement != undefined do process_material nstring ml ml.texmap_displacement
					if ml.texmap_opacity != undefined do process_material nstring ml ml.texmap_opacity
					if ml.texmap_environment != undefined do process_material nstring ml ml.texmap_environment
					-- print ml.texmap_diffuse.fileName
				)

				if isProperty ml #frontMtl do (
					if ml.frontMtl != undefined do process_material nstring ml ml.frontMtl
					if ml.backMtl != undefined do process_material nstring ml ml.backMtl
				)

			)

		) else (

			if displayLog do format "% is invalid at reference %\n" sm.name (n as string)

		)
		n += 1
	)

	-- append message if theres anything
	if userSubMsg != "" do (
		user_msg += "\nMaterial Map Renaming Summary for " + sm.name + "\n"
		user_msg += userSubMsg
	)

	-- for messages over the count, just append summary
	if overCount > 0 do (
		user_msg += "他は" + (overCount as string) + "の名前を変更した" + "\n"
	)
)

-- Cycle through one more time look for remaining unnamed list objects
for sm in mmList do (
	materialList = sm.materialList
	n = 1
	for ml in materialList do (
		if sm.names[n] == "" and ml != undefined do (
			prefix = substring ml.name 1 3
			rename_marker = substring ml.name 3 1
			if rename_marker == "-" then (
				x = (substituteString ml.name prefix "")
			) else (
				x = ml.name
			)
			if displayLog do (
				format "RENAME LIST INDEX mapping % to %\n" sm.names[n] x
			)
			sm.names[n] = x
		)
		n += 1
	)
)

-- display change events to user
-- if changeCount > 0 do ( messageBox user_msg )
