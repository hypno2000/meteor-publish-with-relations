# NOTES
__This package is an updated version of [tmeasday:publish-with-relations](https://atmospherejs.com/tmeasday/publish-with-relations) the key difference is support for arrays, nested arrays, a friendlier interface, and some bug fixes__

## Install via atmosphere
```meteor add lepozepo:publish-with-relations```

## API
### Meteor.publishWithRelations(ops) (SERVER SIDE)
Used inside a ```Meteor.publish()``` function to define relations.

#### Meteor.publishWithRelations __ops.handle__

### Sample
```coffeescript
	Meteor.publish "things", ->
		Meteor.publishWithRelations
			handle:this
			collection:Things
			mappings:[
				{
					foreign_key:"sub_things.deep_things.deep_thing"
					collection:DeepThings
				}
				{
					foreign_key:"sub_things.sub_thing"
					collection:SubThings
				}
				{
					foreign_key:"other_thing"
					collection:OtherThings
				}
				{
					foreign_key:"_id"
					key:"thing"
					collection:ReverseThings
				}
			]
```

This will publish the post specified by id parameter together
with user profile of its author and a list of ten approved comments
with their author profiles as well.

With one call we publish a post to the ```Posts``` collection, post
comments to the ```Comments``` collection and corresponding authors to
the ```Meteor.users``` collection so we have all the data we need to
display a post.


