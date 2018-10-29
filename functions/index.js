const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.searchByCategory = functions.https.onCall((data) => {
  const categoryID = data.categoryID;

  var address = "";
  var dateStart = "";
  var description = "";
  var eventName = "";
  var latitude = "";
  var longitude = "";
  var key = "";
  var obj = {};
  var eventList = [];
  var i = 0;

  var db = admin.database();
  var ref = db.ref("events");
  ref.orderByChild("category").equalTo(categoryID).on("child_added", function(snapshot){
      address = snapshot.val().address;
      dateStart = snapshot.val().dateStart;
      eventName = snapshot.val().eventName;
      description = snapshot.val().description;
      latitude = snapshot.val().latitude;
      longitude = snapshot.val().longitude;
      key = snapshot.key;
      obj = {
        "category": categoryID,
        "address": address,
        "dateStart": dateStart,
        "eventName": eventName,
        "description": description,
        "latitude": latitude,
        "longitude": longitude,
      };
      eventList[i] = obj;
      i = i +1;
  });

  return {
    eventList,
  };
});

exports.searchByDate = functions.https.onCall((data) => {
  const eventDate = data.eventDate;

  var db = admin.database();
  var ref = db.ref("events");

  var obj = {};
  var eventList = [];
  var i = 0;

  ref.orderByChild("dateStart").startAt(eventDate).endAt(eventDate+"\uf8ff").on("child_added", function(snapshot){
    obj = {
      "category": snapshot.val().category,
      "address": snapshot.val().address,
      "dateStart": snapshot.val().dateStart,
      "eventName": snapshot.val().eventName,
      "description": snapshot.val().description,
      "latitude": snapshot.val().latitude,
      "longitude": snapshot.val().longitude,
    };
    eventList[i] = obj;
    i = i + 1;
  });

  return {
    eventList,
  };
});

exports.searchByPrivate = functions.https.onCall((data) => {
  const privateEvent = data.privateEvent;

  var db = admin.database();
  var ref = db.ref("events");
  
  var obj = {};
  var eventList = [];
  var i = 0;

  ref.orderByChild("eventType").equalTo(privateEvent).on("child_added", function(snapshot){
    obj = {
      "category": snapshot.val().category,
      "address": snapshot.val().address,
      "dateStart": snapshot.val().dateStart,
      "eventName": snapshot.val().eventName,
      "eventType": snapshot.val().eventType,
      "description": snapshot.val().description,
      "latitude": snapshot.val().latitude,
      "longitude": snapshot.val().longitude,
    };
    eventList[i] = obj;
    i = i + 1;
  });

  return {
    eventList,
  };
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
