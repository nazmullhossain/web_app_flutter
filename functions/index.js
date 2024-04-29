const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document('posts/{postId}/comments/{commentId}')
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const commentId = context.params.commentId;

    // Retrieve the post data
    const postSnapshot = await admin.firestore().doc(`posts/${postId}`).get();
    const postData = postSnapshot.data();

    // Retrieve the comment data
    const commentData = snapshot.data();

    // Construct the notification payload
    const payload = {
      notification: {
        title: 'New Comment',
        body: `You have a new comment on your post: "${postData.title}"`,
      },
      data: {
        postId: postId,
        commentId: commentId,
      },
      token: postData.userFcmToken, // Use the FCM token of the post author
    };

    // Send the notification
    return admin.messaging().send(payload);
  });
