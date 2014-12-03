# NOTE
__This package is obsolete now in favor of [cottz:publish-with-relations](https://github.com/Goluis/meteor-publish-with-relations/)__

## Install via atmosphere
```meteor add lepozepo:publish-with-relations```

## API

### Basics

```javascript
  Meteor.publish('post', function(id) {
    Meteor.publishWithRelations({
      handle: this,
      collection: Posts,
      filter: id,
      mappings: [{
        key: 'authorId',
        collection: Meteor.users
      }, {
        reverse: true,
        key: 'postId',
        collection: Comments,
        filter: { approved: true },
        options: {
          limit: 10,
          sort: { createdAt: -1 }
        },
        mappings: [{
          key: 'userId',
          collection: Meteor.users
        }]
      }]
    });
  });
```

This will publish the post specified by id parameter together
with user profile of its author and a list of ten approved comments
with their author profiles as well.

With one call we publish a post to the ```Posts``` collection, post
comments to the ```Comments``` collection and corresponding authors to
the ```Meteor.users``` collection so we have all the data we need to
display a post.


