
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:

Parse.Cloud.useMasterKey();


Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


Parse.Cloud.afterSave(Parse.User, function(request) {

	var userId = request.object.id;
	console.log("userID " + userId);

	var user = new Parse.User();
	user.id = userId;

	console.log("user " + user);

	var facebookFriends = request.object.get('friendsUsingTipsy');

	var friendLookupQuery = new Parse.Query(Parse.User);
	friendLookupQuery.containedIn("facebookID", facebookFriends);

	var installationLookupQuery = new Parse.Query(Parse.Installation);
	installationLookupQuery.equalTo("user", user);

	var userArray = [];
	var installationArray = [];

	friendLookupQuery.find({
		success: function(users) {

			for (i = 0; i < users.length; i++) {
				console.log("user i " + i);
				console.log("user id to push " + users[i].id);
				userArray.push(users[i].id);
			};

			request.object.set('tipsyFriendsUsingTipsy', userArray);
			request.object.save();

			console.log("userArray after id push" + userArray);

			installationLookupQuery.find({
				success: function(installations) {
					for(i = 0; i < installations.length; i++) {
						console.log(installations[i]);
						console.log("userArray to append to installation " + userArray);
						installations[i].set('tipsyFriendsUsingTipsy', userArray);
						installations[i].save();
						console.log(installations[i]);
					};
				},
				error: function(error) {
					console.log("installations save error");
				}
			});

		},
		error: function(error) {
			console.log("friend lookup error");
		}
	});

//	console.log(userArray);


});

Parse.Cloud.afterSave("Plan", function(request){

	// Send push for new heart

	var heartingUsers = [];
	if (typeof request.object.get('heartingUsers') !== "undefined") {
		heartingUsers = request.object.get('heartingUsers');		
	};

	var serverHeartCount = request.object.get('heartCount');

	if (heartingUsers.length > serverHeartCount) {

		var planCreatingUser = request.object.get('creatingUser');
		var planMessage = request.object.get('message');
		var planId = request.object.id;

		console.log("plan " + planId);
		console.log("planMessage " + planMessage);

		var userId = heartingUsers[heartingUsers.length - 1]

		var heartPushQuery = new Parse.Query(Parse.Installation);
		heartPushQuery.equalTo('channels', 'all-'+planId);
		heartPushQuery.notEqualTo('user', planCreatingUser);

		var heartUserQuery = new Parse.Query(Parse.User);
		heartUserQuery.equalTo('objectId', userId);

		var heartUsername = [];

		heartUserQuery.find({
			success: function(users) {
				var user = users[0];
				fullname = user.get("fullname");
				heartUsername.push(fullname);
				firstname = heartUsername[0].split(" ")[0]

				Parse.Push.send({
					where: heartPushQuery,
					data: {
						alert: firstname + " just liked " + planMessage + "!",
						badge: "Increment"
					}
				}, {
					success: function() {
						console.log("success");
					},
					error: function(error) {
						console.log("error");
					}
				});

			},
			error: function(error) {
				console.log("error");
			}
		});

		request.object.set('heartCount', heartingUsers.length);
		request.object.save();
	}
	else {
		request.object.set('heartCount', heartingUsers.length);
		request.object.save();
	};

	// Send push for new attendee

	var attendingUsers = [];
	if (typeof request.object.get('attendingUsers') !== "undefined") {
		attendingUsers = request.object.get('attendingUsers');		
	};

	var serverAttendingCount = request.object.get('attendingCount');

	if (attendingUsers.length > serverAttendingCount) {

		// var planCreatingUser = request.object.get('creatingUser');
		// var planMessage = request.object.get('message');
		// var planId = request.object.id;

		// console.log("plan " + planId);
		// console.log("planMessage " + planMessage);

		// var userId = attendingUsers[attendingUsers.length - 1]

		// var attendingPushQuery = new Parse.Query(Parse.Installation);
		// attendingPushQuery.equalTo('channels', 'join-'+planId);
		// attendingPushQuery.notEqualTo('user', planCreatingUser);

		// var attendingUserQuery = new Parse.Query(Parse.User);
		// attendingUserQuery.equalTo('objectId', userId);

		// var attendingUsername = [];

		// attendingUserQuery.find({
		// 	success: function(users) {
		// 		var user = users[0];
		// 		fullname = user.get("fullname");
		// 		attendingUsername.push(fullname);
		// 		firstname = attendingUsername[0].split(" ")[0]

		// 		Parse.Push.send({
		// 			where: attendingPushQuery,
		// 			data: {
		// 				alert: firstname + " just joined " + planMessage + "!"
		// 			}
		// 		}, {
		// 			success: function() {
		// 				console.log("success");
		// 			},
		// 			error: function(error) {
		// 				console.log("error");
		// 			}
		// 		});

		// 	},
		// 	error: function(error) {
		// 		console.log("error");
		// 	}
		// });

		request.object.set('attendingCount', attendingUsers.length);
		request.object.save();
	}
	else {
		request.object.set('attendingCount', attendingUsers.length);
		request.object.save();
	};



	if (!request.object.existed()) {
		var planMessage = request.object.get('message');
		var planCreatingUser = request.object.get('creatingUser');
		var userId = planCreatingUser.id;
		var planLocation = request.object.get('googlePlaceCoordinate');

		console.log(planLocation);

		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo('channels', 'global');
		pushQuery.notEqualTo('user', planCreatingUser);
		pushQuery.equalTo('tipsyFriendsUsingTipsy', userId);
		pushQuery.withinMiles('latestLocation', planLocation, 20);

// pushQuery plan creating user in array of installation friends

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
						alert: firstname + " just planned " + planMessage + "!",
						badge: "Increment"
					}
				}, {
					success: function() {
						console.log("success");
					},
					error: function(error) {
						console.log("error");
					}
				});

			},
			error: function(error) {
				console.log("error");
			}
		});
	};


// 	if (request.object.get('attendingUsers')) {
// 		var newAttendee = request.object.get('attendingUsers');
// 		var userId = newAttendee[newAttendee.length-1];

// 		console.log("user " + userId);

// 		var planMessage = request.object.get('message');
// 		var planId = request.object.id;

// 		console.log("plan " + planId);
// 		console.log("planMessage " + planMessage);


// 		var pushQuery = new Parse.Query(Parse.Installation);
// 		pushQuery.equalTo('channels', 'join-'+planId);
// //		pushQuery.notEqualTo('user', planCreatingUser);

// 		var userQuery = new Parse.Query(Parse.User);
// 		userQuery.equalTo('objectId', userId);

// 		var username = [];

// 		userQuery.find({
// 			success: function(users) {
// 				var user = users[0];
// 				fullname = user.get("fullname");
// 				username.push(fullname);
// 				firstname = username[0].split(" ")[0]

// 				Parse.Push.send({
// 					where: pushQuery,
// 					data: {
// 						alert: "Attendee list changed for " + planMessage + "!"
// 					}
// 				}, {
// 					success: function() {
// 						console.log("success");
// 					},
// 					error: function(error) {
// 						console.log("error");
// 					}
// 				});

// 			},
// 			error: function(error) {
// 				console.log("error");
// 			}
// 		});

// 	};
});

Parse.Cloud.afterSave("Comment", function(request){

	if (!request.object.existed()) {
		var planCommentingUser = request.object.get('commentingUser');
		var userId = planCommentingUser.id;

		var commentedPlan = request.object.get('commentedPlan');
		var planId = commentedPlan.id;


		var allChannel = "all-" + planId;
		var commentChannel = "comments-" + planId;
		var joinChannel = "comments-" + planId;

		var allQuery = new Parse.Query(Parse.Installation);
		allQuery.equalTo('channels', allChannel);
		allQuery.notEqualTo('user', planCommentingUser);
		

		var commentQuery = new Parse.Query(Parse.Installation);
		commentQuery.equalTo('channels', commentChannel);
		commentQuery.notEqualTo('user', planCommentingUser);

		var joinQuery = new Parse.Query(Parse.Installation);
		joinQuery.equalTo('channels', joinChannel);
		joinQuery.notEqualTo('user', planCommentingUser);

		var pushQuery = Parse.Query.or(allQuery, commentQuery, joinQuery);

		var planQuery = new Parse.Query("Plan");
		planQuery.equalTo('objectId', planId);


		planQuery.find({
			success: function(plans) {
				var plan = plans[0];
				message = plan.get("message");

				Parse.Push.send({
					where: pushQuery,
					data: {
						alert: "New comment on " + message,
						badge: "Increment"
					}
				}, {
					success: function() {
						console.log("success");
					},
					error: function(error) {
						console.log("error");
					}
				});

			},
			error: function(error) {
				console.log("error");
			}
		});

	};
});

// Parse.Cloud.beforeSave("Plan", function(request){

// 	var updateType = request.object.op('attendingUsers').toJSON()["__op"];
// 	console.log("updateType returns " + updateType);

// 	var updateUser = request.object.op('attendingUsers').objects();
// 	console.log("updateUser returns "+ updateUser);


// 	var userId = updateUser;


// 	console.log("user " + userId);

// 	var planMessage = request.object.get('message');
// 	var planId = request.object.id;

// 	console.log("plan " + planId);
// 	console.log("planMessage " + planMessage);

// 	var pushQuery = new Parse.Query(Parse.Installation);
// 	pushQuery.equalTo('channels', 'all-'+planId);

// 	var userQuery = new Parse.Query(Parse.User);
// 	userQuery.equalTo('objectId', '3WjgOvDarX');

// 	var username = [];

// 	userQuery.find({
// 		success: function(users) {
// 			var user = users[0];
// 			fullname = user.get("fullname");
// 			username.push(fullname);
// 			firstname = username[0].split(" ")[0]

// 			Parse.Push.send({
// 				where: pushQuery,
// 				data: {
// 					alert: firstname + " just planned " + planMessage + "!"
// 				}
// 			}, {
// 				success: function() {
// 					console.log("success");
// 				},
// 				error: function(error) {
// 					console.log("error");
// 				}
// 			});

// 		},
// 		error: function(error) {
// 			console.log("error");
// 		}
// 	});




// });