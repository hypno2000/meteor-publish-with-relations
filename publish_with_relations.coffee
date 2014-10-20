Meteor.publishWithRelations = (params) ->
	pub = params.handle
	collection = params.collection
	associations = {}
	publishAssoc = (collection, filter, options) ->
		collection.find(filter, options).observeChanges
			added: (id, fields) =>
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
			if mapping.reverse
				objKey = mapping.collection._name
				mapFilter[mapping.key] = id
				# console.log mapFilter
			else
				objKey = mapping.key

				key_map = mapping.key.split "."
				if key_map.length > 1
					if _.isArray obj[key_map[0]]
						ids = []
						_.each key_map, (k,i) ->
							if i is 0 #if start
								ids = _.pluck obj[k],key_map[i+1]

							else if i isnt key_map.length-1 #if not last
								ids = _.flatten ids
								ids = _.pluck ids,key_map[i+1]

						mapFilter._id = 
							$in:ids
				else
					mapFilter._id = obj[mapping.key]

				if _.isArray(mapFilter._id)
					mapFilter._id = {$in: mapFilter._id}

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
				associations[id][objKey] =
					publishAssoc(mapping.collection, mapFilter, mapOptions)

	filter = params.filter
	options = params.options
	collectionHandle = collection.find(filter, options).observeChanges
		added: (id, fields) ->
			pub.added(collection._name, id, fields)
			associations[id] ?= {}
			doMapping(id, fields, params.mappings)
		changed: (id, fields) ->
			_.each fields, (value, key) ->
				changedMappings = _.where(params.mappings, {key: key, reverse: false})
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
