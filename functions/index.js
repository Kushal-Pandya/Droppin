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

exports.searchByFilters = functions.https.onCall((data) => {
  var host = data.host;
  var categoryID = data.categoryID;
  var eventDate = data.eventDate;
  var eventType = data.eventType;

  if(categoryID === ""){
    categoryID = null;
  }

  if(eventDate === ""){
    eventDate = null;
  }

  if(eventType === "All"){
    eventType = null;
  }

  var db = admin.database();
  var ref = db.ref("events");
  
  var obj = {};
  var eventList = [];
  var i = 0;
  var category = "";
  var status = "";
  var creator = "";
  var invites = "";
  var userInvite = "";

  ref.orderByChild("dateStart").startAt(eventDate).endAt(eventDate+"\uf8ff").on("child_added", function(snapshot){
    category = snapshot.val().category;
    status = snapshot.val().eventType;
    creator = snapshot.val().host;
    invites = snapshot.val().invites.split(",");

    function findUser(invite){
        return invite === host;
    }

    userInvite = invites.find(findUser);

    if((category === categoryID || categoryID === null) && (status === eventType || eventType === null) && (creator === host || userInvite === host)) {
      obj = {
        "category": snapshot.val().category,
        "address": snapshot.val().address,
        "dateStart": snapshot.val().dateStart,
        "eventName": snapshot.val().eventName,
        "eventType": snapshot.val().eventType,
        "description": snapshot.val().description,
        "host": snapshot.val().host,
        "invites": snapshot.val().invites,
        "latitude": snapshot.val().latitude,
        "longitude": snapshot.val().longitude,
      };
      eventList[i] = obj;
      i = i + 1;
    }
  });

  return {
    eventList,
  };
});

exports.getEvents = functions.https.onCall((data) => {
  var host = data.host;

  var db = admin.database();
  var ref = db.ref("events");
  
  var obj = {};
  var eventList = [];
  var i = 0;
  var creator = "";
  var status = "";
  var invites = "";
  var userInvite = "";

  ref.orderByChild("dateStart").startAt(null).endAt(null+"\uf8ff").on("child_added", function(snapshot){
    creator = snapshot.val().host;
    invites = snapshot.val().invites.split(",");
    status = snapshot.val().eventType;

    function findUser(invite){
        return invite === host;
    }

    userInvite = invites.find(findUser);

    if(creator === host || userInvite === host || status === "Public") {
      obj = {
        "category": snapshot.val().category,
        "address": snapshot.val().address,
        "dateStart": snapshot.val().dateStart,
        "eventName": snapshot.val().eventName,
        "eventType": snapshot.val().eventType,
        "description": snapshot.val().description,
        "host": snapshot.val().host,
        "invites": snapshot.val().invites,
        "latitude": snapshot.val().latitude,
        "longitude": snapshot.val().longitude,
      };
      eventList[i] = obj;
      i = i + 1;
    }
  });

  return {
    eventList,
  };
});

exports.getHostedEvents = functions.https.onCall((data) => {
  var host = data.host;

  var db = admin.database();
  var ref = db.ref("events");
  
  var obj = {};
  var eventList = [];
  var i = 0;
  var creator = "";

  ref.orderByChild("dateStart").startAt(null).endAt(null+"\uf8ff").on("child_added", function(snapshot){
    creator = snapshot.val().host;

    if(creator === host) {
      obj = {
        "category": snapshot.val().category,
        "address": snapshot.val().address,
        "dateStart": snapshot.val().dateStart,
        "eventName": snapshot.val().eventName,
        "eventType": snapshot.val().eventType,
        "description": snapshot.val().description,
        "host": snapshot.val().host,
        "invites": snapshot.val().invites,
        "latitude": snapshot.val().latitude,
        "longitude": snapshot.val().longitude,
      };
      eventList[i] = obj;
      i = i + 1;
    }
  });

  return {
    eventList,
  };
});

exports.getInvitedEvents = functions.https.onCall((data) => {
  var host = data.host;

  var db = admin.database();
  var ref = db.ref("events");
  
  var obj = {};
  var eventList = [];
  var i = 0;
  var creator = "";
  var status = "";
  var eventDate = "";
  var invites = "";
  var userInvite = "";
  var year = new Date().getFullYear();
  var month = new Date().getMonth();
  var day = new Date().getDate();
  var newDate = "";

  ref.orderByChild("dateStart").startAt(null).endAt(null+"\uf8ff").on("child_added", function(snapshot){
    creator = snapshot.val().host;
    invites = snapshot.val().invites.split(",");
    status = snapshot.val().eventType;
    eventDate = snapshot.val().dateStart.split(" ")[0];
    newEvent = eventDate.split("-");

    function findUser(invite){
        return invite === host;
    }

    userInvite = invites.find(findUser);

    if(userInvite === host && (newEvent[0]>=year && newEvent[1]>=month && newEvent[2]>=day)) {
      obj = {
        "category": snapshot.val().category,
        "address": snapshot.val().address,
        "dateStart": snapshot.val().dateStart,
        "eventName": snapshot.val().eventName,
        "eventType": snapshot.val().eventType,
        "description": snapshot.val().description,
        "host": snapshot.val().host,
        "invites": snapshot.val().invites,
        "latitude": snapshot.val().latitude,
        "longitude": snapshot.val().longitude,
      };
      eventList[i] = obj;
      i = i + 1;
    }
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
