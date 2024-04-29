// Check if firebase is already defined
if (typeof firebase === 'undefined') {
  importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js');
  importScripts('https://www.gstatic.com/firebasejs/9.0.0/firebase-messaging-compat.js');
}

const firebaseConfig = {
  apiKey: "AIzaSyBqk8lxm8h9WyGeToWOwiv20o9SYFftr0o",
  authDomain: "web-ksa.firebaseapp.com",
  projectId: "web-ksa",
  storageBucket: "web-ksa.appspot.com",
  messagingSenderId: "486707698602",
  appId: "1:486707698602:web:eaa2142302d090b2d829d3",
  measurementId: "G-7EHR9RLSVX",
};

// Use firebase.default.initializeApp for compatibility
firebase.default.initializeApp(firebaseConfig);
const messaging = firebase.default.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log("Received background message ", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
