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

@OtherThings = new Meteor.Collection "other_things"
	# Schema
	# name:String
	# property:String

@ReverseThings = new Meteor.Collection "reverse_things"
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

				otherthing = OtherThings.insert
					name:"Otherthing #{thing}"
					property:Random.id()

				thing_id = Things.insert
					name:"Thing #{thing}"
					other_thing:otherthing
					sub_things:[
						sub_thing:subthing
						quantity:Math.ceil Math.random() * 10
						deep_things:[
							quantity:Math.ceil Math.random() * 10
							deep_thing:deepthing
						]
					]

				ReverseThings.insert
					thing:thing_id
					name:"Reversething #{thing}"
					property:Random.id()


	Meteor.publish "things", ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			mappings:[
				{
					foreign_key:"sub_things.deep_things.deep_thing"
					key:"_id"
					collection:DeepThings
				}
				{
					foreign_key:"sub_things.sub_thing"
					key:"_id"
					collection:SubThings
				}
				{
					foreign_key:"other_thing"
					# key:"_id" #This is optional, defaults to _id
					collection:OtherThings
				}
				{
					foreign_key:"_id"
					key:"thing"
					collection:ReverseThings
				}
			]

	Meteor.publish "things_with_subthings", ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			filter:{}
			mappings:[
				foreign_key:"sub_things.sub_thing"
				collection:SubThings
			]

	Meteor.publish "thing", (thing) ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			filter:
				_id:thing
			mappings:[
				foreign_key:"sub_things.sub_thing"
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
					foreign_key:"sub_things.deep_things.deep_thing"
					collection:DeepThings
				}
				{
					foreign_key:"sub_things.sub_thing"
					collection:SubThings
				}
			]


if Meteor.isClient
	Meteor.subscribe "things"
	# Meteor.subscribe "thing", "FDsQKsZoPgCEpcnWW"
	# Meteor.subscribe "thing_with_depth", "CK5fiTEgoKg4TSTtp"









