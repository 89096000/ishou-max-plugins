-- output message
displayLog = false
changeCount = 0
user_msg = ""
maxCount = 20

-- save names that were used before
usedNames = #()

-- create a list of multimaterial objects
mmAllList = for o in material.classes where (o as string) == "Multimaterial" collect (getClassInstances o processAllAnimatables:true)
mmList = (for o in sceneMaterials where classof(o) == Multimaterial collect o)
for matType in mmAllList do (
	for o in matType do (
		appendIfUnique mmList o
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

		) else (

			if displayLog do (
				format "% is invalid at reference %\n" sm.name (n as string)
			)

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
if changeCount > 0 do ( messageBox user_msg )
