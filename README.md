__This package is an updated version of [tmeasday:publish-with-relations](https://atmospherejs.com/tmeasday/publish-with-relations) the key difference is support for arrays, nested arrays, a friendlier interface, and some bug fixes__

### API
#### Meteor.publishWithRelations(ops) (SERVER SIDE)
Used inside a ```Meteor.publish()``` function to define relations.

__ops.handle:__ Must always be ```this``` __(REQUIRED)__
__ops.collection:__ The anchor collection from which relations will be made. __(REQUIRED)__
__ops.mappings:__ An array of objects that maps relationships between collections using ```foreign_key``` and ```key```
__ops.mappings[].collection:__ Defines the collection that will be associated. __(REQUIRED)__
__ops.mappings[].foreign_key:__ Defines the key to associate with at the parent collection. __(REQUIRED)__
__ops.mappings[].key:__ Defines the key to associate with at the current collection. __(DEFAULT:"_id")__

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


