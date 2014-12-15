Package.describe({
	name:"hypno:publish-with-relations",
	summary: "Publish associated collections at once.",
	version:"1.2.2",
	git:"https://github.com/hypno/meteor-publish-with-relations"
});

Package.on_use(function(api) {
	api.versionsFrom('METEOR@0.9.2');

	api.use('coffeescript', 'server');
	api.add_files('publish_with_relations.coffee', 'server');
});

Package.on_test(function(api) {
	api.use('lepozepo:publish-with-relations');

	api.add_files('publish_with_relations_test.coffee', 'server');
});