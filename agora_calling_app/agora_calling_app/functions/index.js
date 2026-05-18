const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onCallCreated = functions.firestore
  .document("calls/{callId}")
  .onCreate(async (snap, context) => {
    const callData = snap.data();

    const receiverId = callData.receiverId;
    const callerName = callData.callerName;

    // Get receiver's FCM token from users collection
    const receiverDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();

    if (!receiverDoc.exists) {
      console.log("Receiver not found");
      return null;
    }

    const receiverData = receiverDoc.data();
    const fcmToken = receiverData.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token for receiver");
      return null;
    }

    // Send notification to receiver
    const message = {
      token: fcmToken,
      notification: {
        title: "Incoming Call 📞",
        body: `${callerName} is calling you...`,
      },
      data: {
        channelId: callData.channelId,
        callerName: callerName,
        callId: context.params.callId,
        type: "incoming_call",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "incoming_call_channel",
          priority: "max",
          sound: "default",
        },
      },
    };

    try {
      await admin.messaging().send(message);
      console.log("✅ Notification sent to:", callerName);
    } catch (error) {
      console.log("❌ Error sending notification:", error);
    }

    return null;
  });