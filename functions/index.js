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

exports.removeEvent = functions.https.onCall((data) => {
  var eventName = data.eventName;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    ref.child(snapshot.key).remove();
  });
});

exports.getEventDetails = functions.https.onCall((data) => {
  var eventName = data.eventName;

  var db = admin.database();
  var ref = db.ref("events");

  var obj = {};
  var eventList = [];
  var i = 0;

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
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
  });

  return {
    eventList,
  };
});

exports.editEvent = functions.https.onCall((data) => {
  var eventName = data.eventName;

  var description = data.description;
  var dateStart = data.dateStart;
  var eventType = data.eventType;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var updates = {};
    updates['/'+snapshot.key+'/description'] = description;
    updates['/'+snapshot.key+'/dateStart'] = dateStart;
    updates['/'+snapshot.key+'/eventType'] = eventType;
    ref.update(updates);
  });
});

exports.acceptInvite = functions.https.onCall((data) => {
  var eventName = data.eventName;
  var email = data.user;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var aData = [];
    if(snapshot.val().accepted.length !== 0){
        aData = snapshot.val().accepted;
    }
    var tData = snapshot.val().tentative;
    var dData = snapshot.val().declined;
    var updates = {};
    var aIndex = aData.indexOf(email);
    var dIndex = dData.indexOf(email);
    var tIndex = tData.indexOf(email);
    if (tIndex > -1){
        tData.splice(tIndex,1);
        if(tData.length === 0){
            updates['/'+snapshot.key+'/tentative'] = "";
        }
        else{
            updates['/'+snapshot.key+'/tentative'] = tData;
        }
    }
    else if (dIndex > -1){
        dData.splice(dIndex,1);
        if(dData.length === 0){
            updates['/'+snapshot.key+'/declined'] = "";
        }
        else{
            updates['/'+snapshot.key+'/declined'] = dData;
        }
    }

    aData.push(email);
    if(aIndex < 0){
        updates['/'+snapshot.key+'/accepted'] = aData;
        ref.update(updates);
    }
    else{
        console.log("User already made this choice");
    }
  });
});

exports.declineInvite = functions.https.onCall((data) => {
  var eventName = data.eventName;
  var email = data.user;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var dData = [];
    if(snapshot.val().declined.length !== 0){
        dData = snapshot.val().dData;
    }
    var aData = snapshot.val().accepted;
    var tData = snapshot.val().tentative;
    var updates = {};
    var i;
    var aIndex = aData.indexOf(email);
    var dIndex = dData.indexOf(email);
    var tIndex = tData.indexOf(email);
    if (aIndex > -1){
        aData.splice(aIndex,1);
        if(aData.length === 0){
            updates['/'+snapshot.key+'/accepted'] = "";
        }
        else{
            updates['/'+snapshot.key+'/accepted'] = aData;
        }
    }
    else if (tIndex > -1){
        tData.splice(tIndex,1);
        if(tData.length === 0){
            updates['/'+snapshot.key+'/tentative'] = "";
        }
        else{
            updates['/'+snapshot.key+'/tentative'] = tData;
        }
    }

    if(dIndex < 0){
        dData.push(email);
        updates['/'+snapshot.key+'/declined'] = dData;
        ref.update(updates);
    }
    else{
        console.log("User already made this choice");
    }
  });
});

exports.tentativeInvite = functions.https.onCall((data) => {
  var eventName = data.eventName;
  var email = data.user;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var tData = [];
    if(snapshot.val().tentative.length !== 0){
        tData = snapshot.val().tentative;
    }
    var aData = snapshot.val().accepted;
    var dData = snapshot.val().declined;
    var updates = {};
    var i;
    var aIndex = aData.indexOf(email);
    var dIndex = dData.indexOf(email);
    var tIndex = tData.indexOf(email);
    if (aIndex > -1){
        aData.splice(aIndex,1);
        if(aData.length === 0){
            updates['/'+snapshot.key+'/accepted'] = "";
        }
        else{
            updates['/'+snapshot.key+'/accepted'] = aData;
        }
    }
    else if (dIndex > -1){
        dData.splice(dIndex,1);
        if(dData.length === 0){
            updates['/'+snapshot.key+'/declined'] = "";
        }
        else{
            updates['/'+snapshot.key+'/declined'] = dData;
        }
    }

    if(tIndex < 0){
        tData.push(email);
        updates['/'+snapshot.key+'/tentative'] = tData;
        ref.update(updates);
    }
    else{
        console.log("User already made this choice");
    }
  });
});

exports.getResponse = functions.https.onCall((data) => {
  var eventName = data.eventName;
  var email = data.user;

  var db = admin.database();
  var ref = db.ref("events");
  var action = "";

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var aData = snapshot.val().accepted;
    var tData = snapshot.val().tentative;
    var dData = snapshot.val().declined;
    var aIndex = aData.indexOf(email);
    var dIndex = dData.indexOf(email);
    var tIndex = tData.indexOf(email);
    if(aIndex > -1){
        action = "accepted";
    }
    else if (dIndex > -1){
        action = "declined";
    }
    else if (tIndex > -1){
        action = "tentative";
    }
    else{
        action = "";
    }
  });

  return {response: action};
});

exports.seenEvent = functions.https.onCall((data) => {
  var eventName = data.eventName;
  var email = data.user;

  var db = admin.database();
  var ref = db.ref("events");

  ref.orderByChild("eventName").equalTo(eventName).on("child_added", function(snapshot){
    var updates = {}
    var seen = "";
    if(snapshot.val().seen === ""){
        seen = email;
    }
    else{
        seen = snapshot.val().seen + "," + email;
    }
    updates['/'+snapshot.key+'/seen'] = seen;
    ref.update(updates);
  });
});

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
