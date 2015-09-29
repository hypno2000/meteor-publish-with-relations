__This package is fork of [hypno2000:publish-with-relations](https://atmospherejs.com/hypno2000/publish-with-relations). This fork fixes a minor bug that threw an error when a published results set changed. Everything else is exactly the same as @hypno2000's version

### Orignal readme

__BREAKING CHANGES:__
* ```key``` is now ```foreign_key```
* ```reverse``` does not exist anymore
* _Migrating_:
	* If ```reverse:false``` then replace ```key:yourkey``` with ```foreign_key:yourkey```

__This package is an updated version of [tmeasday:publish-with-relations](https://atmospherejs.com/tmeasday/publish-with-relations) the key difference is support for arrays, nested arrays, a friendlier interface, and some bug fixes__

### API
#### Meteor.publishWithRelations(ops) (SERVER SIDE)
Used inside a ```Meteor.publish()``` function to define relations.

__ops.handle: (REQUIRED)__  
	Must always be ```this```

__ops.collection: (REQUIRED)__  
	The anchor collection from which relations will be made.

__ops.filter: (OPTIONAL)__  
	The object that filters the collection. This is the equivalent to _filter_ in _collection_.find(_filter_).

__ops.options: (OPTIONAL)__  
	The object that sorts and limits the collection. This is the equivalent to _options_ in _collection_.find(_filter_,_options_).

__ops.mappings: (OPTIONAL)__  
	An array of objects that maps relationships between collections using ```foreign_key``` and ```key```

__ops.mappings[].collection: (REQUIRED)__  
	Defines the collection that will be associated.

__ops.mappings[].foreign_key: (DEFAULT:"_id")__  
	Defines the key to associate with at the parent collection.

__ops.mappings[].key: (DEFAULT:"_id")__  
	Defines the key to associate with at the current collection.

__ops.mappings[].filter: (OPTIONAL)__  
	The object that filters the collection. This is the equivalent to _filter_ in _collection_.find(_filter_).

__ops.mappings[].options: (OPTIONAL)__  
	The object that sorts and limits the collection. This is the equivalent to _options_ in _collection_.find(_filter_,_options_).

### Sample
```coffeescript
Meteor.publish "things", ->
	Meteor.publishWithRelations
		handle:this
		collection:Things
		mappings:[
			{
				foreign_key:"sub_things>deep_things>deep_thing"
				collection:DeepThings
			}
			{
				foreign_key:"sub_things>sub_thing"
				collection:SubThings
			}
			{
				foreign_key:"other_thing"
				collection:OtherThings
			}
			{
				key:"thing"
				collection:ReverseThings
			}
		]
```

This will publish all ```Things``` and their respective ```DeepThings```, ```SubThings```, ```OtherThings```, and ```ReverseThings```

__IMPORTANT:__ When an association is broken, the package will stop all subscriptions to all broken associations but will not remove the association from the client. This means updates to the object with the broken association will not be recorded BUT the object will persist on the client. New associations will be published as expected. (This should not have an impact unless you are doing something with total published counts).


