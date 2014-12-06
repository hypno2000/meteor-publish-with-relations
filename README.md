__BREAKING CHANGES:__
* ```key``` is now ```foreign_key```
* ```reverse``` does not exist anymore
_Migrating_:
	If ```reverse:true``` then ```foreign_key:"_id"``` and ```key:yourkey```
	If ```reverse:false``` then ```foreign_key:yourkey```

__This package is an updated version of [tmeasday:publish-with-relations](https://atmospherejs.com/tmeasday/publish-with-relations) the key difference is support for arrays, nested arrays, a friendlier interface, and some bug fixes__

### API
#### Meteor.publishWithRelations(ops) (SERVER SIDE)
Used inside a ```Meteor.publish()``` function to define relations.

__ops.handle:__
  Must always be ```this``` __(REQUIRED)__

__ops.collection:__
	The anchor collection from which relations will be made. __(REQUIRED)__

__ops.filter:__
	The object that filters the collection. This is the equivalent to _filter_ in _collection_.find(_filter_).  __(OPTIONAL)__

__ops.options:__
	The object that sorts and limits the collection. This is the equivalent to _options_ in _collection_.find(_filter_,_options_). __(OPTIONAL)__

__ops.mappings:__
	An array of objects that maps relationships between collections using ```foreign_key``` and ```key``` __(OPTIONAL)__

__ops.mappings[].collection:__
	Defines the collection that will be associated. __(REQUIRED)__

__ops.mappings[].foreign_key:__
	Defines the key to associate with at the parent collection. __(REQUIRED)__

__ops.mappings[].key:__
	Defines the key to associate with at the current collection. __(DEFAULT:"_id")__

__ops.mappings[].filter:__
	The object that filters the collection. This is the equivalent to _filter_ in _collection_.find(_filter_).  __(OPTIONAL)__

__ops.mappings[].options:__
	The object that sorts and limits the collection. This is the equivalent to _options_ in _collection_.find(_filter_,_options_). __(OPTIONAL)__

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

This will publish all ```Things``` and their respective ```DeepThings```, ```SubThings```, ```OtherThings```, and ```ReverseThings```

__IMPORTANT:__ When an association is broken, the package will stop all subscriptions to all broken associations but will not remove the association from the client. This means updates to the object with the broken association will not be recorded BUT the object will persist on the client. New associations will be published as expected. (This should not have an impact unless you are doing something with total published counts).


