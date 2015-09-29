Meteor.publishWithRelations = (params) ->
	pub = params.handle
	collection = params.collection
	filter = params.filter or {}
	options = params.options or {}

#	console.log '----' + params.collection._name + '----'
#	dumpMap = (mappings) ->
#		for m in mappings
#			_.defaults m,
#				key:"_id"
#				foreign_key:"_id"
#			console.log
#				key: m.key
#				foreign_key: m.foreign_key
#				collection: m.collection._name
#			if m.mappings
#				dumpMap m.mappings
#	dumpMap params.mappings

	associations = {}

	publishAssoc = (collection, filter, options) ->
#		console.log 'publishAssoc', collection._name, filter, options
		collection.find(filter, options).observeChanges
			added: (id, fields) =>
#				console.log 'added', filter, options, id, fields
				pub.added(collection._name, id, fields)
			changed: (id, fields) =>
				pub.changed(collection._name, id, fields)
			removed: (id) =>
				pub.removed(collection._name, id)

	doMapping = (id, obj, mappings) ->
		return unless mappings
		for mapping in mappings
			mapFilter = {}
			mapOptions = {}
			_.defaults mapping,
				key:"_id"
				foreign_key:"_id"

			objKey = mapping.collection._name + '|' + mapping.foreign_key + '|' + mapping.key

			_.extend obj,
				_id:id

			key_map = mapping.foreign_key.split "."
			if key_map.length > 1
				if obj[key_map[0]]
					if _.isArray obj[key_map[0]]
						ids = []
						_.each key_map, (k,i) ->
							if i is 0 #if start
								ids = _.pluck obj[k],key_map[i+1]

							else if i isnt key_map.length-1 #if not last
								ids = _.flatten ids
								ids = _.pluck ids,key_map[i+1]

						mapFilter[mapping.key] =
							$in:ids
					else
						i = obj
						for k in key_map
							break unless i[k]?
							i = i[k]

						mapFilter[mapping.key] = i
				else
					mapFilter = null
			else
				mapFilter[mapping.key] = obj[mapping.foreign_key]

			if mapFilter and mapFilter[mapping.key] and _.isArray(mapFilter[mapping.key])
				mapFilter[mapping.key] = {$in: mapFilter[mapping.key]}

			if mapFilter
				_.extend(mapFilter, mapping.filter)

			_.extend(mapOptions, mapping.options)

			if mapping.mappings
				Meteor.publishWithRelations
					handle: pub
					collection: mapping.collection
					filter: mapFilter
					options: mapOptions
					mappings: mapping.mappings
					_noReady: true
			else
				associations[id][objKey]?.stop()
				# console.log mapFilter
				if mapFilter
					associations[id][objKey] =
						publishAssoc(mapping.collection, mapFilter, mapOptions)


	collectionHandle = collection.find(filter, options).observeChanges
		added: (id, fields) ->
#			console.log 'added', filter, options, id, fields
			pub.added(collection._name, id, fields)
			associations[id] ?= {}
			doMapping(id, fields, params.mappings)
		changed: (id, fields) ->
			_.each _.flatten(fields), (value, key) ->
				changedMappings = _.where(params.mappings, {foreign_key: key})
				doMapping(id, fields, changedMappings)
			pub.changed(collection._name, id, fields)
		removed: (id) ->
			handle.stop() for handle in associations[id]
			pub.removed(collection._name, id)

	pub.ready() unless params._noReady

	pub.onStop ->
		for id, association of associations
			handle.stop() for key, handle of association
		collectionHandle.stop()

