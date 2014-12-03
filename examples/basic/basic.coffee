@Things = new Meteor.Collection "things"
	# Schema
	# name:String
	# sub_things:[Object]
	# "sub_things.$.sub_thing":String
	# "sub_things.$.quantity":Number
	# "sub_things.$.deep_things.$.quantity":Number
	# "sub_things.$.deep_things.$.deep_thing":Number

@SubThings = new Meteor.Collection "sub_things"
	# Schema
	# name:String
	# property:String

@DeepThings = new Meteor.Collection "deep_things"
	# Schema
	# name:String
	# property:String

if Meteor.isServer
	Meteor.startup ->
		if Things.find().count() is 0
			# add a particular thing
			Things.insert
				name:"Particular Thing"

			for thing in [0..10]
				subthing = SubThings.insert
					name:"Subthing #{thing}"
					property:Random.id()

				deepthing = DeepThings.insert
					name:"Deepthing #{thing}"
					property:Random.id()

				Things.insert
					name:"Thing #{thing}"
					sub_things:[
						sub_thing:subthing
						quantity:Math.ceil Math.random() * 10
						deep_things:[
							quantity:Math.ceil Math.random() * 10
							deep_thing:deepthing
						]
					]

	Meteor.publish "things", ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			filter:{}
			mappings:[
				key:"sub_things.sub_thing"
				collection:SubThings
			]

	Meteor.publish "thing", (thing) ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			filter:
				_id:thing
			mappings:[
				key:"sub_things.sub_thing"
				collection:SubThings
			]

	Meteor.publish "thing_with_depth", (thing) ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			filter:
				_id:thing
			mappings:[
				{
					key:"sub_things.deep_things.deep_thing"
					collection:DeepThings
				}
				{
					key:"sub_things.sub_thing"
					collection:SubThings
				}
			]


if Meteor.isClient
	# Meteor.subscribe "things"
	# Meteor.subscribe "thing", "6FsKDdztL4t5rtTJ4"
	Meteor.subscribe "thing_with_depth", "CK5fiTEgoKg4TSTtp"









