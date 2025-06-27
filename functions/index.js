// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// // For cost control, you can set the maximum number of containers that can be
// // running at the same time. This helps mitigate the impact of unexpected
// // traffic spikes by instead downgrading performance. This limit is a
// // per-function limit. You can override the limit for each function using the
// // `maxInstances` option in the function's options, e.g.
// // `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// // NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// // functions should each use functions.runWith({ maxInstances: 10 }) instead.
// // In the v1 API, each function can only serve one request per container, so
// // this will be the maximum concurrent request count.
// setGlobalOptions({ maxInstances: 10 });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

// 1. Cloud Function to send a notification when a new task is created
exports.onTaskCreated = functions.firestore
    .document("tasks/{taskId}")
    .onCreate(async (snap, context) => {
      const taskData = snap.data();
      const userId = taskData.assignedTo;

      // Get the user's document to find their FCM token
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log(`User document not found for userId: ${userId}`);
        return;
      }

      const fcmToken = userDoc.data().fcmToken;
      if (!fcmToken) {
        console.log(`FCM token not found for userId: ${userId}`);
        return;
      }

      // Create the notification message
      const payload = {
        notification: {
          title: "New Task Assigned!",
          body: `You have a new task: ${taskData.title}`,
          sound: "default",
        },
        data: {
          // This data is what your app will use to navigate
          taskId: context.params.taskId,
        },
      };

      // Send the notification
      try {
        await admin.messaging().sendToDevice(fcmToken, payload);
        console.log("Notification sent successfully!");
      } catch (error) {
        console.error("Error sending notification:", error);
      }
    });


// 2. Scheduled Cloud Function to send due date reminders
// This will run every hour, at the 0th minute.
exports.sendDueDateReminders = functions.pubsub
    .schedule("0 * * * *") // Cron syntax for every hour
    .timeZone("America/New_York") // IMPORTANT: Set to your main timezone
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const tomorrow = new admin.firestore.Timestamp(
          now.seconds + (24 * 60 * 60),
          now.nanoseconds,
      );

      // Query for tasks due in the next 24 hours that aren't completed
      const query = db.collection("tasks")
          .where("isCompleted", "==", false)
          .where("dueDate", ">=", now)
          .where("dueDate", "<=", tomorrow);

      const tasks = await query.get();

      tasks.forEach(async (taskDoc) => {
        const taskData = taskDoc.data();
        const userId = taskData.assignedTo;

        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists && userDoc.data().fcmToken) {
          const fcmToken = userDoc.data().fcmToken;
          const payload = {
            notification: {
              title: "Task Due Soon!",
              body: `Your task "${taskData.title}" is due soon.`,
              sound: "default",
            },
            data: {
              taskId: taskDoc.id,
            },
          };
          try {
            await admin.messaging().sendToDevice(fcmToken, payload);
          } catch (error) {
            console.error("Error sending due date reminder:", error);
          }
        }
      });
      return null;
    });
