const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendNotificationOnNewPost = functions.firestore
    .document("post_from_hr/{postId}")
    .onCreate((snapshot, context) => {
      const newData = snapshot.data();
      const title = newData.title; // Lấy tiêu đề của bài viết mới
      const message = newData.message; // Lấy nội dung của bài viết mới

      // Gửi thông báo tới tất cả các thiết bị đăng ký trên chủ đề "new_post"
      return admin.messaging().sendToTopic("new_post", {
        notification: {
          title: title,
          body: message,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });
