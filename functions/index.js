const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccount.json");
admin.initializeApp({credential: admin.credential.cert(serviceAccount)});

exports.sendNotificationOnNewPost = functions.firestore
    .document("post_from_hr/{postId}")
    .onCreate(async (snap, context) => {
      const newValue = snap.data();
      const usersRef = admin.firestore().collection("users");
      const querySnapshot = await usersRef.where("role", "==", "2").get();

      const tokens = [];
      querySnapshot.forEach((doc) => {
        const token = doc.data().fcmToken;
        if (token) {
          tokens.push(token);
        }
      });

      const payload = {
        notification: {
          title: "New Post from HR",
          body: newValue.title,
        },
      };


      if (tokens.length > 0) {
        try {
          const response = await admin.messaging().sendToDevice(tokens,
              payload);
          console.log("Notification sent successfully:", response);
        } catch (error) {
          console.error("Error sending notification:", error);
        }
      } else {
        console.log("No tokens found.");
      }
    });
