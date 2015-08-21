// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});




Parse.Cloud.afterSave("Plan", function(request){

	if (!request.object.existed()) {
		var planMessage = request.object.get('message');
		var planCreatingUser = request.object.get('creatingUser');
		var userId = planCreatingUser.id;

		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo('channels', 'global');
	//	pushQuery.notEqualTo('user', planCreatingUser);

		var userQuery = new Parse.Query(Parse.User);
		userQuery.equalTo('objectId', userId);

		var username = [];

		userQuery.find({
			success: function(users) {
				var user = users[0];
				fullname = user.get("fullname");
				username.push(fullname);
				firstname = username[0].split(" ")[0]

				Parse.Push.send({
					where: pushQuery,
					data: {
						alert: firstname + " just planned " + planMessage + "!"
					}
				}, {
					success: function() {
						print("success")
					},
					error: function(error) {
						print("error")
					}
				});

			},
			error: function(error) {
				console.log("error");
			}
		});
	};
});

Parse.Cloud.afterSave("Comment", function(request){

	if (!request.object.existed()) {
		var planCommentingUser = request.object.get('commentingUser');
		var userId = planCommentingUser.id;

		var commentedPlan = request.object.get('commentedPlan');
		var planId = commentedPlan.id;

		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo('channels', planId);
		pushQuery.notEqualTo('user', planCommentingUser);

		var planQuery = new Parse.Query("Plan");
		planQuery.equalTo('objectId', planId);


		planQuery.find({
			success: function(plans) {
				var plan = plans[0];
				message = plan.get("message");

				Parse.Push.send({
					where: pushQuery,
					data: {
						alert: "New comment on " + message + "!"
					}
				}, {
					success: function() {
						print("success")
					},
					error: function(error) {
						print("error")
					}
				});

			},
			error: function(error) {
				console.log("error");
			}
		});

	};
});